//
//  FinancialAnalyticsView.swift
//  JustDad - Professional Financial Analytics
//
//  Advanced financial analytics with interactive charts, trends, and insights
//

import SwiftUI
import Charts
import Foundation

struct FinancialAnalyticsView: View {
    @StateObject private var viewModel = FinanceViewModel()
    @State private var selectedChartType: ChartType = .expenses
    @State private var selectedPeriod: AnalyticsPeriod = .month
    @State private var showingDetailedView = false
    @State private var selectedCategory: FinancialEntry.ExpenseCategory?
    
    enum ChartType: String, CaseIterable {
        case expenses = "Gastos"
        case categories = "Categorías"
        case trends = "Tendencias"
        case budget = "Presupuesto"
        
        var icon: String {
            switch self {
            case .expenses: return "creditcard.fill"
            case .categories: return "chart.pie.fill"
            case .trends: return "chart.line.uptrend.xyaxis"
            case .budget: return "target"
            }
        }
    }
    
    enum AnalyticsPeriod: String, CaseIterable {
        case week = "Semana"
        case month = "Mes"
        case quarter = "Trimestre"
        case year = "Año"
        
        var dateRange: DateInterval {
            let calendar = Calendar.current
            let now = Date()
            
            switch self {
            case .week:
                let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
                return DateInterval(start: startOfWeek, end: now)
            case .month:
                let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
                return DateInterval(start: startOfMonth, end: now)
            case .quarter:
                let quarter = calendar.component(.month, from: now) / 3
                let startOfQuarter = calendar.date(from: DateComponents(year: calendar.component(.year, from: now), month: quarter * 3 - 2, day: 1)) ?? now
                return DateInterval(start: startOfQuarter, end: now)
            case .year:
                let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
                return DateInterval(start: startOfYear, end: now)
            }
        }
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
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Professional Header
                        analyticsHeader
                        
                        // Chart Type Selector
                        chartTypeSelector
                        
                        // Period Selector
                        periodSelector
                        
                        // Main Analytics Content
                        analyticsContent
                        
                        // Financial Insights
                        financialInsights
                        
                        // Category Breakdown
                        categoryBreakdown
                        
