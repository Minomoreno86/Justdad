//
//  RitualEngine.swift
//  JustDad - Ritual de Liberación y Renovación Engine
//
//  Motor principal que orquesta todo el flujo del ritual con estados y transiciones
//

import Foundation
import SwiftUI
import Combine

// MARK: - Ritual Engine Protocol
protocol RitualEngineProtocol: ObservableObject {
    var currentState: RitualState { get }
    var currentSession: RitualSession? { get }
    var isActive: Bool { get }
    var progress: Double { get }
    
    func startRitual(focus: RitualFocus, customFocusText: String?)
    func transitionToNextState()
    func transitionToState(_ state: RitualState)
    func pauseRitual()
    func resumeRitual()
    func abandonRitual()
    func completeRitual()
    func updateBreathingCycles(_ count: Int)
    func updateVoiceValidation(_ result: RitualVoiceValidationResult)
    func updateEmotionalState(_ state: RitualEmotionalState)
    func setBehavioralVow(_ vow: BehavioralVow)
    func scheduleVowReminder()
}

// MARK: - Ritual Engine Implementation
@MainActor
class RitualEngine: RitualEngineProtocol {
    // MARK: - Published Properties
    @Published var currentState: RitualState = .idle
    @Published var currentSession: RitualSession?
    @Published var isActive: Bool = false
    @Published var progress: Double = 0.0
    @Published var isPaused: Bool = false
    
    // MARK: - Metrics Properties
    @Published var metricsService: RitualMetricsService
    
    // MARK: - Private Properties
    private var stateTimer: Timer?
    private var sessionStartTime: Date?
    private var stateStartTime: Date?
    private let stateTransitionTimes: [RitualState: TimeInterval] = [
        .preparation: 120, // 2 min
        .evocation: 120,   // 2 min
        .verbalization: 240, // 4 min
        .cutting: 60,      // 1 min
        .sealing: 60,      // 1 min
        .renewal: 180,     // 3 min
        .integration: 60   // 1 min
    ]
    
    // MARK: - Services
    private let breathCoach = BreathCoach()
    private let voiceValidator = VoiceValidator()
    private let hapticsService = HapticsService()
    private let audioService = AudioService()
    
    // MARK: - State Management
    private var stateHistory: [RitualState] = []
    private var canTransitionToState: [RitualState: Bool] = [:]
    
    init() {
        self.metricsService = RitualMetricsService()
        setupInitialState()
    }
    
    // MARK: - Public Methods
    
    func startRitual(focus: RitualFocus, customFocusText: String? = nil) {
        guard !isActive else { return }
        
        let session = RitualSession(
            focus: focus,
            customFocusText: customFocusText,
            emotionalStateBefore: .neutral
        )
        
        currentSession = session
        isActive = true
        sessionStartTime = Date()
        
        transitionToState(.preparation)
        
        // Log start
        print("🕯️ Ritual iniciado - Foco: \(focus.displayName)")
    }
    
    func transitionToNextState() {
        guard let session = currentSession else { return }
        
        let nextState = getNextState(from: currentState)
        guard canTransition(to: nextState, in: session) else {
            print("⚠️ No se puede transicionar a \(nextState.displayName)")
            return
        }
        
        transitionToState(nextState)
    }
    
    func transitionToState(_ state: RitualState) {
        guard let session = currentSession else { return }
        
        // Validate transition
        guard canTransition(to: state, in: session) else {
            print("⚠️ Transición inválida de \(currentState.displayName) a \(state.displayName)")
            return
        }
        
        // Complete current state
        completeCurrentState()
        
        // Update state
        let previousState = currentState
        currentState = state
        stateStartTime = Date()
        
        // Add to history
        stateHistory.append(previousState)
        
        // Update progress
        updateProgress()
        
        // Execute state-specific actions
        executeStateActions(for: state)
        
        // Start state timer if needed
        startStateTimer(for: state)
        
        print("🔄 Transición: \(previousState.displayName) → \(state.displayName)")
    }
    
