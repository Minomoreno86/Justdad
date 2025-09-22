//
//  ForgivenessTherapyView.swift
//  JustDad - Forgiveness Therapy Main View
//
//  Vista principal para la Terapia del Perdón Pránica de 21 días
//

import SwiftUI

struct ForgivenessTherapyView: View {
    @EnvironmentObject var router: NavigationRouter
    @StateObject private var forgivenessService = ForgivenessService.shared
    @State private var selectedPhase: ForgivenessPhase = .selfForgiveness
    @State private var showingSession = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Premium Background
                LinearGradient(
                    colors: [
                        Color.purple.opacity(0.8),
                        Color.indigo.opacity(0.6),
                        Color.black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Premium Header
                        premiumHeaderView
                        
                        // Progress Overview
                        progressOverviewView
                        
                        // Phase Tabs
                        phaseTabsView
                        
                        // Current Phase Content
                        currentPhaseView
                        
                        // Action Buttons
                        actionButtonsView
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { router.pop() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Terapia del Perdón")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showingSession) {
                ForgivenessSessionView(phase: selectedPhase, day: getCurrentDayForPhase())
            }
            .sheet(isPresented: $showingSettings) {
                ForgivenessSettingsView()
            }
        }
    }
    
    // MARK: - Premium Header View
    
