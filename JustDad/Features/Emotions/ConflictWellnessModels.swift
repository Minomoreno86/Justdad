//
//  ConflictWellnessModels.swift
//  JustDad - Conflict Wellness Models
//
//  Data models for conflict wellness and coparenting management
//

import Foundation

// MARK: - Communication Examples
struct CommunicationExample: Identifiable, Codable {
    let id = UUID()
    let category: String
    let trigger: String
    let responseSerena: String
    let checks: [String] // ["Breve", "Clara", "Amable", "Firme"]
    let points: Int
    
    enum CodingKeys: String, CodingKey {
        case category, trigger, responseSerena, checks, points
    }
}

// MARK: - Communication Rules
struct CommunicationRule: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let example: String?
    
    enum CodingKeys: String, CodingKey {
        case title, description, example
    }
}

// MARK: - Wellness Journal Entry
struct WellnessJournalEntry: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let type: InteractionType
    let description: String
    let emotion: Int // 1-5 scale
    let actionProxima: String
    
    enum InteractionType: String, CaseIterable, Codable {
        case emotional = "Emocional"
        case logistics = "Logística"
        case children = "Hijos"
        
        var icon: String {
            switch self {
            case .emotional: return "heart.fill"
            case .logistics: return "calendar"
            case .children: return "person.2.fill"
            }
        }
        
        var color: String {
            switch self {
            case .emotional: return "red"
            case .logistics: return "blue"
            case .children: return "green"
            }
        }
    }
}

// MARK: - Children Support Script
struct ChildrenSupportScript: Identifiable, Codable {
    let id = UUID()
    let situation: String
    let dontSay: String
    let doSay: String
    let explanation: String
    
    enum CodingKeys: String, CodingKey {
        case situation, dontSay, doSay, explanation
    }
}

// MARK: - Self Care Practice
struct SelfCarePractice: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let duration: String
    let frequency: String
    let icon: String
    let color: String
    
    enum CodingKeys: String, CodingKey {
        case title, description, duration, frequency, icon, color
    }
}

// MARK: - Daily Affirmation
struct DailyAffirmation: Identifiable, Codable {
    let id = UUID()
    let text: String
    let category: String
    let isUsed: Bool
    
    enum CodingKeys: String, CodingKey {
        case text, category, isUsed
    }
}

// MARK: - Conflict Wellness Stats
struct ConflictWellnessStats: Codable {
    var totalResponses: Int = 0
    var serenaResponses: Int = 0
    var journalEntries: Int = 0
    var childValidations: Int = 0
    var selfCareDays: Int = 0
    var currentStreak: Int = 0
    var totalPoints: Int = 0
    
    var serenaPercentage: Double {
        guard totalResponses > 0 else { return 0 }
        return Double(serenaResponses) / Double(totalResponses) * 100
    }
}

// MARK: - Conflict Achievement Badge
struct ConflictAchievementBadge: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let criteria: String
    let icon: String
    let color: String
    let isUnlocked: Bool
    let unlockedDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case name, description, criteria, icon, color, isUnlocked, unlockedDate
    }
    
    init(name: String, description: String, criteria: String, icon: String, color: String, isUnlocked: Bool = false, unlockedDate: Date? = nil) {
        self.name = name
        self.description = description
        self.criteria = criteria
        self.icon = icon
        self.color = color
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
    }
}

// MARK: - Conflict Wellness Session
struct ConflictWellnessSession: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let type: SessionType
    let duration: TimeInterval
    let completed: Bool
    let notes: String?
    
    enum SessionType: String, CaseIterable, Codable {
        case communication = "Comunicación"
        case journaling = "Bitácora"
        case childrenSupport = "Apoyo a Hijos"
        case selfCare = "Autocuidado"
        case breathing = "Respiración"
        case affirmation = "Afirmación"
        
        var icon: String {
            switch self {
            case .communication: return "message.fill"
            case .journaling: return "book.fill"
            case .childrenSupport: return "person.2.fill"
            case .selfCare: return "heart.fill"
            case .breathing: return "lungs.fill"
            case .affirmation: return "star.fill"
            }
        }
        
        var color: String {
            switch self {
            case .communication: return "blue"
            case .journaling: return "orange"
            case .childrenSupport: return "green"
            case .selfCare: return "purple"
            case .breathing: return "teal"
            case .affirmation: return "yellow"
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, date, type, duration, completed, notes
    }
}

// MARK: - Communication Training Result
struct CommunicationTrainingResult: Identifiable, Codable {
    let id = UUID()
    let example: CommunicationExample
    let userResponse: String
    let isBreve: Bool
    let isClara: Bool
    let isAmable: Bool
    let isFirme: Bool
    let score: Int
    let date: Date
    
    var isSerena: Bool {
        return isBreve && isClara && isAmable && isFirme
    }
    
    enum CodingKeys: String, CodingKey {
        case example, userResponse, isBreve, isClara, isAmable, isFirme, score, date
    }
}
