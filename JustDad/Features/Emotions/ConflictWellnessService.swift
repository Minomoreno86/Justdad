//
//  ConflictWellnessService.swift
//  JustDad - Conflict Wellness Service
//
//  Service for managing conflict wellness and coparenting tools
//

import Foundation

class ConflictWellnessService: ObservableObject {
    static let shared = ConflictWellnessService()
    
    @Published var stats = ConflictWellnessStats()
    @Published var journalEntries: [WellnessJournalEntry] = []
    @Published var achievements: [ConflictAchievementBadge] = []
    @Published var sessions: [ConflictWellnessSession] = []
    @Published var trainingResults: [CommunicationTrainingResult] = []
    @Published var currentAffirmation: DailyAffirmation?
    
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - Initialization
    private init() {
        loadData()
        initializeAchievements()
        generateDailyAffirmation()
    }
    
    // MARK: - Data Management
    private func loadData() {
        loadStats()
        loadJournalEntries()
        loadAchievements()
        loadSessions()
        loadTrainingResults()
    }
    
    private func saveData() {
        saveStats()
        saveJournalEntries()
        saveAchievements()
        saveSessions()
        saveTrainingResults()
    }
    
    // MARK: - Stats Management
    private func loadStats() {
        if let data = userDefaults.data(forKey: "ConflictWellnessStats"),
           let loadedStats = try? decoder.decode(ConflictWellnessStats.self, from: data) {
            stats = loadedStats
        }
    }
    
    private func saveStats() {
        if let data = try? encoder.encode(stats) {
            userDefaults.set(data, forKey: "ConflictWellnessStats")
        }
    }
    
    // MARK: - Journal Management
    func addJournalEntry(_ entry: WellnessJournalEntry) {
        journalEntries.append(entry)
        stats.journalEntries += 1
        saveJournalEntries()
        saveStats()
        checkAchievements()
    }
    
    private func loadJournalEntries() {
        if let data = userDefaults.data(forKey: "ConflictWellnessJournalEntries"),
           let loadedEntries = try? decoder.decode([WellnessJournalEntry].self, from: data) {
            journalEntries = loadedEntries
        }
    }
    
    private func saveJournalEntries() {
        if let data = try? encoder.encode(journalEntries) {
            userDefaults.set(data, forKey: "ConflictWellnessJournalEntries")
        }
    }
    
    // MARK: - Communication Training
    func addTrainingResult(_ result: CommunicationTrainingResult) {
        trainingResults.append(result)
        stats.totalResponses += 1
        
        if result.isSerena {
            stats.serenaResponses += 1
            stats.totalPoints += result.score
        }
        
        saveTrainingResults()
        saveStats()
        checkAchievements()
    }
    
    private func loadTrainingResults() {
        if let data = userDefaults.data(forKey: "ConflictWellnessTrainingResults"),
           let loadedResults = try? decoder.decode([CommunicationTrainingResult].self, from: data) {
            trainingResults = loadedResults
        }
    }
    
    private func saveTrainingResults() {
        if let data = try? encoder.encode(trainingResults) {
            userDefaults.set(data, forKey: "ConflictWellnessTrainingResults")
        }
    }
    
    // MARK: - Child Validation
    func recordChildValidation() {
        stats.childValidations += 1
        stats.totalPoints += 10
        saveStats()
        checkAchievements()
    }
    
    // MARK: - Self Care Tracking
    func recordSelfCareDay() {
        stats.selfCareDays += 1
        stats.currentStreak += 1
        stats.totalPoints += 5
        saveStats()
        checkAchievements()
    }
    
    // MARK: - Session Management
    func addSession(_ session: ConflictWellnessSession) {
        sessions.append(session)
        saveSessions()
    }
    
    private func loadSessions() {
        if let data = userDefaults.data(forKey: "ConflictWellnessSessions"),
           let loadedSessions = try? decoder.decode([ConflictWellnessSession].self, from: data) {
            sessions = loadedSessions
        }
    }
    
    private func saveSessions() {
        if let data = try? encoder.encode(sessions) {
            userDefaults.set(data, forKey: "ConflictWellnessSessions")
        }
    }
    
    // MARK: - Achievement System
    private func initializeAchievements() {
        achievements = [
            ConflictAchievementBadge(
                name: "Maestro de Comunicación",
                description: "20 respuestas serenas entrenadas",
                criteria: "20 respuestas entrenadas",
                icon: "message.fill",
                color: "blue"
            ),
            ConflictAchievementBadge(
                name: "Muro de Acero",
                description: "50 respuestas serenas sin engancharse",
                criteria: "50 respuestas serenas",
                icon: "shield.fill",
                color: "gray"
            ),
            ConflictAchievementBadge(
                name: "Bitácora Constante",
                description: "10 registros escritos",
                criteria: "10 registros en bitácora",
                icon: "book.fill",
                color: "orange"
            ),
            ConflictAchievementBadge(
                name: "Protector de Bienestar Familiar",
                description: "7 validaciones con hijos",
                criteria: "7 validaciones con hijos",
                icon: "person.2.fill",
                color: "green"
            ),
            ConflictAchievementBadge(
                name: "Padre Resiliente",
                description: "21 días de autocuidado",
                criteria: "21 días de autocuidado",
                icon: "heart.fill",
                color: "purple"
            )
        ]
        loadAchievements()
    }
    
