//
//  RealProfessionalAnalyticsView.swift
//  JustDad - Professional Financial Management
//
//  Real professional analytics view with clear, understandable charts
//

import SwiftUI
import Charts

struct RealProfessionalAnalyticsView: View {
    @StateObject private var analyticsService = RealFinancialAnalyticsService()
    @State private var selectedTimeframe: Timeframe = .month
    @State private var selectedTab = 0
    
    // Real data from FinanceViewModel
    let expenses: [FinancialEntry]
    let monthlyIncome: Decimal
    let monthlyBudget: Decimal
    let categoryBreakdown: [CategoryBreakdown]
    let totalAmount: Decimal
    let balanceAmount: Decimal
    
    private let timeframes = ["Semana", "Mes", "Año"]
    
    init(
        expenses: [FinancialEntry] = [],
        monthlyIncome: Decimal = 0,
        monthlyBudget: Decimal = 0,
        categoryBreakdown: [CategoryBreakdown] = [],
        totalAmount: Decimal = 0,
        balanceAmount: Decimal = 0
    ) {
        self.expenses = expenses
        self.monthlyIncome = monthlyIncome
        self.monthlyBudget = monthlyBudget
        self.categoryBreakdown = categoryBreakdown
        self.totalAmount = totalAmount
        self.balanceAmount = balanceAmount
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Professional Background
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.05),
                        Color.purple.opacity(0.03),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Professional Header
                        professionalHeader
                        
                        // Timeframe Selector
                        timeframeSelector
                        
                        // Analytics Content
                        if analyticsService.isLoading {
                            ProfessionalLoadingState(
                                message: "Generando análisis financiero...",
                                showProgress: true
                            )
                        } else if let errorMessage = analyticsService.errorMessage {
                            ProfessionalErrorState(
                                title: "Error en Análisis",
                                message: errorMessage,
                                retryAction: {
                                    Task {
                                        await analyticsService.generateRealAnalysis()
                                    }
                                }
                            )
                        } else {
                            // Analytics Tabs
                            analyticsTabs
                            
                            // Analytics Content based on selected tab
                            Group {
                                switch selectedTab {
                                case 0:
                                    overviewTab
                                case 1:
                                    categoriesTab
                                case 2:
                                    trendsTab
                                case 3:
                                    insightsTab
                                default:
                                    overviewTab
                                }
                            }
                            .animation(.easeInOut(duration: 0.3), value: selectedTab)
                        }
                        
