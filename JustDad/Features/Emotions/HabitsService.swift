//
//  HabitsService.swift
//  JustDad - Advanced Habits Management
//
//  Advanced habit tracking with Atomic Habits principles
//

import Foundation
import SwiftUI

// MARK: - Habits Service
class HabitsService: ObservableObject {
    static let shared = HabitsService()
    
    @Published var habits: [Habit] = []
    @Published var insights: HabitInsights = HabitInsights()
    @Published var achievements: [HabitAchievement] = []
    
    private init() {
        loadHabits()
        loadAchievements()
        updateInsights()
    }
    
    // MARK: - Habit Management
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        saveHabits()
        updateInsights()
        checkForNewAchievements()
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            saveHabits()
            updateInsights()
            checkForNewAchievements()
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        saveHabits()
        updateInsights()
    }
    
    func toggleHabitCompletion(_ habit: Habit) {
        let today = Calendar.current.startOfDay(for: Date())
        
        var updatedHabit = habit
        if updatedHabit.isCompletedToday {
            updatedHabit.completedDays.remove(today)
        } else {
            updatedHabit.completedDays.insert(today)
        }
        
        updateStreak(for: &updatedHabit)
        updateHabit(updatedHabit)
    }
    
    // MARK: - Insights
    private func updateInsights() {
        insights = HabitInsights(
            totalHabits: habits.count,
            completedToday: habits.filter { $0.isCompletedToday }.count,
            averageStreak: habits.map { $0.streak }.reduce(0, +) / max(habits.count, 1),
            bestStreak: habits.map { $0.streak }.max() ?? 0,
            totalCompletions: habits.flatMap { $0.completedDays }.count,
            weeklyProgress: calculateWeeklyProgress(),
            monthlyProgress: calculateMonthlyProgress(),
            categoryBreakdown: calculateCategoryBreakdown()
        )
    }
    
    private func calculateWeeklyProgress() -> [String: Double] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        var progress: [String: Double] = [:]
        
        for habit in habits {
            let weeklyCompletions = habit.completedDays.filter { $0 >= weekAgo }.count
            progress[habit.name] = Double(weeklyCompletions) / 7.0
        }
        
        return progress
    }
    
    private func calculateMonthlyProgress() -> [String: Double] {
        let calendar = Calendar.current
        let monthAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        var progress: [String: Double] = [:]
        
        for habit in habits {
            let monthlyCompletions = habit.completedDays.filter { $0 >= monthAgo }.count
            progress[habit.name] = Double(monthlyCompletions) / 30.0
        }
        
        return progress
    }
    
    private func calculateCategoryBreakdown() -> [HabitCategory: Int] {
        var breakdown: [HabitCategory: Int] = [:]
        
        for habit in habits {
            breakdown[habit.category, default: 0] += 1
        }
        
        return breakdown
    }
    
    // MARK: - Achievements
    private func checkForNewAchievements() {
        let newAchievements = HabitAchievement.allAchievements.filter { achievement in
            !achievements.contains { $0.id == achievement.id } && achievement.isUnlocked(for: habits)
        }
        
        achievements.append(contentsOf: newAchievements)
        saveAchievements()
    }
    
    // MARK: - Streak Management
    private func updateStreak(for habit: inout Habit) {
        let today = Calendar.current.startOfDay(for: Date())
        var streak = 0
        var currentDate = today
        
        while habit.completedDays.contains(currentDate) {
            streak += 1
            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        habit.streak = streak
    }
    
    // MARK: - Persistence
    private func saveHabits() {
        if let data = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(data, forKey: "habits")
        }
    }
    
    private func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: "habits"),
           let loadedHabits = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = loadedHabits
        }
    }
    
    private func saveAchievements() {
        if let data = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(data, forKey: "habit_achievements")
        }
    }
    
    private func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: "habit_achievements"),
           let loadedAchievements = try? JSONDecoder().decode([HabitAchievement].self, from: data) {
            achievements = loadedAchievements
        }
    }
}

