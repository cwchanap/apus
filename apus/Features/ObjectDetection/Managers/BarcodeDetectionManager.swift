
//
//  BarcodeDetectionManager.swift
//  apus
//
//  Created by wa-ik on 2025/08/17
//
import AVFoundation
import Vision
import UIKit

class BarcodeDetectionManager: BarcodeDetectionProtocol {
    func detectBarcodes(on image: UIImage, completion: @escaping ([VNBarcodeObservation]) -> Void) {
        guard let cgImage = image.cgImage else {
            completion([])
            return
        }

        let request = VNDetectBarcodesRequest {
            request, error in
            if let error = error {
                print("Error detecting barcodes: \(error)")
                completion([])
                return
            }
            
            guard let results = request.results as? [VNBarcodeObservation] else {
                completion([])
                return
            }
            
            completion(results)
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform barcode detection: \(error)")
            completion([])
        }
    }
}
