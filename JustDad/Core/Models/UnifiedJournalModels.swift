//
//  UnifiedJournalModels.swift
//  JustDad - Unified Journaling Models
//
//  Unifies both intelligent and traditional journaling systems
//

import Foundation
import SwiftUI
import SwiftData

// MARK: - Using existing types from EmotionModels.swift and IntelligentJournalingService.swift

// MARK: - Unified Journal Entry
@Model
public class UnifiedJournalEntry {
    @Attribute(.unique) public var id: UUID
    public var date: Date
    public var type: JournalType
    public var content: String
    public var title: String?
    public var audioURLString: String?
    public var photoURLStrings: [String]
    public var tags: [String]
    public var isEncrypted: Bool
    public var createdAt: Date
    public var updatedAt: Date
    
    // Computed properties for convenience
    public var audioURL: URL? {
        guard let audioURLString = audioURLString else { return nil }
        return URL(string: audioURLString)
    }
    
    public var photoURLs: [URL] {
        return photoURLStrings.compactMap { URL(string: $0) }
    }
    
    // Initializer for intelligent journaling
    public init(
        emotion: EmotionalState,
        prompt: JournalPrompt,
        content: String,
        audioURL: URL? = nil,
        tags: [String] = [],
        isEncrypted: Bool = false
    ) {
        self.id = UUID()
        self.date = Date()
        self.type = .intelligent(emotion: emotion, prompt: prompt)
        self.content = content
        self.title = nil
        self.audioURLString = audioURL?.absoluteString
        self.photoURLStrings = []
        self.tags = tags
        self.isEncrypted = isEncrypted
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // Initializer for traditional journaling
    public init(
        title: String?,
        content: String,
        mood: String,
        audioURL: URL? = nil,
        photoURLs: [URL] = [],
        tags: [String] = [],
        isEncrypted: Bool = false
    ) {
        self.id = UUID()
        self.date = Date()
        self.type = .traditional(mood: mood)
        self.content = content
        self.title = title
        self.audioURLString = audioURL?.absoluteString
        self.photoURLStrings = photoURLs.map { $0.absoluteString }
        self.tags = tags
        self.isEncrypted = isEncrypted
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Helper Methods
    public func addPhoto(_ url: URL) {
        photoURLStrings.append(url.absoluteString)
        updatedAt = Date()
    }
    
    public func removePhoto(_ url: URL) {
        photoURLStrings.removeAll { $0 == url.absoluteString }
        updatedAt = Date()
    }
    
    public func addTag(_ tag: String) {
        if !tags.contains(tag) {
            tags.append(tag)
            updatedAt = Date()
        }
    }
    
    public func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
        updatedAt = Date()
    }
    
    public func updateContent(_ newContent: String) {
        content = newContent
        updatedAt = Date()
    }
}

// MARK: - Journal Type
public enum JournalType: Codable {
    case intelligent(emotion: EmotionalState, prompt: JournalPrompt)
    case traditional(mood: String)
    
    public var displayName: String {
        switch self {
        case .intelligent(_, _):
            return "Journaling Inteligente"
        case .traditional(_):
            return "Diario Tradicional"
        }
    }
    
    public var icon: String {
        switch self {
        case .intelligent(_, _):
            return "brain.head.profile"
        case .traditional(_):
            return "book.pages"
        }
    }
    
    public var color: Color {
        switch self {
        case .intelligent(_, _):
            return .blue
        case .traditional(_):
            return .green
        }
    }
    
    // MARK: - Codable Implementation
    private enum CodingKeys: String, CodingKey {
        case type, emotion, prompt, mood
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .intelligent(let emotion, let prompt):
            try container.encode("intelligent", forKey: .type)
            try container.encode(emotion, forKey: .emotion)
            try container.encode(prompt, forKey: .prompt)
        case .traditional(let mood):
            try container.encode("traditional", forKey: .type)
            try container.encode(mood, forKey: .mood)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "intelligent":
            let emotion = try container.decode(EmotionalState.self, forKey: .emotion)
            let prompt = try container.decode(JournalPrompt.self, forKey: .prompt)
            self = .intelligent(emotion: emotion, prompt: prompt)
        case "traditional":
            let mood = try container.decode(String.self, forKey: .mood)
            self = .traditional(mood: mood)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown journal type")
        }
    }
}

