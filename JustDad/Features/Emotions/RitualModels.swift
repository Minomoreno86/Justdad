//
//  RitualModels.swift
//  JustDad - Ritual de Liberación y Renovación Models
//
//  Modelos de datos para el módulo completo de Ritual de Liberación y Renovación
//

import Foundation
import SwiftUI

// MARK: - Ritual State Machine
enum RitualState: String, CaseIterable, Codable {
    case idle = "idle"
    case preparation = "preparation"
    case evocation = "evocation"
    case verbalization = "verbalization"
    case cutting = "cutting"
    case sealing = "sealing"
    case renewal = "renewal"
    case integration = "integration"
    case completed = "completed"
    case abandoned = "abandoned"
    
    var displayName: String {
        switch self {
        case .idle: return "Inicio"
        case .preparation: return "Preparación"
        case .evocation: return "Evocación"
        case .verbalization: return "Verbalización"
        case .cutting: return "Corte del Lazo"
        case .sealing: return "Sellado"
        case .renewal: return "Renovación"
        case .integration: return "Integración"
        case .completed: return "Completado"
        case .abandoned: return "Abandonado"
        }
    }
    
    var icon: String {
        switch self {
        case .idle: return "play.circle"
        case .preparation: return "wind"
        case .evocation: return "eye"
        case .verbalization: return "speaker.wave.3"
        case .cutting: return "scissors"
        case .sealing: return "shield.fill"
        case .renewal: return "leaf.arrow.circlepath"
        case .integration: return "checkmark.circle"
        case .completed: return "checkmark.seal"
        case .abandoned: return "xmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .idle: return .blue
        case .preparation: return .cyan
        case .evocation: return .purple
        case .verbalization: return .orange
        case .cutting: return .red
        case .sealing: return .yellow
        case .renewal: return .green
        case .integration: return .indigo
        case .completed: return .mint
        case .abandoned: return .gray
        }
    }
    
    var phaseName: String {
        return displayName
    }
}

// MARK: - Ritual Focus
enum RitualFocus: String, CaseIterable, Codable {
    case exPartner = "ex_partner"
    case brokenPromises = "broken_promises"
    case parentalGuilt = "parental_guilt"
    case absencePattern = "absence_pattern"
    case betrayal = "betrayal"
    case futureFear = "future_fear"
    case custom = "custom"
    
    var displayName: String {
        switch self {
        case .exPartner: return "Ex-pareja"
        case .brokenPromises: return "Promesas Rotas"
        case .parentalGuilt: return "Culpa Paterna"
        case .absencePattern: return "Patrón de Ausencia"
        case .betrayal: return "Traición"
        case .futureFear: return "Miedo al Futuro"
        case .custom: return "Personalizado"
        }
    }
    
    var prompt: String {
        switch self {
        case .exPartner: return "Nombra en voz alta lo que vas a soltar respecto a tu ex-pareja"
        case .brokenPromises: return "Nombra las promesas rotas que necesitas liberar"
        case .parentalGuilt: return "Expresa la culpa que sientes como padre"
        case .absencePattern: return "Reconoce el patrón de ausencia que quieres romper"
        case .betrayal: return "Nombra la traición que necesitas liberar"
        case .futureFear: return "Expresa los miedos al futuro que quieres soltar"
        case .custom: return "Nombra en voz alta lo que vas a liberar hoy"
        }
    }
    
    var evocationPrompt: String {
        return prompt
    }
    
    var description: String {
        switch self {
        case .exPartner: return "Liberar lazos con tu ex-pareja"
        case .brokenPromises: return "Sanar promesas rotas del pasado"
        case .parentalGuilt: return "Liberar culpa como padre"
        case .absencePattern: return "Romper patrones de ausencia"
        case .betrayal: return "Sanar traiciones del pasado"
        case .futureFear: return "Liberar miedos al futuro"
        case .custom: return "Liberación personalizada"
        }
    }
    
    var icon: String {
        switch self {
        case .exPartner: return "heart.slash"
        case .brokenPromises: return "hand.raised.slash"
        case .parentalGuilt: return "person.crop.circle.badge.minus"
        case .absencePattern: return "person.crop.circle.dashed"
        case .betrayal: return "exclamationmark.triangle"
        case .futureFear: return "eye.slash"
        case .custom: return "pencil"
        }
    }
}

