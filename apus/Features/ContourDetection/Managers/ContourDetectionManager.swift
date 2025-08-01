//
//  ContourDetectionManager.swift
//  apus
//
//  Created by Rovo Dev on 30/7/2025.
//

#if !DEBUG && !targetEnvironment(simulator)
import Foundation
import Vision
import UIKit

class ContourDetectionManager: ObservableObject, ContourDetectionProtocol {
    @Published var isDetecting = false
    @Published var lastDetectedContours: [DetectedContour] = []
    
    func detectContours(in image: UIImage, completion: @escaping (Result<[DetectedContour], Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(ContourDetectionError.invalidImage))
            return
        }
        
        DispatchQueue.main.async {
            self.isDetecting = true
        }
        
        // Create contour detection request for edge detection
        let request = VNDetectContoursRequest { [weak self] request, error in
            DispatchQueue.main.async {
                self?.isDetecting = false
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let observations = request.results as? [VNContoursObservation] else {
                    completion(.failure(ContourDetectionError.processingFailed))
                    return
                }
                
                let contours = self?.processContourObservations(observations, imageSize: image.size) ?? []
                self?.lastDetectedContours = contours
                completion(.success(contours))
            }
        }
        
        // Configure for edge/contour detection
        request.contrastAdjustment = 2.0  // Higher contrast for better edge detection
        request.detectsDarkOnLight = true
        request.maximumImageDimension = 512  // Lower resolution for more contours
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.isDetecting = false
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func processContourObservations(_ observations: [VNContoursObservation], imageSize: CGSize) -> [DetectedContour] {
        var detectedContours: [DetectedContour] = []
        
        for observation in observations {
            // Process all contours (including nested ones) for complete edge detection
            let allContours = getAllContours(from: observation)
            
            for contour in allContours {
                // Convert contour points to normalized coordinates
                let normalizedPoints = contour.normalizedPoints
                
                // Accept contours with fewer points for edge detection
                guard normalizedPoints.count >= 2 else { continue }
                
                // Calculate bounding box
                let boundingBox = calculateBoundingBox(for: normalizedPoints)
                
                // Accept smaller contours for detailed edge detection (0.1% of image area)
                let area = boundingBox.width * boundingBox.height
                guard area > 0.001 else { continue }
                
                // Calculate aspect ratio
                let aspectRatio = boundingBox.width / boundingBox.height
                
                // Create detected contour
                let detectedContour = DetectedContour(
                    points: normalizedPoints,
                    boundingBox: boundingBox,
                    confidence: observation.confidence,
                    aspectRatio: aspectRatio,
                    area: area
                )
                
                detectedContours.append(detectedContour)
            }
        }
        
        // Sort by area and return more contours for detailed edge highlighting
        return Array(detectedContours.sorted { $0.area > $1.area }.prefix(50))
    }
    
    private func getAllContours(from observation: VNContoursObservation) -> [VNContour] {
        var allContours: [VNContour] = []
        
        // Add top-level contours
        allContours.append(contentsOf: observation.topLevelContours)
        
        // Recursively add child contours for complete edge detection
        for topContour in observation.topLevelContours {
            allContours.append(contentsOf: getChildContours(from: topContour))
        }
        
        return allContours
    }
    
    private func getChildContours(from contour: VNContour) -> [VNContour] {
        var childContours: [VNContour] = []
        
        for child in contour.childContours {
            childContours.append(child)
            childContours.append(contentsOf: getChildContours(from: child))
        }
        
        return childContours
    }
    
    private func calculateBoundingBox(for points: [CGPoint]) -> CGRect {
        guard !points.isEmpty else { return .zero }
        
        let minX = points.map { $0.x }.min() ?? 0
        let maxX = points.map { $0.x }.max() ?? 0
        let minY = points.map { $0.y }.min() ?? 0
        let maxY = points.map { $0.y }.max() ?? 0
        
        return CGRect(
            x: minX,
            y: minY,
            width: maxX - minX,
            height: maxY - minY
        )
    }
}

enum ContourDetectionError: Error, LocalizedError {
    case invalidImage
    case processingFailed
    case noContoursFound
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image for contour detection"
        case .processingFailed:
            return "Contour detection processing failed"
        case .noContoursFound:
            return "No contours found in the image"
        }
    }
}

#endif