    private func loadAchievements() {
        if let data = userDefaults.data(forKey: "ConflictWellnessAchievements"),
           let loadedAchievements = try? decoder.decode([ConflictAchievementBadge].self, from: data) {
            achievements = loadedAchievements
        }
    }
    
    private func saveAchievements() {
        if let data = try? encoder.encode(achievements) {
            userDefaults.set(data, forKey: "ConflictWellnessAchievements")
        }
    }
    
    private func checkAchievements() {
        var hasNewAchievement = false
        
        // Maestro de Comunicación
        if let achievement = achievements.first(where: { $0.name == "Maestro de Comunicación" }),
           !achievement.isUnlocked && trainingResults.count >= 20 {
            unlockAchievement("Maestro de Comunicación")
            hasNewAchievement = true
        }
        
        // Muro de Acero
        if let achievement = achievements.first(where: { $0.name == "Muro de Acero" }),
           !achievement.isUnlocked && stats.serenaResponses >= 50 {
            unlockAchievement("Muro de Acero")
            hasNewAchievement = true
        }
        
        // Bitácora Constante
        if let achievement = achievements.first(where: { $0.name == "Bitácora Constante" }),
           !achievement.isUnlocked && stats.journalEntries >= 10 {
            unlockAchievement("Bitácora Constante")
            hasNewAchievement = true
        }
        
        // Protector de Bienestar Familiar
        if let achievement = achievements.first(where: { $0.name == "Protector de Bienestar Familiar" }),
           !achievement.isUnlocked && stats.childValidations >= 7 {
            unlockAchievement("Protector de Bienestar Familiar")
            hasNewAchievement = true
        }
        
        // Padre Resiliente
        if let achievement = achievements.first(where: { $0.name == "Padre Resiliente" }),
           !achievement.isUnlocked && stats.selfCareDays >= 21 {
            unlockAchievement("Padre Resiliente")
            hasNewAchievement = true
        }
        
        if hasNewAchievement {
            saveAchievements()
        }
    }
    
    private func unlockAchievement(_ name: String) {
        if let index = achievements.firstIndex(where: { $0.name == name }) {
            achievements[index] = ConflictAchievementBadge(
                name: achievements[index].name,
                description: achievements[index].description,
                criteria: achievements[index].criteria,
                icon: achievements[index].icon,
                color: achievements[index].color,
                isUnlocked: true,
                unlockedDate: Date()
            )
        }
    }
    
    // MARK: - Daily Affirmation
    private func generateDailyAffirmation() {
        let affirmations = [
            DailyAffirmation(text: "Hoy elijo responder con calma. Mi serenidad es mi mejor protección y la de mis hijos.", category: "Serenidad", isUsed: false),
            DailyAffirmation(text: "Soy un padre presente y confiable. Mis acciones reflejan mi amor por mis hijos.", category: "Presencia", isUsed: false),
            DailyAffirmation(text: "Mi calma protege a mis hijos. Elijo respuestas breves, claras, amables y firmes.", category: "Protección", isUsed: false),
            DailyAffirmation(text: "Pongo mi atención en lo que sí puedo construir hoy. Cada día es una oportunidad.", category: "Construcción", isUsed: false),
            DailyAffirmation(text: "Soy fuerte en mi vulnerabilidad. Mi fortaleza viene de mi capacidad de amar.", category: "Fortaleza", isUsed: false),
            DailyAffirmation(text: "Mis hijos son mi prioridad. Cada decisión la tomo pensando en su bienestar.", category: "Prioridad", isUsed: false),
            DailyAffirmation(text: "Elijo la paz sobre el conflicto. Mi serenidad es contagiosa.", category: "Paz", isUsed: false),
            DailyAffirmation(text: "Soy digno de amor y respeto. Mis hijos merecen ver lo mejor de mí.", category: "Dignidad", isUsed: false)
        ]
        
        currentAffirmation = affirmations.randomElement()
    }
    
    // MARK: - Export Functions
    func exportJournalEntries() -> String? {
        let exportData = journalEntries.map { entry in
            [
                "fecha": DateFormatter.iso8601.string(from: entry.date),
                "tipo": entry.type.rawValue,
                "descripcion": entry.description,
                "emocion": String(entry.emotion),
                "accion_proxima": entry.actionProxima
            ]
        }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return nil
    }
    
    // MARK: - Reset Functions
    func resetAllData() {
        stats = ConflictWellnessStats()
        journalEntries.removeAll()
        trainingResults.removeAll()
        sessions.removeAll()
        achievements.removeAll()
        initializeAchievements()
        
        // Clear UserDefaults
        userDefaults.removeObject(forKey: "ConflictWellnessStats")
        userDefaults.removeObject(forKey: "ConflictWellnessJournalEntries")
        userDefaults.removeObject(forKey: "ConflictWellnessTrainingResults")
        userDefaults.removeObject(forKey: "ConflictWellnessSessions")
        userDefaults.removeObject(forKey: "ConflictWellnessAchievements")
    }
}

// MARK: - Extensions
extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
}
