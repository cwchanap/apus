//
//  DetectionResultsManagerCoverageTests.swift
//  apusTests
//
//  Created by Copilot on 2026/03/31.
//

import UIKit
import Vision
import XCTest
@testable import apus

@MainActor
final class DetectionResultsManagerCoverageTests: XCTestCase {
    private var sut: DetectionResultsManager!
    private var appSettings: AppSettings!
    private var testImage: UIImage!

    override func setUpWithError() throws {
        try super.setUpWithError()
        appSettings = AppSettings.shared
        appSettings.resetToDefaults()
        testImage = createTestImage(size: CGSize(width: 400, height: 300))
        sut = DetectionResultsManager()
        XCTAssertTrue(waitUntil { !self.sut.isLoading })
        resetManagerState()
    }

    override func tearDownWithError() throws {
        resetManagerState()
        testImage = nil
        sut = nil
        appSettings.resetToDefaults()
        appSettings = nil
        try super.tearDownWithError()
    }

    func test_saveResultsAcrossCategories_updatesCountsAndPersistsData() {
        sut.saveOCRResult(detectedTexts: makeDetectedTexts(text: "Receipt"), image: testImage)
        sut.saveObjectDetectionResult(detectedObjects: makeDetectedObjects(name: "person"), image: testImage)
        sut.saveClassificationResult(classificationResults: makeClassificationResults(identifier: "document"), image: testImage)
        sut.saveContourDetectionResult(detectedContours: makeContours(aspectRatio: 1.4), image: testImage)
        sut.saveBarcodeResult(detectedBarcodes: [makeBarcodeObservation()], image: testImage)

        XCTAssertEqual(sut.getResultsCount(for: .ocr), 1)
        XCTAssertEqual(sut.getResultsCount(for: .objectDetection), 1)
        XCTAssertEqual(sut.getResultsCount(for: .classification), 1)
        XCTAssertEqual(sut.getResultsCount(for: .contourDetection), 1)
        XCTAssertEqual(sut.getResultsCount(for: .barcode), 1)
        XCTAssertEqual(sut.totalResultsCount, 5)
        XCTAssertTrue(sut.hasAnyResults)
        XCTAssertTrue(waitUntil {
            !self.sut.ocrResultsData.isEmpty &&
            !self.sut.objectDetectionResultsData.isEmpty &&
            !self.sut.classificationResultsData.isEmpty &&
            !self.sut.contourDetectionResultsData.isEmpty &&
            !self.sut.barcodeDetectionResultsData.isEmpty
        })
    }

    func test_clearAllResults_resetsCollectionsAndCachedFlags() {
        populateAllCategories()

        sut.clearAllResults()

        XCTAssertTrue(sut.ocrResults.isEmpty)
        XCTAssertTrue(sut.objectDetectionResults.isEmpty)
        XCTAssertTrue(sut.classificationResults.isEmpty)
        XCTAssertTrue(sut.contourResults.isEmpty)
        XCTAssertTrue(sut.barcodeResults.isEmpty)
        XCTAssertEqual(sut.totalResultsCount, 0)
        XCTAssertFalse(sut.hasAnyResults)
    }

    func test_saveOCRResult_enforcesStorageLimitKeepingNewestEntry() {
        let originalLimit = appSettings.ocrResultsLimit
        defer { appSettings.ocrResultsLimit = originalLimit }
        appSettings.ocrResultsLimit = 1

        sut.saveOCRResult(detectedTexts: makeDetectedTexts(text: "Old"), image: testImage)
        sut.saveOCRResult(detectedTexts: makeDetectedTexts(text: "New"), image: testImage)

        XCTAssertEqual(sut.ocrResults.count, 1)
        XCTAssertEqual(sut.ocrResults.first?.detectedTexts.first?.text, "New")
    }

    func test_deleteOCRResultsAtOffsets_removesRequestedEntry() {
        sut.saveOCRResult(detectedTexts: makeDetectedTexts(text: "First"), image: testImage)
        sut.saveOCRResult(detectedTexts: makeDetectedTexts(text: "Second"), image: testImage)

        sut.deleteOCRResults(at: IndexSet(integer: 0))

        XCTAssertEqual(sut.ocrResults.count, 1)
        XCTAssertEqual(sut.ocrResults.first?.detectedTexts.first?.text, "First")
    }

