# APUS Feature Roadmap - Product Requirements Document

**Document Version:** 1.0
**Last Updated:** January 4, 2026
**Author:** Product Management & Technical Architecture Team
**Status:** Draft for Engineering Review

---

## Executive Summary

### Overview

This PRD outlines a strategic feature roadmap for APUS, an iOS 18.5+ machine learning application focused on real-time computer vision capabilities. The proposed features aim to enhance user productivity, expand ML detection capabilities, improve data management, and increase platform integration.

### Strategic Rationale

APUS currently provides robust computer vision capabilities (object detection, OCR, classification, contour detection, barcode scanning) but lacks critical productivity features such as data export, advanced result management, and iOS platform integration. This gap limits adoption by professional users, restricts workflow integration, and reduces overall utility of captured detection data.

### Key Business Objectives

1. **Increase User Retention:** Advanced result management and export capabilities encourage repeated app usage
2. **Expand Market Reach:** Professional features (document scanning, batch processing) attract business users
3. **Enhance Platform Value:** Widgets and Shortcuts integration increase app visibility and daily engagement
4. **Competitive Differentiation:** Face detection, pose estimation, and custom model import position APUS as a comprehensive ML toolkit

### Success Metrics (6-Month Horizon)

- **User Engagement:** 40% increase in daily active users
- **Session Duration:** 30% increase in average session time
- **Feature Adoption:** 60% of users utilize at least one new feature
- **Export Actions:** 50% of users export results at least once per week
- **Widget Engagement:** 25% of users add at least one APUS widget
- **App Store Rating:** Maintain 4.5+ stars with 50% increase in reviews

---

## Purpose and Problem Statement

### Business Context

The mobile ML/CV application market is rapidly evolving, with increasing user expectations for:
- **Workflow Integration:** Seamless data export to productivity apps (Notes, Files, third-party tools)
- **Advanced Analytics:** Historical trends, pattern recognition, search capabilities
- **Platform Integration:** iOS Widgets, Shortcuts, system-level features
- **Specialized Use Cases:** Document digitization, accessibility features, professional analysis

**Market Opportunity:** Professional and prosumer users represent untapped segments willing to pay for advanced features or premium subscriptions.

**Competitive Landscape:** Competitors (Google Lens, Microsoft Office Lens, specialized ML apps) offer export, document scanning, and cloud sync. APUS must match baseline expectations while differentiating through breadth of ML capabilities.

### User Pain Points

Based on architecture analysis and industry research, current APUS users face:

1. **Data Lock-In (Critical):** No ability to export detection results (OCR text, detected objects, classifications) for use in other apps or workflows
2. **Limited Historical Context:** Cannot search, filter, or analyze past detections; results are isolated snapshots
3. **Workflow Fragmentation:** Switching between APUS and other apps for document scanning, face recognition, or batch processing
4. **Discoverability Barriers:** No home screen widgets or Siri integration for quick access
5. **Confidence Ambiguity:** Fixed confidence thresholds may produce noisy results or miss valid detections
6. **Missing Specialized Features:** No document-specific optimization, human pose analysis, or custom model support

### Current State vs. Desired State

| **Aspect** | **Current State** | **Desired State** |
|------------|-------------------|-------------------|
| **Export** | No export capability | Multi-format export (JSON, CSV, PDF, plain text, images) |
| **Result Management** | Basic list view per category | Timeline view with search, filtering, tagging, comparison |
| **Specialized Detection** | General object detection only | Face detection, pose estimation, document scanning |
| **Platform Integration** | Standalone app | Widgets, Shortcuts, Share Extension |
| **Model Management** | Fixed Vision/Core ML models | Custom model import (.mlpackage, .mlmodel) |
| **Batch Operations** | Single image processing | Batch import, process, export workflows |
| **User Control** | Fixed confidence thresholds | Per-category adjustable thresholds |
| **Performance Insights** | None | Framework benchmarking, latency tracking |

### Strategic Goals

1. **Productivity Enablement:** Enable users to act on detection results beyond app boundaries
2. **Data Intelligence:** Transform isolated results into searchable, actionable historical knowledge
3. **Professional Workflows:** Support document digitization, accessibility, and specialized analysis
4. **iOS Ecosystem Integration:** Become a native part of users' iOS workflows
5. **Extensibility:** Allow advanced users to bring custom models and customize detection parameters

### Success Criteria

**Phase 1 (MVP - 3 months):**
- Export functionality available for all detection types
- Basic timeline view with search/filtering
- Document scanner mode operational
- At least one widget variant published

**Phase 2 (Enhancement - 6 months):**
- Face detection integrated with photo library
- Batch processing supporting 10+ images
- Shortcuts with 5+ actions
- Custom model import (beta)

**Phase 3 (Optimization - 9 months):**
- Side-by-side comparison mode
- Pose estimation for accessibility use cases
- Performance benchmarking dashboard
- Advanced export templates

---

## User Personas and Stories

### Target Personas

#### Persona 1: Professional Archivist (Emma, 34)

**Demographics:**
- Occupation: Museum archivist and researcher
- Technical Proficiency: Intermediate (comfortable with iOS apps, not a developer)
- Device: iPhone 16 Pro, iPad Pro with Apple Pencil

**Behavioral Patterns:**
- Digitizes historical documents, labels, and artifacts
- Needs OCR for handwritten text and metadata extraction
- Exports data to spreadsheets and archival databases
- Works in batch mode (20-50 images per session)

**Motivations:**
- Accuracy and detail preservation
- Efficient workflow integration
- Export to academic/research formats
- Historical context tracking (date, location, classification)

**Current Workarounds:**
- Uses multiple apps (Office Lens for documents, separate OCR tools, manual data entry)
- Takes photos with Camera app, processes later on desktop
- Manually re-types OCR results into spreadsheets

**Pain Points:**
- App-switching overhead reduces productivity
- No batch export capability
- Cannot search historical scans
- Lacks document-specific optimizations (edge detection, perspective correction)

---

#### Persona 2: Accessibility Advocate (Marcus, 28)

**Demographics:**
- Occupation: Accessibility consultant and advocate
- Technical Proficiency: Advanced (uses Shortcuts, assistive technologies)
- Device: iPhone 16 with VoiceOver, Apple Watch

**Behavioral Patterns:**
- Tests app accessibility features
- Uses ML for object recognition to assist visually impaired clients
- Integrates detection with Siri and Shortcuts
- Needs quick access via widgets and voice commands

**Motivations:**
- Rapid object/text identification for assistive use
- Voice-driven workflows
- Real-time feedback (haptics, audio)
- Confidence in detection accuracy

**Current Workarounds:**
- Uses Seeing AI (Microsoft) for basic object detection
- Voice Control with Camera app
- Manual result reading via VoiceOver

**Pain Points:**
- No Siri Shortcuts integration
- Limited haptic feedback customization
- Cannot adjust confidence thresholds for clearer results
- No widgets for home screen quick access

---

#### Persona 3: Computer Vision Researcher (Priya, 41)

**Demographics:**
- Occupation: ML researcher and university professor
- Technical Proficiency: Expert (familiar with Core ML, Python, PyTorch)
- Device: iPhone 16 Pro Max, MacBook Pro M4

**Behavioral Patterns:**
- Benchmarks different ML models and frameworks
- Tests custom Core ML models on device
- Compares detection accuracy across frameworks
- Analyzes performance metrics (latency, memory, accuracy)

**Motivations:**
- Custom model deployment and testing
- Framework performance comparison
- Detailed result export for analysis
- Side-by-side detection comparison

**Current Workarounds:**
- Uses Xcode for custom model testing
- Exports results via screenshot and manual logging
- Uses third-party benchmarking tools

**Pain Points:**
- Cannot import custom .mlpackage models
- No performance metrics or benchmarking
- Cannot compare Vision vs Core ML side-by-side
- Limited export formats (no JSON schema)

---

#### Persona 4: Small Business Owner (David, 52)

**Demographics:**
- Occupation: Retail store owner and inventory manager
- Technical Proficiency: Basic (uses iPhone for business tasks)
- Device: iPhone 15, iPad for POS

**Behavioral Patterns:**
- Scans product barcodes and labels
- Captures invoices and receipts for accounting
- Needs quick document digitization
- Occasional object classification for inventory

**Motivations:**
- Fast, reliable barcode/QR scanning
- Document scanning with OCR
- Easy export to accounting software (CSV, PDF)
- Minimal technical overhead

**Current Workarounds:**
- Uses built-in Camera app + manual typing
- Separate receipt scanner app
- Takes photos, emails to accountant

**Pain Points:**
- No document scanner mode with auto-capture
- Cannot export to CSV for inventory systems
- No batch processing for invoices
- No quick widget access for scanning

---

### User Stories (Prioritized by MoSCoW)

#### Must Have (MVP - Core Value)

**US-1: Export Detection Results**
- **As Emma (Archivist), I want to export OCR results as CSV/JSON/TXT so that I can import data into archival databases**
  - **Acceptance Criteria:**
    - Export button available on all result detail views
    - Supports formats: JSON, CSV, TXT, PDF
    - Includes metadata (timestamp, confidence, category)
    - Share via iOS Share Sheet to Files, Mail, etc.
  - **Dependencies:** None
  - **Technical Constraints:** Must preserve Unicode characters for OCR text

**US-2: Search and Filter Results**
- **As all users, I want to search detection history by text/date/category so that I can quickly find past results**
  - **Acceptance Criteria:**
    - Search bar on ResultsDashboardView
    - Filter by category (OCR, Object Detection, etc.)
    - Date range filtering (today, last 7 days, last 30 days, custom)
    - Text search matches OCR text, object class names, barcode payloads
  - **Dependencies:** Existing DetectionResultsManager
  - **Technical Constraints:** Must maintain performance with 100+ stored results

**US-3: Document Scanner Mode**
- **As Emma and David, I want a document scanner mode with auto-capture and edge detection so that I can digitize documents efficiently**
  - **Acceptance Criteria:**
    - New "Document" mode toggle in CameraView
    - Rectangle detection using Vision VNDetectRectanglesRequest
    - Auto-capture when document detected and stabilized
    - Perspective correction applied
    - OCR automatically triggered on captured document
  - **Dependencies:** VisionTextRecognitionProtocol
  - **Technical Constraints:** Must handle varying lighting and paper types

**US-4: Basic Timeline View**
- **As all users, I want a chronological timeline of all detections so that I can see historical context**
  - **Acceptance Criteria:**
    - New "Timeline" tab in Results
    - Grouped by date (Today, Yesterday, Last 7 Days, etc.)
    - Thumbnail preview for each result
    - Tap to view detail
    - Category badges visible
  - **Dependencies:** DetectionResultsManager
  - **Technical Constraints:** Thumbnail generation must be performant

---

#### Should Have (High Value, Non-Critical)

**US-5: Face Detection and Analysis**
- **As professional users, I want face detection with landmark analysis so that I can identify people in images**
  - **Acceptance Criteria:**
    - New DetectionCategory: .faceDetection
    - Bounding boxes for detected faces
    - Landmark points (eyes, nose, mouth) using Vision VNDetectFaceLandmarksRequest
    - Face quality metrics (blur, occlusion, brightness)
    - Privacy-focused: no face recognition/identification, only detection
    - Results stored similarly to other categories
  - **Dependencies:** New protocol: FaceDetectionProtocol
  - **Technical Constraints:** Privacy compliance (no biometric data storage)

**US-6: Batch Processing**
- **As Emma, I want to import and process multiple images at once so that I can handle large digitization tasks**
  - **Acceptance Criteria:**
    - "Import Batch" button on CameraView or Results
    - Photo library multi-select (10-50 images)
    - Queue-based processing with progress indicator
    - Same detection categories as single-image mode
    - Bulk export after processing
  - **Dependencies:** PhotoLibraryServiceProtocol
  - **Technical Constraints:** Memory management for large batches

**US-7: Home Screen Widget**
- **As Marcus, I want a home screen widget for quick detection so that I can access features without opening the app**
  - **Acceptance Criteria:**
    - Small widget: Latest result preview with category badge
    - Medium widget: Last 3 results with thumbnails
    - Large widget: Summary stats (total results, top categories)
    - Tap widget to open app to relevant result/category
    - Refresh on app state changes
  - **Dependencies:** WidgetKit framework
  - **Technical Constraints:** Widget timeline updates limited by iOS

**US-8: Siri Shortcuts Integration**
- **As Marcus, I want Siri Shortcuts for common actions so that I can use voice commands**
  - **Acceptance Criteria:**
    - Shortcuts: "Scan Barcode", "Detect Objects", "Read Text", "Scan Document"
    - Result returned to Shortcuts app for chaining
    - Support for parameters (e.g., "Detect Objects with confidence > 0.8")
    - Donations for common actions
  - **Dependencies:** Intents framework
  - **Technical Constraints:** Background execution limits

**US-9: Confidence Threshold Sliders**
- **As Marcus and Priya, I want adjustable confidence thresholds per category so that I can control detection sensitivity**
  - **Acceptance Criteria:**
    - Per-category threshold settings in SettingsView
    - Default: 0.5 (50%)
    - Range: 0.1 to 0.95
    - Live preview of threshold effect
    - Stored in AppSettings
  - **Dependencies:** All detection protocols must respect threshold
  - **Technical Constraints:** Must filter results post-detection

---

#### Could Have (Nice-to-Have, Future Iterations)

