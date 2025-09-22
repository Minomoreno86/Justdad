//
//  LiberationLetterModels.swift
//  JustDad - Liberation Letter System Models
//
//  Modelos para el sistema de 21 días de Cartas de Liberación
//

import Foundation
import SwiftUI

// MARK: - Liberation Letter Phase
enum LiberationLetterPhase: String, CaseIterable, Identifiable, Codable {
    case selfHealing = "self_healing"           // Días 1-7
    case exPartnerHealing = "ex_partner"        // Días 8-14
    case childrenHealing = "children_healing"   // Días 15-18
    case futureHealing = "future_healing"       // Días 19-21
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .selfHealing: return "Sanar conmigo mismo"
        case .exPartnerHealing: return "Sanar la relación con la ex-pareja"
        case .childrenHealing: return "Sanar la relación con los hijos"
        case .futureHealing: return "Sanar el futuro"
        }
    }
    
    var description: String {
        switch self {
        case .selfHealing: return "Liberación y perdón hacia uno mismo"
        case .exPartnerHealing: return "Sanación de la relación con la expareja"
        case .childrenHealing: return "Fortalecimiento del vínculo con los hijos"
        case .futureHealing: return "Preparación para un futuro luminoso"
        }
    }
    
    var color: Color {
        switch self {
        case .selfHealing: return .blue
        case .exPartnerHealing: return .purple
        case .childrenHealing: return .green
        case .futureHealing: return .orange
        }
    }
    
    var icon: String {
        switch self {
        case .selfHealing: return "person.circle.fill"
        case .exPartnerHealing: return "heart.circle.fill"
        case .childrenHealing: return "figure.and.child.holdinghands"
        case .futureHealing: return "sun.max.fill"
        }
    }
    
    var dayRange: String {
        switch self {
        case .selfHealing: return "Días 1-7"
        case .exPartnerHealing: return "Días 8-14"
        case .childrenHealing: return "Días 15-18"
        case .futureHealing: return "Días 19-21"
        }
    }
}

// MARK: - Liberation Letter
struct LiberationLetter: Identifiable, Codable {
    let id = UUID()
    let day: Int
    let phase: LiberationLetterPhase
    let title: String
    let content: String
    let duration: String // en minutos
    let voiceAnchors: [String] // 3 anclas de voz
    let affirmations: [String] // 2 afirmaciones
    
    init(day: Int, phase: LiberationLetterPhase, title: String, content: String, duration: String, voiceAnchors: [String], affirmations: [String]) {
        self.day = day
        self.phase = phase
        self.title = title
        self.content = content
        self.duration = duration
        self.voiceAnchors = voiceAnchors
        self.affirmations = affirmations
    }
    
    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case day, phase, title, content, duration, voiceAnchors, affirmations
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        day = try container.decode(Int.self, forKey: .day)
        phase = try container.decode(LiberationLetterPhase.self, forKey: .phase)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        duration = try container.decode(String.self, forKey: .duration)
        voiceAnchors = try container.decode([String].self, forKey: .voiceAnchors)
        affirmations = try container.decode([String].self, forKey: .affirmations)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(day, forKey: .day)
        try container.encode(phase, forKey: .phase)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(duration, forKey: .duration)
        try container.encode(voiceAnchors, forKey: .voiceAnchors)
        try container.encode(affirmations, forKey: .affirmations)
    }
}

// MARK: - Liberation Letter Session
struct LiberationLetterSession: Identifiable, Codable {
    let id = UUID()
    let letter: LiberationLetter
    let date: Date
    let isCompleted: Bool
    let detectedAnchors: [String] // Anclas detectadas por voz
    let emotionalState: EmotionalState?
    let notes: String
    let completionTime: TimeInterval // Tiempo que tomó completar
    
    init(letter: LiberationLetter, detectedAnchors: [String] = [], emotionalState: EmotionalState? = nil, notes: String = "", completionTime: TimeInterval = 0) {
        self.letter = letter
        self.date = Date()
        self.isCompleted = !detectedAnchors.isEmpty
        self.detectedAnchors = detectedAnchors
        self.emotionalState = emotionalState
        self.notes = notes
        self.completionTime = completionTime
    }
    
    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case letter, date, isCompleted, detectedAnchors, emotionalState, notes, completionTime
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        letter = try container.decode(LiberationLetter.self, forKey: .letter)
        date = try container.decode(Date.self, forKey: .date)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        detectedAnchors = try container.decode([String].self, forKey: .detectedAnchors)
        emotionalState = try container.decodeIfPresent(EmotionalState.self, forKey: .emotionalState)
        notes = try container.decode(String.self, forKey: .notes)
        completionTime = try container.decode(TimeInterval.self, forKey: .completionTime)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(letter, forKey: .letter)
        try container.encode(date, forKey: .date)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(detectedAnchors, forKey: .detectedAnchors)
        try container.encodeIfPresent(emotionalState, forKey: .emotionalState)
        try container.encode(notes, forKey: .notes)
        try container.encode(completionTime, forKey: .completionTime)
    }
}

// MARK: - Liberation Letter Progress
struct LiberationLetterProgress: Codable {
    let phase: LiberationLetterPhase
    let completedDays: Int
    let totalDays: Int
    let lastCompletedDay: Int?
    let averageCompletionTime: TimeInterval
    let totalSessions: Int
    
    var completionPercentage: Double {
        return Double(completedDays) / Double(totalDays)
    }
    
    var isPhaseCompleted: Bool {
        return completedDays >= totalDays
    }
    
    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case phase, completedDays, totalDays, lastCompletedDay, averageCompletionTime, totalSessions
    }
    
    init(phase: LiberationLetterPhase, completedDays: Int, totalDays: Int, lastCompletedDay: Int?, averageCompletionTime: TimeInterval, totalSessions: Int) {
        self.phase = phase
        self.completedDays = completedDays
        self.totalDays = totalDays
        self.lastCompletedDay = lastCompletedDay
        self.averageCompletionTime = averageCompletionTime
        self.totalSessions = totalSessions
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        phase = try container.decode(LiberationLetterPhase.self, forKey: .phase)
        completedDays = try container.decode(Int.self, forKey: .completedDays)
        totalDays = try container.decode(Int.self, forKey: .totalDays)
        lastCompletedDay = try container.decodeIfPresent(Int.self, forKey: .lastCompletedDay)
        averageCompletionTime = try container.decode(TimeInterval.self, forKey: .averageCompletionTime)
        totalSessions = try container.decode(Int.self, forKey: .totalSessions)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(phase, forKey: .phase)
        try container.encode(completedDays, forKey: .completedDays)
        try container.encode(totalDays, forKey: .totalDays)
        try container.encodeIfPresent(lastCompletedDay, forKey: .lastCompletedDay)
        try container.encode(averageCompletionTime, forKey: .averageCompletionTime)
        try container.encode(totalSessions, forKey: .totalSessions)
    }
}

// MARK: - Voice Anchor Detection Result
struct VoiceAnchorDetectionResult {
    let detectedAnchors: [String]
    let missedAnchors: [String]
    let accuracy: Double
    let isValid: Bool // Al menos 2 de 3 anclas detectadas
    
    init(detectedAnchors: [String], totalAnchors: [String]) {
        self.detectedAnchors = detectedAnchors
        self.missedAnchors = totalAnchors.filter { !detectedAnchors.contains($0) }
        self.accuracy = Double(detectedAnchors.count) / Double(totalAnchors.count)
        self.isValid = detectedAnchors.count >= 2 // Mínimo 2 de 3 anclas
    }
}

// MARK: - Emotional State (using existing definition from EmotionModels.swift)
