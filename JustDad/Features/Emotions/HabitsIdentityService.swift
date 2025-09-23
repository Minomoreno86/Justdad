//
//  HabitsIdentityService.swift
//  JustDad - Habit Identity System
//
//  Sistema de identidad de hábitos basado en Atomic Habits
//

import Foundation
import SwiftUI

// MARK: - Habit Identity Service
class HabitsIdentityService: ObservableObject {
    static let shared = HabitsIdentityService()
    
    @Published var identities: [HabitIdentity] = []
    @Published var currentIdentity: HabitIdentity?
    @Published var identityProgress: [UUID: IdentityProgress] = [:]
    
    private init() {
        loadIdentities()
        loadCurrentIdentity()
        loadIdentityProgress()
        updateIdentityProgress()
    }
    
    // MARK: - Identity Management
    func createIdentity(name: String, description: String, category: IdentityCategory, targetHabits: [String] = []) {
        let identity = HabitIdentity(
            name: name,
            description: description,
            category: category,
            targetHabits: targetHabits,
            createdAt: Date()
        )
        
        identities.append(identity)
        saveIdentities()
        updateIdentityProgress()
    }
    
    func updateIdentity(_ identity: HabitIdentity) {
        if let index = identities.firstIndex(where: { $0.id == identity.id }) {
            identities[index] = identity
            saveIdentities()
            updateIdentityProgress()
        }
    }
    
    func deleteIdentity(_ identity: HabitIdentity) {
        identities.removeAll { $0.id == identity.id }
        identityProgress.removeValue(forKey: identity.id)
        
        if currentIdentity?.id == identity.id {
            currentIdentity = nil
        }
        
        saveIdentities()
        saveCurrentIdentity()
        saveIdentityProgress()
        updateIdentityProgress()
    }
    
    func setCurrentIdentity(_ identity: HabitIdentity) {
        currentIdentity = identity
        saveCurrentIdentity()
        updateIdentityProgress()
    }
    
    // MARK: - Identity Progress
    private func updateIdentityProgress() {
        let habitsService = HabitsService.shared
        
        for identity in identities {
            let progress = calculateProgress(for: identity, habits: habitsService.habits)
            identityProgress[identity.id] = progress
        }
        
        saveIdentityProgress()
    }
    
    private func calculateProgress(for identity: HabitIdentity, habits: [Habit]) -> IdentityProgress {
        let relevantHabits = habits.filter { habit in
            identity.targetHabits.contains { targetHabit in
                habit.name.localizedCaseInsensitiveContains(targetHabit) ||
                habit.description.localizedCaseInsensitiveContains(targetHabit)
            }
        }
        
        let totalCompletions = relevantHabits.flatMap { $0.completedDays }.count
        let totalStreak = relevantHabits.map { $0.streak }.reduce(0, +)
        let averageStreak = relevantHabits.isEmpty ? 0 : totalStreak / relevantHabits.count
        let completionRate = relevantHabits.isEmpty ? 0.0 : Double(totalCompletions) / Double(relevantHabits.count * 30) // 30 días como referencia
        
        let evidence = generateEvidence(for: identity, habits: relevantHabits)
        
        return IdentityProgress(
            identityId: identity.id,
            totalCompletions: totalCompletions,
            averageStreak: averageStreak,
            completionRate: completionRate,
            evidence: evidence,
            lastUpdated: Date()
        )
    }
    