    func test_deleteObjectDetectionResult_removesMatchingEntry() {
        sut.saveObjectDetectionResult(detectedObjects: makeDetectedObjects(name: "dog"), image: testImage)
        let storedID = sut.objectDetectionResults[0].id

        sut.deleteObjectDetectionResult(id: storedID)

        XCTAssertTrue(sut.objectDetectionResults.isEmpty)
        XCTAssertEqual(sut.getResultsCount(for: .objectDetection), 0)
    }

    func test_clearClassificationResults_removesEntriesAndUpdatesCounts() {
        sut.saveClassificationResult(classificationResults: makeClassificationResults(identifier: "dog"), image: testImage)
        sut.saveClassificationResult(classificationResults: makeClassificationResults(identifier: "cat"), image: testImage)

        sut.clearClassificationResults()

        XCTAssertTrue(sut.classificationResults.isEmpty)
        XCTAssertEqual(sut.getResultsCount(for: .classification), 0)
        XCTAssertFalse(sut.hasAnyResults)
    }

    func test_deleteContourDetectionResult_removesMatchingEntry() {
        sut.saveContourDetectionResult(detectedContours: makeContours(aspectRatio: 1.3), image: testImage)
        let storedID = sut.contourResults[0].id

        sut.deleteContourDetectionResult(id: storedID)

        XCTAssertTrue(sut.contourResults.isEmpty)
        XCTAssertEqual(sut.getResultsCount(for: .contourDetection), 0)
    }

    func test_deleteBarcodeDetectionResultsAtOffsets_removesRequestedEntry() {
        sut.saveBarcodeResult(detectedBarcodes: [makeBarcodeObservation()], image: testImage)
        sut.saveBarcodeResult(detectedBarcodes: [makeBarcodeObservation()], image: testImage)

        sut.deleteBarcodeDetectionResults(at: IndexSet(integer: 0))

        XCTAssertEqual(sut.barcodeResults.count, 1)
    }

    func test_loadResultsMethods_decodePersistedDataForAllCategories() throws {
        let storedOCR = StoredOCRResult(detectedTexts: makeDetectedTexts(text: "Loaded OCR"), image: testImage)
        let storedObject = StoredObjectDetectionResult(detectedObjects: makeDetectedObjects(name: "laptop"), image: testImage)
        let storedClassification = StoredClassificationResult(classificationResults: makeClassificationResults(identifier: "loaded"), image: testImage)
        let storedContour = StoredContourDetectionResult(detectedContours: makeContours(aspectRatio: 1.5), image: testImage)

        sut.ocrResultsData = try JSONEncoder().encode([storedOCR])
        sut.objectDetectionResultsData = try JSONEncoder().encode([storedObject])
        sut.classificationResultsData = try JSONEncoder().encode([storedClassification])
        sut.contourDetectionResultsData = try JSONEncoder().encode([storedContour])
        sut.barcodeDetectionResultsData = try makeBarcodeResultsData(payloads: [(payload: "barcode-1", symbology: "QR")])

        sut.loadOCRResults()
        sut.loadObjectDetectionResults()
        sut.loadClassificationResults()
        sut.loadContourDetectionResults()
        sut.loadBarcodeDetectionResults()

        XCTAssertEqual(sut.ocrResults.first?.detectedTexts.first?.text, "Loaded OCR")
        XCTAssertEqual(sut.objectDetectionResults.first?.detectedObjects.first?.className, "laptop")
        XCTAssertEqual(sut.classificationResults.first?.classificationResults.first?.identifier, "loaded")
        XCTAssertEqual(sut.contourResults.first?.totalContourCount, 1)
        XCTAssertEqual(sut.barcodeResults.first?.detectedBarcodes.first?.payload, "barcode-1")
        XCTAssertEqual(sut.totalResultsCount, 5)
    }

