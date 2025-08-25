//
//  CameraViewModel.swift
//  apus
//
//  Created by Rovo Dev on 28/7/2025.
//

import SwiftUI
import AVFoundation
import Photos
import Combine
import Vision

@MainActor
class CameraViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var capturedImage: UIImage?
    @Published var showingImagePicker = false
    @Published var isFlashOn = false
    @Published var currentZoomFactor: CGFloat = 1.0
    @Published var detectedBarcodes: [VNBarcodeObservation] = []

    // MARK: - Dependencies (Injected)
    @Injected private var cameraManager: any CameraManagerProtocol
    @Injected private var objectDetectionManager: any UnifiedObjectDetectionProtocol
    @Injected private var barcodeDetectionManager: BarcodeDetectionProtocol

    // MARK: - Settings
    @ObservedObject private var appSettings = AppSettings.shared

    // MARK: - Computed Properties
    var isShowingPreview: Binding<Bool> {
        Binding<Bool>(
            get: { self.capturedImage != nil },
            set: { if !$0 { self.capturedImage = nil } }
        )
    }

    var detections: [Detection] {
        // Only return detections if real-time object detection is enabled
        guard appSettings.isRealTimeObjectDetectionEnabled else { return [] }

        // Convert DetectedObject to Detection for backward compatibility
        return objectDetectionManager.lastDetectedObjects.map { detectedObject in
            Detection(
                boundingBox: detectedObject.boundingBox,
                className: detectedObject.className,
                confidence: detectedObject.confidence
            )
        }
    }

    var isRealTimeObjectDetectionEnabled: Bool {
        return appSettings.isRealTimeObjectDetectionEnabled
    }

    var isRealTimeBarcodeDetectionEnabled: Bool {
        return appSettings.isRealTimeBarcodeDetectionEnabled
    }

    // Expose concrete camera manager for UI components that need it
    var concreteCameraManager: CameraManager? {
        return cameraManager as? CameraManager
    }

    var imageSize: CGSize {
        return cameraManager.imageSize
    }

    // MARK: - Initialization
    init() {
        setupBindings()
    }

    // MARK: - Alternative initializer for testing
    init(cameraManager: any CameraManagerProtocol, objectDetectionManager: any UnifiedObjectDetectionProtocol, barcodeDetectionManager: BarcodeDetectionProtocol) {
        // Register test dependencies
        DIContainer.shared.register((any CameraManagerProtocol).self, instance: cameraManager)
        DIContainer.shared.register((any UnifiedObjectDetectionProtocol).self, instance: objectDetectionManager)
        DIContainer.shared.register(BarcodeDetectionProtocol.self, instance: barcodeDetectionManager)
        setupBindings()
    }

    // MARK: - Private Methods
    private func setupBindings() {
        // Set up object detection processing with settings check
        cameraManager.setObjectDetectionHandler { [weak self] pixelBuffer in
            guard let self = self else { return }

            // Convert CVPixelBuffer to UIImage for both object detection and barcode detection
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
            let image = UIImage(cgImage: cgImage)

            if self.appSettings.isRealTimeObjectDetectionEnabled {
                self.objectDetectionManager.detectObjects(in: image) { _ in
                    // The unified protocol handles updating lastDetectedObjects internally
                    // No need to manually update anything here
                }
            }

            if self.appSettings.isRealTimeBarcodeDetectionEnabled {
                self.barcodeDetectionManager.detectBarcodes(on: image) { barcodes in
                    DispatchQueue.main.async {
                        self.detectedBarcodes = barcodes
                    }
                }
            }
        }
    }

    // MARK: - Public Methods
    func startCamera() {
        cameraManager.startSession()
    }

    func stopCamera() {
        cameraManager.stopSession()
    }

    func capturePhoto() {
        cameraManager.capturePhoto { [weak self] image in
            DispatchQueue.main.async {
                self?.capturedImage = image
            }
        }
    }

    func toggleFlash() {
        isFlashOn.toggle()
        cameraManager.toggleFlash()
    }

    func zoom(factor: CGFloat) {
        currentZoomFactor = factor
        cameraManager.zoom(factor: factor)
    }

    func selectImageFromLibrary() {
        showingImagePicker = true
    }

    func handleSelectedImage(_ image: UIImage?) {
        capturedImage = image
        showingImagePicker = false
    }
}
