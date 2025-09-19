//
//  ProfessionalFinancialAnalyticsComponents.swift
//  JustDad - Professional Financial Management
//
//  Professional UI components for financial analytics with SuperDesign
//

import SwiftUI
import Charts

// MARK: - Financial Statement Card
struct ProfessionalFinancialStatementCard: View {
    let statement: FinancialStatement
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Estado Financiero")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.adaptiveLabel)
                    
                    Text("Período: \(statement.period)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chart.bar.doc.horizontal.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            // Financial Metrics Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                FinancialMetricCard(
                    title: "Ingresos",
                    value: formatCurrency(statement.income),
                    icon: "arrow.up.circle.fill",
                    color: .green,
                    trend: .up
                )
                
                FinancialMetricCard(
                    title: "Gastos",
                    value: formatCurrency(statement.expenses),
                    icon: "arrow.down.circle.fill",
                    color: .red,
                    trend: .down
                )
                
                FinancialMetricCard(
                    title: "Ingreso Neto",
                    value: formatCurrency(statement.netIncome),
                    icon: statement.netIncome >= 0 ? "checkmark.circle.fill" : "xmark.circle.fill",
                    color: statement.netIncome >= 0 ? .green : .red,
                    trend: statement.netIncome >= 0 ? .up : .down
                )
                
                FinancialMetricCard(
                    title: "Flujo de Caja",
                    value: formatCurrency(statement.cashFlow),
                    icon: "dollarsign.circle.fill",
                    color: statement.cashFlow >= 0 ? .blue : .orange,
                    trend: statement.cashFlow >= 0 ? .up : .down
                )
            }
            
            // Balance Sheet Summary
            VStack(spacing: 12) {
                HStack {
                    Text("Balance General")
                        .font(.headline)
                        .foregroundColor(Color.adaptiveLabel)
                    Spacer()
                }
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Activos")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(formatCurrency(statement.assets))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("Pasivos")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(formatCurrency(statement.liabilities))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Patrimonio Neto")
                        .font(.headline)
                        .foregroundColor(Color.adaptiveLabel)
                    Spacer()
                    Text(formatCurrency(statement.equity))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(statement.equity >= 0 ? .green : .red)
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

// MARK: - Category Analysis Chart
struct ProfessionalCategoryAnalysisChart: View {
    let analysis: [CategoryAnalysis]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Análisis por Categoría")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.adaptiveLabel)
                    
                    Text("Distribución de gastos")
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
                Chart(analysis.prefix(6), id: \.category) { item in
                    SectorMark(
                        angle: .value("Amount", item.totalAmount),
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
                    ForEach(analysis.prefix(6), id: \.category) { item in
                        CategoryAnalysisRow(
                            category: item.category,
                            amount: item.totalAmount,
                            percentage: item.percentage,
                            trend: convertTrendDirection(item.trend)
                        )
                    }
                }
            }
            
            // Summary Stats
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Categorías")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(analysis.count)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.adaptiveLabel)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Gasto Promedio")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(analysis.map { $0.totalAmount }.reduce(0, +) / Decimal(analysis.count)))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.adaptiveLabel)
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

// MARK: - Cash Flow Analysis Card
struct ProfessionalCashFlowAnalysisCard: View {
    let analysis: CashFlowAnalysis
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Análisis de Flujo de Caja")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.adaptiveLabel)
                    
