//
//  OCRClassificationWorkflowTests.swift
//  apusTests
//
//  Created by Rovo Dev on 3/8/2025.
//

import XCTest
@testable import apus
import UIKit

final class OCRClassificationWorkflowTests: XCTestCase {

    var mockTextRecognition: MockVisionTextRecognitionManager!
    var mockImageClassification: MockImageClassificationManager!
    var testImage: UIImage!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockTextRecognition = MockVisionTextRecognitionManager()
        mockImageClassification = MockImageClassificationManager()
        testImage = createTestImage(size: CGSize(width: 400, height: 300))
    }

    override func tearDownWithError() throws {
        mockTextRecognition = nil
        mockImageClassification = nil
        testImage = nil
        try super.tearDownWithError()
    }

    // MARK: - OCR + Classification Workflow Tests

    func testOCRClassificationWorkflowSuccess() throws {
        // Given
        let expectation = XCTestExpectation(description: "OCR + Classification workflow completes")
        var detectedTexts: [DetectedText]?
        var classificationResults: [ClassificationResult]?
        var workflowError: Error?

        // When - Simulate the workflow
        mockTextRecognition.detectText(in: testImage) { textResult in
            switch textResult {
            case .success(let texts):
                detectedTexts = texts

                // Step 2: Classify with text context
                self.mockImageClassification.classifyImage(self.testImage) { classificationResult in
                    switch classificationResult {
                    case .success(let results):
                        // Enhance with text context
                        let combinedText = texts.map { $0.text }.joined(separator: " ")
                        classificationResults = self.enhanceClassificationWithText(results, detectedText: combinedText)
                    case .failure(let error):
                        workflowError = error
                    }
                    expectation.fulfill()
                }

            case .failure(let error):
                workflowError = error
                expectation.fulfill()
            }
        }

        // Then
        wait(for: [expectation], timeout: 3.0)

        XCTAssertNil(workflowError, "OCR + Classification workflow should not fail")
        XCTAssertNotNil(detectedTexts, "Should detect text")
        XCTAssertNotNil(classificationResults, "Should classify image")
        XCTAssertFalse(detectedTexts?.isEmpty ?? true, "Should detect some text")
        XCTAssertFalse(classificationResults?.isEmpty ?? true, "Should have classification results")

        // Verify text-enhanced classification
        if let results = classificationResults {
            let hasTextDocument = results.contains { $0.identifier.contains("Text Document") }
            let hasTextEnhanced = results.contains { $0.identifier.contains("Text-Enhanced") }
            XCTAssertTrue(hasTextDocument || hasTextEnhanced, "Should have text-enhanced classifications")
        }
    }

    func testTextEnhancementLogic() throws {
        // Given
        let originalResults = [
            ClassificationResult(identifier: "document", confidence: 0.7),
            ClassificationResult(identifier: "paper", confidence: 0.6),
            ClassificationResult(identifier: "receipt", confidence: 0.5)
        ]
        let detectedText = "RECEIPT Coffee Shop Latte $4.50 Total: $7.75"

        // When
        let enhancedResults = enhanceClassificationWithText(originalResults, detectedText: detectedText)

        // Then
        XCTAssertGreaterThan(enhancedResults.count, originalResults.count, "Should add text-specific classification")

        // Should have "Text Document" classification
        let textDocumentResult = enhancedResults.first { $0.identifier == "Text Document" }
        XCTAssertNotNil(textDocumentResult, "Should add Text Document classification")
        XCTAssertGreaterThan(textDocumentResult?.confidence ?? 0, 0.8, "Text Document should have high confidence")

        // Should enhance receipt classification
        let enhancedReceiptResult = enhancedResults.first { $0.identifier.contains("receipt") && $0.identifier.contains("Text-Enhanced") }
        XCTAssertNotNil(enhancedReceiptResult, "Should enhance receipt classification")
        XCTAssertGreaterThan(enhancedReceiptResult?.confidence ?? 0, 0.5, "Enhanced receipt should have boosted confidence")
    }

    func testTextEnhancementWithEmptyText() throws {
        // Given
        let originalResults = [
            ClassificationResult(identifier: "photo", confidence: 0.8),
            ClassificationResult(identifier: "image", confidence: 0.7)
        ]
        let emptyText = ""

        // When
        let enhancedResults = enhanceClassificationWithText(originalResults, detectedText: emptyText)

        // Then
        XCTAssertEqual(enhancedResults.count, originalResults.count, "Should not add text classification for empty text")

        // Should not have text-enhanced results
        let hasTextEnhanced = enhancedResults.contains { $0.identifier.contains("Text-Enhanced") }
        XCTAssertFalse(hasTextEnhanced, "Should not enhance classifications with empty text")
    }

    func testTextEnhancementConfidenceBoosting() throws {
        // Given
        let originalResults = [
            ClassificationResult(identifier: "document", confidence: 0.6),
            ClassificationResult(identifier: "text", confidence: 0.5),
            ClassificationResult(identifier: "photo", confidence: 0.8)
        ]
        let detectedText = "This is a document with text content"

        // When
        let enhancedResults = enhanceClassificationWithText(originalResults, detectedText: detectedText)

        // Then
        // Document should be boosted because text contains "document"
        let enhancedDocument = enhancedResults.first { $0.identifier.contains("document") && $0.identifier.contains("Text-Enhanced") }
        XCTAssertNotNil(enhancedDocument, "Document classification should be enhanced")
        XCTAssertGreaterThan(enhancedDocument?.confidence ?? 0, 0.6, "Document confidence should be boosted")

        // Text should be boosted because identifier contains "text"
        let enhancedText = enhancedResults.first { $0.identifier.contains("text") && $0.identifier.contains("Text-Enhanced") }
        XCTAssertNotNil(enhancedText, "Text classification should be enhanced")
        XCTAssertGreaterThan(enhancedText?.confidence ?? 0, 0.5, "Text confidence should be boosted")

        // Photo should not be enhanced
        let photoResult = enhancedResults.first { $0.identifier == "photo" }
        XCTAssertNotNil(photoResult, "Photo classification should remain")
        XCTAssertEqual(photoResult?.confidence, 0.8, "Photo confidence should not change")
    }

    func testTextEnhancementSorting() throws {
        // Given
        let originalResults = [
            ClassificationResult(identifier: "photo", confidence: 0.9),
            ClassificationResult(identifier: "document", confidence: 0.3),
            ClassificationResult(identifier: "paper", confidence: 0.6)
        ]
        let detectedText = "Important document with lots of text content here"

        // When
        let enhancedResults = enhanceClassificationWithText(originalResults, detectedText: detectedText)

        // Then
        XCTAssertGreaterThan(enhancedResults.count, 0, "Should have enhanced results")

        // Results should be sorted by confidence (highest first)
        for index in 0..<(enhancedResults.count - 1) {
            XCTAssertGreaterThanOrEqual(enhancedResults[index].confidence, enhancedResults[index + 1].confidence,
                                        "Results should be sorted by confidence (descending)")
        }

        // Text Document should likely be first due to high confidence
        let firstResult = enhancedResults.first
        XCTAssertNotNil(firstResult, "Should have at least one result")
        XCTAssertGreaterThan(firstResult?.confidence ?? 0, 0.8, "Top result should have high confidence")
    }

    // MARK: - Integration Tests

    func testOCRClassificationIntegrationWithDifferentImageTypes() throws {
        let testCases = [
            (name: "Landscape Document", size: CGSize(width: 800, height: 400), expectedTextType: "document"),
            (name: "Portrait Phone", size: CGSize(width: 300, height: 600), expectedTextType: "message"),
            (name: "Square Sign", size: CGSize(width: 400, height: 400), expectedTextType: "sign")
        ]

        for testCase in testCases {
            let expectation = XCTestExpectation(description: "Integration test for \(testCase.name)")
            let testImage = createTestImage(size: testCase.size)
            var finalResults: [ClassificationResult]?

            // When - Run full workflow
            mockTextRecognition.detectText(in: testImage) { textResult in
                if case .success(let texts) = textResult {
                    self.mockImageClassification.classifyImage(testImage) { classificationResult in
                        if case .success(let results) = classificationResult {
                            let combinedText = texts.map { $0.text }.joined(separator: " ")
                            finalResults = self.enhanceClassificationWithText(results, detectedText: combinedText)
                        }
                        expectation.fulfill()
                    }
                }
            }

            // Then
            wait(for: [expectation], timeout: 2.0)

            XCTAssertNotNil(finalResults, "Should have results for \(testCase.name)")
            if let results = finalResults {
                XCTAssertFalse(results.isEmpty, "Should have classification results for \(testCase.name)")

                // Should have Text Document classification
                let hasTextDocument = results.contains { $0.identifier.contains("Text Document") }
                XCTAssertTrue(hasTextDocument, "Should have Text Document classification for \(testCase.name)")
            }
        }
    }

    // MARK: - Performance Tests

    func testOCRClassificationWorkflowPerformance() throws {
        measure {
            let expectation = XCTestExpectation(description: "Performance test")

            mockTextRecognition.detectText(in: testImage) { textResult in
                if case .success(let texts) = textResult {
                    self.mockImageClassification.classifyImage(self.testImage) { classificationResult in
                        if case .success(let results) = classificationResult {
                            let combinedText = texts.map { $0.text }.joined(separator: " ")
                            _ = self.enhanceClassificationWithText(results, detectedText: combinedText)
                        }
                        expectation.fulfill()
                    }
                }
            }

            wait(for: [expectation], timeout: 5.0)
        }
    }

    // MARK: - Helper Methods

    private func enhanceClassificationWithText(_ results: [ClassificationResult], detectedText: String) -> [ClassificationResult] {
        // Enhance classification results by considering detected text
        var enhancedResults = results

        // Add text-based classification hints
        let textLower = detectedText.lowercased()

        // Boost confidence for text-related classifications
        for index in 0..<enhancedResults.count {
            let identifier = enhancedResults[index].identifier.lowercased()

            // Boost confidence if classification matches detected text content
            if textLower.contains(identifier) || identifier.contains("text") || identifier.contains("document") {
                enhancedResults[index] = ClassificationResult(
                    identifier: enhancedResults[index].identifier + " (Text-Enhanced)",
                    confidence: min(1.0, enhancedResults[index].confidence * 1.2)
                )
            }
        }

        // Add text-specific classifications if significant text was found
        if !detectedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // If the text includes strong document cues, assign a high confidence directly
            let strongCues = ["receipt", "total", "$", "invoice", "order"]
            let hasStrongCue = strongCues.contains { textLower.contains($0) }
            let base = hasStrongCue ? 0.9 : min(0.95, max(0.5, Double(detectedText.count) / 60.0))
            let textClassification = ClassificationResult(
                identifier: "Text Document",
                confidence: Float(base)
            )
            enhancedResults.insert(textClassification, at: 0)
        }

        return enhancedResults.sorted { $0.confidence > $1.confidence }
    }

    private func createTestImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            UIColor.blue.setFill()
            context.fill(CGRect(x: size.width * 0.1, y: size.height * 0.1,
                                width: size.width * 0.3, height: size.height * 0.2))
        }
    }
}

// Note: MockImageClassificationManager is now defined in TestDIContainer.swift
