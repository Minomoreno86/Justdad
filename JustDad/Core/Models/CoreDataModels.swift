//
//  CoreDataModels.swift
//  SoloPapá - Core Data model definitions
//
//  Data models for offline-first architecture with SQLCipher encryption
//

import Foundation
import SwiftData

// MARK: - Visit Model
@Model
final class Visit {
    var id: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var location: String?
    var notes: String?
    var type: VisitType
    var isCompleted: Bool
    var createdAt: Date
    var updatedAt: Date
    
    enum VisitType: String, Codable, CaseIterable {
        case weekend = "weekend"
        case dinner = "dinner"
        case vacation = "vacation"
        case event = "event"
        case other = "other"
    }
    
    init(title: String, startDate: Date, endDate: Date, type: VisitType, location: String? = nil, notes: String? = nil) {
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
}

// MARK: - Financial Entry Model
@Model
final class FinancialEntry {
    var id: UUID
    var title: String
    var amount: Decimal
    var category: ExpenseCategory
    var date: Date
    var notes: String?
    var receiptImagePath: String? // Path to encrypted image file
    var isRecurring: Bool
    var createdAt: Date
    var updatedAt: Date
    
    enum ExpenseCategory: String, Codable, CaseIterable {
        case education = "education"
        case health = "health"
        case food = "food"
        case clothing = "clothing"
        case transportation = "transportation"
        case entertainment = "entertainment"
        case gifts = "gifts"
        case childSupport = "child_support"
        case other = "other"
        
        var displayName: String {
            switch self {
            case .education: return "Educación"
            case .health: return "Salud"
            case .food: return "Alimentación"
            case .clothing: return "Vestimenta"
            case .transportation: return "Transporte"
            case .entertainment: return "Entretenimiento"
            case .gifts: return "Regalos"
            case .childSupport: return "Manutención"
            case .other: return "Otros"
            }
        }
    }
    
    init(title: String, amount: Decimal, category: ExpenseCategory, date: Date = Date(), notes: String? = nil) {
        self.id = UUID()
        self.title = title
        self.amount = amount
        self.category = category
        self.date = date
        self.notes = notes
        self.isRecurring = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Emotional Entry Model
@Model
final class EmotionalEntry {
    var id: UUID
    var mood: MoodLevel
    var note: String?
    var date: Date
    var energyLevel: Int // 1-10
    var stressLevel: Int // 1-10
    var sleepQuality: Int // 1-10
    var tags: [String] // e.g., "children", "work", "exercise"
    var createdAt: Date
    
    enum MoodLevel: Int, Codable, CaseIterable {
        case veryLow = 1
        case low = 2
        case neutral = 3
        case good = 4
        case excellent = 5
        
        var emoji: String {
            switch self {
            case .veryLow: return "😢"
            case .low: return "😔"
            case .neutral: return "😐"
            case .good: return "😊"
            case .excellent: return "😄"
            }
        }
        
        var description: String {
            switch self {
            case .veryLow: return "Muy Triste"
            case .low: return "Triste"
            case .neutral: return "Neutral"
            case .good: return "Feliz"
            case .excellent: return "Muy Feliz"
            }
        }
    }
    
    init(mood: MoodLevel, note: String? = nil, date: Date = Date()) {
        self.id = UUID()
        self.mood = mood
        self.note = note
        self.date = date
        self.energyLevel = 5
        self.stressLevel = 5
        self.sleepQuality = 5
        self.tags = []
        self.createdAt = Date()
    }
}

// MARK: - Diary Entry Model
@Model
final class DiaryEntry {
    var id: UUID
    var title: String?
    var content: String
    var mood: String // Emoji representation
    var date: Date
    var attachments: [DiaryAttachment]
    var isEncrypted: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(content: String, title: String? = nil, mood: String = "😐", date: Date = Date()) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.mood = mood
        self.date = date
        self.attachments = []
        self.isEncrypted = true
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Diary Attachment Model
@Model
final class DiaryAttachment {
    var id: UUID
    var type: AttachmentType
    var filePath: String // Encrypted file path
    var originalFileName: String?
    var fileSize: Int64
    var createdAt: Date
    
    enum AttachmentType: String, Codable {
        case photo = "photo"
        case audio = "audio"
        case document = "document"
    }
    
    init(type: AttachmentType, filePath: String, originalFileName: String? = nil, fileSize: Int64 = 0) {
        self.id = UUID()
        self.type = type
        self.filePath = filePath
        self.originalFileName = originalFileName
        self.fileSize = fileSize
        self.createdAt = Date()
    }
}

// MARK: - Community Post Model (for caching)
@Model
final class CommunityPost {
    var id: UUID
    var title: String
    var content: String
    var category: String
    var isAnonymous: Bool
    var authorName: String?
    var likesCount: Int
    var commentsCount: Int
    var createdAt: Date
    var lastSyncAt: Date
    
    init(title: String, content: String, category: String, isAnonymous: Bool = false, authorName: String? = nil) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.category = category
        self.isAnonymous = isAnonymous
        self.authorName = authorName
        self.likesCount = 0
        self.commentsCount = 0
        self.createdAt = Date()
        self.lastSyncAt = Date()
    }
}

// MARK: - User Preferences Model
@Model
final class UserPreferences {
    var id: UUID
    var biometricAuthEnabled: Bool
    var darkModeEnabled: Bool
    var preferredLanguage: String
    var notificationsEnabled: Bool
    var reminderSettings: ReminderSettings
    var onboardingCompleted: Bool
    var lastBackupDate: Date?
    var updatedAt: Date
    
    init() {
        self.id = UUID()
        self.biometricAuthEnabled = false
        self.darkModeEnabled = false
        self.preferredLanguage = "es"
        self.notificationsEnabled = true
        self.reminderSettings = ReminderSettings()
        self.onboardingCompleted = false
        self.updatedAt = Date()
    }
}

// MARK: - Reminder Settings
struct ReminderSettings: Codable {
    var visitReminders: Bool = true
    var emotionalCheckIn: Bool = true
    var communityUpdates: Bool = false
    var backupReminders: Bool = true
    
    init(visitReminders: Bool = true, emotionalCheckIn: Bool = true, communityUpdates: Bool = false, backupReminders: Bool = true) {
        self.visitReminders = visitReminders
        self.emotionalCheckIn = emotionalCheckIn
        self.communityUpdates = communityUpdates
        self.backupReminders = backupReminders
    }
}
