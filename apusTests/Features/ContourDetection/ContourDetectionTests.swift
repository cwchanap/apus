import XCTest
@testable import apus

final class DetectedContourTests: XCTestCase {

    func testIsRectangular_withFourPointsAndValidAspectRatio_returnsTrue() {
        let contour = DetectedContour(
            points: [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1), CGPoint(x: 0, y: 1)],
            boundingBox: CGRect(x: 0, y: 0, width: 1, height: 1),
            confidence: 0.9,
            aspectRatio: 1.0,
            area: 1.0
        )
        XCTAssertTrue(contour.isRectangular)
    }

    func testIsRectangular_withFewerThanFourPoints_returnsFalse() {
        let contour = DetectedContour(
            points: [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0)],
            boundingBox: CGRect(x: 0, y: 0, width: 1, height: 0),
            confidence: 0.9,
            aspectRatio: 1.0,
            area: 0.5
        )
        XCTAssertFalse(contour.isRectangular)
    }

    func testIsRectangular_withTooWideAspectRatio_returnsFalse() {
        let contour = DetectedContour(
            points: [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 0.1), CGPoint(x: 0, y: 0.1)],
            boundingBox: CGRect(x: 0, y: 0, width: 1, height: 0.1),
            confidence: 0.9,
            aspectRatio: 5.0,
            area: 0.1
        )
        XCTAssertFalse(contour.isRectangular)
    }

    func testIsRectangular_withTooNarrowAspectRatio_returnsFalse() {
        let contour = DetectedContour(
            points: [CGPoint(x: 0, y: 0), CGPoint(x: 0.1, y: 0), CGPoint(x: 0.1, y: 1), CGPoint(x: 0, y: 1)],
            boundingBox: CGRect(x: 0, y: 0, width: 0.1, height: 1),
            confidence: 0.9,
            aspectRatio: 0.1,
            area: 0.1
        )
        XCTAssertFalse(contour.isRectangular)
    }

    func testContourType_document() {
        let contour = DetectedContour(
            points: [CGPoint](repeating: CGPoint(x: 0.5, y: 0.5), count: 4),
            boundingBox: .zero,
            confidence: 0.9,
            aspectRatio: 1.5,
            area: 0.5
        )
        XCTAssertEqual(contour.contourType, .document)
    }

    func testContourType_square() {
        let contour = DetectedContour(
            points: [CGPoint](repeating: CGPoint(x: 0.5, y: 0.5), count: 4),
            boundingBox: .zero,
            confidence: 0.9,
            aspectRatio: 1.0,
            area: 0.5
        )
        XCTAssertEqual(contour.contourType, .square)
    }

    func testContourType_rectangle() {
        let contour = DetectedContour(
            points: [CGPoint](repeating: CGPoint(x: 0.5, y: 0.5), count: 4),
            boundingBox: .zero,
            confidence: 0.9,
            aspectRatio: 2.5,
            area: 0.5
        )
        XCTAssertEqual(contour.contourType, .rectangle)
    }

    func testContourType_complex() {
        let contour = DetectedContour(
            points: [CGPoint](repeating: CGPoint(x: 0.5, y: 0.5), count: 10),
            boundingBox: .zero,
            confidence: 0.9,
            aspectRatio: 0.1,
            area: 0.5
        )
        XCTAssertEqual(contour.contourType, .complex)
    }

    func testContourType_simple() {
        let contour = DetectedContour(
            points: [CGPoint](repeating: CGPoint(x: 0.5, y: 0.5), count: 3),
            boundingBox: .zero,
            confidence: 0.9,
            aspectRatio: 0.1,
            area: 0.5
        )
        XCTAssertEqual(contour.contourType, .simple)
    }

    func testContourType_allCases() {
        XCTAssertEqual(ContourType.allCases.count, 5)
        XCTAssertEqual(ContourType.document.rawValue, "Document")
        XCTAssertEqual(ContourType.rectangle.rawValue, "Rectangle")
        XCTAssertEqual(ContourType.square.rawValue, "Square")
        XCTAssertEqual(ContourType.complex.rawValue, "Complex Shape")
        XCTAssertEqual(ContourType.simple.rawValue, "Simple Shape")
    }

    func testContourType_colors() {
        XCTAssertNotNil(ContourType.document.color)
        XCTAssertNotNil(ContourType.rectangle.color)
        XCTAssertNotNil(ContourType.square.color)
        XCTAssertNotNil(ContourType.complex.color)
        XCTAssertNotNil(ContourType.simple.color)
    }
}

final class ContourDetectionErrorTests: XCTestCase {

    func testInvalidImage_description() {
        let error = ContourDetectionError.invalidImage
        XCTAssertEqual(error.errorDescription, "Invalid image for contour detection")
    }

    func testProcessingFailed_description() {
        let error = ContourDetectionError.processingFailed
        XCTAssertEqual(error.errorDescription, "Contour detection processing failed")
    }

    func testNoContoursFound_description() {
        let error = ContourDetectionError.noContoursFound
        XCTAssertEqual(error.errorDescription, "No contours found in the image")
    }
}

final class ContourDetectionManagerTests: XCTestCase {

    func testDetectContours_withInvalidImage_returnsError() {
        let manager = ContourDetectionManager()
        let expectation = self.expectation(description: "completion")
        let invalidImage = UIImage()

        manager.detectContours(in: invalidImage) { result in
            switch result {
            case .failure(let error):
                XCTAssertTrue(error is ContourDetectionError)
            case .success:
                XCTFail("Expected failure for invalid image")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2.0)
    }

    func testDetectContours_isDetectingSetToFalseAfterCompletion() {
        let manager = ContourDetectionManager()
        let expectation = self.expectation(description: "completion")
        let invalidImage = UIImage()

        manager.detectContours(in: invalidImage) { _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2.0)
        XCTAssertFalse(manager.isDetecting)
    }
}

final class MockContourDetectionManagerTests: XCTestCase {

    func testDetectContours_callsCompletionWithSuccess() {
        let manager = MockContourDetectionManager()
        let expectation = self.expectation(description: "completion")
        let image = UIImage(systemName: "photo")!

        manager.detectContours(in: image) { result in
            switch result {
            case .success(let contours):
                XCTAssertFalse(contours.isEmpty)
            case .failure:
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 3.0)
    }

    func testDetectContours_setsIsDetecting() {
        let manager = MockContourDetectionManager()
        let image = UIImage(systemName: "photo")!

        XCTAssertTrue(manager.isDetecting == false)
        manager.detectContours(in: image) { _ in }

        XCTAssertTrue(manager.isDetecting)
    }
}
