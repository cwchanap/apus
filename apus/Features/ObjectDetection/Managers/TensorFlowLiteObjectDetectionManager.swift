//
//  TensorFlowLiteObjectDetectionManager.swift
//  apus
//
//  Created by Rovo Dev on 1/8/2025.
//

#if !DEBUG && !targetEnvironment(simulator)
import Foundation
import UIKit
import TensorFlowLite

class TensorFlowLiteObjectDetectionManager: ObservableObject, UnifiedObjectDetectionProtocol {
    @Published var isDetecting = false
    @Published var lastDetectedObjects: [DetectedObject] = []
    let framework: ObjectDetectionFramework = .tensorflowLite
    
    private var interpreter: Interpreter?
    private var labels: [String] = []
    
    init() {
        setupModel()
    }
    
    private func setupModel() {
        guard let modelPath = Bundle.main.path(forResource: "efficientdet_lite0", ofType: "tflite"),
              let labelsPath = Bundle.main.path(forResource: "coco_labels", ofType: "txt") else {
            print("Failed to load TensorFlow Lite model or labels")
            return
        }
        
        do {
            // Load labels
            let labelsContent = try String(contentsOfFile: labelsPath)
            labels = labelsContent.components(separatedBy: .newlines).filter { !$0.isEmpty }
            
            // Initialize interpreter
            interpreter = try Interpreter(modelPath: modelPath)
            try interpreter?.allocateTensors()
            
            print("TensorFlow Lite model loaded successfully with \(labels.count) labels")
        } catch {
            print("Failed to initialize TensorFlow Lite: \(error)")
        }
    }
    
    func detectObjects(in image: UIImage, completion: @escaping (Result<[DetectedObject], Error>) -> Void) {
        guard let interpreter = interpreter else {
            completion(.failure(TensorFlowLiteError.modelNotLoaded))
            return
        }
        
        DispatchQueue.main.async {
            self.isDetecting = true
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Preprocess image
                guard let inputData = self.preprocessImage(image) else {
                    DispatchQueue.main.async {
                        self.isDetecting = false
                        completion(.failure(TensorFlowLiteError.imagePreprocessingFailed))
                    }
                    return
                }
                
                // Run inference
                try interpreter.copy(inputData, toInputAt: 0)
                try interpreter.invoke()
                
                // Get outputs
                let detections = try self.processOutputs(interpreter: interpreter, originalImageSize: image.size)
                
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
    
    private func preprocessImage(_ image: UIImage) -> Data? {
        // EfficientDet expects 320x320 input
        let inputWidth = 320
        let inputHeight = 320
        
        guard let resizedImage = image.resized(to: CGSize(width: inputWidth, height: inputHeight)),
              let cgImage = resizedImage.cgImage else {
            return nil
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * inputWidth
        let bitsPerComponent = 8
        
        var pixelData = [UInt8](repeating: 0, count: inputHeight * inputWidth * bytesPerPixel)
        
        guard let context = CGContext(
            data: &pixelData,
            width: inputWidth,
            height: inputHeight,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: inputWidth, height: inputHeight))
        
        // Convert to float32 and normalize to [0, 1]
        var floatData = [Float32]()
        for i in stride(from: 0, to: pixelData.count, by: 4) {
            let r = Float32(pixelData[i]) / 255.0
            let g = Float32(pixelData[i + 1]) / 255.0
            let b = Float32(pixelData[i + 2]) / 255.0
            
            floatData.append(r)
            floatData.append(g)
            floatData.append(b)
        }
        
        return Data(bytes: floatData, count: floatData.count * MemoryLayout<Float32>.size)
    }
    
    private func processOutputs(interpreter: Interpreter, originalImageSize: CGSize) throws -> [DetectedObject] {
        // EfficientDet outputs:
        // Output 0: Detection boxes [1, 25, 4]
        // Output 1: Detection classes [1, 25]
        // Output 2: Detection scores [1, 25]
        // Output 3: Number of detections [1]
        
        let boxesOutput = try interpreter.output(at: 0)
        let classesOutput = try interpreter.output(at: 1)
        let scoresOutput = try interpreter.output(at: 2)
        let numDetectionsOutput = try interpreter.output(at: 3)
        
        let boxes = boxesOutput.data.withUnsafeBytes { $0.bindMemory(to: Float32.self) }
        let classes = classesOutput.data.withUnsafeBytes { $0.bindMemory(to: Float32.self) }
        let scores = scoresOutput.data.withUnsafeBytes { $0.bindMemory(to: Float32.self) }
        let numDetections = numDetectionsOutput.data.withUnsafeBytes { $0.bindMemory(to: Float32.self) }
        
        var detections: [DetectedObject] = []
        let maxDetections = min(Int(numDetections[0]), 25)
        
        for i in 0..<maxDetections {
            let score = scores[i]
            guard score > 0.3 else { continue } // Confidence threshold
            
            let classIndex = Int(classes[i])
            guard classIndex < labels.count else { continue }
            
            // Boxes are in format [y_min, x_min, y_max, x_max] normalized
            let yMin = CGFloat(boxes[i * 4])
            let xMin = CGFloat(boxes[i * 4 + 1])
            let yMax = CGFloat(boxes[i * 4 + 2])
            let xMax = CGFloat(boxes[i * 4 + 3])
            
            // Convert to our format (top-left origin, normalized)
            let boundingBox = CGRect(
                x: xMin,
                y: yMin,
                width: xMax - xMin,
                height: yMax - yMin
            )
            
            let detection = DetectedObject(
                boundingBox: boundingBox,
                className: labels[classIndex],
                confidence: score,
                framework: .tensorflowLite
            )
            
            detections.append(detection)
        }
        
        // Sort by confidence and return top detections
        return Array(detections
            .sorted { $0.confidence > $1.confidence }
            .prefix(8))
    }
}

enum TensorFlowLiteError: Error, LocalizedError {
    case modelNotLoaded
    case imagePreprocessingFailed
    case inferenceFailed
    
    var errorDescription: String? {
        switch self {
        case .modelNotLoaded:
            return "TensorFlow Lite model not loaded"
        case .imagePreprocessingFailed:
            return "Failed to preprocess image for TensorFlow Lite"
        case .inferenceFailed:
            return "TensorFlow Lite inference failed"
        }
    }
}

// MARK: - UIImage Extension for Resizing
extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

#endif