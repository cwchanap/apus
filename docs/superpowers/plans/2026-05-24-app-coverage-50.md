# App Coverage 50% Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Exclude test projects from Codecov accounting and raise local `apus.app` target coverage from 15.6% to at least 50.0%.

**Architecture:** Keep production behavior unchanged and increase coverage by exercising real app view branches through a reusable SwiftUI hosting harness. Add Codecov path filtering for test targets, centralize detection result fixtures, then render empty and populated states for high-line SwiftUI screens, overlays, and result detail views.

**Tech Stack:** Swift, SwiftUI, XCTest, Xcode coverage, XcodeBuildMCP or `xcodebuild`, Codecov YAML.

---

## File Structure

- Create `.codecov.yml`: Codecov project status target and ignored test-project paths.
- Create `apusTests/TestHelpers/ViewRenderingTestHarness.swift`: one reusable helper that mounts SwiftUI views in `UIHostingController` and forces layout.
- Create `apusTests/TestHelpers/DetectionResultFixtures.swift`: shared deterministic fixtures for images, stored result models, barcode JSON decoding, and populated `DetectionResultsManager` instances.
- Create `apusTests/Results/ResultsViewCoverageTests.swift`: rendering coverage for dashboard, category result views, shared result components, result rows, and detail views.
- Create `apusTests/Features/Timeline/TimelineViewCoverageTests.swift`: rendering coverage for timeline shell, rows, filters, section headers, empty states, and all detail sheet wrappers.
- Create `apusTests/ViewCoverage/SettingsAndPreviewViewCoverageTests.swift`: rendering coverage for settings/storage-limit views and preview/overlay views.
- Modify only if compilation requires it: `apus.xcodeproj/project.pbxproj` to add new test files to `apusTests`.

## Task 1: Add Codecov Test-Project Exclusion

**Files:**
- Create: `.codecov.yml`

- [ ] **Step 1: Write the Codecov config**

```yaml
coverage:
  status:
    project:
      default:
        target: 50%
        threshold: 1%
        if_ci_failed: error

ignore:
  - "apusTests/**"
  - "apusUITests/**"
```

- [ ] **Step 2: Verify YAML syntax by reading it back**

Run: `sed -n '1,80p' .codecov.yml`

Expected: output shows exactly the `coverage.status.project.default` block and `ignore` entries for `apusTests/**` and `apusUITests/**`.

- [ ] **Step 3: Commit**

```bash
git add .codecov.yml
git commit -m "ci: exclude test targets from codecov"
```

## Task 2: Add SwiftUI Rendering Harness And Shared Fixtures

**Files:**
- Create: `apusTests/TestHelpers/ViewRenderingTestHarness.swift`
- Create: `apusTests/TestHelpers/DetectionResultFixtures.swift`

- [ ] **Step 1: Create the rendering harness**

Create `apusTests/TestHelpers/ViewRenderingTestHarness.swift`:

```swift
//
//  ViewRenderingTestHarness.swift
//  apusTests
//
//  Created by Codex on 2026/05/24.
//

import SwiftUI
import UIKit
import XCTest

@MainActor
enum ViewRenderingTestHarness {
    static func render<V: View>(
        _ view: V,
        size: CGSize = CGSize(width: 390, height: 844),
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let window = UIWindow(frame: CGRect(origin: .zero, size: size))
        let host = UIHostingController(rootView: view)
        window.rootViewController = host
        window.makeKeyAndVisible()

        host.view.frame = window.bounds
        host.view.setNeedsLayout()
        host.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        host.view.setNeedsLayout()
        host.view.layoutIfNeeded()

        XCTAssertEqual(host.view.bounds.size.width, size.width, accuracy: 0.5, file: file, line: line)
        XCTAssertEqual(host.view.bounds.size.height, size.height, accuracy: 0.5, file: file, line: line)

        window.isHidden = true
    }
}
```

- [ ] **Step 2: Create deterministic detection fixtures**

Create `apusTests/TestHelpers/DetectionResultFixtures.swift`:

