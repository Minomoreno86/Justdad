//
//  LiberationLetterService.swift
//  JustDad - Liberation Letter Service
//
//  Servicio principal para manejar las sesiones de Cartas de Liberación
//

import Foundation
import SwiftUI
import Combine

// MARK: - Liberation Letter Service
@MainActor
class LiberationLetterService: ObservableObject {
    static let shared = LiberationLetterService()
    
    // MARK: - Published Properties
    @Published var sessions: [LiberationLetterSession] = []
    @Published var currentDay: Int = 1
    @Published var isSessionActive = false
    @Published var currentSession: LiberationLetterSession?
    @Published var progress: [LiberationLetterPhase: LiberationLetterProgress] = [:]
    
    // MARK: - Private Properties
    private let dataProvider = LiberationLetterDataProvider.shared
    private let speechService = LiberationLetterSpeechService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadSessions()
        calculateProgress()
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    /// Obtiene la carta para el día actual
    func getCurrentLetter() -> LiberationLetter? {
        return dataProvider.getLetter(for: currentDay)
    }
    
    /// Obtiene la carta para un día específico
    func getLetter(for day: Int) -> LiberationLetter? {
        return dataProvider.getLetter(for: day)
    }
    
    /// Obtiene todas las cartas de una fase
    func getLetters(for phase: LiberationLetterPhase) -> [LiberationLetter] {
        return dataProvider.getLetters(for: phase)
    }
    
    /// Inicia una nueva sesión
    func startSession(for day: Int) -> LiberationLetter? {
        guard let letter = getLetter(for: day) else { return nil }
        
        let session = LiberationLetterSession(letter: letter)
        currentSession = session
        isSessionActive = true
        currentDay = day
        
        return letter
    }
    
    /// Completa la sesión actual
    func completeSession(
        detectedAnchors: [String],
        emotionalState: EmotionalState,
        notes: String,
        completionTime: TimeInterval
    ) {
        guard var session = currentSession else { return }
        
        // Update session with results
        session = LiberationLetterSession(
            letter: session.letter,
            detectedAnchors: detectedAnchors,
            emotionalState: emotionalState,
            notes: notes,
            completionTime: completionTime
        )
        
        // Add to sessions
        sessions.append(session)
        saveSessions()
        
        // Move to next day if current day was completed
        if session.isCompleted && currentDay < 21 {
            currentDay += 1
        }
        
        // Reset session state
        currentSession = nil
        isSessionActive = false
        
        // Recalculate progress
        calculateProgress()
    }
    
    /// Obtiene el progreso de una fase específica
    func getProgress(for phase: LiberationLetterPhase) -> LiberationLetterProgress {
        return progress[phase] ?? LiberationLetterProgress(
            phase: phase,
            completedDays: 0,
            totalDays: getLetters(for: phase).count,
            lastCompletedDay: nil,
            averageCompletionTime: 0,
            totalSessions: 0
        )
    }
    
    /// Obtiene el progreso general
    func getOverallProgress() -> LiberationLetterProgress {
        let totalCompleted = sessions.filter { $0.isCompleted }.count
        let totalDays = 21
        let averageTime = sessions.isEmpty ? 0 : sessions.map { $0.completionTime }.reduce(0, +) / Double(sessions.count)
        
        return LiberationLetterProgress(
            phase: .selfHealing, // Use as overall indicator
            completedDays: totalCompleted,
            totalDays: totalDays,
            lastCompletedDay: sessions.last?.letter.day,
            averageCompletionTime: averageTime,
            totalSessions: sessions.count
        )
    }
    
    /// Verifica si un día está completado
    func isDayCompleted(_ day: Int) -> Bool {
        return sessions.contains { $0.letter.day == day && $0.isCompleted }
    }
    
    /// Obtiene la sesión para un día específico
    func getSession(for day: Int) -> LiberationLetterSession? {
        return sessions.first { $0.letter.day == day }
    }
    
    /// Obtiene el próximo día disponible
    func getNextAvailableDay() -> Int {
        for day in 1...21 {
            if !isDayCompleted(day) {
                return day
            }
        }
        return 21 // All completed
    }
    
    /// Verifica si puede iniciar una sesión
    func canStartSession() -> Bool {
        return !isSessionActive
    }
    
    /// Reinicia el progreso (para testing o reset completo)
    func resetProgress() {
        sessions.removeAll()
        currentDay = 1
        currentSession = nil
        isSessionActive = false
        progress.removeAll()
        saveSessions()
    }
    
