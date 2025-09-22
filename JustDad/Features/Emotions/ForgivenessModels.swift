//
//  ForgivenessModels.swift
//  JustDad - Forgiveness Therapy Models
//
//  Modelos para la Terapia del Perdón Pránica de 21 días
//

import Foundation
import SwiftData

// MARK: - Forgiveness Session Models

@Model
class ForgivenessSession {
    var id: UUID
    var date: Date
    var phase: ForgivenessPhase
    var day: Int
    var isCompleted: Bool
    var emotionalStateBefore: String // EmotionalState rawValue
    var emotionalStateAfter: String // EmotionalState rawValue
    var peaceLevelBefore: Int // 1-10
    var peaceLevelAfter: Int // 1-10
    var notes: String?
    var audioRecordingURL: String?
    var duration: TimeInterval
    var letterContent: String
    var affirmation: String
    
    init(
        phase: ForgivenessPhase,
        day: Int,
        emotionalStateBefore: String,
        peaceLevelBefore: Int,
        letterContent: String,
        affirmation: String
    ) {
        self.id = UUID()
        self.date = Date()
        self.phase = phase
        self.day = day
        self.isCompleted = false
        self.emotionalStateBefore = emotionalStateBefore
        self.emotionalStateAfter = emotionalStateBefore
        self.peaceLevelBefore = peaceLevelBefore
        self.peaceLevelAfter = peaceLevelBefore
        self.duration = 0
        self.letterContent = letterContent
        self.affirmation = affirmation
    }
}

// MARK: - Forgiveness Phase Enum

enum ForgivenessPhase: String, CaseIterable, Identifiable, Codable {
    case selfForgiveness = "self_forgiveness"
    case partnerForgiveness = "partner_forgiveness"
    case childrenForgiveness = "children_forgiveness"
    case futureForgiveness = "future_forgiveness"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .selfForgiveness:
            return "Sanar conmigo mismo"
        case .partnerForgiveness:
            return "Sanar la relación con la ex-pareja"
        case .childrenForgiveness:
            return "Sanar la relación con los hijos"
        case .futureForgiveness:
            return "Sanar el futuro"
        }
    }
    
    var description: String {
        switch self {
        case .selfForgiveness:
            return "Días 1-7: Perdón hacia ti mismo"
        case .partnerForgiveness:
            return "Días 8-14: Perdón hacia tu ex-pareja"
        case .childrenForgiveness:
            return "Días 15-18: Sanación con tus hijos"
        case .futureForgiveness:
            return "Días 19-21: Liberación del futuro"
        }
    }
    
    var startDay: Int {
        switch self {
        case .selfForgiveness: return 1
        case .partnerForgiveness: return 8
        case .childrenForgiveness: return 15
        case .futureForgiveness: return 19
        }
    }
    
    var endDay: Int {
        switch self {
        case .selfForgiveness: return 7
        case .partnerForgiveness: return 14
        case .childrenForgiveness: return 18
        case .futureForgiveness: return 21
        }
    }
    
    var color: String {
        switch self {
        case .selfForgiveness: return "blue"
        case .partnerForgiveness: return "red"
        case .childrenForgiveness: return "green"
        case .futureForgiveness: return "purple"
        }
    }
    
    var icon: String {
        switch self {
        case .selfForgiveness: return "person.fill"
        case .partnerForgiveness: return "heart.fill"
        case .childrenForgiveness: return "figure.and.child.holdinghands"
        case .futureForgiveness: return "sparkles"
        }
    }
}

// MARK: - Forgiveness Letter Model

struct ForgivenessLetter: Identifiable, Codable {
    let id: UUID
    let day: Int
    let phase: ForgivenessPhase
    let title: String
    let content: String
    let affirmation: String
    let visualizationText: String
    
    init(
        day: Int,
        phase: ForgivenessPhase,
        title: String,
        content: String,
        affirmation: String,
        visualizationText: String
    ) {
        self.id = UUID()
        self.day = day
        self.phase = phase
        self.title = title
        self.content = content
        self.affirmation = affirmation
        self.visualizationText = visualizationText
    }
}

// MARK: - Forgiveness Progress Model

struct ForgivenessProgress: Identifiable, Codable {
    let id: UUID
    let phase: ForgivenessPhase
    let completedDays: Int
    let totalDays: Int
    let peaceLevelImprovement: Int
    let lastSessionDate: Date?
    
    var completionPercentage: Double {
        return Double(completedDays) / Double(totalDays)
    }
    
    var isPhaseCompleted: Bool {
        return completedDays >= totalDays
    }
}

// MARK: - Forgiveness Statistics

struct ForgivenessStatistics: Codable {
    let totalSessions: Int
    let completedSessions: Int
    let averagePeaceLevelImprovement: Double
    let currentStreak: Int
    let longestStreak: Int
    let phaseProgress: [ForgivenessProgress]
    
    var completionRate: Double {
        return totalSessions > 0 ? Double(completedSessions) / Double(totalSessions) : 0
    }
}

// MARK: - Forgiveness Settings

struct ForgivenessSettings: Codable {
    var enableBinauralAudio: Bool
    var enableHapticFeedback: Bool
    var preferredBreathingPattern: BreathingPattern
    var reminderTime: Date?
    var enableProgressNotifications: Bool
    
    init() {
        self.enableBinauralAudio = true
        self.enableHapticFeedback = true
        self.preferredBreathingPattern = .fourSevenEight
        self.enableProgressNotifications = true
    }
}

enum BreathingPattern: String, CaseIterable, Identifiable, Codable {
    case fourSevenEight = "4-7-8"
    case boxBreathing = "box"
    case pranic = "pranic"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .fourSevenEight:
            return "4-7-8 (Relajación)"
        case .boxBreathing:
            return "Respiración en caja"
        case .pranic:
            return "Respiración Pránica"
        }
    }
    
    var description: String {
        switch self {
        case .fourSevenEight:
            return "Inhala 4, mantén 7, exhala 8"
        case .boxBreathing:
            return "Inhala 4, mantén 4, exhala 4, mantén 4"
        case .pranic:
            return "Respiración energética profunda"
        }
    }
}

// MARK: - Forgiveness Session Step

enum ForgivenessSessionStep: Int, CaseIterable {
    case welcome = 0
    case breathing = 1
    case selection = 2
    case letter = 3
    case visualization = 4
    case sealing = 5
    case reinforcement = 6
    
    var title: String {
        switch self {
        case .welcome:
            return "Bienvenida Cinemática"
        case .breathing:
            return "Respiración + Anclaje Energético"
        case .selection:
            return "Selección de Escenario"
        case .letter:
            return "Carta del Perdón"
        case .visualization:
            return "Visualización Energética"
        case .sealing:
            return "Sellado y Expansión"
        case .reinforcement:
            return "Refuerzo Adictivo"
        }
    }
    
    var description: String {
        switch self {
        case .welcome:
            return "Inicio del ritual de liberación"
        case .breathing:
            return "Preparación energética y mental"
        case .selection:
            return "Elige a quién perdonar"
        case .letter:
            return "Lee en voz alta la carta de liberación"
        case .visualization:
            return "Corta el cordón energético"
        case .sealing:
            return "Sella la liberación con luz"
        case .reinforcement:
            return "Registra tu progreso"
        }
    }
    
    var duration: TimeInterval {
        switch self {
        case .welcome: return 60 // 1 min
        case .breathing: return 120 // 2 min
        case .selection: return 60 // 1 min
        case .letter: return 420 // 7 min
        case .visualization: return 180 // 3 min
        case .sealing: return 120 // 2 min
        case .reinforcement: return 60 // 1 min
        }
    }
}
