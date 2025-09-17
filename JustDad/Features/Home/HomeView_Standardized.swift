//
//  HomeView_Standardized.swift
//  JustDad - Professional Dashboard
//
//  Modern home screen with SuperDesign System consistency
//

import SwiftUI

struct HomeView_Standardized: View {
    // MARK: - State
    @State private var currentDate = Date()
    @State private var username = "Jorge" // Personalizable
    @State private var currentTime = Date()
    @State private var isRefreshing = false
    
    // Mock data - En producción vendría de ViewModels
    private let todaysTasks = ["Llevar a Emma al dentista", "Comprar útiles escolares", "Revisar tareas"]
    
    // Timer for real-time updates
    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                // Background using SuperDesign
                SuperDesign.Tokens.colors.surfaceGradient
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: SuperDesign.Tokens.space.lg) {
                        // Hero Header Section
                        heroHeaderSection
                        
                        // Today's Overview
                        todaysOverviewSection
                        
                        // Stats Dashboard
                        statsDashboardSection
                        
                        // Quick Actions
                        quickActionsSection
                        
                        // Recent Activity
                        recentActivitySection
                        
                        // Empty State (when no data)
                        emptyStateSection
                    }
                    .padding(.horizontal, SuperDesign.Tokens.space.lg)
                    .padding(.top, SuperDesign.Tokens.space.sm)
                }
            }
            .navigationBarHidden(true)
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
        .refreshable {
            await refreshData()
        }
    }
    
    // MARK: - Hero Header Section
    private var heroHeaderSection: some View {
        VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.md) {
            HStack {
                VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.xs) {
                    SuperDesign.Components.heading("¡Hola, \(username)!", size: .large)
                        .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                    
                    SuperDesign.Components.body(
                        currentTime.formatted(date: .omitted, time: .shortened),
                        size: .medium,
                        color: SuperDesign.Tokens.colors.textSecondary
                    )
                }
                
                Spacer()
                
                Button(action: {
                    // Profile action
                }) {
                    Circle()
                        .fill(SuperDesign.Tokens.colors.primary)
                        .frame(width: 44, height: 44)
                        .overlay(
                            SuperDesign.Components.heading("J", size: .small)
                                .foregroundColor(.white)
                        )
                }
            }
            
            // Status indicator
            HStack {
                Circle()
                    .fill(SuperDesign.Tokens.colors.success)
                    .frame(width: 8, height: 8)
                
                SuperDesign.Components.body("Todo bajo control", size: .small)
                    .foregroundColor(SuperDesign.Tokens.colors.success)
            }
            .padding(.horizontal, SuperDesign.Tokens.space.md)
            .padding(.vertical, SuperDesign.Tokens.space.xs)
            .background(SuperDesign.Tokens.colors.success.opacity(0.1))
            .cornerRadius(SuperDesign.Tokens.effects.cornerRadiusSmall)
        }
        .padding(SuperDesign.Tokens.space.lg)
        .background(SuperDesign.Tokens.colors.card)
        .cornerRadius(SuperDesign.Tokens.effects.cornerRadius)
        .shadow(
            color: SuperDesign.Tokens.effects.shadow(for: .medium).0,
            radius: SuperDesign.Tokens.effects.shadow(for: .medium).1,
            x: SuperDesign.Tokens.effects.shadow(for: .medium).2,
            y: SuperDesign.Tokens.effects.shadow(for: .medium).3
        )
    }
    
    // MARK: - Today's Overview Section
    private var todaysOverviewSection: some View {
        SuperDesign.Components.section(title: "Resumen de Hoy") {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: SuperDesign.Tokens.space.md) {
                overviewCard(
                    icon: "calendar.badge.plus",
                    title: "Visitas",
                    value: "3",
                    color: SuperDesign.Tokens.colors.primary
                )
                
                overviewCard(
                    icon: "dollarsign.circle.fill",
                    title: "Gastos",
                    value: "$45",
                    color: SuperDesign.Tokens.colors.warning
                )
                
                overviewCard(
                    icon: "heart.circle.fill",
                    title: "Momentos",
                    value: "12",
                    color: SuperDesign.Tokens.colors.error
                )
            }
        }
    }
    
    private func overviewCard(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: SuperDesign.Tokens.space.sm) {
            Image(systemName: icon)
                .font(SuperDesign.Tokens.typography.titleLarge)
                .foregroundColor(color)
            
            SuperDesign.Components.heading(value, size: .medium)
                .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
            
            SuperDesign.Components.body(title, size: .small)
                .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(SuperDesign.Tokens.space.md)
        .background(SuperDesign.Tokens.colors.card)
        .cornerRadius(SuperDesign.Tokens.effects.cornerRadius)
        .shadow(
            color: SuperDesign.Tokens.effects.shadow(for: .low).0,
            radius: SuperDesign.Tokens.effects.shadow(for: .low).1,
            x: SuperDesign.Tokens.effects.shadow(for: .low).2,
            y: SuperDesign.Tokens.effects.shadow(for: .low).3
        )
    }
    
    // MARK: - Stats Dashboard Section
    private var statsDashboardSection: some View {
        SuperDesign.Components.section(title: "Estadísticas") {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: SuperDesign.Tokens.space.md) {
                statCard(
                    icon: "calendar.badge.plus",
                    title: "Visitas esta semana",
                    value: "8",
                    subtitle: "+2 vs semana pasada",
                    color: SuperDesign.Tokens.colors.primary
                )
                
                statCard(
                    icon: "dollarsign.circle.fill",
                    title: "Gastos mensuales",
                    value: "$320",
                    subtitle: "Dentro del presupuesto",
                    color: SuperDesign.Tokens.colors.success
                )
                
                statCard(
                    icon: "heart.circle.fill",
                    title: "Momentos especiales",
                    value: "24",
                    subtitle: "Este mes",
                    color: SuperDesign.Tokens.colors.error
                )
                
                statCard(
                    icon: "star.circle.fill",
                    title: "Calificación",
                    value: "4.8",
                    subtitle: "Excelente trabajo",
                    color: SuperDesign.Tokens.colors.warning
                )
            }
        }
    }
    
    private func statCard(icon: String, title: String, value: String, subtitle: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.sm) {
            HStack {
                Image(systemName: icon)
                    .font(SuperDesign.Tokens.typography.titleMedium)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            SuperDesign.Components.heading(value, size: .large)
                .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
            
            SuperDesign.Components.body(title, size: .small)
                .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
            
            SuperDesign.Components.body(subtitle, size: .small)
                .foregroundColor(SuperDesign.Tokens.colors.textTertiary)
        }
        .padding(SuperDesign.Tokens.space.md)
        .background(SuperDesign.Tokens.colors.card)
        .cornerRadius(SuperDesign.Tokens.effects.cornerRadius)
        .shadow(
            color: SuperDesign.Tokens.effects.shadow(for: .low).0,
            radius: SuperDesign.Tokens.effects.shadow(for: .low).1,
            x: SuperDesign.Tokens.effects.shadow(for: .low).2,
            y: SuperDesign.Tokens.effects.shadow(for: .low).3
        )
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        SuperDesign.Components.section(title: "Acciones Rápidas") {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: SuperDesign.Tokens.space.md) {
                quickActionCard(
                    icon: "plus.circle.fill",
                    title: "Nueva Visita",
                    subtitle: "Agregar visita",
                    color: SuperDesign.Tokens.colors.primary
                ) {
                    // Add visit action
                }
                
                quickActionCard(
                    icon: "dollarsign.circle.fill",
                    title: "Registrar Gasto",
                    subtitle: "Agregar gasto",
                    color: SuperDesign.Tokens.colors.warning
                ) {
                    // Add expense action
                }
                
                quickActionCard(
                    icon: "heart.circle.fill",
                    title: "Momento Especial",
                    subtitle: "Guardar recuerdo",
                    color: SuperDesign.Tokens.colors.error
                ) {
                    // Add moment action
                }
                
                quickActionCard(
                    icon: "chart.bar.fill",
                    title: "Ver Estadísticas",
                    subtitle: "Analizar datos",
                    color: SuperDesign.Tokens.colors.info
                ) {
                    // View analytics action
                }
            }
        }
    }
    
    private func quickActionCard(icon: String, title: String, subtitle: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: SuperDesign.Tokens.space.sm) {
                Image(systemName: icon)
                    .font(SuperDesign.Tokens.typography.titleLarge)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(color)
                    .cornerRadius(SuperDesign.Tokens.effects.cornerRadius)
                
                SuperDesign.Components.heading(title, size: .small)
                    .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                
                SuperDesign.Components.body(subtitle, size: .small)
                    .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(SuperDesign.Tokens.space.md)
            .background(SuperDesign.Tokens.colors.card)
            .cornerRadius(SuperDesign.Tokens.effects.cornerRadius)
            .shadow(
                color: SuperDesign.Tokens.effects.shadow(for: .low).0,
                radius: SuperDesign.Tokens.effects.shadow(for: .low).1,
                x: SuperDesign.Tokens.effects.shadow(for: .low).2,
                y: SuperDesign.Tokens.effects.shadow(for: .low).3
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Recent Activity Section
    private var recentActivitySection: some View {
        SuperDesign.Components.section(title: "Actividad Reciente") {
            VStack(spacing: SuperDesign.Tokens.space.sm) {
                ForEach(todaysTasks, id: \.self) { task in
                    HStack(spacing: SuperDesign.Tokens.space.md) {
                        Circle()
                            .fill(SuperDesign.Tokens.colors.primary)
                            .frame(width: 8, height: 8)
                        
                        SuperDesign.Components.body(task, size: .medium)
                            .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                        
                        Spacer()
                        
                        SuperDesign.Components.body("Hoy", size: .small)
                            .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                    }
                    .padding(SuperDesign.Tokens.space.md)
                    .background(SuperDesign.Tokens.colors.surface)
                    .cornerRadius(SuperDesign.Tokens.effects.cornerRadiusSmall)
                }
            }
        }
    }
    
    // MARK: - Empty State Section
    private var emptyStateSection: some View {
        VStack(spacing: SuperDesign.Tokens.space.lg) {
            Image(systemName: "calendar.badge.plus")
                .font(SuperDesign.Tokens.typography.displaySmall)
                .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
            
            SuperDesign.Components.heading("¡Todo listo!", size: .medium)
                .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
            
            SuperDesign.Components.body(
                "No tienes tareas pendientes para hoy. ¡Disfruta tu tiempo libre!",
                size: .medium,
                color: SuperDesign.Tokens.colors.textSecondary
            )
            .multilineTextAlignment(.center)
            
            SuperDesign.Components.primaryButton(
                title: "Agregar Tarea",
                icon: "plus"
            ) {
                // Add task action
            }
        }
        .padding(SuperDesign.Tokens.space.xl)
        .background(SuperDesign.Tokens.colors.card)
        .cornerRadius(SuperDesign.Tokens.effects.cornerRadius)
        .shadow(
            color: SuperDesign.Tokens.effects.shadow(for: .low).0,
            radius: SuperDesign.Tokens.effects.shadow(for: .low).1,
            x: SuperDesign.Tokens.effects.shadow(for: .low).2,
            y: SuperDesign.Tokens.effects.shadow(for: .low).3
        )
    }
    
    // MARK: - Helper Functions
    private func refreshData() async {
        isRefreshing = true
        // Simulate network request
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isRefreshing = false
    }
}

#Preview {
    HomeView_Standardized()
}
