//
//  YOLOv12CoreMLObjectDetectionManager.swift
//  apus
//
//  Wires a Core ML YOLO model into UnifiedObjectDetectionProtocol with Swift postprocessing.
//

import Foundation
import UIKit
import CoreML

final class YOLOv12CoreMLObjectDetectionManager: ObservableObject, UnifiedObjectDetectionProtocol {
    @Published var isDetecting: Bool = false
    @Published var lastDetectedObjects: [DetectedObject] = []
    let framework: ObjectDetectionFramework = .coreML

    // Config
    private let inputSize: Int = 640
    private let scoreThreshold: Float = 0.25
    private let iouThreshold: Float = 0.45
    private let maxDetections: Int = 300
    private let topK: Int = 100

    private var labels: [String] = []
    private var model: MLModel?
    private var isModelLoaded = false
    private var isModelLoading = false
    private let queue = DispatchQueue(label: "com.apus.yolo.coreml", qos: .userInitiated)

    init() {
        // Lazy load model
        loadLabels()
    }

    func preload() {
        ensureModelLoaded { _ in }
    }

    private func ensureModelLoaded(completion: @escaping (Bool) -> Void) {
        if isModelLoaded {
            completion(true)
            return
        }
        if isModelLoading {
            queue.async {
                while self.isModelLoading { usleep(50_000) }
                DispatchQueue.main.async { completion(self.isModelLoaded) }
            }
            return
        }
        isModelLoading = true
        queue.async {
            defer {
                self.isModelLoading = false
            }
            self.model = Self.loadBundledModel()
            let success = self.model != nil
            self.isModelLoaded = success
            DispatchQueue.main.async { completion(success) }
        }
    }

    static func loadBundledModel() -> MLModel? {
        // Try compiled package first (.mlmodelc), then plain .mlmodel
        let bundle = Bundle.main
        if let url = bundle.url(forResource: "yolov12s", withExtension: "mlmodelc") {
            return try? MLModel(contentsOf: url)
        }
        if let url = bundle.url(forResource: "yolov12s", withExtension: "mlmodel") {
            return try? MLModel(contentsOf: url)
        }
        // Fallback: any mlmodelc in bundle
        if let urls = bundle.urls(forResourcesWithExtension: "mlmodelc", subdirectory: nil), let first = urls.first {
            return try? MLModel(contentsOf: first)
        }
        return nil
    }

    private func loadLabels() {
        if let path = Bundle.main.path(forResource: "coco_labels", ofType: "txt"),
           let content = try? String(contentsOfFile: path, encoding: .utf8) {
            labels = content.split(separator: "\n").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        }
    }

