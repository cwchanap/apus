//
//  ImageClassificationProtocol.swift
//  apus
//
//  Created by Rovo Dev on 28/7/2025.
//

import Foundation
import UIKit

struct ClassificationResult {
    let identifier: String
    let confidence: Float
}

protocol ImageClassificationProtocol: ObservableObject {
    var isClassifying: Bool { get }
    var lastClassificationResults: [ClassificationResult] { get }
    
    func classifyImage(_ image: UIImage, completion: @escaping (Result<[ClassificationResult], Error>) -> Void)
}

#if DEBUG || targetEnvironment(simulator)
// Mock implementation for simulator and debug builds
class MockImageClassificationManager: ImageClassificationProtocol {
    @Published var isClassifying = false
    @Published var lastClassificationResults: [ClassificationResult] = []
    
    func classifyImage(_ image: UIImage, completion: @escaping (Result<[ClassificationResult], Error>) -> Void) {
        isClassifying = true
        
        // Simulate processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isClassifying = false
            
            // Mock classification results
            let mockResults = [
                ClassificationResult(identifier: "dog", confidence: 0.85),
                ClassificationResult(identifier: "animal", confidence: 0.72),
                ClassificationResult(identifier: "pet", confidence: 0.68)
            ]
            
            self.lastClassificationResults = mockResults
            completion(.success(mockResults))
        }
    }
}

typealias ImageClassificationProvider = MockImageClassificationManager
#else
// Use real Vision framework implementation for device builds
typealias ImageClassificationProvider = ImageClassificationManager
#endif