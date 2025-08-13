//
//  CameraManager.swift
//  apus
//
//  Created by Rovo Dev on 28/7/2025.
//

import Foundation
import AVFoundation
import UIKit
import CoreVideo

class CameraManager: NSObject, ObservableObject, CameraManagerProtocol {
    @Published var isSessionRunning = false
    @Published var isFlashOn = false
    @Published var currentZoomFactor: CGFloat = 1.0

    let session = AVCaptureSession()
    private var videoOutput = AVCaptureVideoDataOutput()
    private var photoOutput = AVCapturePhotoOutput()
    private var videoDevice: AVCaptureDevice?
    private var videoDeviceInput: AVCaptureDeviceInput?

    private var photoCompletionHandler: ((UIImage?) -> Void)?
    private var objectDetectionHandler: ((CVPixelBuffer) -> Void)?

    override init() {
        super.init()
        // Don't setup camera immediately - wait for permission
    }

    private func setupCamera() {
        // Clear any existing configuration
        session.beginConfiguration()
        resetSessionIO()
        session.sessionPreset = .photo

        guard let videoDevice = findAvailableVideoDevice() else {
            print("❌ Failed to get any video device - camera functionality will not work")
            session.commitConfiguration()
            return
        }
        self.videoDevice = videoDevice
        print("✅ Using camera device: \(videoDevice.localizedName)")

        do {
            try configureVideoInput(with: videoDevice)
            configurePhotoOutput()
            configureVideoOutput()
            session.commitConfiguration()
        } catch {
            print("Error setting up camera: \(error)")
            session.commitConfiguration()
        }
    }

    // MARK: - Private helpers (split for testability and lower complexity)
    private func resetSessionIO() {
        for input in session.inputs { session.removeInput(input) }
        for output in session.outputs { session.removeOutput(output) }
    }

    private func findAvailableVideoDevice() -> AVCaptureDevice? {
        // Try back camera first
        if let back = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return back
        }
        // Fallback to front camera (common on simulators)
        if let front = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            print("⚠️ Using front camera (likely running on simulator)")
            return front
        }
        // Any available camera
        if let any = AVCaptureDevice.default(for: .video) {
            print("⚠️ Using default camera device")
            return any
        }
        return nil
    }

    private func configureVideoInput(with device: AVCaptureDevice) throws {
        let deviceInput = try AVCaptureDeviceInput(device: device)
        guard session.canAddInput(deviceInput) else {
            throw NSError(domain: "CameraManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot add video input"])
        }
        session.addInput(deviceInput)
        self.videoDeviceInput = deviceInput
    }

    private func configurePhotoOutput() {
        guard session.canAddOutput(photoOutput) else {
            print("Could not add photo output to the session")
            return
        }
        session.addOutput(photoOutput)
    }

    private func configureVideoOutput() {
        guard session.canAddOutput(videoOutput) else {
            print("Could not add video output to the session")
            return
        }
        session.addOutput(videoOutput)
        let queue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        if let connection = videoOutput.connection(with: .video) {
            connection.isEnabled = true
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
        }
    }

    func startSession() {
        requestCameraPermission()
    }

    private func actuallyStartSession() {
        guard !session.isRunning else {
            DispatchQueue.main.async {
                self.isSessionRunning = true
            }
            return
        }

        // Start session on background queue to avoid blocking UI
        let startSessionWork = { [self] in
            self.session.startRunning()

            // Update UI on main thread
            DispatchQueue.main.async {
                self.isSessionRunning = self.session.isRunning
            }
        }

        if Thread.isMainThread {
            DispatchQueue.global(qos: .userInitiated).async(execute: startSessionWork)
        } else {
            startSessionWork()
        }
    }

    func stopSession() {
        if session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.stopRunning()
                DispatchQueue.main.async {
                    self?.isSessionRunning = false
                }
            }
        }
    }

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        guard session.isRunning else {
            completion(nil)
            return
        }

        guard photoOutput.connection(with: .video) != nil else {
            completion(nil)
            return
        }

        photoCompletionHandler = completion

        let settings = AVCapturePhotoSettings()
        if isFlashOn && photoOutput.supportedFlashModes.contains(.on) {
            settings.flashMode = .on
        } else {
            settings.flashMode = .off
        }

        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func toggleFlash() {
        isFlashOn.toggle()
    }

    func zoom(factor: CGFloat) {
        guard let device = videoDevice else { return }

        do {
            try device.lockForConfiguration()
            let clampedFactor = max(1.0, min(factor, device.activeFormat.videoMaxZoomFactor))
            device.videoZoomFactor = clampedFactor
            currentZoomFactor = clampedFactor
            device.unlockForConfiguration()
        } catch {
            print("Error setting zoom: \(error)")
        }
    }

    func setObjectDetectionHandler(_ handler: @escaping (CVPixelBuffer) -> Void) {
        objectDetectionHandler = handler
    }

    func processFrame(_ pixelBuffer: CVPixelBuffer) {
        objectDetectionHandler?(pixelBuffer)
    }

    private func requestCameraPermission() {
        print("🔍 Checking camera permission...")

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("✅ Camera permission already granted")
            setupCamera()
            actuallyStartSession()
        case .notDetermined:
            print("⚠️ Camera permission not determined, requesting...")
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        print("✅ Camera permission granted by user")
                        self?.setupCamera()
                        self?.actuallyStartSession()
                    } else {
                        print("❌ Camera permission denied by user")
                    }
                }
            }
        case .denied, .restricted:
            print("❌ Camera access denied or restricted")
        @unknown default:
            print("❓ Unknown camera authorization status")
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            photoCompletionHandler?(nil)
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            photoCompletionHandler?(nil)
            return
        }

        photoCompletionHandler?(image)
        photoCompletionHandler = nil
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        processFrame(pixelBuffer)
    }
}
