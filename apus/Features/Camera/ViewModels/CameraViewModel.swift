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
    
    // MARK: - Dependencies (Injected)
    @Injected private var cameraManager: CameraManagerProtocol
    @Injected private var objectDetectionManager: ObjectDetectionProtocol
    
    // MARK: - Computed Properties
    var isShowingPreview: Binding<Bool> {
        Binding<Bool>(
            get: { self.capturedImage != nil },
            set: { if !$0 { self.capturedImage = nil } }
        )
    }
    
    var detections: [Detection] {
        objectDetectionManager.detections
    }
    
    // Expose concrete camera manager for UI components that need it
    var concreteCameraManager: CameraManager {
        return cameraManager as! CameraManager
    }
    
    // MARK: - Initialization
    init() {
        setupBindings()
    }
    
    // MARK: - Alternative initializer for testing
    init(cameraManager: CameraManagerProtocol, objectDetectionManager: ObjectDetectionProtocol) {
        // Register test dependencies
        DIContainer.shared.register(CameraManagerProtocol.self, instance: cameraManager)
        DIContainer.shared.register(ObjectDetectionProtocol.self, instance: objectDetectionManager)
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Set up object detection processing
        cameraManager.setObjectDetectionHandler { [weak self] pixelBuffer in
            self?.objectDetectionManager.processFrame(pixelBuffer)
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