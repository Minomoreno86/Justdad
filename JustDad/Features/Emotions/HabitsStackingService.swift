//
//  HabitsStackingService.swift
//  JustDad - Habit Stacking Management
//
//  Advanced habit stacking system based on Atomic Habits principles
//

import Foundation
import SwiftUI

// MARK: - Habit Stack Service
class HabitsStackingService: ObservableObject {
    static let shared = HabitsStackingService()
    
    @Published var stacks: [HabitStack] = []
    @Published var stackInsights: StackInsights = StackInsights()
    @Published var stackAchievements: [StackAchievement] = []
    
    private init() {
        loadStacks()
        loadStackAchievements()
        updateStackInsights()
    }
    
    // MARK: - Stack Management
    func createStack(_ stack: HabitStack) {
        stacks.append(stack)
        saveStacks()
        updateStackInsights()
        checkForNewStackAchievements()
    }
    
    func updateStack(_ stack: HabitStack) {
        if let index = stacks.firstIndex(where: { $0.id == stack.id }) {
            stacks[index] = stack
            saveStacks()
            updateStackInsights()
            checkForNewStackAchievements()
        }
    }
    
    func deleteStack(_ stack: HabitStack) {
        stacks.removeAll { $0.id == stack.id }
        saveStacks()
        updateStackInsights()
    }
    
    func addHabitToStack(_ habitId: UUID, to stackId: UUID, at position: Int) {
        guard let stackIndex = stacks.firstIndex(where: { $0.id == stackId }) else { return }
        
        var updatedStack = stacks[stackIndex]
        updatedStack.habitIds.insert(habitId, at: min(position, updatedStack.habitIds.count))
        stacks[stackIndex] = updatedStack
        
        saveStacks()
        updateStackInsights()
    }
    
    func removeHabitFromStack(_ habitId: UUID, from stackId: UUID) {
        guard let stackIndex = stacks.firstIndex(where: { $0.id == stackId }) else { return }
        
        var updatedStack = stacks[stackIndex]
        updatedStack.habitIds.removeAll { $0 == habitId }
        stacks[stackIndex] = updatedStack
        
        saveStacks()
        updateStackInsights()
    }
    
    func reorderHabitsInStack(_ stackId: UUID, from source: IndexSet, to destination: Int) {
        guard let stackIndex = stacks.firstIndex(where: { $0.id == stackId }) else { return }
        
        var updatedStack = stacks[stackIndex]
        updatedStack.habitIds.move(fromOffsets: source, toOffset: destination)
        stacks[stackIndex] = updatedStack
        
        saveStacks()
    }
    
    func completeStack(_ stackId: UUID) {
        guard let stackIndex = stacks.firstIndex(where: { $0.id == stackId }) else { return }
        
        var updatedStack = stacks[stackIndex]
        let today = Calendar.current.startOfDay(for: Date())
        updatedStack.completedDays.insert(today)
        updatedStack.lastCompletedDate = today
        
        stacks[stackIndex] = updatedStack
        saveStacks()
        updateStackInsights()
        checkForNewStackAchievements()
    }
    
    // MARK: - Stack Insights
    func updateStackInsights() {
        stackInsights = StackInsights(
            totalStacks: stacks.count,
            activeStacks: stacks.filter { $0.isActive }.count,
            completedToday: stacks.filter { $0.isCompletedToday }.count,
            averageStackSize: stacks.map { $0.habitIds.count }.reduce(0, +) / max(stacks.count, 1),
            totalStackCompletions: stacks.flatMap { $0.completedDays }.count,
            mostUsedTrigger: findMostUsedTrigger(),
            stackSuccessRate: calculateStackSuccessRate(),
            categoryBreakdown: calculateStackCategoryBreakdown()
        )
    }
    