// MARK: - Using existing JournalPrompt from IntelligentJournalingService.swift

// MARK: - Prompt Difficulty
public enum PromptDifficulty: String, CaseIterable, Codable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    
    public var displayName: String {
        switch self {
        case .easy: return "Fácil"
        case .medium: return "Medio"
        case .hard: return "Difícil"
        }
    }
    
    public var icon: String {
        switch self {
        case .easy: return "1.circle.fill"
        case .medium: return "2.circle.fill"
        case .hard: return "3.circle.fill"
        }
    }
    
    public var color: Color {
        switch self {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}

// MARK: - Using existing PromptCategory from IntelligentJournalingService.swift

// MARK: - Enhanced Journal Context (extends existing JournalContext)
public enum EnhancedJournalContext: Codable {
    case afterTest(String) // Simplified for now - will reference ParenthoodTestService.TestType later
    case afterExercise(String)
    case endOfDay
    case weekendReflection
    case morningRoutine
    case beforeSleep
    case afterConflict
    case milestone(Date, String)
    case therapy
    case meditation
    
    public var displayName: String {
        switch self {
        case .afterTest(let testType):
            return "Después del test: \(testType)"
        case .afterExercise(let exercise):
            return "Después del ejercicio: \(exercise)"
        case .endOfDay:
            return "Final del día"
        case .weekendReflection:
            return "Reflexión de fin de semana"
        case .morningRoutine:
            return "Rutina matutina"
        case .beforeSleep:
            return "Antes de dormir"
        case .afterConflict:
            return "Después de un conflicto"
        case .milestone(_, let description):
            return "Hito: \(description)"
        case .therapy:
            return "Sesión de terapia"
        case .meditation:
            return "Después de meditar"
        }
    }
    
    public var icon: String {
        switch self {
        case .afterTest(_): return "brain.head.profile"
        case .afterExercise(_): return "figure.run"
        case .endOfDay: return "sunset.fill"
        case .weekendReflection: return "calendar.badge.clock"
        case .morningRoutine: return "sunrise.fill"
        case .beforeSleep: return "moon.fill"
        case .afterConflict: return "heart.fill"
        case .milestone: return "star.fill"
        case .therapy: return "person.circle.fill"
        case .meditation: return "leaf.arrow.circlepath"
        }
    }
}

// MARK: - Journal Statistics
public struct JournalStatistics {
    public let totalEntries: Int
    public let entriesThisWeek: Int
    public let entriesThisMonth: Int
    public let averageWordsPerEntry: Double
    public let mostUsedTags: [String]
    public let emotionTrends: [EmotionTrend]
    public let longestStreak: Int
    public let currentStreak: Int
    
    public init(
        totalEntries: Int,
        entriesThisWeek: Int,
        entriesThisMonth: Int,
        averageWordsPerEntry: Double,
        mostUsedTags: [String],
        emotionTrends: [EmotionTrend],
        longestStreak: Int,
        currentStreak: Int
    ) {
        self.totalEntries = totalEntries
        self.entriesThisWeek = entriesThisWeek
        self.entriesThisMonth = entriesThisMonth
        self.averageWordsPerEntry = averageWordsPerEntry
        self.mostUsedTags = mostUsedTags
        self.emotionTrends = emotionTrends
        self.longestStreak = longestStreak
        self.currentStreak = currentStreak
    }
}

// MARK: - Emotion Trend
public struct EmotionTrend: Identifiable {
    public let id = UUID()
    public let date: Date
    public let emotion: EmotionalState
    public let count: Int
    
    public init(date: Date, emotion: EmotionalState, count: Int) {
        self.date = date
        self.emotion = emotion
        self.count = count
    }
}