**US-10: Side-by-Side Comparison Mode**
- **As Priya, I want to compare detections side-by-side so that I can evaluate framework accuracy**
  - **Acceptance Criteria:**
    - "Compare" mode in Results
    - Select 2 results to compare
    - Split-screen view with overlaid detections
    - Difference metrics (bounding box IoU, confidence delta)
  - **Dependencies:** Result detail views
  - **Technical Constraints:** Must handle different image sizes

**US-11: Pose Estimation**
- **As Marcus, I want human pose detection for accessibility and fitness use cases**
  - **Acceptance Criteria:**
    - New DetectionCategory: .poseEstimation
    - Joint keypoints (17 major body joints)
    - Skeleton visualization overlay
    - Supports multiple people
    - Confidence per joint
  - **Dependencies:** Vision VNDetectHumanBodyPoseRequest
  - **Technical Constraints:** Requires iOS 14+ API

**US-12: Custom Model Import**
- **As Priya, I want to import custom Core ML models so that I can test my own detectors**
  - **Acceptance Criteria:**
    - "Import Model" in Settings (Core ML section)
    - Supports .mlpackage and .mlmodel formats
    - Validates model input/output schema
    - User-defined model name and category
    - Stored in app Documents directory
  - **Dependencies:** UnifiedObjectDetectionProtocol extension
  - **Technical Constraints:** Schema validation, sandboxing

**US-13: Performance Benchmarking**
- **As Priya, I want performance metrics for each detection so that I can optimize model selection**
  - **Acceptance Criteria:**
    - New "Performance" section in Settings
    - Metrics: inference time (ms), memory usage, FPS (real-time)
    - Per-framework comparison chart
    - Export benchmarks as CSV
  - **Dependencies:** Instrumentation in all detection managers
  - **Technical Constraints:** Low overhead measurement

**US-14: Enhanced Haptic Feedback**
- **As Marcus, I want customizable haptic patterns for different detection events**
  - **Acceptance Criteria:**
    - Settings toggle: haptic on/off per category
    - Pattern intensity control (light, medium, strong)
    - Different patterns: detection start, success, failure
    - Accessibility-focused (comply with VoiceOver)
  - **Dependencies:** HapticServiceProtocol
  - **Technical Constraints:** Battery impact consideration

**US-15: Result Tagging and Notes**
- **As Emma, I want to add tags and notes to results so that I can organize and annotate findings**
  - **Acceptance Criteria:**
    - "Add Note" button on result detail
    - Tag creation with autocomplete
    - Filter by tags in timeline/search
    - Export includes tags/notes
  - **Dependencies:** Stored result model extensions
  - **Technical Constraints:** Data migration for existing results

---

#### Won't Have (Out of Scope)

- **Cloud Sync/Backup:** Requires backend infrastructure; not aligned with privacy-first design
- **Social Sharing:** Niche use case; Share Sheet covers basic needs
- **Augmented Reality Overlays:** Out of core CV scope; complex implementation
- **Video Detection:** Resource-intensive; focus on image-based detections
- **Machine Translation:** Not a core ML/CV feature; better served by system APIs
- **User Accounts/Profiles:** Privacy risk; current singleton design sufficient

---

## User Journeys

### Journey 1: Emma Digitizes Historical Documents (Document Scanner Mode)

**Entry Point:** Home screen widget or app icon

**Steps:**
1. **Launch App:** Emma opens APUS from widget tap
2. **Switch Mode:** Taps "Document" mode toggle in CameraView toolbar
3. **Auto-Detection:** Holds phone over document; app detects rectangle edges in real-time (green overlay when stable)
4. **Auto-Capture:** After 1 second of stable detection, app auto-captures with haptic feedback
5. **Perspective Correction:** Image automatically warps to rectangular perspective
6. **OCR Processing:** Text recognition runs automatically; progress indicator shows
7. **Review Results:** PreviewView displays corrected image with OCR text overlay
8. **Batch Continue:** Emma taps "Capture Another" to continue batch; repeats steps 3-7
9. **Export All:** After 15 documents, taps "Export Batch" button
10. **Select Format:** Chooses CSV format for spreadsheet import
11. **Share:** Uses Share Sheet to save to Files app → iCloud Drive
12. **Exit:** Returns to camera for next batch

**Expected Outcome:** 15 documents digitized, OCR text exported to CSV in under 5 minutes

**Edge Cases:**
- **Poor Lighting:** App displays "Improve lighting" warning; Emma adjusts position
- **No Rectangle Detected:** Manual capture button available as fallback
- **Skewed Text:** Perspective correction handles up to 45-degree angles

---

### Journey 2: Marcus Uses Shortcuts for Quick Object Detection

**Entry Point:** Siri voice command on lock screen

**Steps:**
1. **Invoke Siri:** "Hey Siri, detect objects in front of me"
2. **Shortcut Executes:** APUS opens in background; camera permission confirmed (first time only)
3. **Auto-Capture:** Shortcut triggers photo capture after 2-second delay
4. **Detection Runs:** Object detection (current framework) processes image
5. **Results Read:** Siri reads top 3 detected objects with confidence ("Laptop 92%, Phone 87%, Cup 76%")
6. **Haptic Confirmation:** Success pattern vibrates on detection
7. **Save Option:** Siri asks "Save result?" → Marcus says "Yes"
8. **Result Stored:** Detection saved to APUS history with "Shortcut" tag
9. **Exit:** Returns to lock screen

**Expected Outcome:** Object identification within 5 seconds, hands-free workflow

**Edge Cases:**
- **Low Confidence:** If all detections below threshold, Siri says "No objects detected with high confidence"
- **Permission Denied:** Siri prompts to open app and grant camera access
- **Background Limits:** If app backgrounded too long, Siri says "Open APUS to complete"

---

### Journey 3: Priya Benchmarks Custom Model Performance

**Entry Point:** Settings > Core ML > Import Model

**Steps:**
1. **Navigate Settings:** Priya opens APUS → Settings tab → Core ML section
2. **Import Model:** Taps "Import Custom Model" → Files picker opens
3. **Select File:** Chooses custom YOLOv8n.mlpackage from Downloads
4. **Validation:** App validates model schema (input: image, output: bounding boxes + confidences)
5. **Name Model:** Enters "Custom YOLOv8n" as display name
6. **Model Listed:** New model appears in model picker alongside YOLOv12s
7. **Select Model:** Chooses "Custom YOLOv8n" as active model
8. **Enable Benchmarking:** Navigates to Settings > Performance > Enable Benchmarking
9. **Capture Test Image:** Takes photo of test scene (10 objects)
10. **View Metrics:** Taps result → "Performance" tab shows:
    - Inference Time: 45ms
    - Memory: 120MB
    - FPS: 22 (real-time)
11. **Switch Framework:** Changes to Vision framework, re-captures same scene
12. **Compare Results:** Opens "Compare" mode, selects both results side-by-side
13. **Analyze Difference:** Views bounding box IoU matrix, confidence deltas
14. **Export Benchmarks:** Taps "Export Benchmarks" → CSV with all metrics → Saves to Files

**Expected Outcome:** Complete framework comparison with quantitative metrics in under 10 minutes

**Edge Cases:**
- **Invalid Model Schema:** App shows error "Model input/output format not supported" with expected schema
- **Memory Limit:** If model exceeds 500MB, warning displayed
- **Benchmark Overhead:** Performance tab shows "Benchmarking adds ~5ms overhead" disclaimer

---

## Features and Requirements

### Phase 1: Foundation Features (MVP - 3 Months)

---

#### Feature 1: Export & Share Results

**Priority:** Must Have
**User Stories:** US-1
**Estimated Effort:** 2-3 weeks

**Functional Requirements:**

**FR-1.1: Export Formats**
- **Must:** Support JSON, CSV, plain text, and PDF export for all detection categories
- **Must:** JSON schema includes metadata (timestamp, category, framework, confidence stats)
- **Must:** CSV format is spreadsheet-compatible (Excel, Numbers, Google Sheets)
- **Must:** Plain text format is human-readable with clear section headers
- **Must:** PDF includes thumbnail image + formatted results
- **Should:** PDF supports multi-page layout for long results
- **Could:** Custom export templates (user-defined JSON schema)

**FR-1.2: Share Sheet Integration**
- **Must:** Use native iOS Share Sheet (UIActivityViewController)
- **Must:** Support sharing to Files, Mail, Messages, Notes, third-party apps
- **Must:** Preserve file format extension (.json, .csv, .txt, .pdf)
- **Must:** Include meaningful filename: "APUS_OCR_2026-01-04_143022.json"

**FR-1.3: Export UI/UX**
- **Must:** Export button on all result detail views (consistent location)
- **Must:** Format selection picker (segmented control or action sheet)
- **Must:** Preview export content before sharing
- **Should:** Bulk export from Results list view (select multiple)
- **Could:** Scheduled auto-export (daily digest)

**Acceptance Criteria:**
- [ ] All 5 detection categories support all 4 export formats
- [ ] JSON export validates against documented schema
- [ ] CSV export opens correctly in Excel/Numbers without encoding issues
- [ ] PDF export includes image + formatted text on single page (or multi-page if needed)
- [ ] Share Sheet presents at least 8 sharing options (Files, Mail, etc.)
- [ ] Export completes in <2 seconds for typical result (50 OCR words, 10 objects)
- [ ] Filenames include timestamp and category for easy organization

**Dependencies:**
- iOS Share Sheet API
- PDFKit or custom PDF generation
- Codable extensions for JSON schema

**Technical Considerations:**
- **Data Schema:** Define stable JSON schema with versioning for backward compatibility
- **Encoding:** UTF-8 for all text exports; handle emoji, special characters
- **PDF Generation:** Use PDFKit or UIGraphicsPDFRenderer for image + text layout
- **Performance:** Async export generation to avoid UI blocking
- **Testing:** Unit tests for each format; integration tests for Share Sheet

---

#### Feature 2: Detection History Timeline with Search

**Priority:** Must Have
**User Stories:** US-2, US-4
**Estimated Effort:** 2-3 weeks

**Functional Requirements:**

**FR-2.1: Timeline View**
- **Must:** Chronological list of all detections across categories
- **Must:** Grouped by date: Today, Yesterday, Last 7 Days, Earlier (with date headers)
- **Must:** Thumbnail preview (160x160) for each result
- **Must:** Category badge (icon + color) on each row
- **Must:** Confidence indicator (visual bar or percentage)
- **Should:** Swipe-to-delete with confirmation
- **Could:** Pinch-to-zoom on thumbnails

**FR-2.2: Search Functionality**
- **Must:** Search bar at top of timeline (sticky header)
- **Must:** Real-time filtering as user types
- **Must:** Search scope:
  - OCR: detected text content
  - Object Detection: class names (e.g., "person", "car")
  - Classification: identifiers
  - Barcode: payload strings
  - Contour: contour types
- **Should:** Search history suggestions (recent queries)
- **Could:** Advanced query syntax (e.g., "category:OCR confidence:>0.8")

**FR-2.3: Filtering**
- **Must:** Filter by category (multi-select: OCR, Objects, etc.)
- **Must:** Filter by date range (picker or presets)
- **Should:** Filter by confidence range (slider: 0.0-1.0)
- **Should:** Combine filters (e.g., OCR + Last 30 Days + >0.7 confidence)
- **Could:** Save filter presets

**FR-2.4: Sorting**
- **Must:** Sort by timestamp (newest/oldest first)
- **Should:** Sort by confidence (highest/lowest)
- **Could:** Sort by category

**Acceptance Criteria:**
- [ ] Timeline loads 100 results in <1 second on iPhone 15
- [ ] Search returns results in <300ms (indexed search if possible)
- [ ] Filtering updates UI in <500ms
- [ ] Date grouping headers are sticky (remain visible when scrolling)
- [ ] Thumbnail images load progressively without blocking scroll
- [ ] Empty states displayed when no results match filters
- [ ] VoiceOver reads category, date, and confidence for accessibility

**Dependencies:**
- DetectionResultsManager (extend with search/filter methods)
- SwiftUI List performance optimizations (LazyVStack)

**Technical Considerations:**
- **Search Index:** Consider in-memory search or Core Data full-text index for 1000+ results
- **Thumbnail Caching:** Leverage existing thumbnailData in StoredResults; lazy load on scroll
- **Performance:** Async filtering to avoid UI blocking; debounce search input
- **State Management:** Published filter state in ViewModel
- **Testing:** Search accuracy tests; performance tests with 500+ results

---

#### Feature 3: Document Scanner Mode

**Priority:** Must Have
**User Stories:** US-3
**Estimated Effort:** 3-4 weeks

**Functional Requirements:**

**FR-3.1: Rectangle Detection**
- **Must:** Detect document rectangles in real-time using Vision VNDetectRectanglesRequest
- **Must:** Visual overlay (green outline) when rectangle detected
- **Must:** Stability detection (rectangle must be stable for 1 second before auto-capture)
- **Should:** Handle multiple rectangles (choose largest)
- **Should:** Minimum size threshold (reject small rectangles)

**FR-3.2: Auto-Capture**
- **Must:** Auto-capture photo when stable rectangle detected
- **Must:** Haptic feedback on capture (success pattern)
- **Must:** Manual capture button available if auto-capture undesired
- **Should:** Flash screen white briefly to indicate capture
- **Could:** Countdown timer (3-2-1) before auto-capture

