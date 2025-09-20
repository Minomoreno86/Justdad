//
//  AdvancedFilterService.swift
//  JustDad - Advanced Filter Service
//
//  Professional service for managing advanced financial filters.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Filter Models
struct FinancialFilter: Codable {
    var searchText: String = ""
    var dateRange: DateRangeFilter = .all
    var amountRange: AmountRangeFilter = .all
    var categories: Set<FilterCategory> = []
    var expenseTypes: Set<ExpenseTypeFilter> = []
    var isActive: Bool = false
    
    var isEmpty: Bool {
        return searchText.isEmpty &&
               dateRange == .all &&
               amountRange == .all &&
               categories.isEmpty &&
               expenseTypes.isEmpty
    }
}

enum DateRangeFilter: String, CaseIterable, Identifiable, Codable {
    case all = "all"
    case today = "today"
    case thisWeek = "thisWeek"
    case thisMonth = "thisMonth"
    case lastMonth = "lastMonth"
    case thisYear = "thisYear"
    case lastYear = "lastYear"
    case custom = "custom"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .all: return "Todas las fechas"
        case .today: return "Hoy"
        case .thisWeek: return "Esta semana"
        case .thisMonth: return "Este mes"
        case .lastMonth: return "Mes pasado"
        case .thisYear: return "Este año"
        case .lastYear: return "Año pasado"
        case .custom: return "Rango personalizado"
        }
    }
    
    var dateRange: (start: Date, end: Date)? {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .all:
            return nil
        case .today:
            let start = calendar.startOfDay(for: now)
            let end = calendar.date(byAdding: .day, value: 1, to: start)!
            return (start, end)
        case .thisWeek:
            let start = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let end = calendar.date(byAdding: .weekOfYear, value: 1, to: start)!
            return (start, end)
        case .thisMonth:
            let start = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let end = calendar.date(byAdding: .month, value: 1, to: start)!
            return (start, end)
        case .lastMonth:
            let start = calendar.date(byAdding: .month, value: -1, to: now)!
            let monthStart = calendar.dateInterval(of: .month, for: start)?.start ?? start
            let end = calendar.date(byAdding: .month, value: 1, to: monthStart)!
            return (monthStart, end)
        case .thisYear:
            let start = calendar.dateInterval(of: .year, for: now)?.start ?? now
            let end = calendar.date(byAdding: .year, value: 1, to: start)!
            return (start, end)
        case .lastYear:
            let start = calendar.date(byAdding: .year, value: -1, to: now)!
            let yearStart = calendar.dateInterval(of: .year, for: start)?.start ?? start
            let end = calendar.date(byAdding: .year, value: 1, to: yearStart)!
            return (yearStart, end)
        case .custom:
            return nil // Will be set manually
        }
    }
}

enum AmountRangeFilter: String, CaseIterable, Identifiable, Codable {
    case all = "all"
    case under10 = "under10"
    case under50 = "under50"
    case under100 = "under100"
    case under500 = "under500"
    case over500 = "over500"
    case custom = "custom"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .all: return "Todos los montos"
        case .under10: return "Menos de $10"
        case .under50: return "Menos de $50"
        case .under100: return "Menos de $100"
        case .under500: return "Menos de $500"
        case .over500: return "Más de $500"
        case .custom: return "Rango personalizado"
        }
    }
    
    var amountRange: (min: Decimal?, max: Decimal?)? {
        switch self {
        case .all:
            return nil
        case .under10:
            return (nil, 10)
        case .under50:
            return (nil, 50)
        case .under100:
            return (nil, 100)
        case .under500:
            return (nil, 500)
        case .over500:
            return (500, nil)
        case .custom:
            return nil // Will be set manually
        }
    }
}

enum FilterCategory: Hashable, Identifiable, Codable {
    case defaultCategory(FinancialEntry.ExpenseCategory)
    case customCategory(CustomCategory)
    