// MARK: - Voice Validation Block
enum VerbalizationBlock: String, CaseIterable, Codable {
    case recognition = "recognition"
    case forgiveness = "forgiveness"
    case liberation = "liberation"
    
    var displayName: String {
        switch self {
        case .recognition: return "Reconozco"
        case .forgiveness: return "Perdono/Me perdono"
        case .liberation: return "Libero"
        }
    }
    
    var text: String {
        switch self {
        case .recognition: return "Reconozco lo que pasó y cómo me afectó"
        case .forgiveness: return "Elijo perdonar y perdonarme"
        case .liberation: return "Libero el lazo que me une a esta historia y recupero mi energía"
        }
    }
    
    var anchors: [String] {
        switch self {
        case .recognition: return ["reconozco lo que pasó", "me afectó", "hoy decido mirarlo de frente"]
        case .forgiveness: return ["te perdono y me perdono", "elijo comprensión", "me suelto de la culpa"]
        case .liberation: return ["libero este lazo", "corto el cordón", "recupero mi paz"]
        }
    }
    
    var keyPhrases: [String] {
        return anchors
    }
    
    var description: String {
        switch self {
        case .recognition: return "Reconoce lo que pasó y cómo te afectó"
        case .forgiveness: return "Elije perdonar y perdonarte"
        case .liberation: return "Libera el lazo y recupera tu energía"
        }
    }
    
    var icon: String {
        switch self {
        case .recognition: return "eye"
        case .forgiveness: return "heart"
        case .liberation: return "bird"
        }
    }
}

// MARK: - Voice Validation Result (defined in RitualVoiceValidator.swift)

// MARK: - Behavioral Vow
struct BehavioralVow: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let category: VowCategory
    let isCustom: Bool
    let reminderTime: Date?
    
    init(title: String, description: String, category: VowCategory, isCustom: Bool = false, reminderTime: Date? = nil) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.category = category
        self.isCustom = isCustom
        self.reminderTime = reminderTime
    }
    
    init(text: String, category: VowCategory, isCustom: Bool = false, reminderTime: Date? = nil) {
        self.id = UUID()
        self.title = text
        self.description = text
        self.category = category
        self.isCustom = isCustom
        self.reminderTime = reminderTime
    }
}

// MARK: - Vow Duration
enum VowDuration: String, CaseIterable, Codable {
    case twentyFourHours = "24h"
    case fortyEightHours = "48h"
    case seventyTwoHours = "72h"
}

enum VowCategory: String, CaseIterable, Codable {
    case children = "children"
    case exPartner = "ex_partner"
    case selfCare = "self_care"
    case emotional = "emotional"
    case physical = "physical"
    case spiritual = "spiritual"
    case custom = "custom"
    
    var displayName: String {
        switch self {
        case .children: return "Con mis hijos"
        case .exPartner: return "Con mi ex-pareja"
        case .selfCare: return "Autocuidado"
        case .emotional: return "Emocional"
        case .physical: return "Físico"
        case .spiritual: return "Espiritual"
        case .custom: return "Personalizado"
        }
    }
    
    var icon: String {
        switch self {
        case .children: return "figure.and.child.holdinghands"
        case .exPartner: return "person.2.slash"
        case .selfCare: return "heart.fill"
        case .emotional: return "brain.head.profile"
        case .physical: return "figure.walk"
        case .spiritual: return "leaf"
        case .custom: return "pencil"
        }
    }
    
    var color: Color {
        switch self {
        case .children: return .blue
        case .exPartner: return .red
        case .selfCare: return .green
        case .emotional: return .purple
        case .physical: return .orange
        case .spiritual: return .mint
        case .custom: return .gray
        }
    }
}

// MARK: - Ritual Emotional State
enum RitualEmotionalState: Int, CaseIterable, Codable {
    case veryLow = 1
    case low = 2
    case neutral = 3
    case good = 4
    case veryGood = 5
    
    var displayName: String {
        switch self {
        case .veryLow: return "Muy Doloroso"
        case .low: return "Doloroso"
        case .neutral: return "Neutral"
        case .good: return "Paz"
        case .veryGood: return "Muy Tranquilo"
        }
    }
    
    var color: Color {
        switch self {
        case .veryLow: return .red
        case .low: return .orange
        case .neutral: return .yellow
        case .good: return .green
        case .veryGood: return .mint
        }
    }
    
