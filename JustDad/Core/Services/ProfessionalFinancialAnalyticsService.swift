//
//  ProfessionalFinancialAnalyticsService.swift
//  JustDad - Professional Financial Management
//
//  Advanced financial analytics service with accounting-level calculations
//

import Foundation
import SwiftData
import SwiftUI
import Combine

// MARK: - Financial Analytics Models
struct FinancialStatement {
    let period: String
    let income: Decimal
    let expenses: Decimal
    let netIncome: Decimal
    let cashFlow: Decimal
    let assets: Decimal
    let liabilities: Decimal
    let equity: Decimal
}

struct CategoryAnalysis {
    let category: FinancialEntry.ExpenseCategory
    let totalAmount: Decimal
    let percentage: Double
    let transactionCount: Int
    let averageAmount: Decimal
    let trend: FinancialTrendDirection
    let monthlyGrowth: Double
}

struct CashFlowAnalysis {
    let operatingCashFlow: Decimal
    let investingCashFlow: Decimal
    let financingCashFlow: Decimal
    let netCashFlow: Decimal
    let cashFlowMargin: Double
    let freeCashFlow: Decimal
}

struct ProfitabilityAnalysis {
    let grossProfitMargin: Double
    let operatingMargin: Double
    let netProfitMargin: Double
    let returnOnAssets: Double
    let returnOnEquity: Double
    let earningsPerPeriod: Decimal
}

struct LiquidityAnalysis {
    let currentRatio: Double
    let quickRatio: Double
    let cashRatio: Double
    let workingCapital: Decimal
    let daysSalesOutstanding: Double
}

struct BudgetAnalysis {
    let budgetedAmount: Decimal
    let actualAmount: Decimal
    let variance: Decimal
    let variancePercentage: Double
    let remainingBudget: Decimal
    let utilizationRate: Double
}

struct TrendAnalysis {
    let period: String
    let value: Decimal
    let change: Decimal
    let changePercentage: Double
    let movingAverage: Decimal
    let volatility: Double
}

struct FinancialHealthScore {
    let overallScore: Double
    let liquidityScore: Double
    let profitabilityScore: Double
    let efficiencyScore: Double
    let stabilityScore: Double
    let recommendations: [String]
}

// MARK: - Professional Financial Analytics Service
@MainActor
class ProfessionalFinancialAnalyticsService: ObservableObject {
    // MARK: - Published Properties
    @Published var financialStatement: FinancialStatement?
    @Published var categoryAnalysis: [CategoryAnalysis] = []
    @Published var cashFlowAnalysis: CashFlowAnalysis?
    @Published var profitabilityAnalysis: ProfitabilityAnalysis?
    @Published var liquidityAnalysis: LiquidityAnalysis?
    @Published var budgetAnalysis: [BudgetAnalysis] = []
    @Published var trendAnalysis: [TrendAnalysis] = []
    @Published var financialHealthScore: FinancialHealthScore?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let persistenceService = PersistenceService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    func generateCompleteAnalysis() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch all financial data
            let expenses = try persistenceService.fetch(FinancialEntry.self)
            
