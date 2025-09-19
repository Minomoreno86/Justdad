//
//  FinanceViewModel.swift
//  JustDad - Professional Financial Management
//
//  Advanced ViewModel for financial data management with SwiftData integration
//

import Foundation
import SwiftData
import Combine
import SwiftUI

// MARK: - Loading State and Analytics Service are already defined in the project

// MARK: - Financial Entry Model is already defined in CoreDataModels.swift

// MARK: - Finance ViewModel
@MainActor
class FinanceViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var expenses: [FinancialEntry] = []
    @Published var loadingState: LoadingState = .idle
    @Published var errorMessage: String?
    @Published var selectedPeriod: FinancePeriod = .thisMonth
    @Published var totalAmount: Decimal = 0
    @Published var monthlyTrend: TrendDirection = .neutral
    @Published var categoryBreakdown: [CategoryBreakdown] = []
    @Published var recentExpenses: [FinancialEntry] = []
    @Published var monthlyBudget: Decimal = 0
    @Published var monthlyIncome: Decimal = 0
    @Published var budgetProgress: Double = 0.0
    @Published var showingNewExpenseSheet = false
    @Published var showingEditExpenseSheet = false
    @Published var editingExpense: FinancialEntry? = nil
    @Published var selectedCategory: FinancialEntry.ExpenseCategory? = nil
    
    // MARK: - Private Properties
    private let persistenceService = PersistenceService.shared
    private let analyticsService = AnalyticsService.shared
    private let financialNotificationService = FinancialNotificationService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var filteredExpenses: [FinancialEntry] {
        return expenses.filter { expense in
            switch selectedPeriod {
            case .thisWeek:
                return Calendar.current.isDate(expense.date, equalTo: Date(), toGranularity: .weekOfYear)
            case .thisMonth:
                return Calendar.current.isDate(expense.date, equalTo: Date(), toGranularity: .month)
            case .thisYear:
                return Calendar.current.isDate(expense.date, equalTo: Date(), toGranularity: .year)
            case .custom(let startDate, let endDate):
                return expense.date >= startDate && expense.date <= endDate
            }
        }
    }
    
    var totalExpenses: Decimal {
        return filteredExpenses.reduce(0) { $0 + $1.amount }
    }
    
    var averageExpense: Decimal {
        guard !filteredExpenses.isEmpty else { return 0 }
        return totalExpenses / Decimal(filteredExpenses.count)
    }
    
    var topCategory: FinancialEntry.ExpenseCategory? {
        let categoryTotals = Dictionary(grouping: filteredExpenses, by: { $0.category })
            .mapValues { expenses in
                expenses.reduce(0) { $0 + $1.amount }
            }
        return categoryTotals.max(by: { $0.value < $1.value })?.key
    }
    
    // MARK: - Initialization
    init() {
        loadExpenses()
        setupPeriodObserver()
    }
    
    // MARK: - Data Loading
    func loadExpenses() {
        loadingState = .loading
        errorMessage = nil
        
        Task {
            do {
                let allExpenses = try persistenceService.fetch(FinancialEntry.self)
                
                await MainActor.run {
                    self.expenses = allExpenses.sorted { $0.date > $1.date }
                    self.recentExpenses = Array(allExpenses.prefix(5))
                    self.calculateFinancialMetrics()
                    self.loadingState = .success
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Error al cargar gastos: \(error.localizedDescription)"
                    self.loadingState = .error
                }
            }
        }
    }
    
    func refreshExpenses() async {
        loadingState = .loading
        errorMessage = nil
        
        do {
            let allExpenses = try persistenceService.fetch(FinancialEntry.self)
            
            self.expenses = allExpenses.sorted { $0.date > $1.date }
            self.recentExpenses = Array(allExpenses.prefix(5))
            self.calculateFinancialMetrics()
            self.loadingState = .success
        } catch {
            self.errorMessage = "Error al actualizar gastos: \(error.localizedDescription)"
            self.loadingState = .error
        }
    }
    
    // MARK: - CRUD Operations
    func addExpense(_ expense: FinancialEntry) async {
        loadingState = .loading
        errorMessage = nil
        
        do {
            try await persistenceService.save(expense)
            
            // Reload all expenses to ensure data consistency and update all metrics
            let allExpenses = try persistenceService.fetch(FinancialEntry.self)
            
            await MainActor.run {
                self.expenses = allExpenses.sorted { $0.date > $1.date }
                self.recentExpenses = Array(allExpenses.prefix(5))
                self.calculateFinancialMetrics()
                self.loadingState = .success
            }
            
            // Track analytics
            // TODO: Implement analytics tracking when available
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Error al guardar gasto: \(error.localizedDescription)"
                self.loadingState = .error
            }
        }
    }
    
    func updateExpense(_ expense: FinancialEntry) async {
        loadingState = .loading
        errorMessage = nil
        
        do {
            // Update in SwiftData
            expense.updatedAt = Date()
            try persistenceService.modelContext.save()
            
            // Reload all expenses to ensure data consistency and update all metrics
            let allExpenses = try persistenceService.fetch(FinancialEntry.self)
            
            await MainActor.run {
                self.expenses = allExpenses.sorted { $0.date > $1.date }
                self.recentExpenses = Array(allExpenses.prefix(5))
                self.calculateFinancialMetrics()
                self.loadingState = .success
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Error al actualizar gasto: \(error.localizedDescription)"
                self.loadingState = .error
            }
        }
    }
    
    func deleteExpense(_ expense: FinancialEntry) async {
        loadingState = .loading
        errorMessage = nil
        
        do {
            try await persistenceService.delete(expense)
            
            // Reload all expenses to ensure data consistency and update all metrics
            let allExpenses = try persistenceService.fetch(FinancialEntry.self)
            
            await MainActor.run {
                self.expenses = allExpenses.sorted { $0.date > $1.date }
                self.recentExpenses = Array(allExpenses.prefix(5))
                self.calculateFinancialMetrics()
                self.loadingState = .success
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Error al eliminar gasto: \(error.localizedDescription)"
                self.loadingState = .error
            }
        }
    }
    
    // MARK: - Financial Calculations
    private func calculateFinancialMetrics() {
        totalAmount = totalExpenses
        calculateMonthlyTrend()
        calculateCategoryBreakdown()
        calculateBudgetProgress()
    }
    
    private func calculateMonthlyTrend() {
        let calendar = Calendar.current
        let now = Date()
        
        guard let thisMonth = calendar.date(byAdding: .month, value: 0, to: now),
              let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) else {
            monthlyTrend = .neutral
            return
        }
        
        let thisMonthExpenses = expenses.filter { 
            calendar.isDate($0.date, equalTo: thisMonth, toGranularity: .month) 
        }
        let lastMonthExpenses = expenses.filter { 
            calendar.isDate($0.date, equalTo: lastMonth, toGranularity: .month) 
        }
        
        let thisMonthTotal = thisMonthExpenses.reduce(0) { $0 + $1.amount }
        let lastMonthTotal = lastMonthExpenses.reduce(0) { $0 + $1.amount }
        
        if thisMonthTotal > lastMonthTotal {
            monthlyTrend = .up
        } else if thisMonthTotal < lastMonthTotal {
            monthlyTrend = .down
        } else {
            monthlyTrend = .neutral
        }
    }
    
    private func calculateCategoryBreakdown() {
        let categoryTotals = Dictionary(grouping: filteredExpenses, by: { $0.category })
            .mapValues { expenses in
                expenses.reduce(0) { $0 + $1.amount }
            }
        
        categoryBreakdown = categoryTotals.map { (category, total) in
            CategoryBreakdown(
                category: category,
                total: total,
                percentage: totalAmount > 0 ? Double(truncating: NSDecimalNumber(decimal: (total / totalAmount) * 100)) : 0,
                count: filteredExpenses.filter { $0.category == category }.count
            )
        }.sorted { $0.total > $1.total }
    }
    
    private func calculateBudgetProgress() {
        guard monthlyBudget > 0 else {
            budgetProgress = 0.0
            return
        }
        
        let currentMonthExpenses = expenses.filter { 
            Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month) 
        }.reduce(0) { $0 + $1.amount }
        
        budgetProgress = min(Double(truncating: NSDecimalNumber(decimal: currentMonthExpenses / monthlyBudget)), 1.0)
    }
    
    // MARK: - Period Management
    func setPeriod(_ period: FinancePeriod) {
        selectedPeriod = period
        calculateFinancialMetrics()
    }
    
    private func setupPeriodObserver() {
        $selectedPeriod
            .sink { [weak self] _ in
                self?.calculateFinancialMetrics()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Budget Management
    func setMonthlyBudget(_ budget: Decimal) {
        monthlyBudget = budget
        calculateBudgetProgress()
    }
    
    // MARK: - Income Management
    func setMonthlyIncome(_ income: Decimal) {
        monthlyIncome = income
    }
    
    // MARK: - Category Management
    func showNewExpenseSheet(for category: FinancialEntry.ExpenseCategory? = nil) {
        selectedCategory = category
        showingNewExpenseSheet = true
    }
    
    func hideNewExpenseSheet() {
        showingNewExpenseSheet = false
        selectedCategory = nil
    }
    
    func showEditExpenseSheet() {
        showingEditExpenseSheet = true
    }
    
    func hideEditExpenseSheet() {
        showingEditExpenseSheet = false
        editingExpense = nil
    }
    
    // MARK: - Financial Calculations
    var extrasAmount: Decimal {
        // Calculate extras as sum of all non-childSupport categories
        return filteredExpenses
            .filter { $0.category != .childSupport }
            .reduce(0) { $0 + $1.amount }
    }
    
    var childSupportAmount: Decimal {
        return filteredExpenses
            .filter { $0.category == .childSupport }
            .reduce(0) { $0 + $1.amount }
    }
    
    var balanceAmount: Decimal {
        return monthlyIncome - totalAmount
    }
    
    // MARK: - Export Functions
    func exportToCSV() async throws -> URL {
        let csvData = generateCSVData()
        return try saveToDocuments(data: csvData, filename: "expenses.csv")
    }
    
    func exportToPDF() async throws -> URL {
        let pdfData = try await generatePDFData()
        return try saveToDocuments(data: pdfData, filename: "expenses.pdf")
    }
    
    private func generateCSVData() -> Data {
        var csvString = "Fecha,Descripción,Categoría,Monto,Notas\n"
        
        for expense in filteredExpenses {
            let dateString = DateFormatter.financeCsvFormatter.string(from: expense.date)
            let amountString = String(format: "%.2f", Double(truncating: NSDecimalNumber(decimal: expense.amount)))
            let notes = expense.notes?.replacingOccurrences(of: ",", with: ";") ?? ""
            
            csvString += "\(dateString),\(expense.title),\(expense.category.displayName),\(amountString),\(notes)\n"
        }
        
        return csvString.data(using: .utf8) ?? Data()
    }
    
    private func generatePDFData() async throws -> Data {
        // TODO: Implement PDF generation
        return Data()
    }
    
    private func saveToDocuments(data: Data, filename: String) throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(filename)
        try data.write(to: fileURL)
        return fileURL
    }
    
    // MARK: - Financial Notifications
    func checkBudgetAlerts() {
        guard monthlyBudget > 0 else { return }
        
        // Check overall budget
        let budgetPercentage = Double(truncating: (totalAmount / monthlyBudget) as NSNumber)
        
        if budgetPercentage >= 1.0 {
            // Budget exceeded
            financialNotificationService.scheduleBudgetAlert(
                category: "Presupuesto General",
                spent: totalAmount,
                budget: monthlyBudget,
                threshold: .exceeded
            )
        } else if budgetPercentage >= 0.90 {
            // Critical threshold
            financialNotificationService.scheduleBudgetAlert(
                category: "Presupuesto General",
                spent: totalAmount,
                budget: monthlyBudget,
                threshold: .critical
            )
        } else if budgetPercentage >= 0.75 {
            // Warning threshold
            financialNotificationService.scheduleBudgetAlert(
                category: "Presupuesto General",
                spent: totalAmount,
                budget: monthlyBudget,
                threshold: .warning
            )
        }
        
        // Check category-specific budgets
        checkCategoryBudgetAlerts()
    }
    
    private func checkCategoryBudgetAlerts() {
        guard monthlyBudget > 0 else { return }
        
        let budgetPerCategory = monthlyBudget / Decimal(FinancialEntry.ExpenseCategory.allCases.count)
        
        for breakdown in categoryBreakdown {
            let categoryPercentage = Double(truncating: (breakdown.total / budgetPerCategory) as NSNumber)
            
            if categoryPercentage >= 1.0 {
                financialNotificationService.scheduleBudgetAlert(
                    category: breakdown.category.displayName,
                    spent: breakdown.total,
                    budget: budgetPerCategory,
                    threshold: .exceeded
                )
            } else if categoryPercentage >= 0.90 {
                financialNotificationService.scheduleBudgetAlert(
                    category: breakdown.category.displayName,
                    spent: breakdown.total,
                    budget: budgetPerCategory,
                    threshold: .critical
                )
            } else if categoryPercentage >= 0.75 {
                financialNotificationService.scheduleBudgetAlert(
                    category: breakdown.category.displayName,
                    spent: breakdown.total,
                    budget: budgetPerCategory,
                    threshold: .warning
                )
            }
        }
    }
    
    func scheduleFinancialReminders() {
        // Schedule daily spending reminder
        financialNotificationService.scheduleSpendingReminder()
        
        // Schedule weekly report
        financialNotificationService.scheduleWeeklyReport()
        
        // Schedule monthly summary
        financialNotificationService.scheduleMonthlySummary()
    }
    
    func scheduleSavingsGoalReminder(goalName: String, targetAmount: Decimal) {
        let currentSavings = monthlyIncome - totalAmount
        financialNotificationService.scheduleSavingsGoalReminder(
            goalName: goalName,
            currentAmount: currentSavings,
            targetAmount: targetAmount
        )
    }
    
    func scheduleBillReminder(billName: String, dueDate: Date, amount: Decimal) {
        financialNotificationService.scheduleBillReminder(
            billName: billName,
            dueDate: dueDate,
            amount: amount
        )
    }
}

// MARK: - Supporting Types
enum FinancePeriod: CaseIterable {
    case thisWeek
    case thisMonth
    case thisYear
    case custom(Date, Date)
    
    static var allCases: [FinancePeriod] {
        return [.thisWeek, .thisMonth, .thisYear]
    }
    
    var displayName: String {
        switch self {
        case .thisWeek: return "Esta Semana"
        case .thisMonth: return "Este Mes"
        case .thisYear: return "Este Año"
        case .custom: return "Personalizado"
        }
    }
}

enum TrendDirection {
    case up, down, neutral
    
    var icon: String {
        switch self {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .neutral: return "minus"
        }
    }
    
    var color: Color {
        switch self {
        case .up: return .red
        case .down: return .green
        case .neutral: return .gray
        }
    }
}

struct CategoryBreakdown: Identifiable {
    let id = UUID()
    let category: FinancialEntry.ExpenseCategory
    let total: Decimal
    let percentage: Double
    let count: Int
}

// MARK: - Extensions
extension DateFormatter {
    static let financeCsvFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