                        // Bottom padding
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Analytics Financieros")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingDetailedView = true }) {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .foregroundColor(.blue)
                    }
                }
                #endif
            }
            .sheet(isPresented: $showingDetailedView) {
                DetailedFinancialReportView(viewModel: viewModel, period: selectedPeriod)
            }
        }
        .onAppear {
            if viewModel.expenses.isEmpty {
                viewModel.loadExpenses()
            }
        }
    }
    
    // MARK: - Analytics Header
    private var analyticsHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Análisis Financiero")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Insights profesionales de tus finanzas")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Período")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(selectedPeriod.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            
            // Quick Stats
            HStack(spacing: 16) {
                FinancialQuickStatCard(
                    title: "Gastos Totales",
                    value: formatCurrency(viewModel.totalAmount),
                    change: calculateExpenseChange(),
                    icon: "creditcard.fill",
                    color: .red
                )
                
                FinancialQuickStatCard(
                    title: "Categorías",
                    value: "\(viewModel.categoryBreakdown.count)",
                    change: nil,
                    icon: "chart.pie.fill",
                    color: .blue
                )
                
                FinancialQuickStatCard(
                    title: "Promedio Diario",
                    value: formatCurrency(calculateDailyAverage()),
                    change: nil,
                    icon: "calendar",
                    color: .green
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Chart Type Selector
    private var chartTypeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tipo de Análisis")
                .font(.headline)
                        .foregroundColor(.primary)
            
            HStack(spacing: 0) {
                ForEach(ChartType.allCases, id: \.self) { type in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedChartType = type
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: type.icon)
                                .font(.caption)
                            Text(type.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(selectedChartType == type ? .white : Color.adaptiveLabel)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedChartType == type ?
                            LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Period Selector
    private var periodSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Período de Análisis")
                .font(.headline)
                        .foregroundColor(.primary)
            
            HStack(spacing: 0) {
                ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedPeriod = period
                        }
                    }) {
                        Text(period.rawValue)
                            .font(.subheadline)
                            .foregroundColor(selectedPeriod == period ? .white : Color.adaptiveLabel)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                selectedPeriod == period ?
                                LinearGradient(colors: [Color.green, Color.blue], startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Analytics Content
    private var analyticsContent: some View {
        VStack(spacing: 16) {
            Text("Análisis Visual")
                .font(.headline)
                        .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Group {
                switch selectedChartType {
                case .expenses:
                    expensesChart
                case .categories:
                    categoriesChart
                case .trends:
                    trendsChart
                case .budget:
                    budgetChart
                }
            }
            .frame(height: 300)
            .padding(20)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Charts
    private var expensesChart: some View {
        Chart(filteredExpenses, id: \.id) { expense in
            BarMark(
                x: .value("Fecha", expense.date, unit: .day),
                y: .value("Monto", Double(truncating: NSDecimalNumber(decimal: expense.amount)))
            )
            .foregroundStyle(by: .value("Categoría", expense.category.displayName))
            .cornerRadius(4)
        }
        .chartForegroundStyleScale(range: categoryColors)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine()
                AxisValueLabel(format: .currency(code: "USD"))
            }
        }
    }
    
    private var categoriesChart: some View {
        Chart(categoryData, id: \.category) { data in
            SectorMark(
                angle: .value("Monto", data.amount),
                innerRadius: .ratio(0.3),
                angularInset: 2
            )
            .foregroundStyle(by: .value("Categoría", data.category))
            .opacity(0.8)
        }
        .chartForegroundStyleScale(range: categoryColors)
        .chartBackground { chartProxy in
            VStack {
                Text("Total")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(formatCurrency(Decimal(categoryData.reduce(0) { $0 + $1.amount })))
                    .font(.title2)
                    .fontWeight(.bold)
                        .foregroundColor(.primary)
            }
        }
    }
    
    private var trendsChart: some View {
        Chart(trendData, id: \.date) { data in
            LineMark(
                x: .value("Fecha", data.date),
                y: .value("Monto", data.amount)
            )
            .foregroundStyle(.blue)
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            
            AreaMark(
                x: .value("Fecha", data.date),
                y: .value("Monto", data.amount)
            )
            .foregroundStyle(.blue.opacity(0.1))
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine()
                AxisValueLabel(format: .currency(code: "USD"))
            }
        }
    }
    
    private var budgetChart: some View {
        Chart(budgetData, id: \.category) { data in
            BarMark(
                x: .value("Categoría", data.category),
                y: .value("Gastado", data.spent)
            )
            .foregroundStyle(.red.opacity(0.7))
            
            BarMark(
                x: .value("Categoría", data.category),
                y: .value("Presupuesto", data.budget)
            )
            .foregroundStyle(.green.opacity(0.7))
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine()
                AxisValueLabel(format: .currency(code: "USD"))
            }
        }
    }
    
    // MARK: - Financial Insights
    private var financialInsights: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Insights Inteligentes")
                .font(.headline)
                        .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(generateInsights(), id: \.id) { insight in
                    FinancialAnalyticsInsightCard(insight: insight)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Category Breakdown
    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Desglose por Categoría")
                .font(.headline)
                        .foregroundColor(.primary)
            
            ForEach(categoryData.sorted { $0.amount > $1.amount }, id: \.category) { data in
                CategoryBreakdownRow(
                    category: data.category,
                    amount: data.amount,
                    percentage: data.percentage,
                    color: categoryColor(for: data.category)
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Computed Properties
    private var filteredExpenses: [FinancialEntry] {
        let dateRange = selectedPeriod.dateRange
        return viewModel.expenses.filter { expense in
            dateRange.contains(expense.date)
        }
    }
    
    private var categoryData: [CategoryData] {
        let grouped = Dictionary(grouping: filteredExpenses, by: { $0.category })
        let total = filteredExpenses.reduce(0) { $0 + Double(truncating: NSDecimalNumber(decimal: $1.amount)) }
        
        return grouped.map { (category, expenses) in
            let amount = expenses.reduce(0) { $0 + Double(truncating: NSDecimalNumber(decimal: $1.amount)) }
            return CategoryData(
                category: category.displayName,
                amount: amount,
                percentage: total > 0 ? (amount / total) * 100 : 0
            )
        }
    }
    
    private var trendData: [TrendData] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredExpenses) { expense in
            calendar.startOfDay(for: expense.date)
        }
        
        return grouped.map { (date, expenses) in
            let amount = expenses.reduce(0) { $0 + Double(truncating: NSDecimalNumber(decimal: $1.amount)) }
            return TrendData(date: date, amount: amount)
        }.sorted { $0.date < $1.date }
    }
    
    private var budgetData: [BudgetData] {
        // Mock budget data - in real implementation, this would come from user settings
        return categoryData.map { data in
            BudgetData(
                category: data.category,
                spent: data.amount,
                budget: data.amount * 1.2 // 20% over spent amount as budget
            )
        }
    }
    
    private var categoryColors: [Color] {
        [.blue, .green, .orange, .purple, .red, .pink, .yellow, .cyan]
    }
    
    // MARK: - Helper Functions
    private func calculateExpenseChange() -> Double? {
        // Calculate percentage change from previous period
        let currentPeriod = filteredExpenses
        let previousPeriod = getPreviousPeriodExpenses()
        
        let currentTotal = currentPeriod.reduce(0) { $0 + Double(truncating: NSDecimalNumber(decimal: $1.amount)) }
        let previousTotal = previousPeriod.reduce(0) { $0 + Double(truncating: NSDecimalNumber(decimal: $1.amount)) }
        
        guard previousTotal > 0 else { return nil }
        return ((currentTotal - previousTotal) / previousTotal) * 100
    }
    
    private func getPreviousPeriodExpenses() -> [FinancialEntry] {
        let calendar = Calendar.current
        let now = Date()
        let dateRange: DateInterval
        
        switch selectedPeriod {
        case .week:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let previousWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: startOfWeek) ?? now
            let endOfPreviousWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            dateRange = DateInterval(start: previousWeek, end: endOfPreviousWeek)
        case .month:
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let previousMonth = calendar.date(byAdding: .month, value: -1, to: startOfMonth) ?? now
            let endOfPreviousMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            dateRange = DateInterval(start: previousMonth, end: endOfPreviousMonth)
        case .quarter:
            let quarter = calendar.component(.month, from: now) / 3
            let startOfQuarter = calendar.date(from: DateComponents(year: calendar.component(.year, from: now), month: quarter * 3 - 2, day: 1)) ?? now
            let previousQuarter = calendar.date(byAdding: .month, value: -3, to: startOfQuarter) ?? now
            let endOfPreviousQuarter = calendar.date(byAdding: .month, value: -3, to: now) ?? now
            dateRange = DateInterval(start: previousQuarter, end: endOfPreviousQuarter)
        case .year:
            let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
            let previousYear = calendar.date(byAdding: .year, value: -1, to: startOfYear) ?? now
            let endOfPreviousYear = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            dateRange = DateInterval(start: previousYear, end: endOfPreviousYear)
        }
        
        return viewModel.expenses.filter { dateRange.contains($0.date) }
    }
    
    private func calculateDailyAverage() -> Decimal {
        let days = Calendar.current.dateComponents([.day], from: selectedPeriod.dateRange.start, to: selectedPeriod.dateRange.end).day ?? 1
        let total = filteredExpenses.reduce(0) { $0 + $1.amount }
        return total / Decimal(days)
    }
    
    private func categoryColor(for category: String) -> Color {
        let colors: [String: Color] = [
            "Alimentación": .green,
            "Transporte": .blue,
            "Entretenimiento": .purple,
            "Salud": .red,
            "Educación": .orange,
            "Otros": .gray
        ]
        return colors[category] ?? .gray
    }
    
    private func generateInsights() -> [FinancialInsight] {
        var insights: [FinancialInsight] = []
        
        // Insight 1: Top spending category
        if let topCategory = categoryData.max(by: { $0.amount < $1.amount }) {
            insights.append(FinancialInsight(
                title: "Categoría Principal",
                description: "Gastas más en \(topCategory.category) con \(formatCurrency(Decimal(topCategory.amount)))",
                type: .info,
                icon: "chart.pie.fill"
            ))
        }
        
        // Insight 2: Spending trend
        if let change = calculateExpenseChange() {
            let trend = change > 0 ? "aumentó" : "disminuyó"
            insights.append(FinancialInsight(
                title: "Tendencia de Gastos",
                description: "Tus gastos \(trend) un \(String(format: "%.1f", abs(change)))% vs período anterior",
                type: change > 0 ? .warning : .success,
                icon: change > 0 ? "arrow.up.right" : "arrow.down.right"
            ))
        }
        
        // Insight 3: Daily average
        let dailyAvg = calculateDailyAverage()
        insights.append(FinancialInsight(
            title: "Promedio Diario",
            description: "Gastas en promedio \(formatCurrency(dailyAvg)) por día",
            type: .info,
            icon: "calendar"
        ))
        
        return insights
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "es_US")
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }
}

