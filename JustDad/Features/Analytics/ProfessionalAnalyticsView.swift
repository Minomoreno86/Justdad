//
//  ProfessionalAnalyticsView.swift
//  JustDad - Professional Financial Management
//
//  Professional analytics view with accounting-level insights
//

import SwiftUI
import Charts

struct ProfessionalAnalyticsView: View {
    @StateObject private var analyticsService = ProfessionalFinancialAnalyticsService()
    @State private var selectedTimeframe: Timeframe = .month
    @State private var showingExportSheet = false
    @State private var selectedTab = 0
    
    private let timeframes = ["Semana", "Mes", "Año"]
    
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
                                message: "Generando análisis financiero profesional...",
                                showProgress: true
                            )
                        } else if let errorMessage = analyticsService.errorMessage {
                            ProfessionalErrorState(
                                title: "Error en Análisis",
                                message: errorMessage,
                                retryAction: {
                                    Task {
                                        await analyticsService.generateCompleteAnalysis()
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
                                    overviewAnalytics
                                case 1:
                                    profitabilityAnalytics
                                case 2:
                                    cashFlowAnalytics
                                case 3:
                                    healthScoreAnalytics
                                default:
                                    overviewAnalytics
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
                    await analyticsService.generateCompleteAnalysis()
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                ProfessionalExportSheet()
            }
        }
    }
    
    // MARK: - Professional Header
    private var professionalHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Analytics Financieros")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.adaptiveLabel)
                    
                    Text("Análisis contable profesional")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { showingExportSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
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
            if let statement = analyticsService.financialStatement {
                HStack(spacing: 20) {
                    QuickStatCard(
                        title: "Ingresos",
                        value: formatCurrency(statement.income),
                        color: .green,
                        icon: "arrow.up.circle.fill"
                    )
                    
                    QuickStatCard(
                        title: "Gastos",
                        value: formatCurrency(statement.expenses),
                        color: .red,
                        icon: "arrow.down.circle.fill"
                    )
                    
                    QuickStatCard(
                        title: "Neto",
                        value: formatCurrency(statement.netIncome),
                        color: statement.netIncome >= 0 ? .green : .red,
                        icon: statement.netIncome >= 0 ? "checkmark.circle.fill" : "xmark.circle.fill"
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
    
    // MARK: - Overview Analytics
    private var overviewAnalytics: some View {
        VStack(spacing: 20) {
            if let statement = analyticsService.financialStatement {
                ProfessionalFinancialStatementCard(statement: statement)
            }
            
            if !analyticsService.categoryAnalysis.isEmpty {
                ProfessionalCategoryAnalysisChart(analysis: analyticsService.categoryAnalysis)
            }
        }
    }
    
    // MARK: - Profitability Analytics
    private var profitabilityAnalytics: some View {
        VStack(spacing: 20) {
            if let profitability = analyticsService.profitabilityAnalysis {
                ProfessionalProfitabilityAnalysisCard(analysis: profitability)
            }
            
            if !analyticsService.budgetAnalysis.isEmpty {
                ProfessionalBudgetAnalysisCard(analysis: analyticsService.budgetAnalysis)
            }
        }
    }
    
    // MARK: - Cash Flow Analytics
    private var cashFlowAnalytics: some View {
        VStack(spacing: 20) {
            if let cashFlow = analyticsService.cashFlowAnalysis {
                ProfessionalCashFlowAnalysisCard(analysis: cashFlow)
            }
            
            if let liquidity = analyticsService.liquidityAnalysis {
                ProfessionalLiquidityAnalysisCard(analysis: liquidity)
            }
        }
    }
    
    // MARK: - Health Score Analytics
    private var healthScoreAnalytics: some View {
        VStack(spacing: 20) {
            if let healthScore = analyticsService.financialHealthScore {
                ProfessionalFinancialHealthScoreCard(healthScore: healthScore)
            }
            
            if !analyticsService.trendAnalysis.isEmpty {
                ProfessionalTrendAnalysisCard(analysis: analyticsService.trendAnalysis)
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
            ("Rentabilidad", "percent"),
            ("Flujo de Caja", "arrow.triangle.2.circlepath"),
            ("Salud", "heart.fill")
        ]
    }
}

// MARK: - Supporting Views
struct QuickStatCard: View {
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
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color.adaptiveLabel)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.adaptiveSecondarySystemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct ProfessionalBudgetAnalysisCard: View {
    let analysis: [BudgetAnalysis]
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Análisis de Presupuesto")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.adaptiveLabel)
                
                Spacer()
                
                Image(systemName: "target")
                    .font(.title2)
                    .foregroundColor(.orange)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(analysis.prefix(5), id: \.budgetedAmount) { item in
                    BudgetAnalysisRow(analysis: item)
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

struct ProfessionalLiquidityAnalysisCard: View {
    let analysis: LiquidityAnalysis
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Análisis de Liquidez")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.adaptiveLabel)
                
                Spacer()
                
                Image(systemName: "drop.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                LiquidityMetricCard(
                    title: "Ratio Actual",
                    value: String(format: "%.2f", analysis.currentRatio),
                    color: .blue
                )
                
                LiquidityMetricCard(
                    title: "Ratio Rápido",
                    value: String(format: "%.2f", analysis.quickRatio),
                    color: .green
                )
                
                LiquidityMetricCard(
                    title: "Ratio de Caja",
                    value: String(format: "%.2f", analysis.cashRatio),
                    color: .purple
                )
                
                LiquidityMetricCard(
                    title: "Capital de Trabajo",
                    value: formatCurrency(analysis.workingCapital),
                    color: .orange
                )
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

struct ProfessionalTrendAnalysisCard: View {
    let analysis: [TrendAnalysis]
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Análisis de Tendencias")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.adaptiveLabel)
                
                Spacer()
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundColor(.green)
            }
            
            if #available(iOS 16.0, *) {
                Chart(analysis.prefix(6), id: \.period) { item in
                    LineMark(
                        x: .value("Period", item.period),
                        y: .value("Amount", item.value)
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    AreaMark(
                        x: .value("Period", item.period),
                        y: .value("Amount", item.value)
                    )
                    .foregroundStyle(.blue.opacity(0.1))
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            } else {
                // Fallback for older iOS versions
                VStack(spacing: 8) {
                    ForEach(analysis.prefix(6), id: \.period) { item in
                        TrendAnalysisRow(analysis: item)
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

// MARK: - Additional Supporting Views
struct BudgetAnalysisRow: View {
    let analysis: BudgetAnalysis
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Presupuesto")
                    .font(.subheadline)
                    .foregroundColor(Color.adaptiveLabel)
                
                Text(formatCurrency(analysis.budgetedAmount))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Real")
                    .font(.subheadline)
                    .foregroundColor(Color.adaptiveLabel)
                
                Text(formatCurrency(analysis.actualAmount))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Varianza")
                    .font(.subheadline)
                    .foregroundColor(Color.adaptiveLabel)
                
                Text("\(String(format: "%.1f", analysis.variancePercentage))%")
                    .font(.caption)
                    .foregroundColor(analysis.variancePercentage >= 0 ? .red : .green)
            }
        }
        .padding(12)
        .background(Color.adaptiveSecondarySystemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "es_US")
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }
}

struct LiquidityMetricCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.adaptiveSecondarySystemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct TrendAnalysisRow: View {
    let analysis: TrendAnalysis
    
    var body: some View {
        HStack(spacing: 12) {
            Text(analysis.period)
                .font(.subheadline)
                .foregroundColor(Color.adaptiveLabel)
            
            Spacer()
            
            Text(formatCurrency(analysis.value))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color.adaptiveLabel)
            
            Text("\(String(format: "%.1f", analysis.changePercentage))%")
                .font(.caption)
                .foregroundColor(analysis.changePercentage >= 0 ? .green : .red)
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

struct ProfessionalExportSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Exportar Análisis")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.adaptiveLabel)
                
                Text("Selecciona el formato de exportación")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 12) {
                    ExportOptionButton(
                        title: "PDF Completo",
                        description: "Reporte detallado en PDF",
                        icon: "doc.fill",
                        color: .red
                    ) {
                        // Export PDF
                    }
                    
                    ExportOptionButton(
                        title: "Excel Avanzado",
                        description: "Datos en formato Excel",
                        icon: "tablecells.fill",
                        color: .green
                    ) {
                        // Export Excel
                    }
                    
                    ExportOptionButton(
                        title: "CSV de Datos",
                        description: "Datos brutos en CSV",
                        icon: "doc.text.fill",
                        color: .blue
                    ) {
                        // Export CSV
                    }
                }
                
                Spacer()
            }
            .padding(20)
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

struct ExportOptionButton: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(color)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Timeframe Enum
enum Timeframe: Int, CaseIterable {
    case week = 0
    case month = 1
    case year = 2
}

#Preview {
    ProfessionalAnalyticsView()
}
