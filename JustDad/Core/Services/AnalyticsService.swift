//
//  AnalyticsService.swift
//  JustDad - Analytics and Reporting Service
//
//  Professional analytics service for tracking usage patterns and generating insights
//

import Foundation
import SwiftUI
import Combine

// Import agenda types
import EventKit

// MARK: - Analytics Service
@MainActor
class AnalyticsService: ObservableObject {
    static let shared = AnalyticsService()
    
    @Published var isGeneratingReport = false
    @Published var lastReportGenerated: Date?
    
    private let userDefaults = UserDefaults.standard
    private let analyticsKey = "analytics_data"
    
    private init() {
        loadAnalyticsData()
    }
    
    // MARK: - Visit Analytics
    func getVisitAnalytics(visits: [AgendaVisit]) -> VisitAnalytics {
        let calendar = Calendar.current
        let now = Date()
        
        // Time-based filtering
        let thisMonth = visits.filter { calendar.isDate($0.startDate, equalTo: now, toGranularity: .month) }
        let lastMonth = visits.filter { 
            guard let lastMonthDate = calendar.date(byAdding: .month, value: -1, to: now) else { return false }
            return calendar.isDate($0.startDate, equalTo: lastMonthDate, toGranularity: .month)
        }
        
        // Visit type distribution
        let typeDistribution = Dictionary(grouping: visits, by: { $0.visitType })
            .mapValues { $0.count }
        
        // Average duration calculation
        let totalDuration = visits.reduce(0) { sum, visit in
            sum + visit.endDate.timeIntervalSince(visit.startDate)
        }
        let averageDuration = visits.isEmpty ? 0 : totalDuration / Double(visits.count)
        
        // Monthly trends
        let monthlyData = getMonthlyVisitTrends(visits: visits)
        
        // Most frequent locations
        let locationFrequency = Dictionary(grouping: visits.compactMap { $0.location }, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        return VisitAnalytics(
            totalVisits: visits.count,
            thisMonthVisits: thisMonth.count,
            lastMonthVisits: lastMonth.count,
            averageDurationMinutes: Int(averageDuration / 60),
            visitTypeDistribution: typeDistribution,
            monthlyTrends: monthlyData,
            topLocations: Array(locationFrequency.prefix(5)),
            completionRate: calculateCompletionRate(visits: visits),
            upcomingVisits: visits.filter { $0.startDate > now }.count
        )
    }
    
    // MARK: - Dashboard Metrics
    func getDashboardMetrics(visits: [AgendaVisit]) -> DashboardMetrics {
        let calendar = Calendar.current
        let now = Date()
        
        // Today's visits
        let todayVisits = visits.filter { calendar.isDate($0.startDate, inSameDayAs: now) }
        
        // This week's visits
        let thisWeekVisits = visits.filter { calendar.isDate($0.startDate, equalTo: now, toGranularity: .weekOfYear) }
        
        // Next visit
        let nextVisit = visits
            .filter { $0.startDate > now }
            .sorted { $0.startDate < $1.startDate }
            .first
        
        // Streak calculation
        let visitStreak = calculateVisitStreak(visits: visits)
        
        return DashboardMetrics(
            todayVisits: todayVisits.count,
            thisWeekVisits: thisWeekVisits.count,
            nextVisit: nextVisit,
            currentStreak: visitStreak,
            totalTime: calculateTotalTimeSpent(visits: visits),
            averagePerWeek: calculateAverageVisitsPerWeek(visits: visits)
        )
    }
    
    // MARK: - Report Generation
    func generateComprehensiveReport(visits: [AgendaVisit]) async -> AnalyticsReport {
        isGeneratingReport = true
        defer { isGeneratingReport = false }
        
        // Simulate processing time
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        let visitAnalytics = getVisitAnalytics(visits: visits)
        let dashboardMetrics = getDashboardMetrics(visits: visits)
        
        let report = AnalyticsReport(
            generatedDate: Date(),
            period: DateInterval(start: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(), 
                                end: Date()),
            visitAnalytics: visitAnalytics,
            dashboardMetrics: dashboardMetrics,
            insights: generateInsights(visitAnalytics: visitAnalytics),
            recommendations: generateRecommendations(visitAnalytics: visitAnalytics)
        )
        
        lastReportGenerated = Date()
        return report
    }
    
    // MARK: - Private Helper Methods
    private func getMonthlyVisitTrends(visits: [AgendaVisit]) -> [MonthlyData] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: visits) { visit in
            calendar.dateInterval(of: .month, for: visit.startDate)?.start ?? visit.startDate
        }
        
