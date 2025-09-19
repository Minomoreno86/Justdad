//
//  AllTransactionsView.swift
//  JustDad - Complete Transactions View
//
//  Professional view for displaying all financial transactions with advanced filtering and search
//

import SwiftUI
import Foundation

struct AllTransactionsView: View {
    @ObservedObject var viewModel: FinanceViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: FinancialEntry.ExpenseCategory? = nil
    @State private var selectedPeriod: FinancePeriod = .thisMonth
    @State private var sortOption: SortOption = .dateDescending
    @State private var showingFilters = false
    @State private var showingEditExpenseSheet = false
    @State private var editingExpense: FinancialEntry? = nil
    
    enum SortOption: String, CaseIterable {
        case dateDescending = "Más recientes"
        case dateAscending = "Más antiguos"
        case amountDescending = "Mayor monto"
        case amountAscending = "Menor monto"
        case category = "Por categoría"
        
        var icon: String {
            switch self {
            case .dateDescending: return "calendar.badge.clock"
            case .dateAscending: return "calendar"
            case .amountDescending: return "arrow.down.circle"
            case .amountAscending: return "arrow.up.circle"
            case .category: return "tag"
            }
        }
    }
    
    private var filteredExpenses: [FinancialEntry] {
        var expenses = viewModel.expenses
        
        // Filter by search text
        if !searchText.isEmpty {
            expenses = expenses.filter { expense in
                expense.title.localizedCaseInsensitiveContains(searchText) ||
                expense.category.displayName.localizedCaseInsensitiveContains(searchText) ||
                (expense.notes?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Filter by category
        if let selectedCategory = selectedCategory {
            expenses = expenses.filter { $0.category == selectedCategory }
        }
        
        // Filter by period
        expenses = expenses.filter { expense in
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
        
        // Sort expenses
        switch sortOption {
        case .dateDescending:
            expenses = expenses.sorted { $0.date > $1.date }
        case .dateAscending:
            expenses = expenses.sorted { $0.date < $1.date }
        case .amountDescending:
            expenses = expenses.sorted { $0.amount > $1.amount }
        case .amountAscending:
            expenses = expenses.sorted { $0.amount < $1.amount }
        case .category:
            expenses = expenses.sorted { $0.category.displayName < $1.category.displayName }
        }
        
        return expenses
    }
    
    private var totalAmount: Decimal {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Professional Background
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.05),
                        Color.purple.opacity(0.02),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with Summary
                    headerSection
                    
                    // Search and Filters
                    searchAndFiltersSection
                    
                    // Transactions List
                    transactionsListSection
                }
            }
            .navigationTitle("Todas las Transacciones")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingFilters.toggle() }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditExpenseSheet) {
            if let editingExpense = editingExpense {
                ProfessionalEditExpenseSheet(
                    viewModel: viewModel,
                    expense: editingExpense
                )
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Summary Cards
            HStack(spacing: 12) {
                SummaryCard(
                    title: "Total",
                    value: formatCurrency(totalAmount),
                    icon: "dollarsign.circle.fill",
                    color: .blue
                )
                
                SummaryCard(
                    title: "Transacciones",
                    value: "\(filteredExpenses.count)",
                    icon: "list.bullet",
                    color: .green
                )
                
                SummaryCard(
                    title: "Promedio",
                    value: formatCurrency(filteredExpenses.isEmpty ? 0 : totalAmount / Decimal(filteredExpenses.count)),
                    icon: "chart.bar.fill",
                    color: .orange
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - Search and Filters Section
    private var searchAndFiltersSection: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Buscar transacciones...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Quick Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Period Filter
                    FinanceFilterChip(
                        title: selectedPeriod.displayName,
                        isSelected: true,
                        icon: "calendar"
                    ) {
                        // TODO: Show period picker
                    }
                    
                    // Category Filter
                    if let selectedCategory = selectedCategory {
                        FinanceFilterChip(
                            title: selectedCategory.displayName,
                            isSelected: true,
                            icon: "tag.fill"
                        ) {
                            self.selectedCategory = nil
                        }
                    }
                    
                    // Sort Filter
                    FinanceFilterChip(
                        title: sortOption.rawValue,
                        isSelected: true,
                        icon: sortOption.icon
                    ) {
                        // TODO: Show sort picker
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Transactions List Section
    private var transactionsListSection: some View {
        VStack(spacing: 0) {
            if filteredExpenses.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(filteredExpenses, id: \.id) { expense in
                        TransactionRow(
                            expense: expense,
                            onEdit: {
                                editingExpense = expense
                                showingEditExpenseSheet = true
                            },
                            onDelete: {
                                Task {
                                    await viewModel.deleteExpense(expense)
                                }
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No hay transacciones")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("No se encontraron transacciones con los filtros aplicados")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Limpiar Filtros") {
                searchText = ""
                selectedCategory = nil
                selectedPeriod = .thisMonth
                sortOption = .dateDescending
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
    
    // MARK: - Helper Functions
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "es_US")
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }
}

// MARK: - Summary Card
struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Finance Filter Chip
struct FinanceFilterChip: View {
    let title: String
    let isSelected: Bool
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                if isSelected {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                }
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ? 
                LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing) :
                LinearGradient(colors: [Color(.secondarySystemBackground)], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Transaction Row
struct TransactionRow: View {
    let expense: FinancialEntry
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Category Icon
            Image(systemName: categoryIcon(for: expense.category))
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(
                    LinearGradient(
                        colors: [categoryColor(for: expense.category), categoryColor(for: expense.category).opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Text(expense.category.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let expenseType = expense.expenseType {
                        Text("• \(expenseType.displayName)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount and Actions
            VStack(alignment: .trailing, spacing: 8) {
                Text(formatCurrency(expense.amount))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(expense.amount < 0 ? .red : .green)
                
                HStack(spacing: 12) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
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
        case .other: return "dollarsign.circle.fill"
        }
    }
    
    private func categoryColor(for category: FinancialEntry.ExpenseCategory) -> Color {
        switch category {
        case .education: return .blue
        case .health: return .red
        case .food: return .green
        case .transportation: return .orange
        case .entertainment: return .purple
        case .clothing: return .pink
        case .gifts: return .yellow
        case .childSupport: return .orange
        case .other: return .gray
        }
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "es_US")
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }
}

#Preview {
    AllTransactionsView(viewModel: FinanceViewModel())
}