**FR-3.3: Perspective Correction**
- **Must:** Apply perspective transform to extract rectangular document
- **Must:** Use Vision VNImageRequestHandler for transform
- **Must:** Output corrected image with white background (if possible)
- **Should:** Contrast enhancement for low-light documents
- **Could:** Grayscale/black-and-white mode toggle

**FR-3.4: OCR Integration**
- **Must:** Automatically trigger OCR on corrected document
- **Must:** Display OCR results in PreviewView
- **Should:** Editable OCR text (allow corrections)
- **Could:** Language detection and localization

**FR-3.5: UI/UX**
- **Must:** "Document" mode toggle in CameraView toolbar (icon: doc.viewfinder)
- **Must:** Guide overlay: "Position document within frame"
- **Must:** Real-time feedback: "Hold steady" / "Ready to capture"
- **Should:** Settings for auto-capture delay (0.5s, 1s, 2s)
- **Could:** Document type presets (A4, Letter, Business Card)

**Acceptance Criteria:**
- [ ] Detects A4/Letter size documents at 30cm-100cm distance
- [ ] Auto-capture triggers reliably (>90% success rate in good lighting)
- [ ] Perspective correction handles up to 45-degree viewing angles
- [ ] Corrected image resolution is at least 1200x1600 pixels
- [ ] OCR accuracy on corrected documents is >95% (for printed text)
- [ ] Mode toggle switches instantly (<100ms)
- [ ] Manual capture fallback works if auto-capture disabled
- [ ] Accessibility: VoiceOver announces detection status

**Dependencies:**
- Vision framework (VNDetectRectanglesRequest, VNImageRequestHandler)
- VisionTextRecognitionProtocol (existing OCR)
- CameraManager (extend with document mode state)

**Technical Considerations:**
- **Threading:** Rectangle detection on background queue; UI updates on main
- **Stability Algorithm:** Track rectangle corners over time; trigger when variance below threshold
- **Perspective Transform:** Use CIFilter (CIPerspectiveCorrection) or Vision transform
- **Image Quality:** Balance resolution vs. processing time (target 2-3s total)
- **Testing:** Unit tests for rectangle stability; UI tests for auto-capture flow

---

#### Feature 4: Basic Widget (Small + Medium)

**Priority:** Should Have
**User Stories:** US-7
**Estimated Effort:** 2 weeks

**Functional Requirements:**

**FR-4.1: Small Widget (2x2)**
- **Must:** Display latest detection result
- **Must:** Show thumbnail image (cropped to square)
- **Must:** Category badge (icon only, small)
- **Must:** Relative timestamp ("2m ago", "1h ago")
- **Must:** Tap to open app to result detail

**FR-4.2: Medium Widget (4x2)**
- **Must:** Display last 3 results in horizontal scroll
- **Must:** Each result shows thumbnail + category + timestamp
- **Must:** Tap result to open app to that result
- **Should:** Background gradient matching category color

**FR-4.3: Widget Configuration**
- **Must:** No configuration required (auto-updates)
- **Should:** Widget family selection (user chooses small/medium/large)
- **Could:** Category filter configuration (e.g., "Show OCR results only")

**FR-4.4: Timeline Updates**
- **Must:** Widget updates when new result saved
- **Must:** Respect iOS widget update limits (timeline with 10 entries)
- **Should:** Update on app foreground/background transitions
- **Could:** Refresh every 15 minutes if app used recently

**Acceptance Criteria:**
- [ ] Widget displays on home screen after installation
- [ ] Tapping widget opens app to correct result/screen
- [ ] Widget updates within 5 seconds of new detection
- [ ] Placeholder state shown when no results exist
- [ ] Widget supports light/dark mode
- [ ] VoiceOver reads widget content
- [ ] Widget complies with iOS performance guidelines (no excessive reloads)

**Dependencies:**
- WidgetKit framework
- DetectionResultsManager (shared data via App Group)
- App Groups entitlement (com.apus.shared)

**Technical Considerations:**
- **Data Sharing:** Use App Group container to share results between app and widget
- **Timeline Provider:** Implement TimelineProvider with getSnapshot, getTimeline
- **Performance:** Minimize widget size (<1MB); cache thumbnails
- **Privacy:** No sensitive data in widget (e.g., full OCR text)
- **Testing:** Widget extension unit tests; UI tests for tap actions

---

### Phase 2: Enhancement Features (Months 4-6)

---

#### Feature 5: Face Detection and Analysis

**Priority:** Should Have
**User Stories:** US-5
**Estimated Effort:** 3-4 weeks

**Functional Requirements:**

**FR-5.1: Face Detection**
- **Must:** Detect faces using Vision VNDetectFaceRectanglesRequest
- **Must:** Bounding boxes drawn around detected faces
- **Must:** Support multiple faces in single image
- **Must:** Confidence score per face
- **Should:** Minimum face size threshold (reject tiny faces)

**FR-5.2: Face Landmarks**
- **Must:** Detect facial landmarks (eyes, nose, mouth, jawline) via VNDetectFaceLandmarksRequest
- **Must:** Visualize landmarks as overlay points
- **Should:** Landmark confidence scores
- **Could:** Face pose estimation (pitch, yaw, roll)

**FR-5.3: Face Quality Metrics**
- **Must:** Blur detection (using Vision VNDetectFaceCaptureQualityRequest)
- **Should:** Brightness/contrast analysis
- **Should:** Occlusion detection (e.g., sunglasses, mask)
- **Could:** Smile/expression detection

**FR-5.4: Privacy and Ethics**
- **Must:** No face recognition or identification (detection only)
- **Must:** No biometric data storage (only bounding boxes and landmarks)
- **Must:** Privacy disclosure in app settings
- **Should:** Option to blur faces in exported images
- **Won't Have:** Face matching across images (out of scope)

**FR-5.5: Storage and Results**
- **Must:** New DetectionCategory: .faceDetection
- **Must:** StoredFaceDetectionResult with face count, landmark data, quality metrics
- **Must:** Integration with DetectionResultsManager
- **Should:** Face count badge on result thumbnails

**FR-5.6: UI/UX**
- **Must:** "Face Detection" option in CameraView mode picker
- **Must:** Real-time face overlay in camera view (if enabled)
- **Must:** Result detail view shows face crops and landmark visualization
- **Should:** Toggle landmark overlay on/off

**Acceptance Criteria:**
- [ ] Detects faces with >90% accuracy (compare to iOS Photos app)
- [ ] Supports up to 10 faces per image
- [ ] Landmark detection accuracy >85% for frontal faces
- [ ] Quality metrics correlate with human perception (blur, brightness)
- [ ] Privacy policy updated and displayed in Settings
- [ ] No face recognition/matching functionality present (compliance check)
- [ ] Results stored and exportable like other categories

**Dependencies:**
- Vision framework (VNDetectFaceRectanglesRequest, VNDetectFaceLandmarksRequest, VNDetectFaceCaptureQualityRequest)
- New protocol: FaceDetectionProtocol
- DetectionResultsManager extension

**Technical Considerations:**
- **Privacy Compliance:** Ensure no PII stored; consult legal/privacy team
- **Performance:** Face detection on background thread; landmarks may be slower (2-3s)
- **Visualization:** Use CAShapeLayer or SwiftUI Path for landmark overlays
- **Testing:** Face detection accuracy tests with diverse datasets; privacy audit

---

#### Feature 6: Batch Processing

**Priority:** Should Have
**User Stories:** US-6
**Estimated Effort:** 3 weeks

**Functional Requirements:**

**FR-6.1: Batch Import**
- **Must:** Import multiple images from photo library (PHPickerViewController)
- **Must:** Support 10-50 images per batch
- **Must:** Preview selected images before processing
- **Should:** Drag-and-drop reordering in preview
- **Could:** Import from Files app (iCloud Drive, external storage)

**FR-6.2: Batch Processing**
- **Must:** Queue-based processing (FIFO)
- **Must:** Process one image at a time (avoid memory pressure)
- **Must:** Apply current detection mode to all images (OCR, Object Detection, etc.)
- **Must:** Progress indicator (X of Y processed)
- **Should:** Pause/resume batch processing
- **Should:** Background processing (continue if app backgrounded)
- **Could:** Priority queue (user can reorder)

**FR-6.3: Processing Options**
- **Must:** Select detection category (OCR, Object Detection, etc.)
- **Should:** Multi-category processing (run OCR + Object Detection on each)
- **Should:** Confidence threshold override for batch
- **Could:** Custom processing pipeline (e.g., Document Mode + OCR)

**FR-6.4: Results Management**
- **Must:** Save all results to DetectionResultsManager
- **Must:** Group batch results (batch ID or timestamp range)
- **Must:** Bulk export after batch completion
- **Should:** Review/edit results before saving
- **Could:** Batch tagging (apply tag to all results)

**FR-6.5: Error Handling**
- **Must:** Skip failed images (log error, continue batch)
- **Must:** Error report at end (list failed images with reasons)
- **Should:** Retry failed images option
- **Could:** Partial result saving (save successful detections even if some fail)

**FR-6.6: UI/UX**
- **Must:** "Import Batch" button on Results or Camera view
- **Must:** Batch progress sheet (modal) with list and progress bar
- **Must:** Cancel batch button
- **Should:** Notification when batch completes (if app backgrounded)
- **Could:** Batch processing history view

**Acceptance Criteria:**
- [ ] Successfully processes 50 images in <5 minutes (OCR mode, iPhone 15)
- [ ] Memory usage stays below 500MB during batch processing
- [ ] App remains responsive during processing (UI not blocked)
- [ ] Failed images reported clearly with actionable error messages
- [ ] Batch export includes all results in single file (JSON/CSV)
- [ ] Background processing continues for at least 30 seconds after backgrounding
- [ ] VoiceOver announces progress updates

**Dependencies:**
- PHPickerViewController (photo library)
- All detection protocols (must support batch calls or queue)
- DetectionResultsManager (batch save optimizations)

**Technical Considerations:**
- **Memory Management:** Release processed images immediately; use autoreleasepool
- **Threading:** Background queue for processing; main queue for UI updates
- **Cancellation:** Support Task cancellation for clean exit
- **Persistence:** Save results incrementally (every 5 images) to avoid data loss
- **Testing:** Stress tests with 100+ images; memory leak detection; UI tests for progress updates

---

#### Feature 7: Siri Shortcuts Integration

**Priority:** Should Have
**User Stories:** US-8
**Estimated Effort:** 2-3 weeks

**Functional Requirements:**

**FR-7.1: Shortcut Actions**
- **Must:** "Detect Objects" action (captures photo, runs object detection, returns text result)
- **Must:** "Read Text (OCR)" action (captures photo, runs OCR, returns text)
- **Must:** "Scan Barcode" action (captures photo, returns barcode payload)
- **Should:** "Classify Image" action (captures photo, returns top classification)
- **Should:** "Scan Document" action (captures document, runs OCR, returns text)
- **Could:** "Detect Faces" action (requires Face Detection feature)

**FR-7.2: Action Parameters**
- **Must:** Confidence threshold parameter (default 0.5, range 0.1-0.95)
- **Should:** Maximum results parameter (return top N results)
- **Should:** Save result toggle (save to APUS history or not)
- **Could:** Image source parameter (camera vs. photo library)

**FR-7.3: Action Outputs**
- **Must:** Return structured data (dictionary with keys: results, confidence, timestamp)
- **Must:** Return plain text summary for Siri readout
- **Should:** Return image with overlays (for Shortcuts chaining)
- **Could:** Return JSON schema for advanced Shortcuts users

**FR-7.4: Siri Integration**
- **Must:** Voice command support ("Hey Siri, detect objects")
- **Must:** Siri reads results aloud (e.g., "I found a laptop, phone, and cup")
- **Should:** Follow-up actions (e.g., "Save result" confirmation)
- **Could:** Suggested shortcuts on lock screen

**FR-7.5: Donations and Suggestions**
- **Must:** Donate actions when user performs detections in app
- **Should:** Suggest shortcuts based on usage patterns (e.g., if user scans barcodes often)
- **Could:** Proactive suggestions ("Looks like you're at a store, scan barcode?")

**FR-7.6: App Intents**
- **Must:** Implement App Intents framework (iOS 16+)
- **Must:** Define intent schemas for all actions
- **Should:** Support parameters via Siri/Shortcuts UI
- **Could:** Multi-step intents (e.g., detect + export)

**Acceptance Criteria:**
- [ ] All 5 core actions work in Shortcuts app
- [ ] Siri voice commands trigger actions correctly
- [ ] Results returned within 10 seconds (camera capture + detection)
- [ ] Parameter validation prevents invalid inputs (e.g., threshold >1.0)
- [ ] Donated actions appear in Shortcuts suggestions within 24 hours
- [ ] VoiceOver support for Shortcuts UI
- [ ] Actions work in background (up to iOS limits)

**Dependencies:**
- Intents framework or App Intents framework (iOS 16+)
- All detection managers (must support programmatic invocation)
- CameraManager (programmatic photo capture)

**Technical Considerations:**
- **Framework Choice:** Use App Intents (iOS 16+) for modern API; fallback to Intents for iOS 14-15
- **Background Limits:** Actions may timeout after 10-30 seconds in background
- **Camera Access:** Shortcuts require camera permission; handle gracefully
- **Testing:** Shortcuts app integration tests; Siri voice command tests (manual); parameter validation tests

---

#### Feature 8: Confidence Threshold Sliders

