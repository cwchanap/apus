//
//  DetectedObjectTests.swift
//  apusTests
//
//  Created by Copilot on 2026/03/31.
//

import UIKit
import XCTest
@testable import apus

final class DetectedObjectTests: XCTestCase {
    func testDisplayBoundingBoxBasicTransformation() {
        let detectedObject = makeDetectedObject(boundingBox: CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5))
        let displayBox = detectedObject.displayBoundingBox(
            imageSize: CGSize(width: 400, height: 300),
            displaySize: CGSize(width: 400, height: 300)
        )

        XCTAssertEqual(displayBox.origin.x, 100, accuracy: 1.0)
        XCTAssertEqual(displayBox.origin.y, 75, accuracy: 1.0)
        XCTAssertEqual(displayBox.width, 200, accuracy: 1.0)
        XCTAssertEqual(displayBox.height, 150, accuracy: 1.0)
    }

    func testDisplayBoundingBoxWhenImageIsWiderThanDisplay_addsVerticalOffset() {
        let detectedObject = makeDetectedObject(boundingBox: CGRect(x: 0, y: 0, width: 1, height: 1))
        let displayBox = detectedObject.displayBoundingBox(
            imageSize: CGSize(width: 800, height: 400),
            displaySize: CGSize(width: 400, height: 400)
        )

        XCTAssertEqual(displayBox.origin.x, 0, accuracy: 1.0)
        XCTAssertEqual(displayBox.origin.y, 100, accuracy: 1.0)
        XCTAssertEqual(displayBox.width, 400, accuracy: 1.0)
        XCTAssertEqual(displayBox.height, 200, accuracy: 1.0)
    }

    func testDisplayBoundingBoxWhenImageIsTallerThanDisplay_addsHorizontalOffset() {
        let detectedObject = makeDetectedObject(boundingBox: CGRect(x: 0, y: 0, width: 1, height: 1))
        let displayBox = detectedObject.displayBoundingBox(
            imageSize: CGSize(width: 300, height: 600),
            displaySize: CGSize(width: 400, height: 400)
        )

        XCTAssertEqual(displayBox.origin.x, 100, accuracy: 1.0)
        XCTAssertEqual(displayBox.origin.y, 0, accuracy: 1.0)
        XCTAssertEqual(displayBox.width, 200, accuracy: 1.0)
        XCTAssertEqual(displayBox.height, 400, accuracy: 1.0)
    }

    func testDisplayBoundingBoxClampsWithinDisplayBounds() {
        let detectedObject = makeDetectedObject(boundingBox: CGRect(x: 0.9, y: 0.92, width: 0.2, height: 0.15))
        let displaySize = CGSize(width: 200, height: 150)
        let displayBox = detectedObject.displayBoundingBox(
            imageSize: CGSize(width: 400, height: 300),
            displaySize: displaySize
        )

        XCTAssertGreaterThanOrEqual(displayBox.minX, 0)
        XCTAssertGreaterThanOrEqual(displayBox.minY, 0)
        XCTAssertLessThanOrEqual(displayBox.maxX, displaySize.width)
        XCTAssertLessThanOrEqual(displayBox.maxY, displaySize.height)
    }

    func testDisplayBoundingBoxReturnsConsistentResults() {
        let detectedObject = makeDetectedObject(boundingBox: CGRect(x: 0.3, y: 0.2, width: 0.4, height: 0.3))
        let imageSize = CGSize(width: 800, height: 600)
        let displaySize = CGSize(width: 320, height: 240)

        let first = detectedObject.displayBoundingBox(imageSize: imageSize, displaySize: displaySize)
        let second = detectedObject.displayBoundingBox(imageSize: imageSize, displaySize: displaySize)

        XCTAssertEqual(first, second)
    }

    func testObjectDetectionFactoryReturnsManagerUsingRequestedFramework() {
        let manager = ObjectDetectionFactory.createObjectDetectionManager(framework: .coreML)

        XCTAssertEqual(manager.framework, .coreML)
    }

    private func makeDetectedObject(boundingBox: CGRect) -> DetectedObject {
        DetectedObject(
            boundingBox: boundingBox,
            className: "person",
            confidence: 0.92,
            framework: .vision
        )
    }
}
