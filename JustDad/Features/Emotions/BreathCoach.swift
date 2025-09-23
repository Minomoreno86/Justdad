//
//  BreathCoach.swift
//  JustDad - Ritual Breath Coach
//
//  Coach de respiración guiada para el ritual de liberación
//

import Foundation
import SwiftUI
import Combine

// MARK: - Breathing Phase
enum RitualBreathingPhase: String, CaseIterable {
    case inhale = "inhale"
    case hold = "hold"
    case exhale = "exhale"
    case rest = "rest"
    
    var displayName: String {
        switch self {
        case .inhale: return "Inhalar"
        case .hold: return "Mantener"
        case .exhale: return "Exhalar"
        case .rest: return "Descansar"
        }
    }
    
    var instruction: String {
        switch self {
        case .inhale: return "Inhala lentamente"
        case .hold: return "Mantén la respiración"
        case .exhale: return "Exhala suavemente"
        case .rest: return "Descansa un momento"
        }
    }
    
    var color: Color {
        switch self {
        case .inhale: return .blue
        case .hold: return .green
        case .exhale: return .purple
        case .rest: return .gray
        }
    }
}

// MARK: - Ritual Breathing Pattern
struct RitualBreathingPattern: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: String
    let description: String
    let inhaleDuration: TimeInterval
    let holdDuration: TimeInterval
    let exhaleDuration: TimeInterval
    let restDuration: TimeInterval
    let targetCycles: Int
    let isReduceMotion: Bool
    
    var totalCycleDuration: TimeInterval {
        return inhaleDuration + holdDuration + exhaleDuration + restDuration
    }
    
    var totalDuration: TimeInterval {
        return totalCycleDuration * Double(targetCycles)
    }
    
    var estimatedTotalDuration: TimeInterval {
        return totalDuration
    }
    
    static let fourSevenEight = RitualBreathingPattern(
        name: "4-7-8",
        description: "Respiración relajante profunda",
        inhaleDuration: 4.0,
        holdDuration: 7.0,
        exhaleDuration: 8.0,
        restDuration: 1.0,
        targetCycles: 7,
        isReduceMotion: false
    )
    
    static let fiveFive = RitualBreathingPattern(
        name: "5-5",
        description: "Respiración equilibrada",
        inhaleDuration: 5.0,
        holdDuration: 0.0,
        exhaleDuration: 5.0,
        restDuration: 1.0,
        targetCycles: 7,
        isReduceMotion: false
    )
    
    static let fourFourFour = RitualBreathingPattern(
        name: "4-4-4",
        description: "Respiración cuadrada",
        inhaleDuration: 4.0,
        holdDuration: 4.0,
        exhaleDuration: 4.0,
        restDuration: 1.0,
        targetCycles: 7,
        isReduceMotion: false
    )
    
    static let allPatterns = [fourSevenEight, fiveFive, fourFourFour]
}

// MARK: - Breath Coach Protocol
protocol BreathCoachProtocol: ObservableObject {
    var isActive: Bool { get }
    var currentCycle: Int { get }
    var targetCycles: Int { get }
    var remainingTime: TimeInterval { get }
    var progress: Double { get }
    var selectedPattern: RitualBreathingPattern { get }
    var reduceMotion: Bool { get }
    
    func startBreathing(pattern: RitualBreathingPattern?)
    func pauseBreathing()
    func resumeBreathing()
    func stopBreathing()
    func setPattern(_ pattern: RitualBreathingPattern)
    func setReduceMotion(_ enabled: Bool)
}

// MARK: - Breath Coach Implementation
@MainActor
class BreathCoach: BreathCoachProtocol {
    
    // MARK: - Published Properties
    @Published var isActive: Bool = false
    @Published var currentCycle: Int = 0
    @Published var targetCycles: Int = 7
    @Published var remainingTime: TimeInterval = 0
    @Published var progress: Double = 0.0
    @Published var selectedPattern: RitualBreathingPattern = .fourSevenEight
    @Published var reduceMotion: Bool = false
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var currentPhase: RitualBreathingPhase = .rest
    private var phaseStartTime: Date?
    private var totalStartTime: Date?
    
    // MARK: - Callbacks
    var onCycleComplete: ((Int) -> Void)?
    var onSessionComplete: (() -> Void)?
    var onPhaseChange: ((RitualBreathingPhase) -> Void)?
    