**Priority:** Should Have
**User Stories:** US-9
**Estimated Effort:** 1 week

**Functional Requirements:**

**FR-8.1: Per-Category Thresholds**
- **Must:** Separate threshold settings for each DetectionCategory (OCR, Object Detection, Classification, Contour, Barcode, Face)
- **Must:** Default threshold: 0.5 (50%)
- **Must:** Range: 0.1 to 0.95 (slider with 0.05 increments)
- **Should:** Reset to default button per category
- **Could:** Global threshold override (apply same to all categories)

**FR-8.2: Settings UI**
- **Must:** Threshold sliders in SettingsView under "Detection Thresholds" section
- **Must:** Live value display (e.g., "0.75 (75%)")
- **Must:** Icon + label for each category
- **Should:** Explanation text ("Lower threshold = more detections but lower accuracy")
- **Could:** Visual preview of threshold effect (sample image)

**FR-8.3: Threshold Application**
- **Must:** Filter detection results by threshold (discard results below threshold)
- **Must:** Apply to both real-time and single-image detections
- **Must:** Reflect in stored results (only store above-threshold results)
- **Should:** Show "X results filtered" message if results discarded
- **Could:** Option to show below-threshold results dimmed (for reference)

**FR-8.4: Persistence**
- **Must:** Store thresholds in AppSettings (UserDefaults)
- **Must:** Persist across app launches
- **Should:** Export thresholds in settings backup/export

**Acceptance Criteria:**
- [ ] Threshold changes apply immediately to next detection
- [ ] Real-time detection respects threshold (no UI lag)
- [ ] Stored results reflect current threshold at time of detection
- [ ] Slider is accessible (VoiceOver announces value changes)
- [ ] Settings screen shows all 5-6 category thresholds clearly
- [ ] Reset button restores default 0.5 for each category

**Dependencies:**
- AppSettings (add threshold properties)
- All detection protocols (filter by threshold)

**Technical Considerations:**
- **Filtering Logic:** Post-processing filter (easier) vs. pre-processing threshold (more efficient)
- **Real-Time Performance:** Ensure threshold filtering doesn't slow frame rate
- **Data Migration:** Existing results may not have threshold metadata; handle gracefully
- **Testing:** Threshold application tests for each category; UI tests for slider interaction

---

### Phase 3: Advanced Features (Months 7-9)

---

#### Feature 9: Side-by-Side Comparison Mode

**Priority:** Could Have
**User Stories:** US-10
**Estimated Effort:** 2-3 weeks

**Functional Requirements:**

**FR-9.1: Result Selection**
- **Must:** "Compare" button on Results list view
- **Must:** Multi-select mode (tap to select 2 results)
- **Must:** Same category required (compare OCR to OCR, objects to objects)
- **Should:** Quick compare from result detail (find similar results)
- **Could:** Compare across categories (with limitations)

**FR-9.2: Split-Screen View**
- **Must:** Side-by-side image display (2 columns)
- **Must:** Synchronized zoom/pan (zoom both images together)
- **Must:** Overlay toggle (show/hide detection overlays)
- **Should:** Difference highlighting (bounding box mismatches in red)
- **Could:** Slider to blend images (swipe left/right to compare)

**FR-9.3: Comparison Metrics**
- **Must:** Object Detection: Intersection over Union (IoU) for matching boxes
- **Must:** OCR: Text similarity score (Levenshtein distance)
- **Must:** Classification: Top-K overlap
- **Should:** Confidence delta per detection
- **Should:** Framework comparison (Vision vs Core ML)
- **Could:** Performance metrics (inference time, memory)

**FR-9.4: Difference Visualization**
- **Must:** Color-coded overlays (green = match, red = unique to left, blue = unique to right)
- **Must:** Metrics summary card (overall similarity score, match count)
- **Should:** Detailed match table (list each detection pair with IoU/similarity)
- **Could:** Heatmap of differences

**FR-9.5: Export Comparison**
- **Must:** Export comparison report (JSON or PDF)
- **Must:** Include both images, metrics, match table
- **Should:** Side-by-side image export (single image with both views)
- **Could:** CSV format for metric analysis

**Acceptance Criteria:**
- [ ] User can select 2 results and enter comparison view
- [ ] Images display side-by-side with synchronized zoom
- [ ] IoU calculation completes in <500ms for 20 bounding boxes
- [ ] Metrics summary is accurate and easy to understand
- [ ] Export includes all comparison data (images + metrics)
- [ ] Works for all detection categories (with category-specific metrics)

**Dependencies:**
- Result detail views
- Geometry calculation libraries (IoU, Levenshtein)

**Technical Considerations:**
- **Image Sizing:** Handle different aspect ratios and resolutions
- **Performance:** Compute metrics asynchronously; cache results
- **Accuracy:** IoU threshold for "match" detection (e.g., 0.5)
- **Testing:** Metric calculation accuracy tests; UI tests for interaction

---

#### Feature 10: Pose Estimation

**Priority:** Could Have
**User Stories:** US-11
**Estimated Effort:** 2-3 weeks

**Functional Requirements:**

**FR-10.1: Human Pose Detection**
- **Must:** Detect human body pose using Vision VNDetectHumanBodyPoseRequest
- **Must:** 17 major joint keypoints (head, shoulders, elbows, wrists, hips, knees, ankles)
- **Must:** Confidence score per joint
- **Must:** Support multiple people in single image
- **Should:** 2D joint coordinates in image space

**FR-10.2: Skeleton Visualization**
- **Must:** Draw skeleton overlay (connect joints with lines)
- **Must:** Color-coded joints by confidence (green = high, yellow = medium, red = low)
- **Should:** Joint labels on tap (show joint name + confidence)
- **Could:** Pose classification (standing, sitting, walking)

**FR-10.3: Pose Metrics**
- **Must:** Joint angle calculation (elbow, knee, hip angles)
- **Should:** Pose quality score (overall confidence)
- **Could:** Posture analysis (symmetry, alignment)

**FR-10.4: Use Cases**
- **Must:** Accessibility: Pose guidance for exercises or physical therapy
- **Should:** Fitness tracking (detect exercise form)
- **Could:** Motion analysis (compare poses over time)

**FR-10.5: Storage and Results**
- **Must:** New DetectionCategory: .poseEstimation
- **Must:** StoredPoseEstimationResult with joint data, angles, confidence
- **Must:** Integration with DetectionResultsManager

**FR-10.6: UI/UX**
- **Must:** "Pose Estimation" mode in CameraView
- **Must:** Real-time skeleton overlay (if enabled)
- **Must:** Result detail view with joint visualization and metrics
- **Should:** Accessibility announcements (e.g., "2 people detected, average pose quality 85%")

**Acceptance Criteria:**
- [ ] Detects human poses with >85% accuracy (compare to known datasets)
- [ ] Supports up to 5 people per image
- [ ] Joint angle calculations are accurate within 5 degrees
- [ ] Real-time overlay renders at 15+ FPS
- [ ] Results stored and exportable like other categories
- [ ] Accessibility: VoiceOver announces pose metrics

**Dependencies:**
- Vision framework (VNDetectHumanBodyPoseRequest, VNHumanBodyPoseObservation)
- New protocol: PoseEstimationProtocol
- Geometry libraries (angle calculation)

**Technical Considerations:**
- **Performance:** Pose detection is slower than object detection (1-2s per image)
- **Multi-Person:** Handle overlapping poses gracefully
- **Visualization:** Use CAShapeLayer or SwiftUI for skeleton overlay
- **Testing:** Pose accuracy tests with benchmark datasets; UI tests for overlay

---

#### Feature 11: Custom Model Import

**Priority:** Could Have
**User Stories:** US-12
**Estimated Effort:** 3-4 weeks

**Functional Requirements:**

**FR-11.1: Model Import**
- **Must:** Import .mlpackage and .mlmodel files via Files app picker
- **Must:** Validate model schema (check input/output layers)
- **Must:** Support object detection models (bounding box output)
- **Should:** Support classification models (category probabilities)
- **Could:** Support segmentation models (pixel masks)

**FR-11.2: Model Validation**
- **Must:** Check input layer: expects 416x416 or 640x640 RGB image
- **Must:** Check output layers: bounding boxes (x, y, w, h), confidences, class IDs
- **Must:** Display validation errors with expected vs. actual schema
- **Should:** Warn if model size exceeds 500MB
- **Could:** Validate against YOLO/SSD/Faster R-CNN architectures

**FR-11.3: Model Management**
- **Must:** List all imported models in Settings > Core ML > Custom Models
- **Must:** User-assigned model name and description
- **Must:** Model file size and date imported
- **Must:** Delete custom models (with confirmation)
- **Should:** Set custom model as active detector
- **Could:** Model versioning (import multiple versions)

**FR-11.4: Model Execution**
- **Must:** Integrate custom models into UnifiedObjectDetectionProtocol
- **Must:** Run inference using Core ML APIs
- **Must:** Parse output layers to extract bounding boxes
- **Should:** Map class IDs to human-readable labels (user-provided or COCO defaults)
- **Could:** Custom post-processing (NMS threshold, confidence threshold)

**FR-11.5: Storage and Sandboxing**
- **Must:** Store models in app Documents directory (user-accessible via Files app)
- **Must:** Sandboxing compliant (no network access during import)
- **Should:** Model metadata file (JSON with name, labels, input size)
- **Could:** iCloud sync for custom models

**FR-11.6: UI/UX**
- **Must:** "Import Custom Model" button in Settings > Core ML
- **Must:** Model import flow: picker → validation → naming → save
- **Must:** Model list view with delete swipe action
- **Should:** Model detail view (schema, metadata, usage)
- **Could:** Model preview (test on sample image)

**Acceptance Criteria:**
- [ ] Successfully imports valid YOLOv5/v8 .mlpackage models
- [ ] Rejects invalid models with clear error messages
- [ ] Custom models appear in framework/model picker
- [ ] Inference runs correctly with custom models (same as built-in YOLOv12s)
- [ ] Models persist across app launches
- [ ] Delete model removes file from disk
- [ ] File size limit enforced (reject models >1GB)

**Dependencies:**
- Core ML framework (MLModel, MLFeatureProvider)
- Files app (UIDocumentPickerViewController)
- UnifiedObjectDetectionProtocol (extend for custom models)

**Technical Considerations:**
- **Schema Parsing:** Use MLModel.modelDescription to inspect layers
- **Output Parsing:** Support multiple output formats (YOLOv5 vs YOLOv8 vs SSD)
- **Security:** Validate models don't contain malicious code (sandboxing handles this)
- **Performance:** Large models (>200MB) may slow inference; warn users
- **Testing:** Import tests with various model formats; schema validation tests; inference accuracy tests

---

#### Feature 12: Performance Benchmarking

**Priority:** Could Have
**User Stories:** US-13
**Estimated Effort:** 2 weeks

**Functional Requirements:**

**FR-12.1: Metrics Collection**
- **Must:** Inference time (ms) per detection
- **Must:** Memory usage (MB) during inference
- **Must:** FPS for real-time detections
- **Should:** CPU/GPU utilization (if accessible)
- **Could:** Battery impact estimation

**FR-12.2: Framework Comparison**
- **Must:** Compare Vision vs. Core ML performance
- **Must:** Side-by-side metrics table
- **Should:** Chart visualization (bar chart or line graph)
- **Could:** Historical performance tracking (track over time)

**FR-12.3: Benchmarking UI**
- **Must:** "Performance" section in Settings
- **Must:** Toggle to enable/disable benchmarking (disabled by default)
- **Must:** Display latest benchmark results
- **Should:** Export benchmarks as CSV or JSON
- **Could:** Share benchmark report (for research/feedback)

**FR-12.4: Instrumentation**
- **Must:** Minimal overhead (<5ms added latency)
- **Must:** Timestamp-based measurement (mach_absolute_time or ProcessInfo)
- **Should:** Memory snapshots before/after inference
- **Could:** Detailed per-layer metrics (Core ML only)

**FR-12.5: Result Integration**
- **Must:** Attach performance metrics to stored results (optional, if benchmarking enabled)
- **Should:** Filter/sort results by performance metrics
- **Could:** Performance leaderboard (fastest detections)

**Acceptance Criteria:**
- [ ] Inference time measurement accurate within 1ms
- [ ] Memory usage measurement accurate within 10MB
- [ ] Benchmarking overhead <5ms (imperceptible to user)
- [ ] Metrics displayed clearly in Settings > Performance
- [ ] Export includes all metrics in structured format (CSV/JSON)
- [ ] Benchmarking can be toggled on/off without app restart

**Dependencies:**
- All detection managers (add instrumentation hooks)
- ProcessInfo or mach_absolute_time APIs

**Technical Considerations:**
- **Accuracy:** Use high-resolution timers (mach_absolute_time, not Date())
- **Overhead:** Minimize instrumentation impact; only measure when enabled
- **Memory:** Use Memory.usage() or task_info APIs for accurate measurement
- **Testing:** Benchmark accuracy tests; overhead tests; CSV/JSON export validation

---

### Non-Functional Requirements

#### Performance

**NFR-1: Response Time**
- **Must:** All UI interactions respond within 100ms (button taps, navigation)
- **Must:** Real-time detections maintain 15+ FPS on iPhone 15
- **Must:** Export generation completes within 3 seconds for typical results
- **Should:** Batch processing completes at >10 images per minute

