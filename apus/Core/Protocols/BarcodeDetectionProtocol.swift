
//
//  BarcodeDetectionProtocol.swift
//  apus
//
//  Created by wa-ik on 2025/08/17
//
import AVFoundation
import UIKit

protocol BarcodeDetectionProtocol {
    func detectBarcodes(on image: UIImage, completion: @escaping ([VNBarcodeObservation]) -> Void)
}
