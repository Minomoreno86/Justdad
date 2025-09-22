//
//  PsychogenealogyPatternEngine.swift
//  JustDad - Psicogenealogía Pattern Engine
//
//  Motor de detección de patrones familiares con Rule Engine declarativo
//  Created by Jorge Vasquez Rodriguez
//

import Foundation
import SwiftUI

// MARK: - Pattern Engine Core

/// Contexto para el análisis de patrones
struct PatternContext {
    let membersByID: [UUID: FamilyMember]
    let eventsByMemberID: [UUID: [FamilyEvent]]
    let relationshipsByMemberID: [UUID: [Relationship]]
    let rootMemberID: UUID
    let maxDepth: Int
    
    /// Obtiene ancestros de un miembro hasta cierta profundidad
    func ancestors(_ memberID: UUID, depth: Int) -> [UUID] {
        var result: [UUID] = []
        var currentDepth = 0
        var currentMembers = [memberID]
        
        while currentDepth < depth && !currentMembers.isEmpty {
            var nextGeneration: [UUID] = []
            
            for memberID in currentMembers {
                let relationships = relationshipsByMemberID[memberID] ?? []
                let parentRelationships = relationships.filter { $0.type == .parent }
                
                for relationship in parentRelationships {
                    if !result.contains(relationship.fromMemberID) {
                        result.append(relationship.fromMemberID)
                        nextGeneration.append(relationship.fromMemberID)
                    }
                }
            }
            
            currentMembers = nextGeneration
            currentDepth += 1
        }
        
        return result
    }
    
    /// Obtiene eventos por linaje
    func eventsByLineage(_ lineage: Lineage) -> [FamilyEvent] {
        var result: [FamilyEvent] = []
        
        for events in eventsByMemberID.values {
            result.append(contentsOf: events.filter { $0.lineage == lineage })
        }
        
        return result
    }
    
    /// Obtiene eventos por tipo
    func eventsByKind(_ kind: EventKind) -> [FamilyEvent] {
        var result: [FamilyEvent] = []
        
        for events in eventsByMemberID.values {
            result.append(contentsOf: events.filter { $0.kind == kind })
        }
        
        return result
    }
    
    /// Calcula la profundidad generacional de un miembro
    func generationDepth(_ memberID: UUID) -> Int {
        return ancestors(memberID, depth: maxDepth).count
    }
}

/// Regla declarativa para detección de patrones
protocol PatternRule {
    var id: UUID { get }
    var name: String { get }
    var description: String { get }
    var priority: Int { get } // 1-10, mayor número = mayor prioridad
    
    /// Evalúa si la regla se aplica al contexto dado
    func predicate(context: PatternContext) -> Bool
    
    /// Calcula el score del patrón (0-100)
    func score(context: PatternContext) -> Int
    
    /// Emite el patrón detectado
    func emit(context: PatternContext) -> Pattern
}

// MARK: - Base Pattern Rules

/// Cadena de ausencia paterna
struct PaternalAbsenceChainRule: PatternRule {
    let id = UUID()
    let name = "Cadena de Ausencia Paterna"
    let description = "Dos o más generaciones consecutivas con ausencia del padre"
    let priority = 9
    
    func predicate(context: PatternContext) -> Bool {
        let paternalEvents = context.eventsByKind(.absence)
        let paternalLineageEvents = paternalEvents.filter { $0.lineage == .paternal }
        
        // Verificar si hay al menos 2 eventos de ausencia en línea paterna
        return paternalLineageEvents.count >= 2
    }
    
    func score(context: PatternContext) -> Int {
        let paternalEvents = context.eventsByKind(.absence)
        let paternalLineageEvents = paternalEvents.filter { $0.lineage == .paternal }
        
        let baseScore = min(paternalLineageEvents.count * 15, 60)
        let severityBonus = paternalLineageEvents.reduce(0) { $0 + $1.severity } / 2
        
        return min(baseScore + severityBonus, 100)
    }
    
    func emit(context: PatternContext) -> Pattern {
        let paternalEvents = context.eventsByKind(.absence)
        let paternalLineageEvents = paternalEvents.filter { $0.lineage == .paternal }
        
        let evidence = paternalLineageEvents.map { event in
            PatternEvidence(
                memberID: event.memberID ?? UUID(),
                eventID: event.id,
                relationshipID: nil,
                evidenceType: .event,
                description: "Ausencia en línea paterna - \(event.date?.formatted(date: .abbreviated, time: .omitted) ?? "fecha desconocida")",
                weight: Double(event.severity) / 5.0
            )
        }
        
        return Pattern(
            name: name,
            description: description,
            evidence: evidence,
            score: score(context: context),
            lineage: .paternal,
            recommendations: [
                "Trabajar la relación con la figura paterna",
                "Explorar el impacto de la ausencia paterna",
                "Identificar patrones de abandono en relaciones actuales"
            ],
            lettersToUnlock: [] // Se llenará dinámicamente
        )
    }
}

