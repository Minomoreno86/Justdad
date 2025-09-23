//
//  ConflictWellnessView.swift
//  JustDad - Conflict Wellness Main View
//
//  Main interface for conflict wellness and coparenting management
//

import SwiftUI

struct ConflictWellnessView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var service = ConflictWellnessService.shared
    @State private var selectedTab: ConflictWellnessTab = .dashboard
    
    enum ConflictWellnessTab: String, CaseIterable {
        case dashboard = "dashboard"
        case communication = "communication"
        case journal = "journal"
        case children = "children"
        case selfCare = "selfCare"
        case achievements = "achievements"
        
        var title: String {
            switch self {
            case .dashboard: return "Dashboard"
            case .communication: return "Comunicación"
            case .journal: return "Bitácora"
            case .children: return "Hijos"
            case .selfCare: return "Autocuidado"
            case .achievements: return "Logros"
            }
        }
        
        var icon: String {
            switch self {
            case .dashboard: return "house.fill"
            case .communication: return "message.fill"
            case .journal: return "book.fill"
            case .children: return "person.2.fill"
            case .selfCare: return "heart.fill"
            case .achievements: return "trophy.fill"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Tab Selector
                tabSelectorView
                
                // Content
                TabView(selection: $selectedTab) {
                    dashboardView
                        .tag(ConflictWellnessTab.dashboard)
                    
                    communicationView
                        .tag(ConflictWellnessTab.communication)
                    
                    journalView
                        .tag(ConflictWellnessTab.journal)
                    
                    childrenView
                        .tag(ConflictWellnessTab.children)
                    
                    selfCareView
                        .tag(ConflictWellnessTab.selfCare)
                    
                    achievementsView
                        .tag(ConflictWellnessTab.achievements)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("Gestión de Conflictos")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Bienestar en la Coparentalidad")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { /* Settings */ }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .background(Color(UIColor.systemBackground))
    }
    
    // MARK: - Tab Selector
    private var tabSelectorView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ConflictWellnessTab.allCases, id: \.self) { tab in
                    Button(action: { 
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 6) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 18, weight: .medium))
                            
                            Text(tab.title)
                                .font(.caption)
                                .fontWeight(.medium)
                                .lineLimit(1)
                        }
                        .foregroundColor(selectedTab == tab ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedTab == tab ? Color.blue : Color.gray.opacity(0.1))
                        )
                        .scaleEffect(selectedTab == tab ? 1.05 : 1.0)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Dashboard View
    private var dashboardView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Welcome Section
                welcomeSection
                
                // Daily Affirmation
                if let affirmation = service.currentAffirmation {
                    dailyAffirmationSection(affirmation)
                }
                
                // Quick Stats
                quickStatsSection
                
                // Recent Activity
                recentActivitySection
                
                // Quick Actions
                quickActionsSection
            }
            .padding()
        }
    }
    
    private var welcomeSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Bienvenido a tu Centro de Bienestar")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Herramientas para mantener la serenidad y proteger el bienestar familiar")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func dailyAffirmationSection(_ affirmation: DailyAffirmation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("Afirmación del Día")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text(affirmation.text)
                .font(.body)
                .italic()
                .foregroundColor(.primary)
            
            Text("— \(affirmation.category)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tu Progreso")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ConflictStatCard(
                    title: "Respuestas Serenas",
                    value: "\(service.stats.serenaResponses)",
                    subtitle: "de \(service.stats.totalResponses) total",
                    color: .green,
                    icon: "checkmark.shield.fill"
                )
                
                ConflictStatCard(
                    title: "Racha Actual",
                    value: "\(service.stats.currentStreak)",
                    subtitle: "días consecutivos",
                    color: .blue,
                    icon: "flame.fill"
                )
                
                ConflictStatCard(
                    title: "Entradas Bitácora",
                    value: "\(service.stats.journalEntries)",
                    subtitle: "registros escritos",
                    color: .orange,
                    icon: "book.fill"
                )
                
                ConflictStatCard(
                    title: "Puntos Totales",
                    value: "\(service.stats.totalPoints)",
                    subtitle: "puntos acumulados",
                    color: .purple,
                    icon: "star.fill"
                )
            }
        }
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Actividad Reciente")
                .font(.headline)
                .fontWeight(.semibold)
            
            if service.sessions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text("No hay actividad reciente")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Comienza practicando comunicación serena o registrando en tu bitácora")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(service.sessions.suffix(3).reversed()) { session in
                        RecentActivityRow(session: session)
                    }
                }
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Acciones Rápidas")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ConflictQuickActionCard(
                    title: "Entrenar Respuesta",
                    subtitle: "Practica comunicación serena",
                    icon: "message.fill",
                    color: .blue
                ) {
                    selectedTab = .communication
                }
                
                ConflictQuickActionCard(
                    title: "Registrar en Bitácora",
                    subtitle: "Libera tu mente",
                    icon: "book.fill",
                    color: .orange
                ) {
                    selectedTab = .journal
                }
                
                ConflictQuickActionCard(
                    title: "Validar a Hijos",
                    subtitle: "Apoyo emocional",
                    icon: "person.2.fill",
                    color: .green
                ) {
                    selectedTab = .children
                }
                
                ConflictQuickActionCard(
                    title: "Autocuidado",
                    subtitle: "Fortalece tu bienestar",
                    icon: "heart.fill",
                    color: .purple
                ) {
                    selectedTab = .selfCare
                }
            }
        }
    }
    
    // MARK: - Communication View
    private var communicationView: some View {
        ConflictCommunicationView()
    }
    
    // MARK: - Journal View
    private var journalView: some View {
        ConflictJournalView()
    }
    
    // MARK: - Children View
    private var childrenView: some View {
        ConflictChildrenView()
    }
    
    // MARK: - Self Care View
    private var selfCareView: some View {
        ConflictSelfCareView()
    }
    
    // MARK: - Achievements View
    private var achievementsView: some View {
        ConflictAchievementsView()
    }
}

// MARK: - Supporting Views

struct ConflictStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

struct ConflictQuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.title2)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecentActivityRow: View {
    let session: ConflictWellnessSession
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: session.type.icon)
                .foregroundColor(Color(session.type.color))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(session.type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(session.date, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if session.completed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    ConflictWellnessView()
}
