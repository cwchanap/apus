//
//  CGImagePropertyOrientationTests.swift
//  apusTests
//
//  Created by Copilot on 2026/03/31.
//

import ImageIO
import UIKit
import XCTest
@testable import apus

final class CGImagePropertyOrientationTests: XCTestCase {
    func testInitFromUIImageOrientation_mapsEveryKnownOrientation() {
        let cases: [(UIImage.Orientation, CGImagePropertyOrientation)] = [
            (.up, .up),
            (.upMirrored, .upMirrored),
            (.down, .down),
            (.downMirrored, .downMirrored),
            (.left, .left),
            (.leftMirrored, .leftMirrored),
            (.right, .right),
            (.rightMirrored, .rightMirrored)
        ]

        for (uiOrientation, expectedOrientation) in cases {
            XCTAssertEqual(CGImagePropertyOrientation(from: uiOrientation), expectedOrientation)
        }
    }
}
