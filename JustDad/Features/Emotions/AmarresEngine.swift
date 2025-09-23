//
//  AmarresEngine.swift
//  JustDad - Motor del Ritual de Corte de Amarres o Brujería
//
//  Motor principal que orquesta el flujo completo del ritual de liberación
//

import Foundation
import SwiftUI
import Combine

// MARK: - Protocolo del Motor de Amarres
protocol AmarresEngineProtocol: ObservableObject {
    var currentState: AmarresRitualState { get }
    var currentSession: AmarresSession? { get }
    var isActive: Bool { get }
    var progress: Double { get }
    var stats: AmarresStats { get }
    var points: AmarresPoints { get }
    var achievements: [AmarresAchievement] { get }
    
    func startRitual(approach: AmarresApproach, intensity: AttachmentIntensity)
    func transitionToNextState()
    func transitionToState(_ state: AmarresRitualState)
    func pauseRitual()
    func resumeRitual()
    func abandonRitual()
    func completeRitual()
    
    func updateSymptoms(_ symptoms: [AmarresSymptom])
    func updateBindings(_ bindings: [String])
    func updateCleansingElements(_ elements: [String])
    func updateVoiceValidation(_ result: AmarresVoiceValidation)
    func updateIntensityAfter(_ intensity: AttachmentIntensity)
    func setProtectionVow(_ vow: ProtectionVow)
    func scheduleProtectionReminder()
    func reset()
}

// MARK: - Motor Principal de Amarres
@MainActor
public class AmarresEngine: AmarresEngineProtocol {
    @Published public var currentState: AmarresRitualState = .idle
    @Published public var currentSession: AmarresSession?
    @Published public var isActive: Bool = false
    @Published public var progress: Double = 0.0
    @Published public var stats: AmarresStats = AmarresStats()
    @Published public var points: AmarresPoints = AmarresPoints()
    @Published public var achievements: [AmarresAchievement] = []
    
    private var sessionStartTime: Date?
    private var protectionReminderTimer: Timer?
    private let contentPack = AmarresContentPack.shared
    private let voiceValidator = AmarresVoiceValidator()
    private let metricsService = AmarresMetricsService.shared
    
    public init() {
        loadUserData()
        setupAchievements()
    }
    
    // MARK: - Control del Ritual
    
    public func startRitual(approach: AmarresApproach, intensity: AttachmentIntensity) {
        guard !isActive else { return }
        
        let session = AmarresSession(
            approach: approach,
            intensityBefore: intensity
        )
        
        currentSession = session
        isActive = true
        sessionStartTime = Date()
        progress = 0.0
        
        // Ir directamente al estado de diagnóstico
        transitionToState(.diagnosis)
        
        print("🔮 Ritual de Amarres iniciado - Enfoque: \(approach.displayName), Intensidad: \(intensity.displayName)")
    }
    
    public func transitionToNextState() {
        guard isActive, let session = currentSession else { return }
        
        let nextState = getNextState()
        transitionToState(nextState)
    }
    
    public func transitionToState(_ state: AmarresRitualState) {
        guard isActive else { return }
        
        currentState = state
        
        if var session = currentSession {
            session.state = state
            currentSession = session
        }
        
        updateProgress()
        
        // Efectos de transición
        if state == .cutting {
            playCuttingEffect()
        } else if state == .protection {
            playProtectionEffect()
        }
        
        print("🔄 Transición de estado: \(state.displayName)")
    }
    
    public func pauseRitual() {
        guard isActive else { return }
        
        isActive = false
        print("⏸️ Ritual pausado")
    }
    
    public func resumeRitual() {
        guard currentSession != nil else { return }
        
        isActive = true
        print("▶️ Ritual reanudado")
    }
    
    public func abandonRitual() {
        guard let session = currentSession else { return }
        
        if var updatedSession = currentSession {
            updatedSession.state = .abandoned
            updatedSession.endTime = Date()
            currentSession = updatedSession
        }
        
        isActive = false
        currentState = .idle
        progress = 0.0
        sessionStartTime = nil
        
        // Guardar sesión abandonada
        metricsService.recordAbandonedSession(session)
        
        print("❌ Ritual abandonado")
    }
    
    public func completeRitual() {
        guard let session = currentSession else { return }
        
        if var updatedSession = currentSession {
            updatedSession.state = .completion
            updatedSession.endTime = Date()
            updatedSession.isCompleted = true
            currentSession = updatedSession
        }
        
        isActive = false
        progress = 1.0
        
        // Calcular puntos y logros
        calculateSessionRewards()
        
        // Guardar estadísticas
        metricsService.recordCompletedSession(currentSession!)
        
        // Programar recordatorio de protección
        scheduleProtectionReminder()
        
        print("✅ Ritual completado exitosamente")
    }
    
    // MARK: - Actualización de Datos
    
    public func updateSymptoms(_ symptoms: [AmarresSymptom]) {
        guard var session = currentSession else { return }
        session.symptoms = symptoms
        currentSession = session
    }
    
