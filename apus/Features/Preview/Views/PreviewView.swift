
//
//  PreviewView.swift
//  apus
//
//  Created by Chan Wai Chan on 21/7/2025.
//

import SwiftUI
import Photos

struct PreviewView: View {
    @Binding var capturedImage: UIImage?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSaved = false
    @State private var classificationResults: [ClassificationResult] = []
    @State private var showingClassificationResults = false
    @State private var isClassifying = false
    @State private var cachedClassificationResults: [ClassificationResult] = []
    @State private var hasClassificationResults = false
    @State private var showingHistory = false
    @State private var detectedContours: [DetectedContour] = []
    @State private var showingContours = false
    @State private var isDetectingContours = false
    @State private var cachedContours: [DetectedContour] = []
    @State private var hasDetectedContours = false
    @State private var detectedObjects: [DetectedObject] = []
    @State private var showingObjects = false
    @State private var isDetectingObjects = false
    @State private var cachedObjects: [DetectedObject] = []
    @State private var hasDetectedObjects = false
    @State private var detectedTexts: [DetectedText] = []
    @State private var showingTexts = false
    @State private var isDetectingTexts = false
    @State private var cachedTexts: [DetectedText] = []
    @State private var hasDetectedTexts = false
    
    // Computed property for normalized display image
    private var displayImage: UIImage? {
        capturedImage?.preparedForDisplay()
    }
    
    // Computed property for processing image
    private var processingImage: UIImage? {
        capturedImage?.preparedForProcessing()
    }
    