```swift
//
//  DetectionResultFixtures.swift
//  apusTests
//
//  Created by Codex on 2026/05/24.
//

import CoreGraphics
import UIKit
import Vision
@testable import apus

enum DetectionResultFixtures {
    static let timestamp = Date(timeIntervalSince1970: 1_700_000_000)

    static func image(size: CGSize = CGSize(width: 400, height: 300)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            UIColor.systemBlue.setFill()
            context.fill(CGRect(x: size.width * 0.1, y: size.height * 0.2, width: size.width * 0.5, height: size.height * 0.3))
        }
    }

    static func detectedTexts() -> [DetectedText] {
        [
            DetectedText(text: "Receipt", boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.4, height: 0.12), confidence: 0.94, characterBoxes: []),
            DetectedText(text: "Total 12.50", boundingBox: CGRect(x: 0.2, y: 0.4, width: 0.5, height: 0.1), confidence: 0.82, characterBoxes: [])
        ]
    }

    static func detectedObjects() -> [DetectedObject] {
        [
            DetectedObject(boundingBox: CGRect(x: 0.2, y: 0.15, width: 0.4, height: 0.35), className: "book", confidence: 0.91, framework: .vision),
            DetectedObject(boundingBox: CGRect(x: 0.55, y: 0.25, width: 0.25, height: 0.3), className: "laptop", confidence: 0.73, framework: .coreML)
        ]
    }

    static func classifications() -> [ClassificationResult] {
        [
            ClassificationResult(identifier: "document", confidence: 0.88),
            ClassificationResult(identifier: "receipt", confidence: 0.74),
            ClassificationResult(identifier: "paper", confidence: 0.61)
        ]
    }

    static func contours() -> [DetectedContour] {
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
                aspectRatio: 1.33,
                area: 0.27
            )
        ]
    }

    static func ocrResult() -> StoredOCRResult {
        StoredOCRResult(detectedTexts: detectedTexts(), image: image(), timestamp: timestamp)
    }

    static func objectResult() -> StoredObjectDetectionResult {
        StoredObjectDetectionResult(detectedObjects: detectedObjects(), image: image(), timestamp: timestamp)
    }

    static func classificationResult() -> StoredClassificationResult {
        StoredClassificationResult(classificationResults: classifications(), image: image(), timestamp: timestamp)
    }

    static func contourResult() -> StoredContourDetectionResult {
        StoredContourDetectionResult(detectedContours: contours(), image: image())
    }

    static func barcodeResult(payloads: [(payload: String, symbology: String)] = [("https://example.com/docs", "QR")]) -> StoredBarcodeDetectionResult {
        struct StoredDetectedBarcodeFixture: Codable {
            let payload: String
            let symbology: String
            let boundingBox: CGRect
            let confidence: Float
        }

        struct StoredBarcodeDetectionResultFixture: Codable {
            let timestamp: Date
            let detectedBarcodes: [StoredDetectedBarcodeFixture]
            let imageData: Data
            let imageSize: CGSize
            let thumbnailData: Data?
        }

        let fixtureImage = image()
        let fixture = StoredBarcodeDetectionResultFixture(
            timestamp: timestamp,
            detectedBarcodes: payloads.map { payloadInfo in
                StoredDetectedBarcodeFixture(
                    payload: payloadInfo.payload,
                    symbology: payloadInfo.symbology,
                    boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.4, height: 0.4),
                    confidence: 0.92
                )
            },
            imageData: fixtureImage.jpegData(compressionQuality: 0.7) ?? Data(),
            imageSize: fixtureImage.size,
            thumbnailData: nil
        )

        let data = try! JSONEncoder().encode([fixture])
        return try! JSONDecoder().decode([StoredBarcodeDetectionResult].self, from: data)[0]
    }

    @MainActor
    static func emptyManager(isLoading: Bool = false) -> DetectionResultsManager {
        let manager = DetectionResultsManager()
        waitUntilLoaded(manager)
        reset(manager)
        manager.isLoading = isLoading
        return manager
    }

    @MainActor
    static func populatedManager() -> DetectionResultsManager {
        let manager = emptyManager()
        manager.ocrResults = [ocrResult()]
        manager.objectDetectionResults = [objectResult()]
        manager.classificationResults = [classificationResult()]
        manager.contourResults = [contourResult()]
        manager.barcodeResults = [barcodeResult(payloads: [("https://example.com/docs", "QR"), ("9781234567890", "EAN13")])]
        manager.updateCachedValues()
        return manager
    }

    @MainActor
    static func reset(_ manager: DetectionResultsManager) {
        manager.ocrResults = []
        manager.objectDetectionResults = []
        manager.classificationResults = []
        manager.contourResults = []
        manager.barcodeResults = []
        manager.ocrResultsData = Data()
        manager.objectDetectionResultsData = Data()
        manager.classificationResultsData = Data()
        manager.contourDetectionResultsData = Data()
        manager.barcodeDetectionResultsData = Data()
        manager.isLoading = false
        manager.updateCachedValues()
    }

    @MainActor
    private static func waitUntilLoaded(_ manager: DetectionResultsManager, timeout: TimeInterval = 1.0) {
        let deadline = Date().addingTimeInterval(timeout)
        while manager.isLoading && Date() < deadline {
            RunLoop.main.run(until: Date().addingTimeInterval(0.01))
        }
    }
}
```

