//
//  DetectionResultsTestHelpers.swift
//  apusTests
//
//  Created by Codex on 2026/03/30.
//

import Foundation
import CoreGraphics

enum DetectionResultsTestSupportError: Error {
    case invalidTopLevelJSONObject
}

enum DetectionResultsTestSupport {
    static func removingJSONKey(_ key: String, from encodedData: Data) throws -> Data {
        guard var jsonObject = try JSONSerialization.jsonObject(with: encodedData) as? [String: Any] else {
            throw DetectionResultsTestSupportError.invalidTopLevelJSONObject
        }

        jsonObject.removeValue(forKey: key)
        return try JSONSerialization.data(withJSONObject: jsonObject)
    }

    static func replacingJSONValue(_ value: Any, forKey key: String, in encodedData: Data) throws -> Data {
        guard var jsonObject = try JSONSerialization.jsonObject(with: encodedData) as? [String: Any] else {
            throw DetectionResultsTestSupportError.invalidTopLevelJSONObject
        }

        jsonObject[key] = value
        return try JSONSerialization.data(withJSONObject: jsonObject)
    }

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
}