    @Injected private var imageClassificationManager: ImageClassificationProtocol
    @Injected private var hapticService: HapticServiceProtocol
    @Injected private var contourDetectionManager: ContourDetectionProtocol
    @Injected private var unifiedObjectDetectionManager: UnifiedObjectDetectionProtocol
    @Injected private var textRecognitionManager: VisionTextRecognitionProtocol
    @Injected private var detectionResultsManager: DetectionResultsManager

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Image display area with zoom/pan functionality - fixed height
                ZStack {
                    if let image = displayImage {
                        ZoomableImageView(image: image)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black)
                            .overlay(
                                // Overlays for detection results
                                Group {
                                    GeometryReader { geometry in
                                        ZStack {
                                            // Contour detection overlay
                                            if showingContours && !detectedContours.isEmpty {
                                                ContourOverlayView(
                                                    contours: detectedContours,
                                                    imageSize: image.size,
                                                    displaySize: geometry.size
                                                )
                                            }
                                            
                                            // Object detection overlay
                                            if showingObjects && !detectedObjects.isEmpty {
                                                UnifiedObjectDetectionOverlay(
                                                    detections: detectedObjects,
                                                    imageSize: image.size,
                                                    displaySize: geometry.size
                                                )
                                            }
                                            
                                            // Text recognition overlay
                                            if showingTexts && !detectedTexts.isEmpty {
                                                VisionTextRecognitionOverlay(
                                                    detectedTexts: detectedTexts,
                                                    imageSize: image.size,
                                                    displaySize: geometry.size
                                                )
                                            }
                                        }
                                    }
                                }
                            )
                    } else {
                        Rectangle()
                            .fill(Color.black)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    // Classification results overlay
                    if showingClassificationResults && !classificationResults.isEmpty {
                        VStack {
                            Spacer()
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Classification Results:")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                ForEach(classificationResults.prefix(3), id: \.identifier) { result in
                                    HStack {
                                        Text(result.identifier.capitalized)
                                            .font(.body)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("\(Int(result.confidence * 100))%")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                    }
                }
                .frame(height: geometry.size.height - 120) // Reserve space for buttons
                
                // Action buttons in two rows - fixed height
                VStack(spacing: 12) {
                    // Top row: Analysis buttons
                    VStack(spacing: 8) {
                        // First row: OCR + Classification and Object Detection
                        HStack(spacing: 12) {
                        // OCR + Classify button
                        Button(action: {
                            hapticService.actionFeedback()
                            performOCRAndClassification()
                        }) {
                            HStack(spacing: 4) {
                                if isDetectingTexts || isClassifying {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.7)
                                    Text(isDetectingTexts ? "Reading Text..." : "Classifying Text...")
                                        .font(.caption)
                                } else {
                                    Image(systemName: "textformat.abc")
                                        .font(.caption)
                                    Text("OCR + Classify")
                                        .font(.caption)
                                }
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.purple)
                            .clipShape(Capsule())
                        }
                        .disabled(isDetectingTexts || isClassifying)
                        
                        // Object detection button
                        Button(action: {
                            hapticService.actionFeedback()
                            toggleObjects()
                        }) {
                            HStack(spacing: 4) {
                                if isDetectingObjects {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.7)
                                    Text("Detecting...")
                                        .font(.caption)
                                } else {
                                    Image(systemName: showingObjects ? "viewfinder.circle.fill" : "viewfinder.circle")
                                        .font(.caption)
                                    Text(getObjectButtonText())
                                        .font(.caption)
                                }
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(getObjectButtonColor())
                            .clipShape(Capsule())
                        }
                        .disabled(isDetectingObjects)
                        }
                        
                        // Second row: Contour Detection
                        HStack(spacing: 12) {
                        // Contour detection button
                        Button(action: {
                            hapticService.actionFeedback()
                            toggleContours()
                        }) {
                            HStack(spacing: 4) {
                                if isDetectingContours {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.7)
                                    Text("Detecting...")
                                        .font(.caption)
                                } else {
                                    Image(systemName: showingContours ? "eye.slash" : "eye")
                                        .font(.caption)
                                    Text(getContourButtonText())
                                        .font(.caption)
                                }
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(getContourButtonColor())
                            .clipShape(Capsule())
                        }
                        .disabled(isDetectingContours)
                        
                        Spacer() // Fill remaining space
                        }
                    }
                    
                    // Bottom row: Action buttons
                    HStack(spacing: 20) {
                        // Discard button
                        Button(action: {
                            hapticService.buttonTap()
                            clearAllCaches()
                            capturedImage = nil
                        }) {
                            Text("Discard")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.black.opacity(0.7))
                                .clipShape(Capsule())
                        }
                        
                        // Save button
                        Button(action: {
                            hapticService.actionFeedback()
                            if let image = capturedImage {
                                saveImageToPhotos(image)
                            }
                        }) {
                            Text("Save")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .clipShape(Capsule())
                        }
                    }
                }
                .frame(height: 120) // Fixed height for button area
                .padding(.horizontal, 20)
                .background(Color(.systemBackground))
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    hapticService.buttonTap()
                    showingHistory = true
                }) {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.primary)
                }
            }
        }
        .alert("Photo", isPresented: $showingAlert) {
            Button("OK") {
                if isSaved {
                    capturedImage = nil
                }
            }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingHistory) {
            ResultsDashboardView()
        }
        .onChange(of: capturedImage) { oldValue, newValue in
            // Clear all caches when image changes
            if oldValue != newValue {
                clearAllCaches()
            }
        }
    }

    private func classifyImage() {
        guard let image = processingImage else { return }
        
        isClassifying = true
        showingClassificationResults = false
        
        imageClassificationManager.classifyImage(image) { result in
            DispatchQueue.main.async {
                self.isClassifying = false
                
                switch result {
                case .success(let results):
                    self.classificationResults = results
                    self.cachedClassificationResults = results // Cache the results
                    self.hasClassificationResults = true
                    
                    // Save results to storage
                    if let image = self.capturedImage {
                        self.detectionResultsManager.saveClassificationResult(classificationResults: results, image: image)
                    }
                    
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.showingClassificationResults = true
                    }
                    self.hapticService.success() // Success haptic feedback
                    
                    // Save to history if we have results and an image
                    if !results.isEmpty, let originalImage = self.capturedImage {
                        // Save to consolidated results system
                        detectionResultsManager.saveClassificationResult(classificationResults: results, image: originalImage)
                    }
                    
                case .failure(let error):
                    self.alertMessage = "Classification failed: \(error.localizedDescription)"
                    self.showingAlert = true
                    self.hapticService.error() // Error haptic feedback
                }
            }
        }
    }
    
    private func toggleContours() {
        guard let _ = capturedImage else { return }
        
        if showingContours {
            // Hide contours - keep them cached
            withAnimation(.easeInOut(duration: 0.3)) {
                showingContours = false
            }
            hapticService.buttonTap()
            return
        }
        
        // Check if we have cached contours for quick show
        if hasDetectedContours && !cachedContours.isEmpty {
            // Use cached contours for instant display
            detectedContours = cachedContours
            withAnimation(.easeInOut(duration: 0.3)) {
                showingContours = true
            }
            hapticService.buttonTap()
            return
        }
        
        // No cached contours - perform detection
        detectContours()
    }
    
    private func detectContours() {
        guard let image = processingImage else { return }
        
        isDetectingContours = true
        
        contourDetectionManager.detectContours(in: image) { result in
            DispatchQueue.main.async {
                self.isDetectingContours = false
                
                switch result {
                case .success(let contours):
                    self.detectedContours = contours
                    self.cachedContours = contours // Cache the results
                    self.hasDetectedContours = true
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.showingContours = true
                    }
                    self.hapticService.success() // Success haptic feedback
                    
                case .failure(let error):
                    self.alertMessage = "Contour detection failed: \(error.localizedDescription)"
                    self.showingAlert = true
                    self.hapticService.error() // Error haptic feedback
                }
            }
        }
    }
    
    private func getContourButtonText() -> String {
        if showingContours {
            return "Hide Contours"
        } else if hasDetectedContours {
            return "Show Contours"
        } else {
            return "Detect Contours"
        }
    }
    
    private func getContourButtonColor() -> Color {
        if showingContours {
            return .orange  // Orange when showing
        } else if hasDetectedContours {
            return .blue    // Blue when cached (quick show)
        } else {
            return .green   // Green when needs detection
        }
    }
    
    private func toggleObjects() {
        guard let _ = capturedImage else { return }
        
        if showingObjects {
            // Hide objects - keep them cached
            withAnimation(.easeInOut(duration: 0.3)) {
                showingObjects = false
            }
            hapticService.buttonTap()
            return
        }
        
        // Check if we have cached objects for quick show
        if hasDetectedObjects && !cachedObjects.isEmpty {
            // Use cached objects for instant display
            detectedObjects = cachedObjects
            withAnimation(.easeInOut(duration: 0.3)) {
                showingObjects = true
            }
            hapticService.buttonTap()
            return
        }
        
        // No cached objects - perform detection
        detectObjects()
    }
    
    private func detectObjects() {
        guard let image = processingImage else { return }
        
        isDetectingObjects = true
        
        unifiedObjectDetectionManager.detectObjects(in: image) { result in
            DispatchQueue.main.async {
                self.isDetectingObjects = false
                
                switch result {
                case .success(let objects):
                    self.detectedObjects = objects
                    self.cachedObjects = objects // Cache the results
                    self.hasDetectedObjects = true
                    
                    // Save results to storage
                    if let image = self.capturedImage {
                        self.detectionResultsManager.saveObjectDetectionResult(detectedObjects: objects, image: image)
                    }
                    
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.showingObjects = true
                    }
                    self.hapticService.success() // Success haptic feedback
                    
                case .failure(let error):
                    self.alertMessage = "Object detection failed: \(error.localizedDescription)"
                    self.showingAlert = true
                    self.hapticService.error() // Error haptic feedback
                }
            }
        }
    }
    
    private func getObjectButtonText() -> String {
        if showingObjects {
            return "Hide Objects"
        } else if hasDetectedObjects {
            return "Show Objects"
        } else {
            return "Detect Objects"
        }
    }
    
    private func getObjectButtonColor() -> Color {
        if showingObjects {
            return .red      // Red when showing
        } else if hasDetectedObjects {
            return .blue     // Blue when cached (quick show)
        } else {
            return .teal     // Teal when needs detection
        }
    }
    
    private func getTextRecognitionButtonText() -> String {
        if showingTexts {
            return "Hide Text"
        } else if hasDetectedTexts {
            return "Show Text"
        } else {
            return "Detect Text"
        }
    }
    
    private func getTextRecognitionButtonColor() -> Color {
        if showingTexts {
            return .red      // Red when showing
        } else if hasDetectedTexts {
            return .blue     // Blue when cached (quick show)
        } else {
            return .purple   // Purple for text recognition
        }
    }
    
    private func clearContourCache() {
        cachedContours = []
        detectedContours = []
        hasDetectedContours = false
        showingContours = false
    }
    
    private func clearObjectCache() {
        cachedObjects = []
        detectedObjects = []
        hasDetectedObjects = false
        showingObjects = false
    }
    
    private func clearTextCache() {
        cachedTexts = []
        detectedTexts = []
        hasDetectedTexts = false
        showingTexts = false
    }
    
    private func toggleClassification() {
        guard let _ = capturedImage else { return }
        
        if showingClassificationResults {
            // Hide classification results - keep them cached
            withAnimation(.easeInOut(duration: 0.3)) {
                showingClassificationResults = false
            }
            hapticService.buttonTap()
            return
        }
        
        // Check if we have cached results for quick show
        if hasClassificationResults && !cachedClassificationResults.isEmpty {
            // Use cached results for instant display
            classificationResults = cachedClassificationResults
            withAnimation(.easeInOut(duration: 0.3)) {
                showingClassificationResults = true
            }
            hapticService.buttonTap()
            return
        }
        
        // No cached results - perform classification
        classifyImage()
    }
    
    private func toggleTextRecognition() {
        guard let _ = capturedImage else { return }
        
        if showingTexts {
            // Hide text recognition results - keep them cached
            withAnimation(.easeInOut(duration: 0.3)) {
                showingTexts = false
            }
            hapticService.buttonTap()
            return
        }
        
        // Check if we have cached text results for quick show
        if hasDetectedTexts && !cachedTexts.isEmpty {
            // Use cached texts for instant display
            detectedTexts = cachedTexts
            withAnimation(.easeInOut(duration: 0.3)) {
                showingTexts = true
            }
            hapticService.buttonTap()
            return
        }
        
        // No cached texts - perform text recognition
        detectText()
    }
    
    private func detectText() {
        guard let image = processingImage else { return }
        
        isDetectingTexts = true
        
        textRecognitionManager.detectText(in: image) { result in
            DispatchQueue.main.async {
                self.isDetectingTexts = false
                
                switch result {
                case .success(let texts):
                    self.detectedTexts = texts
                    self.cachedTexts = texts // Cache the results
                    self.hasDetectedTexts = true
                    
                    // Save results to storage
                    if let image = self.capturedImage {
                        self.detectionResultsManager.saveOCRResult(detectedTexts: texts, image: image)
                    }
                    
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.showingTexts = true
                    }
                    self.hapticService.success() // Success haptic feedback
                    
                case .failure(let error):
                    self.alertMessage = "Text recognition failed: \(error.localizedDescription)"
                    self.showingAlert = true
                    self.hapticService.error() // Error haptic feedback
                }
            }
        }
    }
    
    private func performOCRAndClassification() {
        guard let image = processingImage else { return }
        
        // Step 1: Perform OCR first
        isDetectingTexts = true
        
        textRecognitionManager.detectText(in: image) { result in
            DispatchQueue.main.async {
                self.isDetectingTexts = false
                
                switch result {
                case .success(let texts):
                    // Cache OCR results
                    self.detectedTexts = texts
                    self.cachedTexts = texts
                    self.hasDetectedTexts = true
                    
                    // Save OCR results to storage
                    if let image = self.capturedImage {
                        self.detectionResultsManager.saveOCRResult(detectedTexts: texts, image: image)
                    }
                    
                    // Show OCR results briefly
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.showingTexts = true
                    }
                    
                    // Step 2: Now classify the detected text content
                    self.classifyDetectedText(texts)
                    
                case .failure(let error):
                    self.alertMessage = "OCR failed: \(error.localizedDescription)"
                    self.showingAlert = true
                    self.hapticService.error()
                }
            }
        }
    }
    
    private func classifyDetectedText(_ texts: [DetectedText]) {
        // Combine all detected text into a single string for classification
        let combinedText = texts.map { $0.text }.joined(separator: " ")
        
        // Create a text-based image for classification
        // For now, we'll classify the original image but show text-aware results
        guard let image = processingImage else { return }
        
        isClassifying = true
        
        imageClassificationManager.classifyImage(image) { result in
            DispatchQueue.main.async {
                self.isClassifying = false
                
                switch result {
                case .success(let results):
                    // Enhance classification results with text context
                    let enhancedResults = self.enhanceClassificationWithText(results, detectedText: combinedText)
                    
                    self.classificationResults = enhancedResults
                    self.cachedClassificationResults = enhancedResults
                    self.hasClassificationResults = true
                    
                    // Save enhanced classification results to storage
                    if let image = self.capturedImage {
                        self.detectionResultsManager.saveClassificationResult(classificationResults: enhancedResults, image: image)
                    }
                    
                    // Hide OCR overlay and show classification results
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.showingTexts = false
                        self.showingClassificationResults = true
                    }
                    
                    self.hapticService.success()
                    
                    // Show success message with text context
                    let textSummary = texts.count > 0 ? "Found \(texts.count) text elements" : "No text detected"
                    self.alertMessage = "OCR + Classification complete!\n\(textSummary)\nTop result: \(enhancedResults.first?.identifier.capitalized ?? "Unknown")"
                    self.showingAlert = true
                    
                case .failure(let error):
                    self.alertMessage = "Classification failed: \(error.localizedDescription)"
                    self.showingAlert = true
                    self.hapticService.error()
                }
            }
        }
    }
    
    private func enhanceClassificationWithText(_ results: [ClassificationResult], detectedText: String) -> [ClassificationResult] {
        // Enhance classification results by considering detected text
        var enhancedResults = results
        
        // Add text-based classification hints
        let textLower = detectedText.lowercased()
        
        // Boost confidence for text-related classifications
        for i in 0..<enhancedResults.count {
            let identifier = enhancedResults[i].identifier.lowercased()
            
            // Boost confidence if classification matches detected text content
            if textLower.contains(identifier) || identifier.contains("text") || identifier.contains("document") {
                enhancedResults[i] = ClassificationResult(
                    identifier: enhancedResults[i].identifier + " (Text-Enhanced)",
                    confidence: min(1.0, enhancedResults[i].confidence * 1.2)
                )
            }
        }
        
        // Add text-specific classifications if significant text was found
        if !detectedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let textClassification = ClassificationResult(
                identifier: "Text Document",
                confidence: Float(min(0.95, Double(detectedText.count) / 100.0))
            )
            enhancedResults.insert(textClassification, at: 0)
        }
        
        return enhancedResults.sorted { $0.confidence > $1.confidence }
    }
    
    private func getClassificationButtonText() -> String {
        if showingClassificationResults {
            return "Hide Results"
        } else if hasClassificationResults {
            return "Show Results"
        } else {
            return "Classify"
        }
    }
    
    private func getClassificationButtonColor() -> Color {
        if showingClassificationResults {
            return .indigo   // Indigo when showing
        } else if hasClassificationResults {
            return .blue     // Blue when cached (quick show)
        } else {
            return .purple   // Purple when needs classification
        }
    }
    
    private func clearClassificationCache() {
        cachedClassificationResults = []
        classificationResults = []
        hasClassificationResults = false
        showingClassificationResults = false
    }
    
    private func clearAllCaches() {
        clearClassificationCache()
        clearContourCache()
        clearObjectCache()
        clearTextCache()
    }
    
    private func saveImageToPhotos(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetCreationRequest.creationRequestForAsset(from: image)
                }) { success, error in
                    DispatchQueue.main.async {
                        if success {
                            self.hapticService.success() // Success haptic for save
                            alertMessage = "Photo saved to gallery!"
                            isSaved = true
                        } else {
                            self.hapticService.error() // Error haptic for save failure
                            alertMessage = "Failed to save photo: \(error?.localizedDescription ?? "Unknown error")"
                            isSaved = false
                        }
                        showingAlert = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    alertMessage = "Photo library access denied"
                    isSaved = false
                    showingAlert = true
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    struct PreviewWrapper: View {
        @State var image: UIImage? = UIImage(systemName: "camera")
        var body: some View {
            NavigationView {
                PreviewView(capturedImage: $image)
            }
        }
    }
    return PreviewWrapper()
}
#endif
