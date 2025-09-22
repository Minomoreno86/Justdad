//
//  PsychogenealogySupportingTypes.swift
//  JustDad - Psicogenealogía Supporting Types
//
//  Tipos de soporte para el módulo de Psicogenealogía
//  Created by Jorge Vasquez Rodriguez
//

import Foundation
import SwiftUI

// MARK: - Session Management

/// Sesión de psicogenealogía
struct PsychogenealogySession: Identifiable, Codable {
    var id = UUID()
    let letterID: UUID
    let date: Date
    var isCompleted: Bool = false
    var emotionalStateAfter: String?
    var peaceLevelAfter: Int?
    var notes: String?
    var completionTime: Double = 0
    var completedAt: Date?
    
    init(letterID: UUID, date: Date = Date(), isCompleted: Bool = false) {
        self.letterID = letterID
        self.date = date
        self.isCompleted = isCompleted
    }
}

/// Carta psicogenealógica
struct PsychogenealogyLetter: Identifiable, Codable {
    var id = UUID()
    let type: LetterType
    let title: String
    let content: String
    let voiceAnchors: [String]
    let affirmations: [String]
    let duration: Int // en minutos
    let targetPattern: PatternType
    let targetRelationship: RelationshipType
    var isUnlocked: Bool = false
    var unlockedAt: Date?
    
    init(
        type: LetterType,
        title: String,
        content: String,
        voiceAnchors: [String] = [],
        affirmations: [String] = [],
        duration: Int = 10,
        targetPattern: PatternType,
        isUnlocked: Bool = false,
        unlockedAt: Date? = nil
    ) {
        self.type = type
        self.title = title
        self.content = content
        self.voiceAnchors = voiceAnchors
        self.affirmations = affirmations
        self.duration = duration
        self.targetPattern = targetPattern
        self.targetRelationship = .parent // Valor por defecto
        self.isUnlocked = isUnlocked
        self.unlockedAt = unlockedAt
    }
}

/// Tipo de carta psicogenealógica
enum LetterType: String, CaseIterable, Codable {
    case paternalLineage = "paternal_lineage"
    case maternalLineage = "maternal_lineage"
    case divorcePattern = "divorce_pattern"
    case familySecrets = "family_secrets"
    case migrationRoots = "migration_roots"
    case integration = "integration"
    
    var displayName: String {
        switch self {
        case .paternalLineage: return "Linaje Paterno"
        case .maternalLineage: return "Linaje Materno"
        case .divorcePattern: return "Patrón de Divorcio"
        case .familySecrets: return "Secretos Familiares"
        case .migrationRoots: return "Raíces y Pertenencia"
        case .integration: return "Integración Sistémica"
        }
    }
    
    var icon: String {
        switch self {
        case .paternalLineage: return "person.2"
        case .maternalLineage: return "person.2"
        case .divorcePattern: return "heart.slash"
        case .familySecrets: return "eye.slash"
        case .migrationRoots: return "airplane"
        case .integration: return "infinity"
        }
    }
}

/// Tipo de patrón para cartas
enum PatternType: String, CaseIterable, Codable {
    case absence = "absence"
    case divorce = "divorce"
    case secrets = "secrets"
    case migration = "migration"
    case earlyDeath = "early_death"
    case addiction = "addiction"
    case violence = "violence"
    
    var displayName: String {
        switch self {
        case .absence: return "Ausencia"
        case .divorce: return "Divorcio"
        case .secrets: return "Secretos"
        case .migration: return "Migración"
        case .earlyDeath: return "Muerte Temprana"
        case .addiction: return "Adicción"
        case .violence: return "Violencia"
        }
    }
}

// MARK: - Progress Tracking

/// Progreso de sanación familiar
struct FamilyHealingProgress: Codable {
    let totalFamilyMembers: Int
    let totalPatterns: Int
    let resolvedPatterns: Int
    let completedLetters: Int
    let totalSessions: Int
    let averageCompletionTime: Double
    let lastSessionDate: Date?
    let healingStreak: Int
    let unlockedLetters: Int
    let familyTreeCompleteness: Int
    
    init(
        totalFamilyMembers: Int = 0,
        totalPatterns: Int = 0,
        resolvedPatterns: Int = 0,
        completedLetters: Int = 0,
        totalSessions: Int = 0,
        averageCompletionTime: Double = 0,
        lastSessionDate: Date? = nil,
        healingStreak: Int = 0,
        unlockedLetters: Int = 0,
        familyTreeCompleteness: Int = 0
    ) {
        self.totalFamilyMembers = totalFamilyMembers
        self.totalPatterns = totalPatterns
        self.resolvedPatterns = resolvedPatterns
        self.completedLetters = completedLetters
        self.totalSessions = totalSessions
        self.averageCompletionTime = averageCompletionTime
        self.lastSessionDate = lastSessionDate
        self.healingStreak = healingStreak
        self.unlockedLetters = unlockedLetters
        self.familyTreeCompleteness = familyTreeCompleteness
    }
}

