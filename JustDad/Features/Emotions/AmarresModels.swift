//
//  AmarresModels.swift
//  JustDad - Corte de Amarres o Brujería Models
//
//  Modelos de datos para el módulo de liberación de amarres y brujería
//

import Foundation
import SwiftUI

// MARK: - Tipos de Amarres
public enum AmarresType: String, CaseIterable, Identifiable, Codable {
    case loveBinding = "love_binding"
    case familyBinding = "family_binding"
    case workBinding = "work_binding"
    case moneyBinding = "money_binding"
    case ancestralBinding = "ancestral_binding"
    case envyBinding = "envy_binding"
    case damageBinding = "damage_binding"
    case unknownBinding = "unknown_binding"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .loveBinding: return "Amarre de Amor"
        case .familyBinding: return "Amarre Familiar"
        case .workBinding: return "Amarre de Trabajo"
        case .moneyBinding: return "Amarre de Dinero"
        case .ancestralBinding: return "Amarre Ancestral"
        case .envyBinding: return "Envida/Maldición"
        case .damageBinding: return "Trabajo de Daño"
        case .unknownBinding: return "Amarre Desconocido"
        }
    }
    
    public var description: String {
        switch self {
        case .loveBinding: return "Vínculo romántico forzado o dependencia emocional"
        case .familyBinding: return "Dependencia familiar tóxica o lealtades invisibles"
        case .workBinding: return "Conexión laboral negativa o bloqueos profesionales"
        case .moneyBinding: return "Bloqueos financieros energéticos o dependencia material"
        case .ancestralBinding: return "Maldiciones familiares heredadas o patrones ancestrales"
        case .envyBinding: return "Energías de envidia o maldiciones dirigidas"
        case .damageBinding: return "Trabajos de daño o energías destructivas"
        case .unknownBinding: return "Influencia energética de origen desconocido"
        }
    }
    
    public var color: Color {
        switch self {
        case .loveBinding: return .pink
        case .familyBinding: return .blue
        case .workBinding: return .orange
        case .moneyBinding: return .green
        case .ancestralBinding: return .purple
        case .envyBinding: return .red
        case .damageBinding: return .black
        case .unknownBinding: return .gray
        }
    }
    
    public var icon: String {
        switch self {
        case .loveBinding: return "heart.fill"
        case .familyBinding: return "person.3.fill"
        case .workBinding: return "briefcase.fill"
        case .moneyBinding: return "dollarsign.circle.fill"
        case .ancestralBinding: return "tree.fill"
        case .envyBinding: return "eye.fill"
        case .damageBinding: return "bolt.fill"
        case .unknownBinding: return "questionmark.circle.fill"
        }
    }
}

// MARK: - Tipos de Brujería
public enum BrujeriaType: String, CaseIterable, Identifiable, Codable {
    case envyCurse = "envy_curse"
    case loveWork = "love_work"
    case damageWork = "damage_work"
    case protectionWork = "protection_work"
    case ancestralCurse = "ancestral_curse"
    case moneyBlock = "money_block"
    case healthCurse = "health_curse"
    case unknownWork = "unknown_work"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .envyCurse: return "Envida/Maldición"
        case .loveWork: return "Trabajo de Amor"
        case .damageWork: return "Trabajo de Daño"
        case .protectionWork: return "Protección"
        case .ancestralCurse: return "Maldición Ancestral"
        case .moneyBlock: return "Bloqueo de Dinero"
        case .healthCurse: return "Maldición de Salud"
        case .unknownWork: return "Trabajo Desconocido"
        }
    }
    
    public var description: String {
        switch self {
        case .envyCurse: return "Energías de envidia y maldiciones dirigidas"
        case .loveWork: return "Trabajos de amor forzado o manipulación romántica"
        case .damageWork: return "Trabajos destinados a causar daño o sufrimiento"
        case .protectionWork: return "Trabajos de protección contra energías negativas"
        case .ancestralCurse: return "Maldiciones heredadas de generaciones anteriores"
        case .moneyBlock: return "Bloqueos energéticos en el área financiera"
        case .healthCurse: return "Maldiciones que afectan la salud física o mental"
        case .unknownWork: return "Trabajo de brujería de origen desconocido"
        }
    }
    
    public var color: Color {
        switch self {
        case .envyCurse: return .red
        case .loveWork: return .pink
        case .damageWork: return .black
        case .protectionWork: return .white
        case .ancestralCurse: return .purple
        case .moneyBlock: return .green
        case .healthCurse: return .orange
        case .unknownWork: return .gray
        }
    }
    
    public var icon: String {
        switch self {
        case .envyCurse: return "eye.fill"
        case .loveWork: return "heart.fill"
        case .damageWork: return "bolt.fill"
        case .protectionWork: return "shield.fill"
        case .ancestralCurse: return "tree.fill"
        case .moneyBlock: return "dollarsign.circle.fill"
        case .healthCurse: return "cross.fill"
        case .unknownWork: return "questionmark.circle.fill"
        }
    }
}

