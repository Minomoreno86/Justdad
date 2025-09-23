//
//  HabitsWeeklyReflectionService.swift
//  JustDad - Weekly Reflection System
//
//  Automated weekly reflection system for habit tracking
//

import Foundation
import SwiftUI

// MARK: - Weekly Reflection Model
struct WeeklyReflection: Identifiable, Codable {
    let id: UUID
    let weekStartDate: Date
    let weekEndDate: Date
    let completedHabits: [UUID] // Habit IDs
    let missedHabits: [UUID] // Habit IDs
    let insights: [ReflectionInsight]
    let goals: [WeeklyGoal]
    let challenges: [String]
    let wins: [String]
    let isCompleted: Bool
    let completedAt: Date?
    
    init(weekStartDate: Date) {
        self.id = UUID()
        self.weekStartDate = weekStartDate
        self.weekEndDate = Calendar.current.date(byAdding: .day, value: 6, to: weekStartDate) ?? weekStartDate
        self.completedHabits = []
        self.missedHabits = []
        self.insights = []
        self.goals = []
        self.challenges = []
        self.wins = []
        self.isCompleted = false
        self.completedAt = nil
    }
    
    var weekNumber: Int {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: weekStartDate)
        let weekOfYear = calendar.component(.weekOfYear, from: weekStartDate)
        return weekOfYear
    }
    
    var completionRate: Double {
        let total = completedHabits.count + missedHabits.count
        guard total > 0 else { return 0.0 }
        return Double(completedHabits.count) / Double(total)
    }
    
    var weekRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let startString = formatter.string(from: weekStartDate)
        let endString = formatter.string(from: weekEndDate)
        
        return "\(startString) - \(endString)"
    }
}

// MARK: - Reflection Insight
struct ReflectionInsight: Identifiable, Codable {
    let id: UUID
    let type: InsightType
    let title: String
    let description: String
    let priority: InsightPriority
    let actionItems: [String]
    let isAddressed: Bool
    
    init(type: InsightType, title: String, description: String, priority: InsightPriority = .medium, actionItems: [String] = []) {
        self.id = UUID()
        self.type = type
        self.title = title
        self.description = description
        self.priority = priority
        self.actionItems = actionItems
        self.isAddressed = false
    }
}

enum InsightType: String, CaseIterable, Codable {
    case consistency = "consistency"
    case motivation = "motivation"
    case scheduling = "scheduling"
    case environment = "environment"
    case progress = "progress"
    case challenge = "challenge"
    
    var icon: String {
        switch self {
        case .consistency: return "chart.line.uptrend.xyaxis"
        case .motivation: return "heart.fill"
        case .scheduling: return "calendar"
        case .environment: return "house.fill"
        case .progress: return "arrow.up.circle.fill"
        case .challenge: return "exclamationmark.triangle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .consistency: return .blue
        case .motivation: return .pink
        case .scheduling: return .orange
        case .environment: return .green
        case .progress: return .purple
        case .challenge: return .red
        }
    }
    
    var displayName: String {
        switch self {
        case .consistency: return "Consistencia"
        case .motivation: return "Motivación"
        case .scheduling: return "Horarios"
        case .environment: return "Ambiente"
        case .progress: return "Progreso"
        case .challenge: return "Desafíos"
        }
    }
}

enum InsightPriority: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
    
    var color: Color {
        switch self {
        case .low: return .gray
        case .medium: return .blue
        case .high: return .orange
        case .critical: return .red
        }
    }
    
    var displayName: String {
        switch self {
        case .low: return "Baja"
        case .medium: return "Media"
        case .high: return "Alta"
        case .critical: return "Crítica"
        }
    }
}

// MARK: - Weekly Goal
struct WeeklyGoal: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let targetValue: Int
    let currentValue: Int
    let habitIds: [UUID]
    let isCompleted: Bool
    
    init(title: String, description: String, targetValue: Int, habitIds: [UUID] = []) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.targetValue = targetValue
        self.currentValue = 0
        self.habitIds = habitIds
        self.isCompleted = false
    }
    
    var progress: Double {
        guard targetValue > 0 else { return 0.0 }
        return min(Double(currentValue) / Double(targetValue), 1.0)
    }
}

// MARK: - Weekly Reflection Service
@MainActor
class HabitsWeeklyReflectionService: ObservableObject {
    static let shared = HabitsWeeklyReflectionService()
    