    func detectObjects(in image: UIImage, completion: @escaping (Result<[DetectedObject], Error>) -> Void) {
        DispatchQueue.main.async { self.isDetecting = true }
        ensureModelLoaded { [weak self] isLoaded in
            guard let self else { completion(.failure(CoreMLError.modelNotLoaded)); return }
            guard isLoaded, let model = self.model else {
                DispatchQueue.main.async { self.isDetecting = false }
                completion(.failure(CoreMLError.modelNotLoaded))
                return
            }

            // Prepare input (letterbox to square input)
            guard let cgImage = image.cgImage else {
                DispatchQueue.main.async { self.isDetecting = false }
                completion(.failure(CoreMLError.invalidImage))
                return
            }

            self.queue.async {
                let (letterboxed, scale, padX, padY) = Self.letterbox(cgImage: cgImage, size: self.inputSize)
                guard let pixelBuffer = letterboxed else {
                    DispatchQueue.main.async { self.isDetecting = false }
                    completion(.failure(CoreMLError.processingFailed))
                    return
                }

                // Determine input feature name dynamically
                guard let inputName = model.modelDescription.inputDescriptionsByName.first(where: { $0.value.type == .image })?.key
                        ?? model.modelDescription.inputDescriptionsByName.keys.first else {
                    DispatchQueue.main.async { self.isDetecting = false }
                    completion(.failure(CoreMLError.processingFailed))
                    return
                }

                let provider = YOLOInputProvider(name: inputName, pixelBuffer: pixelBuffer)
                do {
                    let out = try model.prediction(from: provider)
                    let preds = Self.collectOutputMultiArrays(from: out)
                    let detections = self.decodeDetections(arrays: preds,
                                                           inputSize: self.inputSize,
                                                           origWidth: CGFloat(cgImage.width),
                                                           origHeight: CGFloat(cgImage.height),
                                                           scale: scale,
                                                           padX: padX,
                                                           padY: padY)
                    DispatchQueue.main.async {
                        self.isDetecting = false
                        self.lastDetectedObjects = detections
                        completion(.success(detections))
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.isDetecting = false
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    // swiftlint:disable large_tuple
    private static func letterbox(cgImage: CGImage, size: Int) -> (CVPixelBuffer?, CGFloat, CGFloat, CGFloat) {
        let imageWidth = CGFloat(cgImage.width)
        let imageHeight = CGFloat(cgImage.height)
        let scaleFactor = min(CGFloat(size) / imageWidth, CGFloat(size) / imageHeight)
        let newWidth = floor(imageWidth * scaleFactor)
        let newHeight = floor(imageHeight * scaleFactor)
        let padX = (CGFloat(size) - newWidth) / 2
        let padY = (CGFloat(size) - newHeight) / 2

        let attrs: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ]
        var outputPixelBuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault, size, size, kCVPixelFormatType_32BGRA, attrs as CFDictionary, &outputPixelBuffer)
        guard let pixelBuffer = outputPixelBuffer else { return (nil, scaleFactor, padX, padY) }

        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
        guard let base = CVPixelBufferGetBaseAddress(pixelBuffer) else { return (nil, scaleFactor, padX, padY) }
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.noneSkipFirst.rawValue
        guard let ctx = CGContext(
            data: base,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return (nil, scaleFactor, padX, padY)
        }
        // Fill with black
        ctx.setFillColor(UIColor.black.cgColor)
        ctx.fill(CGRect(x: 0, y: 0, width: size, height: size))
        // Draw resized image centered
        ctx.interpolationQuality = .high
        ctx.draw(cgImage, in: CGRect(x: padX, y: padY, width: newWidth, height: newHeight))
        return (pixelBuffer, scaleFactor, padX, padY)
    }
    // swiftlint:enable large_tuple

    private static func collectOutputMultiArrays(from features: MLFeatureProvider) -> [MLMultiArray] {
        var arrays: [MLMultiArray] = []
        for name in features.featureNames {
            let val = features.featureValue(for: name)
            if val?.type == .multiArray, let multiArray = val?.multiArrayValue { arrays.append(multiArray) }
        }
        return arrays
    }

    // swiftlint:disable function_parameter_count cyclomatic_complexity identifier_name large_tuple
    private func decodeDetections(
        arrays: [MLMultiArray],
        inputSize: Int,
        origWidth: CGFloat,
        origHeight: CGFloat,
        scale: CGFloat,
        padX: CGFloat,
        padY: CGFloat
    ) -> [DetectedObject] {
        // Try to support common YOLO export shapes. We'll flatten any [1, N, C] to [N, C].
        var candidates: [(CGRect, Int, Float)] = []

        for arr in arrays {
            let shape = arr.shape.map { $0.intValue }
            let stride0 = arr.strides.map { $0.intValue }
            // Obtain a flat pointer to Floats
            guard let ptr = arr.dataPointer.bindMemory(to: Float.self, capacity: arr.count) as UnsafeMutablePointer<Float>? else { continue }

            func get(_ i: Int) -> Float { ptr[i] }

            if shape.count == 3 {
                // [B, N, C] or [1, C, N]
                if shape[0] == 1 { // [1, N, C]
                    let n = shape[1], c = shape[2]
                    for i in 0..<min(n, maxDetections) {
                        let base = i * c
                        if c < 6 { continue }
                        let x = get(base + 0), y = get(base + 1), w = get(base + 2), h = get(base + 3)
                        let obj = get(base + 4)
                        var bestScore: Float = 0
                        var bestCls: Int = -1
                        for cls in 5..<c {
                            let sc = obj * get(base + cls)
                            if sc > bestScore {
                                bestScore = sc
                                bestCls = cls - 5
                            }
                        }
                        if bestScore >= scoreThreshold, w > 0, h > 0 {
                            let rect = mapToOriginal(x: x, y: y, w: w, h: h, input: CGFloat(inputSize), scale: scale, padX: padX, padY: padY, origW: origWidth, origH: origHeight)
                            candidates.append((rect, bestCls, bestScore))
                        }
                    }
                } else if shape[1] == 1 { // [C, 1, N] unlikely; skip
                    continue
                } else if shape[2] == 1 { // [C, N, 1] unlikely; skip
                    continue
                }
            } else if shape.count == 2 {
                let n = shape[0], c = shape[1]
                for i in 0..<min(n, maxDetections) {
                    let base = i * c
                    if c < 6 { continue }
                    let x = get(base + 0), y = get(base + 1), w = get(base + 2), h = get(base + 3)
                    let obj = get(base + 4)
                    var bestScore: Float = 0
                    var bestCls: Int = -1
                    for cls in 5..<c {
                        let sc = obj * get(base + cls)
                        if sc > bestScore {
                            bestScore = sc
                            bestCls = cls - 5
                        }
                    }
                    if bestScore >= scoreThreshold, w > 0, h > 0 {
                        let rect = mapToOriginal(x: x, y: y, w: w, h: h, input: CGFloat(inputSize), scale: scale, padX: padX, padY: padY, origW: origWidth, origH: origHeight)
                        candidates.append((rect, bestCls, bestScore))
                    }
                }
            } else {
                // Unknown shape; skip
                continue
            }
        }

        // Apply NMS
        let keep = nonMaxSuppression(candidates: candidates, iouThreshold: iouThreshold, topK: topK)
        // Convert to DetectedObject (normalized 0..1 with top-left origin)
        return keep.map { (rect, cls, score) in
            let className = (cls >= 0 && cls < labels.count) ? labels[cls] : "obj_\(cls)"
            let norm = CGRect(x: rect.minX / origWidth, y: rect.minY / origHeight, width: rect.width / origWidth, height: rect.height / origHeight)
            return DetectedObject(boundingBox: norm, className: className, confidence: score, framework: .coreML)
        }
    }
    // swiftlint:enable function_parameter_count cyclomatic_complexity identifier_name large_tuple

    // swiftlint:disable function_parameter_count identifier_name
    private func mapToOriginal(x: Float, y: Float, w: Float, h: Float, input: CGFloat, scale: CGFloat, padX: CGFloat, padY: CGFloat, origW: CGFloat, origH: CGFloat) -> CGRect {
        // Inputs assumed in model input pixel coordinates: cx, cy, w, h
        let cx = CGFloat(x), cy = CGFloat(y), ww = CGFloat(w), hh = CGFloat(h)
        // Remove letterbox padding and scale back to original image
        let x1 = max(0, (cx - ww/2 - padX) / scale)
        let y1 = max(0, (cy - hh/2 - padY) / scale)
        let x2 = min(origW, (cx + ww/2 - padX) / scale)
        let y2 = min(origH, (cy + hh/2 - padY) / scale)
        return CGRect(x: x1, y: y1, width: max(0, x2 - x1), height: max(0, y2 - y1))
    }
    // swiftlint:enable function_parameter_count identifier_name

    // swiftlint:disable large_tuple
    private func nonMaxSuppression(candidates: [(CGRect, Int, Float)], iouThreshold: Float, topK: Int) -> [(CGRect, Int, Float)] {
        var sorted = candidates.sorted { $0.2 > $1.2 }
        var keep: [(CGRect, Int, Float)] = []
        while !sorted.isEmpty && keep.count < topK {
            let best = sorted.removeFirst()
            keep.append(best)
            sorted.removeAll { cand in
                if cand.1 != best.1 { return false } // class-agnostic switch? choose class-wise NMS
                return iou(rectA: cand.0, rectB: best.0) > iouThreshold
            }
        }
        return keep
    }
    // swiftlint:enable large_tuple

    private func iou(rectA: CGRect, rectB: CGRect) -> Float {
        let inter = rectA.intersection(rectB)
        if inter.isNull || inter.isEmpty { return 0 }
        let interArea = Float(inter.width * inter.height)
        let unionArea = Float(rectA.width * rectA.height + rectB.width * rectB.height - CGFloat(interArea))
        return unionArea > 0 ? interArea / unionArea : 0
    }
}

private final class YOLOInputProvider: MLFeatureProvider {
    let name: String
    let pixelBuffer: CVPixelBuffer
    init(name: String, pixelBuffer: CVPixelBuffer) { self.name = name; self.pixelBuffer = pixelBuffer }
    var featureNames: Set<String> { [name] }
    func featureValue(for featureName: String) -> MLFeatureValue? {
        guard featureName == name else { return nil }
        return MLFeatureValue(pixelBuffer: pixelBuffer)
    }
}
