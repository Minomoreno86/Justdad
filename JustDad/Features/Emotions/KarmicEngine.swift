//
//  KarmicEngine.swift
//  JustDad - Karmic Bonds Liberation Engine
//
//  Orquestador principal del ritual de liberación de vínculos pesados
//

import Foundation
import SwiftUI
import Combine

// MARK: - Karmic Engine
public class KarmicEngine: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var currentState: KarmicRitualState = .idle
    @Published public var isActive: Bool = false
    @Published public var progress: Double = 0.0
    @Published public var currentSession: KarmicSession?
    @Published public var isPaused: Bool = false
    @Published public var sessionStartTime: Date?
    @Published public var stateStartTime: Date?
    @Published public var stateHistory: [KarmicRitualState] = []
    @Published public var metricsService: KarmicMetricsService
    
    // MARK: - Private Properties
    private var stateTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - State Transitions
    private let canTransitionToState: [KarmicRitualState: Bool] = [
        .idle: true,
        .preparation: true,
        .breathing: true,
        .evocation: true,
        .recognition: true,
        .liberation: true,
        .returning: true,
        .cutting: true,
        .sealing: true,
        .renewal: true,
        .completed: true,
        .abandoned: true
    ]
    
    // MARK: - Initialization
    public init() {
        self.metricsService = KarmicMetricsService()
        setupInitialState()
    }
    
    // MARK: - Public Methods
    
    /// Configura la sesión actual
    public func configureSession(
        focus: KarmicApproach,
        bondName: String,
        bondType: KarmicBondType,
        intensity: Int
    ) {
        // Configurar sesión basada en los parámetros
        print("🔧 Sesión configurada - Enfoque: \(focus), Vínculo: \(bondName)")
    }
    
    /// Obtiene el script actual
    public func getCurrentScript() -> KarmicScript {
        guard let session = currentSession else {
            return KarmicContentPack.shared.getScript(at: 0, approach: .secular) ?? KarmicContentPack.shared.secularScripts[0]
        }
        
        // Seleccionar script basado en el tipo de vínculo y enfoque
        let scriptIndex = getScriptIndex(for: session.bondType)
        return KarmicContentPack.shared.getScript(at: scriptIndex, approach: session.approach) ?? KarmicContentPack.shared.secularScripts[0]
    }
    
    /// Obtiene el índice del script basado en el tipo de vínculo
    private func getScriptIndex(for bondType: KarmicBondType) -> Int {
        switch bondType {
        case .exPartner:
            return 0 // Primer script (expareja)
        case .ancestralLoyalty:
            return 1 // Segundo script (lealtad ancestral)
        case .emotionalDebt:
            return 2 // Tercer script (deuda emocional)
        case .soulBond:
            return 3 // Cuarto script (vínculo de alma)
        case .betrayalRumination:
            return 4 // Quinto script (traición)
        case .brokenPromises:
            return 5 // Sexto script (promesas rotas)
        case .emotionalDependency:
            return 6 // Séptimo script (dependencia emocional)
        case .projectionBurden:
            return 7 // Octavo script (proyecciones)
        case .controlStruggle:
            return 8 // Noveno script (control)
        case .unrequitedSoul:
            return 9 // Décimo script (amor no correspondido)
        case .descendantsPast:
            return 10 // Undécimo script (descendientes del pasado)
        case .descendantsFuture:
            return 11 // Duodécimo script (descendientes del futuro)
        case .karmicLineage:
            return 12 // Decimotercer script (línea kármica completa)
        }
    }
    
    /// Obtiene votos sugeridos
    public func getSuggestedVows() -> [KarmicBehavioralVow] {
        return [
            KarmicBehavioralVow(
                title: "No contacto",
                duration: .twentyFourHours,
                category: .noContact,
                isCustom: false,
                reminderDate: nil
            ),
            KarmicBehavioralVow(
                title: "Meditación diaria",
                duration: .seventyTwoHours,
                category: .mindfulness,
                isCustom: false,
                reminderDate: nil
            ),
            KarmicBehavioralVow(
                title: "Autocuidado",
                duration: .twentyFourHours,
                category: .selfCare,
                isCustom: false,
                reminderDate: nil
            )
        ]
    }
    
    /// Obtiene logros nuevos
    public func getNewAchievements() -> [KarmicAchievement] {
        return []
    }
    
    /// Obtiene todos los logros
    public func getAllAchievements() -> [KarmicAchievement] {
        return KarmicAchievement.allCases
    }
    
    /// Obtiene duración de la sesión
    public func getSessionDuration() -> TimeInterval {
        guard let startTime = sessionStartTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
    
    /// Obtiene puntos de la sesión
    public func getSessionPoints() -> Int {
        return 100 // Puntos base
    }
    
    /// Actualiza texto de evocación
    public func updateEvocationText(_ text: String) {
        // Store evocation text in a temporary property
        print("📝 Texto de evocación actualizado: \(text)")
    }
    
    /// Inicia validación de voz
    public func startVoiceValidation(for block: KarmicReadingBlock) {
        print("🎤 Iniciando validación de voz para bloque: \(block.displayName)")
    }
    
    /// Detiene validación de voz
    public func stopVoiceValidation(for block: KarmicReadingBlock) -> KarmicVoiceValidation {
        // Simular validación exitosa
        let anchors = ["te reconozco", "te libero", "te devuelvo"]
        return KarmicVoiceValidation(
            block: block,
            validatedAnchors: anchors,
            totalAnchors: anchors
        )
    }
    
    /// Establece voto de comportamiento
    public func setBehavioralVow(_ vow: KarmicBehavioralVow) {
        // Store vow in a temporary property
        print("🤝 Voto de comportamiento establecido: \(vow.title)")
    }
    
    /// Inicia una nueva sesión de liberación kármica
    public func startKarmicRitual(
        bondType: KarmicBondType,
        approach: KarmicApproach,
        bondName: String,
        intensityBefore: Int
    ) {
        guard !isActive else { return }
        
        let session = KarmicSession(
            bondType: bondType,
            approach: approach,
            bondName: bondName,
            intensityBefore: intensityBefore,
            state: .preparation
        )
        
        currentSession = session
        isActive = true
        sessionStartTime = Date()
        
        // Ir directamente al estado de respiración ya que la preparación se hizo en la vista de bienvenida
        transitionToState(.breathing)
        
        // Log start
        print("🔮 Ritual Kármico iniciado - Tipo: \(bondType.displayName), Enfoque: \(approach.displayName)")
    }
    
    /// Pausa el ritual actual
    public func pauseRitual() {
        guard isActive else { return }
        
        stateTimer?.invalidate()
        stateTimer = nil
        isPaused = true
        
        print("⏸️ Ritual pausado")
    }
    
    /// Reanuda el ritual pausado
    public func resumeRitual() {
        guard isActive && isPaused else { return }
        
        isPaused = false
        stateStartTime = Date()
        
        print("▶️ Ritual reanudado")
    }
    
    /// Abandona el ritual actual
    public func abandonRitual() {
        guard isActive else { return }
        
        stateTimer?.invalidate()
        stateTimer = nil
        
        // Update session to abandoned
        if var session = currentSession {
            let updatedSession = KarmicSession(
                id: session.id,
                startTime: session.startTime,
                endTime: Date(),
                bondType: session.bondType,
                approach: session.approach,
                bondName: session.bondName,
                intensityBefore: session.intensityBefore,
                intensityAfter: session.intensityAfter,
                voiceValidations: session.voiceValidations,
                behavioralVow: session.behavioralVow,
                vowCompleted: session.vowCompleted,
                state: .abandoned,
                notes: session.notes,
                isCompleted: false
            )
            currentSession = updatedSession
        }
        
        // Record completion in metrics (if partially completed)
        if let session = currentSession {
            metricsService.recordKarmicSession(session)
        }
        
        // Reset state
        resetToIdle()
        
        print("❌ Ritual abandonado")
    }
    
    /// Completa el ritual exitosamente
    public func completeRitual(intensityAfter: Int, notes: String? = nil) {
        guard isActive, var session = currentSession else { return }
        
        // Stop all timers
        stateTimer?.invalidate()
        stateTimer = nil
        
        // Complete final state
        completeCurrentState()
        
        // Update session to completed
        let completedSession = KarmicSession(
            id: session.id,
            startTime: session.startTime,
            endTime: Date(),
            bondType: session.bondType,
            approach: session.approach,
            bondName: session.bondName,
            intensityBefore: session.intensityBefore,
            intensityAfter: intensityAfter,
            voiceValidations: session.voiceValidations,
            behavioralVow: session.behavioralVow,
            vowCompleted: session.vowCompleted,
            state: .completed,
            notes: notes,
            isCompleted: true
        )
        currentSession = completedSession
        
        // Record completion in metrics
        metricsService.recordKarmicSession(completedSession)
        
        // Reset state
        resetToIdle()
        
        print("✅ Ritual completado exitosamente")
    }
    
    /// Sale del ritual (diferente a abandonar)
    public func exitRitual() {
        abandonRitual()
    }
    
    // MARK: - State Management
    
    /// Transiciona al siguiente estado del ritual
    public func transitionToNextState() {
        let nextState = getNextState()
        transitionToState(nextState)
    }
    
    /// Transiciona a un estado específico
    public func transitionToState(_ newState: KarmicRitualState) {
        guard canTransitionToState[newState] == true else {
            print("⚠️ No se puede transicionar a \(newState.phaseName)")
            return
        }
        
        // Complete current state
        completeCurrentState()
        
        // Update state
        let previousState = currentState
        currentState = newState
        stateStartTime = Date()
        stateHistory.append(previousState)
        
        // Update progress
        updateProgress()
        
        // Update session state
        if var session = currentSession {
            let updatedSession = KarmicSession(
                id: session.id,
                startTime: session.startTime,
                endTime: session.endTime,
                bondType: session.bondType,
                approach: session.approach,
                bondName: session.bondName,
                intensityBefore: session.intensityBefore,
                intensityAfter: session.intensityAfter,
                voiceValidations: session.voiceValidations,
                behavioralVow: session.behavioralVow,
                vowCompleted: session.vowCompleted,
                state: newState,
                notes: session.notes,
                isCompleted: session.isCompleted
            )
            currentSession = updatedSession
        }
        
        // Start state timer if needed
        startStateTimer(for: newState)
        
        print("🔄 Transición: \(previousState.phaseName) → \(newState.phaseName)")
    }
    
    /// Completa la fase de preparación
    public func completePreparation() {
        transitionToNextState()
    }
    
    /// Completa la fase de respiración
    public func completeBreathing() {
        transitionToNextState()
    }
    
    public func completeEvocation() {
        transitionToNextState()
    }
    
    public func completeCutting() {
        transitionToNextState()
    }
    
    public func completeSealing() {
        transitionToNextState()
    }
    
    public func completeRenewal() {
        transitionToNextState()
    }
    
    public func completeRitual() {
        transitionToState(.completed)
        isActive = false
    }
    
    public func completeReadingBlock(_ block: KarmicReadingBlock) {
        transitionToNextState()
    }
    
    /// Completa un bloque de lectura
    public func completeReadingBlock(_ block: KarmicReadingBlock, validation: KarmicVoiceValidation) {
        // Add validation to session
        if var session = currentSession {
            var updatedValidations = session.voiceValidations
            updatedValidations.append(validation)
            
            let updatedSession = KarmicSession(
                id: session.id,
                startTime: session.startTime,
                endTime: session.endTime,
                bondType: session.bondType,
                approach: session.approach,
                bondName: session.bondName,
                intensityBefore: session.intensityBefore,
                intensityAfter: session.intensityAfter,
                voiceValidations: updatedValidations,
                behavioralVow: session.behavioralVow,
                vowCompleted: session.vowCompleted,
                state: session.state,
                notes: session.notes,
                isCompleted: session.isCompleted
            )
            currentSession = updatedSession
        }
        
        // Transition to next block or cutting phase
        switch block {
        case .recognition:
            if currentState == .recognition {
                transitionToNextState()
            }
        case .liberation:
            if currentState == .liberation {
                transitionToNextState()
            }
        case .returning:
            if currentState == .returning {
                transitionToNextState()
            }
        }
    }
    
    
    /// Completa la fase de renovación
    public func completeRenewal(vow: KarmicBehavioralVow) {
        // Add vow to session
        if var session = currentSession {
            let updatedSession = KarmicSession(
                id: session.id,
                startTime: session.startTime,
                endTime: session.endTime,
                bondType: session.bondType,
                approach: session.approach,
                bondName: session.bondName,
                intensityBefore: session.intensityBefore,
                intensityAfter: session.intensityAfter,
                voiceValidations: session.voiceValidations,
                behavioralVow: vow,
                vowCompleted: session.vowCompleted,
                state: session.state,
                notes: session.notes,
                isCompleted: session.isCompleted
            )
            currentSession = updatedSession
        }
        
        transitionToNextState()
    }
    
    /// Configura el engine (para accesibilidad)
    public func configure(reduceMotion: Bool = false) {
        // Configuration for accessibility
        print("🔧 KarmicEngine configurado - Reduce Motion: \(reduceMotion)")
    }
    
    // MARK: - Private Methods
    
    private func setupInitialState() {
        currentState = .idle
        isActive = false
        progress = 0.0
        currentSession = nil
        sessionStartTime = nil
        stateStartTime = nil
        stateHistory.removeAll()
    }
    
    private func getNextState() -> KarmicRitualState {
        switch currentState {
        case .idle:
            return .preparation
        case .preparation:
            return .breathing
        case .breathing:
            return .evocation
        case .evocation:
            return .recognition
        case .recognition:
            return .liberation
        case .liberation:
            return .returning
        case .returning:
            return .cutting
        case .cutting:
            return .sealing
        case .sealing:
            return .renewal
        case .renewal:
            return .completed
        case .completed, .abandoned:
            return .idle
        }
    }
    
    private func updateProgress() {
        let totalStates = KarmicRitualState.allCases.count - 2 // Exclude completed and abandoned
        let currentOrder = currentState.order
        progress = Double(currentOrder) / Double(totalStates)
    }
    
    private func completeCurrentState() {
        // Handle any cleanup for the current state
        stateTimer?.invalidate()
        stateTimer = nil
    }
    
    private func startStateTimer(for state: KarmicRitualState) {
        // Start timer for states that need automatic progression
        let duration: TimeInterval
        
        switch state {
        case .preparation:
            duration = 60 // 1 minute
        case .breathing:
            duration = 120 // 2 minutes
        case .evocation:
            duration = 180 // 3 minutes
        case .recognition, .liberation, .returning:
            duration = 300 // 5 minutes per reading block
        case .cutting:
            duration = 60 // 1 minute
        case .sealing:
            duration = 90 // 1.5 minutes
        case .renewal:
            duration = 180 // 3 minutes
        default:
            duration = 0 // No timer
        }
        
        if duration > 0 {
            stateTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.handleStateTimeout()
                }
            }
        }
    }
    
    private func handleStateTimeout() {
        // Handle timeout for current state
        print("⏰ Timeout para estado: \(currentState.phaseName)")
        
        // Auto-progress for certain states
        switch currentState {
        case .preparation, .breathing, .evocation:
            transitionToNextState()
        default:
            break
        }
    }
    
    private func resetToIdle() {
        currentState = .idle
        isActive = false
        progress = 0.0
        currentSession = nil
        sessionStartTime = nil
        stateStartTime = nil
        stateHistory.removeAll()
        isPaused = false
    }
}

