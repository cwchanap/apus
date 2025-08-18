//
//  PreviewView.swift
//  apus
//
//  Created by Chan Wai Chan on 21/7/2025.
//  Refactored by Rovo Dev on 5/8/2025.
//

import SwiftUI
import Photos
import Vision

struct PreviewView: View {
    @Binding var capturedImage: UIImage?

    // State properties
    @State var showingAlert = false
    @State var alertMessage = ""
    @State var isSaved = false
    @State var classificationResults: [ClassificationResult] = []
    @State var showingClassificationResults = false
    @State var isClassifying = false
    @State var cachedClassificationResults: [ClassificationResult] = []
    @State var hasClassificationResults = false
    @State var showingHistory = false
    @State var detectedContours: [DetectedContour] = []
    @State var showingContours = false
    @State var isDetectingContours = false
    @State var cachedContours: [DetectedContour] = []
    @State var hasDetectedContours = false
    @State var detectedObjects: [DetectedObject] = []
    @State var showingObjects = false
    @State var isDetectingObjects = false
    @State var cachedObjects: [DetectedObject] = []
    @State var hasDetectedObjects = false
    @State var detectedTexts: [DetectedText] = []
    @State var showingTexts = false
    @State var isDetectingTexts = false
    @State var cachedTexts: [DetectedText] = []
    @State var hasDetectedTexts = false
    @State var historyPath: [DetectionCategory] = []
    @State private var showingActionsSheet = false
    @State var detectedBarcodes: [VNBarcodeObservation] = []
    @State var showingBarcodes = false
    @State var isDetectingBarcodes = false
    @State var cachedBarcodes: [VNBarcodeObservation] = []
    @State var hasDetectedBarcodes = false

    // Injected dependencies
    @Injected var imageClassificationManager: ImageClassificationProtocol
    @Injected var hapticService: HapticServiceProtocol
    @Injected var contourDetectionManager: ContourDetectionProtocol
    @Injected var unifiedObjectDetectionManager: UnifiedObjectDetectionProtocol
    @Injected var textRecognitionManager: VisionTextRecognitionProtocol
    @Injected var detectionResultsManager: DetectionResultsManager
    @Injected var barcodeDetectionManager: BarcodeDetectionProtocol

    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 0) {
                // Image display area with zoom/pan functionality takes most of the screen
                ZStack {
                    if let image = displayImage {
                        ZoomableImageView(image: image)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black)
                            .overlay(
                                GeometryReader { overlayGeometry in
                                    imageOverlayView(image: image, geometry: overlayGeometry)
                                }
                            )
                    } else {
                        Color.black
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    // Classification results overlay over the image
                    if showingClassificationResults && !classificationResults.isEmpty {
                        // Dim gradient behind overlay for contrast
                        VStack(spacing: 0) {
                            Spacer()
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.black.opacity(0.25),
                                    Color.black.opacity(0.12),
                                    Color.clear
                                ]),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .allowsHitTesting(false)
                        }

                        // Results overlay content
                        VStack {
                            Spacer()
                            classificationResultsOverlayView()
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .clipped()

                // Single actions button below the photo
                HStack {
                    Spacer()
                    Button(action: { showingActionsSheet = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "ellipsis.circle")
                                .font(.title2)
                            Text("Actions")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.accentColor)
                        .clipShape(Capsule())
                    }
                    Spacer()
                }
                .padding(.vertical, 12)
                .background(Color(.systemBackground).opacity(0.95))
            }
        }
        .navigationBarHidden(true)
        .alert("Alert", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        // Actions popup sheet
        .sheet(isPresented: $showingActionsSheet) {
            actionsSheetView(showSheet: $showingActionsSheet)
        }
        .sheet(isPresented: $showingHistory) {
            NavigationStack(path: $historyPath) {
                ResultsDashboardView(path: $historyPath)
                    .navigationDestination(for: DetectionCategory.self) { category in
                        CategoryResultsView(category: category)
                    }
            }
        }
    }
}
