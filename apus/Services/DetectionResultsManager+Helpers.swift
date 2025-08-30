//
//  DetectionResultsManager+Helpers.swift
//  apus
//

import Foundation

extension DetectionResultsManager {
    func enforceLimit<T>(for results: inout [T], limit: Int) {
        if results.count > limit {
            results = Array(results.prefix(limit))
        }
    }
}