**NFR-2: Resource Usage**
- **Must:** App memory footprint <300MB during idle
- **Must:** Peak memory <700MB during batch processing
- **Should:** Battery drain <5% per hour during continuous camera use
- **Could:** Adaptive quality (reduce resolution/FPS on low battery)

**NFR-3: Scalability**
- **Must:** Support 1000+ stored results without performance degradation
- **Must:** Search/filter operations complete in <500ms for 1000 results
- **Should:** Widget updates within 5 seconds of new result
- **Could:** Pagination for large result sets

#### Security and Privacy

**NFR-4: Data Privacy**
- **Must:** No biometric data storage (face detection only, no recognition)
- **Must:** All data stored locally on-device (no cloud sync without explicit user consent)
- **Must:** Privacy policy updated for face detection and custom models
- **Should:** Option to blur/redact faces in exported images
- **Could:** Export encryption (password-protected PDFs)

**NFR-5: Sandboxing**
- **Must:** Custom models run in app sandbox (no network access)
- **Must:** Photo library access limited to user-selected images (PHPicker)
- **Should:** App Groups for widget data sharing (secure container)

**NFR-6: Permissions**
- **Must:** Request camera permission only when needed (first camera use)
- **Must:** Request photo library permission only when needed (import/export)
- **Must:** Clear permission prompts with usage descriptions
- **Should:** Settings deep links for denied permissions

#### Accessibility

**NFR-7: VoiceOver Support**
- **Must:** All UI elements have accessibility labels
- **Must:** Detection results announced via VoiceOver (category, count, confidence)
- **Must:** Widget content accessible to VoiceOver
- **Should:** Haptic feedback for detection events (configurable intensity)
- **Could:** Audio cues for detection success/failure

**NFR-8: Dynamic Type**
- **Must:** Support Dynamic Type (text scales with iOS settings)
- **Must:** Layouts adapt to larger text sizes (no truncation)
- **Should:** High contrast mode support

**NFR-9: Color Accessibility**
- **Must:** Minimum 4.5:1 contrast ratio for all text (WCAG AA)
- **Should:** Color-blind friendly palettes (not rely solely on color for info)
- **Could:** Dark mode optimizations

#### Compatibility

**NFR-10: Platform Support**
- **Must:** iOS 18.5+ (baseline)
- **Should:** Support iPhone 14, 15, 16 series
- **Could:** iPad support (responsive layouts)

**NFR-11: Localization**
- **Must:** English language support
- **Should:** Localized strings for UI (prepared for future localization)
- **Could:** Multi-language OCR support (Vision supports 30+ languages)

#### Maintainability

**NFR-12: Code Quality**
- **Must:** SwiftLint compliance (existing .swiftlint.yml rules)
- **Must:** Protocol-first architecture (all new features use protocols)
- **Must:** 80%+ unit test coverage for business logic
- **Should:** UI tests for critical user flows
- **Could:** Code documentation (DocC)

**NFR-13: Architecture Patterns**
- **Must:** Follow existing patterns (DI via @Injected, feature-based structure)
- **Must:** MainActor for ViewModels, background threads for heavy processing
- **Must:** SwiftUI for all UI (no UIKit unless necessary)
- **Should:** Async/await for asynchronous operations (avoid completion handlers)

---

## Technical Specifications

### Architecture Overview

All new features will follow APUS's established architecture:

1. **Protocol-First Design:** Define new protocols in `apus/Core/Protocols/` for each major capability
2. **Feature-Based Structure:** Organize under `apus/Features/<FeatureName>/`
3. **Dependency Injection:** Register all new services in `AppDependencies.swift`
4. **SwiftUI + MVVM:** ViewModels with `@MainActor`, Views as pure presentation
5. **Background Processing:** Heavy operations on `.utility` QoS queues

### Data Model Changes

#### New Detection Categories

**Extend `DetectionCategory` enum in `AppSettings.swift`:**

```swift
enum DetectionCategory: String, CaseIterable, Hashable {
    case ocr = "OCR"
    case objectDetection = "Object Detection"
    case classification = "Classification"
    case contourDetection = "Contour Detection"
    case barcode = "Barcode"
    case faceDetection = "Face Detection"       // NEW
    case poseEstimation = "Pose Estimation"     // NEW
}
```

**Add corresponding storage models in `DetectionResults.swift`:**

```swift
struct StoredFaceDetectionResult: Codable, Identifiable {
    let id = UUID()
    let timestamp: Date
    let detectedFaces: [StoredDetectedFace]
    let imageData: Data
    let imageSize: CGSize
    let thumbnailData: Data?
}

struct StoredDetectedFace: Codable, Identifiable {
    let id = UUID()
    let boundingBox: CGRect
    let landmarks: [CGPoint]  // 68 facial landmarks
    let confidence: Float
    let qualityMetrics: FaceQualityMetrics
}

struct FaceQualityMetrics: Codable {
    let blur: Float
    let brightness: Float
    let occlusion: Bool
}

struct StoredPoseEstimationResult: Codable, Identifiable {
    let id = UUID()
    let timestamp: Date
    let detectedPoses: [StoredDetectedPose]
    let imageData: Data
    let imageSize: CGSize
    let thumbnailData: Data?
}

struct StoredDetectedPose: Codable, Identifiable {
    let id = UUID()
    let joints: [JointKeypoint]  // 17 keypoints
    let confidence: Float
}

struct JointKeypoint: Codable {
    let name: String  // e.g., "leftElbow"
    let position: CGPoint
    let confidence: Float
}
```

#### AppSettings Extensions

**Add new settings for features:**

```swift
// Confidence thresholds per category
@Published var ocrConfidenceThreshold: Float = 0.5
@Published var objectDetectionConfidenceThreshold: Float = 0.5
@Published var classificationConfidenceThreshold: Float = 0.5
@Published var contourConfidenceThreshold: Float = 0.5
@Published var barcodeConfidenceThreshold: Float = 0.5
@Published var faceDetectionConfidenceThreshold: Float = 0.5
@Published var poseEstimationConfidenceThreshold: Float = 0.5

// Document scanner settings
@Published var documentAutoCaptureEnabled: Bool = true
@Published var documentAutoCaptureDelay: TimeInterval = 1.0  // seconds

// Benchmarking
@Published var isBenchmarkingEnabled: Bool = false

// Haptic feedback
@Published var hapticIntensity: HapticIntensity = .medium
enum HapticIntensity: String, Codable {
    case light, medium, strong, off
}
```

### API Design

#### New Protocols

**FaceDetectionProtocol.swift:**

```swift
protocol FaceDetectionProtocol {
    func detectFaces(in image: UIImage) async throws -> [DetectedFace]
    func detectFaceLandmarks(in image: UIImage) async throws -> [DetectedFace]
    func analyzeFaceQuality(in image: UIImage) async throws -> [FaceQualityMetrics]
    func preload()
}

struct DetectedFace {
    let boundingBox: CGRect
    let landmarks: [CGPoint]
    let confidence: Float
    let qualityMetrics: FaceQualityMetrics
}
```

**PoseEstimationProtocol.swift:**

```swift
protocol PoseEstimationProtocol {
    func detectPoses(in image: UIImage) async throws -> [DetectedPose]
    func preload()
}

struct DetectedPose {
    let joints: [JointKeypoint]
    let confidence: Float
}
```

**ExportServiceProtocol.swift:**

```swift
protocol ExportServiceProtocol {
    func exportOCR(_ result: StoredOCRResult, format: ExportFormat) async throws -> URL
    func exportObjectDetection(_ result: StoredObjectDetectionResult, format: ExportFormat) async throws -> URL
    // ... similar for other categories
    func exportBatch(_ results: [any StoredResult], format: ExportFormat) async throws -> URL
}

enum ExportFormat: String, CaseIterable {
    case json, csv, plainText, pdf
}
```

**BatchProcessingServiceProtocol.swift:**

```swift
protocol BatchProcessingServiceProtocol {
    func processBatch(_ images: [UIImage], category: DetectionCategory, progressHandler: @escaping (Int, Int) -> Void) async throws -> [any StoredResult]
    func cancelBatch()
}
```

### Component Architecture

#### Feature: Export & Share

**File Structure:**

```
Features/Export/
├── Services/
│   └── ExportService.swift          // Implements ExportServiceProtocol
├── ViewModels/
│   └── ExportViewModel.swift        // Manages export UI state
└── Views/
    └── ExportFormatPickerView.swift // Format selection UI
```

**Integration Points:**
- Called from result detail views (OCRResultDetailView, ObjectDetectionResultDetailView, etc.)
- Uses iOS Share Sheet (UIActivityViewController wrapped in SwiftUI)
- Async export generation on background queue

#### Feature: Timeline & Search

**File Structure:**

```
Features/Results/
├── ViewModels/
│   ├── TimelineViewModel.swift       // Manages timeline state, search, filtering
│   └── ResultSearchService.swift    // Search indexing and query logic
└── Views/
    ├── TimelineView.swift            // Main timeline UI
    ├── SearchBarView.swift           // Search input + filters
    └── TimelineResultRow.swift       // Reusable row component
```

**Integration Points:**
- Extends existing `ResultsDashboardView`
- Uses `DetectionResultsManager` as data source
- In-memory search index (future: Core Data full-text search)

#### Feature: Document Scanner

**File Structure:**

```
Features/Camera/
├── Managers/
│   └── DocumentDetectionManager.swift  // Rectangle detection + auto-capture
├── ViewModels/
│   └── CameraViewModel.swift           // Extend with document mode
└── Views/
    ├── CameraView.swift                // Add document mode toggle
    └── DocumentOverlayView.swift       // Rectangle detection overlay
```

**Integration Points:**
- Extends `CameraManager` with rectangle detection handler
- Uses Vision `VNDetectRectanglesRequest`
- Triggers OCR via `VisionTextRecognitionProtocol` after perspective correction

#### Feature: Widgets

**File Structure:**

```
apusWidgets/                            // New Widget Extension target
├── apusWidgets.swift                   // Widget entry point
├── TimelineProvider.swift              // Widget timeline provider
├── WidgetViews.swift                   // Small, Medium, Large views
└── SharedData/
    └── ResultsDataProvider.swift       // Reads from App Group
```

**Integration Points:**
- App Group: `group.com.apus.shared`
- Shares `DetectionResultsManager` data via App Group container
- Updates timeline on app state changes (foreground/background)

#### Feature: Shortcuts

**File Structure:**

```
Features/Shortcuts/
├── Intents/
│   ├── DetectObjectsIntent.swift
│   ├── ReadTextIntent.swift
│   └── ScanBarcodeIntent.swift
└── IntentHandlers/
    ├── DetectObjectsIntentHandler.swift
    └── ...
```

**Integration Points:**
- Implements `INExtension` or App Intents framework
- Invokes detection managers programmatically
- Returns structured output for Shortcuts chaining

### Third-Party Services and APIs

**No New Third-Party Dependencies Required:**
- All features use native iOS frameworks (Vision, Core ML, WidgetKit, Intents, PDFKit)
- Export formats implemented with Foundation (JSONEncoder, CSV generation)

### Migration Strategy

#### Existing Data Migration

1. **Add New Categories to Enum:**
   - `DetectionCategory.faceDetection`, `.poseEstimation`
   - Update `AppSettings` storage limits for new categories

2. **Confidence Thresholds:**
   - Add new `@Published` properties to `AppSettings`
   - Default to 0.5 for backward compatibility
   - No migration needed for existing stored results (thresholds applied at display time)

3. **Stored Results Schema:**
   - New `StoredFaceDetectionResult` and `StoredPoseEstimationResult` models are additive
   - Existing models unchanged (backward compatible)
   - Use `@AppStorage` keys like existing categories

4. **Widget Data Sharing:**
   - Create App Group on first app launch
   - Copy latest results to shared container
   - No user action required

#### Rollback Plan

- New features are toggleable (e.g., face detection can be disabled in Settings)
- Export formats are non-destructive (original data unchanged)
- Custom model import isolated (delete custom models reverts to built-in)
- Widgets can be removed by user without affecting app

---

## Implementation Considerations

### Technical Approach

#### Recommended Architecture Patterns

1. **Protocol-Driven Development:**
   - Define protocol first for testability
   - Implement concrete class with Vision/Core ML
   - Register in `AppDependencies`

2. **Async/Await for Asynchronous Work:**
   - All detection methods return `async throws`
   - Use `Task` for background work, `@MainActor` for UI updates

3. **Background Processing:**
   - `.utility` QoS for ML inference
   - `.background` QoS for batch processing
   - Autoreleasepool for memory management in loops

4. **State Management:**
   - `@Published` properties in ViewModels
   - `@StateObject` in Views
   - `AppSettings.shared` for global state

#### Technology Choices

- **SwiftUI:** All UI (no UIKit unless necessary, e.g., Share Sheet wrapper)
- **Vision Framework:** Primary ML framework (face detection, pose, OCR, rectangles)
- **Core ML:** Custom model support
- **WidgetKit:** Home screen widgets
- **App Intents / Intents:** Shortcuts (prefer App Intents for iOS 16+)
- **PDFKit:** PDF export generation

#### Integration with Existing Codebase

- **CameraManager:** Extend with document mode, add rectangle detection handler
- **DetectionResultsManager:** Add extensions for face/pose categories
- **AppSettings:** Add properties for thresholds, document mode, benchmarking
- **ResultsDashboardView:** Add timeline/search UI, integrate with existing results list
- **PreviewView:** Extend to handle document perspective correction preview

