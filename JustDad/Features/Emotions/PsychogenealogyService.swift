//
//  PsychogenealogyService.swift
//  JustDad - Psicogenealogía Service
//
//  Servicio principal para manejar Psicogenealogía con arquitectura limpia
//  Created by Jorge Vasquez Rodriguez
//

import Foundation
import Combine
import SwiftUI

// MARK: - Psychogenealogy Service

@MainActor
class PsychogenealogyService: ObservableObject {
    static let shared = PsychogenealogyService()
    
    // MARK: - Published Properties
    @Published var familyMembers: [FamilyMember] = []
    @Published var relationships: [Relationship] = []
    @Published var familyEvents: [FamilyEvent] = []
    @Published var detectedPatterns: [Pattern] = []
    @Published var availableLetters: [PsychogenealogyLetter] = []
    @Published var sessions: [PsychogenealogySession] = []
    @Published var currentProgress: FamilyHealingProgress = FamilyHealingProgress()
    @Published var selectedRootMember: FamilyMember?
    @Published var isAnalyzingPatterns: Bool = false
    
    // MARK: - Private Properties
    private let patternEngine = PsychogenealogyPatternEngine()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    private init() {
        setupObservers()
        loadData()
        generateAvailableLetters()
        updateProgress()
    }
    
    // MARK: - Setup
    private func setupObservers() {
        // Observar cambios en datos para detectar patrones automáticamente
        Publishers.CombineLatest3(
            $familyMembers,
            $relationships,
            $familyEvents
        )
        .debounce(for: .seconds(1), scheduler: RunLoop.main)
        .sink { [weak self] members, relationships, events in
            self?.detectPatternsAsync()
            self?.updateProgress()
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Family Members Management
    func addFamilyMember(_ member: FamilyMember) {
        familyMembers.append(member)
        saveData()
        detectPatterns()
        updateProgress()
    }
    
    func updateFamilyMember(_ member: FamilyMember) {
        if let index = familyMembers.firstIndex(where: { $0.id == member.id }) {
            familyMembers[index] = member
            saveData()
            detectPatterns()
            updateProgress()
        }
    }
    
    // Alias for compatibility
    func updateMember(_ member: FamilyMember) {
        updateFamilyMember(member)
    }
    
    func removeFamilyMember(_ memberId: UUID) {
        familyMembers.removeAll { $0.id == memberId }
        relationships.removeAll { $0.fromMemberID == memberId || $0.toMemberID == memberId }
        familyEvents.removeAll { $0.memberID == memberId }
        saveData()
        detectPatterns()
        updateProgress()
    }
    
    // Alias for compatibility
    func deleteMember(_ memberId: UUID) {
        removeFamilyMember(memberId)
    }
    
    func getFamilyMember(by id: UUID) -> FamilyMember? {
        return familyMembers.first { $0.id == id }
    }
    
    // MARK: - Pattern Detection
    private func detectPatterns() {
        let membersByID = Dictionary(uniqueKeysWithValues: familyMembers.map { ($0.id, $0) })
        var eventsByMemberID: [UUID: [FamilyEvent]] = [:]
        for event in familyEvents {
            if let memberID = event.memberID {
                eventsByMemberID[memberID, default: []].append(event)
            }
        }
        let relationshipsByMemberID = Dictionary(grouping: relationships, by: { $0.fromMemberID })
        
        let _ = PatternContext(
            membersByID: membersByID,
            eventsByMemberID: eventsByMemberID,
            relationshipsByMemberID: relationshipsByMemberID,
            rootMemberID: selectedRootMember?.id ?? UUID(),
            maxDepth: 5
        )
        
        let newPatterns = patternEngine.detectPatterns(
            members: familyMembers,
            relationships: relationships,
            events: familyEvents,
            rootMemberID: selectedRootMember?.id ?? UUID(),
            maxDepth: 5
        )
        
        // Actualizar patrones existentes y agregar nuevos
        for newPattern in newPatterns {
            if let existingIndex = detectedPatterns.firstIndex(where: { $0.name == newPattern.name }) {
                detectedPatterns[existingIndex] = newPattern
            } else {
                detectedPatterns.append(newPattern)
            }
        }
        
        // Remover patrones que ya no aplican (simplificado)
        detectedPatterns.removeAll { pattern in
            // Simplificación: remover patrones antiguos si no hay miembros relacionados
            pattern.evidence.isEmpty
        }
        
        saveData()
    }
    
    private func detectPatternsAsync() {
        Task {
            await MainActor.run {
                isAnalyzingPatterns = true
            }
            
            // Simular procesamiento asíncrono
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 segundos
            
            await MainActor.run {
                detectPatterns()
                isAnalyzingPatterns = false
            }
        }
    }
    
    func getPatternsForMember(_ memberId: UUID) -> [Pattern] {
        return detectedPatterns.filter { pattern in
            pattern.evidence.contains { evidence in
                evidence.memberID == memberId
            }
        }
    }
    
    // MARK: - Relationships Management
    func addRelationship(_ relationship: Relationship) {
        relationships.append(relationship)
        saveData()
        detectPatterns()
        updateProgress()
    }
    
    func updateRelationship(_ relationship: Relationship) {
        if let index = relationships.firstIndex(where: { $0.id == relationship.id }) {
            relationships[index] = relationship
            saveData()
            detectPatterns()
            updateProgress()
        }
    }
    
    func removeRelationship(_ relationshipId: UUID) {
        relationships.removeAll { $0.id == relationshipId }
        saveData()
        detectPatterns()
        updateProgress()
    }
    
    func getRelationshipsForMember(_ memberId: UUID) -> [Relationship] {
        return relationships.compactMap { relationship in
            if relationship.fromMemberID == memberId || relationship.toMemberID == memberId {
                return relationship
            }
            return nil
        }
    }
    
    // MARK: - Events Management
    func addEvent(_ event: FamilyEvent) {
        familyEvents.append(event)
        saveData()
        detectPatterns()
        updateProgress()
    }
    
    func updateEvent(_ event: FamilyEvent) {
        if let index = familyEvents.firstIndex(where: { $0.id == event.id }) {
            familyEvents[index] = event
            saveData()
            detectPatterns()
            updateProgress()
        }
    }
    
    func removeEvent(_ eventId: UUID) {
        familyEvents.removeAll { $0.id == eventId }
        saveData()
        detectPatterns()
        updateProgress()
    }
    
    func getEventsForMember(_ memberId: UUID) -> [FamilyEvent] {
        return familyEvents.compactMap { event in
            if event.memberID == memberId {
                return event
            }
            return nil
        }
    }
    
    // MARK: - Letters Management
    private func generateAvailableLetters() {
        availableLetters = PsychogenealogyLetterDataProvider.allLetters
    }
    
    func getLettersForPattern(_ patternType: PatternType) -> [PsychogenealogyLetter] {
        return PsychogenealogyLetterDataProvider.getLettersForPattern(patternType)
    }
    
    func getLettersForRelationship(_ relationship: RelationshipType) -> [PsychogenealogyLetter] {
        return PsychogenealogyLetterDataProvider.getLettersForRelationship(relationship)
    }
    
    func getLettersForType(_ letterType: LetterType) -> [PsychogenealogyLetter] {
        return PsychogenealogyLetterDataProvider.getLettersForType(letterType)
    }
    
    func unlockLetter(_ letterId: UUID) {
        if let index = availableLetters.firstIndex(where: { $0.id == letterId }) {
            availableLetters[index].isUnlocked = true
            availableLetters[index].unlockedAt = Date()
            saveData()
            updateProgress()
        }
    }
    
    func lockLetter(_ letterId: UUID) {
        if let index = availableLetters.firstIndex(where: { $0.id == letterId }) {
            availableLetters[index].isUnlocked = false
            availableLetters[index].unlockedAt = nil
            saveData()
            updateProgress()
        }
    }
    
    // MARK: - Sessions Management
    func startSession(for letter: PsychogenealogyLetter) -> PsychogenealogySession {
        let session = PsychogenealogySession(
            letterID: letter.id,
            date: Date(),
            isCompleted: false
        )
        sessions.append(session)
        saveData()
        updateProgress()
        return session
    }
    
    func completeSession(_ sessionId: UUID) {
        if let index = sessions.firstIndex(where: { $0.id == sessionId }) {
            sessions[index] = PsychogenealogySession(
                letterID: sessions[index].letterID,
                date: sessions[index].date,
                isCompleted: true
            )
            saveData()
            updateProgress()
        }
    }
    
    func getSessionsForLetter(_ letterId: UUID) -> [PsychogenealogySession] {
        return sessions.filter { $0.letterID == letterId }
    }
    
    func getSessionsForPattern(_ patternType: PatternType) -> [PsychogenealogySession] {
        let patternLetters = getLettersForPattern(patternType)
        let letterIds = patternLetters.map { $0.id }
        return sessions.filter { letterIds.contains($0.letterID) }
    }
    
    // MARK: - Progress Management
    private func updateProgress() {
        currentProgress = FamilyHealingProgress(
            totalFamilyMembers: familyMembers.count,
            totalPatterns: detectedPatterns.count,
            resolvedPatterns: detectedPatterns.filter { $0.isResolved }.count,
            completedLetters: sessions.filter { $0.isCompleted }.count,
            totalSessions: sessions.count,
            averageCompletionTime: 0,
            lastSessionDate: sessions.last?.date,
            healingStreak: calculateHealingStreak(),
            unlockedLetters: availableLetters.filter { $0.isUnlocked }.count,
            familyTreeCompleteness: Int(calculateFamilyTreeCompleteness() * 100)
        )
    }
    
    private func calculateHealingStreak() -> Int {
        let completedSessions = sessions.filter { $0.isCompleted }
        guard !completedSessions.isEmpty else { return 0 }
        
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        // Ordenar sesiones por fecha descendente
        let sortedSessions = completedSessions.sorted { $0.date > $1.date }
        
        for session in sortedSessions {
            let sessionDate = Calendar.current.startOfDay(for: session.date)
            if Calendar.current.dateInterval(of: .day, for: sessionDate)?.contains(currentDate) == true {
                streak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    // MARK: - Data Persistence
    private func saveData() {
        // TODO: Implementar persistencia con Core Data o UserDefaults
        // Por ahora, solo actualizamos el estado en memoria
    }
    
    private func loadData() {
        // TODO: Implementar carga de datos desde persistencia
        // Por ahora, empezamos con datos vacíos
    }
    
    // MARK: - Family Tree Analysis
    func calculateFamilyTreeCompleteness() -> Double {
        let totalPossibleMembers = 15 // Estimación: padres, abuelos, bisabuelos, hijos, etc.
        let actualMembers = familyMembers.count
        return min(Double(actualMembers) / Double(totalPossibleMembers), 1.0)
    }
    
    func getFamilyTreeStatistics() -> (totalMembers: Int, generations: Int, completeness: Int) {
        let totalMembers = familyMembers.count
        let generations = calculateGenerations()
        let completeness = Int(calculateFamilyTreeCompleteness() * 100)
        
        return (totalMembers, generations, completeness)
    }
    
    private func calculateGenerations() -> Int {
        guard !familyMembers.isEmpty else { return 0 }
        
        // Simplificación: contar generaciones basado en fechas de nacimiento
        let birthYears = familyMembers.compactMap { member in
            member.birthDate.map { Calendar.current.component(.year, from: $0) }
        }
        
        guard !birthYears.isEmpty else { return 1 }
        
        let minYear = birthYears.min() ?? 0
        let maxYear = birthYears.max() ?? 0
        let yearRange = maxYear - minYear
        
        // Aproximadamente 25-30 años por generación
        return max(1, (yearRange / 25) + 1)
    }
    
    // MARK: - Pattern Analysis
    func getPatternStatistics() -> (total: Int, critical: Int, resolved: Int) {
        let total = detectedPatterns.count
        let critical = detectedPatterns.filter { $0.score >= 80 }.count
        let resolved = detectedPatterns.filter { $0.isResolved }.count
        
        return (total, critical, resolved)
    }
    
    func getPatternsByType() -> [PatternType: Int] {
        var counts: [PatternType: Int] = [:]
        
        for pattern in detectedPatterns {
            if let patternType = PatternType(rawValue: pattern.name) {
                counts[patternType, default: 0] += 1
            }
        }
        
        return counts
    }
    
    // MARK: - Healing Progress
    func getHealingProgress() -> FamilyHealingProgress {
        return currentProgress
    }
    
    func getRecommendedLetters() -> [PsychogenealogyLetter] {
        let unresolvedPatterns = detectedPatterns.filter { !$0.isResolved }
        var recommendedLetters: [PsychogenealogyLetter] = []
        
        for pattern in unresolvedPatterns {
            let patternLetters = getLettersForPattern(PatternType(rawValue: pattern.name) ?? .absence)
            let unlockedLetters = patternLetters.filter { $0.isUnlocked }
            recommendedLetters.append(contentsOf: unlockedLetters)
        }
        
        // Remover duplicados usando un Set con IDs
        let uniqueLetters = Dictionary(grouping: recommendedLetters, by: { $0.id })
        return Array(uniqueLetters.values.compactMap { $0.first })
    }
    
    // MARK: - Export/Import
    func exportFamilyTree() -> Data? {
        let exportData = FamilyTreeExport(
            members: familyMembers,
            relationships: relationships,
            events: familyEvents,
            patterns: detectedPatterns,
            sessions: sessions,
            version: "1.0"
        )
        
        return try? JSONEncoder().encode(exportData)
    }
    
    func importFamilyTree(from data: Data) -> Bool {
        guard let importData = try? JSONDecoder().decode(FamilyTreeExport.self, from: data) else {
            return false
        }
        
        familyMembers = importData.members
        relationships = importData.relationships
        familyEvents = importData.events
        detectedPatterns = importData.patterns
        sessions = importData.sessions
        
        saveData()
        detectPatterns()
        updateProgress()
        
        return true
    }
}

// MARK: - Export/Import Models
struct FamilyTreeExport: Codable {
    let members: [FamilyMember]
    let relationships: [Relationship]
    let events: [FamilyEvent]
    let patterns: [Pattern]
    let sessions: [PsychogenealogySession]
    let version: String
}