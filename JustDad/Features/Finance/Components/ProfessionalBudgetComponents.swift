//
//  ProfessionalBudgetComponents.swift
//  JustDad - Professional Budget UI Components
//
//  Reusable UI components for budget management interface
//

import SwiftUI
import Charts

// MARK: - Budget Card Component

struct BudgetCard: View {
    let budget: Budget
    let progress: Double
    let status: BudgetStatus
    let remainingAmount: Decimal
    let onEdit: () -> Void
    let onToggle: () -> Void
    
    private var progressColor: Color {
        switch status {
        case .onTrack: return .blue  // Cambiado de verde a azul para presupuestos
        case .warning: return .orange
        case .critical: return .red
        case .exceeded: return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.category)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(NumberFormatter.currency.string(from: budget.amount as NSDecimalNumber) ?? "$0")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Button(action: onToggle) {
                        Image(systemName: budget.isActive ? "pause.circle.fill" : "play.circle.fill")
                            .font(.title2)
                            .foregroundColor(budget.isActive ? .orange : .green)
                    }
                    
                    Button(action: onEdit) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progreso")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(progressColor)
                }
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            
            // Status and Remaining
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: status.icon)
                        .foregroundColor(progressColor)
                    
                    Text(statusText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(progressColor)
                }
                
                Spacer()
                
                Text("Restante: \(NumberFormatter.currency.string(from: remainingAmount as NSDecimalNumber) ?? "$0")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(progressColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var statusText: String {
        switch status {
        case .onTrack: return "En camino"
        case .warning: return "Advertencia"
        case .critical: return "Crítico"
        case .exceeded: return "Excedido"
        }
    }
}

// MARK: - Budget Insights Card

struct BudgetInsightsCard: View {
    let insights: BudgetInsights
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Análisis de Presupuestos")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if isLoading {
                BudgetInsightsSkeleton()
            } else {
                VStack(spacing: 16) {
                    // Overall Utilization
                    OverallUtilizationView(insights: insights)
                    
                    // Monthly Trend Chart
                    MonthlyTrendChart(trend: insights.monthlyTrend)
                    
                    // Top Recommendations
                    if !insights.recommendations.isEmpty {
                        RecommendationsView(recommendations: insights.recommendations)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Overall Utilization View

struct OverallUtilizationView: View {
    let insights: BudgetInsights
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Utilización General")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(Int(insights.utilizationPercentage * 100))%")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(utilizationColor)
                    
                    Text("de presupuesto utilizado")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(NumberFormatter.currency.string(from: insights.totalSpent as NSDecimalNumber) ?? "$0")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("de \(NumberFormatter.currency.string(from: insights.totalBudgetedAmount as NSDecimalNumber) ?? "$0")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            ProgressView(value: insights.utilizationPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: utilizationColor))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
    }
    
    private var utilizationColor: Color {
        if insights.utilizationPercentage >= 1.0 {
            return .red
        } else if insights.utilizationPercentage >= 0.9 {
            return .orange
        } else {
            return .blue  // Cambiado de verde a azul para presupuestos
        }
    }
}

// MARK: - Monthly Trend Chart

struct MonthlyTrendChart: View {
    let trend: [MonthlyBudgetTrend]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tendencia Mensual")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            if #available(iOS 16.0, *) {
                Chart(trend) { item in
                    BarMark(
                        x: .value("Mes", item.month, unit: .month),
                        y: .value("Utilización", item.utilization * 100)
                    )
                    .foregroundStyle(utilizationColor(for: item.utilization))
                }
                .frame(height: 120)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text("\(Int(doubleValue))%")
                                    .font(.caption)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(DateFormatter.monthAbbreviation.string(from: date))
                                    .font(.caption)
                            }
                        }
                    }
                }
            } else {
                // Fallback for iOS 15
                HStack(spacing: 4) {
                    ForEach(trend) { item in
                        VStack {
                            Rectangle()
                                .fill(utilizationColor(for: item.utilization))
                                .frame(width: 20, height: CGFloat(item.utilization * 100))
                            
                            Text(DateFormatter.monthAbbreviation.string(from: item.month))
                                .font(.caption2)
                        }
                    }
                }
                .frame(height: 120)
            }
        }
    }
    
    private func utilizationColor(for utilization: Double) -> Color {
        if utilization >= 1.0 {
            return .red
        } else if utilization >= 0.8 {
            return .orange
        } else {
            return .blue  // Cambiado de verde a azul para presupuestos
        }
    }
}

// MARK: - Recommendations View

struct RecommendationsView: View {
    let recommendations: [BudgetRecommendation]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recomendaciones")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                ForEach(recommendations.prefix(3)) { recommendation in
                    RecommendationRow(recommendation: recommendation)
                }
            }
        }
    }
}

struct RecommendationRow: View {
    let recommendation: BudgetRecommendation
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(priorityColor)
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(recommendation.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(recommendation.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private var priorityColor: Color {
        switch recommendation.priority {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
}

// MARK: - Budget Creation Form

struct BudgetCreationForm: View {
    @Binding var isPresented: Bool
    @State private var selectedCategory: String = "Manutención"
    @State private var amount: String = ""
    @State private var selectedPeriod: BudgetPeriod = .monthly
    @State private var alertThresholds: [Decimal] = [0.8, 0.9, 1.0]
    
    let onSave: (Budget) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Configuración del Presupuesto")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Categoría")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Picker("Categoría", selection: $selectedCategory) {
                            ForEach(["Manutención", "Educación", "Salud", "Entretenimiento", "Comida", "Transporte", "Servicios", "Otros"], id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Monto")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Período")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Picker("Período", selection: $selectedPeriod) {
                            ForEach(BudgetPeriod.allCases, id: \.self) { period in
                                Text(period.displayName).tag(period)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
            }
            .padding()
            .navigationTitle("Nuevo Presupuesto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveBudget()
                    }
                    .disabled(amount.isEmpty || Decimal(string: amount) == nil)
                }
            }
        }
    }
    
    private func saveBudget() {
        guard let amountDecimal = Decimal(string: amount) else { return }
        
        let budget = Budget(
            id: UUID(),
            category: selectedCategory,
            amount: amountDecimal,
            period: selectedPeriod,
            alertThresholds: alertThresholds,
            createdAt: Date(),
            isActive: true
        )
        
        onSave(budget)
        isPresented = false
    }
}

// MARK: - Budget Skeleton Loading

struct BudgetInsightsSkeleton: View {
    var body: some View {
        VStack(spacing: 16) {
            // Overall Utilization Skeleton
            VStack(alignment: .leading, spacing: 8) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 16)
                    .frame(width: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                
                HStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 24)
                        .frame(width: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    
                    Spacer()
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 16)
                        .frame(width: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 8)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            // Chart Skeleton
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let monthAbbreviation: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }()
}