#### Performance Optimization Strategies

1. **Lazy Loading:**
   - Thumbnails load on-demand in timeline view (LazyVStack)
   - Search results paginated (load 50 at a time)

2. **Caching:**
   - Precompute thumbnails on result save
   - Cache search index in memory (rebuild on app launch)

3. **Batch Operations:**
   - Process images serially to avoid memory spikes
   - Autoreleasepool per image in batch loop

4. **Widget Optimization:**
   - Small timeline (10 entries max)
   - Compressed thumbnails (<50KB per image)

5. **Benchmarking Overhead:**
   - Only measure when enabled
   - Use high-resolution timers (mach_absolute_time)

#### Error Handling and Edge Cases

**Export Errors:**
- Disk full: Catch and display user-friendly message "Not enough storage space"
- Unsupported characters: UTF-8 encoding with fallback to ASCII
- Large files: Warn if export >10MB before sharing

**Search/Filter Errors:**
- Empty results: Display "No results found" with clear filter state
- Regex errors: Catch invalid search patterns, show simple search only

**Document Scanner Errors:**
- No rectangle detected: Show "Position document within frame" hint
- Perspective correction fails: Fallback to uncorrected image with warning

**Batch Processing Errors:**
- Image load failure: Skip image, log to error report
- Out of memory: Pause batch, prompt user to free memory or reduce batch size
- Detection timeout: Skip image after 30 seconds

**Custom Model Errors:**
- Invalid schema: Display expected vs. actual input/output layers
- Model too large: Reject models >1GB with size warning
- Inference failure: Catch Core ML errors, display "Model incompatible with this image"

**Widget Errors:**
- No data: Show placeholder "No recent detections"
- Data corruption: Rebuild widget data from app on next launch

---

### Development Phases

#### Phase 1: Foundation (Months 1-3) - MVP Launch

**Goals:**
- Deliver core productivity features (export, search, timeline)
- Establish document scanner as differentiator
- Launch basic widget for platform integration

**Deliverables:**

**Month 1:**
- Week 1-2: Export Service implementation (JSON, CSV, TXT, PDF formats)
- Week 3-4: Timeline View + Search/Filter UI

**Month 2:**
- Week 1-2: Document Scanner Mode (rectangle detection, auto-capture, perspective correction)
- Week 3-4: Basic Widget (Small + Medium variants)

**Month 3:**
- Week 1: Integration testing, bug fixes
- Week 2: UI polish, accessibility audit
- Week 3: Beta testing (TestFlight)
- Week 4: App Store submission, launch prep

**Success Criteria:**
- All Phase 1 features functional and tested
- Export works for 100% of detection categories
- Document scanner accuracy >90% in varied lighting
- Widget updates reliably within 5 seconds
- App Store approval achieved

**Risks:**
- Document scanner complexity (mitigate: MVP uses Vision APIs, no custom CV)
- Widget timeline limits (mitigate: optimize update frequency, cache data)

---

#### Phase 2: Enhancement (Months 4-6) - Advanced ML & Workflows

**Goals:**
- Expand ML capabilities (face detection, pose estimation)
- Enable batch workflows for professional users
- Deepen iOS integration (Shortcuts)

**Deliverables:**

**Month 4:**
- Week 1-2: Face Detection Protocol + Manager implementation
- Week 3-4: Face Detection UI, storage, export integration

**Month 5:**
- Week 1-2: Batch Processing Service (import, queue, process)
- Week 3-4: Batch UI, progress tracking, bulk export

**Month 6:**
- Week 1-2: Siri Shortcuts (5 core actions: Detect Objects, Read Text, Scan Barcode, Classify, Scan Document)
- Week 3: Confidence Threshold Sliders (all categories)
- Week 4: Integration testing, beta release

**Success Criteria:**
- Face detection matches iOS Photos app accuracy (>90%)
- Batch processing handles 50 images in <5 minutes
- At least 3 Shortcuts work reliably with Siri voice commands
- Threshold sliders apply correctly to all categories

**Risks:**
- Face detection privacy concerns (mitigate: legal review, clear privacy policy)
- Batch processing memory usage (mitigate: serial processing, autoreleasepool)
- Shortcuts background limits (mitigate: clear timeout messaging, graceful failure)

---

#### Phase 3: Optimization (Months 7-9) - Professional Tools & Performance

**Goals:**
- Serve advanced users (researchers, developers)
- Enable comparison and benchmarking workflows
- Support custom model extensibility

**Deliverables:**

**Month 7:**
- Week 1-2: Side-by-Side Comparison Mode (UI + metrics)
- Week 3-4: Pose Estimation Protocol + Manager implementation

**Month 8:**
- Week 1-2: Pose Estimation UI, storage, export integration
- Week 3-4: Custom Model Import (validation, management, execution)

**Month 9:**
- Week 1-2: Performance Benchmarking (instrumentation, metrics UI)
- Week 3: Enhanced Haptic Feedback (customizable patterns)
- Week 4: Final polish, comprehensive testing, release

**Success Criteria:**
- Comparison mode IoU calculations accurate and performant
- Pose estimation supports up to 5 people per image
- Custom models import and run successfully (YOLOv5/v8 tested)
- Benchmarking overhead <5ms

**Risks:**
- Custom model security (mitigate: sandboxing, schema validation)
- Pose estimation performance (mitigate: background processing, frame skipping)
- Comparison mode UI complexity (mitigate: iterative design, user testing)

---

### Dependencies and Blockers

**Internal Dependencies:**

- **DetectionResultsManager:** Must support new categories (face, pose) before features ship
- **CameraManager:** Document mode requires extension for rectangle detection handler
- **AppSettings:** Threshold settings must be in place before Phase 2 features
- **Export Service:** Must be complete before batch processing (Phase 2)

**External Dependencies:**

- **iOS 18.5+ APIs:** All features require iOS 18.5 baseline
- **Vision Framework:** Face landmarks, pose, rectangle detection
- **App Review:** Document scanner, face detection may require privacy justification

**Potential Blockers:**

1. **App Store Review Delays:**
   - **Risk:** Face detection flagged for privacy concerns
   - **Mitigation:** Clear privacy policy, no face recognition/identification, detection only

2. **Performance Issues:**
   - **Risk:** Batch processing causes memory crashes on older devices (iPhone 14)
   - **Mitigation:** Memory profiling, batch size limits, progressive processing

3. **Widget Limitations:**
   - **Risk:** iOS widget timeline limits prevent real-time updates
   - **Mitigation:** Optimize update frequency, use timeline with 10 entries

4. **Custom Model Complexity:**
   - **Risk:** Model schema validation fails for uncommon architectures
   - **Mitigation:** Start with YOLO-only support, expand based on user feedback

5. **Shortcuts Background Limits:**
   - **Risk:** Actions timeout in background (iOS 30-second limit)
   - **Mitigation:** Optimize detection speed, clear timeout messaging

---

### Risks and Mitigation

#### Technical Risks

**Risk T-1: Document Scanner Accuracy**
- **Impact:** High (core differentiator)
- **Probability:** Medium
- **Mitigation:**
  - Use proven Vision APIs (VNDetectRectanglesRequest)
  - Extensive testing with varied documents (paper types, lighting, angles)
  - Manual capture fallback for edge cases
  - User feedback collection via TestFlight

**Risk T-2: Batch Processing Memory Crashes**
- **Impact:** High (app crash = poor UX)
- **Probability:** Medium
- **Mitigation:**
  - Serial processing (one image at a time)
  - Autoreleasepool in batch loop
  - Memory profiling on iPhone 14 (lowest target)
  - Batch size limits (max 50 images)
  - Pause/resume functionality

**Risk T-3: Custom Model Security**
- **Impact:** High (App Store rejection risk)
- **Probability:** Low
- **Mitigation:**
  - Sandboxing (models run in app sandbox)
  - Schema validation (reject malformed models)
  - File size limits (max 1GB)
  - Legal/security review before feature release

**Risk T-4: Widget Update Reliability**
- **Impact:** Medium (poor widget UX)
- **Probability:** Medium
- **Mitigation:**
  - Optimize timeline generation (small data payloads)
  - Test on various iOS versions (18.5, 18.6, 19.0)
  - Fallback to placeholder if data unavailable

#### Business Risks

**Risk B-1: Low Feature Adoption**
- **Impact:** Medium (wasted dev effort)
- **Probability:** Low
- **Mitigation:**
  - User research before development (validate need)
  - In-app onboarding highlights new features
  - TestFlight beta with target personas (Emma, Marcus, Priya, David)
  - Analytics tracking feature usage

**Risk B-2: App Store Privacy Rejection**
- **Impact:** High (blocks release)
- **Probability:** Low
- **Mitigation:**
  - Privacy policy updated and reviewed by legal
  - Face detection: detection only, no recognition/identification
  - Clear App Store submission notes explaining privacy approach
  - Reference Apple's own face detection (Photos app)