    // MARK: - Public Methods
    func startBreathing(pattern: RitualBreathingPattern? = nil) {
        let selectedPattern = pattern ?? self.selectedPattern
        self.selectedPattern = selectedPattern
        self.targetCycles = selectedPattern.targetCycles
        self.currentCycle = 0
        self.isActive = true
        self.totalStartTime = Date()
        
        startPhase(.inhale)
    }
    
    func pauseBreathing() {
        timer?.invalidate()
        timer = nil
    }
    
    func resumeBreathing() {
        startPhase(currentPhase)
    }
    
    func stopBreathing() {
        timer?.invalidate()
        timer = nil
        isActive = false
        currentCycle = 0
        progress = 0.0
        remainingTime = 0
    }
    
    func setPattern(_ pattern: RitualBreathingPattern) {
        selectedPattern = pattern
        targetCycles = pattern.targetCycles
    }
    
    func setReduceMotion(_ enabled: Bool) {
        reduceMotion = enabled
    }
    
    // MARK: - Private Methods
    private func startPhase(_ phase: RitualBreathingPhase) {
        currentPhase = phase
        phaseStartTime = Date()
        onPhaseChange?(phase)
        
        let duration = getPhaseDuration(for: phase)
        
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.completePhase()
        }
    }
    
    private func getPhaseDuration(for phase: RitualBreathingPhase) -> TimeInterval {
        switch phase {
        case .inhale: return selectedPattern.inhaleDuration
        case .hold: return selectedPattern.holdDuration
        case .exhale: return selectedPattern.exhaleDuration
        case .rest: return selectedPattern.restDuration
        }
    }
    
    private func completePhase() {
        switch currentPhase {
        case .inhale:
            if selectedPattern.holdDuration > 0 {
                startPhase(.hold)
            } else {
                startPhase(.exhale)
            }
        case .hold:
            startPhase(.exhale)
        case .exhale:
            if selectedPattern.restDuration > 0 {
                startPhase(.rest)
            } else {
                completeCycle()
            }
        case .rest:
            completeCycle()
        }
    }
    
    private func completeCycle() {
        currentCycle += 1
        onCycleComplete?(currentCycle)
        
        updateProgress()
        
        if currentCycle >= targetCycles {
            completeSession()
        } else {
            startPhase(.inhale)
        }
    }
    
    private func completeSession() {
        stopBreathing()
        onSessionComplete?()
    }
    
    private func updateProgress() {
        guard let startTime = totalStartTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let totalDuration = selectedPattern.estimatedTotalDuration
        progress = min(elapsed / totalDuration, 1.0)
        remainingTime = max(totalDuration - elapsed, 0)
    }
}

// MARK: - Breath Coach Wrapper for UI
@MainActor
class BreathCoachWrapper: ObservableObject {
    @Published var isActive: Bool = false
    @Published var currentCycle: Int = 0
    @Published var targetCycles: Int = 7
    @Published var remainingTime: TimeInterval = 0
    @Published var progress: Double = 0.0
    @Published var selectedPattern: RitualBreathingPattern = .fourSevenEight
    @Published var reduceMotion: Bool = false
    
    private let breathCoach = BreathCoach()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        breathCoach.$isActive
            .assign(to: &$isActive)
        
        breathCoach.$currentCycle
            .assign(to: &$currentCycle)
        
        breathCoach.$targetCycles
            .assign(to: &$targetCycles)
        
        breathCoach.$remainingTime
            .assign(to: &$remainingTime)
        
        breathCoach.$progress
            .assign(to: &$progress)
        
        breathCoach.$selectedPattern
            .assign(to: &$selectedPattern)
        
        breathCoach.$reduceMotion
            .assign(to: &$reduceMotion)
        
        breathCoach.onCycleComplete = { [weak self] cycle in
            self?.currentCycle = cycle
        }
        
        breathCoach.onSessionComplete = { [weak self] in
            self?.isActive = false
        }
    }
    
    func startBreathing(pattern: RitualBreathingPattern? = nil) {
        breathCoach.startBreathing(pattern: pattern)
    }
    
    func pauseBreathing() {
        breathCoach.pauseBreathing()
    }
    
    func resumeBreathing() {
        breathCoach.resumeBreathing()
    }
    
    func stopBreathing() {
        breathCoach.stopBreathing()
    }
    
    func setPattern(_ pattern: RitualBreathingPattern) {
        breathCoach.setPattern(pattern)
    }
    
    func setReduceMotion(_ enabled: Bool) {
        breathCoach.setReduceMotion(enabled)
    }
}