        return grouped.map { date, visits in
            let hours = visits.reduce(0.0) { sum, visit in
                sum + visit.endDate.timeIntervalSince(visit.startDate) / 3600
            }
            return MonthlyData(
                month: date,
                visitCount: visits.count,
                totalHours: hours
            )
        }.sorted { $0.month < $1.month }
    }
    
    private func calculateCompletionRate(visits: [AgendaVisit]) -> Double {
        let pastVisits = visits.filter { $0.endDate < Date() }
        // For now, assume all past visits were completed
        // In a real implementation, you'd track actual completion status
        return pastVisits.isEmpty ? 1.0 : 1.0
    }
    
    private func calculateVisitStreak(visits: [AgendaVisit]) -> Int {
        let calendar = Calendar.current
        let now = Date()
        var streak = 0
        var currentDate = now
        
        // Count consecutive weeks with visits
        for _ in 0..<52 { // Check up to 52 weeks back
            let weekVisits = visits.filter { 
                calendar.isDate($0.startDate, equalTo: currentDate, toGranularity: .weekOfYear)
            }
            
            if weekVisits.isEmpty {
                break
            }
            
            streak += 1
            guard let previousWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate) else { break }
            currentDate = previousWeek
        }
        
        return streak
    }
    
    private func calculateTotalTimeSpent(visits: [AgendaVisit]) -> TimeInterval {
        return visits.reduce(0) { sum, visit in
            sum + visit.endDate.timeIntervalSince(visit.startDate)
        }
    }
    
    private func calculateAverageVisitsPerWeek(visits: [AgendaVisit]) -> Double {
        let calendar = Calendar.current
        let now = Date()
        guard let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: now) else { return 0 }
        
        let recentVisits = visits.filter { $0.startDate >= sixMonthsAgo }
        let weeks = calendar.dateComponents([.weekOfYear], from: sixMonthsAgo, to: now).weekOfYear ?? 1
        
        return weeks == 0 ? 0 : Double(recentVisits.count) / Double(weeks)
    }
    
    private func generateInsights(visitAnalytics: VisitAnalytics) -> [AnalyticsInsight] {
        var insights: [AnalyticsInsight] = []
        
        // Most active visit type
        if let mostFrequentType = visitAnalytics.visitTypeDistribution.max(by: { $0.value < $1.value }) {
            insights.append(AnalyticsInsight(
                title: "Tipo de visita más frecuente",
                description: "El \(mostFrequentType.value)% de tus visitas son de tipo \(mostFrequentType.key.displayName)",
                icon: "chart.bar.fill",
                color: Color.blue
            ))
        }
        
        // Duration insight
        if visitAnalytics.averageDurationMinutes > 120 {
            insights.append(AnalyticsInsight(
                title: "Visitas de calidad",
                description: "Tus visitas duran un promedio de \(visitAnalytics.averageDurationMinutes / 60) horas, excelente tiempo de calidad",
                icon: "clock.fill",
                color: Color.green
            ))
        }
        
        // Monthly trend
        if visitAnalytics.thisMonthVisits > visitAnalytics.lastMonthVisits {
            let increase = visitAnalytics.thisMonthVisits - visitAnalytics.lastMonthVisits
            insights.append(AnalyticsInsight(
                title: "Tendencia positiva",
                description: "Has aumentado \(increase) visitas este mes comparado con el anterior",
                icon: "arrow.up.circle.fill",
                color: Color.green
            ))
        }
        
        return insights
    }
    
    private func generateRecommendations(visitAnalytics: VisitAnalytics) -> [AnalyticsRecommendation] {
        var recommendations: [AnalyticsRecommendation] = []
        
        // Consistency recommendation
        if visitAnalytics.thisMonthVisits < 4 {
            recommendations.append(AnalyticsRecommendation(
                title: "Aumenta la frecuencia",
                description: "Considera programar al menos una visita por semana para mantener una conexión constante",
                priority: .high,
                actionable: true
            ))
        }
        
        // Variety recommendation
        if visitAnalytics.visitTypeDistribution.count < 3 {
            recommendations.append(AnalyticsRecommendation(
                title: "Diversifica las actividades",
                description: "Prueba diferentes tipos de visitas para enriquecer la experiencia",
                priority: .medium,
                actionable: true
            ))
        }
        
        // Planning recommendation
        if visitAnalytics.upcomingVisits < 2 {
            recommendations.append(AnalyticsRecommendation(
                title: "Planifica con anticipación",
                description: "Programa más visitas futuras para mejor organización",
                priority: .medium,
                actionable: true
            ))
        }
        
        return recommendations
    }
    
    // MARK: - Data Persistence
    private func loadAnalyticsData() {
        // Load any saved analytics preferences
    }
    
    private func saveAnalyticsData() {
        // Save analytics preferences
    }
}

// MARK: - Data Models
struct VisitAnalytics {
    let totalVisits: Int
    let thisMonthVisits: Int
    let lastMonthVisits: Int
    let averageDurationMinutes: Int
    let visitTypeDistribution: [AgendaVisitType: Int]
    let monthlyTrends: [MonthlyData]
    let topLocations: [(key: String, value: Int)]
    let completionRate: Double
    let upcomingVisits: Int
}

struct DashboardMetrics {
    let todayVisits: Int
    let thisWeekVisits: Int
    let nextVisit: AgendaVisit?
    let currentStreak: Int
    let totalTime: TimeInterval
    let averagePerWeek: Double
}

struct MonthlyData: Identifiable {
    let id = UUID()
    let month: Date
    let visitCount: Int
    let totalHours: Double
}

struct AnalyticsReport {
    let generatedDate: Date
    let period: DateInterval
    let visitAnalytics: VisitAnalytics
    let dashboardMetrics: DashboardMetrics
    let insights: [AnalyticsInsight]
    let recommendations: [AnalyticsRecommendation]
}

struct AnalyticsRecommendation: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let priority: Priority
    let actionable: Bool
    
    enum Priority {
        case high, medium, low
        
        var color: Color {
            switch self {
            case .high: return .red
            case .medium: return .orange
            case .low: return .gray
            }
        }
    }
}
