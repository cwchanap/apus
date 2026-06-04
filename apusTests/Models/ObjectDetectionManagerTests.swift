import XCTest
@testable import apus

final class DetectionModelTests: XCTestCase {

    func testDetection_creation() {
        let detection = Detection(
            boundingBox: CGRect(x: 0.1, y: 0.2, width: 0.3, height: 0.4),
            className: "person",
            confidence: 0.95
        )
        XCTAssertEqual(detection.className, "person")
        XCTAssertEqual(detection.confidence, 0.95)
        XCTAssertEqual(detection.boundingBox.origin.x, 0.1)
    }
}

final class ObjectDetectionManagerTests: XCTestCase {

    func testInit_doesNotLoadImmediately() {
        let manager = ObjectDetectionManager()
        XCTAssertFalse(manager.isInitialized)
        XCTAssertTrue(manager.detections.isEmpty)
    }

    func testPreload_setsIsInitialized() {
        let manager = ObjectDetectionManager()
        let expectation = self.expectation(description: "preload")
        expectation.expectedFulfillmentCount = 1

        manager.preload()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertTrue(manager.isInitialized)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 3.0)
    }

    func testDetections_initiallyEmpty() {
        let manager = ObjectDetectionManager()
        XCTAssertTrue(manager.detections.isEmpty)
    }
}

final class ClassificationErrorTests: XCTestCase {

    func testModelNotLoaded_description() {
        let error = ClassificationError.modelNotLoaded
        XCTAssertEqual(error.errorDescription, "Classification model could not be loaded")
    }

    func testInvalidImage_description() {
        let error = ClassificationError.invalidImage
        XCTAssertEqual(error.errorDescription, "Invalid image for classification")
    }

    func testProcessingFailed_description() {
        let error = ClassificationError.processingFailed
        XCTAssertEqual(error.errorDescription, "Image classification processing failed")
    }
}

final class ItemTests: XCTestCase {

    func testItem_creation() {
        let date = Date()
        let item = Item(timestamp: date)
        XCTAssertEqual(item.timestamp, date)
    }

    func testItem_defaultTimestamp() {
        let item = Item(timestamp: Date())
        XCTAssertNotNil(item.timestamp)
    }
}
