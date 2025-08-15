//
//  PreviewView.swift
//  apus
//
//  Created by Chan Wai Chan on 21/7/2025.
//  Refactored by Rovo Dev on 5/8/2025.
//

import SwiftUI
import Photos

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

    // Injected dependencies
    @Injected var imageClassificationManager: ImageClassificationProtocol
    @Injected var hapticService: HapticServiceProtocol
    @Injected var contourDetectionManager: ContourDetectionProtocol
    @Injected var unifiedObjectDetectionManager: UnifiedObjectDetectionProtocol
    @Injected var textRecognitionManager: VisionTextRecognitionProtocol
    @Injected var detectionResultsManager: DetectionResultsManager

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Image display area with zoom/pan functionality
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
                }
                .frame(height: geometry.size.height * 0.6)
                .clipped()

                // Controls and results area
                VStack(spacing: 16) {
                    // Action buttons
                    actionButtonsView()
                        .padding(.horizontal)

                    // Results panel
                    if showingClassificationResults || showingHistory {
                        resultsPanelView()
                            .padding(.horizontal)
                    }

                    Spacer()

                    // Bottom controls
                    bottomControlsView()
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
                .frame(height: geometry.size.height * 0.4)
                .background(Color(.systemBackground))
            }
        }
        .navigationBarHidden(true)
        .alert("Alert", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingHistory) {
            NavigationStack(path: $historyPath) {
                ResultsDashboardView(path: $historyPath)
                    .navigationDestination(for: DetectionCategory.self) { category in
                        CategoryResultsView(category: category, resultsManager: detectionResultsManager)
                    }
            }
        }
    }
}
