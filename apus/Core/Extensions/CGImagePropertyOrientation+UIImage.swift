//
//  CGImagePropertyOrientation+UIImage.swift
//  apus
//
//  Created by Rovo Dev on 11/8/2025.
//

import Foundation
import UIKit
import ImageIO

// MARK: - CGImagePropertyOrientation Extension
extension CGImagePropertyOrientation {
    init(from uiImageOrientation: UIImage.Orientation) {
        switch uiImageOrientation {
        case .up:
            self = .up
        case .upMirrored:
            self = .upMirrored
        case .down:
            self = .down
        case .downMirrored:
            self = .downMirrored
        case .left:
            self = .left
        case .leftMirrored:
            self = .leftMirrored
        case .right:
            self = .right
        case .rightMirrored:
            self = .rightMirrored
        @unknown default:
            self = .up
        }
    }
}
