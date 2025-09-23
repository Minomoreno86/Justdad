//
//  KarmicModels.swift
//  JustDad - Karmic Bonds Liberation Models
//
//  Modelos de datos para el módulo de Vínculos Pesados
//

import Foundation
import SwiftUI

// MARK: - Karmic Breathing Phase
public enum KarmicBreathingPhase: String, CaseIterable, Identifiable, Codable {
    case inhale = "inhale"
    case hold = "hold"
    case exhale = "exhale"
    case pause = "pause"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .inhale: return "Inhalar"
        case .hold: return "Mantener"
        case .exhale: return "Exhalar"
        case .pause: return "Pausa"
        }
    }
    
    public var duration: Double {
        switch self {
        case .inhale: return 4.0
        case .hold: return 4.0
        case .exhale: return 6.0
        case .pause: return 2.0
        }
    }
}

// MARK: - Karmic Bond Types
public enum KarmicBondType: String, CaseIterable, Identifiable, Codable {
    case exPartner = "ex_partner"
    case ancestralLoyalty = "ancestral_loyalty"
    case emotionalDebt = "emotional_debt"
    case soulBond = "soul_bond"
    case betrayalRumination = "betrayal_rumination"
    case brokenPromises = "broken_promises"
    case emotionalDependency = "emotional_dependency"
    case projectionBurden = "projection_burden"
    case controlStruggle = "control_struggle"
    case unrequitedSoul = "unrequited_soul"
    case descendantsPast = "descendants_past"
    case descendantsFuture = "descendants_future"
    case karmicLineage = "karmic_lineage"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .exPartner: return "Expareja no resuelta"
        case .ancestralLoyalty: return "Lealtad ancestral"
        case .emotionalDebt: return "Deuda emocional"
        case .soulBond: return "Vínculo de alma no correspondido"
        case .betrayalRumination: return "Rumiación por traición"
        case .brokenPromises: return "Promesas rotas"
        case .emotionalDependency: return "Dependencia emocional"
        case .projectionBurden: return "Proyecciones asumidas"
        case .controlStruggle: return "Lucha por control"
        case .unrequitedSoul: return "Amor de alma no correspondido"
        case .descendantsPast: return "Descendientes de vidas pasadas"
        case .descendantsFuture: return "Descendientes de vidas futuras"
        case .karmicLineage: return "Línea kármica completa"
        }
    }
    
    public var description: String {
        switch self {
        case .exPartner: return "Conexión emocional pendiente con expareja"
        case .ancestralLoyalty: return "Lealtad invisible a patrones familiares"
        case .emotionalDebt: return "Culpa o sensación de 'te debo'"
        case .soulBond: return "Vínculo espiritual no correspondido"
        case .betrayalRumination: return "Pensamientos obsesivos sobre traición"
        case .brokenPromises: return "Expectativas no cumplidas que aún atan"
        case .emotionalDependency: return "Atención excesiva a lo que no controlas"
        case .projectionBurden: return "Cargas emocionales que no te corresponden"
        case .controlStruggle: return "Necesidad de controlar lo incontrolable"
        case .unrequitedSoul: return "Amor profundo no correspondido"
        case .descendantsPast: return "Vínculos con descendientes de vidas anteriores"
        case .descendantsFuture: return "Conexiones con descendientes de vidas futuras"
        case .karmicLineage: return "Liberación completa de la línea kármica familiar"
        }
    }
}

// MARK: - Karmic Approach
public enum KarmicApproach: String, CaseIterable, Identifiable, Codable {
    case secular = "secular"
    case spiritual = "spiritual"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .secular: return "Enfoque Secular"
        case .spiritual: return "Enfoque Espiritual"
        }
    }
    
    public var description: String {
        switch self {
        case .secular: return "Liberación basada en psicología y autocuidado"
        case .spiritual: return "Liberación basada en sanación del alma y karma"
        }
    }
    
    public var color: Color {
        switch self {
        case .secular: return .blue
        case .spiritual: return .purple
        }
    }
}

// MARK: - Karmic Ritual State
public enum KarmicRitualState: String, CaseIterable, Codable {
    case idle = "idle"
    case preparation = "preparation"
    case breathing = "breathing"
    case evocation = "evocation"
    case recognition = "recognition"
    case liberation = "liberation"
    case returning = "returning"
    case cutting = "cutting"
    case sealing = "sealing"
    case renewal = "renewal"
    case completed = "completed"
    case abandoned = "abandoned"
    