- [ ] **Step 3: Run helper-file compilation through a focused test build**

Run:

```bash
xcodebuild \
  -project apus.xcodeproj \
  -scheme apus-ci \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:apusTests/DetectionResultsModelsTests/testDetectionCategoryAllCases \
  -derivedDataPath build/DerivedData \
  test
```

Expected: PASS. If Xcode reports that the new Swift files are not in the `apusTests` target, add them to `apus.xcodeproj/project.pbxproj` using the same `PBXFileSystemSynchronizedRootGroup` convention already used by this project, then rerun.

- [ ] **Step 4: Commit**

```bash
git add apusTests/TestHelpers/ViewRenderingTestHarness.swift apusTests/TestHelpers/DetectionResultFixtures.swift apus.xcodeproj/project.pbxproj
git commit -m "test: add swiftui coverage harness"
```

## Task 3: Cover Results Dashboard And Result Detail Views

**Files:**
- Create: `apusTests/Results/ResultsViewCoverageTests.swift`

- [ ] **Step 1: Add rendering tests for result screens**

Create `apusTests/Results/ResultsViewCoverageTests.swift`:

```swift
//
//  ResultsViewCoverageTests.swift
//  apusTests
//
//  Created by Codex on 2026/05/24.
//

import SwiftUI
import XCTest
@testable import apus

@MainActor
final class ResultsViewCoverageTests: XCTestCase {
    override func setUp() {
        super.setUp()
        AppSettings.shared.resetToDefaults()
    }

    override func tearDown() {
        AppSettings.shared.resetToDefaults()
        super.tearDown()
    }

    func testDashboardRendersLoadingEmptyAndPopulatedStates() {
        let loadingManager = DetectionResultFixtures.emptyManager(isLoading: true)
        ViewRenderingTestHarness.render(
            NavigationStack {
                ResultsDashboardView(path: Binding<[DetectionCategory]>.constant([]))
                    .environmentObject(loadingManager)
            }
        )

        let emptyManager = DetectionResultFixtures.emptyManager()
        ViewRenderingTestHarness.render(
            NavigationStack {
                ResultsDashboardView(path: Binding<[DetectionCategory]>.constant([]))
                    .environmentObject(emptyManager)
            }
        )

        let populatedManager = DetectionResultFixtures.populatedManager()
        ViewRenderingTestHarness.render(
            NavigationStack {
                ResultsDashboardView(path: Binding<[DetectionCategory]>.constant([]))
                    .environmentObject(populatedManager)
            }
        )

        XCTAssertEqual(populatedManager.totalResultsCount, 5)
        XCTAssertTrue(populatedManager.hasAnyResults)
    }

    func testCategoryResultViewsRenderEmptyAndPopulatedBranches() {
        for category in DetectionCategory.allCases {
            let emptyManager = DetectionResultFixtures.emptyManager()
            ViewRenderingTestHarness.render(
                NavigationStack {
                    CategoryResultsView(category: category)
                        .environmentObject(emptyManager)
                }
            )

            let populatedManager = DetectionResultFixtures.populatedManager()
            ViewRenderingTestHarness.render(
                NavigationStack {
                    CategoryResultsView(category: category)
                        .environmentObject(populatedManager)
                }
            )
        }
    }

    func testSharedResultComponentsRenderAcrossCategories() {
        let emptyManager = DetectionResultFixtures.emptyManager()
        let populatedManager = DetectionResultFixtures.populatedManager()

        ViewRenderingTestHarness.render(
            VStack {
                EmptyResultsView(category: .ocr, message: "No OCR results yet", description: "Perform text recognition on images to see results here")
                StatRow(label: "Total Results", value: "5")
                ResultsSummaryCard(category: .classification, count: 2) {}
                StorageInfoRow(label: "OCR Results", count: 1, maxCount: 10, color: .purple)
                RecentResultsPreview(resultsManager: emptyManager, category: .ocr)
                ForEach(DetectionCategory.allCases, id: \.rawValue) { category in
                    RecentResultsPreview(resultsManager: populatedManager, category: category)
                }
            }
        )

        XCTAssertEqual(populatedManager.getResultsCount(for: .barcode), 1)
    }

    func testRecentRowsRenderEachStoredResultType() {
        let barcodeResult = DetectionResultFixtures.barcodeResult(payloads: [("hello world", "QR")])

        ViewRenderingTestHarness.render(
            VStack {
                RecentOCRRow(result: DetectionResultFixtures.ocrResult())
                RecentObjectDetectionRow(result: DetectionResultFixtures.objectResult())
                RecentClassificationRow(result: DetectionResultFixtures.classificationResult())
                RecentContourRow(result: DetectionResultFixtures.contourResult())
                RecentBarcodeRow(result: barcodeResult)
            }
        )

        XCTAssertEqual(barcodeResult.totalBarcodeCount, 1)
    }

    func testRowsAndDetailViewsRenderStoredResults() throws {
        let ocrResult = DetectionResultFixtures.ocrResult()
        let objectResult = DetectionResultFixtures.objectResult()
        let classificationResult = DetectionResultFixtures.classificationResult()
        let barcodeResult = DetectionResultFixtures.barcodeResult(payloads: [("https://example.com/docs", "QR"), ("9781234567890", "EAN13")])
        let firstBarcode = try XCTUnwrap(barcodeResult.detectedBarcodes.first)
        let barcodeManager = BarcodeDetectionManager()

        ViewRenderingTestHarness.render(
            ScrollView {
                VStack {
                    OCRResultRow(result: ocrResult) {}
                    OCRResultDetailView(result: ocrResult, selectedDetent: .constant(.medium), onReset: {})
                    ForEach(ocrResult.detectedTexts) { text in
                        DetectedTextRow(detectedText: text)
                    }

                    ObjectDetectionResultRow(result: objectResult) {}
                    ObjectDetectionResultDetailView(result: objectResult, selectedDetent: .constant(.fraction(0.9)), onReset: {})
                    ForEach(objectResult.detectedObjects) { object in
                        DetectedObjectRow(detectedObject: object)
                    }

                    ClassificationResultRow(result: classificationResult) {}
                    ClassificationResultDetailView(result: classificationResult, selectedDetent: .constant(.medium), onReset: {})
                    ForEach(Array(classificationResult.classificationResults.enumerated()), id: \.element.id) { index, classification in
                        ClassificationRow(classification: classification, rank: index + 1, isTopResult: index == 0)
                    }
                    ConfidenceChartView(results: classificationResult.classificationResults)
                        .frame(height: 120)

                    BarcodeResultRow(result: barcodeResult, barcodeManager: barcodeManager) {}
                    BarcodeResultDetailView(result: barcodeResult, barcodeManager: barcodeManager)
                    BarcodeDetailCard(barcode: firstBarcode, index: 1, barcodeManager: barcodeManager)
                }
            }
        )

        XCTAssertEqual(objectResult.totalObjectCount, 2)
        XCTAssertEqual(classificationResult.classificationResults.count, 3)
        XCTAssertEqual(barcodeResult.totalBarcodeCount, 2)
    }
}
```

