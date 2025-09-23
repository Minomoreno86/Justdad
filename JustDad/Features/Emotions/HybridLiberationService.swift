//
//  HybridLiberationService.swift
//  JustDad - Hybrid Liberation Service
//
//  Servicio híbrido que combina psicología profesional y espiritualidad
//

import Foundation
import SwiftUI

public class HybridLiberationService: ObservableObject {
    public static let shared = HybridLiberationService()
    
    @Published public var liberationSessions: [HybridLiberationSession] = []
    @Published public var currentSession: HybridLiberationSession?
    @Published public var emotionalState: EmotionalIntensity = .neutral
    
    private init() {
        loadLiberationSessions()
    }
    
    // MARK: - Hybrid Liberation Techniques
    public enum HybridTechnique: String, CaseIterable, Identifiable, Codable {
        case forgivenessTherapy = "forgiveness_therapy"
        case liberationLetter = "liberation_letter"
        case psychogenealogy = "psychogenealogy"
        case liberationRitual = "liberation_ritual"
        case energeticCords = "energetic_cords"
        case pastLifeBonds = "past_life_bonds"
        
        public var id: String { rawValue }
        
        public var title: String {
            switch self {
            case .forgivenessTherapy: return "Terapia del Perdón"
            case .liberationLetter: return "Carta de Liberación"
            case .psychogenealogy: return "Psicogenealogía"
            case .liberationRitual: return "Ritual de Liberación"
            case .energeticCords: return "Corte de Amarres o Brujería"
            case .pastLifeBonds: return "Vínculos del Pasado"
            }
        }
        
        public var description: String {
            switch self {
            case .forgivenessTherapy: return "Libera resentimientos y cargas emocionales a través de técnicas psicológicas y espirituales."
            case .liberationLetter: return "Escribe para soltar emociones reprimidas y cerrar ciclos de forma terapéutica."
            case .psychogenealogy: return "Identifica y libera patrones familiares heredados con metodología profesional."
            case .liberationRitual: return "Realiza ceremonias simbólicas para la sanación profunda del alma."
            case .energeticCords: return "Libera amarres, maldiciones y trabajos de brujería con técnicas energéticas reales."
            case .pastLifeBonds: return "Libera conexiones kármicas y votos de otras vidas de forma segura."
            }
        }
        
        public var icon: String {
            switch self {
            case .forgivenessTherapy: return "heart.fill"
            case .liberationLetter: return "envelope.fill"
            case .psychogenealogy: return "tree.fill"
            case .liberationRitual: return "sparkles"
            case .energeticCords: return "scissors"
            case .pastLifeBonds: return "infinity.circle.fill"
            }
        }
        
        public var color: Color {
            switch self {
            case .forgivenessTherapy: return .pink
            case .liberationLetter: return .blue
            case .psychogenealogy: return .green
            case .liberationRitual: return .orange
            case .energeticCords: return .purple
            case .pastLifeBonds: return .indigo
            }
        }
        
        public var estimatedTime: String {
            switch self {
            case .forgivenessTherapy: return "20-25 min"
            case .liberationLetter: return "15-20 min"
            case .psychogenealogy: return "25-30 min"
            case .liberationRitual: return "20-25 min"
            case .energeticCords: return "15-20 min"
            case .pastLifeBonds: return "20-25 min"
            }
        }
        
        public var therapeuticApproach: TherapeuticApproach {
            switch self {
            case .forgivenessTherapy: return .cognitiveBehavioral
            case .liberationLetter: return .expressiveTherapy
            case .psychogenealogy: return .systemicTherapy
            case .liberationRitual: return .transpersonalTherapy
            case .energeticCords: return .energyPsychology
            case .pastLifeBonds: return .transpersonalTherapy
            }
        }
        
        public var spiritualElement: SpiritualElement {
            switch self {
            case .forgivenessTherapy: return .meditation
            case .liberationLetter: return .ritual
            case .psychogenealogy: return .ancestralHealing
            case .liberationRitual: return .ceremony
            case .energeticCords: return .energyWork
            case .pastLifeBonds: return .soulWork
            }
        }
    }
    
    // MARK: - Therapeutic Approaches
    public enum TherapeuticApproach: String, CaseIterable, Codable {
        case cognitiveBehavioral = "cognitive_behavioral"
        case expressiveTherapy = "expressive_therapy"
        case systemicTherapy = "systemic_therapy"
        case transpersonalTherapy = "transpersonal_therapy"
        case energyPsychology = "energy_psychology"
        
        public var name: String {
            switch self {
            case .cognitiveBehavioral: return "Terapia Cognitivo-Conductual"
            case .expressiveTherapy: return "Terapia Expresiva"
            case .systemicTherapy: return "Terapia Sistémica"
            case .transpersonalTherapy: return "Terapia Transpersonal"
            case .energyPsychology: return "Psicología Energética"
            }
        }
        
        public var description: String {
            switch self {
            case .cognitiveBehavioral: return "Técnicas basadas en evidencia científica para cambiar patrones de pensamiento."
            case .expressiveTherapy: return "Uso del arte y la escritura para procesar emociones."
            case .systemicTherapy: return "Análisis de patrones familiares y generacionales."
            case .transpersonalTherapy: return "Integración de aspectos espirituales en la terapia."
            case .energyPsychology: return "Técnicas que trabajan con el campo energético humano."
            }
        }
    }
    
