//
//  UIImage+Processing.swift
//  apus
//
//  Created by Rovo Dev on 30/7/2025.
//

import UIKit
import CoreGraphics

extension UIImage {
    
    /// Normalizes the image by fixing orientation and ensuring consistent processing
    func normalized() -> UIImage {
        // If the image is already in the correct orientation, return it
        guard imageOrientation != .up else { return self }
        
        // Create a graphics context and draw the image with correct orientation
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
    
    /// Resizes image while maintaining aspect ratio and ensuring no unnecessary padding
    func resizedMaintainingAspectRatio(to targetSize: CGSize) -> UIImage {
        let size = self.size
        
        // Calculate the scaling factor to fit the image within target size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Calculate the new size maintaining aspect ratio
        let scaledSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        // Create the resized image
        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: scaledSize))
        }
    }
    
    /// Prepares image for ML processing by normalizing orientation and optionally resizing
    func preparedForProcessing(targetSize: CGSize? = nil) -> UIImage {
        // First normalize the orientation
        let normalizedImage = self.normalized()
        
        // If target size is specified, resize while maintaining aspect ratio
        if let targetSize = targetSize {
            return normalizedImage.resizedMaintainingAspectRatio(to: targetSize)
        }
        
        return normalizedImage
    }
    
    /// Creates a properly oriented and sized image for display in views
    func preparedForDisplay() -> UIImage {
        // Normalize orientation
        let normalizedImage = self.normalized()
        
        // For very large images, resize them to a reasonable display size
        let maxDisplaySize: CGFloat = 2048
        let size = normalizedImage.size
        
        if size.width > maxDisplaySize || size.height > maxDisplaySize {
            let targetSize = CGSize(width: maxDisplaySize, height: maxDisplaySize)
            return normalizedImage.resizedMaintainingAspectRatio(to: targetSize)
        }
        
        return normalizedImage
    }
    
    /// Gets the display size that maintains aspect ratio within given bounds
    func displaySize(within bounds: CGSize) -> CGSize {
        let imageAspectRatio = size.width / size.height
        let boundsAspectRatio = bounds.width / bounds.height
        
        if imageAspectRatio > boundsAspectRatio {
            // Image is wider than bounds
            let displayWidth = bounds.width
            let displayHeight = displayWidth / imageAspectRatio
            return CGSize(width: displayWidth, height: displayHeight)
        } else {
            // Image is taller than bounds
            let displayHeight = bounds.height
            let displayWidth = displayHeight * imageAspectRatio
            return CGSize(width: displayWidth, height: displayHeight)
        }
    }
}