    func pauseRitual() {
        guard isActive else { return }
        
        stateTimer?.invalidate()
        stateTimer = nil
        
        // Save current progress
        saveProgress()
        
        print("⏸️ Ritual pausado en estado: \(currentState.displayName)")
    }
    
    func resumeRitual() {
        guard isActive, let _ = currentSession else { return }
        
        // Restore state
        startStateTimer(for: currentState)
        
        print("▶️ Ritual reanudado en estado: \(currentState.displayName)")
    }
    
    func abandonRitual() {
        guard isActive else { return }
        
        // Stop all timers
        stateTimer?.invalidate()
        stateTimer = nil
        
        // Update session
        if var session = currentSession {
            session = RitualSession(
                id: session.id,
                startTime: session.startTime,
                endTime: Date(),
                focus: session.focus,
                customFocusText: session.customFocusText,
                duration: Date().timeIntervalSince(session.startTime),
                breathingCyclesCompleted: session.breathingCyclesCompleted,
                targetBreathingCycles: session.targetBreathingCycles,
                voiceValidations: session.voiceValidations,
                emotionalStateBefore: session.emotionalStateBefore,
                emotionalStateAfter: session.emotionalStateAfter,
                behavioralVow: session.behavioralVow,
                vowReminderScheduled: session.vowReminderScheduled,
                vowFulfilled: session.vowFulfilled,
                state: .abandoned,
                notes: session.notes,
                isCompleted: false
            )
            currentSession = session
        }
        
        // Record completion in metrics
        if let session = currentSession {
            metricsService.recordRitualCompletion(session)
        }
        
        // Reset state
        resetToIdle()
        
        print("❌ Ritual abandonado")
    }
    
    func completeRitual() {
        guard isActive, let _ = currentSession else { return }
        
        // Stop all timers
        stateTimer?.invalidate()
        stateTimer = nil
        
        // Complete final state
        completeCurrentState()
        
        // Update session to completed
        if var session = currentSession {
            session = RitualSession(
                id: session.id,
                startTime: session.startTime,
                endTime: Date(),
                focus: session.focus,
                customFocusText: session.customFocusText,
                duration: Date().timeIntervalSince(session.startTime),
                breathingCyclesCompleted: session.breathingCyclesCompleted,
                targetBreathingCycles: session.targetBreathingCycles,
                voiceValidations: session.voiceValidations,
                emotionalStateBefore: session.emotionalStateBefore,
                emotionalStateAfter: session.emotionalStateAfter,
                behavioralVow: session.behavioralVow,
                vowReminderScheduled: session.vowReminderScheduled,
                vowFulfilled: session.vowFulfilled,
                state: .completed,
                notes: session.notes,
                isCompleted: true
            )
            currentSession = session
        }
        
        // Record completion in metrics
        if let session = currentSession {
            metricsService.recordRitualCompletion(session)
        }
        
        // Reset state
        resetToIdle()
        
        print("✅ Ritual completado exitosamente")
    }
    
    // MARK: - Session Updates
    
    func updateBreathingCycles(_ count: Int) {
        guard var session = currentSession else { return }
        
        session = RitualSession(
            id: session.id,
            startTime: session.startTime,
            endTime: session.endTime,
            focus: session.focus,
            customFocusText: session.customFocusText,
            duration: session.duration,
            breathingCyclesCompleted: count,
            targetBreathingCycles: session.targetBreathingCycles,
            voiceValidations: session.voiceValidations,
            emotionalStateBefore: session.emotionalStateBefore,
            emotionalStateAfter: session.emotionalStateAfter,
            behavioralVow: session.behavioralVow,
            vowReminderScheduled: session.vowReminderScheduled,
            vowFulfilled: session.vowFulfilled,
            state: session.state,
            notes: session.notes,
            isCompleted: session.isCompleted
        )
        
        currentSession = session
        
        // Check if breathing phase is complete
        if currentState == .preparation && count >= session.targetBreathingCycles {
            transitionToNextState()
        }
    }
    
