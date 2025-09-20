//
//  FinancialGoalService.swift
//  JustDad - Financial Goal Service
//
//  Professional service for managing financial goals and achievements.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class FinancialGoalService: ObservableObject {
    @Published var goals: [FinancialGoal] = []
    @Published var achievements: [GoalAchievement] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let modelContext: ModelContext
    
    init() {
        // Initialize ModelContainerManager first
        do {
            try ModelContainerManager.shared.initializeContainer()
        } catch {
            print("Error initializing container: \(error)")
        }
        
        self.modelContext = ModelContainerManager.shared.getContext() ?? ModelContext(try! ModelContainer(for: FinancialGoal.self, GoalAchievement.self))
        loadGoals()
        loadAchievements()
    }
    
    // MARK: - Goal Management
    func createGoal(title: String, description: String?, targetAmount: Decimal, targetDate: Date, category: GoalCategory, priority: GoalPriority = .medium) async throws {
        let goal = FinancialGoal(
            title: title,
            description: description,
            targetAmount: targetAmount,
            targetDate: targetDate,
            category: category,
            priority: priority
        )
        
        modelContext.insert(goal)
        try modelContext.save()
        loadGoals()
    }
    
    func updateGoal(_ goal: FinancialGoal, title: String, description: String?, targetAmount: Decimal, targetDate: Date, category: GoalCategory, priority: GoalPriority) async throws {
        goal.title = title
        goal.goalDescription = description
        goal.targetAmount = targetAmount
        goal.targetDate = targetDate
        goal.category = category
        goal.priority = priority
        goal.updatedAt = Date()
        
        try modelContext.save()
        loadGoals()
    }
    
    func deleteGoal(_ goal: FinancialGoal) async throws {
        modelContext.delete(goal)
        try modelContext.save()
        loadGoals()
    }
    
    func toggleGoalActiveStatus(_ goal: FinancialGoal) async throws {
        goal.isActive.toggle()
        goal.updatedAt = Date()
        try modelContext.save()
        loadGoals()
    }
    
    func addAmountToGoal(_ goal: FinancialGoal, amount: Decimal) async throws {
        goal.currentAmount += amount
        goal.updatedAt = Date()
        
        // Check if goal is completed
        if goal.currentAmount >= goal.targetAmount && !goal.isCompleted {
            goal.isCompleted = true
            await checkAndAwardAchievements(for: goal)
        }
        
        try modelContext.save()
        loadGoals()
    }
    
    func removeAmountFromGoal(_ goal: FinancialGoal, amount: Decimal) async throws {
        goal.currentAmount = max(0, goal.currentAmount - amount)
        goal.updatedAt = Date()
        
        // Check if goal is no longer completed
        if goal.currentAmount < goal.targetAmount && goal.isCompleted {
            goal.isCompleted = false
        }
        
        try modelContext.save()
        loadGoals()
    }
    
    // MARK: - Achievement System
    private func checkAndAwardAchievements(for goal: FinancialGoal) async {
        let achievementsToCheck: [AchievementType] = [
            .goalCompleted,
            goal.daysRemaining > 0 ? .goalCompletedEarly : .goalCompletedOnTime,
            .precise
        ]
        
        for achievementType in achievementsToCheck {
            await awardAchievement(goalId: goal.id, type: achievementType)
        }
        
        // Check progress achievements
        let progressAchievements: [AchievementType] = [
            goal.progressPercentage >= 0.25 ? .goalProgress25 : nil,
            goal.progressPercentage >= 0.50 ? .goalProgress50 : nil,
            goal.progressPercentage >= 0.75 ? .goalProgress75 : nil
        ].compactMap { $0 }
        
        for achievementType in progressAchievements {
            await awardAchievement(goalId: goal.id, type: achievementType)
        }
        
        // Check category-specific achievements
        if goal.category == .education {
            await awardAchievement(goalId: goal.id, type: .fatherExemplar)
        }
        
        if goal.category == .emergency {
            await awardAchievement(goalId: goal.id, type: .smartSaver)
        }
        
        if goal.category == .vacation {
            await awardAchievement(goalId: goal.id, type: .celebration)
        }
        
        if goal.category == .home {
            await awardAchievement(goalId: goal.id, type: .homeSecure)
        }
    }
    
    private func awardAchievement(goalId: UUID, type: AchievementType) async {
        // Check if achievement already exists
        let existingAchievement = achievements.first { 
            $0.goalId == goalId && $0.achievementType == type 
        }
        
        if existingAchievement == nil {
            let achievement = GoalAchievement(goalId: goalId, achievementType: type)
            modelContext.insert(achievement)
            
            do {
                try modelContext.save()
                loadAchievements()
            } catch {
                print("Error saving achievement: \(error)")
            }
        }
    }
    
    // MARK: - Data Loading
    private func loadGoals() {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchDescriptor = FetchDescriptor<FinancialGoal>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            goals = try modelContext.fetch(fetchDescriptor)
            isLoading = false
        } catch {
            errorMessage = "Error al cargar metas: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    private func loadAchievements() {
        do {
            let fetchDescriptor = FetchDescriptor<GoalAchievement>(
                sortBy: [SortDescriptor(\.earnedAt, order: .reverse)]
            )
            achievements = try modelContext.fetch(fetchDescriptor)
        } catch {
            print("Error loading achievements: \(error)")
        }
    }
    
    // MARK: - Computed Properties
    var activeGoals: [FinancialGoal] {
        goals.filter { $0.isActive && !$0.isCompleted }
    }
    
    var completedGoals: [FinancialGoal] {
        goals.filter { $0.isCompleted }
    }
    
    var overdueGoals: [FinancialGoal] {
        goals.filter { $0.isOverdue && !$0.isCompleted }
    }
    
    var totalTargetAmount: Decimal {
        activeGoals.reduce(0) { $0 + $1.targetAmount }
    }
    
    var totalCurrentAmount: Decimal {
        activeGoals.reduce(0) { $0 + $1.currentAmount }
    }
    
    var overallProgress: Double {
        guard totalTargetAmount > 0 else { return 0 }
        return Double(truncating: NSDecimalNumber(decimal: totalCurrentAmount / totalTargetAmount))
    }
    
    var recentAchievements: [GoalAchievement] {
        Array(achievements.prefix(5))
    }
    
    var uncelebratedAchievements: [GoalAchievement] {
        achievements.filter { !$0.isCelebrated }
    }
    
    // MARK: - Statistics
    func getGoalStats() -> GoalStats {
        let totalGoals = goals.count
        let completedGoalsCount = completedGoals.count
        let activeGoalsCount = activeGoals.count
        let overdueGoalsCount = overdueGoals.count
        
        return GoalStats(
            totalGoals: totalGoals,
            completedGoals: completedGoalsCount,
            activeGoals: activeGoalsCount,
            overdueGoals: overdueGoalsCount,
            completionRate: totalGoals > 0 ? Double(completedGoalsCount) / Double(totalGoals) : 0,
            totalTargetAmount: totalTargetAmount,
            totalCurrentAmount: totalCurrentAmount,
            overallProgress: overallProgress
        )
    }
    
    func getCategoryStats() -> [CategoryStats] {
        let categories = GoalCategory.allCases
        
        return categories.map { category in
            let categoryGoals = goals.filter { $0.category == category }
            let completedGoals = categoryGoals.filter { $0.isCompleted }
            let totalTarget = categoryGoals.reduce(0) { $0 + $1.targetAmount }
            let totalCurrent = categoryGoals.reduce(0) { $0 + $1.currentAmount }
            
            return CategoryStats(
                category: category,
                totalGoals: categoryGoals.count,
                completedGoals: completedGoals.count,
                totalTargetAmount: totalTarget,
                totalCurrentAmount: totalCurrent,
                progress: totalTarget > 0 ? Double(truncating: NSDecimalNumber(decimal: totalCurrent / totalTarget)) : 0
            )
        }
    }
}

