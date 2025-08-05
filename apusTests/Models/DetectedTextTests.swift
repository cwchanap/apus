//
//  DetectedTextTests.swift
//  apusTests
//
//  Created by Rovo Dev on 3/8/2025.
//

import XCTest
@testable import apus
import UIKit

final class DetectedTextTests: XCTestCase {
    
    // MARK: - DetectedText Model Tests
    
    func testDetectedTextInitialization() throws {
        // Given
        let text = "Sample Text"
        let boundingBox = CGRect(x: 0.1, y: 0.2, width: 0.3, height: 0.4)
        let confidence: Float = 0.95
        let characterBoxes: [CGRect] = []
        
        // When
        let detectedText = DetectedText(
            text: text,
            boundingBox: boundingBox,
            confidence: confidence,
            characterBoxes: characterBoxes
        )
        
        // Then
        XCTAssertEqual(detectedText.text, text)
        XCTAssertEqual(detectedText.boundingBox, boundingBox)
        XCTAssertEqual(detectedText.confidence, confidence)
        XCTAssertEqual(detectedText.characterBoxes, characterBoxes)
        XCTAssertNotNil(detectedText.id)
    }
    
    func testDetectedTextEquality() throws {
        // Given
        let text1 = DetectedText(text: "Text 1", boundingBox: CGRect.zero, confidence: 0.9, characterBoxes: [])
        let text2 = DetectedText(text: "Text 2", boundingBox: CGRect.zero, confidence: 0.8, characterBoxes: [])
        let text3 = text1 // Same instance
        
        // Then
        XCTAssertEqual(text1, text1, "DetectedText should equal itself")
        XCTAssertNotEqual(text1, text2, "Different DetectedText instances should not be equal")
        XCTAssertEqual(text1, text3, "Same DetectedText instance should be equal")
    }
    
    func testDetectedTextIdentifiable() throws {
        // Given
        let detectedText1 = DetectedText(text: "Text 1", boundingBox: CGRect.zero, confidence: 0.9, characterBoxes: [])
        let detectedText2 = DetectedText(text: "Text 2", boundingBox: CGRect.zero, confidence: 0.8, characterBoxes: [])
        
        // Then
        XCTAssertNotEqual(detectedText1.id, detectedText2.id, "Each DetectedText should have unique ID")
    }
    
    // MARK: - Display Bounding Box Tests
    
    func testDisplayBoundingBoxBasicTransformation() throws {
        // Given
        let normalizedBox = CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5)
        let detectedText = DetectedText(text: "Center Text", boundingBox: normalizedBox, confidence: 0.9, characterBoxes: [])
        let imageSize = CGSize(width: 400, height: 300)
        let displaySize = CGSize(width: 400, height: 300) // Same size, no scaling needed
        
        // When
        let displayBox = detectedText.displayBoundingBox(imageSize: imageSize, displaySize: displaySize)
        