    public func updateBindings(_ bindings: [String]) {
        guard var session = currentSession else { return }
        session.identifiedBindings = bindings
        currentSession = session
    }
    
    public func updateCleansingElements(_ elements: [String]) {
        guard var session = currentSession else { return }
        session.cleansingElements = elements
        currentSession = session
    }
    
    public func updateVoiceValidation(_ result: AmarresVoiceValidation) {
        // El validador de voz maneja esto internamente
        voiceValidator.updateValidationResult(result)
    }
    
    public func updateIntensityAfter(_ intensity: AttachmentIntensity) {
        guard var session = currentSession else { return }
        session.intensityAfter = intensity
        currentSession = session
    }
    
    public func setProtectionVow(_ vow: ProtectionVow) {
        guard var session = currentSession else { return }
        session.protectionVow = vow.description
        currentSession = session
    }
    
    public func scheduleProtectionReminder() {
        guard let session = currentSession else { return }
        
        // Cancelar timer anterior si existe
        protectionReminderTimer?.invalidate()
        
        // Programar recordatorio según la duración del voto
        let reminderInterval: TimeInterval = 24 * 60 * 60 // 24 horas por defecto
        
        protectionReminderTimer = Timer.scheduledTimer(withTimeInterval: reminderInterval, repeats: true) { [weak self] _ in
            self?.sendProtectionReminder()
        }
        
        print("⏰ Recordatorio de protección programado")
    }
    
    // MARK: - Métodos de Soporte
    
    private func getNextState() -> AmarresRitualState {
        switch currentState {
        case .idle:
            return .preparation
        case .preparation:
            return .diagnosis
        case .diagnosis:
            return .breathing
        case .breathing:
            return .identification
        case .identification:
            return .cleansing
        case .cleansing:
            return .cutting
        case .cutting:
            return .protection
        case .protection:
            return .sealing
        case .sealing:
            return .completion
        case .completion, .abandoned:
            return .idle
        }
    }
    
    private func updateProgress() {
        let totalStates = 9.0 // Desde diagnosis hasta completion
        let currentStateIndex = getCurrentStateIndex()
        progress = currentStateIndex / totalStates
    }
    
    private func getCurrentStateIndex() -> Double {
        switch currentState {
        case .idle, .preparation: return 0.0
        case .diagnosis: return 1.0
        case .breathing: return 2.0
        case .identification: return 3.0
        case .cleansing: return 4.0
        case .cutting: return 5.0
        case .protection: return 6.0
        case .sealing: return 7.0
        case .completion: return 8.0
        case .abandoned: return 0.0
        }
    }
    
    private func calculateSessionRewards() {
        guard let session = currentSession else { return }
        
        var earnedPoints = 0
        
        // Puntos base por completar sesión
        earnedPoints += 50
        points.addPoints(50, type: .liberation)
        
        // Puntos por intensidad reducida
        if let intensityAfter = session.intensityAfter {
            let intensityReduction = session.intensityBefore.numericValue - intensityAfter.numericValue
            if intensityReduction > 0 {
                let bonusPoints = intensityReduction * 10
                earnedPoints += bonusPoints
                points.addPoints(bonusPoints, type: .liberation)
            }
        }
        
        // Puntos por elementos de limpieza
        let cleansingPoints = session.cleansingElements.count * 5
        earnedPoints += cleansingPoints
        points.addPoints(cleansingPoints, type: .cleansing)
        
        // Puntos por amarres identificados
        let bindingPoints = session.identifiedBindings.count * 15
        earnedPoints += bindingPoints
        points.addPoints(bindingPoints, type: .liberation)
        
        // Puntos por voto de protección
        if !session.protectionVow.isEmpty {
            earnedPoints += 25
            points.addPoints(25, type: .protection)
        }
        
        print("💰 Puntos ganados: \(earnedPoints)")
        
        // Verificar logros
        _ = checkAchievements()
    }
    
    private func checkAchievements() {
        let newAchievements = metricsService.checkAchievements()
        
        for achievement in newAchievements {
            if !achievements.contains(where: { $0.id == achievement.id }) {
                achievements.append(achievement)
                print("🏆 Logro desbloqueado: \(achievement.title)")
            }
        }
    }
    
    private func playCuttingEffect() {
        // Efecto haptic para el corte
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        // Sonido de corte (si está disponible)
        // AudioServicesPlaySystemSound(1104) // Sonido de corte
    }
    
    private func playProtectionEffect() {
        // Efecto haptic para la protección
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        // Sonido de protección (si está disponible)
        // AudioServicesPlaySystemSound(1057) // Sonido de éxito
    }
    
