//
//  DetectionResultsModelsTests.swift
//  apusTests
//
//  Created by Rovo Dev on 3/8/2025.
//

import XCTest
@testable import apus
import UIKit

final class DetectionResultsModelsTests: XCTestCase {
    
    var testImage: UIImage!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        testImage = createTestImage(size: CGSize(width: 400, height: 300))
    }
    
    override func tearDownWithError() throws {
        testImage = nil
        try super.tearDownWithError()
    }
    
    // MARK: - StoredOCRResult Tests
    
    func testStoredOCRResultInitialization() throws {
        // Given
        let detectedTexts = [
            DetectedText(text: "Hello World", boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.3, height: 0.1), confidence: 0.95, characterBoxes: []),
            DetectedText(text: "Test Text", boundingBox: CGRect(x: 0.5, y: 0.2, width: 0.4, height: 0.1), confidence: 0.88, characterBoxes: [])
        ]
        
        // When
        let storedResult = StoredOCRResult(detectedTexts: detectedTexts, image: testImage)
        
        // Then
        XCTAssertNotNil(storedResult.id, "Should have a unique ID")
        XCTAssertEqual(storedResult.detectedTexts.count, 2, "Should store all detected texts")
        XCTAssertEqual(storedResult.detectedTexts[0].text, "Hello World", "First text should match")
        XCTAssertEqual(storedResult.detectedTexts[1].text, "Test Text", "Second text should match")
        XCTAssertNotNil(storedResult.image, "Should be able to reconstruct image")
        XCTAssertEqual(storedResult.imageSize, testImage.size, "Should preserve image size")
        XCTAssertTrue(storedResult.imageData.count > 0, "Should have compressed image data")
    }
    
    func testStoredOCRResultStatistics() throws {
        // Given
        let detectedTexts = [
            DetectedText(text: "High", boundingBox: CGRect.zero, confidence: 0.9, characterBoxes: []),
            DetectedText(text: "Medium", boundingBox: CGRect.zero, confidence: 0.7, characterBoxes: []),
            DetectedText(text: "Low", boundingBox: CGRect.zero, confidence: 0.5, characterBoxes: [])
        ]
        
        // When
        let storedResult = StoredOCRResult(detectedTexts: detectedTexts, image: testImage)
        
        // Then
        XCTAssertEqual(storedResult.totalTextCount, 3, "Should count all texts")
        XCTAssertEqual(storedResult.averageConfidence, 0.7, accuracy: 0.01, "Should calculate correct average")
        XCTAssertEqual(storedResult.allText, "High Medium Low", "Should combine all text with spaces")
    }
    
    func testStoredOCRResultWithEmptyTexts() throws {
        // Given
        let emptyTexts: [DetectedText] = []
        
        // When
        let storedResult = StoredOCRResult(detectedTexts: emptyTexts, image: testImage)
        
        // Then
        XCTAssertEqual(storedResult.totalTextCount, 0, "Should have zero text count")
        XCTAssertEqual(storedResult.averageConfidence, 0.0, "Should have zero average confidence")
        XCTAssertEqual(storedResult.allText, "", "Should have empty combined text")
    }
    
    func testStoredOCRResultCodable() throws {
        // Given
        let detectedTexts = [
            DetectedText(text: "Codable Test", boundingBox: CGRect(x: 0.1, y: 0.2, width: 0.3, height: 0.4), confidence: 0.95, characterBoxes: [])
        ]
        let originalResult = StoredOCRResult(detectedTexts: detectedTexts, image: testImage)
        
        // When
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let encodedData = try encoder.encode(originalResult)
        let decodedResult = try decoder.decode(StoredOCRResult.self, from: encodedData)
        
        // Then
        XCTAssertEqual(decodedResult.detectedTexts.count, originalResult.detectedTexts.count, "Should preserve text count")
        XCTAssertEqual(decodedResult.detectedTexts[0].text, originalResult.detectedTexts[0].text, "Should preserve text content")
        XCTAssertEqual(decodedResult.imageSize, originalResult.imageSize, "Should preserve image size")
        XCTAssertEqual(decodedResult.imageData, originalResult.imageData, "Should preserve image data")
    }
    
    // MARK: - StoredObjectDetectionResult Tests
    
    func testStoredObjectDetectionResultInitialization() throws {
        // Given
        let detectedObjects = [
            DetectedObject(boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.3, height: 0.4), className: "person", confidence: 0.92, framework: .vision),
            DetectedObject(boundingBox: CGRect(x: 0.6, y: 0.2, width: 0.25, height: 0.3), className: "dog", confidence: 0.87, framework: .tensorflowLite)
        ]
        
        // When
        let storedResult = StoredObjectDetectionResult(detectedObjects: detectedObjects, image: testImage)
        
        // Then
        XCTAssertNotNil(storedResult.id, "Should have a unique ID")
        XCTAssertEqual(storedResult.detectedObjects.count, 2, "Should store all detected objects")
        XCTAssertEqual(storedResult.detectedObjects[0].className, "person", "First object should be person")
        XCTAssertEqual(storedResult.detectedObjects[1].className, "dog", "Second object should be dog")
        XCTAssertEqual(storedResult.framework, "Vision", "Should use framework from first object")
        XCTAssertNotNil(storedResult.image, "Should be able to reconstruct image")
    }
    
    func testStoredObjectDetectionResultStatistics() throws {
        // Given
        let detectedObjects = [
            DetectedObject(boundingBox: CGRect.zero, className: "person", confidence: 0.95, framework: .vision),
            DetectedObject(boundingBox: CGRect.zero, className: "person", confidence: 0.85, framework: .vision),
            DetectedObject(boundingBox: CGRect.zero, className: "dog", confidence: 0.75, framework: .vision)
        ]
        
        // When
        let storedResult = StoredObjectDetectionResult(detectedObjects: detectedObjects, image: testImage)
        
        // Then
        XCTAssertEqual(storedResult.totalObjectCount, 3, "Should count all objects")
        XCTAssertEqual(storedResult.averageConfidence, 0.85, accuracy: 0.01, "Should calculate correct average")
        XCTAssertEqual(storedResult.uniqueClasses.count, 2, "Should have 2 unique classes")
        XCTAssertTrue(storedResult.uniqueClasses.contains("person"), "Should contain person")
        XCTAssertTrue(storedResult.uniqueClasses.contains("dog"), "Should contain dog")
        XCTAssertEqual(storedResult.uniqueClasses, ["dog", "person"], "Should be sorted alphabetically")
    }
    
    func testStoredObjectDetectionResultWithEmptyObjects() throws {
        // Given
        let emptyObjects: [DetectedObject] = []
        
        // When
        let storedResult = StoredObjectDetectionResult(detectedObjects: emptyObjects, image: testImage)
        
        // Then
        XCTAssertEqual(storedResult.totalObjectCount, 0, "Should have zero object count")
        XCTAssertEqual(storedResult.averageConfidence, 0.0, "Should have zero average confidence")
        XCTAssertEqual(storedResult.uniqueClasses.count, 0, "Should have no unique classes")
        XCTAssertEqual(storedResult.framework, "Unknown", "Should default to Unknown framework")
    }
    
    // MARK: - StoredClassificationResult Tests
    
    func testStoredClassificationResultInitialization() throws {
        // Given
        let classificationResults = [
            ClassificationResult(identifier: "golden retriever", confidence: 0.92),
            ClassificationResult(identifier: "dog", confidence: 0.85),
            ClassificationResult(identifier: "animal", confidence: 0.78)
        ]
        
        // When
        let storedResult = StoredClassificationResult(classificationResults: classificationResults, image: testImage)
        
        // Then
        XCTAssertNotNil(storedResult.id, "Should have a unique ID")
        XCTAssertEqual(storedResult.classificationResults.count, 3, "Should store all classification results")
        XCTAssertEqual(storedResult.classificationResults[0].identifier, "golden retriever", "First result should match")
        XCTAssertEqual(storedResult.topResult?.identifier, "golden retriever", "Top result should be first")
        XCTAssertEqual(storedResult.topResult?.confidence, 0.92, "Top result confidence should match")
    }
    
    func testStoredClassificationResultStatistics() throws {
        // Given
        let classificationResults = [
            ClassificationResult(identifier: "high", confidence: 0.9),
            ClassificationResult(identifier: "medium", confidence: 0.6),
            ClassificationResult(identifier: "low", confidence: 0.3)
        ]
        
        // When
        let storedResult = StoredClassificationResult(classificationResults: classificationResults, image: testImage)
        
        // Then
        XCTAssertEqual(storedResult.averageConfidence, 0.6, accuracy: 0.01, "Should calculate correct average")
        XCTAssertEqual(storedResult.topResult?.identifier, "high", "Top result should be highest confidence")
    }
    
    func testStoredClassificationResultWithEmptyResults() throws {
        // Given
        let emptyResults: [ClassificationResult] = []
        
        // When
        let storedResult = StoredClassificationResult(classificationResults: emptyResults, image: testImage)
        
        // Then
        XCTAssertEqual(storedResult.classificationResults.count, 0, "Should have zero results")
        XCTAssertNil(storedResult.topResult, "Should have no top result")
        XCTAssertEqual(storedResult.averageConfidence, 0.0, "Should have zero average confidence")
    }
    
    // MARK: - StoredDetectedText Tests
    
    func testStoredDetectedTextConversion() throws {
        // Given
        let originalText = DetectedText(
            text: "Test Text",
            boundingBox: CGRect(x: 0.1, y: 0.2, width: 0.3, height: 0.4),
            confidence: 0.95,
            characterBoxes: [CGRect(x: 0.1, y: 0.2, width: 0.05, height: 0.04)]
        )
        
        // When
        let storedText = StoredDetectedText(from: originalText)
        let convertedText = storedText.toDetectedText()
        
        // Then
        XCTAssertNotEqual(storedText.id, originalText.id, "Should have different IDs")
        XCTAssertEqual(convertedText.text, originalText.text, "Text should be preserved")
        XCTAssertEqual(convertedText.boundingBox, originalText.boundingBox, "Bounding box should be preserved")
        XCTAssertEqual(convertedText.confidence, originalText.confidence, "Confidence should be preserved")
        XCTAssertEqual(convertedText.characterBoxes.count, 0, "Character boxes should be empty in conversion")
    }
    
    // MARK: - StoredDetectedObject Tests
    
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
        XCTAssertNotEqual(storedObject.id, originalObject.id, "Should have different IDs")
        XCTAssertEqual(convertedObject.boundingBox, originalObject.boundingBox, "Bounding box should be preserved")
        XCTAssertEqual(convertedObject.className, originalObject.className, "Class name should be preserved")
        XCTAssertEqual(convertedObject.confidence, originalObject.confidence, "Confidence should be preserved")
        XCTAssertEqual(convertedObject.framework, originalObject.framework, "Framework should be preserved")
    }
    
    func testStoredDetectedObjectFrameworkConversion() throws {
        // Given
        let visionObject = DetectedObject(boundingBox: CGRect.zero, className: "test", confidence: 0.8, framework: .vision)
        let tensorflowObject = DetectedObject(boundingBox: CGRect.zero, className: "test", confidence: 0.8, framework: .tensorflowLite)
        
        // When
        let storedVision = StoredDetectedObject(from: visionObject)
        let storedTensorflow = StoredDetectedObject(from: tensorflowObject)
        
        let convertedVision = storedVision.toDetectedObject()
        let convertedTensorflow = storedTensorflow.toDetectedObject()
        
        // Then
        XCTAssertEqual(storedVision.framework, "Vision", "Should store Vision framework name")
        XCTAssertEqual(storedTensorflow.framework, "TensorFlow Lite", "Should store TensorFlow Lite framework name")
        XCTAssertEqual(convertedVision.framework, .vision, "Should convert back to Vision framework")
        XCTAssertEqual(convertedTensorflow.framework, .tensorflowLite, "Should convert back to TensorFlow Lite framework")
    }
    
    // MARK: - StoredClassification Tests
    
    func testStoredClassificationConversion() throws {
        // Given
        let originalResult = ClassificationResult(identifier: "golden retriever", confidence: 0.92)
        
        // When
        let storedResult = StoredClassification(from: originalResult)
        let convertedResult = storedResult.toClassificationResult()
        
        // Then
        XCTAssertNotEqual(storedResult.id, originalResult.id, "Should have different IDs")
        XCTAssertEqual(convertedResult.identifier, originalResult.identifier, "Identifier should be preserved")
        XCTAssertEqual(convertedResult.confidence, originalResult.confidence, "Confidence should be preserved")
    }
    
    // MARK: - DetectionCategory Tests
    
    func testDetectionCategoryProperties() throws {
        // Test OCR category
        XCTAssertEqual(DetectionCategory.ocr.rawValue, "OCR", "OCR raw value should be correct")
        XCTAssertEqual(DetectionCategory.ocr.icon, "textformat", "OCR icon should be correct")
        XCTAssertEqual(DetectionCategory.ocr.color, .purple, "OCR color should be purple")
        
        // Test Object Detection category
        XCTAssertEqual(DetectionCategory.objectDetection.rawValue, "Object Detection", "Object Detection raw value should be correct")
        XCTAssertEqual(DetectionCategory.objectDetection.icon, "viewfinder", "Object Detection icon should be correct")
        XCTAssertEqual(DetectionCategory.objectDetection.color, .blue, "Object Detection color should be blue")
        
        // Test Classification category
        XCTAssertEqual(DetectionCategory.classification.rawValue, "Classification", "Classification raw value should be correct")
        XCTAssertEqual(DetectionCategory.classification.icon, "brain.head.profile", "Classification icon should be correct")
        XCTAssertEqual(DetectionCategory.classification.color, .green, "Classification color should be green")
    }
    
    func testDetectionCategoryAllCases() throws {
        // Given
        let allCases = DetectionCategory.allCases
        
        // Then
        XCTAssertEqual(allCases.count, 3, "Should have 3 detection categories")
        XCTAssertTrue(allCases.contains(.ocr), "Should contain OCR category")
        XCTAssertTrue(allCases.contains(.objectDetection), "Should contain Object Detection category")
        XCTAssertTrue(allCases.contains(.classification), "Should contain Classification category")
    }
    
    // MARK: - Image Compression Tests
    
    func testImageCompressionQuality() throws {
        // Given
        let largeImage = createTestImage(size: CGSize(width: 2048, height: 1536))
        let detectedTexts = [DetectedText(text: "Test", boundingBox: CGRect.zero, confidence: 0.9, characterBoxes: [])]
        
        // When
        let storedResult = StoredOCRResult(detectedTexts: detectedTexts, image: largeImage)
        
        // Then
        XCTAssertTrue(storedResult.imageData.count > 0, "Should have compressed image data")
        XCTAssertNotNil(storedResult.image, "Should be able to reconstruct image")
        
        // Verify compression by comparing original vs stored image data size
        let originalData = largeImage.jpegData(compressionQuality: 1.0) ?? Data()
        XCTAssertLessThan(storedResult.imageData.count, originalData.count, "Compressed data should be smaller than original")
    }
    
    // MARK: - Performance Tests
    
    func testModelCreationPerformance() throws {
        // Given
        let detectedTexts = Array(1...100).map { i in
            DetectedText(text: "Text \(i)", boundingBox: CGRect.zero, confidence: 0.9, characterBoxes: [])
        }
        
        // When & Then
        measure {
            _ = StoredOCRResult(detectedTexts: detectedTexts, image: testImage)
        }
    }
    
    func testModelEncodingPerformance() throws {
        // Given
        let detectedTexts = Array(1...50).map { i in
            DetectedText(text: "Text \(i)", boundingBox: CGRect.zero, confidence: 0.9, characterBoxes: [])
        }
        let storedResult = StoredOCRResult(detectedTexts: detectedTexts, image: testImage)
        let encoder = JSONEncoder()
        
        // When & Then
        measure {
            _ = try? encoder.encode(storedResult)
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