        // Then
        XCTAssertEqual(displayBox.origin.x, 100, accuracy: 1.0, "X should be 25% of 400 = 100")
        XCTAssertEqual(displayBox.origin.y, 75, accuracy: 1.0, "Y should be 25% of 300 = 75")
        XCTAssertEqual(displayBox.width, 200, accuracy: 1.0, "Width should be 50% of 400 = 200")
        XCTAssertEqual(displayBox.height, 150, accuracy: 1.0, "Height should be 50% of 300 = 150")
    }
    
    func testDisplayBoundingBoxWithImageWiderThanDisplay() throws {
        // Given - Image is wider than display (landscape image in portrait display)
        let normalizedBox = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0) // Full image
        let detectedText = DetectedText(text: "Full Image Text", boundingBox: normalizedBox, confidence: 0.9, characterBoxes: [])
        let imageSize = CGSize(width: 800, height: 400) // 2:1 aspect ratio
        let displaySize = CGSize(width: 400, height: 400) // 1:1 aspect ratio
        
        // When
        let displayBox = detectedText.displayBoundingBox(imageSize: imageSize, displaySize: displaySize)
        
        // Then
        // Image should fit to width (400), height becomes 200, centered vertically
        let expectedImageHeight: CGFloat = 200 // 400 * (400/800)
        let expectedOffsetY: CGFloat = 100 // (400 - 200) / 2
        
        XCTAssertEqual(displayBox.origin.x, 0, accuracy: 1.0, "X should be 0 (no horizontal offset)")
        XCTAssertEqual(displayBox.origin.y, expectedOffsetY, accuracy: 1.0, "Y should be offset for centering")
        XCTAssertEqual(displayBox.width, 400, accuracy: 1.0, "Width should fill display width")
        XCTAssertEqual(displayBox.height, expectedImageHeight, accuracy: 1.0, "Height should be scaled")
    }
    
    func testDisplayBoundingBoxWithImageTallerThanDisplay() throws {
        // Given - Image is taller than display (portrait image in landscape display)
        let normalizedBox = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0) // Full image
        let detectedText = DetectedText(text: "Full Image Text", boundingBox: normalizedBox, confidence: 0.9, characterBoxes: [])
        let imageSize = CGSize(width: 300, height: 600) // 1:2 aspect ratio
        let displaySize = CGSize(width: 400, height: 400) // 1:1 aspect ratio
        
        // When
        let displayBox = detectedText.displayBoundingBox(imageSize: imageSize, displaySize: displaySize)
        
        // Then
        // Image should fit to height (400), width becomes 200, centered horizontally
        let expectedImageWidth: CGFloat = 200 // 400 * (300/600)
        let expectedOffsetX: CGFloat = 100 // (400 - 200) / 2
        
        XCTAssertEqual(displayBox.origin.x, expectedOffsetX, accuracy: 1.0, "X should be offset for centering")
        XCTAssertEqual(displayBox.origin.y, 0, accuracy: 1.0, "Y should be 0 (no vertical offset)")
        XCTAssertEqual(displayBox.width, expectedImageWidth, accuracy: 1.0, "Width should be scaled")
        XCTAssertEqual(displayBox.height, 400, accuracy: 1.0, "Height should fill display height")
    }
    
    func testDisplayBoundingBoxWithSmallTextInCorner() throws {
        // Given - Small text in top-left corner
        let normalizedBox = CGRect(x: 0.0, y: 0.0, width: 0.2, height: 0.1)
        let detectedText = DetectedText(text: "Corner Text", boundingBox: normalizedBox, confidence: 0.8, characterBoxes: [])
        let imageSize = CGSize(width: 1000, height: 800)
        let displaySize = CGSize(width: 500, height: 400)
        
        // When
        let displayBox = detectedText.displayBoundingBox(imageSize: imageSize, displaySize: displaySize)
        
        // Then
        // Image aspect ratio: 1000/800 = 1.25, Display: 500/400 = 1.25 (same ratio)
        XCTAssertEqual(displayBox.origin.x, 0, accuracy: 1.0, "Small text should start at corner")
        XCTAssertEqual(displayBox.origin.y, 0, accuracy: 1.0, "Small text should start at corner")
        XCTAssertEqual(displayBox.width, 100, accuracy: 1.0, "Width should be 20% of 500 = 100")
        XCTAssertEqual(displayBox.height, 40, accuracy: 1.0, "Height should be 10% of 400 = 40")
    }
    
    func testDisplayBoundingBoxWithTextInCenter() throws {
        // Given - Text in center of image
        let normalizedBox = CGRect(x: 0.4, y: 0.45, width: 0.2, height: 0.1)
        let detectedText = DetectedText(text: "Center Text", boundingBox: normalizedBox, confidence: 0.95, characterBoxes: [])
        let imageSize = CGSize(width: 600, height: 400)
        let displaySize = CGSize(width: 300, height: 200)
        
        // When
        let displayBox = detectedText.displayBoundingBox(imageSize: imageSize, displaySize: displaySize)
        
        // Then
        // Both have 3:2 aspect ratio, so no centering offset needed
        XCTAssertEqual(displayBox.origin.x, 120, accuracy: 1.0, "X should be 40% of 300 = 120")
        XCTAssertEqual(displayBox.origin.y, 90, accuracy: 1.0, "Y should be 45% of 200 = 90")
        XCTAssertEqual(displayBox.width, 60, accuracy: 1.0, "Width should be 20% of 300 = 60")
        XCTAssertEqual(displayBox.height, 20, accuracy: 1.0, "Height should be 10% of 200 = 20")
    }
    
    func testDisplayBoundingBoxBoundaryConditions() throws {
        // Given - Edge cases
        let testCases = [
            // Zero-sized bounding box
            (box: CGRect.zero, name: "Zero box"),
            // Full-sized bounding box
            (box: CGRect(x: 0, y: 0, width: 1, height: 1), name: "Full box"),
            // Very small bounding box
            (box: CGRect(x: 0.99, y: 0.99, width: 0.01, height: 0.01), name: "Tiny corner box"),
            // Thin horizontal line
            (box: CGRect(x: 0.1, y: 0.5, width: 0.8, height: 0.01), name: "Horizontal line"),
            // Thin vertical line
            (box: CGRect(x: 0.5, y: 0.1, width: 0.01, height: 0.8), name: "Vertical line")
        ]
        
        let imageSize = CGSize(width: 400, height: 300)
        let displaySize = CGSize(width: 200, height: 150)
        
        for testCase in testCases {
            // When
            let detectedText = DetectedText(text: "Test", boundingBox: testCase.box, confidence: 0.9, characterBoxes: [])
            let displayBox = detectedText.displayBoundingBox(imageSize: imageSize, displaySize: displaySize)
            
            // Then
            XCTAssertGreaterThanOrEqual(displayBox.origin.x, 0, "\(testCase.name): X should be non-negative")
            XCTAssertGreaterThanOrEqual(displayBox.origin.y, 0, "\(testCase.name): Y should be non-negative")
            XCTAssertGreaterThanOrEqual(displayBox.width, 0, "\(testCase.name): Width should be non-negative")
            XCTAssertGreaterThanOrEqual(displayBox.height, 0, "\(testCase.name): Height should be non-negative")
            XCTAssertLessThanOrEqual(displayBox.maxX, displaySize.width, "\(testCase.name): Should fit within display width")
            XCTAssertLessThanOrEqual(displayBox.maxY, displaySize.height, "\(testCase.name): Should fit within display height")
        }
    }
    
    func testDisplayBoundingBoxConsistency() throws {
        // Given - Same input should produce same output
        let normalizedBox = CGRect(x: 0.3, y: 0.2, width: 0.4, height: 0.3)
        let detectedText = DetectedText(text: "Consistent Text", boundingBox: normalizedBox, confidence: 0.9, characterBoxes: [])
        let imageSize = CGSize(width: 800, height: 600)
        let displaySize = CGSize(width: 400, height: 300)
        
        // When - Call multiple times
        let displayBox1 = detectedText.displayBoundingBox(imageSize: imageSize, displaySize: displaySize)
        let displayBox2 = detectedText.displayBoundingBox(imageSize: imageSize, displaySize: displaySize)
        let displayBox3 = detectedText.displayBoundingBox(imageSize: imageSize, displaySize: displaySize)
        
        // Then - Should be identical
        XCTAssertEqual(displayBox1, displayBox2, "Multiple calls should produce identical results")
        XCTAssertEqual(displayBox2, displayBox3, "Multiple calls should produce identical results")
        XCTAssertEqual(displayBox1, displayBox3, "Multiple calls should produce identical results")
    }
    
    // MARK: - Performance Tests
    
    func testDisplayBoundingBoxPerformance() throws {
        // Given
        let detectedText = DetectedText(text: "Performance Test", boundingBox: CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5), confidence: 0.9, characterBoxes: [])
        let imageSize = CGSize(width: 1920, height: 1080)
        let displaySize = CGSize(width: 375, height: 667)
        
        // When & Then
        measure {
            for _ in 0..<1000 {
                _ = detectedText.displayBoundingBox(imageSize: imageSize, displaySize: displaySize)
            }
        }
    }
    
    // MARK: - Character Boxes Tests
    
    func testDetectedTextWithCharacterBoxes() throws {
        // Given
        let characterBoxes = [
            CGRect(x: 0.1, y: 0.1, width: 0.05, height: 0.05),
            CGRect(x: 0.15, y: 0.1, width: 0.05, height: 0.05),
            CGRect(x: 0.2, y: 0.1, width: 0.05, height: 0.05)
        ]
        let detectedText = DetectedText(
            text: "ABC",
            boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.15, height: 0.05),
            confidence: 0.95,
            characterBoxes: characterBoxes
        )
        
        // Then
        XCTAssertEqual(detectedText.characterBoxes.count, 3, "Should have 3 character boxes")
        XCTAssertEqual(detectedText.characterBoxes, characterBoxes, "Character boxes should match input")
    }
}