// MARK: - Enfoque del Ritual
public enum AmarresApproach: String, CaseIterable, Identifiable, Codable {
    case secular = "secular"
    case spiritual = "spiritual"
    case traditional = "traditional"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .secular: return "Enfoque Secular"
        case .spiritual: return "Enfoque Espiritual"
        case .traditional: return "Enfoque Tradicional"
        }
    }
    
    public var description: String {
        switch self {
        case .secular: return "Liberación basada en psicología y técnicas energéticas"
        case .spiritual: return "Liberación con elementos espirituales y religiosos"
        case .traditional: return "Liberación con métodos tradicionales de limpieza"
        }
    }
}

// MARK: - Intensidad del Apego
public enum AttachmentIntensity: String, CaseIterable, Identifiable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case extreme = "extreme"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .low: return "Baja (1-3)"
        case .medium: return "Media (4-6)"
        case .high: return "Alta (7-8)"
        case .extreme: return "Extrema (9-10)"
        }
    }
    
    public var numericValue: Int {
        switch self {
        case .low: return 2
        case .medium: return 5
        case .high: return 7
        case .extreme: return 9
        }
    }
    
    public var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .extreme: return .red
        }
    }
}

// MARK: - Síntomas de Amarres
public enum AmarresSymptom: String, CaseIterable, Identifiable, Codable {
    case physicalPain = "physical_pain"
    case fatigue = "fatigue"
    case nightmares = "nightmares"
    case anxiety = "anxiety"
    case depression = "depression"
    case obsessiveThoughts = "obsessive_thoughts"
    case insomnia = "insomnia"
    case moodSwings = "mood_swings"
    case energyDrain = "energy_drain"
    case relationshipProblems = "relationship_problems"
    case workIssues = "work_issues"
    case financialBlocks = "financial_blocks"
    case healthIssues = "health_issues"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .physicalPain: return "Dolores físicos inexplicables"
        case .fatigue: return "Cansancio extremo"
        case .nightmares: return "Pesadillas recurrentes"
        case .anxiety: return "Ansiedad constante"
        case .depression: return "Depresión profunda"
        case .obsessiveThoughts: return "Pensamientos obsesivos"
        case .insomnia: return "Insomnio"
        case .moodSwings: return "Cambios de humor extremos"
        case .energyDrain: return "Pérdida de energía vital"
        case .relationshipProblems: return "Problemas en relaciones"
        case .workIssues: return "Problemas laborales"
        case .financialBlocks: return "Bloqueos financieros"
        case .healthIssues: return "Problemas de salud"
        }
    }
    
    public var title: String {
        return displayName
    }
    
    public var description: String {
        switch self {
        case .physicalPain: return "Dolores en el cuerpo sin causa médica aparente"
        case .fatigue: return "Agotamiento constante que no mejora con el descanso"
        case .nightmares: return "Sueños perturbadores que se repiten frecuentemente"
        case .anxiety: return "Sensación constante de preocupación y tensión"
        case .depression: return "Tristeza profunda y pérdida de interés en actividades"
        case .obsessiveThoughts: return "Pensamientos recurrentes que no puedes controlar"
        case .insomnia: return "Dificultad para conciliar o mantener el sueño"
        case .moodSwings: return "Cambios emocionales bruscos e incontrolables"
        case .energyDrain: return "Sensación de que te roban la energía vital"
        case .relationshipProblems: return "Conflictos constantes en relaciones personales"
        case .workIssues: return "Problemas recurrentes en el ámbito laboral"
        case .financialBlocks: return "Dificultades económicas inexplicables"
        case .healthIssues: return "Problemas de salud que no responden al tratamiento"
        }
    }
    
    public var icon: String {
        switch self {
        case .physicalPain: return "bandage"
        case .fatigue: return "bed.double"
        case .nightmares: return "moon.zzz"
        case .anxiety: return "heart.rectangle"
        case .depression: return "cloud.rain"
        case .obsessiveThoughts: return "brain.head.profile"
        case .insomnia: return "moon.stars"
        case .moodSwings: return "arrow.up.arrow.down"
        case .energyDrain: return "battery.0"
        case .relationshipProblems: return "person.2.slash"
        case .workIssues: return "briefcase.slash"
        case .financialBlocks: return "dollarsign.circle.slash"
        case .healthIssues: return "cross.case"
        }
    }
    
    public var category: SymptomCategory {
        switch self {
        case .physicalPain, .fatigue, .insomnia, .energyDrain, .healthIssues:
            return .physical
        case .anxiety, .depression, .obsessiveThoughts, .moodSwings, .nightmares:
            return .emotional
        case .relationshipProblems, .workIssues, .financialBlocks:
            return .life
        }
    }
}