    private func sendProtectionReminder() {
        // Enviar notificación local
        let content = UNMutableNotificationContent()
        content.title = "Recordatorio de Protección"
        content.body = "Es hora de renovar tu protección energética"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "protection_reminder",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error enviando notificación: \(error)")
            }
        }
    }
    
    private func loadUserData() {
        // Cargar estadísticas desde UserDefaults o Core Data
        if let data = UserDefaults.standard.data(forKey: "amarres_stats"),
           let loadedStats = try? JSONDecoder().decode(AmarresStats.self, from: data) {
            stats = loadedStats
        }
        
        if let data = UserDefaults.standard.data(forKey: "amarres_points"),
           let loadedPoints = try? JSONDecoder().decode(AmarresPoints.self, from: data) {
            points = loadedPoints
        }
        
        if let data = UserDefaults.standard.data(forKey: "amarres_achievements"),
           let loadedAchievements = try? JSONDecoder().decode([AmarresAchievement].self, from: data) {
            achievements = loadedAchievements
        }
    }
    
    private func saveUserData() {
        // Guardar datos en UserDefaults
        if let statsData = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(statsData, forKey: "amarres_stats")
        }
        
        if let pointsData = try? JSONEncoder().encode(points) {
            UserDefaults.standard.set(pointsData, forKey: "amarres_points")
        }
        
        if let achievementsData = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(achievementsData, forKey: "amarres_achievements")
        }
    }
    
    private func setupAchievements() {
        if achievements.isEmpty {
            achievements = AmarresAchievementFactory.createDefaultAchievements()
        }
    }
    
    // MARK: - Métodos Públicos de Consulta
    
    public func getCurrentScript() -> AmarresScript? {
        guard let session = currentSession else { return nil }
        
        let scriptIndex = getScriptIndex(for: currentState)
        return contentPack.getScript(at: scriptIndex, approach: session.approach)
    }
    
    public func getSuggestedProtectionVows() -> [ProtectionVow] {
        return [
            ProtectionVow(
                title: "Protección Diaria",
                description: "Renovaré mi protección energética cada día al despertar",
                duration: AmarresVowDuration.daily
            ),
            ProtectionVow(
                title: "Protección Semanal",
                description: "Mantendré mi escudo energético activo durante toda la semana",
                duration: AmarresVowDuration.weekly
            ),
            ProtectionVow(
                title: "Protección Permanente",
                description: "Sellaré mi campo energético con protección permanente",
                duration: AmarresVowDuration.permanent
            )
        ]
    }
    
    public func getCleansingElements() -> [String] {
        return [
            "Sal marina",
            "Palo santo",
            "Salvia blanca",
            "Incienso",
            "Lavanda",
            "Eucalipto",
            "Cuarzo blanco",
            "Turmalina negra",
            "Amatista",
            "Agua bendita"
        ]
    }
    
    public func getAllAchievements() -> [AmarresAchievement] {
        return achievements
    }
    
    public func getUnlockedAchievements() -> [AmarresAchievement] {
        return achievements.filter { $0.isUnlocked }
    }
    
    private func getScriptIndex(for state: AmarresRitualState) -> Int {
        switch state {
        case .diagnosis: return 0
        case .breathing: return 1
        case .identification: return 2
        case .cleansing: return 3
        case .cutting: return 4
        case .protection: return 5
        case .sealing: return 6
        default: return 0
        }
    }
    
    // MARK: - Método de Reset
    
    public func reset() {
        currentState = .idle
        currentSession = nil
        isActive = false
        progress = 0.0
        sessionStartTime = nil
    }
}

// MARK: - Factory de Logros
public class AmarresAchievementFactory {
    public static func createDefaultAchievements() -> [AmarresAchievement] {
        return [
            AmarresAchievement(
                title: "Primer Paso",
                description: "Completa tu primera sesión de liberación",
                icon: "star.fill",
                color: "gold",
                requirement: .sessionsCompleted(1),
                reward: AchievementReward(points: 50, pointsType: .liberation, title: "Primer Paso", description: "¡Bienvenido al camino de la liberación!")
            ),
            AmarresAchievement(
                title: "Rompe-Amarras",
                description: "Rompe 10 amarres exitosamente",
                icon: "scissors",
                color: "purple",
                requirement: .bindingsBroken(10),
                reward: AchievementReward(points: 100, pointsType: .liberation, title: "Rompe-Amarras", description: "¡Eres un experto en romper vínculos tóxicos!")
            ),
            AmarresAchievement(
                title: "Guardián Energético",
                description: "Mantén protección activa por 30 días",
                icon: "shield.fill",
                color: "blue",
                requirement: .protectionDays(30),
                reward: AchievementReward(points: 200, pointsType: .protection, title: "Guardián Energético", description: "¡Tu campo energético está bien protegido!")
            ),
            AmarresAchievement(
                title: "Maestro de la Luz",
                description: "Alcanza el nivel Maestro",
                icon: "crown.fill",
                color: "yellow",
                requirement: .levelReached(.master),
                reward: AchievementReward(points: 500, pointsType: .mastery, title: "Maestro de la Luz", description: "¡Has alcanzado la maestría en liberación energética!")
            )
        ]
    }
}
