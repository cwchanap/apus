//
//  UIImageProcessingTests.swift
//  apusTests
//
//  Created by Rovo Dev on 31/7/2025.
//

import XCTest
@testable import apus
import UIKit

class UIImageProcessingTests: XCTestCase {
    
    var testImage: UIImage!
    var landscapeImage: UIImage!
    var portraitImage: UIImage!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Create test images with different orientations and sizes
        testImage = createTestImage(size: CGSize(width: 100, height: 100), orientation: .up)
        landscapeImage = createTestImage(size: CGSize(width: 200, height: 100), orientation: .up)
        portraitImage = createTestImage(size: CGSize(width: 100, height: 200), orientation: .up)
    }
    
    override func tearDownWithError() throws {
        testImage = nil
        landscapeImage = nil
        portraitImage = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Test Image Creation Helper
    
    private func createTestImage(size: CGSize, orientation: UIImage.Orientation = .up) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            // Create a simple test pattern
            UIColor.red.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            UIColor.blue.setFill()
            context.fill(CGRect(x: 0, y: 0, width: size.width/2, height: size.height/2))
        }
        
        // Create image with specific orientation if needed
        if orientation != .up {
            return UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: orientation)
        }
        
        return image
    }
    
    // MARK: - Normalization Tests
    
    func testNormalizedImageWithUpOrientation() {
        // Given
        let originalImage = testImage!
        
        // When
        let normalizedImage = originalImage.normalized()
        
        // Then
        XCTAssertEqual(normalizedImage.imageOrientation, .up)
        XCTAssertEqual(normalizedImage.size, originalImage.size)
    }
    
    func testNormalizedImageWithDifferentOrientation() {
        // Given
        let rotatedImage = createTestImage(size: CGSize(width: 100, height: 200), orientation: .left)
        
        // When
        let normalizedImage = rotatedImage.normalized()
        
        // Then
        XCTAssertEqual(normalizedImage.imageOrientation, .up)
        // Size should remain the same for the normalized image
        XCTAssertNotNil(normalizedImage.cgImage)
    }
    
    // MARK: - Aspect Ratio Resizing Tests
    
    func testResizedMaintainingAspectRatioSquareToSquare() {
        // Given
        let targetSize = CGSize(width: 50, height: 50)
        
        // When
        let resizedImage = testImage.resizedMaintainingAspectRatio(to: targetSize)
        
        // Then
        XCTAssertEqual(resizedImage.size, targetSize)
    }
    
    func testResizedMaintainingAspectRatioLandscapeToSquare() {
        // Given
        let targetSize = CGSize(width: 100, height: 100)
        
        // When
        let resizedImage = landscapeImage.resizedMaintainingAspectRatio(to: targetSize)
        
        // Then
        // Should fit width, height will be smaller to maintain aspect ratio
        XCTAssertEqual(resizedImage.size.width, 100)
        XCTAssertEqual(resizedImage.size.height, 50) // 200:100 ratio maintained
    }
    
    func testResizedMaintainingAspectRatioPortraitToSquare() {
        // Given
        let targetSize = CGSize(width: 100, height: 100)
        
        // When
        let resizedImage = portraitImage.resizedMaintainingAspectRatio(to: targetSize)
        
        // Then
        // Should fit height, width will be smaller to maintain aspect ratio
        XCTAssertEqual(resizedImage.size.width, 50) // 100:200 ratio maintained
        XCTAssertEqual(resizedImage.size.height, 100)
    }
    
    func testResizedMaintainingAspectRatioUpscaling() {
        // Given
        let targetSize = CGSize(width: 400, height: 400)
        
        // When
        let resizedImage = landscapeImage.resizedMaintainingAspectRatio(to: targetSize)
        
        // Then
        XCTAssertEqual(resizedImage.size.width, 400)
        XCTAssertEqual(resizedImage.size.height, 200) // Maintains 2:1 aspect ratio
    }
    
    // MARK: - Processing Preparation Tests
    
    func testPreparedForProcessingWithoutTargetSize() {
        // Given
        let originalImage = testImage!
        
        // When
        let processedImage = originalImage.preparedForProcessing()
        
        // Then
        XCTAssertEqual(processedImage.imageOrientation, .up)
        XCTAssertEqual(processedImage.size, originalImage.size)
    }
    
    func testPreparedForProcessingWithTargetSize() {
        // Given
        let targetSize = CGSize(width: 224, height: 224)
        
        // When
        let processedImage = landscapeImage.preparedForProcessing(targetSize: targetSize)
        
        // Then
        XCTAssertEqual(processedImage.imageOrientation, .up)
        
        // Verify aspect ratio is maintained (most important test)
        let originalAspectRatio = landscapeImage.size.width / landscapeImage.size.height
        let processedAspectRatio = processedImage.size.width / processedImage.size.height
        XCTAssertEqual(originalAspectRatio, processedAspectRatio, accuracy: 0.01, "Aspect ratio should be preserved")
        
        // Verify image fits within target bounds
        XCTAssertLessThanOrEqual(processedImage.size.width, targetSize.width, "Width should not exceed target")
        XCTAssertLessThanOrEqual(processedImage.size.height, targetSize.height, "Height should not exceed target")
        
        // Verify at least one dimension uses the full target size (efficient scaling)
        let usesFullWidth = abs(processedImage.size.width - targetSize.width) < 1.0
        let usesFullHeight = abs(processedImage.size.height - targetSize.height) < 1.0
        XCTAssertTrue(usesFullWidth || usesFullHeight, "Should use full available space in at least one dimension")
        
        // Verify the image was actually resized (not just normalized)
        XCTAssertNotEqual(processedImage.size, landscapeImage.size, "Image should be resized when target size is specified")
    }
    
    // MARK: - Display Preparation Tests
    
    func testPreparedForDisplaySmallImage() {
        // Given
        let smallImage = testImage!
        
        // When
        let displayImage = smallImage.preparedForDisplay()
        
        // Then
        XCTAssertEqual(displayImage.imageOrientation, .up)
        XCTAssertEqual(displayImage.size, smallImage.size) // Should not resize small images
    }
    
    func testPreparedForDisplayLargeImage() {
        // Given
        let largeImage = createTestImage(size: CGSize(width: 4000, height: 3000))
        
        // When
        let displayImage = largeImage.preparedForDisplay()
        
        // Then
        XCTAssertEqual(displayImage.imageOrientation, .up)
        // Should resize large images to max display size while maintaining aspect ratio
        XCTAssertLessThanOrEqual(displayImage.size.width, 2048)
        XCTAssertLessThanOrEqual(displayImage.size.height, 2048)
        
        // Check aspect ratio is maintained (4:3 ratio)
        let aspectRatio = displayImage.size.width / displayImage.size.height
        XCTAssertEqual(aspectRatio, 4.0/3.0, accuracy: 0.01)
    }
    
    // MARK: - Display Size Calculation Tests
    
    func testDisplaySizeWithinBoundsLandscape() {
        // Given
        let bounds = CGSize(width: 300, height: 200)
        
        // When
        let displaySize = landscapeImage.displaySize(within: bounds)
        
        // Then
        // Image is 200x100, bounds are 300x200
        // Should fit to width: 300x150
        XCTAssertEqual(displaySize.width, 300)
        XCTAssertEqual(displaySize.height, 150)
    }
    
    func testDisplaySizeWithinBoundsPortrait() {
        // Given
        let bounds = CGSize(width: 200, height: 300)
        
        // When
        let displaySize = portraitImage.displaySize(within: bounds)
        
        // Then
        // Image is 100x200, bounds are 200x300
        // Should fit to height: 150x300
        XCTAssertEqual(displaySize.width, 150)
        XCTAssertEqual(displaySize.height, 300)
    }
    
    func testDisplaySizeWithinBoundsSquare() {
        // Given
        let bounds = CGSize(width: 150, height: 150)
        
        // When
        let displaySize = testImage.displaySize(within: bounds)
        
        // Then
        // Square image should fit exactly
        XCTAssertEqual(displaySize.width, 150)
        XCTAssertEqual(displaySize.height, 150)
    }
    
    // MARK: - Edge Cases Tests
    
    func testResizeToZeroSize() {
        // Given
        let zeroSize = CGSize.zero
        
        // When
        let resizedImage = testImage.resizedMaintainingAspectRatio(to: zeroSize)
        
        // Then
        XCTAssertEqual(resizedImage.size, zeroSize)
    }
    
    func testDisplaySizeWithZeroBounds() {
        // Given
        let zeroBounds = CGSize.zero
        
        // When
        let displaySize = testImage.displaySize(within: zeroBounds)
        
        // Then
        XCTAssertEqual(displaySize, CGSize.zero)
    }
    
    // MARK: - Performance Tests
    
    func testNormalizationPerformance() {
        // Given
        let largeImage = createTestImage(size: CGSize(width: 2000, height: 2000))
        
        // When & Then
        measure {
            _ = largeImage.normalized()
        }
    }
    
    func testResizingPerformance() {
        // Given
        let largeImage = createTestImage(size: CGSize(width: 2000, height: 2000))
        let targetSize = CGSize(width: 500, height: 500)
        
        // When & Then
        measure {
            _ = largeImage.resizedMaintainingAspectRatio(to: targetSize)
        }
    }
    
    func testProcessingPreparationPerformance() {
        // Given
        let largeImage = createTestImage(size: CGSize(width: 2000, height: 2000))
        let targetSize = CGSize(width: 224, height: 224)
        
        // When & Then
        measure {
            _ = largeImage.preparedForProcessing(targetSize: targetSize)
        }
    }
}