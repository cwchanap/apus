
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
        // Simulate processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let mockBarcodes = self.generateMockBarcodes(for: image)
            completion(mockBarcodes)
        }
    }
    
    private func generateMockBarcodes(for image: UIImage) -> [VNBarcodeObservation] {
        let imageHash = simpleImageHash(image)
        
        // Different mock barcode scenarios
        let scenarios: [[MockBarcodeData]] = [
            // QR Code scenarios
            [
                MockBarcodeData(
                    payload: "https://www.apple.com",
                    symbology: .qr,
                    boundingBox: CGRect(x: 0.2, y: 0.3, width: 0.4, height: 0.4),
                    confidence: 0.95
                )
            ],
            [
                MockBarcodeData(
                    payload: "mailto:contact@example.com",
                    symbology: .qr,
                    boundingBox: CGRect(x: 0.15, y: 0.25, width: 0.5, height: 0.5),
                    confidence: 0.92
                )
            ],
            [
                MockBarcodeData(
                    payload: "WIFI:T:WPA;S:MyNetwork;P:password123;H:false;;",
                    symbology: .qr,
                    boundingBox: CGRect(x: 0.1, y: 0.2, width: 0.6, height: 0.6),
                    confidence: 0.88
                )
            ],
            [
                MockBarcodeData(
                    payload: "tel:+1234567890",
                    symbology: .qr,
                    boundingBox: CGRect(x: 0.25, y: 0.35, width: 0.3, height: 0.3),
                    confidence: 0.91
                )
            ],
            // Traditional barcode scenarios
            [
                MockBarcodeData(
                    payload: "123456789012",
                    symbology: .ean13,
                    boundingBox: CGRect(x: 0.1, y: 0.4, width: 0.8, height: 0.2),
                    confidence: 0.87
                )
            ],
            [
                MockBarcodeData(
                    payload: "SAMPLE123",
                    symbology: .code128,
                    boundingBox: CGRect(x: 0.15, y: 0.45, width: 0.7, height: 0.15),
                    confidence: 0.84
                )
            ],
            // Multiple barcodes
            [
                MockBarcodeData(
                    payload: "https://github.com",
                    symbology: .qr,
                    boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.35, height: 0.35),
                    confidence: 0.93
                ),
                MockBarcodeData(
                    payload: "987654321098",
                    symbology: .ean13,
                    boundingBox: CGRect(x: 0.1, y: 0.6, width: 0.8, height: 0.2),
                    confidence: 0.89
                )
            ]
        ]
        
        let selectedScenario = scenarios[imageHash % scenarios.count]
        return selectedScenario.compactMap { createMockObservation(from: $0) }
    }
    
    private func createMockObservation(from data: MockBarcodeData) -> VNBarcodeObservation? {
        // Create a mock VNBarcodeObservation
        // Note: This is a simplified mock - in real usage, VNBarcodeObservation would be created by Vision framework
        let observation = MockVNBarcodeObservation(
            payload: data.payload,
            symbology: data.symbology,
            boundingBox: data.boundingBox,
            confidence: data.confidence
        )
        return observation
    }
    
    private func simpleImageHash(_ image: UIImage) -> Int {
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        let scale = Int(image.scale * 100)
        return (width * 31 + height * 17 + scale * 7) % 1000
    }
}

// MARK: - Mock Data Structures
private struct MockBarcodeData {
    let payload: String
    let symbology: VNBarcodeSymbology
    let boundingBox: CGRect
    let confidence: Float
}

// MARK: - Mock VNBarcodeObservation
private class MockVNBarcodeObservation: VNBarcodeObservation {
    private let _payloadStringValue: String?
    private let _symbology: VNBarcodeSymbology
    private let _boundingBox: CGRect
    private let _confidence: Float
    
    init(payload: String?, symbology: VNBarcodeSymbology, boundingBox: CGRect, confidence: Float) {
        self._payloadStringValue = payload
        self._symbology = symbology
        self._boundingBox = boundingBox
        self._confidence = confidence
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var payloadStringValue: String? {
        return _payloadStringValue
    }
    
    override var symbology: VNBarcodeSymbology {
        return _symbology
    }
    
    override var boundingBox: CGRect {
        return _boundingBox
    }
    
    override var confidence: VNConfidence {
        return _confidence
    }
}