    private func findMostUsedTrigger() -> String {
        let triggerCounts = stacks.reduce(into: [String: Int]()) { counts, stack in
            counts[stack.trigger, default: 0] += 1
        }
        
        return triggerCounts.max(by: { $0.value < $1.value })?.key ?? "Ninguno"
    }
    
    private func calculateStackSuccessRate() -> Double {
        guard !stacks.isEmpty else { return 0.0 }
        
        let totalPossibleCompletions = stacks.count * 30 // Last 30 days
        let actualCompletions = stacks.flatMap { $0.completedDays }.count
        
        return Double(actualCompletions) / Double(totalPossibleCompletions)
    }
    
    private func calculateStackCategoryBreakdown() -> [StackCategory: Int] {
        var breakdown: [StackCategory: Int] = [:]
        
        for stack in stacks {
            breakdown[stack.category, default: 0] += 1
        }
        
        return breakdown
    }
    
    // MARK: - Stack Achievements
    private func checkForNewStackAchievements() {
        for achievement in StackAchievement.allAchievements {
            if achievement.isUnlocked(for: stacks) && !stackAchievements.contains(where: { $0.id == achievement.id }) {
                var unlockedAchievement = achievement
                unlockedAchievement.unlockedAt = Date()
                stackAchievements.append(unlockedAchievement)
            }
        }
        saveStackAchievements()
    }
    
    // MARK: - Persistence
    private func saveStacks() {
        if let data = try? JSONEncoder().encode(stacks) {
            UserDefaults.standard.set(data, forKey: "habit_stacks")
        }
    }
    
    private func loadStacks() {
        if let data = UserDefaults.standard.data(forKey: "habit_stacks"),
           let loadedStacks = try? JSONDecoder().decode([HabitStack].self, from: data) {
            stacks = loadedStacks
        }
    }
    
    private func saveStackAchievements() {
        if let data = try? JSONEncoder().encode(stackAchievements) {
            UserDefaults.standard.set(data, forKey: "stack_achievements")
        }
    }
    
    private func loadStackAchievements() {
        if let data = UserDefaults.standard.data(forKey: "stack_achievements"),
           let loadedAchievements = try? JSONDecoder().decode([StackAchievement].self, from: data) {
            stackAchievements = loadedAchievements
        }
    }
}

// MARK: - Habit Stack Model
struct HabitStack: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var trigger: String // "Después de [X], haré [Y]"
    var habitIds: [UUID] // Ordered list of habit IDs
    var category: StackCategory
    var isActive: Bool
    var completedDays: Set<Date> = []
    var lastCompletedDate: Date?
    var createdAt: Date
    var updatedAt: Date
    
    var isCompletedToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return completedDays.contains(today)
    }
    
    var streak: Int {
        let calendar = Calendar.current
        var currentStreak = 0
        var checkDate = Calendar.current.startOfDay(for: Date())
        
        while completedDays.contains(checkDate) {
            currentStreak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }
        
        return currentStreak
    }
    
    var completionRate: Double {
        let daysSinceStart = Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 1
        return Double(completedDays.count) / Double(max(daysSinceStart, 1))
    }
    
    var weeklyCompletionRate: Double {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let weeklyCompletions = completedDays.filter { $0 >= weekAgo }.count
        return Double(weeklyCompletions) / 7.0
    }
    
    var motivationQuote: String {
        switch streak {
        case 0...6:
            return "Los pequeños pasos llevan a grandes cambios"
        case 7...29:
            return "¡Excelente! Estás construyendo momentum"
        case 30...89:
            return "¡Increíble! Este stack se está volviendo automático"
        default:
            return "¡Eres una inspiración! Sigue así"
        }
    }
    
    init(name: String, description: String, trigger: String, habitIds: [UUID] = [], category: StackCategory, isActive: Bool = true) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.trigger = trigger
        self.habitIds = habitIds
        self.category = category
        self.isActive = isActive
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Stack Category
enum StackCategory: String, CaseIterable, Codable {
    case morning = "morning"
    case evening = "evening"
    case work = "work"
    case health = "health"
    case learning = "learning"
    case social = "social"
    case productivity = "productivity"
    case wellness = "wellness"
    case custom = "custom"
    