    var id: String {
        switch self {
        case .defaultCategory(let category):
            return "default_\(category.rawValue)"
        case .customCategory(let category):
            return "custom_\(category.id.uuidString)"
        }
    }
    
    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case type
        case category
        case customCategoryId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "default":
            let category = try container.decode(FinancialEntry.ExpenseCategory.self, forKey: .category)
            self = .defaultCategory(category)
        case "custom":
            let customCategoryId = try container.decode(UUID.self, forKey: .customCategoryId)
            // For now, we'll create a placeholder CustomCategory
            // In a real implementation, you'd fetch this from the database
            let placeholder = CustomCategory(name: "placeholder", displayName: "Placeholder", icon: "tag", color: "gray")
            placeholder.id = customCategoryId
            self = .customCategory(placeholder)
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown FilterCategory type"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .defaultCategory(let category):
            try container.encode("default", forKey: .type)
            try container.encode(category, forKey: .category)
        case .customCategory(let category):
            try container.encode("custom", forKey: .type)
            try container.encode(category.id, forKey: .customCategoryId)
        }
    }
    
    var displayName: String {
        switch self {
        case .defaultCategory(let category):
            return category.displayName
        case .customCategory(let category):
            return category.displayName
        }
    }
    
    var icon: String {
        switch self {
        case .defaultCategory(let category):
            return categoryIcon(for: category)
        case .customCategory(let category):
            return category.systemIcon
        }
    }
    
    var color: Color {
        switch self {
        case .defaultCategory(let category):
            return categoryColor(for: category)
        case .customCategory(let category):
            return category.swiftUIColor
        }
    }
    
    private func categoryIcon(for category: FinancialEntry.ExpenseCategory) -> String {
        switch category {
        case .education: return "book.fill"
        case .health: return "cross.fill"
        case .food: return "fork.knife"
        case .transportation: return "car.fill"
        case .entertainment: return "gamecontroller.fill"
        case .clothing: return "tshirt.fill"
        case .gifts: return "gift.fill"
        case .childSupport: return "house.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    private func categoryColor(for category: FinancialEntry.ExpenseCategory) -> Color {
        switch category {
        case .education: return .blue
        case .health: return .red
        case .food: return .orange
        case .transportation: return .green
        case .entertainment: return .purple
        case .clothing: return .pink
        case .gifts: return .yellow
        case .childSupport: return .brown
        case .other: return .gray
        }
    }
}

enum ExpenseTypeFilter: String, CaseIterable, Identifiable, Codable {
    case all = "all"
    case fixed = "fixed"
    case variable = "variable"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .all: return "Todos los tipos"
        case .fixed: return "Gastos fijos"
        case .variable: return "Gastos variables"
        }
    }
}

// MARK: - Saved Filter
struct SavedFilter: Identifiable, Codable {
    let id: UUID
    let name: String
    let filter: FinancialFilter
    let createdAt: Date
    
    init(name: String, filter: FinancialFilter) {
        self.id = UUID()
        self.name = name
        self.filter = filter
        self.createdAt = Date()
    }
}

// MARK: - Advanced Filter Service
@MainActor
class AdvancedFilterService: ObservableObject {
    @Published var currentFilter = FinancialFilter()
    @Published var savedFilters: [SavedFilter] = []
    @Published var customDateRange: (start: Date, end: Date) = (Date(), Date())
    @Published var customAmountRange: (min: Decimal?, max: Decimal?) = (nil, nil)
    @Published var availableCategories: [FilterCategory] = []
    
    private let modelContext: ModelContext
    
    init() {
        self.modelContext = ModelContainerManager.shared.getContext() ?? ModelContext(try! ModelContainer(for: FinancialEntry.self, CustomCategory.self))
        loadSavedFilters()
        loadAvailableCategories()
    }
    
