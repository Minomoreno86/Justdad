//
//  HabitsGoalsService.swift
//  JustDad - Goals Management System
//
//  Sistema completo de metas y objetivos para hábitos
//

import Foundation
import SwiftUI

// MARK: - Habits Goals Service
class HabitsGoalsService: ObservableObject {
    static let shared = HabitsGoalsService()
    
    @Published var goals: [HabitsGoal] = []
    @Published var activeGoals: [HabitsGoal] = []
    @Published var completedGoals: [HabitsGoal] = []
    @Published var goalInsights: GoalInsights = GoalInsights()
    
    private init() {
        loadGoals()
        updateGoalInsights()
    }
    
    // MARK: - Goal Management
    func createGoal(_ goal: HabitsGoal) {
        goals.append(goal)
        updateGoalCategories()
        saveGoals()
        updateGoalInsights()
    }
    
    func updateGoal(_ goal: HabitsGoal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            updateGoalCategories()
            saveGoals()
            updateGoalInsights()
        }
    }
    
    func deleteGoal(_ goal: HabitsGoal) {
        goals.removeAll { $0.id == goal.id }
        updateGoalCategories()
        saveGoals()
        updateGoalInsights()
    }
    
    func completeGoal(_ goal: HabitsGoal) {
        var updatedGoal = goal
        updatedGoal.status = .completed
        updatedGoal.completedAt = Date()
        updateGoal(updatedGoal)
    }
    
    func pauseGoal(_ goal: HabitsGoal) {
        var updatedGoal = goal
        updatedGoal.status = .paused
        updateGoal(updatedGoal)
    }
    
    func resumeGoal(_ goal: HabitsGoal) {
        var updatedGoal = goal
        updatedGoal.status = .active
        updateGoal(updatedGoal)
    }
    
    // MARK: - Progress Tracking
    func updateGoalProgress(_ goalId: UUID, progress: Double) {
        if let index = goals.firstIndex(where: { $0.id == goalId }) {
            goals[index].currentProgress = min(progress, 1.0)
            
            // Check if goal is completed
            if goals[index].currentProgress >= 1.0 && goals[index].status != .completed {
                completeGoal(goals[index])
            }
            
            saveGoals()
            updateGoalInsights()
        }
    }
    
    func addMilestone(_ milestone: GoalMilestone, to goalId: UUID) {
        if let index = goals.firstIndex(where: { $0.id == goalId }) {
            goals[index].milestones.append(milestone)
            saveGoals()
        }
    }
    
    func completeMilestone(_ milestoneId: UUID, in goalId: UUID) {
        if let goalIndex = goals.firstIndex(where: { $0.id == goalId }),
           let milestoneIndex = goals[goalIndex].milestones.firstIndex(where: { $0.id == milestoneId }) {
            goals[goalIndex].milestones[milestoneIndex].isCompleted = true
            goals[goalIndex].milestones[milestoneIndex].completedAt = Date()
            
            // Update overall goal progress
            updateGoalProgressFromMilestones(goalId: goalId)
            saveGoals()
            updateGoalInsights()
        }
    }
    
    private func updateGoalProgressFromMilestones(goalId: UUID) {
        if let goalIndex = goals.firstIndex(where: { $0.id == goalId }) {
            let completedMilestones = goals[goalIndex].milestones.filter { $0.isCompleted }.count
            let totalMilestones = goals[goalIndex].milestones.count
            
            if totalMilestones > 0 {
                let progress = Double(completedMilestones) / Double(totalMilestones)
                goals[goalIndex].currentProgress = progress
                
                // Check if goal is completed
                if progress >= 1.0 && goals[goalIndex].status != .completed {
                    completeGoal(goals[goalIndex])
                }
            }
        }
    }
    
    // MARK: - Goal Categories
    private func updateGoalCategories() {
        activeGoals = goals.filter { $0.status == .active }
        completedGoals = goals.filter { $0.status == .completed }
    }
    
    // MARK: - Insights
    private func updateGoalInsights() {
        let activeGoals = goals.filter { $0.status == .active }
        let completedGoals = goals.filter { $0.status == .completed }
        let overdueGoals = goals.filter { $0.isOverdue }
        
        let totalProgress = goals.isEmpty ? 0.0 : goals.map { $0.currentProgress }.reduce(0, +) / Double(goals.count)
        
        goalInsights = GoalInsights(
            totalGoals: goals.count,
            activeGoals: activeGoals.count,
            completedGoals: completedGoals.count,
            overdueGoals: overdueGoals.count,
            averageProgress: totalProgress,
            completionRate: goals.isEmpty ? 0.0 : Double(completedGoals.count) / Double(goals.count),
            goalsByCategory: calculateGoalsByCategory(),
            goalsByPriority: calculateGoalsByPriority(),
            recentCompletions: getRecentCompletions(),
            upcomingDeadlines: getUpcomingDeadlines()
        )
    }
    
    private func calculateGoalsByCategory() -> [HabitsGoalCategory: Int] {
        var breakdown: [HabitsGoalCategory: Int] = [:]
        
        for goal in goals {
            breakdown[goal.category, default: 0] += 1
        }
        
        return breakdown
    }
    
    private func calculateGoalsByPriority() -> [HabitsGoalPriority: Int] {
        var breakdown: [HabitsGoalPriority: Int] = [:]
        
        for goal in goals {
            breakdown[goal.priority, default: 0] += 1
        }
        
        return breakdown
    }
    
    private func getRecentCompletions() -> [HabitsGoal] {
        return goals
            .filter { $0.status == .completed && $0.completedAt != nil }
            .sorted { $0.completedAt! > $1.completedAt! }
            .prefix(5)
            .map { $0 }
    }
    
    private func getUpcomingDeadlines() -> [HabitsGoal] {
        let now = Date()
        let thirtyDaysFromNow = Calendar.current.date(byAdding: .day, value: 30, to: now) ?? now
        
        return goals
            .filter { goal in
                guard let deadline = goal.deadline else { return false }
                return goal.status == .active && deadline > now && deadline <= thirtyDaysFromNow
            }
            .sorted { $0.deadline! < $1.deadline! }
    }
    
    // MARK: - Goal Suggestions
    func getSuggestedGoals() -> [GoalSuggestion] {
        let habitsService = HabitsService.shared
        let userHabits = habitsService.habits
        
        var suggestions: [GoalSuggestion] = []
        
        // Analyze user habits to suggest relevant goals
        let healthHabits = userHabits.filter { $0.category == .health }
        let parentingHabits = userHabits.filter { $0.category == .parenting }
        let workHabits = userHabits.filter { $0.category == .work }
        
        if healthHabits.count >= 2 && !goals.contains(where: { $0.category == .health && $0.title.contains("salud") }) {
            suggestions.append(GoalSuggestion(
                title: "Objetivo de Salud Integral",
                description: "Mantén una rutina saludable durante 30 días",
                category: .health,
                suggestedHabits: healthHabits.map { $0.name },
                confidence: .high
            ))
        }
        
        if parentingHabits.count >= 1 && !goals.contains(where: { $0.category == .parenting }) {
            suggestions.append(GoalSuggestion(
                title: "Padre Presente",
                description: "Fortalece tu conexión con tus hijos",
                category: .parenting,
                suggestedHabits: parentingHabits.map { $0.name },
                confidence: .high
            ))
        }
        
        if workHabits.count >= 1 && !goals.contains(where: { $0.category == .professional }) {
            suggestions.append(GoalSuggestion(
                title: "Crecimiento Profesional",
                description: "Desarrolla habilidades profesionales",
                category: .professional,
                suggestedHabits: workHabits.map { $0.name },
                confidence: .medium
            ))
        }
        
        return suggestions
    }
    
    // MARK: - Persistence
    private func saveGoals() {
        if let data = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(data, forKey: "habits_goals")
        }
    }
    
    private func loadGoals() {
        if let data = UserDefaults.standard.data(forKey: "habits_goals"),
           let loadedGoals = try? JSONDecoder().decode([HabitsGoal].self, from: data) {
            goals = loadedGoals
            updateGoalCategories()
        }
    }
}

