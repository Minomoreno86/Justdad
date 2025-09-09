//
//  PlaceholderChart.swift
//  JustDad - Placeholder chart component
//
//  Mock chart component for data visualization
//

import SwiftUI

struct PlaceholderChart: View {
    let title: String
    let data: [ChartDataPoint]
    let height: CGFloat
    let color: Color
    
    struct ChartDataPoint: Identifiable {
        let id = UUID()
        let label: String
        let value: Double
        let color: Color?
        
        init(label: String, value: Double, color: Color? = nil) {
            self.label = label
            self.value = value
            self.color = color
        }
    }
    
    init(
        title: String,
        data: [ChartDataPoint] = [],
        height: CGFloat = 200,
        color: Color = .blue
    ) {
        self.title = title
        self.data = data.isEmpty ? Self.mockData : data
        self.height = height
        self.color = color
    }
    
    static let mockData = [
        ChartDataPoint(label: "Mon", value: 3.2, color: .blue),
        ChartDataPoint(label: "Tue", value: 2.8, color: .green),
        ChartDataPoint(label: "Wed", value: 4.1, color: .orange),
        ChartDataPoint(label: "Thu", value: 3.7, color: .blue),
        ChartDataPoint(label: "Fri", value: 2.9, color: .red),
        ChartDataPoint(label: "Sat", value: 4.5, color: .green),
        ChartDataPoint(label: "Sun", value: 4.2, color: .green)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            // Simple bar chart placeholder
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(data) { point in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(point.color ?? color)
                            .frame(width: 24, height: CGFloat(point.value) * 30)
                        
                        Text(point.label)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 140)
            
            Text("TODO: Replace with real chart library")
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Specific Chart Types
struct MoodChart: View {
    let weekData: [Double] // Mood scores 1-5 for each day
    
    init(weekData: [Double] = [3.2, 2.8, 4.1, 3.7, 2.9, 4.5, 4.2]) {
        self.weekData = weekData
    }
    
    var chartData: [PlaceholderChart.ChartDataPoint] {
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return zip(days, weekData).map { day, mood in
            let color: Color = {
                switch mood {
                case 0..<2: return .red
                case 2..<3: return .orange
                case 3..<4: return .gray
                case 4..<5: return .blue
                default: return .green
                }
            }()
            return PlaceholderChart.ChartDataPoint(label: day, value: mood, color: color)
        }
    }
    
    var body: some View {
        PlaceholderChart(
            title: "Weekly Mood Trend",
            data: chartData,
            color: .blue
        )
    }
}

struct ExpenseChart: View {
    var body: some View {
        PlaceholderChart(
            title: "Monthly Expenses",
            data: [
                PlaceholderChart.ChartDataPoint(label: "Edu", value: 4.0, color: .blue),
                PlaceholderChart.ChartDataPoint(label: "Food", value: 3.5, color: .green),
                PlaceholderChart.ChartDataPoint(label: "Health", value: 2.0, color: .red),
                PlaceholderChart.ChartDataPoint(label: "Fun", value: 2.8, color: .orange),
                PlaceholderChart.ChartDataPoint(label: "Other", value: 1.5, color: .gray)
            ],
            color: .green
        )
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            PlaceholderChart(title: "Sample Chart")
            
            MoodChart()
            
            ExpenseChart()
        }
        .padding()
    }
}