// MARK: - Karmic Metrics Service
public class KarmicMetricsService: ObservableObject {
    @Published public var totalSessions: Int = 0
    @Published public var completedSessions: Int = 0
    @Published public var currentStreak: Int = 0
    @Published public var bestStreak: Int = 0
    @Published public var totalPoints: Int = 0
    @Published public var unlockedAchievements: Set<KarmicAchievement> = []
    @Published public var lastSessionDate: Date?
    
    public init() {
        loadMetrics()
    }
    
    public func recordKarmicSession(_ session: KarmicSession) {
        totalSessions += 1
        
        if session.isCompleted {
            completedSessions += 1
            
            // Award points
            let pointsEarned = calculatePoints(for: session)
            totalPoints += pointsEarned
            
            // Update streak
            updateStreak()
            
            // Check achievements
            checkAchievements(for: session)
        }
        
        lastSessionDate = session.startTime
        saveMetrics()
    }
    
    private func calculatePoints(for session: KarmicSession) -> Int {
        var points = 100 // Base points for completion
        
        // Bonus for intensity improvement
        if let improvement = session.intensityImprovement, improvement > 0 {
            points += improvement * 20
        }
        
        // Bonus for successful voice validations
        let successfulValidations = session.voiceValidations.filter { $0.success }.count
        points += successfulValidations * 25
        
        // Bonus for vow completion
        if let vowCompleted = session.vowCompleted, vowCompleted {
            points += 50
        }
        
        return points
    }
    