public enum SymptomCategory: String, CaseIterable {
    case physical = "physical"
    case emotional = "emotional"
    case life = "life"
    
    public var displayName: String {
        switch self {
        case .physical: return "Físicos"
        case .emotional: return "Emocionales"
        case .life: return "Vida"
        }
    }
    
    public var color: Color {
        switch self {
        case .physical: return .red
        case .emotional: return .blue
        case .life: return .green
        }
    }
}

// MARK: - Estados del Ritual
public enum AmarresRitualState: String, CaseIterable, Codable {
    case idle = "idle"
    case preparation = "preparation"
    case diagnosis = "diagnosis"
    case breathing = "breathing"
    case identification = "identification"
    case cleansing = "cleansing"
    case cutting = "cutting"
    case protection = "protection"
    case sealing = "sealing"
    case completion = "completion"
    case abandoned = "abandoned"
    
    public var displayName: String {
        switch self {
        case .idle: return "Inactivo"
        case .preparation: return "Preparación"
        case .diagnosis: return "Diagnóstico"
        case .breathing: return "Respiración"
        case .identification: return "Identificación"
        case .cleansing: return "Limpieza"
        case .cutting: return "Corte"
        case .protection: return "Protección"
        case .sealing: return "Sellado"
        case .completion: return "Completado"
        case .abandoned: return "Abandonado"
        }
    }
}

// MARK: - Sesión de Amarres
public struct AmarresSession: Identifiable, Codable {
    public let id = UUID()
    public let startTime: Date
    public var endTime: Date?
    public var state: AmarresRitualState = .preparation
    public var approach: AmarresApproach
    public var bindingType: AmarresType?
    public var witchcraftType: BrujeriaType?
    public var intensityBefore: AttachmentIntensity
    public var intensityAfter: AttachmentIntensity?
    public var symptoms: [AmarresSymptom] = []
    public var identifiedBindings: [String] = []
    public var cleansingElements: [String] = []
    public var protectionVow: String = ""
    public var notes: String = ""
    public var isCompleted: Bool = false
    
    public init(
        approach: AmarresApproach,
        intensityBefore: AttachmentIntensity
    ) {
        self.startTime = Date()
        self.approach = approach
        self.intensityBefore = intensityBefore
    }
}

// MARK: - Resultado de Validación de Voz
public struct AmarresVoiceValidation: Codable {
    public let isValid: Bool
    public let accuracy: Double
    public let phrasesDetected: [String]
    public let missingPhrases: [String]
    public let timestamp: Date
    
