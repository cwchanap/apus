//
//  Item.swift
//  apus
//
//  Created by Chan Wai Chan on 27/6/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
