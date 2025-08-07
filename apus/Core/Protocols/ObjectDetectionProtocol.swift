import Foundation
import UIKit

struct Detection {
    let boundingBox: CGRect
    let className: String
    let confidence: Float
}

protocol ObjectDetectionProtocol: ObservableObject {
    var detections: [Detection] { get }
    func processFrame(_ pixelBuffer: CVPixelBuffer)
}

#if DEBUG || targetEnvironment(simulator)
// Use mock implementation for simulator and previews/debug builds
class MockObjectDetectionManager: ObjectDetectionProtocol {
    @Published var detections: [Detection] = []

    func processFrame(_ pixelBuffer: CVPixelBuffer) {
        // Mock implementation - no actual detection
    }
}
typealias ObjectDetectionProvider = MockObjectDetectionManager
#else
// Use real TensorFlow Lite implementation for device builds
typealias ObjectDetectionProvider = ObjectDetectionManager
#endif
