//
//  DetectionResultsManagerTests.swift
//  apusTests
//
//  Created by Rovo Dev on 3/8/2025.
//

import XCTest
@testable import apus
import UIKit

final class DetectionResultsManagerTests: XCTestCase {

    var resultsManager: DetectionResultsManager!
    var testImage: UIImage!

    override func setUpWithError() throws {
        try super.setUpWithError()
        resultsManager = DetectionResultsManager()
        testImage = createTestImage(size: CGSize(width: 400, height: 300))

        // Clear any existing results
        resultsManager.clearAllResults()
    }

    override func tearDownWithError() throws {
        resultsManager.clearAllResults()
        resultsManager = nil
        testImage = nil
        try super.tearDownWithError()
    }

    // MARK: - OCR Results Tests

    func testSaveOCRResult() throws {
        // Given
        let detectedTexts = [
            DetectedText(text: "Test Text 1", boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.3, height: 0.1), confidence: 0.95, characterBoxes: []),
            DetectedText(text: "Test Text 2", boundingBox: CGRect(x: 0.5, y: 0.2, width: 0.4, height: 0.1), confidence: 0.88, characterBoxes: [])
        ]

        // When
        resultsManager.saveOCRResult(detectedTexts: detectedTexts, image: testImage)

        // Then
        XCTAssertEqual(resultsManager.ocrResults.count, 1, "Should have one OCR result")

