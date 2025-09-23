import Foundation
import SwiftUI

// MARK: - Gamification Models

struct MetricsAchievement: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: String
    let requirement: AchievementRequirement
    let reward: AchievementReward
    var isUnlocked: Bool = false
    var unlockedDate: Date?
    
    enum AchievementRequirement: Codable {
        case ritualsCompleted(count: Int)
        case streakDays(count: Int)
        case totalTime(minutes: Int)
        case emotionalProgress(improvement: Double)
        case vowCompletion(percentage: Double)
        case specificPattern(pattern: String)
    }
    
    struct AchievementReward: Codable {
        let points: Int
        let title: String
        let message: String
    }
}

struct RitualStreak: Codable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastRitualDate: Date?
    var streakStartDate: Date?
}

struct RitualStats: Codable {
    var totalRitualsCompleted: Int = 0
    var totalTimeSpent: TimeInterval = 0
    var averageEmotionalImprovement: Double = 0.0
    var vowCompletionRate: Double = 0.0
    var favoriteFocus: RitualFocus = .exPartner
    var mostUsedBreathingPattern: String = "4-7-8"
    var completionRate: Double = 0.0
}

struct RitualPoints: Codable {
    var totalPoints: Int = 0
    var pointsThisWeek: Int = 0
    var pointsThisMonth: Int = 0
    var level: Int = 1
    var experienceToNextLevel: Int = 100
    var totalExperience: Int = 0
}

// MARK: - Ritual Metrics Service

@MainActor
class RitualMetricsService: ObservableObject {
    @Published var stats: RitualStats = RitualStats()
    @Published var streak: RitualStreak = RitualStreak()
    @Published var points: RitualPoints = RitualPoints()
    @Published var achievements: [MetricsAchievement] = []
    @Published var weeklyProgress: [Date: Int] = [:]
    @Published var monthlyProgress: [Date: Int] = [:]
    
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - Initialization
    
    init() {
        loadData()
        setupDefaultAchievements()
        updateAchievements()
    }
    
    // MARK: - Data Persistence
    
    private func saveData() {
        if let statsData = try? encoder.encode(stats) {
            userDefaults.set(statsData, forKey: "ritual_stats")
        }
        if let streakData = try? encoder.encode(streak) {
            userDefaults.set(streakData, forKey: "ritual_streak")
        }
        if let pointsData = try? encoder.encode(points) {
            userDefaults.set(pointsData, forKey: "ritual_points")
        }
        if let achievementsData = try? encoder.encode(achievements) {
            userDefaults.set(achievementsData, forKey: "ritual_achievements")
        }
        if let weeklyData = try? encoder.encode(weeklyProgress) {
            userDefaults.set(weeklyData, forKey: "ritual_weekly_progress")
        }
        if let monthlyData = try? encoder.encode(monthlyProgress) {
            userDefaults.set(monthlyData, forKey: "ritual_monthly_progress")
        }
    }
    
    private func loadData() {
        if let statsData = userDefaults.data(forKey: "ritual_stats"),
           let loadedStats = try? decoder.decode(RitualStats.self, from: statsData) {
            stats = loadedStats
        }
        
        if let streakData = userDefaults.data(forKey: "ritual_streak"),
           let loadedStreak = try? decoder.decode(RitualStreak.self, from: streakData) {
            streak = loadedStreak
        }
        
        if let pointsData = userDefaults.data(forKey: "ritual_points"),
           let loadedPoints = try? decoder.decode(RitualPoints.self, from: pointsData) {
            points = loadedPoints
        }
        
        if let achievementsData = userDefaults.data(forKey: "ritual_achievements"),
           let loadedAchievements = try? decoder.decode([MetricsAchievement].self, from: achievementsData) {
            achievements = loadedAchievements
        }
        
        if let weeklyData = userDefaults.data(forKey: "ritual_weekly_progress"),
           let loadedWeekly = try? decoder.decode([Date: Int].self, from: weeklyData) {
            weeklyProgress = loadedWeekly
        }
        
        if let monthlyData = userDefaults.data(forKey: "ritual_monthly_progress"),
           let loadedMonthly = try? decoder.decode([Date: Int].self, from: monthlyData) {
            monthlyProgress = loadedMonthly
        }
    }
    
    // MARK: - Ritual Completion
    
    func recordRitualCompletion(_ session: RitualSession) {
        let now = Date()
        
        // Update stats
        stats.totalRitualsCompleted += 1
        stats.totalTimeSpent += session.duration
        
        // Update emotional improvement
        if let afterEmotional = session.emotionalStateAfter {
            let beforeEmotional = session.emotionalStateBefore
            let improvement = Double(afterEmotional.rawValue - beforeEmotional.rawValue)
            let currentTotal = stats.averageEmotionalImprovement * Double(stats.totalRitualsCompleted - 1)
            stats.averageEmotionalImprovement = (currentTotal + improvement) / Double(stats.totalRitualsCompleted)
        }
        
        // Update vow completion rate
        if let vow = session.behavioralVow {
            // Simulate vow completion rate (in real app, this would be tracked over time)
            let completionRate = Double.random(in: 0.6...1.0)
            stats.vowCompletionRate = (stats.vowCompletionRate * Double(stats.totalRitualsCompleted - 1) + completionRate) / Double(stats.totalRitualsCompleted)
        }
        
        // Update favorite focus
        stats.favoriteFocus = session.focus
        
        // Update breathing pattern usage
        stats.mostUsedBreathingPattern = "4-7-8" // Default, could be tracked from session
        
        // Update completion rate
        stats.completionRate = 1.0 // Ritual was completed
        
        // Update streak
        updateStreak(completionDate: now)
        
        // Award points
        awardPoints(for: session)
        
        // Update progress tracking
        updateProgressTracking(date: now)
        
        // Check achievements
        updateAchievements()
        
        saveData()
    }
    