// MARK: - Persistence Types

/// Datos completos de psicogenealogía para persistencia
struct PsychogenealogyData: Codable {
    let members: [FamilyMember]
    let relationships: [Relationship]
    let events: [FamilyEvent]
    let patterns: [Pattern]
    let sessions: [PsychogenealogySession]
}

/// Datos para exportación
struct PsychogenealogyExportData: Codable {
    let version: String
    let exportDate: Date
    let members: [FamilyMember]
    let relationships: [Relationship]
    let events: [FamilyEvent]
    let patterns: [Pattern]
    let sessions: [PsychogenealogySession]
}

/// Estrategia de importación
enum ImportMergeStrategy: String, Codable {
    case replace = "replace"
    case merge = "merge"
}

// MARK: - Persistence Manager

/// Manager de persistencia simplificado
class PsychogenealogyPersistenceManager {
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let dataURL: URL
    
    init() {
        dataURL = documentsDirectory.appendingPathComponent("psychogenealogy_data.json")
    }
    
    func loadData() async throws -> PsychogenealogyData {
        guard FileManager.default.fileExists(atPath: dataURL.path) else {
            return PsychogenealogyData(
                members: [],
                relationships: [],
                events: [],
                patterns: [],
                sessions: []
            )
        }
        
        let data = try Data(contentsOf: dataURL)
        return try JSONDecoder().decode(PsychogenealogyData.self, from: data)
    }
    
    func saveData(_ data: PsychogenealogyData) async throws {
        let encodedData = try JSONEncoder().encode(data)
        try encodedData.write(to: dataURL)
    }
}

// MARK: - Legacy Compatibility Types

/// Para mantener compatibilidad con el sistema anterior
struct FamilyPattern: Identifiable, Codable {
    var id = UUID()
    let type: PatternType
    let title: String
    let description: String
    let affectedMembers: [UUID]
    let severity: Int
    let generations: Int
    let isDetected: Bool
    let detectedDate: Date
    var isResolved: Bool = false
    var resolutionDate: Date?
    
    init(
        type: PatternType,
        title: String,
        description: String,
        affectedMembers: [UUID] = [],
        severity: Int = 1,
        generations: Int = 1,
        isDetected: Bool = true,
        detectedDate: Date = Date(),
        isResolved: Bool = false,
        resolutionDate: Date? = nil
    ) {
        self.type = type
        self.title = title
        self.description = description
        self.affectedMembers = affectedMembers
        self.severity = severity
        self.generations = generations
        self.isDetected = isDetected
        self.detectedDate = detectedDate
        self.isResolved = isResolved
        self.resolutionDate = resolutionDate
    }
}

// MARK: - Extensions

extension FamilyHealingProgress {
    /// Calcula el porcentaje de progreso general
    var overallProgress: Double {
        let patternProgress = totalPatterns > 0 ? Double(resolvedPatterns) / Double(totalPatterns) : 0
        let letterProgress = unlockedLetters > 0 ? Double(completedLetters) / Double(unlockedLetters) : 0
        let treeProgress = Double(familyTreeCompleteness) / 100.0
        
        return (patternProgress + letterProgress + treeProgress) / 3.0
    }
    
    /// Verifica si hay progreso reciente
    var hasRecentProgress: Bool {
        guard let lastSession = lastSessionDate else { return false }
        let daysSinceLastSession = Calendar.current.dateComponents([.day], from: lastSession, to: Date()).day ?? 0
        return daysSinceLastSession <= 7
    }
    
    /// Obtiene el nivel de sanación basado en métricas
    var healingLevel: HealingLevel {
        let progress = overallProgress
        
        switch progress {
        case 0.0..<0.25:
            return .beginning
        case 0.25..<0.5:
            return .developing
        case 0.5..<0.75:
            return .progressing
        case 0.75..<0.9:
            return .advanced
        case 0.9...1.0:
            return .mastery
        default:
            return .beginning
        }
    }
}

/// Nivel de sanación familiar
enum HealingLevel: String, CaseIterable, Codable {
    case beginning = "beginning"
    case developing = "developing"
    case progressing = "progressing"
    case advanced = "advanced"
    case mastery = "mastery"
    
    var displayName: String {
        switch self {
        case .beginning: return "Iniciando"
        case .developing: return "Desarrollando"
        case .progressing: return "Progresando"
        case .advanced: return "Avanzado"
        case .mastery: return "Maestría"
        }
    }
    
    var color: Color {
        switch self {
        case .beginning: return .gray
        case .developing: return .blue
        case .progressing: return .green
        case .advanced: return .orange
        case .mastery: return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .beginning: return "seedling"
        case .developing: return "leaf"
        case .progressing: return "tree"
        case .advanced: return "tree.circle"
        case .mastery: return "crown"
        }
    }
}
