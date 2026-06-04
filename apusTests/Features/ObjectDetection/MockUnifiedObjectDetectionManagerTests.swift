import XCTest
@testable import apus

final class MockUnifiedObjectDetectionManagerTests: XCTestCase {

    func testInit_setsFramework() {
        let visionManager = MockUnifiedObjectDetectionManager(framework: .vision)
        XCTAssertEqual(visionManager.framework, .vision)

        let coreMLManager = MockUnifiedObjectDetectionManager(framework: .coreML)
        XCTAssertEqual(coreMLManager.framework, .coreML)
    }

    func testDetectObjects_returnsSuccessForVision() {
        let manager = MockUnifiedObjectDetectionManager(framework: .vision)
        let expectation = self.expectation(description: "completion")
        let image = UIImage(systemName: "photo")!

        manager.detectObjects(in: image) { result in
            switch result {
            case .success(let objects):
                XCTAssertFalse(objects.isEmpty)
                objects.forEach { XCTAssertEqual($0.framework, .vision) }
            case .failure:
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 3.0)
    }

    func testDetectObjects_returnsSuccessForCoreML() {
        let manager = MockUnifiedObjectDetectionManager(framework: .coreML)
        let expectation = self.expectation(description: "completion")
        let image = UIImage(systemName: "photo")!

        manager.detectObjects(in: image) { result in
            switch result {
            case .success(let objects):
                XCTAssertFalse(objects.isEmpty)
                objects.forEach { XCTAssertEqual($0.framework, .coreML) }
            case .failure:
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 3.0)
    }

    func testDetectObjects_updatesLastDetectedObjects() {
        let manager = MockUnifiedObjectDetectionManager(framework: .vision)
        let expectation = self.expectation(description: "completion")
        let image = UIImage(systemName: "photo")!

        XCTAssertTrue(manager.lastDetectedObjects.isEmpty)

        manager.detectObjects(in: image) { _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 3.0)
        XCTAssertFalse(manager.lastDetectedObjects.isEmpty)
    }

    func testDetectObjects_setsIsDetectingDuringProcessing() {
        let manager = MockUnifiedObjectDetectionManager(framework: .vision)
        let image = UIImage(systemName: "photo")!

        manager.detectObjects(in: image) { _ in }
        XCTAssertTrue(manager.isDetecting)
    }

    func testDetectObjects_withDifferentImages_givesDifferentResults() {
        let manager = MockUnifiedObjectDetectionManager(framework: .vision)
        let expectation = self.expectation(description: "completion")
        expectation.expectedFulfillmentCount = 2

        let image1 = UIImage(systemName: "photo")!
        let image2 = UIImage(systemName: "star")!

        var results1: [DetectedObject] = []
        var results2: [DetectedObject] = []

        manager.detectObjects(in: image1) { result in
            if case .success(let objects) = result { results1 = objects }
            expectation.fulfill()
        }

        let manager2 = MockUnifiedObjectDetectionManager(framework: .vision)
        manager2.detectObjects(in: image2) { result in
            if case .success(let objects) = result { results2 = objects }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 3.0)
    }
}
