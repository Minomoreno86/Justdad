//
//  SearchStatsView.swift
//  JustDad - Search Statistics Component
//
//  Professional search statistics display with filter insights
//

import SwiftUI

struct SearchStatsView: View {
    // MARK: - Properties
    let totalVisits: Int
    let filteredVisits: Int
    let searchFilter: AdvancedSearchFilter
    
    // MARK: - Computed Properties
    private var isFiltered: Bool {
        return filteredVisits != totalVisits
    }
    
    private var filterPercentage: Double {
        guard totalVisits > 0 else { return 0 }
        return Double(filteredVisits) / Double(totalVisits) * 100
    }
    
    // MARK: - Body
    var body: some View {
        if isFiltered {
            HStack(spacing: SuperDesign.Tokens.space.sm) {
                // Filter Icon
                Image(systemName: "line.3.horizontal.decrease")
                    .foregroundColor(SuperDesign.Tokens.colors.primary)
                    .font(.system(size: 14))
                
                // Stats Text
                VStack(alignment: .leading, spacing: 2) {
                    Text("Mostrando \(filteredVisits) de \(totalVisits) visitas")
                        .font(SuperDesign.Tokens.typography.bodySmall)
                        .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                    
                    if searchFilter.hasActiveFilters {
                        Text("\(searchFilter.activeFilterCount) filtros activos")
                            .font(SuperDesign.Tokens.typography.labelSmall)
                            .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                    }
                }
                
                Spacer()
                
                // Clear Filters Button
                Button(action: {
                    // This will be handled by the parent view
                }) {
                    HStack(spacing: SuperDesign.Tokens.space.xxs) {
                        Image(systemName: "xmark.circle.fill")
                        Text("Limpiar")
                    }
                    .font(SuperDesign.Tokens.typography.labelSmall)
                    .foregroundColor(SuperDesign.Tokens.colors.error)
                }
            }
            .padding(.horizontal, SuperDesign.Tokens.space.md)
            .padding(.vertical, SuperDesign.Tokens.space.sm)
            .background(SuperDesign.Tokens.colors.primary.opacity(0.05))
            .cornerRadius(SuperDesign.Tokens.space.sm)
            .padding(.horizontal, SuperDesign.Tokens.space.md)
        }
    }
}

// MARK: - Search Insights View
struct SearchInsightsView: View {
    // MARK: - Properties
    let visits: [AgendaVisit]
    let searchFilter: AdvancedSearchFilter
    
    // MARK: - Computed Properties
    private var visitTypeDistribution: [(AgendaVisitType, Int)] {
        let typeCounts = Dictionary(grouping: visits, by: { $0.visitType })
            .mapValues { $0.count }
        
        return AgendaVisitType.allCases.compactMap { visitType in
            guard let count = typeCounts[visitType], count > 0 else { return nil }
            return (visitType, count)
        }.sorted { $0.1 > $1.1 }
    }
    
    private var timeDistribution: [(String, Int)] {
        let calendar = Calendar.current
        let morning = visits.filter { visit in
            let hour = calendar.component(.hour, from: visit.startDate)
            return hour >= 6 && hour < 12
        }.count
        
        let afternoon = visits.filter { visit in
            let hour = calendar.component(.hour, from: visit.startDate)
            return hour >= 12 && hour < 18
        }.count
        
        let evening = visits.filter { visit in
            let hour = calendar.component(.hour, from: visit.startDate)
            return hour >= 18 && hour < 22
        }.count
        
        let night = visits.filter { visit in
            let hour = calendar.component(.hour, from: visit.startDate)
            return hour >= 22 || hour < 6
        }.count
        
        return [
            ("Mañana", morning),
            ("Tarde", afternoon),
            ("Noche", evening),
            ("Madrugada", night)
        ].filter { $0.1 > 0 }
    }
    
    private var averageDuration: TimeInterval {
        guard !visits.isEmpty else { return 0 }
        let totalDuration = visits.reduce(0) { total, visit in
            total + visit.endDate.timeIntervalSince(visit.startDate)
        }
        return totalDuration / Double(visits.count)
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.md) {
            // Header
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(SuperDesign.Tokens.colors.primary)
                Text("Insights de Búsqueda")
                    .font(SuperDesign.Tokens.typography.titleSmall)
                    .fontWeight(.medium)
            }
            
            // Stats Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: SuperDesign.Tokens.space.sm) {
                // Total Visits
                StatCard(
                    title: "Total",
                    value: "\(visits.count)",
                    icon: "calendar",
                    color: SuperDesign.Tokens.colors.primary
                )
                
                // Average Duration
                StatCard(
                    title: "Duración Promedio",
                    value: formatDuration(averageDuration),
                    icon: "clock",
                    color: SuperDesign.Tokens.colors.info
                )
                
                // Recurring Visits
                let recurringCount = visits.filter { $0.isRecurring }.count
                StatCard(
                    title: "Recurrentes",
                    value: "\(recurringCount)",
                    icon: "repeat",
                    color: SuperDesign.Tokens.colors.warning
                )
                
                // With Notes
                let withNotesCount = visits.filter { $0.notes != nil && !$0.notes!.isEmpty }.count
                StatCard(
                    title: "Con Notas",
                    value: "\(withNotesCount)",
                    icon: "note.text",
                    color: SuperDesign.Tokens.colors.success
                )
            }
            
            // Visit Type Distribution
            if !visitTypeDistribution.isEmpty {
                VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.xs) {
                    Text("Distribución por Tipo")
                        .font(SuperDesign.Tokens.typography.bodyMedium)
                        .fontWeight(.medium)
                    
                    ForEach(visitTypeDistribution.prefix(3), id: \.0) { visitType, count in
                        HStack {
                            Image(systemName: visitType.systemIcon)
                                .foregroundColor(visitTypeColor(visitType))
                                .frame(width: 16)
                            
                            Text(visitType.displayName)
                                .font(SuperDesign.Tokens.typography.bodySmall)
                            
                            Spacer()
                            
                            Text("\(count)")
                                .font(SuperDesign.Tokens.typography.bodySmall)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
        }
        .padding(SuperDesign.Tokens.space.md)
        .background(SuperDesign.Tokens.colors.surfaceSecondary)
        .cornerRadius(SuperDesign.Tokens.space.sm)
        .padding(.horizontal, SuperDesign.Tokens.space.md)
    }
    
    // MARK: - Helper Methods
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func visitTypeColor(_ type: AgendaVisitType) -> Color {
        switch type {
        case .medical: return SuperDesign.Tokens.colors.error
        case .school: return SuperDesign.Tokens.colors.info
        case .activity: return SuperDesign.Tokens.colors.success
        case .weekend: return SuperDesign.Tokens.colors.warning
        case .dinner: return SuperDesign.Tokens.colors.accent
        case .emergency: return SuperDesign.Tokens.colors.error
        case .general: return SuperDesign.Tokens.colors.primary
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: SuperDesign.Tokens.space.xs) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 20))
            
            Text(value)
                .font(SuperDesign.Tokens.typography.titleMedium)
                .fontWeight(.bold)
                .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
            
            Text(title)
                .font(SuperDesign.Tokens.typography.labelSmall)
                .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(SuperDesign.Tokens.space.sm)
        .background(color.opacity(0.1))
        .cornerRadius(SuperDesign.Tokens.space.sm)
    }
}