- [ ] **Step 2: Run the new result-view tests**

Run:

```bash
xcodebuild \
  -project apus.xcodeproj \
  -scheme apus-ci \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:apusTests/ResultsViewCoverageTests \
  -derivedDataPath build/DerivedData \
  test
```

Expected: PASS.

- [ ] **Step 3: Commit**

```bash
git add apusTests/Results/ResultsViewCoverageTests.swift apus.xcodeproj/project.pbxproj
git commit -m "test: cover result view rendering"
```

## Task 4: Cover Timeline, Settings, Preview, And Overlay Views

**Files:**
- Create: `apusTests/Features/Timeline/TimelineViewCoverageTests.swift`
- Create: `apusTests/ViewCoverage/SettingsAndPreviewViewCoverageTests.swift`

- [ ] **Step 1: Add timeline rendering tests**

Create `apusTests/Features/Timeline/TimelineViewCoverageTests.swift`:

```swift
//
//  TimelineViewCoverageTests.swift
//  apusTests
//
//  Created by Codex on 2026/05/24.
//

import SwiftUI
import XCTest
@testable import apus

@MainActor
final class TimelineViewCoverageTests: XCTestCase {
    override func setUp() {
        super.setUp()
        AppDependencies.shared.configureForTesting()
    }

    func testTimelineShellAndFilterViewsRender() {
        let manager = DetectionResultFixtures.populatedManager()
        let viewModel = TimelineViewModel(resultsManager: manager)
        viewModel.searchQuery = "document"
        viewModel.updateSections()

        ViewRenderingTestHarness.render(
            NavigationStack {
                VStack {
                    TimelineView()
                    TimelineFilterBar(viewModel: viewModel)
                    TimelineSearchBar(searchQuery: .constant("receipt"))
                    TimelineCategoryFilters(viewModel: viewModel)
                    TimelineDatePresets(selectedPreset: .constant(.last7Days))
                }
            }
        )

        XCTAssertEqual(viewModel.countForCategory(.ocr), 1)
    }

    func testTimelineRowsEmptyStatesAndChipsRender() {
        let result = TimelineResult.ocr(DetectionResultFixtures.ocrResult())

        ViewRenderingTestHarness.render(
            ScrollView {
                VStack {
                    TimelineRowView(result: result)
                    TimelineSectionHeader(title: "Today")
                    EmptyTimelineView(hasFilters: false) {}
                    EmptyTimelineView(hasFilters: true) {}
                    CategoryFilterChip(category: .barcode, isSelected: true, count: 2) {}
                    CategoryFilterChip(category: .barcode, isSelected: false, count: 0) {}
                    DatePresetChip(preset: .today, isSelected: true) {}
                    DatePresetChip(preset: .last30Days, isSelected: false) {}
                }
            }
        )

        XCTAssertEqual(result.category, .ocr)
    }

    func testTimelineDetailSheetsRenderEveryResultKind() {
        let results: [TimelineResult] = [
            .ocr(DetectionResultFixtures.ocrResult()),
            .objectDetection(DetectionResultFixtures.objectResult()),
            .classification(DetectionResultFixtures.classificationResult()),
            .contour(DetectionResultFixtures.contourResult()),
            .barcode(DetectionResultFixtures.barcodeResult(payloads: [("sms:+15551234567:hello", "QR")]))
        ]

        ViewRenderingTestHarness.render(
            TabView {
                ForEach(Array(results.enumerated()), id: \.offset) { _, result in
                    TimelineDetailSheet(result: result)
                }
            }
        )

        XCTAssertEqual(results.map(\.category), DetectionCategory.allCases)
    }
}
```

