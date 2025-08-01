//
//  CameraManagerProtocol.swift
//  apus
//
//  Created by Rovo Dev on 28/7/2025.
//

import Foundation
import AVFoundation
import UIKit
import CoreVideo

protocol CameraManagerProtocol: ObservableObject {
    var session: AVCaptureSession { get }
    var isSessionRunning: Bool { get }
    var isFlashOn: Bool { get }
    var currentZoomFactor: CGFloat { get }
    
    func startSession()
    func stopSession()
    func capturePhoto(completion: @escaping (UIImage?) -> Void)
    func toggleFlash()
    func zoom(factor: CGFloat)
    func setObjectDetectionHandler(_ handler: @escaping (CVPixelBuffer) -> Void)
    func processFrame(_ pixelBuffer: CVPixelBuffer)
}