                        // Bottom padding
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            #if os(iOS)
            .toolbar(.hidden, for: .navigationBar)
            #endif
            .onAppear {
                Task {
                    await analyticsService.generateRealAnalysisWithData(
                        expenses: expenses,
                        monthlyIncome: monthlyIncome,
                        monthlyBudget: monthlyBudget,
                        categoryBreakdown: categoryBreakdown,
                        totalAmount: totalAmount,
                        balanceAmount: balanceAmount
                    )
                }
            }
        }
    }
    
    // MARK: - Professional Header
    private var professionalHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Análisis Financiero")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.adaptiveLabel)
                    
                    Text("Datos reales y análisis prácticos")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { 
                    Task {
                        await analyticsService.generateRealAnalysis()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Circle())
                        .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Quick Stats
            if let overview = analyticsService.overview {
                HStack(spacing: 20) {
                    QuickStatCard(
                        title: "Ingresos",
                        value: formatCurrency(overview.totalIncome),
                        color: .green,
                        icon: "arrow.up.circle.fill"
                    )
                    
                    QuickStatCard(
                        title: "Gastos",
                        value: formatCurrency(overview.totalExpenses),
                        color: .red,
                        icon: "arrow.down.circle.fill"
                    )
                    
                    QuickStatCard(
                        title: "Ahorro",
                        value: formatCurrency(overview.netIncome),
                        color: overview.netIncome >= 0 ? .green : .red,
                        icon: overview.netIncome >= 0 ? "checkmark.circle.fill" : "xmark.circle.fill"
                    )
                }
            }
        }
    }
    
    // MARK: - Timeframe Selector
    private var timeframeSelector: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Período de Análisis")
                    .font(.headline)
                    .foregroundColor(Color.adaptiveLabel)
                
                Spacer()
            }
            
            HStack(spacing: 0) {
                ForEach(Array(timeframes.enumerated()), id: \.offset) { index, timeframe in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTimeframe = Timeframe(rawValue: index) ?? .month
                        }
                    }) {
                        Text(timeframe)
                            .font(.subheadline)
                            .foregroundColor(selectedTimeframe.rawValue == index ? .white : Color.adaptiveLabel)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                selectedTimeframe.rawValue == index ? 
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
            .background(Color.adaptiveSecondarySystemBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - Analytics Tabs
    private var analyticsTabs: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Análisis Detallado")
                    .font(.headline)
                    .foregroundColor(Color.adaptiveLabel)
                
                Spacer()
            }
            
            HStack(spacing: 0) {
                ForEach(Array(analyticsTabData.enumerated()), id: \.offset) { index, tab in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = index
                        }
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: tab.icon)
                                .font(.title3)
                                .foregroundColor(selectedTab == index ? .white : Color.adaptiveLabel)
                            
                            Text(tab.title)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(selectedTab == index ? .white : Color.adaptiveLabel)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            selectedTab == index ? 
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
            .background(Color.adaptiveSecondarySystemBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - Overview Tab
    private var overviewTab: some View {
        VStack(spacing: 20) {
            if let overview = analyticsService.overview {
                RealOverviewCard(overview: overview)
            }
            
            if let budgetAnalysis = analyticsService.budgetAnalysis {
                RealBudgetAnalysisCard(analysis: budgetAnalysis)
            }
        }
    }
    
    // MARK: - Categories Tab
    private var categoriesTab: some View {
        VStack(spacing: 20) {
            if !analyticsService.categoryBreakdown.isEmpty {
                RealCategoryBreakdownCard(breakdown: analyticsService.categoryBreakdown)
            }
        }
    }
    
    // MARK: - Trends Tab
    private var trendsTab: some View {
        VStack(spacing: 20) {
            if !analyticsService.monthlyTrends.isEmpty {
                RealMonthlyTrendsCard(trends: analyticsService.monthlyTrends)
            }
        }
    }
    
    // MARK: - Insights Tab
    private var insightsTab: some View {
        VStack(spacing: 20) {
            if let insights = analyticsService.insights {
                RealInsightsCard(insights: insights)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "es_US")
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }
    
    private var analyticsTabData: [(title: String, icon: String)] {
        [
            ("Resumen", "chart.bar.fill"),
            ("Categorías", "chart.pie.fill"),
            ("Tendencias", "chart.line.uptrend.xyaxis"),
            ("Insights", "lightbulb.fill")
        ]
    }
}

// MARK: - Real Overview Card
struct RealOverviewCard: View {
    let overview: RealFinancialOverview
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Resumen Financiero")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.adaptiveLabel)
                    
                    Text("Estado actual de tus finanzas")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chart.bar.doc.horizontal.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            // Key Metrics
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                RealMetricCard(
                    title: "Presupuesto Utilizado",
                    value: "\(String(format: "%.1f", overview.budgetUtilization))%",
                    color: overview.budgetUtilization > 90 ? .red : overview.budgetUtilization > 70 ? .orange : .green,
                    icon: "target"
                )
                
                RealMetricCard(
                    title: "Tasa de Ahorro",
                    value: "\(String(format: "%.1f", overview.savingsRate))%",
                    color: overview.savingsRate > 20 ? .green : overview.savingsRate > 10 ? .orange : .red,
                    icon: "banknote"
                )
                
                RealMetricCard(
                    title: "Crecimiento Gastos",
                    value: "\(String(format: "%.1f", overview.expenseGrowth))%",
                    color: overview.expenseGrowth > 0 ? .red : .green,
                    icon: "arrow.up.right"
                )
                
                RealMetricCard(
                    title: "Crecimiento Ingresos",
                    value: "\(String(format: "%.1f", overview.incomeGrowth))%",
                    color: overview.incomeGrowth > 0 ? .green : .red,
                    icon: "arrow.up.circle"
                )
            }
            
            // Net Income Summary
            VStack(spacing: 12) {
                HStack {
                    Text("Resultado Neto")
                        .font(.headline)
                        .foregroundColor(Color.adaptiveLabel)
                    Spacer()
                    Text(formatCurrency(overview.netIncome))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(overview.netIncome >= 0 ? .green : .red)
                }
                
                Text(overview.netIncome >= 0 ? "¡Excelente! Estás ahorrando dinero." : "Necesitas revisar tus gastos para equilibrar tu presupuesto.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(16)
            .background(Color.adaptiveSecondarySystemBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "es_US")
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }
}

// MARK: - Real Category Breakdown Card
struct RealCategoryBreakdownCard: View {
    let breakdown: [RealCategoryBreakdown]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Gastos por Categoría")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.adaptiveLabel)
                    
                    Text("Distribución de tus gastos")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chart.pie.fill")
                    .font(.title2)
                    .foregroundColor(.purple)
            }
            
            // Pie Chart
            if #available(iOS 16.0, *) {
                Chart(breakdown.prefix(6), id: \.category) { item in
                    SectorMark(
                        angle: .value("Amount", item.amount),
                        innerRadius: .ratio(0.4),
                        angularInset: 2
                    )
                    .foregroundStyle(by: .value("Category", item.category.displayName))
                    .opacity(0.8)
                }
                .frame(height: 200)
                .chartLegend(position: .bottom, alignment: .center)
            } else {
                // Fallback for older iOS versions
                VStack(spacing: 12) {
                    ForEach(breakdown.prefix(6), id: \.category) { item in
                        RealCategoryRow(item: item)
                    }
                }
            }
            
            // Top Categories
            VStack(alignment: .leading, spacing: 12) {
                Text("Top 3 Categorías")
                    .font(.headline)
                    .foregroundColor(Color.adaptiveLabel)
                
                ForEach(Array(breakdown.prefix(3).enumerated()), id: \.offset) { index, item in
                    HStack {
                        Text("\(index + 1).")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .frame(width: 20, alignment: .leading)
                        
                        Text(item.category.displayName)
                            .font(.subheadline)
                            .foregroundColor(Color.adaptiveLabel)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(formatCurrency(item.amount))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.adaptiveLabel)
                            
                            Text("\(String(format: "%.1f", item.percentage))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(16)
            .background(Color.adaptiveSecondarySystemBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "es_US")
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }
}

// MARK: - Real Monthly Trends Card
struct RealMonthlyTrendsCard: View {
    let trends: [RealMonthlyTrend]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tendencias Mensuales")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.adaptiveLabel)
                    
                    Text("Evolución de tus finanzas")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundColor(.green)
            }
            
            // Line Chart
            if #available(iOS 16.0, *) {
                Chart(trends, id: \.month) { item in
                    LineMark(
                        x: .value("Month", item.month),
                        y: .value("Income", item.income)
                    )
                    .foregroundStyle(.green)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    LineMark(
                        x: .value("Month", item.month),
                        y: .value("Expenses", item.expenses)
                    )
                    .foregroundStyle(.red)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    LineMark(
                        x: .value("Month", item.month),
                        y: .value("Net Income", item.netIncome)
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartLegend(position: .bottom, alignment: .center)
            } else {
                // Fallback for older iOS versions
                VStack(spacing: 8) {
                    ForEach(trends, id: \.month) { item in
                        RealTrendRow(item: item)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Real Budget Analysis Card
struct RealBudgetAnalysisCard: View {
    let analysis: RealBudgetAnalysis
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Análisis de Presupuesto")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.adaptiveLabel)
                    
                    Text("Control presupuestario")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "target")
                    .font(.title2)
                    .foregroundColor(.orange)
            }
            
            // Budget Progress
            VStack(spacing: 16) {
                HStack {
                    Text("Presupuesto Utilizado")
                        .font(.headline)
                        .foregroundColor(Color.adaptiveLabel)
                    Spacer()
                    Text("\(String(format: "%.1f", analysis.budgetEfficiency))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(analysis.budgetEfficiency > 90 ? .red : analysis.budgetEfficiency > 70 ? .orange : .green)
                }
                
                ProgressView()
                    .progressViewStyle(LinearProgressViewStyle(tint: analysis.budgetEfficiency > 90 ? .red : analysis.budgetEfficiency > 70 ? .orange : .green))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                
                HStack {
                    Text("Gastado: \(formatCurrency(analysis.totalSpent))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Restante: \(formatCurrency(analysis.remainingBudget))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Budget Status
            VStack(spacing: 12) {
                if !analysis.overBudgetCategories.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("⚠️ Sobre Presupuesto")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        ForEach(analysis.overBudgetCategories, id: \.self) { category in
                            Text("• \(category.displayName)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(12)
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                if !analysis.underBudgetCategories.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("✅ Bajo Presupuesto")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        ForEach(analysis.underBudgetCategories.prefix(3), id: \.self) { category in
                            Text("• \(category.displayName)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(12)
                    .background(Color.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "es_US")
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }
}

// MARK: - Real Insights Card
struct RealInsightsCard: View {
    let insights: RealFinancialInsights
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Insights Financieros")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.adaptiveLabel)
                    
                    Text("Análisis inteligente de tus gastos")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "lightbulb.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
            }
            
            // Key Insights
            VStack(spacing: 16) {
                RealInsightRow(
                    title: "Mayor Gasto",
                    value: insights.topExpenseCategory.displayName,
                    subtitle: formatCurrency(insights.biggestExpense),
                    icon: "arrow.up.circle.fill",
                    color: .red
                )
                
                RealInsightRow(
                    title: "Gasto Promedio Diario",
                    value: formatCurrency(insights.averageDailySpending),
                    subtitle: "Por día",
                    icon: "calendar",
                    color: .blue
                )
                
                RealInsightRow(
                    title: "Día Más Caro",
                    value: insights.mostExpensiveDay,
                    subtitle: "Del mes",
                    icon: "exclamationmark.triangle.fill",
                    color: .orange
                )
                
                RealInsightRow(
                    title: "Patrón de Gastos",
                    value: insights.spendingPattern,
                    subtitle: "Análisis",
                    icon: "chart.bar.fill",
                    color: .purple
                )
            }
            
            // Recommendations
            if !insights.recommendations.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("💡 Recomendaciones")
                        .font(.headline)
                        .foregroundColor(Color.adaptiveLabel)
                    
                    ForEach(insights.recommendations, id: \.self) { recommendation in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                                .padding(.top, 2)
                            
                            Text(recommendation)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(16)
                .background(Color.adaptiveSecondarySystemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
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
struct RealMetricCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color.adaptiveLabel)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.adaptiveSecondarySystemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct RealCategoryRow: View {
    let item: RealCategoryBreakdown
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(categoryColor(item.category))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.category.displayName)
                    .font(.subheadline)
                    .foregroundColor(Color.adaptiveLabel)
                
                Text("\(String(format: "%.1f", item.percentage))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatCurrency(item.amount))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.adaptiveLabel)
                
                if item.overBudget {
                    Text("Sobre presupuesto")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func categoryColor(_ category: FinancialEntry.ExpenseCategory) -> Color {
        switch category {
        case .childSupport: return .orange
        case .food: return .green
        case .transportation: return .blue
        case .education: return .purple
        case .entertainment: return .pink
        case .health: return .red
        case .clothing: return .purple
        case .gifts: return .pink
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

struct RealTrendRow: View {
    let item: RealMonthlyTrend
    
    var body: some View {
        HStack(spacing: 12) {
            Text(item.month)
                .font(.subheadline)
                .foregroundColor(Color.adaptiveLabel)
                .frame(width: 80, alignment: .leading)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("Ingresos: \(formatCurrency(item.income))")
                    .font(.caption)
                    .foregroundColor(.green)
                
                Text("Gastos: \(formatCurrency(item.expenses))")
                    .font(.caption)
                    .foregroundColor(.red)
                
                Text("Neto: \(formatCurrency(item.netIncome))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(item.netIncome >= 0 ? .green : .red)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "es_US")
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }
}

struct RealInsightRow: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.adaptiveLabel)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.adaptiveSecondarySystemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Timeframe Enum
// Note: Timeframe enum is already defined in ProfessionalAnalyticsView.swift

#Preview {
    RealProfessionalAnalyticsView()
}