- [ ] **Step 2: Add settings, preview, and overlay rendering tests**

Create `apusTests/ViewCoverage/SettingsAndPreviewViewCoverageTests.swift`:

```swift
//
//  SettingsAndPreviewViewCoverageTests.swift
//  apusTests
//
//  Created by Codex on 2026/05/24.
//

import SwiftUI
import Vision
import XCTest
@testable import apus

@MainActor
final class SettingsAndPreviewViewCoverageTests: XCTestCase {
    override func setUp() {
        super.setUp()
        AppDependencies.shared.configureForTesting()
        AppSettings.shared.resetToDefaults()
    }

    override func tearDown() {
        AppSettings.shared.resetToDefaults()
        super.tearDown()
    }

    func testSettingsAndStorageLimitViewsRender() {
        let viewModel = SettingsViewModel()
        viewModel.objectDetectionFramework = .coreML
        viewModel.setStorageLimit(for: .ocr, limit: 1)
        viewModel.setStorageLimit(for: .barcode, limit: 100)

        ViewRenderingTestHarness.render(
            NavigationStack {
                VStack {
                    SettingsView()
                    StorageLimitsSettingsView()
                    ForEach(DetectionCategory.allCases, id: \.rawValue) { category in
                        StorageLimitRowView(category: category, viewModel: viewModel)
                    }
                }
            }
        )

        XCTAssertEqual(viewModel.getStorageLimit(for: .ocr), 1)
        XCTAssertEqual(viewModel.getStorageLimit(for: .barcode), 100)
    }

    func testPreviewViewRendersWithAndWithoutImage() {
        var missingImage: UIImage?
        var capturedImage: UIImage? = DetectionResultFixtures.image()

        ViewRenderingTestHarness.render(
            NavigationStack {
                VStack {
                    PreviewView(capturedImage: Binding(get: { missingImage }, set: { missingImage = $0 }))
                    PreviewView(capturedImage: Binding(get: { capturedImage }, set: { capturedImage = $0 }))
                }
            }
        )

        XCTAssertNotNil(capturedImage)
    }

    func testOverlayViewsRenderWithDetections() {
        let detections = DetectionResultFixtures.detectedObjects()
        let texts = DetectionResultFixtures.detectedTexts()
        let contours = DetectionResultFixtures.contours()
        let barcode = VNBarcodeObservation()

        ViewRenderingTestHarness.render(
            ZStack {
                ObjectDetectionOverlay(
                    detections: [
                        Detection(boundingBox: CGRect(x: 0.2, y: 0.2, width: 0.3, height: 0.3), className: "book", confidence: 0.9)
                    ]
                )
                UnifiedObjectDetectionOverlay(detections: detections, imageSize: CGSize(width: 400, height: 300), displaySize: CGSize(width: 300, height: 220))
                VisionTextRecognitionOverlay(detectedTexts: texts, imageSize: CGSize(width: 400, height: 300), displaySize: CGSize(width: 300, height: 220))
                ContourOverlayView(contours: contours, imageSize: CGSize(width: 400, height: 300), displaySize: CGSize(width: 300, height: 220))
                BarcodeOverlayView(barcodes: [barcode], imageSize: CGSize(width: 400, height: 300), displaySize: CGSize(width: 300, height: 220))
                BarcodeDetectionOverlay(barcodes: [barcode])
            }
            .frame(width: 300, height: 220)
        )

        XCTAssertEqual(detections.count, 2)
        XCTAssertEqual(texts.count, 2)
        XCTAssertEqual(contours.count, 1)
    }
}
```

