import XCTest
@testable import apus

final class MockContourScenariosTests: XCTestCase {

    func testCreateDocumentContours_returnsNonEmpty() {
        let contours = MockContourScenarios.createDocumentContours()
        XCTAssertFalse(contours.isEmpty)
        XCTAssertTrue(contours.allSatisfy { $0.points.count >= 2 })
    }

    func testCreateNaturalContours_returnsNonEmpty() {
        let contours = MockContourScenarios.createNaturalContours()
        XCTAssertFalse(contours.isEmpty)
        XCTAssertTrue(contours.allSatisfy { $0.confidence > 0 })
    }

    func testCreateGeometricContours_returnsNonEmpty() {
        let contours = MockContourScenarios.createGeometricContours()
        XCTAssertEqual(contours.count, 3)
    }

    func testCreateEdgeHeavyContours_returnsNonEmpty() {
        let contours = MockContourScenarios.createEdgeHeavyContours()
        XCTAssertFalse(contours.isEmpty)
    }

    func testCreateSimpleContours_returnsNonEmpty() {
        let contours = MockContourScenarios.createSimpleContours()
        XCTAssertFalse(contours.isEmpty)
    }

    func testCreateComplexSceneContours_returnsNonEmpty() {
        let contours = MockContourScenarios.createComplexSceneContours()
        XCTAssertFalse(contours.isEmpty)
    }

    func testAllScenarios_haveValidBoundingBoxes() {
        let allScenarios: [[DetectedContour]] = [
            MockContourScenarios.createDocumentContours(),
            MockContourScenarios.createNaturalContours(),
            MockContourScenarios.createGeometricContours(),
            MockContourScenarios.createEdgeHeavyContours(),
            MockContourScenarios.createSimpleContours(),
            MockContourScenarios.createComplexSceneContours()
        ]

        for contours in allScenarios {
            for contour in contours {
                XCTAssertGreaterThan(contour.boundingBox.width, 0)
                XCTAssertGreaterThanOrEqual(contour.boundingBox.minX, 0)
                XCTAssertGreaterThanOrEqual(contour.boundingBox.minY, 0)
            }
        }
    }

    func testAllScenarios_haveValidConfidence() {
        let allScenarios: [[DetectedContour]] = [
            MockContourScenarios.createDocumentContours(),
            MockContourScenarios.createNaturalContours(),
            MockContourScenarios.createGeometricContours(),
            MockContourScenarios.createEdgeHeavyContours(),
            MockContourScenarios.createSimpleContours(),
            MockContourScenarios.createComplexSceneContours()
        ]

        for contours in allScenarios {
            for contour in contours {
                XCTAssertGreaterThan(contour.confidence, 0)
                XCTAssertLessThanOrEqual(contour.confidence, 1.0)
            }
        }
    }

    func testAllScenarios_haveValidAreas() {
        let allScenarios: [[DetectedContour]] = [
            MockContourScenarios.createDocumentContours(),
            MockContourScenarios.createNaturalContours(),
            MockContourScenarios.createGeometricContours(),
            MockContourScenarios.createEdgeHeavyContours(),
            MockContourScenarios.createSimpleContours(),
            MockContourScenarios.createComplexSceneContours()
        ]

        for contours in allScenarios {
            for contour in contours {
                XCTAssertGreaterThan(contour.area, 0)
            }
        }
    }
}