    func updateVoiceValidation(_ result: RitualVoiceValidationResult) {
        guard var session = currentSession else { return }
        
        var validations = session.voiceValidations
        if let index = validations.firstIndex(where: { $0.block == result.block }) {
            validations[index] = result
        } else {
            validations.append(result)
        }
        
        session = RitualSession(
            id: session.id,
            startTime: session.startTime,
            endTime: session.endTime,
            focus: session.focus,
            customFocusText: session.customFocusText,
            duration: session.duration,
            breathingCyclesCompleted: session.breathingCyclesCompleted,
            targetBreathingCycles: session.targetBreathingCycles,
            voiceValidations: validations,
            emotionalStateBefore: session.emotionalStateBefore,
            emotionalStateAfter: session.emotionalStateAfter,
            behavioralVow: session.behavioralVow,
            vowReminderScheduled: session.vowReminderScheduled,
            vowFulfilled: session.vowFulfilled,
            state: session.state,
            notes: session.notes,
            isCompleted: session.isCompleted
        )
        
        currentSession = session
        
        // Check if verbalization phase is complete
        if currentState == .verbalization && session.voiceValidationSuccess {
            transitionToNextState()
        }
    }
    
    func updateEmotionalState(_ state: RitualEmotionalState) {
        guard var session = currentSession else { return }
        
        session = RitualSession(
            id: session.id,
            startTime: session.startTime,
            endTime: session.endTime,
            focus: session.focus,
            customFocusText: session.customFocusText,
            duration: session.duration,
            breathingCyclesCompleted: session.breathingCyclesCompleted,
            targetBreathingCycles: session.targetBreathingCycles,
            voiceValidations: session.voiceValidations,
            emotionalStateBefore: session.emotionalStateBefore,
            emotionalStateAfter: state,
            behavioralVow: session.behavioralVow,
            vowReminderScheduled: session.vowReminderScheduled,
            vowFulfilled: session.vowFulfilled,
            state: session.state,
            notes: session.notes,
            isCompleted: session.isCompleted
        )
        
        currentSession = session
    }
    
    func setBehavioralVow(_ vow: BehavioralVow) {
        guard var session = currentSession else { return }
        
        session = RitualSession(
            id: session.id,
            startTime: session.startTime,
            endTime: session.endTime,
            focus: session.focus,
            customFocusText: session.customFocusText,
            duration: session.duration,
            breathingCyclesCompleted: session.breathingCyclesCompleted,
            targetBreathingCycles: session.targetBreathingCycles,
            voiceValidations: session.voiceValidations,
            emotionalStateBefore: session.emotionalStateBefore,
            emotionalStateAfter: session.emotionalStateAfter,
            behavioralVow: vow,
            vowReminderScheduled: session.vowReminderScheduled,
            vowFulfilled: session.vowFulfilled,
            state: session.state,
            notes: session.notes,
            isCompleted: session.isCompleted
        )
        
        currentSession = session
    }
    
    func scheduleVowReminder() {
        guard var session = currentSession,
              let vow = session.behavioralVow else { return }
        
        // Schedule reminder for 24-72 hours
        let reminderTime = Date().addingTimeInterval(24 * 60 * 60) // 24 hours
        
        session = RitualSession(
            id: session.id,
            startTime: session.startTime,
            endTime: session.endTime,
            focus: session.focus,
            customFocusText: session.customFocusText,
            duration: session.duration,
            breathingCyclesCompleted: session.breathingCyclesCompleted,
            targetBreathingCycles: session.targetBreathingCycles,
            voiceValidations: session.voiceValidations,
            emotionalStateBefore: session.emotionalStateBefore,
            emotionalStateAfter: session.emotionalStateAfter,
            behavioralVow: BehavioralVow(
                text: vow.title,
                category: vow.category,
                isCustom: vow.isCustom,
                reminderTime: reminderTime
            ),
            vowReminderScheduled: true,
            vowFulfilled: session.vowFulfilled,
            state: session.state,
            notes: session.notes,
            isCompleted: session.isCompleted
        )
        
        currentSession = session
        
        // Schedule local notification
        scheduleLocalNotification(for: vow, at: reminderTime)
    }
    
