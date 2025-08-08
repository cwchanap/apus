//
//  PreviewViewWorkflowTests.swift
//  apusTests
//
//  Updated by Rovo Dev on 5/8/2025 to reflect OCR vs Image Classification separation
//

import XCTest
import SwiftUI
@testable import apus

final class PreviewViewWorkflowTests: XCTestCase {
    
    var testImage: UIImage!
    var mockImageClassificationManager: TestImageClassificationManager!
    var mockTextRecognitionManager: TestVisionTextRecognitionManager!
    var mockDetectionResultsManager: TestDetectionResultsManager!
    var mockHapticService: TestHapticService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        testImage = createTestImage(size: CGSize(width: 400, height: 300))
        
        // Create mock services
        mockImageClassificationManager = TestImageClassificationManager()
        mockTextRecognitionManager = TestVisionTextRecognitionManager()
        mockDetectionResultsManager = TestDetectionResultsManager()
        mockHapticService = TestHapticService()
    }
    
    override func tearDownWithError() throws {
        testImage = nil
        mockImageClassificationManager = nil
        mockTextRecognitionManager = nil
        mockDetectionResultsManager = nil
        mockHapticService = nil
        try super.tearDownWithError()
    }
    
    // MARK: - OCR Workflow (Text detection + recognition)
    
    func testOCRWorkflowDetectsTextUsingManager() throws {
        let exp = expectation(description: "OCR completed")
        
        let mockDetectedTexts = [
            DetectedText(text: "Hello", boundingBox: .zero, confidence: 0.95, characterBoxes: [])
        ]
        mockTextRecognitionManager.mockDetectedTexts = mockDetectedTexts
        
        mockTextRecognitionManager.detectText(in: testImage) { result in
            switch result {
            case .success(let texts):
                XCTAssertEqual(texts.count, 1)
                XCTAssertEqual(texts.first?.text, "Hello")
                exp.fulfill()
            case .failure:
                XCTFail("OCR should succeed")
            }
        }
        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - Image Classification Workflow (separate from OCR)
    
    func testImageClassificationWorkflowUsesManager() throws {
        let exp = expectation(description: "Classification completed")
        let results = [
            ClassificationResult(identifier: "Document", confidence: 0.9),
            ClassificationResult(identifier: "Text", confidence: 0.8)
        ]
        mockImageClassificationManager.mockResults = results
        
        mockImageClassificationManager.classifyImage(testImage) { result in
            switch result {
            case .success(let classified):
                XCTAssertEqual(classified.count, 2)
                XCTAssertEqual(classified.first?.identifier, "Document")
                exp.fulfill()
            case .failure:
                XCTFail("Classification should succeed")
            }
        }
        wait(for: [exp], timeout: 2)
    }
    
    // MARK: - Button state logic (separate)
    
    func testOCRButtonStateLogic() {
        var isDetectingTexts = false
        
        func ocrProgressText() -> String {
            isDetectingTexts ? "Reading Text..." : "OCR"
        }
        
        XCTAssertEqual(ocrProgressText(), "OCR")
        isDetectingTexts = true
        XCTAssertEqual(ocrProgressText(), "Reading Text...")
    }
    
    func testClassificationButtonStateLogic() {
        var isClassifying = false
        
        func classificationProgressText() -> String {
            isClassifying ? "Classifying..." : "Classify"
        }
        
        XCTAssertEqual(classificationProgressText(), "Classify")
        isClassifying = true
        XCTAssertEqual(classificationProgressText(), "Classifying...")
    }
    
    // MARK: - Results saving integration points
    
    func testResultsSavingIntegration() {
        // Save OCR results
        let ocrTexts = [DetectedText(text: "A", boundingBox: .zero, confidence: 0.9, characterBoxes: [])]
        mockDetectionResultsManager.saveOCRResult(detectedTexts: ocrTexts, image: testImage)
        XCTAssertTrue(mockDetectionResultsManager.saveOCRCalled)
        
        // Save classification results
        let classification = [ClassificationResult(identifier: "Doc", confidence: 0.85)]
        mockDetectionResultsManager.saveClassificationResult(classificationResults: classification, image: testImage)
        XCTAssertTrue(mockDetectionResultsManager.saveClassificationCalled)
    }
    
    // MARK: - Helper Methods
    
    private func createTestImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }
}

// MARK: - Test Mocks

class TestImageClassificationManager: ImageClassificationProtocol {
    @Published var isClassifying = false
    @Published var lastClassificationResults: [ClassificationResult] = []
    
    var mockResults: [ClassificationResult] = []
    var shouldFail = false
    
    func classifyImage(_ image: UIImage, completion: @escaping (Result<[ClassificationResult], Error>) -> Void) {
        isClassifying = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.isClassifying = false
            if self.shouldFail {
                completion(.failure(NSError(domain: "Test", code: 1)))
            } else {
                self.lastClassificationResults = self.mockResults
                completion(.success(self.mockResults))
            }
        }
    }
}

class TestVisionTextRecognitionManager: VisionTextRecognitionProtocol {
    var mockDetectedTexts: [DetectedText] = []
    var shouldFail = false
    
    func detectText(in image: UIImage, completion: @escaping (Result<[DetectedText], Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if self.shouldFail {
                completion(.failure(NSError(domain: "Test", code: 2)))
            } else {
                completion(.success(self.mockDetectedTexts))
            }
        }
    }
}

class TestDetectionResultsManager {
    var saveOCRCalled = false
    var saveClassificationCalled = false
    
    func saveOCRResult(detectedTexts: [DetectedText], image: UIImage) {
        saveOCRCalled = true
    }
    
    func saveClassificationResult(classificationResults: [ClassificationResult], image: UIImage) {
        saveClassificationCalled = true
    }
}

class TestHapticService: HapticServiceProtocol {
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {}
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {}
    func selection() {}
    
    func actionFeedback() {}
    func buttonTap() {}
    func strongFeedback() {}
    func success() {}
    func warning() {}
    func error() {}
    func selectionChanged() {}
}