    var icon: String {
        switch self {
        case .veryLow: return "face.dashed"
        case .low: return "face.dashed.fill"
        case .neutral: return "minus.circle"
        case .good: return "face.smiling"
        case .veryGood: return "face.smiling.inverse"
        }
    }
}

// MARK: - Ritual Session
struct RitualSession: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    let endTime: Date?
    let focus: RitualFocus
    let customFocusText: String?
    let duration: TimeInterval
    let breathingCyclesCompleted: Int
    let targetBreathingCycles: Int
    var voiceValidations: [RitualVoiceValidationResult]
    let emotionalStateBefore: RitualEmotionalState
    let emotionalStateAfter: RitualEmotionalState?
    var behavioralVow: BehavioralVow?
    let vowReminderScheduled: Bool
    let vowFulfilled: Bool?
    let state: RitualState
    var notes: String?
    let isCompleted: Bool
    
    var breathingCompletionPercentage: Double {
        guard targetBreathingCycles > 0 else { return 0 }
        return Double(breathingCyclesCompleted) / Double(targetBreathingCycles)
    }
    
    var voiceValidationSuccess: Bool {
        guard !voiceValidations.isEmpty else { return false }
        return voiceValidations.allSatisfy { $0.validationPercentage >= 0.67 } // 2/3 threshold
    }
    
    var emotionalImprovement: Int? {
        guard let after = emotionalStateAfter else { return nil }
        return after.rawValue - emotionalStateBefore.rawValue
    }
    
    init(
        focus: RitualFocus,
        customFocusText: String? = nil,
        targetBreathingCycles: Int = 7,
        emotionalStateBefore: RitualEmotionalState = .neutral
    ) {
        self.id = UUID()
        self.startTime = Date()
        self.endTime = nil
        self.focus = focus
        self.customFocusText = customFocusText
        self.duration = 0
        self.breathingCyclesCompleted = 0
        self.targetBreathingCycles = targetBreathingCycles
        self.voiceValidations = []
        self.emotionalStateBefore = emotionalStateBefore
        self.emotionalStateAfter = nil
        self.behavioralVow = nil
        self.vowReminderScheduled = false
        self.vowFulfilled = nil
        self.state = .idle
        self.notes = nil
        self.isCompleted = false
    }
    
    init(
        id: UUID,
        startTime: Date,
        endTime: Date?,
        focus: RitualFocus,
        customFocusText: String?,
        duration: TimeInterval,
        breathingCyclesCompleted: Int,
        targetBreathingCycles: Int,
        voiceValidations: [RitualVoiceValidationResult],
        emotionalStateBefore: RitualEmotionalState,
        emotionalStateAfter: RitualEmotionalState?,
        behavioralVow: BehavioralVow?,
        vowReminderScheduled: Bool,
        vowFulfilled: Bool?,
        state: RitualState,
        notes: String?,
        isCompleted: Bool
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.focus = focus
        self.customFocusText = customFocusText
        self.duration = duration
        self.breathingCyclesCompleted = breathingCyclesCompleted
        self.targetBreathingCycles = targetBreathingCycles
        self.voiceValidations = voiceValidations
        self.emotionalStateBefore = emotionalStateBefore
        self.emotionalStateAfter = emotionalStateAfter
        self.behavioralVow = behavioralVow
        self.vowReminderScheduled = vowReminderScheduled
        self.vowFulfilled = vowFulfilled
        self.state = state
        self.notes = notes
        self.isCompleted = isCompleted
    }
}

// MARK: - Ritual Metrics
struct RitualMetrics: Codable {
    let totalRituals: Int
    let completedRituals: Int
    let averageDuration: TimeInterval
    let averageEmotionalImprovement: Double
    let vowsFulfilled: Int
    let vowsTotal: Int
    let currentStreak: Int
    let longestStreak: Int
    let lastRitualDate: Date?
    let favoriteFocus: RitualFocus?
    let favoriteVowCategory: VowCategory?
    
    var completionRate: Double {
        guard totalRituals > 0 else { return 0 }
        return Double(completedRituals) / Double(totalRituals)
    }
    
    var vowFulfillmentRate: Double {
        guard vowsTotal > 0 else { return 0 }
        return Double(vowsFulfilled) / Double(vowsTotal)
    }
}