    private var premiumHeaderView: some View {
        VStack(spacing: 20) {
            // Main Icon with Glow Effect
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.pink.opacity(0.3), .purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.pink.opacity(0.8), .purple.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "heart.fill")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .white.opacity(0.3), radius: 5, x: 0, y: 0)
                    )
            }
            
            // Title with Premium Typography
            VStack(spacing: 12) {
                Text("Terapia del Perdón")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                
                Text("Pránica")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.yellow)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
            
            // Subtitle with Glass Effect
            Text("21 días de liberación emocional y sanación profunda")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Progress Overview
    
    private var progressOverviewView: some View {
        VStack(spacing: 20) {
            // Progress Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.yellow)
                    
                    Text("Progreso General")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("\(getTotalCompletedDays())/21 días")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.yellow)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.3))
                            .overlay(
                                Capsule()
                                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
            
            // Premium Progress Bar
            VStack(spacing: 8) {
                ProgressView()
                    .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
                    .scaleEffect(y: 3)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.3))
                    )
                
                Text("\(Int((Double(getTotalCompletedDays()) / 21.0) * 100))% Completado")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Stats Cards
            HStack(spacing: 12) {
                premiumStatCard(
                    icon: "checkmark.circle.fill",
                    title: "Sesiones",
                    value: "\(forgivenessService.currentSessions.filter { $0.isCompleted }.count)",
                    color: .green
                )
                
                premiumStatCard(
                    icon: "flame.fill",
                    title: "Racha Actual",
                    value: "\(getCurrentStreak())",
                    color: .orange
                )
                
                premiumStatCard(
                    icon: "arrow.up.circle.fill",
                    title: "Mejora",
                    value: "+\(getAverageImprovement())",
                    color: .blue
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func premiumStatCard(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Phase Tabs
    
    private var phaseTabsView: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.yellow)
                
                Text("Fases de la Terapia")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(ForgivenessPhase.allCases) { phase in
                        premiumPhaseTabButton(phase: phase)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func premiumPhaseTabButton(phase: ForgivenessPhase) -> some View {
        Button(action: { selectedPhase = phase }) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            selectedPhase == phase ? 
                            LinearGradient(colors: [.pink.opacity(0.8), .purple.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                            LinearGradient(colors: [Color.white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(selectedPhase == phase ? Color.pink : Color.white.opacity(0.3), lineWidth: 2)
                        )
                    
                    Image(systemName: phase.icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(selectedPhase == phase ? .white : .white.opacity(0.8))
                }
                
                VStack(spacing: 4) {
                    Text(phase.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Días \(phase.startDay)-\(phase.endDay)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .frame(width: 110, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedPhase == phase ? Color.pink.opacity(0.2) : Color.black.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(selectedPhase == phase ? Color.pink.opacity(0.5) : Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Current Phase View
    
    private var currentPhaseView: some View {
        VStack(spacing: 20) {
            // Phase Header
            VStack(spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.pink.opacity(0.8), .purple.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: selectedPhase.icon)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedPhase.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Días \(selectedPhase.startDay)-\(selectedPhase.endDay)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                }
                
                Text(selectedPhase.description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 52)
            }
            
            // Days Grid
            VStack(spacing: 12) {
                HStack {
                    Text("Progreso de la Fase")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(getPhaseCompletedDays())/\(selectedPhase.endDay - selectedPhase.startDay + 1) días")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.yellow)
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(selectedPhase.startDay...selectedPhase.endDay, id: \.self) { day in
                        premiumDayButton(day: day)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func premiumDayButton(day: Int) -> some View {
        let isCompleted = isDayCompleted(day)
        let isCurrentDay = day == getCurrentDayForPhase()
        
        return Button(action: {
            if isCurrentDay || isCompleted {
                showingSession = true
            }
        }) {
            VStack(spacing: 6) {
                Text("\(day)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 16, weight: .bold))
                        .shadow(color: .green.opacity(0.5), radius: 3, x: 0, y: 0)
                } else if isCurrentDay {
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 16, weight: .bold))
                        .shadow(color: .yellow.opacity(0.5), radius: 3, x: 0, y: 0)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.white.opacity(0.4))
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .frame(width: 44, height: 56)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isCurrentDay ? 
                        LinearGradient(colors: [.yellow.opacity(0.3), .orange.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        isCompleted ?
                        LinearGradient(colors: [.green.opacity(0.3), .mint.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: [Color.black.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isCurrentDay ? Color.yellow.opacity(0.5) :
                                isCompleted ? Color.green.opacity(0.5) :
                                Color.white.opacity(0.2), 
                                lineWidth: isCurrentDay || isCompleted ? 2 : 1
                            )
                    )
            )
        }
        .disabled(!isCurrentDay && !isCompleted)
        .scaleEffect(isCurrentDay ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isCurrentDay)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtonsView: some View {
        VStack(spacing: 16) {
            // Main Action Button
            Button(action: { showingSession = true }) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "play.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Iniciar Sesión del Día \(getCurrentDayForPhase())")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Comienza tu jornada de sanación")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [.pink.opacity(0.8), .purple.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .pink.opacity(0.3), radius: 10, x: 0, y: 5)
                )
            }
            
            // Secondary Action Button
            if hasCompletedSessions() {
                Button(action: { 
                    // Show progress details
                }) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.3))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.yellow)
                        }
                        
                        Text("Ver Progreso Detallado")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getTotalCompletedDays() -> Int {
        return forgivenessService.currentSessions.filter { $0.isCompleted }.count
    }
    
    private func getCurrentStreak() -> Int {
        let statistics = forgivenessService.getStatistics()
        return statistics.currentStreak
    }
    
    private func getAverageImprovement() -> Int {
        let statistics = forgivenessService.getStatistics()
        return Int(statistics.averagePeaceLevelImprovement)
    }
    
    private func isDayCompleted(_ day: Int) -> Bool {
        return forgivenessService.currentSessions.contains { $0.day == day && $0.isCompleted }
    }
    
    private func getCurrentDayForPhase() -> Int {
        let completedDays = forgivenessService.currentSessions.filter { $0.isCompleted }.map { $0.day }
        
        for day in selectedPhase.startDay...selectedPhase.endDay {
            if !completedDays.contains(day) {
                return day
            }
        }
        
        return selectedPhase.endDay
    }
    
    private func hasCompletedSessions() -> Bool {
        return !forgivenessService.currentSessions.filter { $0.isCompleted }.isEmpty
    }
    
    private func getPhaseCompletedDays() -> Int {
        return forgivenessService.currentSessions.filter { session in
            session.day >= selectedPhase.startDay && 
            session.day <= selectedPhase.endDay && 
            session.isCompleted
        }.count
    }
}

#Preview {
    ForgivenessTherapyView()
        .environmentObject(NavigationRouter())
}
