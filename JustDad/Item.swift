//
//  Item.swift
//  JustDad
//
//  Created by Jorge Vasquez rodriguez on 8/9/25.
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
