import XCTest
@testable import apus

final class VisionDetectionTests: XCTestCase {

    func testDisplayBoundingBox_flipsYCoordinate() {
        let detection = VisionDetection(
            boundingBox: CGRect(x: 0.1, y: 0.2, width: 0.3, height: 0.4),
            className: "person",
            confidence: 0.9
        )
        let display = detection.displayBoundingBox
        XCTAssertEqual(display.minX, 0.1, accuracy: 0.001)
        XCTAssertEqual(display.minY, 0.4, accuracy: 0.001)
        XCTAssertEqual(display.width, 0.3, accuracy: 0.001)
        XCTAssertEqual(display.height, 0.4, accuracy: 0.001)
    }

    func testDisplayBoundingBox_withTopOrigin() {
        let detection = VisionDetection(
            boundingBox: CGRect(x: 0.0, y: 0.8, width: 0.5, height: 0.2),
            className: "car",
            confidence: 0.85
        )
        let display = detection.displayBoundingBox
        XCTAssertEqual(display.minY, 0.0, accuracy: 0.001)
        XCTAssertEqual(display.height, 0.2, accuracy: 0.001)
    }

    func testDisplayBoundingBox_fullFrame() {
        let detection = VisionDetection(
            boundingBox: CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0),
            className: "background",
            confidence: 0.5
        )
        let display = detection.displayBoundingBox
        XCTAssertEqual(display.minX, 0.0, accuracy: 0.001)
        XCTAssertEqual(display.minY, 0.0, accuracy: 0.001)
        XCTAssertEqual(display.width, 1.0, accuracy: 0.001)
        XCTAssertEqual(display.height, 1.0, accuracy: 0.001)
    }

    func testVisionDetection_hasUniqueId() {
        let d1 = VisionDetection(boundingBox: .zero, className: "a", confidence: 0.5)
        let d2 = VisionDetection(boundingBox: .zero, className: "a", confidence: 0.5)
        XCTAssertNotEqual(d1.id, d2.id)
    }
}

final class MockVisionObjectDetectionManagerTests: XCTestCase {

    func testDetectObjects_returnsSuccess() {
        let manager = MockVisionObjectDetectionManager()
        let expectation = self.expectation(description: "completion")
        let image = UIImage(systemName: "photo")!

        manager.detectObjects(in: image) { result in
            switch result {
            case .success(let detections):
                XCTAssertFalse(detections.isEmpty)
            case .failure:
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 3.0)
    }

    func testDetectObjects_setsIsDetectingDuringProcessing() {
        let manager = MockVisionObjectDetectionManager()
        let image = UIImage(systemName: "photo")!

        manager.detectObjects(in: image) { _ in }
        XCTAssertTrue(manager.isDetecting)
    }

    func testDetectObjects_updatesLastDetectedObjects() {
        let manager = MockVisionObjectDetectionManager()
        let expectation = self.expectation(description: "completion")
        let image = UIImage(systemName: "photo")!

        XCTAssertTrue(manager.lastDetectedObjects.isEmpty)

        manager.detectObjects(in: image) { _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 3.0)
        XCTAssertFalse(manager.lastDetectedObjects.isEmpty)
    }
}