    var title: String {
        switch self {
        case .morning: return "Mañana"
        case .evening: return "Noche"
        case .work: return "Trabajo"
        case .health: return "Salud"
        case .learning: return "Aprendizaje"
        case .social: return "Social"
        case .productivity: return "Productividad"
        case .wellness: return "Bienestar"
        case .custom: return "Personalizado"
        }
    }
    
    var icon: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .evening: return "moon.fill"
        case .work: return "briefcase.fill"
        case .health: return "heart.fill"
        case .learning: return "book.fill"
        case .social: return "person.2.fill"
        case .productivity: return "bolt.fill"
        case .wellness: return "leaf.fill"
        case .custom: return "star.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .morning: return .orange
        case .evening: return .purple
        case .work: return .blue
        case .health: return .red
        case .learning: return .green
        case .social: return .pink
        case .productivity: return .yellow
        case .wellness: return .mint
        case .custom: return .gray
        }
    }
}

// MARK: - Stack Insights
struct StackInsights: Codable {
    let totalStacks: Int
    let activeStacks: Int
    let completedToday: Int
    let averageStackSize: Int
    let totalStackCompletions: Int
    let mostUsedTrigger: String
    let stackSuccessRate: Double
    let categoryBreakdown: [StackCategory: Int]
    
    init(totalStacks: Int = 0, activeStacks: Int = 0, completedToday: Int = 0, averageStackSize: Int = 0, totalStackCompletions: Int = 0, mostUsedTrigger: String = "", stackSuccessRate: Double = 0.0, categoryBreakdown: [StackCategory: Int] = [:]) {
        self.totalStacks = totalStacks
        self.activeStacks = activeStacks
        self.completedToday = completedToday
        self.averageStackSize = averageStackSize
        self.totalStackCompletions = totalStackCompletions
        self.mostUsedTrigger = mostUsedTrigger
        self.stackSuccessRate = stackSuccessRate
        self.categoryBreakdown = categoryBreakdown
    }
}

// MARK: - Stack Achievement
struct StackAchievement: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let color: String
    var unlockedAt: Date?
    
    init(title: String, description: String, icon: String, color: String, unlockedAt: Date? = nil) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.icon = icon
        self.color = color
        self.unlockedAt = unlockedAt
    }
    
    static let allAchievements: [StackAchievement] = [
        StackAchievement(
            title: "Primer Stack",
            description: "Crea tu primer stack de hábitos",
            icon: "square.stack.3d.up.fill",
            color: "blue"
        ),
        StackAchievement(
            title: "Stack Master",
            description: "Completa un stack por 7 días seguidos",
            icon: "flame.fill",
            color: "orange"
        ),
        StackAchievement(
            title: "Stack Legend",
            description: "Completa un stack por 30 días seguidos",
            icon: "crown.fill",
            color: "purple"
        ),
        StackAchievement(
            title: "Multi-Stacker",
            description: "Crea 5 stacks diferentes",
            icon: "square.stack.3d.up.badge.a.fill",
            color: "green"
        ),
        StackAchievement(
            title: "Stack Consistency",
            description: "Mantén una tasa de éxito del 80% por una semana",
            icon: "checkmark.seal.fill",
            color: "gold"
        )
    ]
    
    func isUnlocked(for stacks: [HabitStack]) -> Bool {
        switch title {
        case "Primer Stack":
            return !stacks.isEmpty
        case "Stack Master":
            return stacks.contains { $0.streak >= 7 }
        case "Stack Legend":
            return stacks.contains { $0.streak >= 30 }
        case "Multi-Stacker":
            return stacks.count >= 5
        case "Stack Consistency":
            return stacks.contains { $0.weeklyCompletionRate >= 0.8 }
        default:
            return false
        }
    }
}