// MARK: - Supporting Types
struct GoalStats {
    let totalGoals: Int
    let completedGoals: Int
    let activeGoals: Int
    let overdueGoals: Int
    let completionRate: Double
    let totalTargetAmount: Decimal
    let totalCurrentAmount: Decimal
    let overallProgress: Double
}

struct CategoryStats {
    let category: GoalCategory
    let totalGoals: Int
    let completedGoals: Int
    let totalTargetAmount: Decimal
    let totalCurrentAmount: Decimal
    let progress: Double
}

// MARK: - Predefined Goals
extension FinancialGoalService {
    static var predefinedGoals: [PredefinedGoal] {
        [
            PredefinedGoal(
                title: "Fondo de Emergencia",
                description: "Ahorra 3-6 meses de gastos para emergencias",
                category: .emergency,
                priority: .high,
                suggestedAmount: 5000,
                suggestedMonths: 12
            ),
            PredefinedGoal(
                title: "Educación de los Hijos",
                description: "Ahorra para la educación universitaria",
                category: .education,
                priority: .high,
                suggestedAmount: 10000,
                suggestedMonths: 24
            ),
            PredefinedGoal(
                title: "Vacaciones en Familia",
                description: "Disfruta unas vacaciones merecidas con tu familia",
                category: .vacation,
                priority: .medium,
                suggestedAmount: 2000,
                suggestedMonths: 6
            ),
            PredefinedGoal(
                title: "Reparaciones del Hogar",
                description: "Mantén tu hogar en perfecto estado",
                category: .home,
                priority: .medium,
                suggestedAmount: 1500,
                suggestedMonths: 8
            ),
            PredefinedGoal(
                title: "Control de Gastos en Comida",
                description: "Reduce gastos innecesarios en alimentación",
                category: .food,
                priority: .low,
                suggestedAmount: 500,
                suggestedMonths: 3
            ),
            PredefinedGoal(
                title: "Nuevo Vehículo",
                description: "Ahorra para un vehículo confiable",
                category: .transportation,
                priority: .high,
                suggestedAmount: 15000,
                suggestedMonths: 36
            )
        ]
    }
}

struct PredefinedGoal {
    let title: String
    let description: String
    let category: GoalCategory
    let priority: GoalPriority
    let suggestedAmount: Decimal
    let suggestedMonths: Int
}