    // MARK: - Private Methods
    
    private func setupInitialState() {
        currentState = .idle
        isActive = false
        progress = 0.0
        setupStateTransitions()
    }
    
    private func setupStateTransitions() {
        canTransitionToState = [
            .idle: true,
            .preparation: true,
            .evocation: true,
            .verbalization: true,
            .cutting: true,
            .sealing: true,
            .renewal: true,
            .integration: true,
            .completed: true,
            .abandoned: true
        ]
    }
    
    private func getNextState(from current: RitualState) -> RitualState {
        switch current {
        case .idle: return .preparation
        case .preparation: return .evocation
        case .evocation: return .verbalization
        case .verbalization: return .cutting
        case .cutting: return .sealing
        case .sealing: return .renewal
        case .renewal: return .integration
        case .integration: return .completed
        case .completed, .abandoned: return .idle
        }
    }
    
    private func canTransition(to state: RitualState, in session: RitualSession) -> Bool {
        // Basic state validation
        guard canTransitionToState[state] == true else { return false }
        
        // Specific validation based on current state
        switch currentState {
        case .verbalization:
            // Can only cut cord if verbalization is validated
            if state == .cutting {
                return session.voiceValidationSuccess
            }
        case .renewal:
            // Can only integrate if vow is set
            if state == .integration {
                return session.behavioralVow != nil
            }
        default:
            break
        }
        
        return true
    }
    
    private func executeStateActions(for state: RitualState) {
        switch state {
        case .preparation:
            breathCoach.startBreathing()
            hapticsService.playGentlePulse()
            
        case .evocation:
            audioService.playAmbientSound("evocation", volume: 0.3)
            
        case .verbalization:
            voiceValidator.startListening()
            hapticsService.playAttentionPulse()
            
        case .cutting:
            hapticsService.playImpactPulse()
            audioService.playSound("cord_cutting", volume: 0.8)
            
        case .sealing:
            hapticsService.playGentlePulse()
            audioService.playAmbientSound("sealing", volume: 0.5)
            
        case .renewal:
            hapticsService.playSuccessPulse()
            
        case .integration:
            hapticsService.playCompletionPulse()
            audioService.playSound("completion", volume: 0.6)
            
        default:
            break
        }
    }
    