/// Repetición de divorcios
struct DivorceRepetitionRule: PatternRule {
    let id = UUID()
    let name = "Repetición de Divorcios"
    let description = "Tres o más divorcios en línea materna o paterna"
    let priority = 8
    
    func predicate(context: PatternContext) -> Bool {
        let divorceEvents = context.eventsByKind(.divorce)
        return divorceEvents.count >= 3
    }
    
    func score(context: PatternContext) -> Int {
        let divorceEvents = context.eventsByKind(.divorce)
        let baseScore = min(divorceEvents.count * 12, 50)
        let severityBonus = divorceEvents.reduce(0) { $0 + $1.severity } / 3
        
        return min(baseScore + severityBonus, 100)
    }
    
    func emit(context: PatternContext) -> Pattern {
        let divorceEvents = context.eventsByKind(.divorce)
        
        let evidence = divorceEvents.map { event in
            PatternEvidence(
                memberID: event.memberID ?? UUID(),
                eventID: event.id,
                relationshipID: nil,
                evidenceType: .event,
                description: "Divorcio en \(event.lineage.displayName) - \(event.date?.formatted(date: .abbreviated, time: .omitted) ?? "fecha desconocida")",
                weight: Double(event.severity) / 5.0
            )
        }
        
        return Pattern(
            name: name,
            description: description,
            evidence: evidence,
            score: score(context: context),
            lineage: .mixed, // Puede afectar ambas líneas
            recommendations: [
                "Explorar patrones de relación en la familia",
                "Identificar miedos al compromiso",
                "Trabajar la estabilidad en relaciones actuales"
            ],
            lettersToUnlock: []
        )
    }
}

/// Muerte temprana en línea masculina
struct EarlyDeathMaleLineRule: PatternRule {
    let id = UUID()
    let name = "Muerte Temprana en Línea Masculina"
    let description = "Dos o más muertes masculinas antes de los 40 años en línea paterna"
    let priority = 7
    
    func predicate(context: PatternContext) -> Bool {
        let deathEvents = context.eventsByKind(.death)
        let paternalDeaths = deathEvents.filter { $0.lineage == .paternal }
        
        // Verificar muertes tempranas (antes de 40 años)
        var earlyDeaths = 0
        for event in paternalDeaths {
            if let memberID = event.memberID,
               let member = context.membersByID[memberID],
               member.sex == .male,
               let age = member.age(at: event.date ?? Date()),
               age < 40 {
                earlyDeaths += 1
            }
        }
        
        return earlyDeaths >= 2
    }
    
    func score(context: PatternContext) -> Int {
        let deathEvents = context.eventsByKind(.death)
        let paternalDeaths = deathEvents.filter { $0.lineage == .paternal }
        
        var earlyDeaths = 0
        for event in paternalDeaths {
            if let memberID = event.memberID,
               let member = context.membersByID[memberID],
               member.sex == .male,
               let age = member.age(at: event.date ?? Date()),
               age < 40 {
                earlyDeaths += 1
            }
        }
        
        return min(earlyDeaths * 25, 100)
    }
    
    func emit(context: PatternContext) -> Pattern {
        let deathEvents = context.eventsByKind(.death)
        let paternalDeaths = deathEvents.filter { $0.lineage == .paternal }
        
        var evidence: [PatternEvidence] = []
        for event in paternalDeaths {
            if let memberID = event.memberID,
               let member = context.membersByID[memberID],
               member.sex == .male,
               let age = member.age(at: event.date ?? Date()),
               age < 40 {
                
                evidence.append(PatternEvidence(
                    memberID: memberID,
                    eventID: event.id,
                    relationshipID: nil,
                    evidenceType: .event,
                    description: "Muerte temprana de \(member.displayName) a los \(age) años",
                    weight: Double(40 - age) / 40.0 // Mayor peso para muertes más tempranas
                ))
            }
        }
        
        return Pattern(
            name: name,
            description: description,
            evidence: evidence,
            score: score(context: context),
            lineage: .paternal,
            recommendations: [
                "Explorar el impacto de las pérdidas tempranas",
                "Trabajar el miedo a la muerte prematura",
                "Identificar patrones de salud en línea masculina"
            ],
            lettersToUnlock: []
        )
    }
}

/// Cluster de secretos familiares
struct SecretsClusterRule: PatternRule {
    let id = UUID()
    let name = "Cluster de Secretos Familiares"
    let description = "Existencia de secretos, pérdidas de hijos o abortos no declarados"
    let priority = 10
    
