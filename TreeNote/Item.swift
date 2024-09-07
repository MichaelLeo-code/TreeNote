//
//  Item.swift
//  TreeNote
//
//  Created by Michael Leo on 07/09/2024.
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