        let savedResult = resultsManager.ocrResults.first!
        XCTAssertEqual(savedResult.detectedTexts.count, 2, "Should have two detected texts")
        XCTAssertEqual(savedResult.detectedTexts[0].text, "Test Text 1", "First text should match")
        XCTAssertEqual(savedResult.detectedTexts[1].text, "Test Text 2", "Second text should match")
        XCTAssertEqual(savedResult.totalTextCount, 2, "Total text count should be 2")
        XCTAssertNotNil(savedResult.image, "Should have saved image")
    }

    func testOCRResultsLimit() throws {
        // Given - Create 12 OCR results (more than the 10 limit)
        for index in 1...12 {
            let detectedTexts = [
                DetectedText(text: "Text \(index)", boundingBox: CGRect.zero, confidence: 0.9, characterBoxes: [])
            ]
            resultsManager.saveOCRResult(detectedTexts: detectedTexts, image: testImage)
        }

        // Then
        XCTAssertEqual(resultsManager.ocrResults.count, 10, "Should limit to 10 OCR results")

        // Verify most recent results are kept (FIFO)
        XCTAssertEqual(resultsManager.ocrResults.first?.detectedTexts.first?.text, "Text 12", "Most recent should be first")
        XCTAssertEqual(resultsManager.ocrResults.last?.detectedTexts.first?.text, "Text 3", "Oldest kept should be Text 3")
    }

    func testClearOCRResults() throws {
        // Given
        let detectedTexts = [DetectedText(text: "Test", boundingBox: CGRect.zero, confidence: 0.9, characterBoxes: [])]
        resultsManager.saveOCRResult(detectedTexts: detectedTexts, image: testImage)
        XCTAssertEqual(resultsManager.ocrResults.count, 1, "Should have one result")

        // When
        resultsManager.clearOCRResults()

        // Then
        XCTAssertEqual(resultsManager.ocrResults.count, 0, "Should have no OCR results after clearing")
    }

    func testOCRResultStatistics() throws {
        // Given
        let detectedTexts = [
            DetectedText(text: "High confidence", boundingBox: CGRect.zero, confidence: 0.95, characterBoxes: []),
            DetectedText(text: "Medium confidence", boundingBox: CGRect.zero, confidence: 0.75, characterBoxes: []),
            DetectedText(text: "Low confidence", boundingBox: CGRect.zero, confidence: 0.55, characterBoxes: [])
        ]

        // When
        resultsManager.saveOCRResult(detectedTexts: detectedTexts, image: testImage)

        // Then
        let savedResult = resultsManager.ocrResults.first!
        XCTAssertEqual(savedResult.totalTextCount, 3, "Should count all texts")
        XCTAssertEqual(savedResult.averageConfidence, 0.75, accuracy: 0.01, "Should calculate correct average confidence")
        XCTAssertEqual(savedResult.allText, "High confidence Medium confidence Low confidence", "Should combine all text")
    }

    // MARK: - Object Detection Results Tests

    func testSaveObjectDetectionResult() throws {
        // Given
        let detectedObjects = [
            DetectedObject(boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.3, height: 0.4), className: "person", confidence: 0.92, framework: .vision),
            DetectedObject(boundingBox: CGRect(x: 0.6, y: 0.2, width: 0.25, height: 0.3), className: "dog", confidence: 0.87, framework: .tensorflowLite)
        ]

        // When
        resultsManager.saveObjectDetectionResult(detectedObjects: detectedObjects, image: testImage)

        // Then
        XCTAssertEqual(resultsManager.objectDetectionResults.count, 1, "Should have one object detection result")

        let savedResult = resultsManager.objectDetectionResults.first!
        XCTAssertEqual(savedResult.detectedObjects.count, 2, "Should have two detected objects")
        XCTAssertEqual(savedResult.detectedObjects[0].className, "person", "First object should be person")
        XCTAssertEqual(savedResult.detectedObjects[1].className, "dog", "Second object should be dog")
        XCTAssertEqual(savedResult.totalObjectCount, 2, "Total object count should be 2")
        XCTAssertEqual(savedResult.uniqueClasses, ["dog", "person"], "Should have sorted unique classes")
    }

    func testObjectDetectionResultsLimit() throws {
        // Given - Create 15 object detection results
        for index in 1...15 {
            let detectedObjects = [
                DetectedObject(boundingBox: CGRect.zero, className: "object\(index)", confidence: 0.8, framework: .vision)
            ]
            resultsManager.saveObjectDetectionResult(detectedObjects: detectedObjects, image: testImage)
        }

        // Then
        XCTAssertEqual(resultsManager.objectDetectionResults.count, 10, "Should limit to 10 object detection results")

        // Verify most recent results are kept
        XCTAssertEqual(resultsManager.objectDetectionResults.first?.detectedObjects.first?.className, "object15", "Most recent should be first")
    }

    func testObjectDetectionStatistics() throws {
        // Given
        let detectedObjects = [
            DetectedObject(boundingBox: CGRect.zero, className: "person", confidence: 0.95, framework: .vision),
            DetectedObject(boundingBox: CGRect.zero, className: "person", confidence: 0.85, framework: .vision),
            DetectedObject(boundingBox: CGRect.zero, className: "dog", confidence: 0.75, framework: .tensorflowLite)
        ]

        // When
        resultsManager.saveObjectDetectionResult(detectedObjects: detectedObjects, image: testImage)

        // Then
        let savedResult = resultsManager.objectDetectionResults.first!
        XCTAssertEqual(savedResult.totalObjectCount, 3, "Should count all objects")
        XCTAssertEqual(savedResult.averageConfidence, 0.85, accuracy: 0.01, "Should calculate correct average confidence")
        XCTAssertEqual(savedResult.uniqueClasses.count, 2, "Should have 2 unique classes")
        XCTAssertTrue(savedResult.uniqueClasses.contains("person"), "Should contain person class")
        XCTAssertTrue(savedResult.uniqueClasses.contains("dog"), "Should contain dog class")
    }

    // MARK: - Classification Results Tests

    func testSaveClassificationResult() throws {
        // Given
        let classificationResults = [
            ClassificationResult(identifier: "golden retriever", confidence: 0.92),
            ClassificationResult(identifier: "dog", confidence: 0.85),
            ClassificationResult(identifier: "animal", confidence: 0.78)
        ]

        // When
        resultsManager.saveClassificationResult(classificationResults: classificationResults, image: testImage)

        // Then
        XCTAssertEqual(resultsManager.classificationResults.count, 1, "Should have one classification result")

        let savedResult = resultsManager.classificationResults.first!
        XCTAssertEqual(savedResult.classificationResults.count, 3, "Should have three classification results")
        XCTAssertEqual(savedResult.topResult?.identifier, "golden retriever", "Top result should be golden retriever")
        XCTAssertEqual(savedResult.topResult?.confidence, 0.92, "Top result confidence should be 0.92")
    }

    func testClassificationResultsLimit() throws {
        // Given - Create 12 classification results
        for index in 1...12 {
            let classificationResults = [
                ClassificationResult(identifier: "class\(index)", confidence: 0.8)
            ]
            resultsManager.saveClassificationResult(classificationResults: classificationResults, image: testImage)
        }

        // Then
        XCTAssertEqual(resultsManager.classificationResults.count, 10, "Should limit to 10 classification results")

        // Verify most recent results are kept
        XCTAssertEqual(resultsManager.classificationResults.first?.topResult?.identifier, "class12", "Most recent should be first")
    }

    func testClassificationStatistics() throws {
        // Given
        let classificationResults = [
            ClassificationResult(identifier: "high", confidence: 0.9),
            ClassificationResult(identifier: "medium", confidence: 0.7),
            ClassificationResult(identifier: "low", confidence: 0.5)
        ]

        // When
        resultsManager.saveClassificationResult(classificationResults: classificationResults, image: testImage)

        // Then
        let savedResult = resultsManager.classificationResults.first!
        XCTAssertEqual(savedResult.averageConfidence, 0.7, accuracy: 0.01, "Should calculate correct average confidence")
        XCTAssertEqual(savedResult.topResult?.identifier, "high", "Top result should be highest confidence")
    }

    // MARK: - General Management Tests

    func testClearAllResults() throws {
        // Given - Add results to all categories
        let detectedTexts = [DetectedText(text: "Test", boundingBox: CGRect.zero, confidence: 0.9, characterBoxes: [])]
        let detectedObjects = [DetectedObject(boundingBox: CGRect.zero, className: "test", confidence: 0.8, framework: .vision)]
        let classificationResults = [ClassificationResult(identifier: "test", confidence: 0.7)]

        resultsManager.saveOCRResult(detectedTexts: detectedTexts, image: testImage)
        resultsManager.saveObjectDetectionResult(detectedObjects: detectedObjects, image: testImage)
        resultsManager.saveClassificationResult(classificationResults: classificationResults, image: testImage)

        XCTAssertEqual(resultsManager.totalResultsCount, 3, "Should have 3 total results")

        // When
        resultsManager.clearAllResults()

        // Then
        XCTAssertEqual(resultsManager.totalResultsCount, 0, "Should have no results after clearing all")
        XCTAssertEqual(resultsManager.ocrResults.count, 0, "Should have no OCR results")
        XCTAssertEqual(resultsManager.objectDetectionResults.count, 0, "Should have no object detection results")
        XCTAssertEqual(resultsManager.classificationResults.count, 0, "Should have no classification results")
        XCTAssertFalse(resultsManager.hasAnyResults, "Should not have any results")
    }

    func testResultsCount() throws {
        // Given
        let detectedTexts = [DetectedText(text: "Test", boundingBox: CGRect.zero, confidence: 0.9, characterBoxes: [])]
        let detectedObjects = [DetectedObject(boundingBox: CGRect.zero, className: "test", confidence: 0.8, framework: .vision)]

        // When
        resultsManager.saveOCRResult(detectedTexts: detectedTexts, image: testImage)
        resultsManager.saveOCRResult(detectedTexts: detectedTexts, image: testImage) // Add second OCR result
        resultsManager.saveObjectDetectionResult(detectedObjects: detectedObjects, image: testImage)

        // Then
        XCTAssertEqual(resultsManager.getResultsCount(for: .ocr), 2, "Should have 2 OCR results")
        XCTAssertEqual(resultsManager.getResultsCount(for: .objectDetection), 1, "Should have 1 object detection result")
        XCTAssertEqual(resultsManager.getResultsCount(for: .classification), 0, "Should have 0 classification results")
        XCTAssertEqual(resultsManager.totalResultsCount, 3, "Should have 3 total results")
        XCTAssertTrue(resultsManager.hasAnyResults, "Should have results")
    }

    // MARK: - Data Model Tests

    func testStoredDetectedTextConversion() throws {
        // Given
        let originalText = DetectedText(
            text: "Test Text",
            boundingBox: CGRect(x: 0.1, y: 0.2, width: 0.3, height: 0.4),
            confidence: 0.95,
            characterBoxes: []
        )

        // When
        let storedText = StoredDetectedText(from: originalText)
        let convertedText = storedText.toDetectedText()

        // Then
        XCTAssertEqual(convertedText.text, originalText.text, "Text should be preserved")
        XCTAssertEqual(convertedText.boundingBox, originalText.boundingBox, "Bounding box should be preserved")
        XCTAssertEqual(convertedText.confidence, originalText.confidence, "Confidence should be preserved")
    }

    func testStoredDetectedObjectConversion() throws {
        // Given
        let originalObject = DetectedObject(
            boundingBox: CGRect(x: 0.1, y: 0.2, width: 0.3, height: 0.4),
            className: "person",
            confidence: 0.92,
            framework: .vision
        )

        // When
        let storedObject = StoredDetectedObject(from: originalObject)
        let convertedObject = storedObject.toDetectedObject()

        // Then
        XCTAssertEqual(convertedObject.boundingBox, originalObject.boundingBox, "Bounding box should be preserved")
        XCTAssertEqual(convertedObject.className, originalObject.className, "Class name should be preserved")
        XCTAssertEqual(convertedObject.confidence, originalObject.confidence, "Confidence should be preserved")
        XCTAssertEqual(convertedObject.framework, originalObject.framework, "Framework should be preserved")
    }

    func testStoredClassificationConversion() throws {
        // Given
        let originalResult = ClassificationResult(identifier: "golden retriever", confidence: 0.92)

        // When
        let storedResult = StoredClassification(from: originalResult)
        let convertedResult = storedResult.toClassificationResult()

        // Then
        XCTAssertEqual(convertedResult.identifier, originalResult.identifier, "Identifier should be preserved")
        XCTAssertEqual(convertedResult.confidence, originalResult.confidence, "Confidence should be preserved")
    }

    // MARK: - Performance Tests

    func testSaveResultsPerformance() throws {
        // Given
        let detectedTexts = Array(1...100).map { idx in
            DetectedText(text: "Text \(idx)", boundingBox: CGRect.zero, confidence: 0.9, characterBoxes: [])
        }

        // When & Then
        measure {
            resultsManager.saveOCRResult(detectedTexts: detectedTexts, image: testImage)
        }
    }

    func testLargeImageStoragePerformance() throws {
        // Given
        let largeImage = createTestImage(size: CGSize(width: 2048, height: 1536))
        let detectedTexts = [DetectedText(text: "Test", boundingBox: CGRect.zero, confidence: 0.9, characterBoxes: [])]

        // When & Then
        measure {
            resultsManager.saveOCRResult(detectedTexts: detectedTexts, image: largeImage)
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
}