    /// Obtiene estadísticas detalladas
    func getDetailedStatistics() -> LiberationLetterStatistics {
        let completedSessions = sessions.filter { $0.isCompleted }
        let totalSessions = sessions.count
        let averageCompletionTime = completedSessions.isEmpty ? 0 : 
            completedSessions.map { $0.completionTime }.reduce(0, +) / Double(completedSessions.count)
        
        let emotionalStates = completedSessions.compactMap { $0.emotionalState }
        let mostCommonEmotionalState = emotionalStates.isEmpty ? nil :
            Dictionary(grouping: emotionalStates, by: { $0 })
                .max(by: { $0.value.count < $1.value.count })?.key
        
        let phaseProgress = LiberationLetterPhase.allCases.map { phase in
            getProgress(for: phase)
        }
        
        return LiberationLetterStatistics(
            totalSessions: totalSessions,
            completedSessions: completedSessions.count,
            averageCompletionTime: averageCompletionTime,
            mostCommonEmotionalState: mostCommonEmotionalState,
            phaseProgress: phaseProgress,
            currentDay: currentDay,
            isSessionActive: isSessionActive
        )
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Listen to speech service changes
        speechService.$isListening
            .sink { [weak self] isListening in
                if !isListening && self?.isSessionActive == true {
                    // Session might have ended
                }
            }
            .store(in: &cancellables)
    }
    
    private func calculateProgress() {
        for phase in LiberationLetterPhase.allCases {
            let phaseSessions = sessions.filter { $0.letter.phase == phase && $0.isCompleted }
            let phaseLetters = getLetters(for: phase)
            
            let completedDays = phaseSessions.count
            let totalDays = phaseLetters.count
            let lastCompletedDay = phaseSessions.last?.letter.day
            let averageCompletionTime = phaseSessions.isEmpty ? 0 :
                phaseSessions.map { $0.completionTime }.reduce(0, +) / Double(phaseSessions.count)
            
            progress[phase] = LiberationLetterProgress(
                phase: phase,
                completedDays: completedDays,
                totalDays: totalDays,
                lastCompletedDay: lastCompletedDay,
                averageCompletionTime: averageCompletionTime,
                totalSessions: phaseSessions.count
            )
        }
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: "liberation_letter_sessions"),
           let loadedSessions = try? JSONDecoder().decode([LiberationLetterSession].self, from: data) {
            sessions = loadedSessions
        }
        
        // Load current day
        currentDay = UserDefaults.standard.integer(forKey: "liberation_letter_current_day")
        if currentDay == 0 {
            currentDay = 1
        }
    }
    
    private func saveSessions() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: "liberation_letter_sessions")
        }
        UserDefaults.standard.set(currentDay, forKey: "liberation_letter_current_day")
    }
}

// MARK: - Liberation Letter Statistics
struct LiberationLetterStatistics {
    let totalSessions: Int
    let completedSessions: Int
    let averageCompletionTime: TimeInterval
    let mostCommonEmotionalState: EmotionalState?
    let phaseProgress: [LiberationLetterProgress]
    let currentDay: Int
    let isSessionActive: Bool
    
    var completionRate: Double {
        guard totalSessions > 0 else { return 0.0 }
        return Double(completedSessions) / Double(totalSessions)
    }
    
    var formattedAverageTime: String {
        let minutes = Int(averageCompletionTime / 60)
        let seconds = Int(averageCompletionTime.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Session State Management
extension LiberationLetterService {
    
    /// Pausa la sesión actual
    func pauseSession() {
        speechService.pauseListening()
    }
    
    /// Resume la sesión actual
    func resumeSession() {
        speechService.resumeListening()
    }
    
    /// Cancela la sesión actual
    func cancelSession() {
        speechService.stopListening()
        currentSession = nil
        isSessionActive = false
    }
    
    /// Obtiene el estado de la sesión actual
    func getSessionState() -> LiberationSessionState {
        if isSessionActive {
            return .active
        } else if currentDay > 21 {
            return .completed
        } else {
            return .ready
        }
    }
}

// MARK: - Liberation Session State
enum LiberationSessionState {
    case ready
    case active
    case paused
    case completed
    
    var displayName: String {
        switch self {
        case .ready: return "Listo para comenzar"
        case .active: return "Sesión activa"
        case .paused: return "Sesión pausada"
        case .completed: return "Completado"
        }
    }
    
    var color: Color {
        switch self {
        case .ready: return .blue
        case .active: return .green
        case .paused: return .orange
        case .completed: return .purple
        }
    }
}