    private func updateStreak() {
        let calendar = Calendar.current
        let today = Date()
        
        if let lastDate = lastSessionDate,
           calendar.isDate(lastDate, inSameDayAs: today) {
            currentStreak += 1
        } else if let lastDate = lastSessionDate,
                  calendar.dateInterval(of: .day, for: lastDate)?.end ?? Date() < today {
            // Check if it's the next day
            if calendar.dateInterval(of: .day, for: lastDate)?.end ?? Date() < today {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }
        
        if currentStreak > bestStreak {
            bestStreak = currentStreak
        }
    }
    
    private func checkAchievements(for session: KarmicSession) {
        var newAchievements: Set<KarmicAchievement> = []
        
        // Always unlock first liberation on first completion
        newAchievements.insert(.firstLiberation)
        
        // Check bond cutter achievement
        if completedSessions >= 3 {
            newAchievements.insert(.bondCutter)
        }
        
        // Check ancestral liberator achievement
        if session.bondType == .ancestralLoyalty {
            newAchievements.insert(.ancestralLiberator)
        }
        
        // Check light soul achievement
        if completedSessions >= 21 {
            newAchievements.insert(.lightSoul)
        }
        
        // Check vow keeper achievement
        if session.vowCompleted == true {
            newAchievements.insert(.vowKeeper)
        }
        
        // Check streak master achievement
        if currentStreak >= 7 {
            newAchievements.insert(.streakMaster)
        }
        
        // Check intensity master achievement
        if (session.intensityImprovement ?? 0) >= 3 {
            newAchievements.insert(.intensityMaster)
        }
        
        // Check voice master achievement
        if session.voiceValidations.allSatisfy({ $0.success }) {
            newAchievements.insert(.voiceMaster)
        }
        
        for achievement in newAchievements {
            if !unlockedAchievements.contains(achievement) {
                unlockedAchievements.insert(achievement)
                totalPoints += achievement.pointsReward
            }
        }
    }
    
    private func loadMetrics() {
        // Load from UserDefaults or Core Data
        if let data = UserDefaults.standard.data(forKey: "karmic_metrics"),
           let decoded = try? JSONDecoder().decode(KarmicMetricsData.self, from: data) {
            totalSessions = decoded.totalSessions
            completedSessions = decoded.completedSessions
            currentStreak = decoded.currentStreak
            bestStreak = decoded.bestStreak
            totalPoints = decoded.totalPoints
            unlockedAchievements = Set(decoded.unlockedAchievements)
            lastSessionDate = decoded.lastSessionDate
        }
    }
    
    private func saveMetrics() {
        let data = KarmicMetricsData(
            totalSessions: totalSessions,
            completedSessions: completedSessions,
            currentStreak: currentStreak,
            bestStreak: bestStreak,
            totalPoints: totalPoints,
            unlockedAchievements: Array(unlockedAchievements),
            lastSessionDate: lastSessionDate
        )
        
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: "karmic_metrics")
        }
    }
}

// MARK: - Karmic Metrics Data
private struct KarmicMetricsData: Codable {
    let totalSessions: Int
    let completedSessions: Int
    let currentStreak: Int
    let bestStreak: Int
    let totalPoints: Int
    let unlockedAchievements: [KarmicAchievement]
    let lastSessionDate: Date?
}