    private func generateEvidence(for identity: HabitIdentity, habits: [Habit]) -> [IdentityEvidence] {
        var evidence: [IdentityEvidence] = []
        
        for habit in habits {
            if habit.streak >= 7 {
                evidence.append(IdentityEvidence(
                    description: "He completado '\(habit.name)' por \(habit.streak) días seguidos",
                    strength: habit.streak >= 30 ? .strong : .medium,
                    habitId: habit.id,
                    date: Date()
                ))
            }
            
            if habit.completionRate >= 0.8 {
                evidence.append(IdentityEvidence(
                    description: "Mantengo una consistencia del \(Int(habit.completionRate * 100))% en '\(habit.name)'",
                    strength: habit.completionRate >= 0.95 ? .strong : .medium,
                    habitId: habit.id,
                    date: Date()
                ))
            }
        }
        
        // Agregar evidencia específica por categoría
        switch identity.category {
        case .presentFather:
            if habits.contains(where: { $0.category == .parenting && $0.streak >= 14 }) {
                evidence.append(IdentityEvidence(
                    description: "Soy un padre presente y comprometido",
                    strength: .strong,
                    habitId: nil,
                    date: Date()
                ))
            }
        case .healthyPerson:
            if habits.contains(where: { $0.category == .health && $0.streak >= 14 }) {
                evidence.append(IdentityEvidence(
                    description: "Me cuido física y mentalmente",
                    strength: .strong,
                    habitId: nil,
                    date: Date()
                ))
            }
        case .organizedPerson:
            if habits.contains(where: { $0.name.localizedCaseInsensitiveContains("organizar") && $0.streak >= 7 }) {
                evidence.append(IdentityEvidence(
                    description: "Mantengo mi vida organizada y en orden",
                    strength: .medium,
                    habitId: nil,
                    date: Date()
                ))
            }
        case .learner:
            if habits.contains(where: { $0.name.localizedCaseInsensitiveContains("leer") || $0.name.localizedCaseInsensitiveContains("estudiar") }) {
                evidence.append(IdentityEvidence(
                    description: "Soy una persona que siempre está aprendiendo",
                    strength: .medium,
                    habitId: nil,
                    date: Date()
                ))
            }
        case .mindfulPerson:
            if habits.contains(where: { $0.name.localizedCaseInsensitiveContains("meditar") || $0.name.localizedCaseInsensitiveContains("mindfulness") }) {
                evidence.append(IdentityEvidence(
                    description: "Practico la atención plena regularmente",
                    strength: .medium,
                    habitId: nil,
                    date: Date()
                ))
            }
        case .successfulProfessional:
            if habits.contains(where: { $0.category == .work && $0.streak >= 14 }) {
                evidence.append(IdentityEvidence(
                    description: "Soy un profesional exitoso y dedicado",
                    strength: .strong,
                    habitId: nil,
                    date: Date()
                ))
            }
        case .lovingPartner:
            if habits.contains(where: { $0.category == .relationships && $0.streak >= 7 }) {
                evidence.append(IdentityEvidence(
                    description: "Invierto en mis relaciones importantes",
                    strength: .medium,
                    habitId: nil,
                    date: Date()
                ))
            }
        case .custom:
            // Para identidades personalizadas, generar evidencia basada en los hábitos objetivo
            if !identity.targetHabits.isEmpty {
                let completedTargets = identity.targetHabits.filter { target in
                    habits.contains { habit in
                        habit.name.localizedCaseInsensitiveContains(target) && habit.streak >= 7
                    }
                }
                
                if !completedTargets.isEmpty {
                    evidence.append(IdentityEvidence(
                        description: "Estoy trabajando activamente en mis objetivos de '\(identity.name)'",
                        strength: completedTargets.count >= identity.targetHabits.count / 2 ? .strong : .medium,
                        habitId: nil,
                        date: Date()
                    ))
                }
            }
        }
        
        return evidence.sorted { $0.date > $1.date }
    }
    
    // MARK: - Identity Suggestions
    func getIdentitySuggestions() -> [IdentitySuggestion] {
        let habitsService = HabitsService.shared
        let userHabits = habitsService.habits
        
        var suggestions: [IdentitySuggestion] = []
        
        // Analizar hábitos existentes para sugerir identidades
        let parentingHabits = userHabits.filter { $0.category == .parenting }
        let healthHabits = userHabits.filter { $0.category == .health }
        let workHabits = userHabits.filter { $0.category == .work }
        let relationshipHabits = userHabits.filter { $0.category == .relationships }
        
        if parentingHabits.count >= 2 && !identities.contains(where: { $0.category == .presentFather }) {
            suggestions.append(IdentitySuggestion(
                category: .presentFather,
                title: "Padre Presente",
                description: "Basado en tus hábitos de paternidad, podrías desarrollar la identidad de un padre presente y comprometido",
                supportingHabits: parentingHabits.map { $0.name },
                confidence: IdentitySuggestionConfidence.high
            ))
        }
        
        if healthHabits.count >= 2 && !identities.contains(where: { $0.category == .healthyPerson }) {
            suggestions.append(IdentitySuggestion(
                category: .healthyPerson,
                title: "Persona Saludable",
                description: "Tus hábitos de salud sugieren que valoras el bienestar físico y mental",
                supportingHabits: healthHabits.map { $0.name },
                confidence: IdentitySuggestionConfidence.high
            ))
        }
        
        if workHabits.count >= 1 && !identities.contains(where: { $0.category == .successfulProfessional }) {
            suggestions.append(IdentitySuggestion(
                category: .successfulProfessional,
                title: "Profesional Exitoso",
                description: "Tus hábitos profesionales indican que buscas el crecimiento en tu carrera",
                supportingHabits: workHabits.map { $0.name },
                confidence: IdentitySuggestionConfidence.medium
            ))
        }
        
        return suggestions
    }
    
