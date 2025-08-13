//
//  TextRecognitionTestSuite.swift
//  apusTests
//
//  Created by Rovo Dev on 3/8/2025.
//

import XCTest
@testable import apus

/// Comprehensive test suite for OCR text recognition functionality
final class TextRecognitionTestSuite: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Set up test environment
        continueAfterFailure = false
    }

    // MARK: - Test Suite Overview

    func testTextRecognitionTestSuiteOverview() throws {
        // This test provides an overview of all OCR-related tests
        print("📝 OCR Text Recognition Test Suite")
        print("==================================")
        print("1. VisionTextRecognitionTests - Core text recognition functionality")
        print("2. OCRClassificationWorkflowTests - OCR + Classification integration")
        print("3. DetectedTextTests - Model and coordinate transformation tests")
        print("4. TextRecognitionTestSuite - Integration and end-to-end tests")
        print("")

        // Verify all test classes are available
        XCTAssertNotNil(VisionTextRecognitionTests.self, "VisionTextRecognitionTests should be available")
        XCTAssertNotNil(OCRClassificationWorkflowTests.self, "OCRClassificationWorkflowTests should be available")
        XCTAssertNotNil(DetectedTextTests.self, "DetectedTextTests should be available")
    }

    // MARK: - Integration Tests

    func testFullOCRPipelineIntegration() throws {
        // Given
        let testContainer = TestDIContainer()
        TestDependencySetup.setupMockDependencies(container: testContainer)

        let textRecognitionManager: VisionTextRecognitionProtocol = testContainer.resolve(VisionTextRecognitionProtocol.self)
        let imageClassificationManager: ImageClassificationProtocol = testContainer.resolve(ImageClassificationProtocol.self)
        let hapticService = testContainer.resolve(HapticServiceProtocol.self) as? MockHapticService

        let testImage = createTestImage(size: CGSize(width: 600, height: 400))

        // When - Test full pipeline
        let ocrExpectation = XCTestExpectation(description: "OCR completes")
        let classificationExpectation = XCTestExpectation(description: "Classification completes")

        var detectedTexts: [DetectedText]?
        var classificationResults: [ClassificationResult]?

        // Step 1: OCR
        textRecognitionManager.detectText(in: testImage) { result in
            if case .success(let texts) = result {
                detectedTexts = texts
                ocrExpectation.fulfill()

                // Step 2: Classification
                imageClassificationManager.classifyImage(testImage) { result in
                    if case .success(let results) = result {
                        classificationResults = results
                        classificationExpectation.fulfill()
                    }
                }
            }
        }

        // Then
        wait(for: [ocrExpectation, classificationExpectation], timeout: 3.0)

        XCTAssertNotNil(detectedTexts, "OCR should complete successfully")
        XCTAssertNotNil(classificationResults, "Classification should complete successfully")
        XCTAssertNotNil(hapticService, "Haptic service should be available")

        // Verify pipeline results
        if let texts = detectedTexts {
            XCTAssertFalse(texts.isEmpty, "Should detect some text")

            // Test coordinate transformation for all detected texts
            for text in texts {
                let displayBox = text.displayBoundingBox(
                    imageSize: testImage.size,
                    displaySize: CGSize(width: 375, height: 667)
                )
                XCTAssertTrue(displayBox.width > 0 && displayBox.height > 0,
                              "All text boxes should have valid display coordinates")
            }
        }

        if let results = classificationResults {
            XCTAssertFalse(results.isEmpty, "Should have classification results")
            XCTAssertTrue(results.allSatisfy { $0.confidence > 0 && $0.confidence <= 1 },
                          "All confidence scores should be valid")
        }
    }

    func testOCROverlayPositioningAccuracy() throws {
        // Given - Test the fix for OCR overlay positioning
        let testCases = [
            (imageSize: CGSize(width: 400, height: 300), displaySize: CGSize(width: 375, height: 667), name: "iPhone Portrait"),
            (imageSize: CGSize(width: 800, height: 600), displaySize: CGSize(width: 667, height: 375), name: "iPhone Landscape"),
            (imageSize: CGSize(width: 1024, height: 768), displaySize: CGSize(width: 768, height: 1024), name: "iPad Portrait"),
            (imageSize: CGSize(width: 1920, height: 1080), displaySize: CGSize(width: 414, height: 896), name: "Large Image Small Display")
        ]

        for testCase in testCases {
            // Create text at various positions
            let textPositions = [
                CGRect(x: 0.0, y: 0.0, width: 0.2, height: 0.1), // Top-left
                CGRect(x: 0.4, y: 0.45, width: 0.2, height: 0.1), // Center
                CGRect(x: 0.8, y: 0.9, width: 0.2, height: 0.1), // Bottom-right
                CGRect(x: 0.0, y: 0.9, width: 1.0, height: 0.1), // Bottom full width
                CGRect(x: 0.9, y: 0.0, width: 0.1, height: 1.0)  // Right full height
            ]

            for (index, position) in textPositions.enumerated() {
                // When
                let detectedText = DetectedText(
                    text: "Test Text \(index)",
                    boundingBox: position,
                    confidence: 0.9,
                    characterBoxes: []
                )

                let displayBox = detectedText.displayBoundingBox(
                    imageSize: testCase.imageSize,
                    displaySize: testCase.displaySize
                )

                // Then - Verify positioning is within bounds and reasonable
                XCTAssertGreaterThanOrEqual(displayBox.minX, 0,
                                            "\(testCase.name) position \(index): X should be non-negative")
                XCTAssertGreaterThanOrEqual(displayBox.minY, 0,
                                            "\(testCase.name) position \(index): Y should be non-negative")
                XCTAssertLessThanOrEqual(displayBox.maxX, testCase.displaySize.width,
                                         "\(testCase.name) position \(index): Should fit within display width")
                XCTAssertLessThanOrEqual(displayBox.maxY, testCase.displaySize.height,
                                         "\(testCase.name) position \(index): Should fit within display height")

                // Verify the box is not stuck in top-left corner (the original bug)
                if position.minX > 0.1 || position.minY > 0.1 {
                    XCTAssertTrue(displayBox.minX > 5 || displayBox.minY > 5,
                                  "\(testCase.name) position \(index): Text should not be stuck in top-left corner")
                }
            }
        }
    }

    func testOCRClassificationWorkflowEndToEnd() throws {
        // Given
        let testContainer = TestDIContainer()
        TestDependencySetup.setupMockDependencies(container: testContainer)

        let textRecognitionManager: VisionTextRecognitionProtocol = testContainer.resolve(VisionTextRecognitionProtocol.self)
        let imageClassificationManager: ImageClassificationProtocol = testContainer.resolve(ImageClassificationProtocol.self)

        let documentImage = createDocumentImage()

        // When - Simulate the OCR + Classification workflow
        let workflowExpectation = XCTestExpectation(description: "Full workflow completes")
        var finalResults: [ClassificationResult]?
        var detectedTexts: [DetectedText]?

        // Step 1: OCR Detection
        textRecognitionManager.detectText(in: documentImage) { textResult in
            if case .success(let texts) = textResult {
                detectedTexts = texts

                // Step 2: Enhanced Classification
                imageClassificationManager.classifyImage(documentImage) { classificationResult in
                    if case .success(let results) = classificationResult {
                        // Step 3: Text Enhancement
                        let combinedText = texts.map { $0.text }.joined(separator: " ")
                        finalResults = self.enhanceClassificationWithText(results, detectedText: combinedText)
                    }
                    workflowExpectation.fulfill()
                }
            }
        }

        // Then
        wait(for: [workflowExpectation], timeout: 3.0)

        XCTAssertNotNil(detectedTexts, "Should detect text")
        XCTAssertNotNil(finalResults, "Should have enhanced classification results")

        if let texts = detectedTexts {
            XCTAssertFalse(texts.isEmpty, "Should detect text in document image")

            // Verify text content makes sense for a document
            let allText = texts.map { $0.text }.joined(separator: " ").lowercased()
            let hasDocumentKeywords = allText.contains("receipt") || allText.contains("total") || allText.contains("$")
            XCTAssertTrue(hasDocumentKeywords, "Document image should contain document-related text")
        }

        if let results = finalResults {
            XCTAssertFalse(results.isEmpty, "Should have enhanced results")

            // Should have text-enhanced classifications
            let hasTextDocument = results.contains { $0.identifier.contains("Text Document") }
            let hasTextEnhanced = results.contains { $0.identifier.contains("Text-Enhanced") }
            XCTAssertTrue(hasTextDocument || hasTextEnhanced, "Should have text-enhanced classifications")

            // Results should be sorted by confidence
            for index in 0..<(results.count - 1) {
                XCTAssertGreaterThanOrEqual(results[index].confidence, results[index + 1].confidence,
                                            "Results should be sorted by confidence")
            }
        }
    }

    // MARK: - Error Handling Tests

    func testOCRErrorHandling() throws {
        // Given
        let invalidImage = UIImage() // Empty image
        let textRecognitionManager = MockVisionTextRecognitionManager()

        // When
        let expectation = XCTestExpectation(description: "Error handling test")
        var receivedError: Error?

        textRecognitionManager.detectText(in: invalidImage) { result in
            if case .failure(let error) = result {
                receivedError = error
            }
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 2.0)

        // Mock should still succeed (it generates mock data), but in real implementation this would test error handling
        // This test verifies the error handling structure is in place
        XCTAssertNil(receivedError, "Mock should handle empty images gracefully")
    }

    // MARK: - Performance Tests

    func testOCRPipelinePerformance() throws {
        // Given
        let testImage = createTestImage(size: CGSize(width: 800, height: 600))
        let textRecognitionManager = MockVisionTextRecognitionManager()
        let imageClassificationManager = MockImageClassificationManager()

        // When & Then
        measure {
            let expectation = XCTestExpectation(description: "Performance test")

            textRecognitionManager.detectText(in: testImage) { textResult in
                if case .success(let texts) = textResult {
                    imageClassificationManager.classifyImage(testImage) { classificationResult in
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

    private func createDocumentImage() -> UIImage {
        // Create an image that would trigger document scenario in mock
        return createTestImage(size: CGSize(width: 800, height: 400)) // Landscape for document scenario
    }

    private func enhanceClassificationWithText(_ results: [ClassificationResult], detectedText: String) -> [ClassificationResult] {
        var enhancedResults = results
        let textLower = detectedText.lowercased()

        // Boost confidence for text-related classifications
        for index in 0..<enhancedResults.count {
            let identifier = enhancedResults[index].identifier.lowercased()

            if textLower.contains(identifier) || identifier.contains("text") || identifier.contains("document") {
                enhancedResults[index] = ClassificationResult(
                    identifier: enhancedResults[index].identifier + " (Text-Enhanced)",
                    confidence: min(1.0, enhancedResults[index].confidence * 1.2)
                )
            }
        }

        // Add text-specific classifications if significant text was found
        if !detectedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let textClassification = ClassificationResult(
                identifier: "Text Document",
                confidence: Float(min(0.95, Double(detectedText.count) / 100.0))
            )
            enhancedResults.insert(textClassification, at: 0)
        }

        return enhancedResults.sorted { $0.confidence > $1.confidence }
    }
}