// MARK: - Habit Insights
struct HabitInsights: Codable {
    let totalHabits: Int
    let completedToday: Int
    let averageStreak: Int
    let bestStreak: Int
    let totalCompletions: Int
    let weeklyProgress: [String: Double]
    let monthlyProgress: [String: Double]
    let categoryBreakdown: [HabitCategory: Int]
    
    init(totalHabits: Int = 0, completedToday: Int = 0, averageStreak: Int = 0, bestStreak: Int = 0, totalCompletions: Int = 0, weeklyProgress: [String: Double] = [:], monthlyProgress: [String: Double] = [:], categoryBreakdown: [HabitCategory: Int] = [:]) {
        self.totalHabits = totalHabits
        self.completedToday = completedToday
        self.averageStreak = averageStreak
        self.bestStreak = bestStreak
        self.totalCompletions = totalCompletions
        self.weeklyProgress = weeklyProgress
        self.monthlyProgress = monthlyProgress
        self.categoryBreakdown = categoryBreakdown
    }
}

// MARK: - Habit Achievement
struct HabitAchievement: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let color: String
    let unlockedAt: Date?
    
    init(title: String, description: String, icon: String, color: String, unlockedAt: Date? = nil) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.icon = icon
        self.color = color
        self.unlockedAt = unlockedAt
    }
    
    static let allAchievements: [HabitAchievement] = [
        HabitAchievement(
            title: "Primer Paso",
            description: "Completa tu primer hábito",
            icon: "star.fill",
            color: "gold"
        ),
        HabitAchievement(
            title: "Racha de 7",
            description: "Mantén una racha de 7 días",
            icon: "flame.fill",
            color: "orange"
        ),
        HabitAchievement(
            title: "Racha de 30",
            description: "Mantén una racha de 30 días",
            icon: "crown.fill",
            color: "purple"
        ),
        HabitAchievement(
            title: "Maestro de Hábitos",
            description: "Completa 100 hábitos en total",
            icon: "trophy.fill",
            color: "blue"
        ),
        HabitAchievement(
            title: "Consistencia Perfecta",
            description: "Completa todos tus hábitos por 7 días seguidos",
            icon: "checkmark.seal.fill",
            color: "green"
        )
    ]
    
    func isUnlocked(for habits: [Habit]) -> Bool {
        switch title {
        case "Primer Paso":
            return habits.contains { $0.completedDays.count > 0 }
        case "Racha de 7":
            return habits.contains { $0.streak >= 7 }
        case "Racha de 30":
            return habits.contains { $0.streak >= 30 }
        case "Maestro de Hábitos":
            return habits.flatMap { $0.completedDays }.count >= 100
        case "Consistencia Perfecta":
            return habits.allSatisfy { $0.streak >= 7 }
        default:
            return false
        }
    }
}

// MARK: - Habit Goal
struct HabitGoal: Identifiable, Codable {
    let id: UUID
    let habitId: UUID
    let targetStreak: Int
    let targetCompletions: Int
    let deadline: Date?
    let isCompleted: Bool
    
    init(habitId: UUID, targetStreak: Int, targetCompletions: Int, deadline: Date? = nil, isCompleted: Bool = false) {
        self.id = UUID()
        self.habitId = habitId
        self.targetStreak = targetStreak
        self.targetCompletions = targetCompletions
        self.deadline = deadline
        self.isCompleted = isCompleted
    }
}

// MARK: - Habit Reminder
struct HabitReminder: Identifiable, Codable {
    let id: UUID
    let habitId: UUID
    let time: Date
    let message: String
    let isEnabled: Bool
    
    init(habitId: UUID, time: Date, message: String, isEnabled: Bool = true) {
        self.id = UUID()
        self.habitId = habitId
        self.time = time
        self.message = message
        self.isEnabled = isEnabled
    }
}