    // MARK: - Filter Application
    func applyFilter(to expenses: [FinancialEntry]) -> [FinancialEntry] {
        var filteredExpenses = expenses
        
        // Search text filter
        if !currentFilter.searchText.isEmpty {
            filteredExpenses = filteredExpenses.filter { expense in
                expense.title.localizedCaseInsensitiveContains(currentFilter.searchText) ||
                (expense.notes?.localizedCaseInsensitiveContains(currentFilter.searchText) ?? false)
            }
        }
        
        // Date range filter
        if let dateRange = getEffectiveDateRange() {
            filteredExpenses = filteredExpenses.filter { expense in
                expense.date >= dateRange.start && expense.date < dateRange.end
            }
        }
        
        // Amount range filter
        if let amountRange = getEffectiveAmountRange() {
            filteredExpenses = filteredExpenses.filter { expense in
                if let minAmount = amountRange.min, expense.amount < minAmount {
                    return false
                }
                if let maxAmount = amountRange.max, expense.amount > maxAmount {
                    return false
                }
                return true
            }
        }
        
        // Category filter
        if !currentFilter.categories.isEmpty {
            filteredExpenses = filteredExpenses.filter { expense in
                let expenseCategory = FilterCategory.defaultCategory(expense.category)
                let customCategory = expense.customCategory.map { FilterCategory.customCategory($0) }
                
                return currentFilter.categories.contains(expenseCategory) ||
                       (customCategory != nil && currentFilter.categories.contains(customCategory!))
            }
        }
        
        // Expense type filter
        if !currentFilter.expenseTypes.isEmpty && !currentFilter.expenseTypes.contains(.all) {
            filteredExpenses = filteredExpenses.filter { expense in
                guard let expenseType = expense.expenseType else { return false }
                
                switch expenseType {
                case .fixed:
                    return currentFilter.expenseTypes.contains(.fixed)
                case .variable:
                    return currentFilter.expenseTypes.contains(.variable)
                }
            }
        }
        
        return filteredExpenses
    }
    
    // MARK: - Filter Management
    func clearAllFilters() {
        currentFilter = FinancialFilter()
        customDateRange = (Date(), Date())
        customAmountRange = (nil, nil)
    }
    
    func resetToDefault() {
        currentFilter = FinancialFilter()
    }
    
    func saveCurrentFilter(as name: String) {
        let savedFilter = SavedFilter(name: name, filter: currentFilter)
        savedFilters.append(savedFilter)
        saveSavedFilters()
    }
    
    func loadSavedFilter(_ savedFilter: SavedFilter) {
        currentFilter = savedFilter.filter
    }
    
    func deleteSavedFilter(_ savedFilter: SavedFilter) {
        savedFilters.removeAll { $0.id == savedFilter.id }
        saveSavedFilters()
    }
    
    // MARK: - Helper Methods
    private func getEffectiveDateRange() -> (start: Date, end: Date)? {
        if currentFilter.dateRange == .custom {
            return customDateRange
        }
        return currentFilter.dateRange.dateRange
    }
    
    private func getEffectiveAmountRange() -> (min: Decimal?, max: Decimal?)? {
        if currentFilter.amountRange == .custom {
            return customAmountRange
        }
        return currentFilter.amountRange.amountRange
    }
    
    private func loadSavedFilters() {
        if let data = UserDefaults.standard.data(forKey: "saved_filters"),
           let filters = try? JSONDecoder().decode([SavedFilter].self, from: data) {
            savedFilters = filters
        }
    }
    
    private func saveSavedFilters() {
        if let data = try? JSONEncoder().encode(savedFilters) {
            UserDefaults.standard.set(data, forKey: "saved_filters")
        }
    }
    
    private func loadAvailableCategories() {
        var categories: [FilterCategory] = []
        
        // Add default categories
        for category in FinancialEntry.ExpenseCategory.allCases {
            categories.append(.defaultCategory(category))
        }
        
        // Add custom categories
        do {
            let fetchDescriptor = FetchDescriptor<CustomCategory>(predicate: #Predicate { $0.isActive })
            let customCategories = try modelContext.fetch(fetchDescriptor)
            for customCategory in customCategories {
                categories.append(.customCategory(customCategory))
            }
        } catch {
            print("Error loading custom categories: \(error)")
        }
        
        availableCategories = categories
    }
    
    // MARK: - Filter Statistics
    func getFilterStats(for expenses: [FinancialEntry]) -> FilterStats {
        let filteredCount = applyFilter(to: expenses).count
        let totalCount = expenses.count
        
        return FilterStats(
            totalExpenses: totalCount,
            filteredExpenses: filteredCount,
            isFiltered: !currentFilter.isEmpty
        )
    }
}

// MARK: - Filter Statistics
struct FilterStats {
    let totalExpenses: Int
    let filteredExpenses: Int
    let isFiltered: Bool
    
    var percentage: Double {
        guard totalExpenses > 0 else { return 0 }
        return Double(filteredExpenses) / Double(totalExpenses) * 100
    }
}
