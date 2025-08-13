//
//  VisionTextRecognitionTests.swift
//  apusTests
//
//  Created by Rovo Dev on 3/8/2025.
//

import XCTest
@testable import apus
import UIKit

final class VisionTextRecognitionTests: XCTestCase {

    var textRecognitionManager: MockVisionTextRecognitionManager!
    var testImage: UIImage!

    override func setUpWithError() throws {
        try super.setUpWithError()
        textRecognitionManager = MockVisionTextRecognitionManager()
        testImage = createTestImage(size: CGSize(width: 400, height: 300))
    }

    override func tearDownWithError() throws {
        textRecognitionManager = nil
        testImage = nil
        try super.tearDownWithError()
    }

    // MARK: - Text Recognition Tests

    func testDetectTextSuccess() throws {
        // Given
        let expectation = XCTestExpectation(description: "Text detection completes")
        var detectedTexts: [DetectedText]?
        var detectionError: Error?

        // When
        textRecognitionManager.detectText(in: testImage) { result in
            switch result {
            case .success(let texts):
                detectedTexts = texts
            case .failure(let error):
                detectionError = error
            }
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 2.0)

        XCTAssertNil(detectionError, "Text detection should not fail")
        XCTAssertNotNil(detectedTexts, "Should return detected texts")
        XCTAssertFalse(detectedTexts?.isEmpty ?? true, "Should detect some text")

        // Verify text properties
        if let texts = detectedTexts {
            for text in texts {
                XCTAssertFalse(text.text.isEmpty, "Text content should not be empty")
                XCTAssertGreaterThan(text.confidence, 0.0, "Confidence should be positive")
                XCTAssertLessThanOrEqual(text.confidence, 1.0, "Confidence should not exceed 1.0")
                XCTAssertTrue(text.boundingBox.width > 0, "Bounding box width should be positive")
                XCTAssertTrue(text.boundingBox.height > 0, "Bounding box height should be positive")
            }
        }
    }

    func testDetectTextWithLandscapeImage() throws {
        // Given
        let landscapeImage = createTestImage(size: CGSize(width: 800, height: 400))
        let expectation = XCTestExpectation(description: "Landscape text detection completes")
        var detectedTexts: [DetectedText]?

        // When
        textRecognitionManager.detectText(in: landscapeImage) { result in
            if case .success(let texts) = result {
                detectedTexts = texts
            }
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 2.0)

        XCTAssertNotNil(detectedTexts, "Should detect text in landscape image")

        // Should get document scenario for landscape images
        if let texts = detectedTexts {
            let hasReceiptText = texts.contains { $0.text.contains("RECEIPT") }
            let hasPriceText = texts.contains { $0.text.contains("$") }
            XCTAssertTrue(hasReceiptText || hasPriceText, "Landscape image should trigger document scenario")
        }
    }

    func testDetectTextWithPortraitImage() throws {
        // Given
        let portraitImage = createTestImage(size: CGSize(width: 300, height: 600))
        let expectation = XCTestExpectation(description: "Portrait text detection completes")
        var detectedTexts: [DetectedText]?

        // When
        textRecognitionManager.detectText(in: portraitImage) { result in
            if case .success(let texts) = result {
                detectedTexts = texts
            }
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 2.0)

        XCTAssertNotNil(detectedTexts, "Should detect text in portrait image")

        // Should get phone screen scenario for portrait images
        if let texts = detectedTexts {
            let hasMessagesText = texts.contains { $0.text.contains("Messages") }
            let hasNameText = texts.contains { $0.text.contains("John") || $0.text.contains("Doe") }
            XCTAssertTrue(hasMessagesText || hasNameText, "Portrait image should trigger phone screen scenario")
        }
    }

    func testDetectTextWithSquareImage() throws {
        // Given
        let squareImage = createTestImage(size: CGSize(width: 400, height: 400))
        let expectation = XCTestExpectation(description: "Square text detection completes")
        var detectedTexts: [DetectedText]?

        // When
        textRecognitionManager.detectText(in: squareImage) { result in
            if case .success(let texts) = result {
                detectedTexts = texts
            }
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 2.0)

        XCTAssertNotNil(detectedTexts, "Should detect text in square image")

        // Should get sign scenario for square images
        if let texts = detectedTexts {
            let hasStopText = texts.contains { $0.text.contains("STOP") }
            let hasStreetText = texts.contains { $0.text.contains("Street") }
            XCTAssertTrue(hasStopText || hasStreetText, "Square image should trigger sign scenario")
        }
    }

    // MARK: - Coordinate Transformation Tests

    func testDisplayBoundingBoxTransformation() throws {
        // Given
        let normalizedBoundingBox = CGRect(x: 0.2, y: 0.3, width: 0.4, height: 0.2)
        let detectedText = DetectedText(
            text: "Test Text",
            boundingBox: normalizedBoundingBox,
            confidence: 0.95,
            characterBoxes: []
        )
        let imageSize = CGSize(width: 400, height: 300)
        let displaySize = CGSize(width: 350, height: 250)

        // When
        let displayBoundingBox = detectedText.displayBoundingBox(imageSize: imageSize, displaySize: displaySize)

        // Then
        XCTAssertGreaterThan(displayBoundingBox.width, 0, "Display width should be positive")
        XCTAssertGreaterThan(displayBoundingBox.height, 0, "Display height should be positive")
        XCTAssertGreaterThanOrEqual(displayBoundingBox.minX, 0, "Display X should be non-negative")
        XCTAssertGreaterThanOrEqual(displayBoundingBox.minY, 0, "Display Y should be non-negative")
        XCTAssertLessThanOrEqual(displayBoundingBox.maxX, displaySize.width, "Display box should fit within display width")
        XCTAssertLessThanOrEqual(displayBoundingBox.maxY, displaySize.height, "Display box should fit within display height")
    }