    // MARK: - Streak Management
    
    private func updateStreak(completionDate: Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: completionDate)
        
        if let lastDate = streak.lastRitualDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysDifference = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysDifference == 1 {
                // Consecutive day
                streak.currentStreak += 1
            } else if daysDifference == 0 {
                // Same day, no change to streak
            } else {
                // Streak broken
                streak.currentStreak = 1
                streak.streakStartDate = today
            }
        } else {
            // First ritual
            streak.currentStreak = 1
            streak.streakStartDate = today
        }
        
        streak.lastRitualDate = today
        streak.longestStreak = max(streak.longestStreak, streak.currentStreak)
    }
    
    // MARK: - Points System
    
    private func awardPoints(for session: RitualSession) {
        var pointsEarned = 0
        
        // Base points for completion
        pointsEarned += 50
        
        // Bonus points for completion time
        let durationMinutes = session.duration / 60
        if durationMinutes >= 10 {
            pointsEarned += 25 // Bonus for longer sessions
        }
        
        // Bonus points for emotional improvement
        if let after = session.emotionalStateAfter {
            let before = session.emotionalStateBefore
            if after.rawValue > before.rawValue {
                pointsEarned += 30
            }
        }
        
        // Bonus points for voice validation success
        if session.voiceValidationSuccess {
            pointsEarned += 20
        }
        
        // Bonus points for streak
        if streak.currentStreak > 1 {
            pointsEarned += min(streak.currentStreak * 5, 50) // Max 50 bonus points for streak
        }
        
        // Update points
        points.totalPoints += pointsEarned
        points.totalExperience += pointsEarned
        
        // Update weekly and monthly points
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let monthStart = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
        
        points.pointsThisWeek = weeklyProgress[weekStart] ?? 0
        points.pointsThisWeek += pointsEarned
        
        points.pointsThisMonth = monthlyProgress[monthStart] ?? 0
        points.pointsThisMonth += pointsEarned
        
        // Update level
        updateLevel()
    }
    
    private func updateLevel() {
        let experiencePerLevel = 100
        let newLevel = (points.totalExperience / experiencePerLevel) + 1
        points.level = newLevel
        points.experienceToNextLevel = (newLevel * experiencePerLevel) - points.totalExperience
    }
    
    // MARK: - Progress Tracking
    
    private func updateProgressTracking(date: Date) {
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        let monthStart = calendar.dateInterval(of: .month, for: date)?.start ?? date
        
        weeklyProgress[weekStart] = (weeklyProgress[weekStart] ?? 0) + 1
        monthlyProgress[monthStart] = (monthlyProgress[monthStart] ?? 0) + 1
    }
    
    // MARK: - Achievements System
    
    private func setupDefaultAchievements() {
        if achievements.isEmpty {
            achievements = [
                MetricsAchievement(
                    title: "Primer Ritual",
                    description: "Completa tu primer ritual de liberación",
                    icon: "star.fill",
                    color: "gold",
                    requirement: .ritualsCompleted(count: 1),
                    reward: MetricsAchievement.AchievementReward(points: 100, title: "¡Bienvenido!", message: "Has dado el primer paso hacia la liberación")
                ),
                MetricsAchievement(
                    title: "Liberador Consistente",
                    description: "Completa 7 rituales",
                    icon: "flame.fill",
                    color: "orange",
                    requirement: .ritualsCompleted(count: 7),
                    reward: MetricsAchievement.AchievementReward(points: 200, title: "¡Consistencia!", message: "La constancia es la clave de la transformación")
                ),
                MetricsAchievement(
                    title: "Maestro de la Liberación",
                    description: "Completa 30 rituales",
                    icon: "crown.fill",
                    color: "purple",
                    requirement: .ritualsCompleted(count: 30),
                    reward: MetricsAchievement.AchievementReward(points: 500, title: "¡Maestría!", message: "Has dominado el arte de la liberación")
                ),
                MetricsAchievement(
                    title: "Racha de 3 Días",
                    description: "Completa rituales 3 días consecutivos",
                    icon: "calendar.badge.checkmark",
                    color: "blue",
                    requirement: .streakDays(count: 3),
                    reward: MetricsAchievement.AchievementReward(points: 150, title: "¡Racha!", message: "La consistencia diaria transforma")
                ),
                MetricsAchievement(
                    title: "Racha de 7 Días",
                    description: "Completa rituales 7 días consecutivos",
                    icon: "calendar.badge.plus",
                    color: "green",
                    requirement: .streakDays(count: 7),
                    reward: MetricsAchievement.AchievementReward(points: 300, title: "¡Semana Perfecta!", message: "Una semana de transformación continua")
                ),
                MetricsAchievement(
                    title: "Transformación Emocional",
                    description: "Mejora tu estado emocional en 5 rituales",
                    icon: "heart.fill",
                    color: "pink",
                    requirement: .emotionalProgress(improvement: 5.0),
                    reward: MetricsAchievement.AchievementReward(points: 250, title: "¡Transformación!", message: "Tu crecimiento emocional es evidente")
                ),
                MetricsAchievement(
                    title: "Voto Cumplido",
                    description: "Cumple con el 80% de tus votos conductuales",
                    icon: "checkmark.seal.fill",
                    color: "green",
                    requirement: .vowCompletion(percentage: 0.8),
                    reward: MetricsAchievement.AchievementReward(points: 400, title: "¡Compromiso!", message: "Tu palabra tiene poder")
                ),
                MetricsAchievement(
                    title: "Tiempo de Calidad",
                    description: "Acumula 300 minutos de rituales",
                    icon: "clock.fill",
                    color: "indigo",
                    requirement: .totalTime(minutes: 300),
                    reward: MetricsAchievement.AchievementReward(points: 350, title: "¡Dedicación!", message: "El tiempo invertido en ti mismo es valioso")
                )
            ]
        }
    }
    
    private func updateAchievements() {
        for i in 0..<achievements.count {
            if !achievements[i].isUnlocked {
                if checkAchievementRequirement(achievements[i].requirement) {
                    achievements[i].isUnlocked = true
                    achievements[i].unlockedDate = Date()
                    awardAchievementPoints(achievements[i].reward)
                }
            }
        }
    }
    
    private func checkAchievementRequirement(_ requirement: MetricsAchievement.AchievementRequirement) -> Bool {
        switch requirement {
        case .ritualsCompleted(let count):
            return stats.totalRitualsCompleted >= count
        case .streakDays(let count):
            return streak.currentStreak >= count
        case .totalTime(let minutes):
            return Int(stats.totalTimeSpent / 60) >= minutes
        case .emotionalProgress(let improvement):
            return stats.averageEmotionalImprovement >= improvement
        case .vowCompletion(let percentage):
            return stats.vowCompletionRate >= percentage
        case .specificPattern(let pattern):
            return stats.mostUsedBreathingPattern == pattern
        }
    }
    
    private func awardAchievementPoints(_ reward: MetricsAchievement.AchievementReward) {
        points.totalPoints += reward.points
        points.totalExperience += reward.points
        updateLevel()
    }
    
    // MARK: - Public Methods
    
    func getUnlockedAchievements() -> [MetricsAchievement] {
        return achievements.filter { $0.isUnlocked }
    }
    
    func getRecentAchievements() -> [MetricsAchievement] {
        let recentDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return achievements.filter { achievement in
            guard let unlockedDate = achievement.unlockedDate else { return false }
            return achievement.isUnlocked && unlockedDate >= recentDate
        }
    }
    
    func getWeeklyStats() -> [String: Int] {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        var weeklyStats: [String: Int] = [:]
        for i in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: i, to: weekStart) {
                let dayKey = DateFormatter.dayFormatter.string(from: day)
                weeklyStats[dayKey] = weeklyProgress[day] ?? 0
            }
        }
        
        return weeklyStats
    }
    
    func getMonthlyStats() -> [String: Int] {
        let calendar = Calendar.current
        let today = Date()
        let monthStart = calendar.dateInterval(of: .month, for: today)?.start ?? today
        
        var monthlyStats: [String: Int] = [:]
        let daysInMonth = calendar.range(of: .day, in: .month, for: today)?.count ?? 30
        
        for i in 0..<daysInMonth {
            if let day = calendar.date(byAdding: .day, value: i, to: monthStart) {
                let dayKey = "\(i + 1)"
                monthlyStats[dayKey] = monthlyProgress[day] ?? 0
            }
        }
        
        return monthlyStats
    }
    
    func resetData() {
        stats = RitualStats()
        streak = RitualStreak()
        points = RitualPoints()
        weeklyProgress = [:]
        monthlyProgress = [:]
        
        for i in 0..<achievements.count {
            achievements[i].isUnlocked = false
            achievements[i].unlockedDate = nil
        }
        
        saveData()
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()
}

extension MetricsAchievement.AchievementRequirement {
    var displayText: String {
        switch self {
        case .ritualsCompleted(let count):
            return "Completa \(count) rituales"
        case .streakDays(let count):
            return "\(count) días consecutivos"
        case .totalTime(let minutes):
            return "\(minutes) minutos totales"
        case .emotionalProgress(let improvement):
            return "Mejora emocional de \(improvement)"
        case .vowCompletion(let percentage):
            return "\(Int(percentage * 100))% cumplimiento de votos"
        case .specificPattern(let pattern):
            return "Usar patrón \(pattern)"
        }
    }
}