// MARK: - Goal Models
struct HabitsGoal: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var category: HabitsGoalCategory
    var priority: HabitsGoalPriority
    var status: GoalStatus
    var targetValue: Double
    var currentProgress: Double
    var unit: String
    var deadline: Date?
    var createdAt: Date
    var completedAt: Date?
    var milestones: [GoalMilestone]
    var relatedHabits: [UUID] // IDs of related habits
    var motivation: String
    var obstacles: [String]
    var rewards: [String]
    var isPublic: Bool
    
    var progressPercentage: Double {
        return currentProgress * 100
    }
    
    var isOverdue: Bool {
        guard let deadline = deadline else { return false }
        return status == .active && deadline < Date()
    }
    
    var daysRemaining: Int? {
        guard let deadline = deadline else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: deadline)
        return components.day
    }
    
    var formattedDeadline: String? {
        guard let deadline = deadline else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: deadline)
    }
    
    init(title: String, description: String, category: HabitsGoalCategory, priority: HabitsGoalPriority, targetValue: Double, unit: String, deadline: Date? = nil, relatedHabits: [UUID] = [], motivation: String = "", obstacles: [String] = [], rewards: [String] = [], isPublic: Bool = false) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.category = category
        self.priority = priority
        self.status = .active
        self.targetValue = targetValue
        self.currentProgress = 0.0
        self.unit = unit
        self.deadline = deadline
        self.createdAt = Date()
        self.completedAt = nil
        self.milestones = []
        self.relatedHabits = relatedHabits
        self.motivation = motivation
        self.obstacles = obstacles
        self.rewards = rewards
        self.isPublic = isPublic
    }
}

