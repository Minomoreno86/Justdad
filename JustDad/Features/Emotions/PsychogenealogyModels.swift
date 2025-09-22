//
//  PsychogenealogyModels.swift
//  JustDad - Psicogenealogía Core Models
//
//  Arquitectura limpia para el módulo de Psicogenealogía
//  Created by Jorge Vasquez Rodriguez
//

import Foundation
import SwiftUI

// MARK: - Core Entities

/// Entidad núcleo que representa un miembro de la familia
struct FamilyMember: Identifiable, Codable, Equatable {
    var id = UUID()
    let givenName: String
    let familyName: String
    let displayName: String
    let sex: Sex
    let birthDate: Date?
    let deathDate: Date?
    let notes: String
    let tags: [String]
    let isAlive: Bool
    let isPresent: Bool // Si está presente en la vida del usuario
    let createdAt: Date
    let updatedAt: Date
    
    init(
        givenName: String,
        familyName: String,
        sex: Sex,
        birthDate: Date? = nil,
        deathDate: Date? = nil,
        notes: String = "",
        tags: [String] = [],
        isAlive: Bool = true,
        isPresent: Bool = true
    ) {
        self.givenName = givenName
        self.familyName = familyName
        self.displayName = "\(givenName) \(familyName)".trimmingCharacters(in: .whitespaces)
        self.sex = sex
        self.birthDate = birthDate
        self.deathDate = deathDate
        self.notes = notes
        self.tags = tags
        self.isAlive = isAlive
        self.isPresent = isPresent
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

/// Sexo del miembro de la familia
enum Sex: String, CaseIterable, Codable {
    case male = "male"
    case female = "female"
    case other = "other"
    case unknown = "unknown"
    
    var displayName: String {
        switch self {
        case .male: return "Masculino"
        case .female: return "Femenino"
        case .other: return "Otro"
        case .unknown: return "No especificado"
        }
    }
    
    var icon: String {
        switch self {
        case .male: return "person.fill"
        case .female: return "person.fill"
        case .other: return "person.fill"
        case .unknown: return "person.fill"
        }
    }
}

/// Relación entre dos miembros de la familia
struct Relationship: Identifiable, Codable, Equatable {
    var id = UUID()
    let type: RelationshipType
    let fromMemberID: UUID
    let toMemberID: UUID
    let startDate: Date?
    let endDate: Date?
    let notes: String
    let createdAt: Date
    let updatedAt: Date
    
    init(
        type: RelationshipType,
        fromMemberID: UUID,
        toMemberID: UUID,
        startDate: Date? = nil,
        endDate: Date? = nil,
        notes: String = ""
    ) {
        self.type = type
        self.fromMemberID = fromMemberID
        self.toMemberID = toMemberID
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

/// Tipo de relación familiar
enum RelationshipType: String, CaseIterable, Codable {
    case parent = "parent"
    case partner = "partner"
    case sibling = "sibling"
    case child = "child"
    case grandparent = "grandparent"
    case grandchild = "grandchild"
    case uncle = "uncle"
    case aunt = "aunt"
    case cousin = "cousin"
    case nephew = "nephew"
    case niece = "niece"
    case exPartner = "ex_partner"
    
    var displayName: String {
        switch self {
        case .parent: return "Padre/Madre"
        case .partner: return "Pareja"
        case .sibling: return "Hermano/Hermana"
        case .child: return "Hijo/Hija"
        case .grandparent: return "Abuelo/Abuela"
        case .grandchild: return "Nieto/Nieta"
        case .uncle: return "Tío"
        case .aunt: return "Tía"
        case .cousin: return "Primo/Prima"
        case .nephew: return "Sobrino"
        case .niece: return "Sobrina"
        case .exPartner: return "Ex pareja"
        }
    }
    
    var isDirectLineage: Bool {
        switch self {
        case .parent, .child, .grandparent, .grandchild:
            return true
        default:
            return false
        }
    }
}

/// Evento significativo en la historia familiar
struct FamilyEvent: Identifiable, Codable, Equatable {
    var id = UUID()
    let memberID: UUID? // Opcional si es de línea
    let lineage: Lineage
    let kind: EventKind
    let date: Date?
    let location: String?
    let severity: Int // 1-5
    let notes: String
    let isSecret: Bool
    let createdAt: Date
    let updatedAt: Date
    
    init(
        memberID: UUID? = nil,
        lineage: Lineage,
        kind: EventKind,
        date: Date? = nil,
        location: String? = nil,
        severity: Int = 1,
        notes: String = "",
        isSecret: Bool = false
    ) {
        self.memberID = memberID
        self.lineage = lineage
        self.kind = kind
        self.date = date
        self.location = location
        self.severity = max(1, min(5, severity)) // Clamp between 1-5
        self.notes = notes
        self.isSecret = isSecret
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

/// Linaje familiar
enum Lineage: String, CaseIterable, Codable {
    case paternal = "paternal"
    case maternal = "maternal"
    case mixed = "mixed"
    case unknown = "unknown"
    
    var displayName: String {
        switch self {
        case .paternal: return "Línea Paterna"
        case .maternal: return "Línea Materna"
        case .mixed: return "Línea Mixta"
        case .unknown: return "Línea Desconocida"
        }
    }
    
    var color: Color {
        switch self {
        case .paternal: return .blue
        case .maternal: return .pink
        case .mixed: return .purple
        case .unknown: return .gray
        }
    }
}

/// Tipo de evento familiar
enum EventKind: String, CaseIterable, Codable {
    case divorce = "divorce"
    case absence = "absence"
    case migration = "migration"
    case death = "death"
    case disease = "disease"
    case secret = "secret"
    case trauma = "trauma"
    case violence = "violence"
    case addiction = "addiction"
    case bankruptcy = "bankruptcy"
    case infidelity = "infidelity"
    case childLoss = "child_loss"
    case abortion = "abortion"
    case war = "war"
    case poverty = "poverty"
    case success = "success"
    case education = "education"
    case career = "career"
    
    var displayName: String {
        switch self {
        case .divorce: return "Divorcio"
        case .absence: return "Ausencia"
        case .migration: return "Migración"
        case .death: return "Muerte"
        case .disease: return "Enfermedad"
        case .secret: return "Secreto"
        case .trauma: return "Trauma"
        case .violence: return "Violencia"
        case .addiction: return "Adicción"
        case .bankruptcy: return "Quiebra"
        case .infidelity: return "Infidelidad"
        case .childLoss: return "Pérdida de hijo"
        case .abortion: return "Aborto"
        case .war: return "Guerra"
        case .poverty: return "Pobreza"
        case .success: return "Éxito"
        case .education: return "Educación"
        case .career: return "Carrera"
        }
    }
    
    var icon: String {
        switch self {
        case .divorce: return "heart.slash"
        case .absence: return "person.badge.minus"
        case .migration: return "airplane"
        case .death: return "cross.fill"
        case .disease: return "cross.case"
        case .secret: return "eye.slash"
        case .trauma: return "exclamationmark.triangle"
        case .violence: return "hand.raised"
        case .addiction: return "pills"
        case .bankruptcy: return "banknote"
        case .infidelity: return "heart.break"
        case .childLoss: return "heart.circle"
        case .abortion: return "heart.circle"
        case .war: return "shield"
        case .poverty: return "dollarsign.circle"
        case .success: return "star.fill"
        case .education: return "graduationcap"
        case .career: return "briefcase"
        }
    }
    
    var color: Color {
        switch self {
        case .divorce, .infidelity: return .red
        case .absence, .trauma: return .orange
        case .migration: return .blue
        case .death: return .black
        case .disease: return .yellow
        case .secret: return .purple
        case .violence: return .red
        case .addiction: return .brown
        case .bankruptcy, .poverty: return .gray
        case .childLoss, .abortion: return .pink
        case .war: return .red
        case .success: return .green
        case .education: return .blue
        case .career: return .indigo
        }
    }
}

// MARK: - Projection Views

/// Camino ascendente desde un miembro hacia cierta generación
struct LineagePath: Identifiable, Codable {
    var id = UUID()
    let rootMemberID: UUID
    let targetGeneration: Int
    let path: [UUID] // IDs de miembros en orden ascendente
    let lineage: Lineage
    let depth: Int
    
    init(rootMemberID: UUID, targetGeneration: Int, path: [UUID], lineage: Lineage) {
        self.rootMemberID = rootMemberID
        self.targetGeneration = targetGeneration
        self.path = path
        self.lineage = lineage
        self.depth = path.count
    }
}

/// Evidencia que respalda un patrón detectado
struct PatternEvidence: Identifiable, Codable {
    var id = UUID()
    let memberID: UUID
    let eventID: UUID?
    let relationshipID: UUID?
    let evidenceType: EvidenceType
    let description: String
    let weight: Double // 0.0 - 1.0
    
    enum EvidenceType: String, Codable {
        case event = "event"
        case relationship = "relationship"
        case generational = "generational"
        case temporal = "temporal"
        case statistical = "statistical"
    }
}

/// Patrón detectado por el motor de reglas
struct Pattern: Identifiable, Codable {
    var id = UUID()
    let name: String
    let description: String
    let evidence: [PatternEvidence]
    let score: Int // 0-100
    let lineage: Lineage
    let recommendations: [String]
    let lettersToUnlock: [UUID] // IDs de cartas psicogenealógicas
    let detectedAt: Date
    let isResolved: Bool
    let resolvedAt: Date?
    
    init(
        name: String,
        description: String,
        evidence: [PatternEvidence] = [],
        score: Int,
        lineage: Lineage,
        recommendations: [String] = [],
        lettersToUnlock: [UUID] = []
    ) {
        self.name = name
        self.description = description
        self.evidence = evidence
        self.score = max(0, min(100, score)) // Clamp between 0-100
        self.lineage = lineage
        self.recommendations = recommendations
        self.lettersToUnlock = lettersToUnlock
        self.detectedAt = Date()
        self.isResolved = false
        self.resolvedAt = nil
    }
}

// MARK: - Tree Structure

/// Nodo del árbol familiar para visualización
struct TreeNode: Identifiable, Codable {
    var id = UUID()
    let memberID: UUID
    let generationDepth: Int
    let lineage: Lineage
    let position: CGPoint // Para auto-layout
    let isExpanded: Bool
    let hasChildren: Bool
    
    init(memberID: UUID, generationDepth: Int, lineage: Lineage, position: CGPoint = .zero) {
        self.memberID = memberID
        self.generationDepth = generationDepth
        self.lineage = lineage
        self.position = position
        self.isExpanded = false
        self.hasChildren = false
    }
}

/// Arista del árbol familiar para visualización
struct TreeEdge: Identifiable, Codable {
    var id = UUID()
    let fromNodeID: UUID
    let toNodeID: UUID
    let relationshipType: RelationshipType
    let isActive: Bool // Si la relación sigue activa
    let path: [CGPoint] // Puntos para dibujar la línea
    
    init(fromNodeID: UUID, toNodeID: UUID, relationshipType: RelationshipType, isActive: Bool = true) {
        self.fromNodeID = fromNodeID
        self.toNodeID = toNodeID
        self.relationshipType = relationshipType
        self.isActive = isActive
        self.path = []
    }
}

// MARK: - Legacy Compatibility

/// Para mantener compatibilidad con el sistema anterior
typealias FamilyRelationship = RelationshipType
typealias FamilyEventType = EventKind
typealias EmotionalConnection = String // Simplificado para compatibilidad
typealias FamilyTreeNode = TreeNode

// MARK: - Extensions

extension FamilyMember {
    /// Calcula la edad actual o al momento de la muerte
    func age(at date: Date = Date()) -> Int? {
        guard let birth = birthDate else { return nil }
        
        let endDate = deathDate ?? date
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birth, to: endDate)
        return ageComponents.year
    }
    
    /// Verifica si el miembro está vivo en una fecha específica
    func isAlive(at date: Date = Date()) -> Bool {
        if let death = deathDate {
            return date < death
        }
        return true
    }
    
    /// Genera un nombre abreviado para visualización
    var shortDisplayName: String {
        let components = displayName.components(separatedBy: " ")
        if components.count > 2 {
            return "\(components[0]) \(components[1])"
        }
        return displayName
    }
}

extension EventKind {
    /// Verifica si el evento es considerado traumático
    var isTraumatic: Bool {
        switch self {
        case .death, .trauma, .violence, .childLoss, .abortion, .war:
            return true
        default:
            return false
        }
    }
    
    /// Verifica si el evento es considerado un secreto familiar
    var isFamilySecret: Bool {
        switch self {
        case .secret, .abortion, .childLoss, .infidelity, .addiction:
            return true
        default:
            return false
        }
    }
}

extension Pattern {
    /// Verifica si el patrón es de alta prioridad
    var isHighPriority: Bool {
        return score >= 70 || evidence.contains { $0.weight > 0.8 }
    }
    
    /// Verifica si el patrón requiere atención profesional
    var requiresProfessionalAttention: Bool {
        return score >= 80 || evidence.contains { evidence in
            evidence.evidenceType == .event || evidence.weight > 0.9
        }
    }
}
