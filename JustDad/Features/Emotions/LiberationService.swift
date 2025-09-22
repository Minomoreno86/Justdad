//
//  LiberationService.swift
//  JustDad - Liberation and Emotional Healing Service
//
//  Servicio simple para técnicas de liberación emocional
//

import Foundation
import SwiftUI

// MARK: - Liberation Service
public class LiberationService: ObservableObject {
    static let shared = LiberationService()
    
    @Published var liberationSessions: [LiberationSession] = []
    
    private init() {
        loadLiberationSessions()
    }
    
    // MARK: - Forgiveness Therapy Integration
    
    func getForgivenessProgress() -> ForgivenessProgress? {
        let forgivenessService = ForgivenessService.shared
        let statistics = forgivenessService.getStatistics()
        
        let totalCompletedDays = statistics.phaseProgress.reduce(0) { $0 + $1.completedDays }
        let averageImprovement = Int(statistics.averagePeaceLevelImprovement)
        
        return ForgivenessProgress(
            id: UUID(),
            phase: .selfForgiveness, // Default phase for overall progress
            completedDays: totalCompletedDays,
            totalDays: 21,
            peaceLevelImprovement: averageImprovement,
            lastSessionDate: statistics.phaseProgress.first?.lastSessionDate
        )
    }
    
    func canStartForgivenessTherapy() -> Bool {
        let forgivenessService = ForgivenessService.shared
        return forgivenessService.canStartSession()
    }
    
    func getNextForgivenessDay() -> Int {
        let forgivenessService = ForgivenessService.shared
        return forgivenessService.getNextAvailableDay()
    }
    
    // MARK: - Liberation Techniques
    public enum LiberationTechnique: String, CaseIterable, Identifiable, Codable {
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
            case .energeticCords: return "Corte de Amarras"
            case .pastLifeBonds: return "Vínculos del Pasado"
            }
        }
        
        public var description: String {
            switch self {
            case .forgivenessTherapy: return "Libera resentimientos y cargas emocionales a través del perdón"
            case .liberationLetter: return "Escribe y libera emociones reprimidas con cartas terapéuticas"
            case .psychogenealogy: return "Libera patrones familiares heredados y ciclos negativos"
            case .liberationRitual: return "Realiza ceremonias simbólicas de liberación y renovación"
            case .energeticCords: return "Corta vínculos energéticos y emocionales tóxicos"
            case .pastLifeBonds: return "Libera conexiones kármicas y vínculos del alma"
            }
        }
        
        var icon: String {
            switch self {
            case .forgivenessTherapy: return "heart.circle.fill"
            case .liberationLetter: return "envelope.circle.fill"
            case .psychogenealogy: return "tree.circle.fill"
            case .liberationRitual: return "candle.fill"
            case .energeticCords: return "scissors"
            case .pastLifeBonds: return "infinity.circle.fill"
            }
        }
        
        var color: Color {
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
            case .forgivenessTherapy: return "15-20 min"
            case .liberationLetter: return "10-15 min"
            case .psychogenealogy: return "20-25 min"
            case .liberationRitual: return "15-20 min"
            case .energeticCords: return "10-15 min"
            case .pastLifeBonds: return "15-20 min"
            }
        }
        
        public var isForgivenessTherapy: Bool {
            return self == .forgivenessTherapy
        }
        
        public var forgivenessDays: Int {
            switch self {
            case .forgivenessTherapy: return 21
            default: return 1
            }
        }
    }
    
    // MARK: - Liberation Session
    public struct LiberationSession: Identifiable, Codable {
        public let id: UUID
        public let technique: LiberationTechnique
        public let date: Date
        public let notes: String
        public let progress: Int // 1-10 scale
        
        public init(technique: LiberationTechnique, notes: String, progress: Int) {
            self.id = UUID()
            self.technique = technique
            self.date = Date()
            self.notes = notes
            self.progress = progress
        }
    }
    
    // MARK: - Session Management
    public func addSession(technique: LiberationTechnique, notes: String, progress: Int) {
        let session = LiberationSession(technique: technique, notes: notes, progress: progress)
        liberationSessions.append(session)
        saveLiberationSessions()
    }
    
    // MARK: - Data Persistence
    private func loadLiberationSessions() {
        if let data = UserDefaults.standard.data(forKey: "liberation_sessions"),
           let sessions = try? JSONDecoder().decode([LiberationSession].self, from: data) {
            liberationSessions = sessions
        }
    }
    
    private func saveLiberationSessions() {
        if let data = try? JSONEncoder().encode(liberationSessions) {
            UserDefaults.standard.set(data, forKey: "liberation_sessions")
        }
    }
}