                    Text("Flujo de efectivo detallado")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            // Cash Flow Metrics
            VStack(spacing: 16) {
                CashFlowMetricRow(
                    title: "Flujo Operativo",
                    amount: analysis.operatingCashFlow,
                    color: .blue,
                    icon: "building.2.fill"
                )
                
                CashFlowMetricRow(
                    title: "Flujo de Inversión",
                    amount: analysis.investingCashFlow,
                    color: .purple,
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                CashFlowMetricRow(
                    title: "Flujo Financiero",
                    amount: analysis.financingCashFlow,
                    color: .orange,
                    icon: "banknote.fill"
                )
                
                Divider()
                
                CashFlowMetricRow(
                    title: "Flujo Neto",
                    amount: analysis.netCashFlow,
                    color: analysis.netCashFlow >= 0 ? .green : .red,
                    icon: analysis.netCashFlow >= 0 ? "checkmark.circle.fill" : "xmark.circle.fill",
                    isTotal: true
                )
            }
            
            // Key Ratios
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Margen de Flujo")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(String(format: "%.1f", analysis.cashFlowMargin))%")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(analysis.cashFlowMargin >= 0 ? .green : .red)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Flujo Libre")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(analysis.freeCashFlow))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(analysis.freeCashFlow >= 0 ? .green : .red)
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

// MARK: - Profitability Analysis Card
struct ProfessionalProfitabilityAnalysisCard: View {
    let analysis: ProfitabilityAnalysis
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Análisis de Rentabilidad")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.adaptiveLabel)
                    
                    Text("Márgenes y retornos")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "percent")
                    .font(.title2)
                    .foregroundColor(.green)
            }
            
            // Profitability Metrics Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ProfitabilityMetricCard(
                    title: "Margen Bruto",
                    value: "\(String(format: "%.1f", analysis.grossProfitMargin))%",
                    color: .green,
                    icon: "chart.bar.fill"
                )
                
                ProfitabilityMetricCard(
                    title: "Margen Operativo",
                    value: "\(String(format: "%.1f", analysis.operatingMargin))%",
                    color: .blue,
                    icon: "gear"
                )
                
                ProfitabilityMetricCard(
                    title: "Margen Neto",
                    value: "\(String(format: "%.1f", analysis.netProfitMargin))%",
                    color: .purple,
                    icon: "target"
                )
                
                ProfitabilityMetricCard(
                    title: "ROA",
                    value: "\(String(format: "%.1f", analysis.returnOnAssets))%",
                    color: .orange,
                    icon: "building.2"
                )
            }
            
            // Additional Metrics
            VStack(spacing: 12) {
                HStack {
                    Text("ROE (Retorno sobre Patrimonio)")
                        .font(.subheadline)
                        .foregroundColor(Color.adaptiveLabel)
                    Spacer()
                    Text("\(String(format: "%.1f", analysis.returnOnEquity))%")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(analysis.returnOnEquity >= 0 ? .green : .red)
                }
                
                HStack {
                    Text("Ganancias por Período")
                        .font(.subheadline)
                        .foregroundColor(Color.adaptiveLabel)
                    Spacer()
                    Text(formatCurrency(analysis.earningsPerPeriod))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(analysis.earningsPerPeriod >= 0 ? .green : .red)
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

// MARK: - Financial Health Score Card
struct ProfessionalFinancialHealthScoreCard: View {
    let healthScore: FinancialHealthScore
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Salud Financiera")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.adaptiveLabel)
                    
                    Text("Puntuación general")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "heart.fill")
                    .font(.title2)
                    .foregroundColor(healthScore.overallScore >= 70 ? .green : healthScore.overallScore >= 50 ? .orange : .red)
            }
            
            // Overall Score
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(healthScore.overallScore / 100))
                        .stroke(
                            LinearGradient(
                                colors: healthScore.overallScore >= 70 ? [.green, .blue] : 
                                       healthScore.overallScore >= 50 ? [.orange, .yellow] : [.red, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: healthScore.overallScore)
                    
                    VStack(spacing: 4) {
                        Text("\(Int(healthScore.overallScore))")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color.adaptiveLabel)
                        Text("Puntos")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(healthScoreDescription(score: healthScore.overallScore))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Detailed Scores
            VStack(spacing: 12) {
                HealthScoreRow(
                    title: "Liquidez",
                    score: healthScore.liquidityScore,
                    icon: "drop.fill",
                    color: .blue
                )
                
                HealthScoreRow(
                    title: "Rentabilidad",
                    score: healthScore.profitabilityScore,
                    icon: "percent",
                    color: .green
                )
                
                HealthScoreRow(
                    title: "Eficiencia",
                    score: healthScore.efficiencyScore,
                    icon: "gear",
                    color: .purple
                )
                
                HealthScoreRow(
                    title: "Estabilidad",
                    score: healthScore.stabilityScore,
                    icon: "shield.fill",
                    color: .orange
                )
            }
            
            // Recommendations
            if !healthScore.recommendations.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recomendaciones")
                        .font(.headline)
                        .foregroundColor(Color.adaptiveLabel)
                    
                    ForEach(healthScore.recommendations, id: \.self) { recommendation in
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
    
    private func healthScoreDescription(score: Double) -> String {
        switch score {
        case 80...100:
            return "Excelente salud financiera"
        case 60..<80:
            return "Buena salud financiera"
        case 40..<60:
            return "Salud financiera regular"
        case 20..<40:
            return "Salud financiera débil"
        default:
            return "Salud financiera crítica"
        }
    }
}

// MARK: - Supporting Views
struct FinancialMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: TrendDirection
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
                
                Image(systemName: trend == .up ? "arrow.up" : trend == .down ? "arrow.down" : "minus")
                    .font(.caption)
                    .foregroundColor(trend == .up ? .green : trend == .down ? .red : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.adaptiveLabel)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color.adaptiveSecondarySystemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct CategoryAnalysisRow: View {
    let category: FinancialEntry.ExpenseCategory
    let amount: Decimal
    let percentage: Double
    let trend: TrendDirection
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(categoryColor(category))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.displayName)
                    .font(.subheadline)
                    .foregroundColor(Color.adaptiveLabel)
                
                Text("\(String(format: "%.1f", percentage))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatCurrency(amount))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.adaptiveLabel)
                
                Image(systemName: trend == .up ? "arrow.up" : trend == .down ? "arrow.down" : "minus")
                    .font(.caption)
                    .foregroundColor(trend == .up ? .green : trend == .down ? .red : .gray)
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

struct CashFlowMetricRow: View {
    let title: String
    let amount: Decimal
    let color: Color
    let icon: String
    var isTotal: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(isTotal ? .title3 : .subheadline)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(isTotal ? .headline : .subheadline)
                .fontWeight(isTotal ? .bold : .medium)
                .foregroundColor(Color.adaptiveLabel)
            
            Spacer()
            
            Text(formatCurrency(amount))
                .font(isTotal ? .title3 : .subheadline)
                .fontWeight(isTotal ? .bold : .semibold)
                .foregroundColor(amount >= 0 ? .green : .red)
        }
        .padding(.vertical, isTotal ? 8 : 4)
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "es_US")
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }
}

