
//
//  MockBarcodeDetectionManager.swift
//  apus
//
//  Created by wa-ik on 2025/08/17
//
import AVFoundation
import UIKit
import Vision

class MockBarcodeDetectionManager: BarcodeDetectionProtocol {
    func detectBarcodes(on image: UIImage, completion: @escaping ([VNBarcodeObservation]) -> Void) {
        completion([])
    }
}