    @Published var reflections: [WeeklyReflection] = []
    @Published var currentReflection: WeeklyReflection?
    @Published var isReflectionDue: Bool = false
    @Published var lastReflectionDate: Date?
    
    private let userDefaultsKey = "weekly_reflections"
    private let lastReflectionKey = "last_reflection_date"
    
    private init() {
        loadReflections()
        checkForReflectionDue()
        generateCurrentReflection()
    }
    
    // MARK: - Reflection Management
    func generateCurrentReflection() {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        // Check if we already have a reflection for this week
        if let existingReflection = reflections.first(where: { 
            calendar.isDate($0.weekStartDate, equalTo: weekStart, toGranularity: .weekOfYear)
        }) {
            currentReflection = existingReflection
            return
        }
        
        // Create new reflection for this week
        let newReflection = WeeklyReflection(weekStartDate: weekStart)
        reflections.append(newReflection)
        currentReflection = newReflection
        saveReflections()
    }
    
    func updateReflection(_ reflection: WeeklyReflection) {
        if let index = reflections.firstIndex(where: { $0.id == reflection.id }) {
            reflections[index] = reflection
            if reflection.id == currentReflection?.id {
                currentReflection = reflection
            }
            saveReflections()
        }
    }
    
    func completeReflection(_ reflection: WeeklyReflection) {
        var completedReflection = reflection
        completedReflection = WeeklyReflection(
            id: completedReflection.id,
            weekStartDate: completedReflection.weekStartDate,
            weekEndDate: completedReflection.weekEndDate,
            completedHabits: completedReflection.completedHabits,
            missedHabits: completedReflection.missedHabits,
            insights: completedReflection.insights,
            goals: completedReflection.goals,
            challenges: completedReflection.challenges,
            wins: completedReflection.wins,
            isCompleted: true,
            completedAt: Date()
        )
        
        updateReflection(completedReflection)
        lastReflectionDate = Date()
        UserDefaults.standard.set(lastReflectionDate, forKey: lastReflectionKey)
        checkForReflectionDue()
    }
    
    // MARK: - Insight Generation
    func generateInsights(for habits: [Habit], completedHabits: [UUID], missedHabits: [UUID]) -> [ReflectionInsight] {
        var insights: [ReflectionInsight] = []
        
        // Consistency insight
        let consistencyRate = Double(completedHabits.count) / Double(completedHabits.count + missedHabits.count)
        if consistencyRate < 0.5 {
            insights.append(ReflectionInsight(
                type: .consistency,
                title: "Consistencia Baja",
                description: "Tu tasa de cumplimiento esta semana fue del \(Int(consistencyRate * 100))%. Considera ajustar tus hábitos para mejorar la consistencia.",
                priority: .high,
                actionItems: [
                    "Reduce el número de hábitos simultáneos",
                    "Establece horarios más específicos",
                    "Crea recordatorios más frecuentes"
                ]
            ))
        } else if consistencyRate > 0.8 {
            insights.append(ReflectionInsight(
                type: .consistency,
                title: "Excelente Consistencia",
                description: "¡Increíble! Mantuviste una tasa de cumplimiento del \(Int(consistencyRate * 100))% esta semana.",
                priority: .low,
                actionItems: [
                    "Considera agregar un nuevo hábito",
                    "Comparte tu éxito con otros",
                    "Mantén el impulso para la próxima semana"
                ]
            ))
        }
        
        // Progress insight
        let improvedHabits = habits.filter { habit in
            habit.streak > 3 && completedHabits.contains(habit.id)
        }
        
        if !improvedHabits.isEmpty {
            insights.append(ReflectionInsight(
                type: .progress,
                title: "Progreso Notable",
                description: "\(improvedHabits.count) de tus hábitos han mantenido rachas de más de 3 días.",
                priority: .medium,
                actionItems: [
                    "Celebra estos logros",
                    "Identifica qué está funcionando bien",
                    "Aplica estas estrategias a otros hábitos"
                ]
            ))
        }
        
        // Challenge insight
        let problematicHabits = habits.filter { habit in
            missedHabits.contains(habit.id) && habit.streak == 0
        }
        
        if !problematicHabits.isEmpty {
            insights.append(ReflectionInsight(
                type: .challenge,
                title: "Hábitos en Dificultad",
                description: "\(problematicHabits.count) hábitos han sido especialmente desafiantes esta semana.",
                priority: .high,
                actionItems: [
                    "Revisa la dificultad de estos hábitos",
                    "Considera dividirlos en pasos más pequeños",
                    "Evalúa si el momento del día es el adecuado"
                ]
            ))
        }
        
        return insights
    }
    