struct ProfitabilityMetricCard: View {
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

struct HealthScoreRow: View {
    let title: String
    let score: Double
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.adaptiveLabel)
            
            Spacer()
            
            HStack(spacing: 8) {
                ProgressView(value: score, total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: color))
                    .frame(width: 60)
                
                Text("\(Int(score))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.adaptiveLabel)
                    .frame(width: 30, alignment: .trailing)
            }
        }
    }
}

// MARK: - Helper Functions
private func convertTrendDirection(_ trend: FinancialTrendDirection) -> TrendDirection {
    switch trend {
    case .up:
        return .up
    case .down:
        return .down
    case .neutral:
        return .neutral
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            ProfessionalFinancialStatementCard(
                statement: FinancialStatement(
                    period: "12/2024",
                    income: 5000,
                    expenses: 3500,
                    netIncome: 1500,
                    cashFlow: 1500,
                    assets: 60000,
                    liabilities: 30000,
                    equity: 30000
                )
            )
            
            ProfessionalCategoryAnalysisChart(
                analysis: [
                    CategoryAnalysis(
                        category: .childSupport,
                        totalAmount: 1000,
                        percentage: 28.6,
                        transactionCount: 1,
                        averageAmount: 1000,
                        trend: .neutral,
                        monthlyGrowth: 0
                    )
                ]
            )
        }
        .padding()
    }
}