    func test_loadResultsMethods_invalidData_clearsCollections() throws {
        sut.ocrResults = [StoredOCRResult(detectedTexts: makeDetectedTexts(text: "Existing OCR"), image: testImage)]
        sut.objectDetectionResults = [StoredObjectDetectionResult(detectedObjects: makeDetectedObjects(name: "chair"), image: testImage)]
        sut.classificationResults = [StoredClassificationResult(classificationResults: makeClassificationResults(identifier: "existing"), image: testImage)]
        sut.contourResults = [StoredContourDetectionResult(detectedContours: makeContours(aspectRatio: 1.1), image: testImage)]
        sut.barcodeResults = [try makeBarcodeResult(payloads: [(payload: "existing", symbology: "QR")])]

        sut.ocrResultsData = Data("bad-json".utf8)
        sut.objectDetectionResultsData = Data("bad-json".utf8)
        sut.classificationResultsData = Data("bad-json".utf8)
        sut.contourDetectionResultsData = Data("bad-json".utf8)
        sut.barcodeDetectionResultsData = Data("bad-json".utf8)

        sut.loadOCRResults()
        sut.loadObjectDetectionResults()
        sut.loadClassificationResults()
        sut.loadContourDetectionResults()
        sut.loadBarcodeDetectionResults()

        XCTAssertTrue(sut.ocrResults.isEmpty)
        XCTAssertTrue(sut.objectDetectionResults.isEmpty)
        XCTAssertTrue(sut.classificationResults.isEmpty)
        XCTAssertTrue(sut.contourResults.isEmpty)
        XCTAssertTrue(sut.barcodeResults.isEmpty)
        XCTAssertEqual(sut.totalResultsCount, 0)
        XCTAssertFalse(sut.hasAnyResults)
    }

    func test_asyncLoaders_returnDecodedResultsForValidData() async throws {
        let ocrData = try JSONEncoder().encode([StoredOCRResult(detectedTexts: makeDetectedTexts(text: "Async OCR"), image: testImage)])
        let objectData = try JSONEncoder().encode([StoredObjectDetectionResult(detectedObjects: makeDetectedObjects(name: "keyboard"), image: testImage)])
        let classificationData = try JSONEncoder().encode([StoredClassificationResult(classificationResults: makeClassificationResults(identifier: "async"), image: testImage)])
        let contourData = try JSONEncoder().encode([StoredContourDetectionResult(detectedContours: makeContours(aspectRatio: 1.2), image: testImage)])
        let barcodeData = try makeBarcodeResultsData(payloads: [(payload: "async-barcode", symbology: "Code128")])

        let ocrResults = await sut.loadOCRResultsAsync(from: ocrData)
        let objectResults = await sut.loadObjectDetectionResultsAsync(from: objectData)
        let classificationResults = await sut.loadClassificationResultsAsync(from: classificationData)
        let contourResults = await sut.loadContourDetectionResultsAsync(from: contourData)
        let barcodeResults = await sut.loadBarcodeDetectionResultsAsync(from: barcodeData)

        XCTAssertEqual(ocrResults.first?.detectedTexts.first?.text, "Async OCR")
        XCTAssertEqual(objectResults.first?.detectedObjects.first?.className, "keyboard")
        XCTAssertEqual(classificationResults.first?.classificationResults.first?.identifier, "async")
        XCTAssertEqual(contourResults.first?.totalContourCount, 1)
        XCTAssertEqual(barcodeResults.first?.detectedBarcodes.first?.payload, "async-barcode")
    }

    func test_asyncLoaders_returnEmptyArrays_forEmptyData() async {
        let ocrResults = await sut.loadOCRResultsAsync(from: Data())
        let objectResults = await sut.loadObjectDetectionResultsAsync(from: Data())
        let classificationResults = await sut.loadClassificationResultsAsync(from: Data())
        let contourResults = await sut.loadContourDetectionResultsAsync(from: Data())
        let barcodeResults = await sut.loadBarcodeDetectionResultsAsync(from: Data())

        XCTAssertTrue(ocrResults.isEmpty)
        XCTAssertTrue(objectResults.isEmpty)
        XCTAssertTrue(classificationResults.isEmpty)
        XCTAssertTrue(contourResults.isEmpty)
        XCTAssertTrue(barcodeResults.isEmpty)
    }

    func test_asyncLoaders_returnEmptyArrays_forInvalidData() async {
        let invalidData = Data("bad-json".utf8)

        let ocrResults = await sut.loadOCRResultsAsync(from: invalidData)
        let objectResults = await sut.loadObjectDetectionResultsAsync(from: invalidData)
        let classificationResults = await sut.loadClassificationResultsAsync(from: invalidData)
        let contourResults = await sut.loadContourDetectionResultsAsync(from: invalidData)
        let barcodeResults = await sut.loadBarcodeDetectionResultsAsync(from: invalidData)

        XCTAssertTrue(ocrResults.isEmpty)
        XCTAssertTrue(objectResults.isEmpty)
        XCTAssertTrue(classificationResults.isEmpty)
        XCTAssertTrue(contourResults.isEmpty)
        XCTAssertTrue(barcodeResults.isEmpty)
    }

