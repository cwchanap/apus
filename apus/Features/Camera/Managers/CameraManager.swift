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
        setupCamera()
    }
    
    private func setupCamera() {
        session.sessionPreset = .photo
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get video device")
            return
        }
        
        self.videoDevice = videoDevice
        
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            }
            
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }
            
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
                
                videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem))
                
                if let connection = videoOutput.connection(with: .video) {
                    connection.isEnabled = true
                    if connection.isVideoOrientationSupported {
                        connection.videoOrientation = .portrait
                    }
                }
            }
            
        } catch {
            print("Error setting up camera: \(error)")
        }
    }
    
    func startSession() {
        requestCameraPermission()
        if !session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.startRunning()
                DispatchQueue.main.async {
                    self?.isSessionRunning = self?.session.isRunning ?? false
                }
            }
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
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async {
                self.setupCamera()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.setupCamera()
                    }
                }
            }
        case .denied, .restricted:
            print("Camera access denied")
        @unknown default:
            print("Unknown camera authorization status")
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