    func predicate(context: PatternContext) -> Bool {
        let secretEvents = context.eventsByKind(.secret)
        let childLossEvents = context.eventsByKind(.childLoss)
        let abortionEvents = context.eventsByKind(.abortion)
        
        return (secretEvents.count + childLossEvents.count + abortionEvents.count) >= 2
    }
    
    func score(context: PatternContext) -> Int {
        let secretEvents = context.eventsByKind(.secret)
        let childLossEvents = context.eventsByKind(.childLoss)
        let abortionEvents = context.eventsByKind(.abortion)
        
        let totalSecretEvents = secretEvents.count + childLossEvents.count + abortionEvents.count
        let baseScore = min(totalSecretEvents * 20, 70)
        
        // Bonus por severidad y si son eventos marcados como secretos
        let secretBonus = (secretEvents.count * 15) + 
                         (childLossEvents.filter { $0.isSecret }.count * 10) +
                         (abortionEvents.filter { $0.isSecret }.count * 10)
        
        return min(baseScore + secretBonus, 100)
    }
    
    func emit(context: PatternContext) -> Pattern {
        let secretEvents = context.eventsByKind(.secret)
        let childLossEvents = context.eventsByKind(.childLoss)
        let abortionEvents = context.eventsByKind(.abortion)
        
        var evidence: [PatternEvidence] = []
        
        for event in secretEvents {
            evidence.append(PatternEvidence(
                memberID: event.memberID ?? UUID(),
                eventID: event.id,
                relationshipID: nil,
                evidenceType: .event,
                description: "Secreto familiar en \(event.lineage.displayName)",
                weight: Double(event.severity) / 5.0
            ))
        }
        
        for event in childLossEvents {
            evidence.append(PatternEvidence(
                memberID: event.memberID ?? UUID(),
                eventID: event.id,
                relationshipID: nil,
                evidenceType: .event,
                description: "Pérdida de hijo \(event.isSecret ? "(secreto)" : "")",
                weight: Double(event.severity) / 5.0 * (event.isSecret ? 1.2 : 1.0)
            ))
        }
        
        for event in abortionEvents {
            evidence.append(PatternEvidence(
                memberID: event.memberID ?? UUID(),
                eventID: event.id,
                relationshipID: nil,
                evidenceType: .event,
                description: "Aborto \(event.isSecret ? "(secreto)" : "")",
                weight: Double(event.severity) / 5.0 * (event.isSecret ? 1.2 : 1.0)
            ))
        }
        
        return Pattern(
            name: name,
            description: description,
            evidence: evidence,
            score: score(context: context),
            lineage: .mixed,
            recommendations: [
                "Crear un espacio seguro para hablar de secretos",
                "Explorar el impacto de la ocultación en la familia",
                "Trabajar la transparencia en relaciones actuales"
            ],
            lettersToUnlock: []
        )
    }
}

/// Rupturas por migración
struct MigrationBreaksRule: PatternRule {
    let id = UUID()
    let name = "Rupturas por Migración"
    let description = "Migraciones que correlacionan con divorcios o ausencias"
    let priority = 6
    
    func predicate(context: PatternContext) -> Bool {
        let migrationEvents = context.eventsByKind(.migration)
        let divorceEvents = context.eventsByKind(.divorce)
        let absenceEvents = context.eventsByKind(.absence)
        
        return migrationEvents.count >= 2 && (divorceEvents.count > 0 || absenceEvents.count > 0)
    }
    
    func score(context: PatternContext) -> Int {
        let migrationEvents = context.eventsByKind(.migration)
        let divorceEvents = context.eventsByKind(.divorce)
        let absenceEvents = context.eventsByKind(.absence)
        
        let baseScore = min(migrationEvents.count * 10, 40)
        let correlationBonus = (divorceEvents.count + absenceEvents.count) * 15
        
        return min(baseScore + correlationBonus, 100)
    }
    
    func emit(context: PatternContext) -> Pattern {
        let migrationEvents = context.eventsByKind(.migration)
        let divorceEvents = context.eventsByKind(.divorce)
        let absenceEvents = context.eventsByKind(.absence)
        
        var evidence: [PatternEvidence] = []
        
        for event in migrationEvents {
            evidence.append(PatternEvidence(
                memberID: event.memberID ?? UUID(),
                eventID: event.id,
                relationshipID: nil,
                evidenceType: .event,
                description: "Migración a \(event.location ?? "ubicación desconocida")",
                weight: Double(event.severity) / 5.0
            ))
        }
        
        // Agregar evidencia de eventos correlacionados
        for event in divorceEvents {
            evidence.append(PatternEvidence(
                memberID: event.memberID ?? UUID(),
                eventID: event.id,
                relationshipID: nil,
                evidenceType: .event,
                description: "Divorcio correlacionado con migración",
                weight: Double(event.severity) / 5.0 * 0.8
            ))
        }
        
        for event in absenceEvents {
            evidence.append(PatternEvidence(
                memberID: event.memberID ?? UUID(),
                eventID: event.id,
                relationshipID: nil,
                evidenceType: .event,
                description: "Ausencia correlacionada con migración",
                weight: Double(event.severity) / 5.0 * 0.8
            ))
        }
        
        return Pattern(
            name: name,
            description: description,
            evidence: evidence,
            score: score(context: context),
            lineage: .mixed,
            recommendations: [
                "Explorar el impacto de las migraciones en la familia",
                "Trabajar la pertenencia y las raíces",
                "Identificar patrones de adaptación y resistencia al cambio"
            ],
            lettersToUnlock: []
        )
    }
}

