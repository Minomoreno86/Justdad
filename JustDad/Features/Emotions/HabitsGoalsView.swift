//
//  HabitsGoalsView.swift
//  JustDad - Goals Management UI
//
//  Vista principal para gestionar metas y objetivos
//

import SwiftUI

struct HabitsGoalsView: View {
    @StateObject private var goalsService = HabitsGoalsService.shared
    @State private var showingCreateGoal = false
    @State private var selectedGoal: HabitsGoal?
    @State private var showingGoalDetail = false
    @State private var selectedTab: GoalTab = .active
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with Stats
                headerView
                
                // Tab Selector
                tabSelectorView
                
                // Content
                TabView(selection: $selectedTab) {
                    activeGoalsView
                        .tag(GoalTab.active)
                    
                    completedGoalsView
                        .tag(GoalTab.completed)
                    
                    insightsView
                        .tag(GoalTab.insights)
                    
                    suggestionsView
                        .tag(GoalTab.suggestions)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Mis Metas")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateGoal = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.purple)
                    }
                }
            }
            .sheet(isPresented: $showingCreateGoal) {
                CreateGoalView { goal in
                    goalsService.createGoal(goal)
                }
            }
            .sheet(item: $selectedGoal) { goal in
                Text("Detalle de Meta: \(goal.title)")
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            // Quick Stats
            HStack(spacing: 16) {
                HabitsGoalStatCard(
                    title: "Activas",
                    value: "\(goalsService.goalInsights.activeGoals)",
                    color: .green,
                    icon: "play.circle.fill"
                )
                
                HabitsGoalStatCard(
                    title: "Completadas",
                    value: "\(goalsService.goalInsights.completedGoals)",
                    color: .blue,
                    icon: "checkmark.circle.fill"
                )
                
                HabitsGoalStatCard(
                    title: "Progreso",
                    value: "\(Int(goalsService.goalInsights.averageProgress * 100))%",
                    color: .purple,
                    icon: "chart.bar.fill"
                )
                
                HabitsGoalStatCard(
                    title: "Vencidas",
                    value: "\(goalsService.goalInsights.overdueGoals)",
                    color: .red,
                    icon: "exclamationmark.triangle.fill"
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(UIColor.systemGray6))
    }
    
    // MARK: - Tab Selector
    private var tabSelectorView: some View {
        HStack(spacing: 0) {
            ForEach(GoalTab.allCases, id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 16))
                        
                        Text(tab.title)
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedTab == tab ? .purple : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemGray6))
                .padding(.horizontal)
        )
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    // MARK: - Active Goals View
    private var activeGoalsView: some View {
        ScrollView {
            VStack(spacing: 16) {
                if goalsService.activeGoals.isEmpty {
                    emptyActiveGoalsView
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(goalsService.activeGoals) { goal in
                            HabitsGoalCard(goal: goal) {
                                selectedGoal = goal
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    // MARK: - Completed Goals View
    private var completedGoalsView: some View {
        ScrollView {
            VStack(spacing: 16) {
                if goalsService.completedGoals.isEmpty {
                    emptyCompletedGoalsView
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(goalsService.completedGoals) { goal in
                            HabitsCompletedGoalCard(goal: goal) {
                                selectedGoal = goal
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    // MARK: - Insights View
    private var insightsView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Progress Overview
                progressOverviewSection
                
                // Goals by Category
                categoryBreakdownSection
                
                // Goals by Priority
                priorityBreakdownSection
                
                // Recent Completions
                if !goalsService.goalInsights.recentCompletions.isEmpty {
                    recentCompletionsSection
                }
                
                // Upcoming Deadlines
                if !goalsService.goalInsights.upcomingDeadlines.isEmpty {
                    upcomingDeadlinesSection
                }
            }
            .padding()
        }
    }
    
    // MARK: - Suggestions View
    private var suggestionsView: some View {
        ScrollView {
            VStack(spacing: 16) {
                let suggestions = goalsService.getSuggestedGoals()
                
                if suggestions.isEmpty {
                    noSuggestionsView
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(suggestions) { suggestion in
                            GoalSuggestionCard(suggestion: suggestion) {
                                // Create goal from suggestion
                                let newGoal = HabitsGoal(
                                    title: suggestion.title,
                                    description: suggestion.description,
                                    category: suggestion.category,
                                    priority: .medium,
                                    targetValue: 100.0,
                                    unit: "%",
                                    motivation: "Meta sugerida basada en tus hábitos"
                                )
                                goalsService.createGoal(newGoal)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    // MARK: - Empty States
    private var emptyActiveGoalsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No tienes metas activas")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Crea tu primera meta para comenzar tu camino hacia el éxito")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Crear mi primera meta") {
                showingCreateGoal = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
        }
        .padding()
    }
    
    private var emptyCompletedGoalsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No has completado metas aún")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Cuando completes una meta, aparecerá aquí para celebrar tu logro")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var noSuggestionsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "lightbulb")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No hay sugerencias disponibles")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Crea más hábitos para recibir sugerencias personalizadas de metas")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - Insights Sections
    private var progressOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resumen de Progreso")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                InsightRow(
                    title: "Promedio de Progreso",
                    value: "\(Int(goalsService.goalInsights.averageProgress * 100))%",
                    icon: "chart.bar.fill",
                    color: .blue
                )
                
                InsightRow(
                    title: "Tasa de Completación",
                    value: "\(Int(goalsService.goalInsights.completionRate * 100))%",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                InsightRow(
                    title: "Metas Totales",
                    value: "\(goalsService.goalInsights.totalGoals)",
                    icon: "target",
                    color: .purple
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemGray6))
        )
    }
    
    private var categoryBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Metas por Categoría")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(HabitsGoalCategory.allCases, id: \.self) { category in
                    if let count = goalsService.goalInsights.goalsByCategory[category], count > 0 {
                        CategoryGoalCard(
                            category: category,
                            count: count
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemGray6))
        )
    }
    
    private var priorityBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Metas por Prioridad")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(HabitsGoalPriority.allCases, id: \.self) { priority in
                    if let count = goalsService.goalInsights.goalsByPriority[priority], count > 0 {
                        PriorityGoalRow(
                            priority: priority,
                            count: count
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemGray6))
        )
    }
    
    private var recentCompletionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Completadas Recientemente")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 8) {
                ForEach(goalsService.goalInsights.recentCompletions) { goal in
                    RecentCompletionCard(goal: goal) {
                        selectedGoal = goal
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemGray6))
        )
    }
    
    private var upcomingDeadlinesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Próximos Vencimientos")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 8) {
                ForEach(goalsService.goalInsights.upcomingDeadlines) { goal in
                    UpcomingDeadlineCard(goal: goal) {
                        selectedGoal = goal
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemGray6))
        )
    }
}

