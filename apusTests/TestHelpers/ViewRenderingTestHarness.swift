//
//  ViewRenderingTestHarness.swift
//  apusTests
//
//  Created by Codex on 2026/05/24.
//

import SwiftUI
import UIKit
import XCTest

@MainActor
enum ViewRenderingTestHarness {
    static func render<V: View>(
        _ view: V,
        size: CGSize = CGSize(width: 390, height: 844),
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let previousKeyWindow = currentKeyWindow()
        let window = UIWindow(frame: CGRect(origin: .zero, size: size))
        let host = UIHostingController(rootView: view)

        defer {
            window.isHidden = true
            window.rootViewController = nil
            previousKeyWindow?.makeKey()
        }

        window.rootViewController = host
        window.makeKeyAndVisible()

        host.view.frame = window.bounds
        window.setNeedsLayout()
        window.layoutIfNeeded()
        host.view.setNeedsLayout()
        host.view.layoutIfNeeded()

        RunLoop.main.run(until: Date().addingTimeInterval(0.05))

        host.view.frame = window.bounds
        host.view.setNeedsLayout()
        host.view.layoutIfNeeded()

        XCTAssertEqual(host.view.bounds.size.width, size.width, accuracy: 0.5, file: file, line: line)
        XCTAssertEqual(host.view.bounds.size.height, size.height, accuracy: 0.5, file: file, line: line)
    }

    private static func currentKeyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
    }
}
