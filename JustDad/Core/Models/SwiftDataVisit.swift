//
//  SwiftDataVisit.swift
//  JustDad - Basic SwiftData Visit Model
//
//  Simple SwiftData model for visits - Migration Phase 1
//

import Foundation
import SwiftData

@Model
final class SwiftDataVisit {
    var id: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var location: String?
    var notes: String?
    var type: String
    var isCompleted: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(title: String, startDate: Date, endDate: Date, type: String = "general", location: String? = nil, notes: String? = nil) {
        self.id = UUID()
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.type = type
        self.location = location
        self.notes = notes
        self.isCompleted = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Computed Properties
    var formattedDuration: String {
        let duration = endDate.timeIntervalSince(startDate)
        let hours = Int(duration) / 3600
        let minutes = Int(duration.truncatingRemainder(dividingBy: 3600)) / 60
        
        if hours > 0 {
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
    
    var isUpcoming: Bool {
        return startDate > Date()
    }
    
    var isPast: Bool {
        return endDate < Date()
    }
    
    // MARK: - Methods
    func markAsCompleted() {
        isCompleted = true
        updatedAt = Date()
    }
}
