//
//  HomeView.swift
//  SoloPapá - Dashboard/Home screen
//
//  Shows quick overview cards and main navigation
//

import SwiftUI

struct HomeView: View {
    // MARK: - Properties
    @ObservedObject private var router = NavigationRouter.shared
    
    // MARK: - State
    @State private var currentDate = Date()
    @State private var username = "Papá"
    
    // Mock data
    private let recentVisits = MockData.visits.prefix(3)
    private let weekExpenses = MockData.expenses.prefix(5)
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Section
                    headerSection
                    
                    // Stats Cards Section
                    statsSection
                    
                    // Quick Actions Section
                    quickActionsSection
                    
                    // Recent Activity Section
                    recentActivitySection
                }
                .padding()
            }
            .navigationTitle("JustDad")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { router.push(.settings) }) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hola, \(username)")
                .font(Typography.displayMedium)
                .foregroundColor(Palette.textPrimary)
            
            Text(currentDate.formatted(date: .complete, time: .omitted))
                .font(Typography.bodyMedium)
                .foregroundColor(Palette.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                HomeStatCard(
                    title: "Visitas esta semana",
                    value: "3",
                    unit: "citas",
                    color: Palette.primary,
                    icon: "calendar.badge.clock"
                )
                
                HomeStatCard(
                    title: "Gastos del mes",
                    value: "$450",
                    unit: "total",
                    color: Palette.secondary,
                    icon: "dollarsign.circle"
                )
            }
            
            HStack(spacing: 12) {
                HomeStatCard(
                    title: "Entradas de diario",
                    value: "12",
                    unit: "este mes",
                    color: Palette.tertiary,
                    icon: "book.fill"
                )
                
                HomeStatCard(
                    title: "Estado de ánimo",
                    value: "😊",
                    unit: "promedio",
                    color: Palette.success,
                    icon: "heart.fill"
                )
            }
        }
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Acciones rápidas")
                .font(Typography.titleMedium)
                .foregroundColor(Palette.textPrimary)
            
            VStack(spacing: 8) {
                QuickActionRow(
                    title: "Ver agenda",
                    icon: "calendar",
                    color: Palette.primary
                ) {
                    router.push(.agenda)
                }
                
                QuickActionRow(
                    title: "Agregar visita",
                    icon: "plus.circle",
                    color: Palette.secondary
                ) {
                    router.push(.agendaAddVisit)
                }
                
                QuickActionRow(
                    title: "Nueva entrada de diario",
                    icon: "square.and.pencil",
                    color: Palette.tertiary
                ) {
                    router.push(.journalNew)
                }
            }
        }
    }
    
    // MARK: - Recent Activity Section
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Actividad reciente")
                .font(Typography.titleMedium)
                .foregroundColor(Palette.textPrimary)
            
            VStack(spacing: 8) {
                ForEach(Array(recentVisits.enumerated()), id: \.offset) { index, visit in
                    RecentVisitCard(visit: visit)
                }
            }
        }
    }
}

// MARK: - Home Stat Card Component
struct HomeStatCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(Typography.displaySmall)
                .foregroundColor(Palette.textPrimary)
            
            Text(title)
                .font(Typography.bodySmall)
                .foregroundColor(Palette.textSecondary)
            
            Text(unit)
                .font(Typography.captionMedium)
                .foregroundColor(Palette.textTertiary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.surfaceContainer)
        .cornerRadius(12)
    }
}

// MARK: - Dashboard Card Component
struct DashboardCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                    Spacer()
                }
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Quick Action Row Component
struct QuickActionRow: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Recent Visit Card Component
struct RecentVisitCard: View {
    let visit: MockVisit
    
    var body: some View {
        HStack {
            Circle()
                .fill(Palette.primary)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(visit.title)
                    .font(Typography.bodyMedium)
                    .foregroundColor(Palette.textPrimary)
                
                Text(visit.date.formatted(date: .abbreviated, time: .shortened))
                    .font(Typography.captionMedium)
                    .foregroundColor(Palette.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Palette.textTertiary)
        }
        .padding()
        .background(Palette.surfaceContainer)
        .cornerRadius(8)
    }
}

#Preview {
    HomeView()
}
