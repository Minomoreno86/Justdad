//
//  ProfessionalBudgetService.swift
//  JustDad - Professional Budget Management Service
//
//  Handles intelligent budget configuration, tracking, and alerts
//

import Foundation
import SwiftData
import Combine
import UserNotifications
import SwiftUI

@MainActor
class ProfessionalBudgetService: ObservableObject {
    static let shared = ProfessionalBudgetService()
    
    @Published var budgets: [Budget] = []
    @Published var budgetAlerts: [BudgetAlert] = []
    @Published var isGeneratingInsights = false
    @Published var budgetInsights: BudgetInsights?
    @Published var monthlyIncome: Decimal = 0
    
    private let persistenceService = PersistenceService.shared
    private let notificationService = UNUserNotificationCenter.current
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupNotificationPermissions()
        loadBudgets()
    }
    
    // MARK: - Data Refresh
    
    func refreshBudgetData() {
        // This method can be called when expenses are updated
        // to recalculate budget progress and insights
        Task {
            await generateBudgetInsights()
        }
    }
    
    // MARK: - Income Management
    
    func setMonthlyIncome(_ amount: Decimal) {
        monthlyIncome = amount
        saveBudgets() // Save income along with budgets
    }
    
    func getTotalIncome() -> Decimal {
        return monthlyIncome
    }
    
    func getIncomeUtilization() -> Double {
        guard monthlyIncome > 0 else { return 0 }
        let totalBudgeted = budgets.reduce(0) { $0 + $1.amount }
        return Double(truncating: NSDecimalNumber(decimal: totalBudgeted / monthlyIncome))
    }
    
    // MARK: - Budget Management
    
    func createBudget(for category: String, 
                     amount: Decimal, 
                     period: BudgetPeriod = .monthly,
                     alertThresholds: [Decimal] = [0.8, 0.9, 1.0]) {
        let budget = Budget(
            id: UUID(),
            category: category,
            amount: amount,
            period: period,
            alertThresholds: alertThresholds,
            createdAt: Date(),
            isActive: true
        )
        
        budgets.append(budget)
        saveBudgets()
        scheduleBudgetAlerts(for: budget)
    }
    
    func updateBudget(_ budget: Budget) {
        if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
            budgets[index] = budget
            saveBudgets()
            scheduleBudgetAlerts(for: budget)
        }
    }
    
    func deleteBudget(_ budget: Budget) {
        budgets.removeAll { $0.id == budget.id }
        saveBudgets()
        cancelBudgetAlerts(for: budget)
    }
    
    func toggleBudget(_ budget: Budget) {
        if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
            budgets[index].isActive.toggle()
            saveBudgets()
            
            if budgets[index].isActive {
                scheduleBudgetAlerts(for: budgets[index])
            } else {
                cancelBudgetAlerts(for: budgets[index])
            }
        }
    }
    
    // MARK: - Budget Tracking
    
    func getCurrentSpending(for budget: Budget) -> Decimal {
        do {
            let allExpenses = try persistenceService.fetch(FinancialEntry.self)
            let calendar = Calendar.current
            let now = Date()
            
            // Filter expenses by category and period
            let filteredExpenses = allExpenses.filter { expense in
                // Match category (convert budget category string to FinancialEntry.ExpenseCategory)
                let expenseCategory = mapStringToExpenseCategory(budget.category)
                guard expense.category == expenseCategory else { return false }
                
                // Filter by period
                switch budget.period {
                case .weekly:
                    return calendar.isDate(expense.date, equalTo: now, toGranularity: .weekOfYear)
                case .monthly:
                    return calendar.isDate(expense.date, equalTo: now, toGranularity: .month)
                case .quarterly:
                    let quarter = calendar.component(.quarter, from: now)
                    let expenseQuarter = calendar.component(.quarter, from: expense.date)
                    return quarter == expenseQuarter && calendar.isDate(expense.date, equalTo: now, toGranularity: .year)
                case .yearly:
                    return calendar.isDate(expense.date, equalTo: now, toGranularity: .year)
                }
            }
            
            return filteredExpenses.reduce(0) { $0 + $1.amount }
        } catch {
            print("Error fetching expenses for budget: \(error)")
            return 0
        }
    }
    
    private func mapStringToExpenseCategory(_ categoryString: String) -> FinancialEntry.ExpenseCategory {
        switch categoryString {
        case "Manutención": return .childSupport
        case "Educación": return .education
        case "Salud": return .health
        case "Alimentación", "Comida": return .food
        case "Vestimenta": return .clothing
        case "Transporte": return .transportation
        case "Entretenimiento": return .entertainment
        case "Regalos": return .gifts
        case "Otros": return .other
        default: return .other
        }
    }
    
    func getBudgetProgress(for budget: Budget) -> Double {
        let spending = getCurrentSpending(for: budget)
        return min(Double(truncating: NSDecimalNumber(decimal: spending / budget.amount)), 1.0)
    }
    
    func getBudgetStatus(for budget: Budget) -> BudgetStatus {
        let progress = getBudgetProgress(for: budget)
        
        if progress >= 1.0 {
            return .exceeded
        } else if progress >= 0.9 {
            return .critical
        } else if progress >= 0.8 {
            return .warning
        } else {
            return .onTrack
        }
    }
    
    func getRemainingAmount(for budget: Budget) -> Decimal {
        let spending = getCurrentSpending(for: budget)
        return max(budget.amount - spending, 0)
    }
    
    // MARK: - Budget Insights
    
    func generateBudgetInsights() async {
        isGeneratingInsights = true
        
        // Simulate processing time
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        let insights = BudgetInsights(
            totalBudgetedAmount: budgets.reduce(0) { $0 + $1.amount },
            totalSpent: budgets.reduce(0) { $0 + getCurrentSpending(for: $1) },
            averageUtilization: budgets.isEmpty ? 0 : budgets.reduce(0) { $0 + getBudgetProgress(for: $1) } / Double(budgets.count),
            topOverSpendingCategories: getTopOverSpendingCategories(),
            recommendations: generateRecommendations(),
            monthlyTrend: generateMonthlyTrend(),
            projectedOverspend: calculateProjectedOverspend()
        )
        
        budgetInsights = insights
        isGeneratingInsights = false
    }
    
    // MARK: - Alerts and Notifications
    
    private func setupNotificationPermissions() {
        notificationService().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    private func scheduleBudgetAlerts(for budget: Budget) {
        guard budget.isActive else { return }
        
        // Cancel existing alerts
        cancelBudgetAlerts(for: budget)
        
        // Schedule new alerts based on thresholds
        for (index, threshold) in budget.alertThresholds.enumerated() {
            let alert = BudgetAlert(
                id: "\(budget.id.uuidString)_\(index)",
                budgetId: budget.id,
                threshold: threshold,
                isTriggered: false,
                createdAt: Date()
            )
            
            budgetAlerts.append(alert)
        }
    }
    
    private func cancelBudgetAlerts(for budget: Budget) {
        budgetAlerts.removeAll { $0.budgetId == budget.id }
    }
    
    func checkBudgetAlerts() {
        for budget in budgets where budget.isActive {
            let progress = getBudgetProgress(for: budget)
            
            for alert in budgetAlerts where alert.budgetId == budget.id && !alert.isTriggered {
                let threshold = Double(truncating: NSDecimalNumber(decimal: alert.threshold))
                
                if progress >= threshold {
                    triggerBudgetAlert(alert, budget: budget, progress: progress)
                }
            }
        }
    }
    
    private func triggerBudgetAlert(_ alert: BudgetAlert, budget: Budget, progress: Double) {
        // Update alert status
        if let index = budgetAlerts.firstIndex(where: { $0.id == alert.id }) {
            budgetAlerts[index].isTriggered = true
        }
        
        // Send notification
        let content = UNMutableNotificationContent()
        content.title = "Presupuesto \(budget.category)"
        content.body = "Has gastado \(Int(progress * 100))% de tu presupuesto mensual"
        content.sound = .default
        content.badge = 1
        
        let request = UNNotificationRequest(
            identifier: alert.id,
            content: content,
            trigger: nil
        )
        
        notificationService().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getTopOverSpendingCategories() -> [CategoryOverspend] {
        return budgets.compactMap { budget in
            let progress = getBudgetProgress(for: budget)
            if progress > 1.0 {
                return CategoryOverspend(
                    category: budget.category,
                    overspendAmount: getCurrentSpending(for: budget) - budget.amount,
                    overspendPercentage: (progress - 1.0) * 100
                )
            }
            return nil
        }.sorted { $0.overspendAmount > $1.overspendAmount }
    }
    
    private func generateRecommendations() -> [BudgetRecommendation] {
        var recommendations: [BudgetRecommendation] = []
        
        // Analyze spending patterns
        let totalBudgeted = budgets.reduce(0) { $0 + $1.amount }
        let totalSpent = budgets.reduce(0) { $0 + getCurrentSpending(for: $1) }
        let utilization = totalBudgeted > 0 ? Double(truncating: NSDecimalNumber(decimal: totalSpent / totalBudgeted)) : 0
        
        if utilization > 1.1 {
            recommendations.append(BudgetRecommendation(
                type: .reduceSpending,
                title: "Reducir Gastos Urgente",
                description: "Estás gastando \(Int(utilization * 100))% de tu presupuesto. Considera reducir gastos en categorías no esenciales.",
                priority: .high
            ))
        } else if utilization > 0.9 {
            recommendations.append(BudgetRecommendation(
                type: .monitorClosely,
                title: "Monitorear de Cerca",
                description: "Estás cerca del límite de tu presupuesto. Revisa tus gastos diarios.",
                priority: .medium
            ))
        } else if utilization < 0.5 {
            recommendations.append(BudgetRecommendation(
                type: .increaseBudget,
                title: "Considera Aumentar Presupuesto",
                description: "Tienes espacio en tu presupuesto. Podrías considerar aumentar el presupuesto para categorías importantes.",
                priority: .low
            ))
        }
        
        return recommendations
    }
    
    private func generateMonthlyTrend() -> [MonthlyBudgetTrend] {
        do {
            let allExpenses = try persistenceService.fetch(FinancialEntry.self)
            let calendar = Calendar.current
            
            return (0..<6).map { monthOffset in
                let date = calendar.date(byAdding: .month, value: -monthOffset, to: Date()) ?? Date()
                
                // Calculate budgeted amount for this month
                let budgetedAmount = budgets
                    .filter { budget in
                        switch budget.period {
                        case .monthly: return true
                        case .quarterly: 
                            let quarter = calendar.component(.quarter, from: date)
                            let currentQuarter = calendar.component(.quarter, from: Date())
                            return quarter == currentQuarter
                        case .yearly:
                            return calendar.isDate(date, equalTo: Date(), toGranularity: .year)
                        case .weekly: return true // Weekly budgets apply to all months
                        }
                    }
                    .reduce(0) { $0 + $1.amount }
                
                // Calculate spent amount for this month
                let spentAmount = allExpenses
                    .filter { expense in
                        calendar.isDate(expense.date, equalTo: date, toGranularity: .month)
                    }
                    .reduce(0) { $0 + $1.amount }
                
                let utilization = budgetedAmount > 0 ? 
                    Double(truncating: NSDecimalNumber(decimal: spentAmount / budgetedAmount)) : 0
                
                return MonthlyBudgetTrend(
                    month: date,
                    budgetedAmount: budgetedAmount,
                    spentAmount: spentAmount,
                    utilization: utilization
                )
            }.reversed()
        } catch {
            print("Error generating monthly trend: \(error)")
            return []
        }
    }
    
    private func calculateProjectedOverspend() -> Decimal {
        let currentSpending = budgets.reduce(0) { $0 + getCurrentSpending(for: $1) }
        let totalBudget = budgets.reduce(0) { $0 + $1.amount }
        
        // Simple projection based on current month progress
        let daysInMonth = Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 30
        let currentDay = Calendar.current.component(.day, from: Date())
        let projectionFactor = Decimal(daysInMonth) / Decimal(currentDay)
        
        return max(currentSpending * projectionFactor - totalBudget, 0)
    }
    
    // MARK: - Persistence
    
    private func loadBudgets() {
        // Load budgets from SwiftData in the future
        // For now, start with empty budgets - user will create their own
        budgets = []
    }
    
    private func saveBudgets() {
        // In a real implementation, this would save to SwiftData
        // For now, budgets are stored in memory
    }
    
    private func createSampleBudgets() {
        let categories = ["Manutención", "Educación", "Salud", "Entretenimiento", "Comida"]
        let amounts: [Decimal] = [2000, 1000, 500, 300, 800]
        
        for (index, category) in categories.enumerated() {
            createBudget(
                for: category,
                amount: amounts[index],
                period: .monthly,
                alertThresholds: [0.7, 0.85, 1.0]
            )
        }
    }
}

// MARK: - Data Models

struct Budget: Identifiable {
    let id: UUID
    let category: String
    let amount: Decimal
    let period: BudgetPeriod
    let alertThresholds: [Decimal]
    let createdAt: Date
    var isActive: Bool
    
    var displayName: String {
        "\(category) - \(NumberFormatter.currency.string(from: amount as NSDecimalNumber) ?? "$0")"
    }
}

enum BudgetPeriod: String, CaseIterable, Codable {
    case weekly = "Semanal"
    case monthly = "Mensual"
    case quarterly = "Trimestral"
    case yearly = "Anual"
    
    var displayName: String { self.rawValue }
}

enum BudgetStatus {
    case onTrack
    case warning
    case critical
    case exceeded
    
    var color: String {
        switch self {
        case .onTrack: return "green"
        case .warning: return "orange"
        case .critical: return "red"
        case .exceeded: return "red"
        }
    }
    
    var icon: String {
        switch self {
        case .onTrack: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .critical: return "exclamationmark.octagon.fill"
        case .exceeded: return "xmark.circle.fill"
        }
    }
}

struct BudgetAlert: Identifiable, Codable {
    let id: String
    let budgetId: UUID
    let threshold: Decimal
    var isTriggered: Bool
    let createdAt: Date
}

struct BudgetInsights {
    let totalBudgetedAmount: Decimal
    let totalSpent: Decimal
    let averageUtilization: Double
    let topOverSpendingCategories: [CategoryOverspend]
    let recommendations: [BudgetRecommendation]
    let monthlyTrend: [MonthlyBudgetTrend]
    let projectedOverspend: Decimal
    
    var utilizationPercentage: Double {
        totalBudgetedAmount > 0 ? Double(truncating: NSDecimalNumber(decimal: totalSpent / totalBudgetedAmount)) : 0
    }
}

struct CategoryOverspend: Identifiable {
    let id = UUID()
    let category: String
    let overspendAmount: Decimal
    let overspendPercentage: Double
}

struct BudgetRecommendation: Identifiable {
    let id = UUID()
    let type: RecommendationType
    let title: String
    let description: String
    let priority: Priority
    
    enum RecommendationType {
        case reduceSpending
        case monitorClosely
        case increaseBudget
        case reallocateFunds
    }
    
    enum Priority {
        case low, medium, high
        
        var color: String {
            switch self {
            case .low: return "blue"
            case .medium: return "orange"
            case .high: return "red"
            }
        }
    }
}

struct MonthlyBudgetTrend: Identifiable {
    let id = UUID()
    let month: Date
    let budgetedAmount: Decimal
    let spentAmount: Decimal
    let utilization: Double
}

// MARK: - Extensions