    public init(
        isValid: Bool,
        accuracy: Double,
        phrasesDetected: [String],
        missingPhrases: [String]
    ) {
        self.isValid = isValid
        self.accuracy = accuracy
        self.phrasesDetected = phrasesDetected
        self.missingPhrases = missingPhrases
        self.timestamp = Date()
    }
}

// MARK: - Voto de Protección
public struct ProtectionVow: Identifiable, Codable {
    public let id = UUID()
    public let title: String
    public let description: String
    public let duration: AmarresVowDuration
    public let isCustom: Bool
    
    public init(
        title: String,
        description: String,
        duration: AmarresVowDuration,
        isCustom: Bool = false
    ) {
        self.title = title
        self.description = description
        self.duration = duration
        self.isCustom = isCustom
    }
}

public enum AmarresVowDuration: String, CaseIterable, Identifiable, Codable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case permanent = "permanent"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .daily: return "Diario"
        case .weekly: return "Semanal"
        case .monthly: return "Mensual"
        case .permanent: return "Permanente"
        }
    }
    
    public var description: String {
        switch self {
        case .daily: return "Renovación diaria de protección"
        case .weekly: return "Protección semanal activa"
        case .monthly: return "Protección mensual reforzada"
        case .permanent: return "Protección permanente sellada"
        }
    }
    
    public var days: Int {
        switch self {
        case .daily: return 1
        case .weekly: return 7
        case .monthly: return 30
        case .permanent: return 365
        }
    }
}

// MARK: - Estadísticas de Amarres
public struct AmarresStats: Codable {
    public var totalSessions: Int = 0
    public var completedSessions: Int = 0
    public var bindingsBroken: Int = 0
    public var protectionDays: Int = 0
    public var currentStreak: Int = 0
    public var longestStreak: Int = 0
    public var averageIntensityReduction: Double = 0.0
    public var lastSessionDate: Date?
    public var favoriteApproach: AmarresApproach?
    public var mostCommonBindingType: AmarresType?
}

// MARK: - Racha de Protección
public struct ProtectionStreak: Codable {
    public var currentStreak: Int = 0
    public var longestStreak: Int = 0
    public var lastProtectionDate: Date?
    public var streakBroken: Bool = false
    
    public var isActive: Bool {
        guard let lastDate = lastProtectionDate else { return false }
        return Calendar.current.isDate(lastDate, inSameDayAs: Date()) || 
               Calendar.current.isDate(lastDate, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())
    }
}

// MARK: - Puntos de Amarres
public struct AmarresPoints: Codable {
    public var totalPoints: Int = 0
    public var cleansingPoints: Int = 0
    public var protectionPoints: Int = 0
    public var liberationPoints: Int = 0
    public var masteryPoints: Int = 0
    public var currentLevel: AmarresLevel = .novice
    public var pointsToNextLevel: Int = 100
    
    public mutating func addPoints(_ points: Int, type: PointsType) {
        totalPoints += points
        
        switch type {
        case .cleansing:
            cleansingPoints += points
        case .protection:
            protectionPoints += points
        case .liberation:
            liberationPoints += points
        case .mastery:
            masteryPoints += points
        }
        
        updateLevel()
    }
    
    private mutating func updateLevel() {
        let newLevel = AmarresLevel.level(for: totalPoints)
        if newLevel != currentLevel {
            currentLevel = newLevel
            pointsToNextLevel = newLevel.nextLevelPoints - totalPoints
        }
    }
}

public enum PointsType: String, CaseIterable, Codable {
    case cleansing = "cleansing"
    case protection = "protection"
    case liberation = "liberation"
    case mastery = "mastery"
    
    public var displayName: String {
        switch self {
        case .cleansing: return "Limpieza"
        case .protection: return "Protección"
        case .liberation: return "Liberación"
        case .mastery: return "Maestría"
        }
    }
}

