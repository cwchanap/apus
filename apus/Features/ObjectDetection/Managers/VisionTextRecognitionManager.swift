//
//  VisionTextRecognitionManager.swift
//  apus
//
//  Created by Rovo Dev on 3/8/2025.
//

import Foundation
import UIKit
import Vision

/// Manager for text recognition using Apple Vision framework
class VisionTextRecognitionManager: ObservableObject, VisionTextRecognitionProtocol {
    
    func detectText(in image: UIImage, completion: @escaping (Result<[DetectedText], Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            DispatchQueue.main.async {
                completion(.failure(VisionTextRecognitionError.invalidImage))
            }
            return
        }
        
        // Create text recognition request
        let request = VNRecognizeTextRequest { [weak self] request, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    completion(.failure(VisionTextRecognitionError.processingFailed))
                    return
                }
                
                let detectedTexts = self?.processTextObservations(observations, imageSize: image.size) ?? []
                completion(.success(detectedTexts))
            }
        }
        
        // Configure request for optimal text recognition
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.minimumTextHeight = 0.01 // Detect small text
        
        // Set up image orientation
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        
        // Perform the request
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func processTextObservations(_ observations: [VNRecognizedTextObservation], imageSize: CGSize) -> [DetectedText] {
        var detectedTexts: [DetectedText] = []
        
        for observation in observations {
            // Get the top candidate for recognized text
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            
            // Convert Vision coordinates to UIKit coordinates
            let boundingBox = convertVisionToUIKit(
                visionRect: observation.boundingBox,
                imageSize: imageSize
            )
            
            // Get character-level bounding boxes if available
            let characterBoxes = getCharacterBoundingBoxes(
                from: observation,
                text: topCandidate.string,
                imageSize: imageSize
            )
            
            let detectedText = DetectedText(
                text: topCandidate.string,
                boundingBox: boundingBox,
                confidence: topCandidate.confidence,
                characterBoxes: characterBoxes
            )
            
            detectedTexts.append(detectedText)
        }
        
        return detectedTexts
    }
    
    private func convertVisionToUIKit(visionRect: CGRect, imageSize: CGSize) -> CGRect {
        // Vision framework uses bottom-left origin, UIKit uses top-left
        // Vision coordinates are normalized (0-1), we need to convert to image coordinates
        
        let x = visionRect.origin.x * imageSize.width
        let y = (1.0 - visionRect.origin.y - visionRect.height) * imageSize.height
        let width = visionRect.width * imageSize.width
        let height = visionRect.height * imageSize.height
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    private func getCharacterBoundingBoxes(from observation: VNRecognizedTextObservation, text: String, imageSize: CGSize) -> [CGRect] {
        var characterBoxes: [CGRect] = []
        
        // Try to get character-level bounding boxes
        do {
            let range = text.startIndex..<text.endIndex
            if let characterObservations = try observation.boundingBox(for: range) {
                let characterBox = convertVisionToUIKit(
                    visionRect: characterObservations.boundingBox,
                    imageSize: imageSize
                )
                characterBoxes.append(characterBox)
            }
        } catch {
            // If character-level detection fails, use the word-level bounding box
            print("Character-level bounding box detection failed: \(error)")
        }
        
        return characterBoxes
    }
}

// MARK: - Error Types

enum VisionTextRecognitionError: Error, LocalizedError {
    case invalidImage
    case processingFailed
    case noTextFound
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image provided for text recognition"
        case .processingFailed:
            return "Text recognition processing failed"
        case .noTextFound:
            return "No text found in the image"
        }
    }
}

// MARK: - CGImagePropertyOrientation Extension

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}