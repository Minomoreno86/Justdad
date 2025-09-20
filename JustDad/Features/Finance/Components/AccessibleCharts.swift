//
//  AccessibleCharts.swift
//  JustDad - Accessible Chart Components
//
//  Professional accessible chart components for financial data visualization.
//

import SwiftUI
import Charts

// MARK: - Accessible Pie Chart
struct AccessiblePieChart: View {
    let data: [ChartDataPoint]
    let title: String
    let accessibilityDescription: String
    
    struct ChartDataPoint: Identifiable {
        let id = UUID()
        let name: String
        let value: Double
        let color: Color
        let percentage: Double
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .accessibleHeading(2)
            
            Chart(data) { point in
                SectorMark(
                    angle: .value("Value", point.value),
                    innerRadius: .ratio(0.5),
                    angularInset: 2
                )
                .foregroundStyle(point.color)
            }
            .frame(height: 200)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(title). \(accessibilityDescription)")
            .accessibilityValue(createAccessibilityValue())
            .accessibilityAddTraits(.isImage)
            
            // Legend
            VStack(alignment: .leading, spacing: 8) {
                ForEach(data) { point in
                    HStack {
                        Circle()
                            .fill(point.color)
                            .frame(width: 12, height: 12)
                        
                        Text(point.name)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(String(format: "%.1f", point.percentage))%")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(point.name): \(String(format: "%.1f", point.percentage)) por ciento")
                    .accessibilityValue("$\(String(format: "%.2f", point.value))")
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func createAccessibilityValue() -> String {
        let sortedData = data.sorted { $0.value > $1.value }
        return sortedData.map { "\($0.name): \(String(format: "%.1f", $0.percentage)) por ciento" }.joined(separator: ", ")
    }
}

// MARK: - Accessible Bar Chart
struct AccessibleBarChart: View {
    let data: [BarChartDataPoint]
    let title: String
    let xAxisLabel: String
    let yAxisLabel: String
    let accessibilityDescription: String
    
    struct BarChartDataPoint: Identifiable {
        let id = UUID()
        let name: String
        let value: Double
        let color: Color
        let date: Date?
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .accessibleHeading(2)
            
            Chart(data) { point in
                BarMark(
                    x: .value(xAxisLabel, point.name),
                    y: .value(yAxisLabel, point.value)
                )
                .foregroundStyle(point.color)
                .accessibilityLabel("\(point.name): $\(String(format: "%.2f", point.value))")
            }
            .frame(height: 200)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(title). \(accessibilityDescription)")
            .accessibilityValue(createAccessibilityValue())
            .accessibilityAddTraits(.isImage)
            
            // Data summary
            VStack(alignment: .leading, spacing: 4) {
                Text("Resumen de datos:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .accessibleHeading(3)
                
                Text("Total: $\(String(format: "%.2f", data.reduce(0) { $0 + $1.value }))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Promedio: $\(String(format: "%.2f", data.reduce(0) { $0 + $1.value } / Double(data.count)))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func createAccessibilityValue() -> String {
        let sortedData = data.sorted { $0.value > $1.value }
        return sortedData.map { "\($0.name): $\(String(format: "%.2f", $0.value))" }.joined(separator: ", ")
    }
}

// MARK: - Accessible Line Chart
struct AccessibleLineChart: View {
    let data: [LineChartDataPoint]
    let title: String
    let xAxisLabel: String
    let yAxisLabel: String
    let accessibilityDescription: String
    
    struct LineChartDataPoint: Identifiable {
        let id = UUID()
        let name: String
        let value: Double
        let date: Date
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .accessibleHeading(2)
            
            Chart(data) { point in
                LineMark(
                    x: .value(xAxisLabel, point.date),
                    y: .value(yAxisLabel, point.value)
                )
                .foregroundStyle(.blue)
                .interpolationMethod(.catmullRom)
                
                PointMark(
                    x: .value(xAxisLabel, point.date),
                    y: .value(yAxisLabel, point.value)
                )
                .foregroundStyle(.blue)
                .accessibilityLabel("\(point.name): $\(String(format: "%.2f", point.value))")
            }
            .frame(height: 200)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(title). \(accessibilityDescription)")
            .accessibilityValue(createAccessibilityValue())
            .accessibilityAddTraits(.isImage)
            
            // Trend analysis
            VStack(alignment: .leading, spacing: 4) {
                Text("Análisis de tendencia:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .accessibleHeading(3)
                
                if data.count >= 2 {
                    let firstValue = data.first?.value ?? 0
                    let lastValue = data.last?.value ?? 0
                    let change = lastValue - firstValue
                    let percentageChange = firstValue != 0 ? (change / firstValue) * 100 : 0
                    
                    Text("Cambio: \(change >= 0 ? "+" : "")$\(String(format: "%.2f", change)) (\(percentageChange >= 0 ? "+" : "")\(String(format: "%.1f", percentageChange))%)")
                        .font(.caption)
                        .foregroundColor(change >= 0 ? .green : .red)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func createAccessibilityValue() -> String {
        let sortedData = data.sorted { $0.date < $1.date }
        return sortedData.map { "\($0.name): $\(String(format: "%.2f", $0.value))" }.joined(separator: ", ")
    }
}

// MARK: - Accessible Progress Ring
struct AccessibleProgressRing: View {
    let title: String
    let currentValue: Double
    let maxValue: Double
    let color: Color
    let accessibilityDescription: String
    
    private var percentage: Double {
        guard maxValue > 0 else { return 0 }
        return min(currentValue / maxValue, 1.0)
    }
    
    private var percentageText: String {
        "\(Int(percentage * 100))%"
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .accessibleHeading(2)
            
            ZStack {
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: percentage)
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: percentage)
                
                VStack {
                    Text(percentageText)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Completado")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(title). \(accessibilityDescription)")
            .accessibilityValue("\(percentageText) completado. $\(String(format: "%.2f", currentValue)) de $\(String(format: "%.2f", maxValue))")
            .accessibilityAddTraits(.isImage)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Progreso:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .accessibleHeading(3)
                
                Text("$\(String(format: "%.2f", currentValue)) de $\(String(format: "%.2f", maxValue))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Restante: $\(String(format: "%.2f", maxValue - currentValue))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Accessible Data Table
struct AccessibleDataTable: View {
    let data: [TableRow]
    let title: String
    let accessibilityDescription: String
    
    struct TableRow: Identifiable {
        let id = UUID()
        let label: String
        let value: String
        let isHeader: Bool
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .accessibleHeading(2)
            
            VStack(spacing: 0) {
                ForEach(Array(data.enumerated()), id: \.element.id) { index, row in
                    HStack {
                        Text(row.label)
                            .font(row.isHeader ? .subheadline : .body)
                            .fontWeight(row.isHeader ? .semibold : .regular)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(row.value)
                            .font(row.isHeader ? .subheadline : .body)
                            .fontWeight(row.isHeader ? .semibold : .regular)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        index % 2 == 0 ? Color(.systemBackground) : Color(.systemGray6)
                    )
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(row.label): \(row.value)")
                    .accessibilityAddTraits(row.isHeader ? [.isStaticText, .isHeader] : .isStaticText)
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(title). \(accessibilityDescription)")
    }
}