    public var phaseName: String {
        switch self {
        case .idle: return "Inicio"
        case .preparation: return "Preparación"
        case .breathing: return "Respiración"
        case .evocation: return "Evocación"
        case .recognition: return "Reconozco"
        case .liberation: return "Libero"
        case .returning: return "Devuelvo"
        case .cutting: return "Corte Simbólico"
        case .sealing: return "Sellado"
        case .renewal: return "Renovación"
        case .completed: return "Completado"
        case .abandoned: return "Abandonado"
        }
    }
    
    public var order: Int {
        switch self {
        case .idle: return 0
        case .preparation: return 1
        case .breathing: return 2
        case .evocation: return 3
        case .recognition: return 4
        case .liberation: return 5
        case .returning: return 6
        case .cutting: return 7
        case .sealing: return 8
        case .renewal: return 9
        case .completed: return 10
        case .abandoned: return 11
        }
    }
}

// MARK: - Karmic Reading Block
public enum KarmicReadingBlock: String, CaseIterable, Codable {
    case recognition = "recognition"
    case liberation = "liberation"
    case returning = "returning"
    
    public var displayName: String {
        switch self {
        case .recognition: return "Reconozco"
        case .liberation: return "Libero"
        case .returning: return "Devuelvo"
        }
    }
    
    public var description: String {
        switch self {
        case .recognition: return "Reconocer el impacto y aprendizaje"
        case .liberation: return "Liberar el vínculo y recuperar energía"
        case .returning: return "Devolver lo ajeno y recuperar lo propio"
        }
    }
    
    public var color: Color {
        switch self {
        case .recognition: return .orange
        case .liberation: return .red
        case .returning: return .green
        }
    }
}

// MARK: - Karmic Voice Validation
public struct KarmicVoiceValidation: Identifiable, Codable {
    public let id = UUID()
    public let block: KarmicReadingBlock
    public let validatedAnchors: [String]
    public let totalAnchors: [String]
    public let validationPercentage: Double
    public let timestamp: Date
    public let success: Bool
    
    public init(block: KarmicReadingBlock, validatedAnchors: [String], totalAnchors: [String]) {
        self.block = block
        self.validatedAnchors = validatedAnchors
        self.totalAnchors = totalAnchors
        self.validationPercentage = Double(validatedAnchors.count) / Double(totalAnchors.count)
        self.timestamp = Date()
        self.success = validationPercentage >= (2.0/3.0) // ≥ 2/3 required
    }
}

// MARK: - Behavioral Vow
public struct KarmicBehavioralVow: Identifiable, Codable {
    public let id = UUID()
    public let title: String
    public let duration: VowDuration
    public let category: VowCategory
    public let isCustom: Bool
    public let reminderDate: Date?
    
    public enum VowDuration: String, CaseIterable, Codable {
        case twentyFourHours = "24h"
        case fortyEightHours = "48h"
        case seventyTwoHours = "72h"
        
        public var displayName: String {
            switch self {
            case .twentyFourHours: return "24 horas"
            case .fortyEightHours: return "48 horas"
            case .seventyTwoHours: return "72 horas"
            }
        }
        
        public var hours: Int {
            switch self {
            case .twentyFourHours: return 24
            case .fortyEightHours: return 48
            case .seventyTwoHours: return 72
            }
        }
    }
    
    public enum VowCategory: String, CaseIterable, Codable {
        case noContact = "no_contact"
        case digitalHygiene = "digital_hygiene"
        case selfCare = "self_care"
        case coparenting = "coparenting"
        case mindfulness = "mindfulness"
        case physicalActivity = "physical_activity"
        
        public var displayName: String {
            switch self {
            case .noContact: return "No Contacto"
            case .digitalHygiene: return "Higiene Digital"
            case .selfCare: return "Autocuidado"
            case .coparenting: return "Coparentalidad"
            case .mindfulness: return "Mindfulness"
            case .physicalActivity: return "Actividad Física"
            }
        }
        
        public var icon: String {
            switch self {
            case .noContact: return "hand.raised.fill"
            case .digitalHygiene: return "iphone.slash"
            case .selfCare: return "heart.fill"
            case .coparenting: return "person.2.fill"
            case .mindfulness: return "leaf.fill"
            case .physicalActivity: return "figure.walk"
            }
        }
    }
}

// MARK: - Karmic Session
public struct KarmicSession: Identifiable, Codable {
    public let id: UUID
    public let startTime: Date
    public let endTime: Date?
    public let bondType: KarmicBondType
    public let approach: KarmicApproach
    public let bondName: String
    public let intensityBefore: Int // 1-5 scale
    public let intensityAfter: Int? // 1-5 scale
    public let voiceValidations: [KarmicVoiceValidation]
    public let behavioralVow: KarmicBehavioralVow?
    public let vowCompleted: Bool?
    public let state: KarmicRitualState
    public let notes: String?
    public let isCompleted: Bool
    
