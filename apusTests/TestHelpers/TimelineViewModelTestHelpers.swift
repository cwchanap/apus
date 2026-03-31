//
//  TimelineViewModelTestHelpers.swift
//  apusTests
//
//  Created by Codex on 2026/03/30.
//

import XCTest
import Combine
import UIKit
@testable import apus

@MainActor
class TimelineViewModelTestCase: XCTestCase {
    var sut: TimelineViewModel!
    var resultsManager: DetectionResultsManager!
    var testImage: UIImage!
    var cancellables: Set<AnyCancellable>!
    var testContainer: TestDIContainer!

    override func setUp() async throws {
        try await super.setUp()

        AppDependencies.shared.configureForTesting()
        clearPersistedResults()

        testContainer = TestDIContainer()
        TestDependencySetup.setupMockDependencies(container: testContainer)
        testContainer.register(DetectionResultsManager.self, instance: DetectionResultsManager())

        resultsManager = testContainer.resolve(DetectionResultsManager.self)
        testImage = createTestImage(size: CGSize(width: 100, height: 100))
        sut = TimelineViewModel(resultsManager: resultsManager)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() async throws {
        sut = nil
        resultsManager = nil
        testImage = nil
        cancellables = nil
        testContainer = nil
        clearPersistedResults()
        try await super.tearDown()
    }

    func createTestImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }

    func createOCRResult(text: String = "Test", timestamp: Date = Date()) -> StoredOCRResult {
        let texts = [DetectedText(text: text, boundingBox: .zero, confidence: 0.9, characterBoxes: [])]
        return StoredOCRResult(detectedTexts: texts, image: testImage, timestamp: timestamp)
    }

    func createObjectDetectionResult(className: String = "person", timestamp: Date = Date()) -> StoredObjectDetectionResult {
        let objects = [DetectedObject(boundingBox: .zero, className: className, confidence: 0.9, framework: .vision)]
        return StoredObjectDetectionResult(detectedObjects: objects, image: testImage, timestamp: timestamp)
    }

    func createClassificationResult(identifier: String = "dog", timestamp: Date = Date()) -> StoredClassificationResult {
        let classifications = [ClassificationResult(identifier: identifier, confidence: 0.9)]
        return StoredClassificationResult(classificationResults: classifications, image: testImage, timestamp: timestamp)
    }

    private func clearPersistedResults() {
        let defaults = UserDefaults.standard
        let keys = [
            "stored_ocr_results",
            "stored_object_detection_results",
            "stored_classification_results",
            "stored_contour_detection_results",
            "stored_barcode_detection_results"
        ]

        keys.forEach(defaults.removeObject(forKey:))
    }
}