**Risk B-3: Competitive Feature Parity**
- **Impact:** Low (APUS already has broad ML capabilities)
- **Probability:** Medium
- **Mitigation:**
  - Focus on breadth (5+ ML categories vs. competitors' 2-3)
  - Custom model import as unique differentiator
  - Performance benchmarking for research/prosumer users

#### User Experience Risks

**Risk UX-1: Feature Complexity Overload**
- **Impact:** Medium (confused users, poor reviews)
- **Probability:** Medium
- **Mitigation:**
  - Progressive disclosure (advanced features in Settings)
  - Onboarding tooltips for new features
  - Default settings work for 80% of users
  - User testing with non-technical personas

**Risk UX-2: Export Format Confusion**
- **Impact:** Low (minor friction)
- **Probability:** Medium
- **Mitigation:**
  - Clear format descriptions in picker (e.g., "CSV - Spreadsheet compatible")
  - Preview export content before sharing
  - Default to most common format (JSON for developers, CSV for business users)

**Risk UX-3: Shortcuts Discoverability**
- **Impact:** Low (feature underutilized)
- **Probability:** High
- **Mitigation:**
  - In-app "Add to Siri" prompts after common actions
  - Settings section for Shortcuts with examples
  - Donate actions proactively (iOS suggestions)

---

## Success Metrics and Analytics

### Quantitative Metrics

**User Engagement (6-Month Targets):**

- **Daily Active Users (DAU):** +40% increase from baseline
  - **Measurement:** Firebase Analytics or App Analytics
  - **Target:** 10,000 → 14,000 DAU

- **Session Duration:** +30% increase
  - **Baseline:** 3 minutes average
  - **Target:** 3.9 minutes average
  - **Measurement:** Track session start/end events

- **Sessions Per User Per Week:** +25% increase
  - **Baseline:** 5 sessions/week
  - **Target:** 6.25 sessions/week

**Feature Adoption:**

- **Export Usage:** 50% of active users export at least once per week
  - **Measurement:** Track "Export Completed" event with format parameter

- **Timeline/Search Usage:** 70% of users with >10 results use search/filter
  - **Measurement:** Track "Search Query" and "Filter Applied" events

- **Document Scanner Usage:** 40% of users try document mode within first week
  - **Measurement:** Track "Document Mode Enabled" event

- **Widget Installation:** 25% of users add at least one APUS widget
  - **Measurement:** Track widget view impressions (WidgetKit analytics)

- **Shortcuts Creation:** 15% of users create at least one Siri Shortcut
  - **Measurement:** Track intent donations and Shortcut invocations

- **Batch Processing:** 10% of users process a batch of 5+ images
  - **Measurement:** Track "Batch Process Started" event with image count

- **Confidence Threshold Adjustment:** 20% of users modify at least one threshold
  - **Measurement:** Track "Threshold Changed" event with category and value

**Performance Metrics:**

- **Export Success Rate:** >98% (exports complete without errors)
- **Document Scanner Auto-Capture Rate:** >85% (successful auto-capture vs. manual)
- **Batch Processing Completion Rate:** >95% (batches complete without crashes)
- **Widget Update Latency:** <5 seconds (95th percentile)

### Qualitative Metrics

**User Satisfaction:**

- **App Store Rating:** Maintain 4.5+ stars
  - **Target:** 500+ new reviews with 4.5+ average
  - **Measurement:** App Store Connect analytics

- **Feature Feedback:** Net Promoter Score (NPS) for new features
  - **Target:** NPS >50 (promoters > detractors)
  - **Measurement:** In-app survey after feature use (optional, non-intrusive)

- **Support Tickets:** <5% increase in support volume despite feature expansion
  - **Measurement:** Support ticket categorization by feature

**User Feedback Themes (Qualitative Analysis):**

- Monitor reviews and feedback for:
  - Export format requests (e.g., "Need Excel export")
  - Document scanner usability issues (e.g., "Auto-capture too sensitive")
  - Performance complaints (e.g., "Batch processing slow")
  - Privacy concerns (e.g., "Where is face data stored?")

### Instrumentation Plan

#### Events to Track

**Core Events (Existing):**
- `detection_completed` (category, confidence, framework)
- `result_saved` (category)
- `app_launch`, `app_foreground`, `app_background`

**New Events (Phase 1):**
- `export_started` (category, format)
- `export_completed` (category, format, duration_ms)
- `export_failed` (category, format, error_code)
- `search_query` (query_length, results_count)
- `filter_applied` (filter_type, filter_value)
- `timeline_viewed` (results_count)
- `document_mode_enabled`
- `document_auto_capture` (success: true/false)
- `document_manual_capture`
- `widget_viewed` (widget_family)
- `widget_tapped` (result_category)

**New Events (Phase 2):**
- `face_detection_completed` (face_count, avg_confidence)
- `batch_started` (image_count, category)
- `batch_progress` (completed_count, total_count)
- `batch_completed` (image_count, duration_ms, failures_count)
- `batch_cancelled` (completed_count, total_count)
- `shortcut_invoked` (action_name, source)
- `threshold_changed` (category, old_value, new_value)

**New Events (Phase 3):**
- `comparison_mode_opened` (category)
- `comparison_metrics_viewed` (metric_type)
- `pose_estimation_completed` (pose_count, avg_confidence)
- `custom_model_imported` (model_size_mb, success: true/false)
- `custom_model_selected` (model_name)
- `benchmarking_enabled`
- `benchmark_viewed` (framework, metric_type)

#### Data to Collect

**User Properties:**
- `install_date` (cohort analysis)
- `device_model` (performance segmentation)
- `iOS_version` (compatibility tracking)
- `features_used` (array of feature flags)
- `preferred_detection_category` (most-used category)

**Event Properties:**
- `timestamp` (ISO 8601)
- `session_id` (UUID per session)
- `user_id` (anonymized, hashed device ID)
- `app_version` (semantic version)

**Performance Metrics (If Benchmarking Enabled):**
- `inference_time_ms`
- `memory_usage_mb`
- `fps` (real-time only)

#### Analytics Tools

**Primary Tool:** Firebase Analytics (recommended)
- Free tier supports most needs
- Integrates with Crashlytics for error tracking
- BigQuery export for advanced analysis

**Alternative:** Apple App Analytics
- Built-in, privacy-focused
- Limited custom events
- Good for basic metrics (DAU, sessions, retention)

**Custom Dashboard (Optional):**
- Build internal analytics dashboard for real-time monitoring
- Use Firebase or custom backend

#### Privacy Compliance

- **No PII Collection:** Do not track user names, emails, locations (unless explicitly opted in)
- **Anonymized IDs:** Use hashed device IDs or UUID (not IDFA without consent)
- **Opt-Out:** Provide "Disable Analytics" toggle in Settings (respect user choice)
- **Privacy Policy:** Update to disclose analytics collection and usage

---

## Launch and Rollout Strategy

### Launch Criteria (Phase 1 MVP)

**Must-Have Gates:**

1. **Feature Completeness:**
   - [ ] Export functionality works for all 5 detection categories
   - [ ] Timeline view with search/filter operational
   - [ ] Document scanner mode achieves >85% auto-capture success rate
   - [ ] Widget (Small + Medium) displays correctly on iOS 18.5 and 19.0

2. **Quality Assurance:**
   - [ ] Zero crash bugs (crash-free rate >99.9% in TestFlight)
   - [ ] All critical user flows tested (camera, detection, export, timeline)
   - [ ] Accessibility audit passed (VoiceOver, Dynamic Type, color contrast)
   - [ ] Performance benchmarks met (timeline loads <1s, export <3s)

3. **Legal and Privacy:**
   - [ ] Privacy policy updated and reviewed by legal team
   - [ ] App Store privacy nutrition label completed
   - [ ] No biometric data storage (face detection detection-only, if Phase 2)

4. **Documentation:**
   - [ ] In-app onboarding for new features (tooltips, guides)
   - [ ] App Store description and screenshots updated
   - [ ] Support docs published (FAQs for export, document scanner)

5. **Analytics Instrumentation:**
   - [ ] All Phase 1 events tracked and validated (test with Firebase DebugView)
   - [ ] Dashboard configured for launch metrics

**Should-Have (Nice-to-Have Before Launch):**
- [ ] 100+ beta testers on TestFlight with >4.5 avg rating
- [ ] At least 50 user feedback submissions reviewed
- [ ] Performance testing on iPhone 14, 15, 16 (all pass)

**Won't Block Launch:**
- Minor UI polish (can be addressed in point releases)
- Phase 2/3 features (intentionally deferred)
- Localization (English-only for MVP)

---

### Rollout Approach

#### Phased Rollout Plan

**Week 1: Internal Beta**
- Release to internal team (10-15 users)
- Focus: Smoke testing, critical bugs
- Daily check-ins for feedback

**Week 2-3: External Beta (TestFlight)**
- Invite 100-200 external testers (target personas: Emma, Marcus, Priya, David)
- Focus: Feature usability, export formats, document scanner accuracy
- Collect feedback via TestFlight reviews and in-app survey
- Fix high-priority bugs, iterate on UX

**Week 4: Staged App Store Release**
- **Day 1-3:** 10% rollout (gradual release via App Store Connect)
  - Monitor crash rate, export errors, widget issues
  - Pause rollout if crash rate >1%
- **Day 4-7:** 50% rollout (if metrics healthy)
  - Monitor engagement metrics (DAU, export usage, timeline views)
- **Day 8-10:** 100% rollout (full availability)

**Post-Launch (Week 5+):**
- Monitor analytics dashboard daily for first 2 weeks
- Respond to App Store reviews within 48 hours
- Hotfix releases as needed (target <1 week turnaround for critical bugs)

#### Feature Flags

**Use Feature Flags for:**
- **Document Scanner Mode:** Toggle on/off remotely (mitigate if accuracy issues reported)
- **Widget:** Disable widget timeline updates if performance issues detected
- **Confidence Thresholds:** Revert to fixed thresholds if user confusion observed

**Tool:** Firebase Remote Config or custom flag system in AppSettings

#### A/B Testing (Optional)

**Potential Tests:**
- **Export Default Format:** Test JSON vs. CSV as default (measure which has higher completion rate)
- **Timeline Grouping:** Test date grouping (Today/Yesterday/Older) vs. flat list
- **Onboarding:** Test tooltip-based vs. full-screen onboarding for new features

**Tool:** Firebase A/B Testing or manual flag-based segmentation

---

### Communication Plan

#### User Notifications

**In-App Announcements:**
- "What's New" sheet on first launch after update
  - Highlights: Export, Timeline Search, Document Scanner, Widget
  - Screenshots/animations for each feature
  - Dismissible (don't block app use)

**Push Notifications (Optional, Opt-In):**
- "Try the new Document Scanner!" (1 week after install if not used)
- "You've saved 50 results! Export them now." (engagement prompt)

**Widget Promotion:**
- In-app prompt: "Add APUS widget to your home screen" (with instructions)

#### App Store Listing

**What's New (Release Notes):**

```
Version 2.0 - Major Feature Update

NEW FEATURES:
✨ Export Results - Save detections as JSON, CSV, PDF, or text
🔍 Timeline & Search - Find past results with powerful search and filters
📄 Document Scanner - Auto-capture and digitize documents with OCR
🏠 Home Screen Widget - View latest results without opening the app

IMPROVEMENTS:
- Faster performance across all detection modes
- Improved accessibility with VoiceOver support
- Bug fixes and stability improvements

We'd love your feedback! Rate us on the App Store.
```

**App Description Update:**
- Add bullet points for new features
- Update screenshots to showcase timeline, export, document scanner
- Emphasize productivity and workflow integration

#### Support Materials

**Help Center / FAQs:**
- "How to export detection results"
- "Using Document Scanner mode"
- "Searching and filtering your history"
- "Setting up APUS widgets"

**In-App Tips:**
- Contextual tooltips (e.g., "Tap export icon to save results" on first result view)
- Settings descriptions (explain confidence thresholds, document auto-capture delay)

#### Developer Community (Phase 3)

**For Custom Model Import Feature:**
- Blog post: "Importing Custom Core ML Models into APUS"
- GitHub example: Sample YOLO model conversion script
- Twitter/LinkedIn announcement targeting ML researchers

---

### Monitoring Plan

#### Key Metrics to Watch Post-Launch

**Week 1-2 (Critical Period):**

**Daily Monitoring:**
- Crash-free rate (target >99.5%)
- Export success rate (target >98%)
- Document scanner usage rate (target >20% of new users try it)
- Widget view count (target 1000+ impressions/day)

**Real-Time Alerts (via Firebase or custom):**
- Crash rate exceeds 1% → Page on-call engineer
- Export failure rate exceeds 5% → Investigate immediately
- Widget update failures exceed 10% → Check App Group data sync

**Weekly Review:**
- DAU trend (compare to baseline)
- Feature adoption rates (export, timeline, document scanner, widget)
- App Store reviews and ratings (respond to negative reviews)
- Support ticket volume (categorize by feature)

#### Launch Dashboards

**Executive Dashboard (Weekly):**
- DAU, WAU, MAU trends
- Feature adoption percentages
- App Store rating and review count
- Revenue impact (if premium features later)

**Engineering Dashboard (Daily):**
- Crash-free rate by device model and iOS version
- Export failure rate by format
- Document scanner auto-capture success rate
- Widget timeline update latency (p50, p95, p99)
- Batch processing completion rate

**Product Dashboard (Daily):**
- Top search queries (identify user intent)
- Most exported categories (OCR, Object Detection, etc.)
- Document scanner usage by time of day (optimize auto-capture settings)
- Confidence threshold adjustments (track median values per category)

#### Alert Thresholds

- **Critical (Immediate Action):** Crash rate >1%, Export failure >10%, Widget not updating >50% of time
- **High (4-hour Response):** DAU drops >20%, Export failure >5%, Document scanner usage <10%
- **Medium (24-hour Response):** App Store rating drops below 4.0, Support tickets increase >50%

---

### Rollback Plan

#### Criteria for Rollback

**Trigger Rollback If:**
1. Crash-free rate drops below 98% for 24 hours
2. Export failure rate exceeds 20% for any format
3. Critical privacy issue discovered (e.g., unintended data leakage)
4. App Store emergency takedown request (legal/privacy violation)

#### Rollback Process

**Option 1: Feature Flag Disable (Preferred)**
- Use Firebase Remote Config to disable problematic feature
- Push config update within 1 hour
- No app update required (instant fix)

**Option 2: Hotfix Release (If Feature Flag Insufficient)**
- Create hotfix branch from last stable release
- Remove problematic feature code
- Expedited QA (smoke tests only, 2-4 hours)
- Submit to App Store with "Critical Bug Fix" priority review request
- Rollout: 100% immediately (no staged rollout for hotfixes)

**Option 3: Revert to Previous App Version (Nuclear Option)**
- Only if hotfix cannot be prepared within 24 hours
- Submit previous stable version (e.g., v1.9) to App Store
- Users on v2.0 must update to downgraded v1.9.1
- Communicate clearly in release notes: "Temporary rollback due to critical issue"

#### Post-Rollback Actions

1. **Root Cause Analysis (RCA):**
   - Conduct RCA within 48 hours of rollback
   - Document issue, timeline, impact, resolution steps

2. **User Communication:**
   - In-app message explaining rollback and apology
   - App Store release notes transparency: "We've temporarily disabled [feature] to fix an issue"
   - Email to beta testers (if issue was in beta)

3. **Fix and Re-Release:**
   - Prepare fix in separate branch
   - Extensive testing (QA + internal dogfooding)
   - Gradual rollout (10% → 50% → 100% over 7 days)

---

## Open Questions and Risks

### Outstanding Decisions (Require Stakeholder Input)

**OQ-1: Export Pricing Model**
- **Question:** Should export functionality be free or premium (paid feature)?
- **Options:**
  1. Free for all users (builds goodwill, drives adoption)
  2. Freemium (10 exports/month free, unlimited with subscription)
  3. One-time unlock ($4.99 IAP for unlimited exports)
- **Decision Needed By:** End of Phase 1 development (Month 2)
- **Stakeholders:** Product, Business, Engineering

**OQ-2: Cloud Sync for Results**
- **Question:** Should we add iCloud sync for detection results?
- **Current State:** All data local (privacy-first)
- **Options:**
  1. No cloud sync (maintain privacy-first stance)
  2. Optional iCloud sync (user opt-in, end-to-end encrypted)
  3. Custom cloud backend (requires infrastructure investment)
- **Decision Needed By:** Phase 2 planning (Month 4)
- **Stakeholders:** Product, Engineering, Privacy/Legal

**OQ-3: Custom Model Library/Marketplace**
- **Question:** Should we host a model library (curated custom models users can download)?
- **Considerations:**
  - Hosting costs and liability
  - Model quality and accuracy guarantees
  - Community contributions (open model marketplace)
- **Decision Needed By:** Phase 3 planning (Month 7)
- **Stakeholders:** Product, Engineering, Legal

**OQ-4: Batch Processing Limits**
- **Question:** What is the maximum batch size?
- **Current Proposal:** 50 images
- **Options:**
  1. 50 images (conservative, safe for memory)
  2. 100 images (requires aggressive memory management)
  3. Unlimited (queue-based, may take hours)
- **Decision Needed By:** Phase 2 Month 5
- **Stakeholders:** Engineering (memory testing), Product (user expectations)

**OQ-5: Widget Data Privacy**
- **Question:** Should widget show OCR text or barcode payloads (potentially sensitive)?
- **Current Proposal:** Show thumbnails + category only (no text/payloads)
- **Options:**
  1. Thumbnails + category (privacy-safe)
  2. Thumbnails + category + truncated text preview (e.g., first 20 chars)
  3. User toggle (allow sensitive data in widget, opt-in)
- **Decision Needed By:** Phase 1 Month 2
- **Stakeholders:** Product, Privacy/Legal, UX

---

### Technical Risks (From Earlier Sections, Consolidated)

**TR-1: Document Scanner Accuracy in Low Light**
- **Impact:** High (poor UX, negative reviews)
- **Probability:** Medium
- **Mitigation:** Flash toggle, contrast enhancement, extensive low-light testing
- **Owner:** Engineering Lead (Computer Vision)

**TR-2: Batch Processing Memory Crashes on iPhone 14**
- **Impact:** High (app crash)
- **Probability:** Medium
- **Mitigation:** Serial processing, autoreleasepool, memory profiling on target devices
- **Owner:** Engineering Lead (Performance)

**TR-3: Widget Timeline Update Delays**
- **Impact:** Medium (poor widget UX)
- **Probability:** Medium
- **Mitigation:** Optimize timeline generation, test on multiple iOS versions
- **Owner:** Engineering Lead (Platform Integration)

**TR-4: Custom Model Schema Validation Complexity**
- **Impact:** Low (feature may not support all models)
- **Probability:** High
- **Mitigation:** Start with YOLO-only support, document supported architectures
- **Owner:** Engineering Lead (ML)

**TR-5: Shortcuts Background Timeout**
- **Impact:** Low (Shortcuts may fail if backgrounded too long)
- **Probability:** High (iOS limitation)
- **Mitigation:** Clear messaging, optimize detection speed, graceful timeout handling
- **Owner:** Engineering Lead (Platform Integration)

---

### Assumptions (Document for Validation)

**Assumption A-1: User Demand for Export**
- **Assumption:** 50%+ of active users will use export at least once
- **Validation:** User surveys, competitive analysis (Google Lens has export)
- **Risk If Wrong:** Wasted dev effort on low-value feature

**Assumption A-2: Document Scanner Differentiator**
- **Assumption:** Document scanner mode will drive new user acquisition
- **Validation:** Market research (Office Lens has 10M+ downloads)
- **Risk If Wrong:** Feature may not drive growth; still useful for existing users

**Assumption A-3: Vision Framework Sufficient for Face Detection**
- **Assumption:** Vision APIs provide accuracy comparable to third-party SDKs
- **Validation:** Benchmark against iOS Photos app, third-party face detection apps
- **Risk If Wrong:** May need to integrate third-party SDK (e.g., Google ML Kit)

**Assumption A-4: Widgets Drive Engagement**
- **Assumption:** Users with widgets have 20%+ higher DAU
- **Validation:** Industry benchmarks (widget usage correlates with engagement)
- **Risk If Wrong:** Widgets may have low adoption; still provides platform integration value

**Assumption A-5: No Backend Required**
- **Assumption:** All features can be implemented on-device (no server needed)
- **Validation:** Architecture review confirms local processing for all features
- **Risk If Wrong:** Cloud sync or model marketplace would require backend (future scope)

---

### Future Considerations (Beyond 9-Month Roadmap)

**FC-1: Premium Subscription Tier**
- Unlimited export, cloud sync, priority support, advanced models
- Research pricing: $4.99/month or $29.99/year

**FC-2: iPad Version with Pencil Support**
- Annotation on detection overlays
- Split-view comparison mode
- Document scanner optimized for larger screen

**FC-3: macOS Catalyst Version**
- Desktop document scanning via Mac camera
- Bulk processing of large image libraries
- Integration with Mac file system

**FC-4: Collaborative Features**
- Share detection results with team (via link or AirDrop)
- Collaborative annotation (e.g., for research teams)

**FC-5: API for Third-Party Integrations**
- Allow other apps to invoke APUS detection via URL scheme or App Clips
- Export results to Zapier, IFTTT, etc.

**FC-6: Machine Learning Model Training**
- Allow users to fine-tune models with custom datasets (on-device federated learning)
- Community model sharing

**FC-7: Video Detection (Live Stream Analysis)**
- Real-time object tracking in video
- Frame-by-frame analysis export

---

## Appendices

### Appendix A: User Persona Deep Dives

*Detailed persona profiles available in internal research repository (link: docs/personas)*

**Emma (Professional Archivist):**
- Digitizes 200+ documents per month
- Exports to CSV for archival database (FileMaker Pro)
- Prefers batch workflows (15-20 documents per session)
- Uses iPad Pro + iPhone 16 Pro

**Marcus (Accessibility Advocate):**
- Uses VoiceOver daily
- Needs quick object identification for assistive use
- Voice-driven workflows (Siri Shortcuts)
- High contrast mode, large text

**Priya (Computer Vision Researcher):**
- Benchmarks 5+ ML models per month
- Exports results to Jupyter notebooks for analysis (JSON format)
- Compares Vision vs. Core ML vs. custom models
- Requires detailed performance metrics

**David (Small Business Owner):**
- Scans 50+ receipts per month
- Needs CSV export for QuickBooks import
- Values simplicity over advanced features
- Occasional barcode scanning for inventory

### Appendix B: Competitive Analysis Summary

| **Feature** | **APUS (Current)** | **APUS (Proposed)** | **Google Lens** | **Office Lens** | **Seeing AI (Microsoft)** |
|-------------|-------------------|---------------------|-----------------|-----------------|---------------------------|
| **Object Detection** | ✅ Vision + Core ML | ✅ | ✅ | ❌ | ✅ |
| **OCR** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Barcode Scanning** | ✅ | ✅ | ✅ | ❌ | ✅ |
| **Face Detection** | ❌ | ✅ (Phase 2) | ✅ | ❌ | ✅ |
| **Document Scanner** | ❌ | ✅ (Phase 1) | ❌ | ✅ | ❌ |
| **Export (JSON/CSV/PDF)** | ❌ | ✅ (Phase 1) | Partial (text only) | ✅ | ❌ |
| **Batch Processing** | ❌ | ✅ (Phase 2) | ❌ | ✅ | ❌ |
| **Widgets** | ❌ | ✅ (Phase 1) | ❌ | ❌ | ❌ |
| **Siri Shortcuts** | ❌ | ✅ (Phase 2) | Partial | ❌ | ✅ |
| **Custom Models** | ❌ | ✅ (Phase 3) | ❌ | ❌ | ❌ |
| **Pose Estimation** | ❌ | ✅ (Phase 3) | ❌ | ❌ | ❌ |

**Competitive Advantages (Post-Implementation):**
1. Breadth of ML capabilities (7 detection types vs. competitors' 2-4)
2. Custom model support (unique among consumer apps)
3. Comprehensive export formats (JSON/CSV/PDF/TXT)
4. Performance benchmarking (targets researchers/developers)

### Appendix C: Technical Architecture Diagrams

*Diagrams available in Figma/Lucidchart (link: docs/architecture-diagrams)*

**Key Diagrams:**
1. System Architecture (App + Widget + Shortcuts Extension)
2. Data Flow (Camera → Detection → Storage → Export)
3. Widget Timeline Update Sequence
4. Batch Processing Queue Architecture
5. Custom Model Import Validation Pipeline

### Appendix D: Export Format Schemas

**JSON Schema (Example - OCR Result):**

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "APUS OCR Export",
  "type": "object",
  "properties": {
    "version": { "type": "string", "const": "1.0" },
    "category": { "type": "string", "const": "OCR" },
    "timestamp": { "type": "string", "format": "date-time" },
    "detectedTexts": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "text": { "type": "string" },
          "boundingBox": {
            "type": "object",
            "properties": {
              "x": { "type": "number" },
              "y": { "type": "number" },
              "width": { "type": "number" },
              "height": { "type": "number" }
            },
            "required": ["x", "y", "width", "height"]
          },
          "confidence": { "type": "number", "minimum": 0, "maximum": 1 }
        },
        "required": ["text", "boundingBox", "confidence"]
      }
    },
    "metadata": {
      "type": "object",
      "properties": {
        "imageSize": {
          "type": "object",
          "properties": {
            "width": { "type": "number" },
            "height": { "type": "number" }
          }
        },
        "appVersion": { "type": "string" },
        "device": { "type": "string" }
      }
    }
  },
  "required": ["version", "category", "timestamp", "detectedTexts"]
}
```

**CSV Format (Example - Object Detection):**

```csv
Timestamp,Category,Object,Confidence,BoundingBox_X,BoundingBox_Y,BoundingBox_Width,BoundingBox_Height,Framework
2026-01-04T14:30:22Z,Object Detection,person,0.92,120.5,340.2,180.0,450.0,Vision
2026-01-04T14:30:22Z,Object Detection,laptop,0.87,340.0,100.0,200.0,150.0,Vision
2026-01-04T14:30:22Z,Object Detection,cup,0.76,500.0,320.0,80.0,100.0,Vision
```

### Appendix E: Privacy Policy Updates (Draft)

**New Sections to Add:**

**Face Detection:**
> APUS uses Apple's Vision framework to detect faces in images you capture. Face detection identifies the presence and location of faces but does not recognize or identify individuals. No biometric data, facial recognition templates, or personally identifiable information is stored. All face detection processing occurs on your device; no data is transmitted to external servers.

**Custom Model Import:**
> APUS allows you to import custom Core ML models (.mlpackage, .mlmodel) for advanced use cases. Imported models run in a sandboxed environment on your device with no network access. APUS does not validate or guarantee the accuracy or safety of custom models. You are responsible for ensuring imported models comply with applicable laws and do not violate third-party intellectual property rights.

**Widgets and App Groups:**
> APUS widgets access detection results stored in a shared app container (App Group) to display recent detections on your home screen. Widget data is stored locally on your device and not transmitted to external servers. You can remove widgets at any time via iOS home screen settings.

**Analytics:**
> APUS collects anonymized usage data to improve app performance and user experience. This includes feature usage counts, detection performance metrics, and error reports. No personally identifiable information (PII) is collected. You may disable analytics in Settings > Privacy > Analytics.

### Appendix F: Testing Checklist (Phase 1 MVP)

**Unit Tests (Target 80%+ Coverage):**
- [ ] Export Service: JSON/CSV/TXT/PDF generation for all categories
- [ ] Search/Filter: Query parsing, result filtering, date range filtering
- [ ] Document Scanner: Rectangle detection, stability algorithm, perspective correction
- [ ] Widget Timeline: Timeline provider, snapshot generation, data sync

**Integration Tests:**
- [ ] Export → Share Sheet → Files app save
- [ ] Search → Filter → Result display
- [ ] Document auto-capture → OCR → Result save
- [ ] Widget update → App Group data sync → Widget display

**UI Tests (Critical Flows):**
- [ ] Camera → Document Mode → Auto-capture → Preview → Save
- [ ] Results → Timeline → Search → Tap result → Export → Share
- [ ] Settings → Confidence Threshold → Adjust → Capture → Verify filtered results
- [ ] Home Screen → Widget → Tap → App opens to correct result

**Accessibility Tests:**
- [ ] VoiceOver reads all UI elements correctly
- [ ] Dynamic Type scales text without truncation
- [ ] Color contrast meets WCAG AA (4.5:1 minimum)
- [ ] Keyboard navigation (external keyboard on iPad)

**Performance Tests:**
- [ ] Timeline loads 100 results in <1s (iPhone 15)
- [ ] Export completes in <3s for typical result
- [ ] Document auto-capture triggers within 1s of stability
- [ ] Widget updates within 5s of new result

**Device Compatibility:**
- [ ] iPhone 14 (A15 chip, 6GB RAM)
- [ ] iPhone 15 (A16 chip, 6GB RAM)
- [ ] iPhone 16 Pro (A18 chip, 8GB RAM)
- [ ] iOS 18.5, 18.6, 19.0 beta

**Edge Case Tests:**
- [ ] Export with no results (empty state)
- [ ] Search with no matches (empty state)
- [ ] Document scanner with no rectangle detected (manual fallback)
- [ ] Widget with no data (placeholder state)
- [ ] Export with special characters (emoji, unicode)
- [ ] Batch processing with failed images (error report)

---

## Document Revision History

| **Version** | **Date** | **Author** | **Changes** |
|-------------|----------|------------|-------------|
| 0.1 | 2026-01-04 | Product Team | Initial draft with executive summary and user personas |
| 0.5 | 2026-01-04 | Engineering Team | Added technical specifications and architecture details |
| 1.0 | 2026-01-04 | Product & Engineering | Final draft for stakeholder review |

---

## Sign-Off and Approvals

**Reviewed By:**
- [ ] Product Manager: ___________________________ Date: ___________
- [ ] Engineering Lead: ___________________________ Date: ___________
- [ ] UX/Design Lead: ___________________________ Date: ___________
- [ ] QA Lead: ___________________________ Date: ___________
- [ ] Privacy/Legal: ___________________________ Date: ___________

**Approved for Development:**
- [ ] VP of Product: ___________________________ Date: ___________
- [ ] VP of Engineering: ___________________________ Date: ___________

---

**Next Steps:**
1. Schedule PRD review meeting with stakeholders (target: Week of Jan 6, 2026)
2. Finalize Phase 1 scope and timeline (Engineering Lead + Product Manager)
3. Create JIRA epics and stories for Phase 1 features
4. Kick off development (target start: Jan 13, 2026)

**Contact:**
- Product Questions: [product@apus.app](mailto:product@apus.app)
- Technical Questions: [engineering@apus.app](mailto:engineering@apus.app)
- Document Feedback: [prd-feedback@apus.app](mailto:prd-feedback@apus.app)

---

**End of Document**