    func testDisplayBoundingBoxAspectRatioPreservation() throws {
        // Given
        let normalizedBoundingBox = CGRect(x: 0.1, y: 0.1, width: 0.8, height: 0.8)
        let detectedText = DetectedText(
            text: "Large Text",
            boundingBox: normalizedBoundingBox,
            confidence: 0.90,
            characterBoxes: []
        )

        // Test with different aspect ratios
        let testCases = [
            (imageSize: CGSize(width: 400, height: 300), displaySize: CGSize(width: 200, height: 150)), // Same aspect ratio
            (imageSize: CGSize(width: 400, height: 300), displaySize: CGSize(width: 300, height: 300)), // Display more square
            (imageSize: CGSize(width: 300, height: 400), displaySize: CGSize(width: 200, height: 150))  // Different orientations
        ]

        for testCase in testCases {
            // When
            let displayBoundingBox = detectedText.displayBoundingBox(
                imageSize: testCase.imageSize,
                displaySize: testCase.displaySize
            )

            // Then
            XCTAssertTrue(displayBoundingBox.width > 0 && displayBoundingBox.height > 0,
                          "Display bounding box should have positive dimensions for image \(testCase.imageSize) in display \(testCase.displaySize)")

            // Verify the box fits within display bounds
            XCTAssertTrue(displayBoundingBox.maxX <= testCase.displaySize.width + 1.0,
                          "Display box should fit within display width (with 1px tolerance)")
            XCTAssertTrue(displayBoundingBox.maxY <= testCase.displaySize.height + 1.0,
                          "Display box should fit within display height (with 1px tolerance)")
        }
    }

    func testDisplayBoundingBoxCentering() throws {
        // Given - Image that needs centering in display
        let normalizedBoundingBox = CGRect(x: 0.4, y: 0.4, width: 0.2, height: 0.2)
        let detectedText = DetectedText(
            text: "Centered Text",
            boundingBox: normalizedBoundingBox,
            confidence: 0.85,
            characterBoxes: []
        )
        let imageSize = CGSize(width: 200, height: 200) // Square image
        let displaySize = CGSize(width: 400, height: 200) // Wide display

        // When
        let displayBoundingBox = detectedText.displayBoundingBox(imageSize: imageSize, displaySize: displaySize)

        // Then
        // Image should be centered horizontally in the display
        let expectedImageDisplayWidth = displaySize.height // Image fits to height, so width = height
        let expectedOffsetX = (displaySize.width - expectedImageDisplayWidth) / 2

        XCTAssertGreaterThan(displayBoundingBox.minX, expectedOffsetX - 5,
                             "Text should be offset due to image centering")
        XCTAssertLessThan(displayBoundingBox.minX, expectedOffsetX + expectedImageDisplayWidth,
                          "Text should be within the centered image area")
    }

    // MARK: - Mock Scenario Tests

    func testMockScenarioConsistency() throws {
        // Given
        let testImages = [
            createTestImage(size: CGSize(width: 800, height: 400)), // Landscape
            createTestImage(size: CGSize(width: 300, height: 600)), // Portrait
            createTestImage(size: CGSize(width: 400, height: 400))  // Square
        ]

        for (index, image) in testImages.enumerated() {
            let expectation = XCTestExpectation(description: "Scenario \(index) detection")
            var firstResult: [DetectedText]?
            var secondResult: [DetectedText]?

            // When - Run detection twice on the same image
            textRecognitionManager.detectText(in: image) { result in
                if case .success(let texts) = result {
                    firstResult = texts
                }

                // Run again
                self.textRecognitionManager.detectText(in: image) { result in
                    if case .success(let texts) = result {
                        secondResult = texts
                    }
                    expectation.fulfill()
                }
            }

            // Then
            wait(for: [expectation], timeout: 3.0)

            XCTAssertNotNil(firstResult, "First detection should succeed for image \(index)")
            XCTAssertNotNil(secondResult, "Second detection should succeed for image \(index)")

            if let first = firstResult, let second = secondResult {
                XCTAssertEqual(first.count, second.count, "Same image should produce consistent text count")

                // Check that the same texts are detected (order might vary)
                for firstText in first {
                    let matchingText = second.first { $0.text == firstText.text }
                    XCTAssertNotNil(matchingText, "Same text '\(firstText.text)' should be detected consistently")
                }
            }
        }
    }

    // MARK: - Performance Tests

    func testTextRecognitionPerformance() throws {
        // Given
        let largeImage = createTestImage(size: CGSize(width: 1024, height: 768))

        // When & Then
        measure {
            let expectation = XCTestExpectation(description: "Performance test")

            textRecognitionManager.detectText(in: largeImage) { _ in
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 5.0)
        }
    }

    // MARK: - Helper Methods

    private func createTestImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // Create a simple test image with some visual content
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // Add some colored rectangles to simulate content
            UIColor.blue.setFill()
            context.fill(CGRect(x: size.width * 0.1, y: size.height * 0.1,
                                width: size.width * 0.3, height: size.height * 0.2))

            UIColor.red.setFill()
            context.fill(CGRect(x: size.width * 0.6, y: size.height * 0.3,
                                width: size.width * 0.2, height: size.height * 0.4))

            UIColor.green.setFill()
            context.fill(CGRect(x: size.width * 0.2, y: size.height * 0.7,
                                width: size.width * 0.5, height: size.height * 0.1))
        }
    }
}