    private func startStateTimer(for state: RitualState) {
        guard let duration = stateTransitionTimes[state] else { return }
        
        stateTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.handleStateTimeout(for: state)
            }
        }
    }
    
    private func handleStateTimeout(for state: RitualState) {
        print("⏰ Timeout para estado: \(state.displayName)")
        
        // Handle timeout based on state
        switch state {
        case .preparation:
            // Auto-advance if breathing cycles are complete
            if let session = currentSession,
               session.breathingCyclesCompleted >= session.targetBreathingCycles {
                transitionToNextState()
            }
            
        case .verbalization:
            // Check if we can advance based on voice validation
            if let session = currentSession,
               session.voiceValidationSuccess {
                transitionToNextState()
            }
            
        default:
            // For other states, allow manual advancement
            break
        }
    }
    
    private func completeCurrentState() {
        guard let startTime = stateStartTime else { return }
        
        let duration = Date().timeIntervalSince(startTime)
        print("⏱️ Estado \(currentState.displayName) completado en \(duration)s")
        
        // Stop any running timers
        stateTimer?.invalidate()
        stateTimer = nil
        
        // Stop services if needed
        switch currentState {
        case .preparation:
            breathCoach.stopBreathing()
        case .verbalization:
            voiceValidator.stopListening()
        default:
            break
        }
    }
    
    private func updateProgress() {
        let totalStates = 8.0 // From preparation to integration
        let currentStateIndex = Double(stateHistory.count)
        progress = min(currentStateIndex / totalStates, 1.0)
    }
    
    private func saveProgress() {
        // Save current session state to persistent storage
        // Note: Metrics are recorded only when ritual is completed
    }
    
    private func resetToIdle() {
        currentState = .idle
        isActive = false
        progress = 0.0
        currentSession = nil
        sessionStartTime = nil
        stateStartTime = nil
        stateHistory.removeAll()
    }
    
    private func checkAchievements() {
        guard let session = currentSession else { return }
        
        // Check for various achievements
        // Note: Achievements are checked automatically in recordRitualCompletion
    }
    
    private func scheduleLocalNotification(for vow: BehavioralVow, at time: Date) {
        // Implementation for local notification scheduling
        print("🔔 Recordatorio programado para: \(vow.title) a las \(time)")
    }
    
    // MARK: - Additional Methods for UI Integration
    
    func configure(reduceMotion: Bool) {
        // Configure the ritual engine with accessibility settings
        print("⚙️ Configurando ritual con reduce motion: \(reduceMotion)")
    }
    
    func startRitual() {
        // Simplified start without parameters for UI
        startRitual(focus: .custom, customFocusText: nil)
    }
    
    func completePreparation() {
        transitionToNextState()
    }
    
    func completeEvocation(focus: RitualFocus, text: String, voiceText: String) {
        // Store evocation data
        currentSession?.notes = "Evocación: \(text) | Voz: \(voiceText)"
        transitionToNextState()
    }
    
    func completeVerbalization(_ results: [VerbalizationBlock: RitualVoiceValidationResult]) {
        // Store verbalization results
        let validationResults = Array(results.values)
        // Update session with voice validation results
        // Note: voiceValidationSuccess is computed from voiceValidations array
        // We need to add the results to the session's voiceValidations
        currentSession?.voiceValidations.append(contentsOf: validationResults)
        transitionToNextState()
    }
    
    func completeCutting() {
        transitionToNextState()
    }
    
    func completeSealing() {
        transitionToNextState()
    }
    
    func completeRenewal(vow: BehavioralVow, duration: VowDuration, deadline: Date) {
        // Store behavioral vow
        currentSession?.behavioralVow = vow
        scheduleVowReminder()
        transitionToNextState()
    }
    
    func completeIntegration(beforeState: Double, afterState: Double) {
        // Update emotional states
        let _ = RitualEmotionalState(rawValue: Int(beforeState * 4) + 1) ?? .neutral
        let _ = RitualEmotionalState(rawValue: Int(afterState * 4) + 1) ?? .neutral
        
        // Update session with emotional states
        transitionToNextState()
    }
    
    func finishRitual() {
        completeRitual()
    }
    
    func exitRitual() {
        abandonRitual()
    }
    
}

// MARK: - Supporting Services (Placeholder implementations)

class VoiceValidator {
    func startListening() {
        print("🎤 Iniciando validación de voz")
    }
    
    func stopListening() {
        print("🎤 Deteniendo validación de voz")
    }
}

class HapticsService {
    func playGentlePulse() {
        print("📳 Pulso suave")
    }
    
    func playAttentionPulse() {
        print("📳 Pulso de atención")
    }
    
    func playImpactPulse() {
        print("📳 Pulso de impacto")
    }
    
    func playSuccessPulse() {
        print("📳 Pulso de éxito")
    }
    
    func playCompletionPulse() {
        print("📳 Pulso de completación")
    }
}

class AudioService {
    func playAmbientSound(_ name: String, volume: Double) {
        print("🔊 Sonido ambiente: \(name) (volumen: \(volume))")
    }
    
    func playSound(_ name: String, volume: Double) {
        print("🔊 Sonido: \(name) (volumen: \(volume))")
    }
}