    private func populateAllCategories() {
        sut.saveOCRResult(detectedTexts: makeDetectedTexts(text: "Receipt"), image: testImage)
        sut.saveObjectDetectionResult(detectedObjects: makeDetectedObjects(name: "book"), image: testImage)
        sut.saveClassificationResult(classificationResults: makeClassificationResults(identifier: "note"), image: testImage)
        sut.saveContourDetectionResult(detectedContours: makeContours(aspectRatio: 1.4), image: testImage)
        sut.saveBarcodeResult(detectedBarcodes: [makeBarcodeObservation()], image: testImage)
        XCTAssertTrue(waitUntil {
            !self.sut.ocrResultsData.isEmpty &&
            !self.sut.objectDetectionResultsData.isEmpty &&
            !self.sut.classificationResultsData.isEmpty &&
            !self.sut.contourDetectionResultsData.isEmpty &&
            !self.sut.barcodeDetectionResultsData.isEmpty
        })
    }

    private func resetManagerState() {
        guard let sut else { return }
        sut.ocrResults = []
        sut.objectDetectionResults = []
        sut.classificationResults = []
        sut.contourResults = []
        sut.barcodeResults = []
        sut.ocrResultsData = Data()
        sut.objectDetectionResultsData = Data()
        sut.classificationResultsData = Data()
        sut.contourDetectionResultsData = Data()
        sut.barcodeDetectionResultsData = Data()
        sut.isLoading = false
        sut.updateCachedValues()
    }

    private func makeDetectedTexts(text: String) -> [DetectedText] {
        [
            DetectedText(
                text: text,
                boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.4, height: 0.12),
                confidence: 0.94,
                characterBoxes: []
            )
        ]
    }

    private func makeDetectedObjects(name: String) -> [DetectedObject] {
        [
            DetectedObject(
                boundingBox: CGRect(x: 0.2, y: 0.15, width: 0.4, height: 0.35),
                className: name,
                confidence: 0.91,
                framework: .vision
            )
        ]
    }

    private func makeClassificationResults(identifier: String) -> [ClassificationResult] {
        [
            ClassificationResult(identifier: identifier, confidence: 0.88)
        ]
    }

    private func makeContours(aspectRatio: Float) -> [DetectedContour] {
        [
            DetectedContour(
                points: [
                    CGPoint(x: 0.1, y: 0.1),
                    CGPoint(x: 0.7, y: 0.1),
                    CGPoint(x: 0.7, y: 0.55),
                    CGPoint(x: 0.1, y: 0.55)
                ],
                boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.6, height: 0.45),
                confidence: 0.86,
                aspectRatio: aspectRatio,
                area: 0.27
            )
        ]
    }

    private func makeBarcodeObservation() -> VNBarcodeObservation {
        VNBarcodeObservation()
    }

    private func makeBarcodeResultsData(payloads: [(payload: String, symbology: String)]) throws -> Data {
        let fixtures = [
            DetectionResultsTestSupport.StoredBarcodeDetectionResultFixture(
                timestamp: Date(timeIntervalSince1970: 1_234),
                detectedBarcodes: payloads.map { payloadInfo in
                    DetectionResultsTestSupport.StoredDetectedBarcodeFixture(
                        payload: payloadInfo.payload,
                        symbology: payloadInfo.symbology,
                        boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.4, height: 0.4),
                        confidence: 0.92
                    )
                },
                imageData: testImage.jpegData(compressionQuality: 0.7) ?? Data(),
                imageSize: testImage.size,
                thumbnailData: nil
            )
        ]
        return try JSONEncoder().encode(fixtures)
    }

    private func makeBarcodeResult(payloads: [(payload: String, symbology: String)]) throws -> StoredBarcodeDetectionResult {
        let data = try makeBarcodeResultsData(payloads: payloads)
        return try XCTUnwrap(JSONDecoder().decode([StoredBarcodeDetectionResult].self, from: data).first)
    }

    @discardableResult
    private func waitUntil(timeout: TimeInterval = 15.0, pollInterval: TimeInterval = 0.01, condition: () -> Bool) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(pollInterval))
        }
        return condition()
    }

    private func createTestImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            UIColor.systemBlue.setFill()
            context.fill(CGRect(x: size.width * 0.1, y: size.height * 0.2, width: size.width * 0.5, height: size.height * 0.3))
        }
    }
}
