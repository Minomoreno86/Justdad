//
//  TestVisit.swift
//  JustDad - SwiftData Migration Test Model
//
//  Created by Jorge Vasquez rodriguez on 9/16/25.
//

import Foundation
import SwiftData

@Model
final class TestVisit {
    var id: String
    var title: String
    var startDate: Date
    var endDate: Date
    var notes: String
    var timestamp: Date
    
    init(
        id: String = UUID().uuidString,
        title: String,
        startDate: Date,
        endDate: Date,
        notes: String = "",
        timestamp: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
        self.timestamp = timestamp
    }
}