// MARK: - Pattern Engine

/// Motor principal de detección de patrones
class PsychogenealogyPatternEngine {
    private var rules: [PatternRule] = []
    
    init() {
        setupDefaultRules()
    }
    
    /// Configura las reglas por defecto
    private func setupDefaultRules() {
        rules = [
            PaternalAbsenceChainRule(),
            DivorceRepetitionRule(),
            EarlyDeathMaleLineRule(),
            SecretsClusterRule(),
            MigrationBreaksRule()
        ]
        
        // Ordenar por prioridad (mayor primero)
        rules.sort { $0.priority > $1.priority }
    }
    
    /// Agrega una nueva regla personalizada
    func addRule(_ rule: PatternRule) {
        rules.append(rule)
        rules.sort { $0.priority > $1.priority }
    }
    
    /// Ejecuta el análisis de patrones
    func detectPatterns(
        members: [FamilyMember],
        relationships: [Relationship],
        events: [FamilyEvent],
        rootMemberID: UUID,
        maxDepth: Int = 4
    ) -> [Pattern] {
        
        // Crear contexto
        let membersByID = Dictionary(uniqueKeysWithValues: members.map { ($0.id, $0) })
        let eventsByMemberID = Dictionary(grouping: events) { $0.memberID ?? UUID() }
        let relationshipsByMemberID = Dictionary(grouping: relationships) { $0.fromMemberID }
        
        let context = PatternContext(
            membersByID: membersByID,
            eventsByMemberID: eventsByMemberID,
            relationshipsByMemberID: relationshipsByMemberID,
            rootMemberID: rootMemberID,
            maxDepth: maxDepth
        )
        
        // Ejecutar reglas
        var detectedPatterns: [Pattern] = []
        
        for rule in rules {
            if rule.predicate(context: context) {
                let pattern = rule.emit(context: context)
                detectedPatterns.append(pattern)
            }
        }
        
        // Filtrar patrones con score mínimo y ordenar por score
        let filteredPatterns = detectedPatterns
            .filter { $0.score >= 40 } // Umbral mínimo
            .sorted { $0.score > $1.score }
        
        return filteredPatterns
    }
    
    /// Obtiene sugerencias de cartas basadas en patrones
    func suggestLetters(for patterns: [Pattern]) -> [UUID] {
        var suggestedLetterIDs: [UUID] = []
        
        for pattern in patterns {
            if pattern.score >= 60 {
                suggestedLetterIDs.append(contentsOf: pattern.lettersToUnlock)
            }
        }
        
        return Array(Set(suggestedLetterIDs)) // Eliminar duplicados
    }
    
    /// Obtiene patrones de alta prioridad que requieren atención profesional
    func getHighPriorityPatterns(_ patterns: [Pattern]) -> [Pattern] {
        return patterns.filter { $0.requiresProfessionalAttention }
    }
}

// MARK: - Extensions

extension PatternContext {
    /// Calcula estadísticas del árbol familiar
    func calculateStatistics() -> FamilyTreeStatistics {
        let totalMembers = membersByID.count
        let totalEvents = eventsByMemberID.values.flatMap { $0 }.count
        let totalRelationships = relationshipsByMemberID.values.flatMap { $0 }.count
        
        let eventsByType = Dictionary(grouping: eventsByMemberID.values.flatMap { $0 }) { $0.kind }
        let eventsByLineage = Dictionary(grouping: eventsByMemberID.values.flatMap { $0 }) { $0.lineage }
        
        return FamilyTreeStatistics(
            totalMembers: totalMembers,
            totalEvents: totalEvents,
            totalRelationships: totalRelationships,
            eventsByType: eventsByType,
            eventsByLineage: eventsByLineage,
            averageGenerationDepth: Double(ancestors(rootMemberID, depth: maxDepth).count)
        )
    }
}

/// Estadísticas del árbol familiar
struct FamilyTreeStatistics {
    let totalMembers: Int
    let totalEvents: Int
    let totalRelationships: Int
    let eventsByType: [EventKind: [FamilyEvent]]
    let eventsByLineage: [Lineage: [FamilyEvent]]
    let averageGenerationDepth: Double
}