    // MARK: - Spiritual Elements
    public enum SpiritualElement: String, CaseIterable, Codable {
        case meditation = "meditation"
        case ritual = "ritual"
        case ancestralHealing = "ancestral_healing"
        case ceremony = "ceremony"
        case energyWork = "energy_work"
        case soulWork = "soul_work"
        
        public var name: String {
            switch self {
            case .meditation: return "Meditación"
            case .ritual: return "Ritual"
            case .ancestralHealing: return "Sanación Ancestral"
            case .ceremony: return "Ceremonia"
            case .energyWork: return "Trabajo Energético"
            case .soulWork: return "Trabajo del Alma"
            }
        }
        
        public var description: String {
            switch self {
            case .meditation: return "Prácticas de atención plena y conexión interior."
            case .ritual: return "Ceremonias simbólicas para la transformación."
            case .ancestralHealing: return "Sanación de patrones generacionales."
            case .ceremony: return "Celebraciones sagradas de liberación."
            case .energyWork: return "Técnicas de manipulación del campo energético."
            case .soulWork: return "Trabajo profundo con la esencia del alma."
            }
        }
    }
    
    // MARK: - Emotional Intensity
    public enum EmotionalIntensity: String, CaseIterable, Codable {
        case veryLow = "very_low"
        case low = "low"
        case neutral = "neutral"
        case high = "high"
        case veryHigh = "very_high"
        
        public var name: String {
            switch self {
            case .veryLow: return "Muy Bajo"
            case .low: return "Bajo"
            case .neutral: return "Neutral"
            case .high: return "Alto"
            case .veryHigh: return "Muy Alto"
            }
        }
        
        public var color: Color {
            switch self {
            case .veryLow: return .blue
            case .low: return .green
            case .neutral: return .gray
            case .high: return .orange
            case .veryHigh: return .red
            }
        }
        
        public var description: String {
            switch self {
            case .veryLow: return "Estado de calma profunda"
            case .low: return "Estado relajado y tranquilo"
            case .neutral: return "Estado equilibrado"
            case .high: return "Estado emocional intenso"
            case .veryHigh: return "Estado de alta intensidad emocional"
            }
        }
    }
    
    // MARK: - Hybrid Liberation Session
    public struct HybridLiberationSession: Identifiable, Codable {
        public let id: UUID
        public let technique: HybridTechnique
        public let date: Date
        public var duration: TimeInterval
        public var notes: String
        public var emotionalState: String
        public var progress: Int // 1-10 scale
        public var therapeuticInsights: [String]
        public var spiritualExperiences: [String]
        public var ritualElements: [String]
        public var handwrittenContent: String?
        public var emotionalIntensity: EmotionalIntensity
        
        public init(technique: HybridTechnique, duration: TimeInterval, notes: String, emotionalState: String, progress: Int, therapeuticInsights: [String] = [], spiritualExperiences: [String] = [], ritualElements: [String] = [], handwrittenContent: String? = nil, emotionalIntensity: EmotionalIntensity = .neutral) {
            self.id = UUID()
            self.technique = technique
            self.date = Date()
            self.duration = duration
            self.notes = notes
            self.emotionalState = emotionalState
            self.progress = progress
            self.therapeuticInsights = therapeuticInsights
            self.spiritualExperiences = spiritualExperiences
            self.ritualElements = ritualElements
            self.handwrittenContent = handwrittenContent
            self.emotionalIntensity = emotionalIntensity
        }
    }
    
    // MARK: - Session Management
    public func startSession(technique: HybridTechnique) {
        currentSession = HybridLiberationSession(
            technique: technique,
            duration: 0,
            notes: "",
            emotionalState: "neutral",
            progress: 0,
            emotionalIntensity: .neutral
        )
    }
    
    public func completeSession(notes: String, emotionalState: String, progress: Int, therapeuticInsights: [String] = [], spiritualExperiences: [String] = [], ritualElements: [String] = [], handwrittenContent: String? = nil, emotionalIntensity: EmotionalIntensity = .neutral) {
        guard var session = currentSession else { return }
        
        session.notes = notes
        session.emotionalState = emotionalState
        session.progress = progress
        session.therapeuticInsights = therapeuticInsights
        session.spiritualExperiences = spiritualExperiences
        session.ritualElements = ritualElements
        session.handwrittenContent = handwrittenContent
        session.emotionalIntensity = emotionalIntensity
        session.duration = Date().timeIntervalSince(session.date)
        
        liberationSessions.insert(session, at: 0)
        saveLiberationSessions()
        currentSession = nil
        print("✅ Hybrid liberation session completed and saved: \(session.technique.title)")
    }
    
    // MARK: - Persistence
    private let userDefaultsKey = "hybrid_liberation_sessions"
    
    private func saveLiberationSessions() {
        if let encoded = try? JSONEncoder().encode(liberationSessions) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
            print("💾 Saved \(liberationSessions.count) hybrid liberation sessions.")
        } else {
            print("❌ Failed to save hybrid liberation sessions.")
        }
    }
    
    private func loadLiberationSessions() {
        if let savedSessionsData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedSessions = try? JSONDecoder().decode([HybridLiberationSession].self, from: savedSessionsData) {
            liberationSessions = decodedSessions
            print("📖 Loaded \(liberationSessions.count) hybrid liberation sessions.")
        } else {
            liberationSessions = []
            print("📖 No hybrid liberation sessions found, starting fresh.")
        }
    }
}

