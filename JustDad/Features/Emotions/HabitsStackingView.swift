//
//  HabitsStackingView.swift
//  JustDad - Habit Stacking UI
//
//  User interface for managing habit stacks
//

import SwiftUI

struct HabitsStackingView: View {
    @StateObject private var stackingService = HabitsStackingService.shared
    @StateObject private var habitsService = HabitsService.shared
    @State private var showingCreateStack = false
    @State private var showingStackDetail: HabitStack?
    @State private var selectedStack: HabitStack?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with Stats
                    headerView
                    
                    // Quick Actions
                    quickActionsView
                    
                    // Active Stacks
                    activeStacksSection
                    
                    // Stack Insights
                    stackInsightsSection
                    
                    // Stack Achievements
                    if !stackingService.stackAchievements.isEmpty {
                        stackAchievementsSection
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Habit Stacking")
            .onAppear {
                updateStackInsights()
            }
            .sheet(isPresented: $showingCreateStack) {
                HabitsCreateStackView { newStack in
                    stackingService.createStack(newStack)
                }
            }
            .sheet(item: $showingStackDetail) { stack in
                HabitsStackDetailView(stack: stack)
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Habit Stacking")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Conecta hábitos para crear rutinas automáticas")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    showingCreateStack = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Stats Cards
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StackStatCard(
                    title: "Stacks Activos",
                    value: "\(stackingService.stackInsights.activeStacks)",
                    icon: "square.stack.3d.up.fill",
                    color: .blue
                )
                
                StackStatCard(
                    title: "Completados Hoy",
                    value: "\(stackingService.stackInsights.completedToday)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StackStatCard(
                    title: "Tasa de Éxito",
                    value: "\(Int(stackingService.stackInsights.stackSuccessRate * 100))%",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .orange
                )
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Quick Actions View
    private var quickActionsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Acciones Rápidas")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    StackingQuickActionCard(
                        title: "Crear Stack",
                        icon: "plus.circle.fill",
                        color: .blue,
                        action: {
                            showingCreateStack = true
                        }
                    )
                    
                    StackingQuickActionCard(
                        title: "Stacks Sugeridos",
                        icon: "lightbulb.fill",
                        color: .yellow,
                        action: {
                            // TODO: Implement suggested stacks
                        }
                    )
                    
                    StackingQuickActionCard(
                        title: "Análisis",
                        icon: "chart.bar.fill",
                        color: .purple,
                        action: {
                            // TODO: Implement analytics
                        }
                    )
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Active Stacks Section
    private var activeStacksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Stacks Activos")
                    .font(.headline)
                
                Spacer()
                
                Button("Ver todos") {
                    // TODO: Navigate to all stacks view
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            if stackingService.stacks.isEmpty {
                emptyStacksView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(stackingService.stacks.prefix(3)) { stack in
                        StackCard(stack: stack) {
                            showingStackDetail = stack
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Empty Stacks View
    private var emptyStacksView: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No tienes stacks aún")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Los stacks te ayudan a conectar hábitos y crear rutinas automáticas. ¡Crea tu primer stack!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Crear mi primer stack") {
                showingCreateStack = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
        .padding(.horizontal)
    }
    
    // MARK: - Stack Insights Section
    private var stackInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Insights")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    StackingInsightCard(
                        title: "Trigger Más Usado",
                        value: stackingService.stackInsights.mostUsedTrigger,
                        icon: "bolt.fill",
                        color: .yellow
                    )
                    
                    StackingInsightCard(
                        title: "Tamaño Promedio",
                        value: "\(stackingService.stackInsights.averageStackSize) hábitos",
                        icon: "number.circle.fill",
                        color: .blue
                    )
                    
                    StackingInsightCard(
                        title: "Total Completados",
                        value: "\(stackingService.stackInsights.totalStackCompletions)",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Stack Achievements Section
    private var stackAchievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Logros de Stacks")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(stackingService.stackAchievements) { achievement in
                        StackingAchievementCard(achievement: achievement)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func updateStackInsights() {
        stackingService.updateStackInsights()
    }
}

// MARK: - Supporting Views

struct StackStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct StackingQuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 80, height: 80)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StackCard: View {
    let stack: HabitStack
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: stack.category.icon)
                        .font(.title3)
                        .foregroundColor(stack.category.color)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(stack.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(stack.trigger)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if stack.isCompletedToday {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                
                // Progress
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Racha: \(stack.streak) días")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Text("Completado: \(Int(stack.completionRate * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(stack.habitIds.count) hábitos")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(stack.category.color.opacity(0.2))
                        .foregroundColor(stack.category.color)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StackingInsightCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 140)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct StackingAchievementCard: View {
    let achievement: StackAchievement
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundColor(Color(achievement.color))
            
            Text(achievement.title)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80, height: 80)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    HabitsStackingView()
}
