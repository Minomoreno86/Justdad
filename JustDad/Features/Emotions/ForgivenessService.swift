//
//  ForgivenessService.swift
//  JustDad - Forgiveness Therapy Service
//
//  Servicio para la Terapia del Perdón Pránica de 21 días
//

import Foundation
import SwiftUI
import AVFoundation

public class ForgivenessService: ObservableObject {
    static let shared = ForgivenessService()
    
    @Published var currentSessions: [ForgivenessSession] = []
    @Published var currentProgress: [ForgivenessProgress] = []
    @Published var currentDay: Int = 1
    @Published var currentPhase: ForgivenessPhase = .selfForgiveness
    @Published var settings: ForgivenessSettings = ForgivenessSettings()
    
    private var audioPlayer: AVAudioPlayer?
    private var binauralPlayer: AVAudioPlayer?
    
    private init() {
        loadSessions()
        loadProgress()
        updateCurrentDay()
    }
    
    // MARK: - Session Management
    
    func startNewSession(day: Int, phase: ForgivenessPhase, emotionalState: String, peaceLevel: Int) -> ForgivenessSession {
        let letter = getLetterForDay(day, phase: phase)
        let session = ForgivenessSession(
            phase: phase,
            day: day,
            emotionalStateBefore: emotionalState,
            peaceLevelBefore: peaceLevel,
            letterContent: letter.content,
            affirmation: letter.affirmation
        )
        
        currentSessions.append(session)
        saveSessions()
        return session
    }
    
    func completeSession(_ session: ForgivenessSession, emotionalStateAfter: String, peaceLevelAfter: Int, notes: String? = nil, audioURL: String? = nil) {
        session.isCompleted = true
        session.emotionalStateAfter = emotionalStateAfter
        session.peaceLevelAfter = peaceLevelAfter
        session.notes = notes
        session.audioRecordingURL = audioURL
        session.duration = Date().timeIntervalSince(session.date)
        
        updateProgress(for: session)
        saveSessions()
        saveProgress()
    }
    
    // MARK: - Letter Management
    
    func getLetterForDay(_ day: Int, phase: ForgivenessPhase) -> ForgivenessLetter {
        return ForgivenessLetters.allLetters.first { $0.day == day && $0.phase == phase } ?? ForgivenessLetters.defaultLetter
    }
    
    func getCurrentLetter() -> ForgivenessLetter {
        return getLetterForDay(currentDay, phase: currentPhase)
    }
    
    // MARK: - Progress Management
    
    private func updateProgress(for session: ForgivenessSession) {
        let peaceImprovement = session.peaceLevelAfter - session.peaceLevelBefore
        
        if let existingProgress = currentProgress.first(where: { $0.phase == session.phase }) {
            // Update existing progress
            let newCompletedDays = existingProgress.completedDays + 1
            let newImprovement = existingProgress.peaceLevelImprovement + peaceImprovement
            
            if let index = currentProgress.firstIndex(where: { $0.phase == session.phase }) {
                currentProgress[index] = ForgivenessProgress(
                    id: existingProgress.id,
                    phase: session.phase,
                    completedDays: newCompletedDays,
                    totalDays: existingProgress.totalDays,
                    peaceLevelImprovement: newImprovement,
                    lastSessionDate: Date()
                )
            }
        } else {
            // Create new progress
            let totalDays = session.phase.endDay - session.phase.startDay + 1
            let newProgress = ForgivenessProgress(
                id: UUID(),
                phase: session.phase,
                completedDays: 1,
                totalDays: totalDays,
                peaceLevelImprovement: peaceImprovement,
                lastSessionDate: Date()
            )
            currentProgress.append(newProgress)
        }
    }
    
    func getStatistics() -> ForgivenessStatistics {
        let completedSessions = currentSessions.filter { $0.isCompleted }
        let totalSessions = currentSessions.count
        let averageImprovement = completedSessions.isEmpty ? 0.0 : 
            Double(completedSessions.reduce(0) { $0 + ($1.peaceLevelAfter - $1.peaceLevelBefore) }) / Double(completedSessions.count)
        
        let currentStreak = calculateCurrentStreak()
        let longestStreak = calculateLongestStreak()
        
        return ForgivenessStatistics(
            totalSessions: totalSessions,
            completedSessions: completedSessions.count,
            averagePeaceLevelImprovement: averageImprovement,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            phaseProgress: currentProgress
        )
    }
    