// MARK: - Niveles de Amarres
public enum AmarresLevel: String, CaseIterable, Identifiable, Codable {
    case novice = "novice"
    case apprentice = "apprentice"
    case guardian = "guardian"
    case protector = "protector"
    case master = "master"
    case grandmaster = "grandmaster"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .novice: return "Novato de la Luz"
        case .apprentice: return "Aprendiz Energético"
        case .guardian: return "Guardián Energético"
        case .protector: return "Protector de la Luz"
        case .master: return "Maestro de la Luz"
        case .grandmaster: return "Gran Maestro Energético"
        }
    }
    
    public var requiredPoints: Int {
        switch self {
        case .novice: return 0
        case .apprentice: return 100
        case .guardian: return 300
        case .protector: return 600
        case .master: return 1000
        case .grandmaster: return 1500
        }
    }
    
    public var nextLevelPoints: Int {
        switch self {
        case .novice: return 100
        case .apprentice: return 300
        case .guardian: return 600
        case .protector: return 1000
        case .master: return 1500
        case .grandmaster: return 2000
        }
    }
    
    public var color: Color {
        switch self {
        case .novice: return .gray
        case .apprentice: return .blue
        case .guardian: return .green
        case .protector: return .purple
        case .master: return .orange
        case .grandmaster: return .yellow
        }
    }
    
    public var icon: String {
        switch self {
        case .novice: return "star.fill"
        case .apprentice: return "star.circle.fill"
        case .guardian: return "shield.fill"
        case .protector: return "shield.checkered"
        case .master: return "crown.fill"
        case .grandmaster: return "crown.circle.fill"
        }
    }
    
    public static func level(for points: Int) -> AmarresLevel {
        switch points {
        case 0..<100: return .novice
        case 100..<300: return .apprentice
        case 300..<600: return .guardian
        case 600..<1000: return .protector
        case 1000..<1500: return .master
        default: return .grandmaster
        }
    }
}

// MARK: - Logro de Amarres
public struct AmarresAchievement: Identifiable, Codable, Hashable {
    public let id = UUID()
    public let title: String
    public let description: String
    public let icon: String
    public let color: String
    public let requirement: AchievementRequirement
    public let reward: AchievementReward
    public let isUnlocked: Bool
    public let unlockedDate: Date?
    
    public init(
        title: String,
        description: String,
        icon: String,
        color: String,
        requirement: AchievementRequirement,
        reward: AchievementReward,
        isUnlocked: Bool = false,
        unlockedDate: Date? = nil
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.color = color
        self.requirement = requirement
        self.reward = reward
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
    }
}

// MARK: - Requisitos de Logros
public enum AchievementRequirement: Codable, Hashable {
    case sessionsCompleted(Int)
    case bindingsBroken(Int)
    case protectionDays(Int)
    case streakDays(Int)
    case levelReached(AmarresLevel)
    case pointsEarned(Int, PointsType)
    case approachUsed(AmarresApproach)
    case bindingTypeBroken(AmarresType)
    
    public var description: String {
        switch self {
        case .sessionsCompleted(let count):
            return "Completar \(count) sesiones"
        case .bindingsBroken(let count):
            return "Romper \(count) amarres"
        case .protectionDays(let days):
            return "Mantener protección por \(days) días"
        case .streakDays(let days):
            return "Racha de \(days) días"
        case .levelReached(let level):
            return "Alcanzar nivel \(level.displayName)"
        case .pointsEarned(let points, let type):
            return "Ganar \(points) puntos de \(type.displayName)"
        case .approachUsed(let approach):
            return "Usar enfoque \(approach.displayName)"
        case .bindingTypeBroken(let type):
            return "Romper amarre de tipo \(type.displayName)"
        }
    }
}

// MARK: - Recompensas de Logros
public struct AchievementReward: Codable, Hashable {
    public let points: Int
    public let pointsType: PointsType
    public let title: String
    public let description: String
    
    public init(
        points: Int,
        pointsType: PointsType,
        title: String,
        description: String
    ) {
        self.points = points
        self.pointsType = pointsType
        self.title = title
        self.description = description
    }
}
