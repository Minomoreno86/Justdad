//
//  HomeView.swift
//  JustDad - Professional Dashboard
//
//  Modern home screen with professional design for fathers managing family life
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct HomeView: View {
    // MARK: - Navigation
    @Binding var selectedTab: MainTabView.Tab
    
    // MARK: - ViewModel
    @StateObject private var viewModel: HomeViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    init(selectedTab: Binding<MainTabView.Tab>) {
        self._selectedTab = selectedTab
        self._viewModel = StateObject(wrappedValue: HomeViewModel(selectedTab: selectedTab))
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.gray.opacity(0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 24) {
                        // Hero Header Section
                        heroHeaderSection
                        
                        // Today's Overview
                        todaysOverviewSection
                        
                        // Stats Dashboard
                        statsDashboardSection
                        
                        // Quick Actions Grid
                        quickActionsGridSection
                        
                        // Today's Schedule
                        todaysScheduleSection
                        
                        // Recent Activity Feed
                        recentActivityFeedSection
                        
                        // Dad Tips Section
                        dadTipsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100) // Extra padding for tab bar
                }
                .refreshable {
                    await viewModel.refreshData()
                }
                .onAppear {
                    viewModel.onAppear()
                }
            }
        }
    }
    
    // MARK: - Hero Header Section
    private var heroHeaderSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.greetingMessage)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(viewModel.username)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(viewModel.currentTime.formatted(date: .complete, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Profile & Settings
                HStack(spacing: 12) {
                    Button(action: {}) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .frame(width: 44, height: 44)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    // Avatar
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(String(viewModel.username.prefix(1)).uppercased())
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        )
                }
            }
            .padding(.top, 8)
        }
    }
    
    // MARK: - Today's Overview Section
    private var todaysOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Hoy en resumen")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(viewModel.currentTime.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .clipShape(Capsule())
            }
            
            HStack(spacing: 12) {
                // Tasks counter
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color.orange)
                    
                    VStack(spacing: 2) {
                        Text("\(viewModel.todaysOverview.pendingTasks)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Tareas")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("pendientes")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Next visit
                VStack(spacing: 8) {
                    Image(systemName: "calendar.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color.blue)
                    
                    VStack(spacing: 2) {
                        Text(viewModel.nextAppointmentText)
                            .font(.title2)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        
                        Text("Próxima")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("cita")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Mood tracker
                VStack(spacing: 8) {
                    Image(systemName: "heart.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color.pink)
                    
                    VStack(spacing: 2) {
                        Text(viewModel.todaysOverview.currentMood?.displayName ?? "😊")
                            .font(.title2)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        
                        Text("Ánimo")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("actual")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Stats Dashboard Section
    private var statsDashboardSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Estadísticas")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .font(.title3)
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    
                    Text("\(viewModel.dashboardStats.visitsThisWeek)")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)
                    
                    Text("Visitas esta semana")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Total de visitas")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "dollarsign.circle")
                            .font(.title3)
                            .foregroundColor(.green)
                        Spacer()
                    }
                    
                    Text("$\(viewModel.dashboardStats.monthlyExpenses, format: .number.precision(.fractionLength(0)))")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)
                    
                    Text("Gastos del mes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Total mensual")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "heart.circle")
                            .font(.title3)
                            .foregroundColor(.red)
                        Spacer()
                    }
                    
                    Text("\(viewModel.dashboardStats.qualityTimeHours)h")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)
                    
                    Text("Horas de calidad")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Esta semana")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "figure.run.circle")
                            .font(.title3)
                            .foregroundColor(.purple)
                        Spacer()
                    }
                    
                    Text("\(viewModel.dashboardStats.activitiesThisWeek)")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)
                    
                    Text("Actividades")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Esta semana")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Quick Actions Grid Section
    private var quickActionsGridSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Acciones rápidas")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                
                Button(action: { viewModel.addNewVisit() }) {
                    VStack(spacing: 12) {
                        Circle()
                            .fill(LinearGradient(colors: [Color.blue, Color.cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(spacing: 4) {
                            Text("Nueva visita")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("Agendar cita")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                }
                
                Button(action: { viewModel.navigateToAgenda() }) {
                    VStack(spacing: 12) {
                        Circle()
                            .fill(LinearGradient(colors: [Color.purple, Color.pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "calendar.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(spacing: 4) {
                            Text("Ver agenda")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("Próximas citas")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                }
                
                Button(action: { viewModel.writeJournalEntry() }) {
                    VStack(spacing: 12) {
                        Circle()
                            .fill(LinearGradient(colors: [Color.orange, Color.red], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "square.and.pencil.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(spacing: 4) {
                            Text("Escribir diario")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("Nueva entrada")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                }
                
                Button(action: { viewModel.openSOS() }) {
                    VStack(spacing: 12) {
                        Circle()
                            .fill(LinearGradient(colors: [Color.red, Color.pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(spacing: 4) {
                            Text("SOS Urgente")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("Emergencia")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                }
            }
        }
    }
    
    // MARK: - Today's Schedule Section
    private var todaysScheduleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Agenda de hoy")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Ver todo") {}
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            if viewModel.todaysVisits.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 8) {
                        Text("Sin citas hoy")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("¡Perfecto día para relajarse!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 40)
                .padding(.horizontal, 20)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.todaysVisits.prefix(3)) { visit in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(visit.title)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text(visit.startDate.formatted(date: .omitted, time: .shortened))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "calendar.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                    }
                }
                .padding(.vertical, 40)
                .padding(.horizontal, 20)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
            }
        }
    }
    
    // MARK: - Recent Activity Feed Section
    private var recentActivityFeedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Actividad reciente")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                if viewModel.recentActivities.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.badge")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 8) {
                            Text("Sin actividad reciente")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("Las actividades aparecerán aquí")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ForEach(viewModel.recentActivities) { activity in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [activity.color, activity.color.opacity(0.7)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: activity.icon)
                                        .foregroundColor(.white)
                                        .font(.system(size: 18, weight: .semibold))
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(activity.title)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text(activity.subtitle)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(timeAgoString(from: activity.timestamp))
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(activity.color.opacity(0.2))
                                .foregroundColor(activity.color)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    // MARK: - Dad Tips Section
    private var dadTipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Consejo del día")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // Dad Tip Card con diseño profesional
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("💡")
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Consejo de comunicación")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Dedica 10 minutos cada día para preguntar a tu hijo sobre su día, sin distracciones.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(nil)
                    }
                    
                    Spacer()
                }
                
                HStack {
                    HStack(spacing: 6) {
                        ForEach(0..<4, id: \.self) { index in
                            Circle()
                                .fill(index == 0 ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 6, height: 6)
                        }
                    }
                    
                    Spacer()
                    
                    Button("Siguiente consejo") {
                        // Lógica para siguiente consejo
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.05),
                                Color.purple.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
    }
    
    // MARK: - Helper Functions
    private func timeAgoString(from date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        if timeInterval < 60 {
            return "Hace un momento"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "Hace \(minutes) min"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "Hace \(hours)h"
        } else {
            let days = Int(timeInterval / 86400)
            return days == 1 ? "Ayer" : "Hace \(days) días"
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home))
}
