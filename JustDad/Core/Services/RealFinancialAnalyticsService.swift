//
//  RealFinancialAnalyticsService.swift
//  JustDad - Professional Financial Management
//
//  Real financial analytics service using actual data from FinanceView
//

import Foundation
import SwiftData
import SwiftUI
import Combine

// MARK: - Real Financial Analytics Models
struct RealFinancialOverview {
    let totalIncome: Decimal
    let totalExpenses: Decimal
    let netIncome: Decimal
    let monthlyBudget: Decimal
    let budgetUtilization: Double
    let savingsRate: Double
    let expenseGrowth: Double
    let incomeGrowth: Double
}

struct RealCategoryBreakdown {
    let category: FinancialEntry.ExpenseCategory
    let amount: Decimal
    let percentage: Double
    let transactionCount: Int
    let averageAmount: Decimal
    let monthlyTrend: Double
    let budgetAllocation: Decimal
    let overBudget: Bool
}

struct RealMonthlyTrend {
    let month: String
    let income: Decimal
    let expenses: Decimal
    let netIncome: Decimal
    let savings: Decimal
}

struct RealBudgetAnalysis {
    let totalBudget: Decimal
    let totalSpent: Decimal
    let remainingBudget: Decimal
    let overBudgetCategories: [FinancialEntry.ExpenseCategory]
    let underBudgetCategories: [FinancialEntry.ExpenseCategory]
    let budgetEfficiency: Double
}

struct RealFinancialInsights {
    let topExpenseCategory: FinancialEntry.ExpenseCategory
    let biggestExpense: Decimal
    let averageDailySpending: Decimal
    let mostExpensiveDay: String
    let spendingPattern: String
    let recommendations: [String]
}

// MARK: - Real Financial Analytics Service
@MainActor
class RealFinancialAnalyticsService: ObservableObject {
    // MARK: - Published Properties
    @Published var overview: RealFinancialOverview?
    @Published var categoryBreakdown: [RealCategoryBreakdown] = []
    @Published var monthlyTrends: [RealMonthlyTrend] = []
    @Published var budgetAnalysis: RealBudgetAnalysis?
    @Published var insights: RealFinancialInsights?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let persistenceService = PersistenceService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Real Data Properties (from FinanceViewModel)
    private var realExpenses: [FinancialEntry] = []
    private var realMonthlyIncome: Decimal = 0
    private var realMonthlyBudget: Decimal = 0
    private var realCategoryBreakdown: [CategoryBreakdown] = []
    private var realTotalAmount: Decimal = 0
    private var realBalanceAmount: Decimal = 0
    
    // MARK: - Public Methods
    func generateRealAnalysis() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch all financial data
            let expenses = try persistenceService.fetch(FinancialEntry.self)
            let income = await getRealMonthlyIncome()
            
