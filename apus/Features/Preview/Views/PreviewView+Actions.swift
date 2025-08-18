//
//  PreviewView+Actions.swift
//  apus
//
//  Created by Rovo Dev on 5/8/2025.
//

import SwiftUI
import Photos
import Vision

// MARK: - PreviewView Action Methods Extension
extension PreviewView {

    // MARK: - Classification Actions
    func toggleClassification() {
        guard let image = processingImage else { return }

        if showingClassificationResults {
            showingClassificationResults = false
            classificationResults = []
        } else {
            if hasClassificationResults {
                classificationResults = cachedClassificationResults
                showingClassificationResults = true
            } else {
                performClassification(on: image)
            }
        }
    }

    func performClassification(on image: UIImage) {
        isClassifying = true

        imageClassificationManager.classifyImage(image) { [self] result in
            DispatchQueue.main.async {
                self.isClassifying = false

                switch result {
                case .success(let results):
                    self.classificationResults = results
                    self.cachedClassificationResults = results
                    self.hasClassificationResults = true
                    self.showingClassificationResults = true

                    // Save to results manager
                    self.detectionResultsManager.saveClassificationResult(
                        classificationResults: results,
                        image: image
                    )

                case .failure(let error):
                    self.showAlert(message: "Classification failed: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Contour Detection Actions
    func toggleContours() {
        guard let image = processingImage else { return }

        if showingContours {
            showingContours = false
            detectedContours = []
        } else {
            if hasDetectedContours {
                detectedContours = cachedContours
                showingContours = true
            } else {
                performContourDetection(on: image)
            }
        }
    }

    func performContourDetection(on image: UIImage) {
        isDetectingContours = true

        contourDetectionManager.detectContours(in: image) { [self] result in
            DispatchQueue.main.async {
                self.isDetectingContours = false

                switch result {
                case .success(let contours):
                    self.detectedContours = contours
                    self.cachedContours = contours
                    self.hasDetectedContours = true
                    self.showingContours = true

                    // Save to results manager
                    self.detectionResultsManager.saveContourDetectionResult(
                        detectedContours: contours,
                        image: image
                    )

                case .failure(let error):
                    self.showAlert(message: "Contour detection failed: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Object Detection Actions
    func toggleObjects() {
        guard let image = processingImage else { return }

        if showingObjects {
            showingObjects = false
            detectedObjects = []
        } else {
            if hasDetectedObjects {
                detectedObjects = cachedObjects
                showingObjects = true
            } else {
                performObjectDetection(on: image)
            }
        }
    }

    func performObjectDetection(on image: UIImage) {
        isDetectingObjects = true

        unifiedObjectDetectionManager.detectObjects(in: image) { [self] result in
            DispatchQueue.main.async {
                self.isDetectingObjects = false

                switch result {
                case .success(let objects):
                    self.detectedObjects = objects
                    self.cachedObjects = objects
                    self.hasDetectedObjects = true
                    self.showingObjects = true

                    // Save to results manager
                    self.detectionResultsManager.saveObjectDetectionResult(
                        detectedObjects: objects,
                        image: image
                    )

                case .failure(let error):
                    self.showAlert(message: "Object detection failed: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Text Recognition Actions
    func toggleTextRecognition() {
        guard let image = processingImage else { return }

        if showingTexts {
            showingTexts = false
            detectedTexts = []
        } else {
            if hasDetectedTexts {
                detectedTexts = cachedTexts
                showingTexts = true
            } else {
                performTextRecognition(on: image)
            }
        }
    }

    func performTextRecognition(on image: UIImage) {
        isDetectingTexts = true

        textRecognitionManager.detectText(in: image) { [self] result in
            DispatchQueue.main.async {
                self.isDetectingTexts = false

                switch result {
                case .success(let texts):
                    self.detectedTexts = texts
                    self.cachedTexts = texts
                    self.hasDetectedTexts = true
                    self.showingTexts = true

                    // Save to results manager
                    self.detectionResultsManager.saveOCRResult(
                        detectedTexts: texts,
                        image: image
                    )

                case .failure(let error):
                    self.showAlert(message: "Text recognition failed: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Barcode Detection Actions
    func toggleBarcodes() {
        guard let image = processingImage else { return }

        if showingBarcodes {
            showingBarcodes = false
            detectedBarcodes = []
        } else {
            if hasDetectedBarcodes {
                detectedBarcodes = cachedBarcodes
                showingBarcodes = true
            } else {
                performBarcodeDetection(on: image)
            }
        }
    }

    func performBarcodeDetection(on image: UIImage) {
        isDetectingBarcodes = true

        barcodeDetectionManager.detectBarcodes(on: image) { [self] (barcodes: [VNBarcodeObservation]) in
            DispatchQueue.main.async {
                self.isDetectingBarcodes = false

                self.detectedBarcodes = barcodes
                self.cachedBarcodes = barcodes
                self.hasDetectedBarcodes = true
                self.showingBarcodes = true

                // Save to results manager
                self.detectionResultsManager.saveBarcodeResult(
                    detectedBarcodes: barcodes,
                    image: image
                )
            }
        }
    }

    // Combined OCR + Classification pipeline removed.
    // OCR is text detection + text recognition handled by VisionTextRecognitionManager.
    // Image classification is a separate workflow via ImageClassificationManager.

    // MARK: - Helper Methods
    func showAlert(message: String) {
        alertMessage = message
        showingAlert = true
    }

    func saveToPhotoLibrary() {
        guard let image = capturedImage else { return }

        hapticService.actionFeedback()

        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                if status == .authorized {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    self.isSaved = true
                    self.hapticService.success()
                    self.showAlert(message: "Image saved to Photos")
                } else {
                    self.hapticService.error()
                    self.showAlert(message: "Permission denied to save to Photos")
                }
            }
        }
    }
}