    // MARK: - Identity Affirmations
    func getDailyAffirmation() -> String {
        guard let identity = currentIdentity else {
            return "Cada día es una oportunidad para crecer y mejorar"
        }
        
        let affirmations = identity.category.affirmations
        let randomAffirmation = affirmations.randomElement() ?? affirmations.first ?? ""
        
        return "Soy \(identity.name.lowercased()). \(randomAffirmation)"
    }
    
    // MARK: - Persistence
    private func saveIdentities() {
        if let data = try? JSONEncoder().encode(identities) {
            UserDefaults.standard.set(data, forKey: "habit_identities")
        }
    }
    
    private func loadIdentities() {
        if let data = UserDefaults.standard.data(forKey: "habit_identities"),
           let loadedIdentities = try? JSONDecoder().decode([HabitIdentity].self, from: data) {
            identities = loadedIdentities
        }
    }
    
    private func saveCurrentIdentity() {
        if let identity = currentIdentity,
           let data = try? JSONEncoder().encode(identity) {
            UserDefaults.standard.set(data, forKey: "current_habit_identity")
        } else {
            UserDefaults.standard.removeObject(forKey: "current_habit_identity")
        }
    }
    
    private func loadCurrentIdentity() {
        if let data = UserDefaults.standard.data(forKey: "current_habit_identity"),
           let identity = try? JSONDecoder().decode(HabitIdentity.self, from: data) {
            currentIdentity = identity
        }
    }
    
    private func saveIdentityProgress() {
        if let data = try? JSONEncoder().encode(identityProgress) {
            UserDefaults.standard.set(data, forKey: "identity_progress")
        }
    }
    
    private func loadIdentityProgress() {
        if let data = UserDefaults.standard.data(forKey: "identity_progress"),
           let progress = try? JSONDecoder().decode([UUID: IdentityProgress].self, from: data) {
            identityProgress = progress
        }
    }
}

// MARK: - Habit Identity Model
struct HabitIdentity: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let category: IdentityCategory
    let targetHabits: [String]
    let createdAt: Date
    var isActive: Bool = true
    
    init(name: String, description: String, category: IdentityCategory, targetHabits: [String] = [], createdAt: Date) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.category = category
        self.targetHabits = targetHabits
        self.createdAt = createdAt
    }
}

// MARK: - Identity Category
enum IdentityCategory: String, CaseIterable, Codable {
    case presentFather = "present_father"
    case healthyPerson = "healthy_person"
    case organizedPerson = "organized_person"
    case learner = "learner"
    case mindfulPerson = "mindful_person"
    case successfulProfessional = "successful_professional"
    case lovingPartner = "loving_partner"
    case custom = "custom"
    
    var title: String {
        switch self {
        case .presentFather: return "Padre Presente"
        case .healthyPerson: return "Persona Saludable"
        case .organizedPerson: return "Persona Organizada"
        case .learner: return "Aprendiz Constante"
        case .mindfulPerson: return "Persona Consciente"
        case .successfulProfessional: return "Profesional Exitoso"
        case .lovingPartner: return "Pareja Amorosa"
        case .custom: return "Personalizada"
        }
    }
    
    var description: String {
        switch self {
        case .presentFather: return "Un padre comprometido, presente y emocionalmente disponible para sus hijos"
        case .healthyPerson: return "Alguien que se cuida física y mentalmente, priorizando su bienestar"
        case .organizedPerson: return "Una persona ordenada, planificada y eficiente en su vida diaria"
        case .learner: return "Alguien que siempre está aprendiendo y creciendo intelectualmente"
        case .mindfulPerson: return "Una persona consciente, centrada y en paz consigo misma"
        case .successfulProfessional: return "Un profesional dedicado, competente y exitoso en su carrera"
        case .lovingPartner: return "Una pareja amorosa, comprensiva y comprometida en las relaciones"
        case .custom: return "Una identidad personalizada que defines tú mismo"
        }
    }
    
    var icon: String {
        switch self {
        case .presentFather: return "figure.and.child.holdinghands"
        case .healthyPerson: return "heart.fill"
        case .organizedPerson: return "folder.fill"
        case .learner: return "book.fill"
        case .mindfulPerson: return "brain.head.profile"
        case .successfulProfessional: return "briefcase.fill"
        case .lovingPartner: return "heart.circle.fill"
        case .custom: return "person.crop.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .presentFather: return .blue
        case .healthyPerson: return .red
        case .organizedPerson: return .green
        case .learner: return .purple
        case .mindfulPerson: return .orange
        case .successfulProfessional: return .indigo
        case .lovingPartner: return .pink
        case .custom: return .gray
        }
    }
    