// MARK: - Goal Tab Enum
enum GoalTab: String, CaseIterable {
    case active = "active"
    case completed = "completed"
    case insights = "insights"
    case suggestions = "suggestions"
    
    var title: String {
        switch self {
        case .active: return "Activas"
        case .completed: return "Completadas"
        case .insights: return "Insights"
        case .suggestions: return "Sugerencias"
        }
    }
    
    var icon: String {
        switch self {
        case .active: return "play.circle.fill"
        case .completed: return "checkmark.circle.fill"
        case .insights: return "chart.bar.fill"
        case .suggestions: return "lightbulb.fill"
        }
    }
}

// MARK: - Supporting Views
struct HabitsGoalStatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct CategoryGoalCard: View {
    let category: HabitsGoalCategory
    let count: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: category.icon)
                .font(.title2)
                .foregroundColor(category.color)
            
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(category.title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(category.color.opacity(0.1))
        )
    }
}

struct PriorityGoalRow: View {
    let priority: HabitsGoalPriority
    let count: Int
    
    var body: some View {
        HStack {
            Image(systemName: priority.icon)
                .foregroundColor(priority.color)
                .frame(width: 20)
            
            Text(priority.title)
                .font(.body)
            
            Spacer()
            
            Text("\(count)")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(priority.color)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(priority.color.opacity(0.1))
        )
    }
}

struct RecentCompletionCard: View {
    let goal: HabitsGoal
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: goal.category.icon)
                    .foregroundColor(goal.category.color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.title)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Completada el \(goal.completedAt?.formatted(date: .abbreviated, time: .omitted) ?? "")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct UpcomingDeadlineCard: View {
    let goal: HabitsGoal
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: goal.category.icon)
                    .foregroundColor(goal.category.color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.title)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Vence el \(goal.formattedDeadline ?? "")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(goal.daysRemaining ?? 0)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Text("días")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GoalSuggestionCard: View {
    let suggestion: GoalSuggestion
    let onAccept: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: suggestion.category.icon)
                    .font(.title2)
                    .foregroundColor(suggestion.category.color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(suggestion.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 4) {
                        Text("Confianza:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text(suggestion.confidence.title)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(suggestion.confidence.color)
                    }
                }
                
                Spacer()
                
                Button(action: onAccept) {
                    Text("Crear")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.purple)
                        )
                }
            }
            
            Text(suggestion.description)
                .font(.body)
                .foregroundColor(.secondary)
            
            if !suggestion.suggestedHabits.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hábitos relacionados:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text(suggestion.suggestedHabits.joined(separator: " • "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    HabitsGoalsView()
}
