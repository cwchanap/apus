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

@MainActor
class CameraViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var capturedImage: UIImage?
    @Published var showingImagePicker = false
    @Published var isFlashOn = false
    @Published var currentZoomFactor: CGFloat = 1.0
    @Published var detectedBarcodes: [VNBarcodeObservation] = []

    // MARK: - Dependencies (Injected)
    @Injected private var cameraManager: CameraManagerProtocol
    @Injected private var objectDetectionManager: ObjectDetectionProtocol
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
        return appSettings.isRealTimeObjectDetectionEnabled ? objectDetectionManager.detections : []
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
    init(cameraManager: CameraManagerProtocol, objectDetectionManager: ObjectDetectionProtocol, barcodeDetectionManager: BarcodeDetectionProtocol) {
        // Register test dependencies
        DIContainer.shared.register(CameraManagerProtocol.self, instance: cameraManager)
        DIContainer.shared.register(ObjectDetectionProtocol.self, instance: objectDetectionManager)
        DIContainer.shared.register(BarcodeDetectionProtocol.self, instance: barcodeDetectionManager)
        setupBindings()
    }

    // MARK: - Private Methods
    private func setupBindings() {
        // Set up object detection processing with settings check
        cameraManager.setObjectDetectionHandler { [weak self] pixelBuffer in
            guard let self = self else { return }
            if self.appSettings.isRealTimeObjectDetectionEnabled {
                self.objectDetectionManager.processFrame(pixelBuffer)
            }
            if self.appSettings.isRealTimeBarcodeDetectionEnabled {
                // Convert CVPixelBuffer to UIImage
                let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
                let context = CIContext()
                guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
                let image = UIImage(cgImage: cgImage)
                
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