    private func calculateCurrentStreak() -> Int {
        let sortedSessions = currentSessions.filter { $0.isCompleted }.sorted { $0.date > $1.date }
        var streak = 0
        
        for session in sortedSessions {
            let daysSinceSession = Calendar.current.dateComponents([.day], from: session.date, to: Date()).day ?? 0
            if daysSinceSession == streak {
                streak += 1
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func calculateLongestStreak() -> Int {
        let sortedSessions = currentSessions.filter { $0.isCompleted }.sorted { $0.date < $1.date }
        var maxStreak = 0
        var currentStreak = 0
        var lastDate: Date?
        
        for session in sortedSessions {
            if let last = lastDate {
                let daysBetween = Calendar.current.dateComponents([.day], from: last, to: session.date).day ?? 0
                if daysBetween == 1 {
                    currentStreak += 1
                } else {
                    maxStreak = max(maxStreak, currentStreak)
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            lastDate = session.date
        }
        
        return max(maxStreak, currentStreak)
    }
    
    // MARK: - Audio Management
    
    func playBinauralAudio() {
        guard settings.enableBinauralAudio else { return }
        
        // TODO: Implement binaural audio at 528Hz
        // For now, we'll use a simple audio file
        if let url = Bundle.main.url(forResource: "binaural_528hz", withExtension: "mp3") {
            do {
                binauralPlayer = try AVAudioPlayer(contentsOf: url)
                binauralPlayer?.numberOfLoops = -1 // Loop indefinitely
                binauralPlayer?.play()
            } catch {
                print("Error playing binaural audio: \(error)")
            }
        }
    }
    
    func stopBinauralAudio() {
        binauralPlayer?.stop()
        binauralPlayer = nil
    }
    
    // MARK: - Haptic Feedback
    
    func triggerHapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard settings.enableHapticFeedback else { return }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
    }
    
    func triggerHapticBreathing() {
        guard settings.enableHapticFeedback else { return }
        
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }
    
    // MARK: - Data Persistence
    
    private func saveSessions() {
        // TODO: Implement SwiftData persistence
        // For now, we'll skip UserDefaults since ForgivenessSession is @Model
        // UserDefaults.standard.set(data, forKey: "ForgivenessSessions")
    }
    
    private func loadSessions() {
        // TODO: Implement SwiftData loading
        // For now, we'll skip UserDefaults since ForgivenessSession is @Model
        // Load sessions will be handled by SwiftData
    }
    
    private func saveProgress() {
        if let data = try? JSONEncoder().encode(currentProgress) {
            UserDefaults.standard.set(data, forKey: "ForgivenessProgress")
        }
    }
    
    private func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: "ForgivenessProgress"),
           let progress = try? JSONDecoder().decode([ForgivenessProgress].self, from: data) {
            currentProgress = progress
        }
    }
    
    // MARK: - Day Management
    
    private func updateCurrentDay() {
        // Find the next incomplete day
        let completedDays = Set(currentSessions.filter { $0.isCompleted }.map { $0.day })
        
        for day in 1...21 {
            if !completedDays.contains(day) {
                currentDay = day
                currentPhase = getPhaseForDay(day)
                return
            }
        }
        
        // All days completed
        currentDay = 21
        currentPhase = .futureForgiveness
    }
    
    private func getPhaseForDay(_ day: Int) -> ForgivenessPhase {
        switch day {
        case 1...7:
            return .selfForgiveness
        case 8...14:
            return .partnerForgiveness
        case 15...18:
            return .childrenForgiveness
        case 19...21:
            return .futureForgiveness
        default:
            return .selfForgiveness
        }
    }
    
    func canStartSession() -> Bool {
        let completedSessions = currentSessions.filter { $0.isCompleted }
        return completedSessions.count < 21
    }
    
    func getNextAvailableDay() -> Int {
        let completedDays = Set(currentSessions.filter { $0.isCompleted }.map { $0.day })
        
        for day in 1...21 {
            if !completedDays.contains(day) {
                return day
            }
        }
        
        return 21 // All completed
    }
}