// MARK: - Ritual Achievement
enum RitualAchievement: String, CaseIterable, Codable {
    case firstRitual = "first_ritual"
    case threeDayStreak = "three_day_streak"
    case sevenDayStreak = "seven_day_streak"
    case twentyOneDayStreak = "twenty_one_day_streak"
    case coparentalClosure = "coparental_closure"
    case paternalPresence = "paternal_presence"
    case rebirth = "rebirth"
    case voiceMaster = "voice_master"
    case vowKeeper = "vow_keeper"
    case emotionalHealer = "emotional_healer"
    
    var displayName: String {
        switch self {
        case .firstRitual: return "Primer Ritual"
        case .threeDayStreak: return "Racha de 3 Días"
        case .sevenDayStreak: return "Racha de 7 Días"
        case .twentyOneDayStreak: return "Racha de 21 Días"
        case .coparentalClosure: return "Cierre Coparental"
        case .paternalPresence: return "Presencia Paterna"
        case .rebirth: return "Renacer"
        case .voiceMaster: return "Maestro de la Voz"
        case .vowKeeper: return "Guardián del Voto"
        case .emotionalHealer: return "Sanador Emocional"
        }
    }
    
    var description: String {
        switch self {
        case .firstRitual: return "Completaste tu primer ritual de liberación"
        case .threeDayStreak: return "Mantuviste una racha de 3 días consecutivos"
        case .sevenDayStreak: return "Mantuviste una racha de 7 días consecutivos"
        case .twentyOneDayStreak: return "Mantuviste una racha de 21 días consecutivos"
        case .coparentalClosure: return "Realizaste 3 rituales enfocados en tu ex-pareja"
        case .paternalPresence: return "Realizaste 3 votos enfocados en tus hijos"
        case .rebirth: return "Completaste 7 rituales en 14 días"
        case .voiceMaster: return "Validaste todas las anclas de voz en 5 rituales"
        case .vowKeeper: return "Cumpliste 10 votos consecutivos"
        case .emotionalHealer: return "Mejoraste tu estado emocional en 10 rituales"
        }
    }
    
    var icon: String {
        switch self {
        case .firstRitual: return "star.fill"
        case .threeDayStreak: return "flame.fill"
        case .sevenDayStreak: return "flame.fill"
        case .twentyOneDayStreak: return "flame.fill"
        case .coparentalClosure: return "heart.slash.fill"
        case .paternalPresence: return "figure.and.child.holdinghands"
        case .rebirth: return "leaf.arrow.circlepath"
        case .voiceMaster: return "speaker.wave.3.fill"
        case .vowKeeper: return "hand.raised.fill"
        case .emotionalHealer: return "brain.head.profile"
        }
    }
    
    var color: Color {
        switch self {
        case .firstRitual: return .yellow
        case .threeDayStreak: return .orange
        case .sevenDayStreak: return .red
        case .twentyOneDayStreak: return .purple
        case .coparentalClosure: return .pink
        case .paternalPresence: return .blue
        case .rebirth: return .green
        case .voiceMaster: return .cyan
        case .vowKeeper: return .mint
        case .emotionalHealer: return .indigo
        }
    }
    
    var points: Int {
        switch self {
        case .firstRitual: return 100
        case .threeDayStreak: return 150
        case .sevenDayStreak: return 300
        case .twentyOneDayStreak: return 500
        case .coparentalClosure: return 200
        case .paternalPresence: return 250
        case .rebirth: return 400
        case .voiceMaster: return 300
        case .vowKeeper: return 350
        case .emotionalHealer: return 200
        }
    }
}

// MARK: - Safety Check
enum SafetyLevel: String, CaseIterable {
    case safe = "safe"
    case caution = "caution"
    case warning = "warning"
    case critical = "critical"
    
    var displayName: String {
        switch self {
        case .safe: return "Seguro"
        case .caution: return "Precaución"
        case .warning: return "Advertencia"
        case .critical: return "Crítico"
        }
    }
    
    var color: Color {
        switch self {
        case .safe: return .green
        case .caution: return .yellow
        case .warning: return .orange
        case .critical: return .red
        }
    }
    
    var message: String {
        switch self {
        case .safe: return "Continúa con el ritual"
        case .caution: return "Considera hacer una pausa"
        case .warning: return "Es recomendable detener el ritual"
        case .critical: return "Detén el ritual y busca apoyo"
        }
    }
}