    var affirmations: [String] {
        switch self {
        case .presentFather:
            return [
                "Estoy presente para mis hijos en cada momento",
                "Soy un ejemplo positivo para mis hijos",
                "Mi amor y dedicación hacen la diferencia en sus vidas",
                "Soy el padre que mis hijos necesitan",
                "Mi presencia emocional es mi mayor regalo"
            ]
        case .healthyPerson:
            return [
                "Me cuido porque me amo",
                "Mi salud es mi prioridad",
                "Cada elección saludable me acerca a mi mejor versión",
                "Soy responsable de mi bienestar",
                "Mi cuerpo y mente son sagrados"
            ]
        case .organizedPerson:
            return [
                "Mi orden externo refleja mi paz interna",
                "La organización me da libertad",
                "Soy eficiente y productivo",
                "Mi espacio ordenado nutre mi mente",
                "La planificación es mi superpoder"
            ]
        case .learner:
            return [
                "Cada día aprendo algo nuevo",
                "Mi curiosidad me lleva más lejos",
                "El conocimiento es mi mayor riqueza",
                "Soy un estudiante de la vida",
                "Mi mente está siempre abierta al crecimiento"
            ]
        case .mindfulPerson:
            return [
                "Estoy presente en cada momento",
                "Mi paz interior es inquebrantable",
                "Soy consciente de mis pensamientos y emociones",
                "La meditación me conecta con mi esencia",
                "Vivo con intención y propósito"
            ]
        case .successfulProfessional:
            return [
                "Soy excelente en lo que hago",
                "Mi dedicación se refleja en mis resultados",
                "Soy un líder inspirador",
                "Mi trabajo aporta valor real",
                "Soy reconocido por mi competencia"
            ]
        case .lovingPartner:
            return [
                "Amo profundamente y soy amado",
                "Soy comprensivo y paciente en mis relaciones",
                "Mi amor transforma positivamente a otros",
                "Soy digno de amor y respeto",
                "Mis relaciones están llenas de conexión genuina"
            ]
        case .custom:
            return [
                "Soy quien elijo ser",
                "Mi identidad está en constante evolución",
                "Soy auténtico y verdadero",
                "Mi camino es único y valioso",
                "Soy el arquitecto de mi propia identidad"
            ]
        }
    }
}

// MARK: - Identity Progress
struct IdentityProgress: Codable {
    let identityId: UUID
    let totalCompletions: Int
    let averageStreak: Int
    let completionRate: Double
    let evidence: [IdentityEvidence]
    let lastUpdated: Date
    
    var strength: IdentityStrength {
        if completionRate >= 0.8 && averageStreak >= 14 {
            return .strong
        } else if completionRate >= 0.6 && averageStreak >= 7 {
            return .medium
        } else {
            return .weak
        }
    }
}

// MARK: - Identity Evidence
struct IdentityEvidence: Identifiable, Codable {
    let id = UUID()
    let description: String
    let strength: IdentityStrength
    let habitId: UUID?
    let date: Date
}

// MARK: - Identity Strength
enum IdentityStrength: String, CaseIterable, Codable {
    case weak = "weak"
    case medium = "medium"
    case strong = "strong"
    
    var title: String {
        switch self {
        case .weak: return "Emergiendo"
        case .medium: return "Fortaleciéndose"
        case .strong: return "Establecida"
        }
    }
    
    var color: Color {
        switch self {
        case .weak: return .orange
        case .medium: return .blue
        case .strong: return .green
        }
    }
    
    var icon: String {
        switch self {
        case .weak: return "seedling"
        case .medium: return "leaf.fill"
        case .strong: return "tree.fill"
        }
    }
}

// MARK: - Identity Suggestion
struct IdentitySuggestion: Identifiable {
    let id = UUID()
    let category: IdentityCategory
    let title: String
    let description: String
    let supportingHabits: [String]
    let confidence: IdentitySuggestionConfidence
}

// MARK: - Identity Suggestion Confidence
enum IdentitySuggestionConfidence: String, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var title: String {
        switch self {
        case .low: return "Baja"
        case .medium: return "Media"
        case .high: return "Alta"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .gray
        case .medium: return .yellow
        case .high: return .green
        }
    }
}