            // Generate all analyses
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.generateFinancialStatement(expenses: expenses) }
                group.addTask { await self.generateCategoryAnalysis(expenses: expenses) }
                group.addTask { await self.generateCashFlowAnalysis(expenses: expenses) }
                group.addTask { await self.generateProfitabilityAnalysis(expenses: expenses) }
                group.addTask { await self.generateLiquidityAnalysis(expenses: expenses) }
                group.addTask { await self.generateBudgetAnalysis(expenses: expenses) }
                group.addTask { await self.generateTrendAnalysis(expenses: expenses) }
                group.addTask { await self.generateFinancialHealthScore(expenses: expenses) }
            }
            
            isLoading = false
        } catch {
            errorMessage = "Error generando análisis financiero: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - Financial Statement Generation
    private func generateFinancialStatement(expenses: [FinancialEntry]) async {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        
        let monthlyExpenses = expenses.filter { expense in
            let expenseMonth = Calendar.current.component(.month, from: expense.date)
            let expenseYear = Calendar.current.component(.year, from: expense.date)
            return expenseMonth == currentMonth && expenseYear == currentYear
        }
        
        let totalExpenses = monthlyExpenses.reduce(0) { $0 + $1.amount }
        let totalIncome = await getMonthlyIncome()
        let netIncome = totalIncome - totalExpenses
        
        financialStatement = FinancialStatement(
            period: "\(currentMonth)/\(currentYear)",
            income: totalIncome,
            expenses: totalExpenses,
            netIncome: netIncome,
            cashFlow: netIncome,
            assets: totalIncome * 12, // Simplified calculation
            liabilities: totalExpenses * 12, // Simplified calculation
            equity: (totalIncome - totalExpenses) * 12
        )
    }
    
    // MARK: - Category Analysis Generation
    private func generateCategoryAnalysis(expenses: [FinancialEntry]) async {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        
        let monthlyExpenses = expenses.filter { expense in
            let expenseMonth = Calendar.current.component(.month, from: expense.date)
            let expenseYear = Calendar.current.component(.year, from: expense.date)
            return expenseMonth == currentMonth && expenseYear == currentYear
        }
        
        let totalAmount = monthlyExpenses.reduce(0) { $0 + $1.amount }
        
        var analysis: [CategoryAnalysis] = []
        
        for category in FinancialEntry.ExpenseCategory.allCases {
            let categoryExpenses = monthlyExpenses.filter { $0.category == category }
            let categoryTotal = categoryExpenses.reduce(0) { $0 + $1.amount }
            let percentage = totalAmount > 0 ? Double(truncating: NSDecimalNumber(decimal: categoryTotal / totalAmount)) : 0.0
            let averageAmount = categoryExpenses.count > 0 ? categoryTotal / Decimal(categoryExpenses.count) : 0
            
            // Calculate trend (simplified)
            let previousMonth = getPreviousMonthExpenses(expenses: expenses, category: category)
            let trend = calculateTrend(current: categoryTotal, previous: previousMonth)
            let monthlyGrowth = calculateMonthlyGrowth(current: categoryTotal, previous: previousMonth)
            
            analysis.append(CategoryAnalysis(
                category: category,
                totalAmount: categoryTotal,
                percentage: percentage * 100,
                transactionCount: categoryExpenses.count,
                averageAmount: averageAmount,
                trend: trend,
                monthlyGrowth: monthlyGrowth
            ))
        }
        
        categoryAnalysis = analysis.sorted { $0.totalAmount > $1.totalAmount }
    }
    
    // MARK: - Cash Flow Analysis Generation
    private func generateCashFlowAnalysis(expenses: [FinancialEntry]) async {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        
        let monthlyExpenses = expenses.filter { expense in
            let expenseMonth = Calendar.current.component(.month, from: expense.date)
            let expenseYear = Calendar.current.component(.year, from: expense.date)
            return expenseMonth == currentMonth && expenseYear == currentYear
        }
        
        let operatingExpenses = monthlyExpenses.filter { $0.category != .childSupport }
        let operatingCashFlow = await getMonthlyIncome() - operatingExpenses.reduce(0) { $0 + $1.amount }
        
        // Simplified calculations for demonstration
        let investingCashFlow: Decimal = 0 // No investment data available
        let financingCashFlow: Decimal = 0 // No financing data available
        let netCashFlow = operatingCashFlow + investingCashFlow + financingCashFlow
        
        let totalIncome = await getMonthlyIncome()
        let cashFlowMargin = totalIncome > 0 ? Double(truncating: NSDecimalNumber(decimal: netCashFlow / totalIncome)) : 0.0
        let freeCashFlow = netCashFlow // Simplified
        
        cashFlowAnalysis = CashFlowAnalysis(
            operatingCashFlow: operatingCashFlow,
            investingCashFlow: investingCashFlow,
            financingCashFlow: financingCashFlow,
            netCashFlow: netCashFlow,
            cashFlowMargin: cashFlowMargin * 100,
            freeCashFlow: freeCashFlow
        )
    }
    
    // MARK: - Profitability Analysis Generation
    private func generateProfitabilityAnalysis(expenses: [FinancialEntry]) async {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        
        let monthlyExpenses = expenses.filter { expense in
            let expenseMonth = Calendar.current.component(.month, from: expense.date)
            let expenseYear = Calendar.current.component(.year, from: expense.date)
            return expenseMonth == currentMonth && expenseYear == currentYear
        }
        
        let totalIncome = await getMonthlyIncome()
        let totalExpenses = monthlyExpenses.reduce(0) { $0 + $1.amount }
        let netIncome = totalIncome - totalExpenses
        
        // Calculate margins
        let grossProfitMargin = totalIncome > 0 ? Double(truncating: NSDecimalNumber(decimal: netIncome / totalIncome)) : 0.0
        let operatingMargin = totalIncome > 0 ? Double(truncating: NSDecimalNumber(decimal: netIncome / totalIncome)) : 0.0
        let netProfitMargin = totalIncome > 0 ? Double(truncating: NSDecimalNumber(decimal: netIncome / totalIncome)) : 0.0
        
        // Simplified ROA and ROE calculations
        let assets = totalIncome * 12 // Simplified
        let equity = netIncome * 12 // Simplified
        let returnOnAssets = assets > 0 ? Double(truncating: NSDecimalNumber(decimal: netIncome / assets)) : 0.0
        let returnOnEquity = equity > 0 ? Double(truncating: NSDecimalNumber(decimal: netIncome / equity)) : 0.0
        
        profitabilityAnalysis = ProfitabilityAnalysis(
            grossProfitMargin: grossProfitMargin * 100,
            operatingMargin: operatingMargin * 100,
            netProfitMargin: netProfitMargin * 100,
            returnOnAssets: returnOnAssets * 100,
            returnOnEquity: returnOnEquity * 100,
            earningsPerPeriod: netIncome
        )
    }
    
    // MARK: - Liquidity Analysis Generation
    private func generateLiquidityAnalysis(expenses: [FinancialEntry]) async {
        let totalIncome = await getMonthlyIncome()
        let monthlyExpenses = expenses.filter { expense in
            let expenseMonth = Calendar.current.component(.month, from: expense.date)
            let expenseYear = Calendar.current.component(.year, from: expense.date)
            return expenseMonth == expenseMonth && expenseYear == Calendar.current.component(.year, from: Date())
        }
        
        let totalExpenses = monthlyExpenses.reduce(0) { $0 + $1.amount }
        let workingCapital = totalIncome - totalExpenses
        
        // Simplified liquidity ratios
        let currentRatio = totalExpenses > 0 ? Double(truncating: NSDecimalNumber(decimal: totalIncome / totalExpenses)) : 0.0
        let quickRatio = currentRatio // Simplified
        let cashRatio = currentRatio // Simplified
        
        liquidityAnalysis = LiquidityAnalysis(
            currentRatio: currentRatio,
            quickRatio: quickRatio,
            cashRatio: cashRatio,
            workingCapital: workingCapital,
            daysSalesOutstanding: 0.0 // Not applicable for personal finance
        )
    }
    
    // MARK: - Budget Analysis Generation
    private func generateBudgetAnalysis(expenses: [FinancialEntry]) async {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        
        let monthlyExpenses = expenses.filter { expense in
            let expenseMonth = Calendar.current.component(.month, from: expense.date)
            let expenseYear = Calendar.current.component(.year, from: expense.date)
            return expenseMonth == currentMonth && expenseYear == currentYear
        }
        
        var analysis: [BudgetAnalysis] = []
        
        for category in FinancialEntry.ExpenseCategory.allCases {
            let categoryExpenses = monthlyExpenses.filter { $0.category == category }
            let actualAmount = categoryExpenses.reduce(0) { $0 + $1.amount }
            
            // Simplified budget calculation (10% of income per category)
            let budgetedAmount = await getMonthlyIncome() / Decimal(FinancialEntry.ExpenseCategory.allCases.count)
            let variance = actualAmount - budgetedAmount
            let variancePercentage = budgetedAmount > 0 ? Double(truncating: NSDecimalNumber(decimal: variance / budgetedAmount)) : 0.0
            let remainingBudget = max(0, budgetedAmount - actualAmount)
            let utilizationRate = budgetedAmount > 0 ? Double(truncating: NSDecimalNumber(decimal: actualAmount / budgetedAmount)) : 0.0
            
            analysis.append(BudgetAnalysis(
                budgetedAmount: budgetedAmount,
                actualAmount: actualAmount,
                variance: variance,
                variancePercentage: variancePercentage * 100,
                remainingBudget: remainingBudget,
                utilizationRate: utilizationRate * 100
            ))
        }
        
        budgetAnalysis = analysis
    }
    
    // MARK: - Trend Analysis Generation
    private func generateTrendAnalysis(expenses: [FinancialEntry]) async {
        let calendar = Calendar.current
        let currentDate = Date()
        
        var trends: [TrendAnalysis] = []
        
        // Generate trends for last 12 months
        for i in 0..<12 {
            let monthDate = calendar.date(byAdding: .month, value: -i, to: currentDate) ?? currentDate
            let month = calendar.component(.month, from: monthDate)
            let year = calendar.component(.year, from: monthDate)
            
            let monthExpenses = expenses.filter { expense in
                let expenseMonth = calendar.component(.month, from: expense.date)
                let expenseYear = calendar.component(.year, from: expense.date)
                return expenseMonth == month && expenseYear == year
            }
            
            let totalAmount = monthExpenses.reduce(0) { $0 + $1.amount }
            
            // Calculate change from previous month
            let previousMonthDate = calendar.date(byAdding: .month, value: -1, to: monthDate) ?? monthDate
            let previousMonth = calendar.component(.month, from: previousMonthDate)
            let previousYear = calendar.component(.year, from: previousMonthDate)
            
            let previousMonthExpenses = expenses.filter { expense in
                let expenseMonth = calendar.component(.month, from: expense.date)
                let expenseYear = calendar.component(.year, from: expense.date)
                return expenseMonth == previousMonth && expenseYear == previousYear
            }
            
            let previousAmount = previousMonthExpenses.reduce(0) { $0 + $1.amount }
            let change = totalAmount - previousAmount
            let changePercentage = previousAmount > 0 ? Double(truncating: NSDecimalNumber(decimal: change / previousAmount)) : 0.0
            
            trends.append(TrendAnalysis(
                period: "\(month)/\(year)",
                value: totalAmount,
                change: change,
                changePercentage: changePercentage * 100,
                movingAverage: totalAmount, // Simplified
                volatility: 0.0 // Simplified
            ))
        }
        
        trendAnalysis = trends.reversed()
    }
    
    // MARK: - Financial Health Score Generation
    private func generateFinancialHealthScore(expenses: [FinancialEntry]) async {
        let totalIncome = await getMonthlyIncome()
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        
        let monthlyExpenses = expenses.filter { expense in
            let expenseMonth = Calendar.current.component(.month, from: expense.date)
            let expenseYear = Calendar.current.component(.year, from: expense.date)
            return expenseMonth == currentMonth && expenseYear == currentYear
        }
        
        let totalExpenses = monthlyExpenses.reduce(0) { $0 + $1.amount }
        let netIncome = totalIncome - totalExpenses
        
        // Calculate individual scores (0-100)
        let liquidityScore = calculateLiquidityScore(income: totalIncome, expenses: totalExpenses)
        let profitabilityScore = calculateProfitabilityScore(income: totalIncome, expenses: totalExpenses)
        let efficiencyScore = calculateEfficiencyScore(expenses: monthlyExpenses)
        let stabilityScore = calculateStabilityScore(expenses: expenses)
        
        let overallScore = (liquidityScore + profitabilityScore + efficiencyScore + stabilityScore) / 4
        
        let recommendations = generateRecommendations(
            liquidityScore: liquidityScore,
            profitabilityScore: profitabilityScore,
            efficiencyScore: efficiencyScore,
            stabilityScore: stabilityScore
        )
        
        financialHealthScore = FinancialHealthScore(
            overallScore: overallScore,
            liquidityScore: liquidityScore,
            profitabilityScore: profitabilityScore,
            efficiencyScore: efficiencyScore,
            stabilityScore: stabilityScore,
            recommendations: recommendations
        )
    }
    
    // MARK: - Helper Methods
    private func getMonthlyIncome() async -> Decimal {
        // This would typically come from a user setting or income tracking
        // For now, return a default value
        return 5000.0
    }
    
    private func getPreviousMonthExpenses(expenses: [FinancialEntry], category: FinancialEntry.ExpenseCategory) -> Decimal {
        let calendar = Calendar.current
        let previousMonth = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        let month = calendar.component(.month, from: previousMonth)
        let year = calendar.component(.year, from: previousMonth)
        
        let previousExpenses = expenses.filter { expense in
            let expenseMonth = calendar.component(.month, from: expense.date)
            let expenseYear = calendar.component(.year, from: expense.date)
            return expenseMonth == month && expenseYear == year && expense.category == category
        }
        
        return previousExpenses.reduce(0) { $0 + $1.amount }
    }
    
    private func calculateTrend(current: Decimal, previous: Decimal) -> FinancialTrendDirection {
        if current > previous {
            return .up
        } else if current < previous {
            return .down
        } else {
            return .neutral
        }
    }
    
    private func calculateMonthlyGrowth(current: Decimal, previous: Decimal) -> Double {
        guard previous > 0 else { return 0.0 }
        return Double(truncating: NSDecimalNumber(decimal: (current - previous) / previous)) * 100
    }
    
    private func calculateLiquidityScore(income: Decimal, expenses: Decimal) -> Double {
        guard expenses > 0 else { return 100.0 }
        let ratio = Double(truncating: NSDecimalNumber(decimal: income / expenses))
        return min(100.0, max(0.0, ratio * 50))
    }
    
    private func calculateProfitabilityScore(income: Decimal, expenses: Decimal) -> Double {
        guard income > 0 else { return 0.0 }
        let margin = Double(truncating: NSDecimalNumber(decimal: (income - expenses) / income))
        return min(100.0, max(0.0, margin * 100))
    }
    
    private func calculateEfficiencyScore(expenses: [FinancialEntry]) -> Double {
        // Calculate based on expense diversity and consistency
        let categories = Set(expenses.map { $0.category }).count
        let totalCategories = FinancialEntry.ExpenseCategory.allCases.count
        return Double(categories) / Double(totalCategories) * 100
    }
    
    private func calculateStabilityScore(expenses: [FinancialEntry]) -> Double {
        // Calculate based on expense consistency over time
        let monthlyTotals = Dictionary(grouping: expenses) { expense in
            let calendar = Calendar.current
            let month = calendar.component(.month, from: expense.date)
            let year = calendar.component(.year, from: expense.date)
            return "\(month)/\(year)"
        }.mapValues { expenses in
            expenses.reduce(0) { $0 + $1.amount }
        }
        
        guard monthlyTotals.count > 1 else { return 50.0 }
        
        let values = Array(monthlyTotals.values)
        let average = values.reduce(0, +) / Decimal(values.count)
        let variance = values.map { pow(Double(truncating: NSDecimalNumber(decimal: $0 - average)), 2) }.reduce(0, +) / Double(values.count)
        let standardDeviation = sqrt(variance)
        let coefficientOfVariation = standardDeviation / Double(truncating: NSDecimalNumber(decimal: average))
        
        return max(0.0, 100.0 - (coefficientOfVariation * 100))
    }
    
    private func generateRecommendations(liquidityScore: Double, profitabilityScore: Double, efficiencyScore: Double, stabilityScore: Double) -> [String] {
        var recommendations: [String] = []
        
        if liquidityScore < 50 {
            recommendations.append("Considera aumentar tus ingresos o reducir gastos para mejorar tu liquidez")
        }
        
        if profitabilityScore < 50 {
            recommendations.append("Revisa tus gastos para mejorar tu margen de ganancia")
        }
        
        if efficiencyScore < 50 {
            recommendations.append("Diversifica tus gastos para una mejor distribución financiera")
        }
        
        if stabilityScore < 50 {
            recommendations.append("Mantén un patrón de gastos más consistente")
        }
        
        if recommendations.isEmpty {
            recommendations.append("¡Excelente salud financiera! Mantén tus buenas prácticas")
        }
        
        return recommendations
    }
}

// MARK: - Financial Trend Direction Enum
enum FinancialTrendDirection {
    case up, down, neutral
}