- [ ] **Step 3: Run the new view-coverage tests**

Run:

```bash
xcodebuild \
  -project apus.xcodeproj \
  -scheme apus-ci \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:apusTests/TimelineViewCoverageTests \
  -only-testing:apusTests/SettingsAndPreviewViewCoverageTests \
  -derivedDataPath build/DerivedData \
  test
```

Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add apusTests/Features/Timeline/TimelineViewCoverageTests.swift apusTests/ViewCoverage/SettingsAndPreviewViewCoverageTests.swift apus.xcodeproj/project.pbxproj
git commit -m "test: cover timeline settings and overlay views"
```

## Task 5: Verify App Target Coverage And Patch Remaining Gaps

**Files:**
- Modify only if required by the coverage report:
  - `apusTests/Results/ResultsViewCoverageTests.swift`
  - `apusTests/Features/Timeline/TimelineViewCoverageTests.swift`
  - `apusTests/ViewCoverage/SettingsAndPreviewViewCoverageTests.swift`

- [ ] **Step 1: Run full unit coverage**

Run:

```bash
xcodebuild \
  -project apus.xcodeproj \
  -scheme apus-ci \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -enableCodeCoverage YES \
  -only-testing:apusTests \
  -skip-testing:apusUITests \
  -resultBundlePath build/TestResults/LocalCoverage.xcresult \
  -derivedDataPath build/DerivedData \
  test