// MARK: - Habits Goal Category
enum HabitsGoalCategory: String, CaseIterable, Codable {
    case health = "health"
    case parenting = "parenting"
    case professional = "professional"
    case personal = "personal"
    case relationships = "relationships"
    case financial = "financial"
    case learning = "learning"
    case creative = "creative"
    
    var title: String {
        switch self {
        case .health: return "Salud"
        case .parenting: return "Paternidad"
        case .professional: return "Profesional"
        case .personal: return "Personal"
        case .relationships: return "Relaciones"
        case .financial: return "Financiero"
        case .learning: return "Aprendizaje"
        case .creative: return "Creativo"
        }
    }
    
    var icon: String {
        switch self {
        case .health: return "heart.fill"
        case .parenting: return "figure.and.child.holdinghands"
        case .professional: return "briefcase.fill"
        case .personal: return "person.fill"
        case .relationships: return "heart.circle.fill"
        case .financial: return "dollarsign.circle.fill"
        case .learning: return "book.fill"
        case .creative: return "paintbrush.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .health: return .red
        case .parenting: return .blue
        case .professional: return .green
        case .personal: return .purple
        case .relationships: return .pink
        case .financial: return .yellow
        case .learning: return .orange
        case .creative: return .indigo
        }
    }
}

// MARK: - Habits Goal Priority
enum HabitsGoalPriority: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
    
    var title: String {
        switch self {
        case .low: return "Baja"
        case .medium: return "Media"
        case .high: return "Alta"
        case .critical: return "Crítica"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .gray
        case .medium: return .blue
        case .high: return .orange
        case .critical: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "circle"
        case .medium: return "circle.fill"
        case .high: return "exclamationmark.circle.fill"
        case .critical: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - Goal Status
enum GoalStatus: String, CaseIterable, Codable {
    case active = "active"
    case paused = "paused"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var title: String {
        switch self {
        case .active: return "Activa"
        case .paused: return "Pausada"
        case .completed: return "Completada"
        case .cancelled: return "Cancelada"
        }
    }
    
    var color: Color {
        switch self {
        case .active: return .green
        case .paused: return .orange
        case .completed: return .blue
        case .cancelled: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .active: return "play.circle.fill"
        case .paused: return "pause.circle.fill"
        case .completed: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }
}

// MARK: - Goal Milestone
struct GoalMilestone: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var targetValue: Double
    var currentValue: Double
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date
    
    var progress: Double {
        return currentValue / targetValue
    }
    
    init(title: String, description: String, targetValue: Double) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.targetValue = targetValue
        self.currentValue = 0.0
        self.isCompleted = false
        self.completedAt = nil
        self.createdAt = Date()
    }
}

// MARK: - Goal Insights
struct GoalInsights: Codable {
    let totalGoals: Int
    let activeGoals: Int
    let completedGoals: Int
    let overdueGoals: Int
    let averageProgress: Double
    let completionRate: Double
    let goalsByCategory: [HabitsGoalCategory: Int]
    let goalsByPriority: [HabitsGoalPriority: Int]
    let recentCompletions: [HabitsGoal]
    let upcomingDeadlines: [HabitsGoal]
    
    init(totalGoals: Int = 0, activeGoals: Int = 0, completedGoals: Int = 0, overdueGoals: Int = 0, averageProgress: Double = 0.0, completionRate: Double = 0.0, goalsByCategory: [HabitsGoalCategory: Int] = [:], goalsByPriority: [HabitsGoalPriority: Int] = [:], recentCompletions: [HabitsGoal] = [], upcomingDeadlines: [HabitsGoal] = []) {
        self.totalGoals = totalGoals
        self.activeGoals = activeGoals
        self.completedGoals = completedGoals
        self.overdueGoals = overdueGoals
        self.averageProgress = averageProgress
        self.completionRate = completionRate
        self.goalsByCategory = goalsByCategory
        self.goalsByPriority = goalsByPriority
        self.recentCompletions = recentCompletions
        self.upcomingDeadlines = upcomingDeadlines
    }
}

// MARK: - Goal Suggestion
struct GoalSuggestion: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: HabitsGoalCategory
    let suggestedHabits: [String]
    let confidence: GoalSuggestionConfidence
}

// MARK: - Suggestion Confidence
enum GoalSuggestionConfidence: String, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var title: String {
        switch self {
        case .low: return "Baja"
        case .medium: return "Media"
        case .high: return "Alta"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .gray
        case .medium: return .yellow
        case .high: return .green
        }
    }
}