            // Generate all analyses
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.generateOverview(expenses: expenses, income: income) }
                group.addTask { await self.generateCategoryBreakdown(expenses: expenses, income: income) }
                group.addTask { await self.generateMonthlyTrends(expenses: expenses, income: income) }
                group.addTask { await self.generateBudgetAnalysis(expenses: expenses, income: income) }
                group.addTask { await self.generateInsights(expenses: expenses, income: income) }
            }
            
            isLoading = false
        } catch {
            errorMessage = "Error generando análisis: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - Real Data Integration
    func generateRealAnalysisWithData(
        expenses: [FinancialEntry],
        monthlyIncome: Decimal,
        monthlyBudget: Decimal,
        categoryBreakdown: [CategoryBreakdown],
        totalAmount: Decimal,
        balanceAmount: Decimal
    ) async {
        isLoading = true
        errorMessage = nil
        
        // Store real data
        self.realExpenses = expenses
        self.realMonthlyIncome = monthlyIncome
        self.realMonthlyBudget = monthlyBudget
        self.realCategoryBreakdown = categoryBreakdown
        self.realTotalAmount = totalAmount
        self.realBalanceAmount = balanceAmount
        
        
        // Generate all analyses with real data
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.generateOverview(expenses: expenses, income: monthlyIncome) }
            group.addTask { await self.generateCategoryBreakdown(expenses: expenses, income: monthlyIncome) }
            group.addTask { await self.generateMonthlyTrends(expenses: expenses, income: monthlyIncome) }
            group.addTask { await self.generateBudgetAnalysis(expenses: expenses, income: monthlyIncome) }
            group.addTask { await self.generateInsights(expenses: expenses, income: monthlyIncome) }
        }
        
        isLoading = false
    }
    
    // MARK: - Overview Generation
    private func generateOverview(expenses: [FinancialEntry], income: Decimal) async {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        
        let monthlyExpenses = expenses.filter { expense in
            let expenseMonth = Calendar.current.component(.month, from: expense.date)
            let expenseYear = Calendar.current.component(.year, from: expense.date)
            return expenseMonth == currentMonth && expenseYear == currentYear
        }
        
        let totalExpenses = monthlyExpenses.reduce(0) { $0 + $1.amount }
        let netIncome = income - totalExpenses
        
        // Use real budget if available, otherwise use income as budget (100% of income)
        let monthlyBudget = realMonthlyBudget > 0 ? realMonthlyBudget : income
        
        
        let budgetUtilization = monthlyBudget > 0 ? Double(truncating: NSDecimalNumber(decimal: totalExpenses / monthlyBudget)) : 0.0
        
        // Calculate savings rate
        let savingsRate = income > 0 ? Double(truncating: NSDecimalNumber(decimal: netIncome / income)) : 0.0
        
        // Calculate growth rates
        let expenseGrowth = await calculateExpenseGrowth(expenses: expenses)
        let incomeGrowth = await calculateIncomeGrowth(income: income)
        
        overview = RealFinancialOverview(
            totalIncome: income,
            totalExpenses: totalExpenses,
            netIncome: netIncome,
            monthlyBudget: monthlyBudget,
            budgetUtilization: budgetUtilization * 100,
            savingsRate: savingsRate * 100,
            expenseGrowth: expenseGrowth,
            incomeGrowth: incomeGrowth
        )
    }
    
    // MARK: - Category Breakdown Generation
    private func generateCategoryBreakdown(expenses: [FinancialEntry], income: Decimal) async {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        
        let monthlyExpenses = expenses.filter { expense in
            let expenseMonth = Calendar.current.component(.month, from: expense.date)
            let expenseYear = Calendar.current.component(.year, from: expense.date)
            return expenseMonth == currentMonth && expenseYear == currentYear
        }
        
        let totalExpenses = monthlyExpenses.reduce(0) { $0 + $1.amount }
        // Use real budget if available, otherwise use income as budget (100% of income)
        let monthlyBudget = realMonthlyBudget > 0 ? realMonthlyBudget : income
        let budgetPerCategory = monthlyBudget / Decimal(FinancialEntry.ExpenseCategory.allCases.count)
        
        var breakdown: [RealCategoryBreakdown] = []
        
        for category in FinancialEntry.ExpenseCategory.allCases {
            let categoryExpenses = monthlyExpenses.filter { $0.category == category }
            let categoryAmount = categoryExpenses.reduce(0) { $0 + $1.amount }
            let percentage = totalExpenses > 0 ? Double(truncating: NSDecimalNumber(decimal: categoryAmount / totalExpenses)) : 0.0
            let averageAmount = categoryExpenses.count > 0 ? categoryAmount / Decimal(categoryExpenses.count) : 0
            
            // Calculate monthly trend
            let monthlyTrend = await calculateCategoryTrend(expenses: expenses, category: category)
            
            // Check if over budget
            let overBudget = categoryAmount > budgetPerCategory
            
            breakdown.append(RealCategoryBreakdown(
                category: category,
                amount: categoryAmount,
                percentage: percentage * 100,
                transactionCount: categoryExpenses.count,
                averageAmount: averageAmount,
                monthlyTrend: monthlyTrend,
                budgetAllocation: budgetPerCategory,
                overBudget: overBudget
            ))
        }
        
        categoryBreakdown = breakdown.sorted { $0.amount > $1.amount }
    }
    
    // MARK: - Monthly Trends Generation
    private func generateMonthlyTrends(expenses: [FinancialEntry], income: Decimal) async {
        let calendar = Calendar.current
        let currentDate = Date()
        
        var trends: [RealMonthlyTrend] = []
        
        // Generate trends for last 6 months
        for i in 0..<6 {
            let monthDate = calendar.date(byAdding: .month, value: -i, to: currentDate) ?? currentDate
            let month = calendar.component(.month, from: monthDate)
            let year = calendar.component(.year, from: monthDate)
            
            let monthExpenses = expenses.filter { expense in
                let expenseMonth = calendar.component(.month, from: expense.date)
                let expenseYear = calendar.component(.year, from: expense.date)
                return expenseMonth == month && expenseYear == year
            }
            
            let monthExpensesTotal = monthExpenses.reduce(0) { $0 + $1.amount }
            let monthNetIncome = income - monthExpensesTotal
            let monthSavings = max(0, monthNetIncome)
            
            let monthName = DateFormatter().monthSymbols[month - 1]
            
            trends.append(RealMonthlyTrend(
                month: "\(monthName) \(year)",
                income: income,
                expenses: monthExpensesTotal,
                netIncome: monthNetIncome,
                savings: monthSavings
            ))
        }
        
        monthlyTrends = trends.reversed()
    }
    
    // MARK: - Budget Analysis Generation
    private func generateBudgetAnalysis(expenses: [FinancialEntry], income: Decimal) async {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        
        let monthlyExpenses = expenses.filter { expense in
            let expenseMonth = Calendar.current.component(.month, from: expense.date)
            let expenseYear = Calendar.current.component(.year, from: expense.date)
            return expenseMonth == currentMonth && expenseYear == currentYear
        }
        
        // Use real budget if available, otherwise use income as budget (100% of income)
        let totalBudget = realMonthlyBudget > 0 ? realMonthlyBudget : income
        let totalSpent = monthlyExpenses.reduce(0) { $0 + $1.amount }
        let remainingBudget = max(0, totalBudget - totalSpent)
        
        let budgetPerCategory = totalBudget / Decimal(FinancialEntry.ExpenseCategory.allCases.count)
        
        var overBudgetCategories: [FinancialEntry.ExpenseCategory] = []
        var underBudgetCategories: [FinancialEntry.ExpenseCategory] = []
        
        for category in FinancialEntry.ExpenseCategory.allCases {
            let categoryExpenses = monthlyExpenses.filter { $0.category == category }
            let categoryAmount = categoryExpenses.reduce(0) { $0 + $1.amount }
            
            if categoryAmount > budgetPerCategory {
                overBudgetCategories.append(category)
            } else if categoryAmount < budgetPerCategory * 0.5 {
                underBudgetCategories.append(category)
            }
        }
        
        let budgetEfficiency = totalBudget > 0 ? Double(truncating: NSDecimalNumber(decimal: totalSpent / totalBudget)) : 0.0
        
        budgetAnalysis = RealBudgetAnalysis(
            totalBudget: totalBudget,
            totalSpent: totalSpent,
            remainingBudget: remainingBudget,
            overBudgetCategories: overBudgetCategories,
            underBudgetCategories: underBudgetCategories,
            budgetEfficiency: budgetEfficiency * 100
        )
    }
    
    // MARK: - Insights Generation
    private func generateInsights(expenses: [FinancialEntry], income: Decimal) async {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        
        let monthlyExpenses = expenses.filter { expense in
            let expenseMonth = Calendar.current.component(.month, from: expense.date)
            let expenseYear = Calendar.current.component(.year, from: expense.date)
            return expenseMonth == currentMonth && expenseYear == currentYear
        }
        
        // Find top expense category
        let categoryTotals = Dictionary(grouping: monthlyExpenses) { $0.category }
            .mapValues { expenses in expenses.reduce(0) { $0 + $1.amount } }
        
        let topCategory = categoryTotals.max { $0.value < $1.value }?.key ?? .other
        
        // Find biggest expense
        let biggestExpense = monthlyExpenses.max { $0.amount < $1.amount }?.amount ?? 0
        
        // Calculate average daily spending
        let daysInMonth = Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 30
        let totalExpenses = monthlyExpenses.reduce(0) { $0 + $1.amount }
        let averageDailySpending = totalExpenses / Decimal(daysInMonth)
        
        // Find most expensive day
        let dayTotals = Dictionary(grouping: monthlyExpenses) { expense in
            Calendar.current.component(.day, from: expense.date)
        }.mapValues { expenses in expenses.reduce(0) { $0 + $1.amount } }
        
        let mostExpensiveDay = dayTotals.max { $0.value < $1.value }?.key ?? 1
        let mostExpensiveDayStr = "Día \(mostExpensiveDay)"
        
        // Analyze spending pattern
        let spendingPattern = analyzeSpendingPattern(expenses: monthlyExpenses)
        
        // Generate recommendations
        let recommendations = generateRecommendations(
            categoryBreakdown: categoryBreakdown,
            budgetAnalysis: budgetAnalysis,
            spendingPattern: spendingPattern
        )
        
        insights = RealFinancialInsights(
            topExpenseCategory: topCategory,
            biggestExpense: biggestExpense,
            averageDailySpending: averageDailySpending,
            mostExpensiveDay: mostExpensiveDayStr,
            spendingPattern: spendingPattern,
            recommendations: recommendations
        )
    }
    
    // MARK: - Helper Methods
    private func getRealMonthlyIncome() async -> Decimal {
        // Use real data if available, otherwise fetch from persistence
        if realMonthlyIncome > 0 {
            return realMonthlyIncome
        }
        
        // Fallback to default value
        return 5000.0
    }
    
    private func calculateExpenseGrowth(expenses: [FinancialEntry]) async -> Double {
        let calendar = Calendar.current
        let currentDate = Date()
        
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        
        let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        let prevMonth = calendar.component(.month, from: previousMonth)
        let prevYear = calendar.component(.year, from: previousMonth)
        
        let currentExpenses = expenses.filter { expense in
            let expenseMonth = calendar.component(.month, from: expense.date)
            let expenseYear = calendar.component(.year, from: expense.date)
            return expenseMonth == currentMonth && expenseYear == currentYear
        }
        
        let previousExpenses = expenses.filter { expense in
            let expenseMonth = calendar.component(.month, from: expense.date)
            let expenseYear = calendar.component(.year, from: expense.date)
            return expenseMonth == prevMonth && expenseYear == prevYear
        }
        
        let currentTotal = currentExpenses.reduce(0) { $0 + $1.amount }
        let previousTotal = previousExpenses.reduce(0) { $0 + $1.amount }
        
        guard previousTotal > 0 else { return 0.0 }
        return Double(truncating: NSDecimalNumber(decimal: (currentTotal - previousTotal) / previousTotal)) * 100
    }
    
    private func calculateIncomeGrowth(income: Decimal) async -> Double {
        // For now, return 0 as we don't have historical income data
        return 0.0
    }
    
    private func calculateCategoryTrend(expenses: [FinancialEntry], category: FinancialEntry.ExpenseCategory) async -> Double {
        let calendar = Calendar.current
        let currentDate = Date()
        
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        
        let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        let prevMonth = calendar.component(.month, from: previousMonth)
        let prevYear = calendar.component(.year, from: previousMonth)
        
        let currentExpenses = expenses.filter { expense in
            let expenseMonth = calendar.component(.month, from: expense.date)
            let expenseYear = calendar.component(.year, from: expense.date)
            return expenseMonth == currentMonth && expenseYear == currentYear && expense.category == category
        }
        
        let previousExpenses = expenses.filter { expense in
            let expenseMonth = calendar.component(.month, from: expense.date)
            let expenseYear = calendar.component(.year, from: expense.date)
            return expenseMonth == prevMonth && expenseYear == prevYear && expense.category == category
        }
        
        let currentTotal = currentExpenses.reduce(0) { $0 + $1.amount }
        let previousTotal = previousExpenses.reduce(0) { $0 + $1.amount }
        
        guard previousTotal > 0 else { return 0.0 }
        return Double(truncating: NSDecimalNumber(decimal: (currentTotal - previousTotal) / previousTotal)) * 100
    }
    
    private func analyzeSpendingPattern(expenses: [FinancialEntry]) -> String {
        let totalExpenses = expenses.reduce(0) { $0 + $1.amount }
        
        if totalExpenses == 0 {
            return "Sin gastos registrados"
        }
        
        let categoryCount = Set(expenses.map { $0.category }).count
        let totalCategories = FinancialEntry.ExpenseCategory.allCases.count
        
        if categoryCount == 1 {
            return "Gastos concentrados en una categoría"
        } else if categoryCount < totalCategories / 2 {
            return "Gastos concentrados en pocas categorías"
        } else {
            return "Gastos distribuidos en múltiples categorías"
        }
    }
    
    private func generateRecommendations(
        categoryBreakdown: [RealCategoryBreakdown],
        budgetAnalysis: RealBudgetAnalysis?,
        spendingPattern: String
    ) -> [String] {
        var recommendations: [String] = []
        
        // Budget recommendations
        if let budget = budgetAnalysis {
            if budget.budgetEfficiency > 90 {
                recommendations.append("¡Excelente control presupuestario! Mantén este nivel de disciplina.")
            } else if budget.budgetEfficiency > 70 {
                recommendations.append("Buen control presupuestario. Considera optimizar algunos gastos.")
            } else {
                recommendations.append("Revisa tu presupuesto. Estás gastando más de lo planificado.")
            }
            
            if !budget.overBudgetCategories.isEmpty {
                recommendations.append("Categorías sobre presupuesto: \(budget.overBudgetCategories.map { $0.displayName }.joined(separator: ", "))")
            }
        }
        
        // Category recommendations
        let topCategories = categoryBreakdown.prefix(3)
        if let topCategory = topCategories.first {
            recommendations.append("Tu mayor gasto es en \(topCategory.category.displayName) (\(String(format: "%.1f", topCategory.percentage))%)")
        }
        
        // Spending pattern recommendations
        if spendingPattern.contains("concentrados") {
            recommendations.append("Considera diversificar tus gastos para un mejor balance financiero.")
        }
        
        if recommendations.isEmpty {
            recommendations.append("¡Excelente gestión financiera! Mantén tus buenas prácticas.")
        }
        
        return recommendations
    }
}

// MARK: - Extensions
// Note: displayName is already defined in CoreDataModels.swift