```

Expected: all unit tests pass.

- [ ] **Step 2: Inspect app-target coverage**

Run with XcodeBuildMCP coverage report, or with shell:

```bash
xcrun xccov view --report build/TestResults/LocalCoverage.xcresult
```

Expected: the `apus.app` row is at least `50.00%`.

- [ ] **Step 3: If `apus.app` is below 50%, add these exact fallback renders**

Append this test to `apusTests/Results/ResultsViewCoverageTests.swift`:

```swift
func testImageAndDashboardUtilityViewsRenderFallbackBranches() {
    let populatedManager = DetectionResultFixtures.populatedManager()

    ViewRenderingTestHarness.render(
        ScrollView {
            VStack {
                ImageDetailView(image: DetectionResultFixtures.image())
                ResultsDashboardView(path: Binding<[DetectionCategory]>.constant([.ocr]))
                    .environmentObject(populatedManager)
                CategoryResultsView(category: .ocr)
                    .environmentObject(populatedManager)
                CategoryResultsView(category: .objectDetection)
                    .environmentObject(populatedManager)
                CategoryResultsView(category: .classification)
                    .environmentObject(populatedManager)
                CategoryResultsView(category: .contourDetection)
                    .environmentObject(populatedManager)
                CategoryResultsView(category: .barcode)
                    .environmentObject(populatedManager)
            }
        }
    )

    XCTAssertEqual(populatedManager.totalResultsCount, 5)
}
```

Append this test to `apusTests/ViewCoverage/SettingsAndPreviewViewCoverageTests.swift`:

```swift
func testOverlayViewsRenderEmptyBranches() {
    ViewRenderingTestHarness.render(
        ZStack {
            ObjectDetectionOverlay(detections: [])
            UnifiedObjectDetectionOverlay(detections: [], imageSize: CGSize(width: 400, height: 300), displaySize: CGSize(width: 300, height: 220))
            VisionTextRecognitionOverlay(detectedTexts: [], imageSize: CGSize(width: 400, height: 300), displaySize: CGSize(width: 300, height: 220))
            ContourOverlayView(contours: [], imageSize: CGSize(width: 400, height: 300), displaySize: CGSize(width: 300, height: 220))
            BarcodeOverlayView(barcodes: [], imageSize: CGSize(width: 400, height: 300), displaySize: CGSize(width: 300, height: 220))
            BarcodeDetectionOverlay(barcodes: [])
        }
        .frame(width: 300, height: 220)
    )

    XCTAssertTrue(true)
}
```

Run:

```bash
xcodebuild \
  -project apus.xcodeproj \
  -scheme apus-ci \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:apusTests/ResultsViewCoverageTests/testImageAndDashboardUtilityViewsRenderFallbackBranches \
  -only-testing:apusTests/SettingsAndPreviewViewCoverageTests/testOverlayViewsRenderEmptyBranches \
  -derivedDataPath build/DerivedData \
  test
```

Expected: PASS.

- [ ] **Step 4: Rerun full coverage**

Run the full coverage command from Step 1 again.

Expected: all unit tests pass and `apus.app` is at least `50.00%`.

- [ ] **Step 5: Commit final coverage tests**

```bash
git add apusTests/Results/ResultsViewCoverageTests.swift apusTests/Features/Timeline/TimelineViewCoverageTests.swift apusTests/ViewCoverage/SettingsAndPreviewViewCoverageTests.swift apus.xcodeproj/project.pbxproj
git commit -m "test: raise app target coverage"
```

## Task 6: Final Verification And Reporting

**Files:**
- Read-only verification, unless formatting changes are needed.

- [ ] **Step 1: Run SwiftLint**

Run: `swiftlint --strict --no-cache`

Expected: `Done linting! Found 0 violations`.

- [ ] **Step 2: Run final full unit coverage**

Run:

```bash
xcodebuild \
  -project apus.xcodeproj \
  -scheme apus-ci \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -enableCodeCoverage YES \
  -only-testing:apusTests \
  -skip-testing:apusUITests \
  -resultBundlePath build/TestResults/LocalCoverage.xcresult \
  -derivedDataPath build/DerivedData \
  test
```

Expected: all unit tests pass.

- [ ] **Step 3: Capture final target coverage**

Run:

```bash
xcrun xccov view --report build/TestResults/LocalCoverage.xcresult
```

Expected: `apus.app` is at least `50.00%`. Also note that aggregate coverage may still differ from target coverage because Xcode reports every target in the bundle.

- [ ] **Step 4: Check git status**

Run: `git status --short`

Expected: no unstaged implementation changes except pre-existing untracked `.codex/` if it remains.