    public init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        endTime: Date? = nil,
        bondType: KarmicBondType,
        approach: KarmicApproach,
        bondName: String,
        intensityBefore: Int,
        intensityAfter: Int? = nil,
        voiceValidations: [KarmicVoiceValidation] = [],
        behavioralVow: KarmicBehavioralVow? = nil,
        vowCompleted: Bool? = nil,
        state: KarmicRitualState = .idle,
        notes: String? = nil,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.bondType = bondType
        self.approach = approach
        self.bondName = bondName
        self.intensityBefore = intensityBefore
        self.intensityAfter = intensityAfter
        self.voiceValidations = voiceValidations
        self.behavioralVow = behavioralVow
        self.vowCompleted = vowCompleted
        self.state = state
        self.notes = notes
        self.isCompleted = isCompleted
    }
    
    public var duration: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
    
    public var intensityImprovement: Int? {
        guard let intensityAfter = intensityAfter else { return nil }
        return intensityBefore - intensityAfter // Positive means improvement
    }
    
    public var allVoiceValidationsSuccessful: Bool {
        return voiceValidations.allSatisfy { $0.success }
    }
}

// MARK: - Karmic Progress
public struct KarmicProgress: Identifiable, Codable {
    public let id = UUID()
    public let totalSessions: Int
    public let completedSessions: Int
    public let currentStreak: Int
    public let bestStreak: Int
    public let totalPoints: Int
    public let averageIntensityImprovement: Double
    public let lastSessionDate: Date?
    public let vowsCompleted: Int
    public let vowsTotal: Int
    
    public var completionRate: Double {
        guard totalSessions > 0 else { return 0 }
        return Double(completedSessions) / Double(totalSessions)
    }
    
    public var vowCompletionRate: Double {
        guard vowsTotal > 0 else { return 0 }
        return Double(vowsCompleted) / Double(vowsTotal)
    }
}

// MARK: - Karmic Achievement
public enum KarmicAchievement: String, CaseIterable, Identifiable, Codable {
    case firstLiberation = "first_liberation"
    case bondCutter = "bond_cutter"
    case ancestralLiberator = "ancestral_liberator"
    case lightSoul = "light_soul"
    case vowKeeper = "vow_keeper"
    case streakMaster = "streak_master"
    case intensityMaster = "intensity_master"
    case voiceMaster = "voice_master"
    
    public var id: String { rawValue }
    
    public var title: String {
        switch self {
        case .firstLiberation: return "Primera Liberación"
        case .bondCutter: return "Cortador de Lazos"
        case .ancestralLiberator: return "Liberador Ancestral"
        case .lightSoul: return "Alma Ligera"
        case .vowKeeper: return "Guardián de Promesas"
        case .streakMaster: return "Maestro de Rachas"
        case .intensityMaster: return "Maestro de Intensidad"
        case .voiceMaster: return "Maestro de la Voz"
        }
    }
    
    public var description: String {
        switch self {
        case .firstLiberation: return "Completa tu primera sesión de liberación"
        case .bondCutter: return "Completa 3 sesiones de liberación"
        case .ancestralLiberator: return "Libera un vínculo ancestral"
        case .lightSoul: return "Completa 21 sesiones de liberación"
        case .vowKeeper: return "Cumple 5 votos consecutivos"
        case .streakMaster: return "Mantén una racha de 7 días"
        case .intensityMaster: return "Mejora la intensidad en 3 puntos"
        case .voiceMaster: return "Completa 10 validaciones de voz perfectas"
        }
    }
    
    public var icon: String {
        switch self {
        case .firstLiberation: return "star.fill"
        case .bondCutter: return "scissors"
        case .ancestralLiberator: return "tree.circle.fill"
        case .lightSoul: return "sparkles"
        case .vowKeeper: return "hand.raised.fill"
        case .streakMaster: return "flame.fill"
        case .intensityMaster: return "chart.line.uptrend.xyaxis"
        case .voiceMaster: return "mic.fill"
        }
    }
    
    public var color: Color {
        switch self {
        case .firstLiberation: return .yellow
        case .bondCutter: return .red
        case .ancestralLiberator: return .green
        case .lightSoul: return .purple
        case .vowKeeper: return .blue
        case .streakMaster: return .orange
        case .intensityMaster: return .indigo
        case .voiceMaster: return .pink
        }
    }
    
    public var pointsReward: Int {
        switch self {
        case .firstLiberation: return 100
        case .bondCutter: return 150
        case .ancestralLiberator: return 200
        case .lightSoul: return 500
        case .vowKeeper: return 300
        case .streakMaster: return 400
        case .intensityMaster: return 250
        case .voiceMaster: return 350
        }
    }
}