    // MARK: - Goal Suggestions
    func generateWeeklyGoals(for habits: [Habit]) -> [WeeklyGoal] {
        var goals: [WeeklyGoal] = []
        
        // Consistency goal
        goals.append(WeeklyGoal(
            title: "Mantener Consistencia",
            description: "Completa al menos el 70% de tus hábitos diarios",
            targetValue: Int(Double(habits.count) * 0.7 * 7),
            habitIds: habits.map { $0.id }
        ))
        
        // Streak goal
        let longestStreak = habits.map { $0.streak }.max() ?? 0
        if longestStreak > 0 {
            goals.append(WeeklyGoal(
                title: "Superar Racha Personal",
                description: "Mantén tu racha más larga durante toda la semana",
                targetValue: longestStreak + 7,
                habitIds: habits.filter { $0.streak == longestStreak }.map { $0.id }
            ))
        }
        
        // New habit goal
        let newHabits = habits.filter { $0.streak < 7 }
        if !newHabits.isEmpty {
            goals.append(WeeklyGoal(
                title: "Establecer Nuevos Hábitos",
                description: "Mantén tus nuevos hábitos durante 7 días consecutivos",
                targetValue: newHabits.count * 7,
                habitIds: newHabits.map { $0.id }
            ))
        }
        
        return goals
    }
    
    // MARK: - Reflection Scheduling
    private func checkForReflectionDue() {
        guard let lastReflection = lastReflectionDate else {
            isReflectionDue = true
            return
        }
        
        let calendar = Calendar.current
        let daysSinceLastReflection = calendar.dateComponents([.day], from: lastReflection, to: Date()).day ?? 0
        
        // Reflection is due every 7 days
        isReflectionDue = daysSinceLastReflection >= 7
    }
    
    func scheduleReflectionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Reflexión Semanal de Hábitos"
        content.body = "Es hora de revisar tu progreso semanal y planificar la próxima semana."
        content.sound = .default
        
        // Schedule for next Sunday at 9 AM
        var dateComponents = DateComponents()
        dateComponents.weekday = 1 // Sunday
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "weekly_reflection", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Analytics
    func getReflectionStats() -> (total: Int, completed: Int, averageCompletion: Double) {
        let total = reflections.count
        let completed = reflections.filter { $0.isCompleted }.count
        let averageCompletion = reflections.isEmpty ? 0.0 : reflections.map { $0.completionRate }.reduce(0, +) / Double(reflections.count)
        
        return (total, completed, averageCompletion)
    }
    
    func getTrendingInsights() -> [InsightType: Int] {
        var insightCounts: [InsightType: Int] = [:]
        
        for reflection in reflections {
            for insight in reflection.insights {
                insightCounts[insight.type, default: 0] += 1
            }
        }
        
        return insightCounts
    }
    
    // MARK: - Persistence
    private func saveReflections() {
        if let data = try? JSONEncoder().encode(reflections) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    private func loadReflections() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            if let loadedReflections = try? JSONDecoder().decode([WeeklyReflection].self, from: data) {
                reflections = loadedReflections
            }
        }
        
        lastReflectionDate = UserDefaults.standard.object(forKey: lastReflectionKey) as? Date
    }
}

// MARK: - Helper Extensions
extension WeeklyReflection {
    init(id: UUID, weekStartDate: Date, weekEndDate: Date, completedHabits: [UUID], missedHabits: [UUID], insights: [ReflectionInsight], goals: [WeeklyGoal], challenges: [String], wins: [String], isCompleted: Bool, completedAt: Date?) {
        self.id = id
        self.weekStartDate = weekStartDate
        self.weekEndDate = weekEndDate
        self.completedHabits = completedHabits
        self.missedHabits = missedHabits
        self.insights = insights
        self.goals = goals
        self.challenges = challenges
        self.wins = wins
        self.isCompleted = isCompleted
        self.completedAt = completedAt
    }
}