// MARK: - Supporting Views
struct FinancialQuickStatCard: View {
    let title: String
    let value: String
    let change: Double?
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
                if let change = change {
                    HStack(spacing: 4) {
                        Image(systemName: change > 0 ? "arrow.up" : "arrow.down")
                            .font(.caption)
                        Text("\(String(format: "%.1f", abs(change)))%")
                            .font(.caption)
                    }
                    .foregroundColor(change > 0 ? .red : .green)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                        .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct FinancialAnalyticsInsightCard: View {
    let insight: FinancialInsight
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: insight.icon)
                .font(.title2)
                .foregroundColor(insight.type.color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                        .foregroundColor(.primary)
                
                Text(insight.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct CategoryBreakdownRow: View {
    let category: String
    let amount: Double
    let percentage: Double
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(category)
                .font(.subheadline)
                        .foregroundColor(.primary)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(String(format: "%.2f", amount))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                        .foregroundColor(.primary)
                
                Text("\(String(format: "%.1f", percentage))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Data Models
struct CategoryData {
    let category: String
    let amount: Double
    let percentage: Double
}

struct TrendData {
    let date: Date
    let amount: Double
}

struct BudgetData {
    let category: String
    let spent: Double
    let budget: Double
}

struct FinancialInsight: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let type: InsightType
    let icon: String
    
    enum InsightType {
        case info, success, warning, error
        
        var color: Color {
            switch self {
            case .info: return .blue
            case .success: return .green
            case .warning: return .orange
            case .error: return .red
            }
        }
    }
}

// MARK: - Detailed Report View
struct DetailedFinancialReportView: View {
    @ObservedObject var viewModel: FinanceViewModel
    let period: FinancialAnalyticsView.AnalyticsPeriod
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Reporte Detallado")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                    // Add detailed report content here
                    Text("Contenido del reporte detallado...")
                        .foregroundColor(.secondary)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    FinancialAnalyticsView()
}
