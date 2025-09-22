//
//  HabitsTrackingView.swift
//  JustDad - Atomic Habits Integration
//
//  Habit tracking based on Atomic Habits principles
//

import SwiftUI

enum HabitTab: String, CaseIterable {
    case overview = "overview"
    case analytics = "analytics"
    case achievements = "achievements"
    case goals = "goals"
    
    var title: String {
        switch self {
        case .overview: return "Resumen"
        case .analytics: return "Analytics"
        case .achievements: return "Logros"
        case .goals: return "Metas"
        }
    }
    
    var icon: String {
        switch self {
        case .overview: return "house.fill"
        case .analytics: return "chart.bar.fill"
        case .achievements: return "trophy.fill"
        case .goals: return "target"
        }
    }
}

struct HabitsTrackingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var habitsService = HabitsService.shared
    @State private var showingAddHabit = false
    @State private var showingInsights = false
    @State private var showingAchievements = false
    @State private var selectedTab: HabitTab = .overview
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("Tab", selection: $selectedTab) {
                    ForEach(HabitTab.allCases, id: \.self) { tab in
                        HStack {
                            Image(systemName: tab.icon)
                            Text(tab.title)
                        }
                        .tag(tab)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content
                TabView(selection: $selectedTab) {
                    overviewView
                        .tag(HabitTab.overview)
                    
                    analyticsView
                        .tag(HabitTab.analytics)
                    
                    achievementsView
                        .tag(HabitTab.achievements)
                    
                    goalsView
                        .tag(HabitTab.goals)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Hábitos Atómicos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Agregar") {
                        showingAddHabit = true
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView { habit in
                    habitsService.addHabit(habit)
                }
            }
        }
    }
    
    // MARK: - Overview Tab
    private var overviewView: some View {
        ScrollView {
            VStack(spacing: 20) {
                if habitsService.habits.isEmpty {
                    emptyStateView
                } else {
                    // Quick Stats
                    quickStatsView
                    
                    // Habits List
                    LazyVStack(spacing: 16) {
                        ForEach(habitsService.habits) { habit in
                            HabitCard(habit: habit) { updatedHabit in
                                habitsService.updateHabit(updatedHabit)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    // MARK: - Analytics Tab
    private var analyticsView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Insights Overview
                insightsOverviewView
                
                // Weekly Progress Chart
                weeklyProgressView
                
                // Category Breakdown
                categoryBreakdownView
                
                // Streak Analysis
                streakAnalysisView
            }
            .padding()
        }
    }
    
    // MARK: - Achievements Tab
    private var achievementsView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Achievements Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(habitsService.achievements) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
                .padding()
            }
        }
    }
    
    // MARK: - Goals Tab
    private var goalsView: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Metas y Objetivos")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Próximamente: Sistema de metas personalizadas")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
        }
    }
    
    // MARK: - Quick Stats View
    private var quickStatsView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Resumen de Hoy")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                HabitStatCard(
                    title: "Completados",
                    value: "\(habitsService.insights.completedToday)",
                    subtitle: "de \(habitsService.insights.totalHabits)",
                    color: .green,
                    icon: "checkmark.circle.fill"
                )
                
                HabitStatCard(
                    title: "Racha Máxima",
                    value: "\(habitsService.insights.bestStreak)",
                    subtitle: "días",
                    color: .orange,
                    icon: "flame.fill"
                )
                
                HabitStatCard(
                    title: "Total",
                    value: "\(habitsService.insights.totalCompletions)",
                    subtitle: "completados",
                    color: .blue,
                    icon: "chart.bar.fill"
                )
            }
        }
        .padding()
    }
    
    // MARK: - Insights Overview
    private var insightsOverviewView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Insights Generales")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                InsightRow(
                    title: "Hábitos Activos",
                    value: "\(habitsService.insights.totalHabits)",
                    icon: "list.bullet",
                    color: .blue
                )
                
                InsightRow(
                    title: "Completados Hoy",
                    value: "\(habitsService.insights.completedToday)",
                    icon: "checkmark.circle",
                    color: .green
                )
                
                InsightRow(
                    title: "Racha Promedio",
                    value: "\(habitsService.insights.averageStreak) días",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .orange
                )
                
                InsightRow(
                    title: "Mejor Racha",
                    value: "\(habitsService.insights.bestStreak) días",
                    icon: "crown.fill",
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
    
    // MARK: - Weekly Progress
    private var weeklyProgressView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progreso Semanal")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(Array(habitsService.insights.weeklyProgress.keys), id: \.self) { habitName in
                    if let progress = habitsService.insights.weeklyProgress[habitName] {
                        WeeklyProgressRow(
                            habitName: habitName,
                            progress: progress
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
    
    // MARK: - Category Breakdown
    private var categoryBreakdownView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Distribución por Categoría")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(HabitCategory.allCases, id: \.self) { category in
                    if let count = habitsService.insights.categoryBreakdown[category], count > 0 {
                        CategoryCard(
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
    
    // MARK: - Streak Analysis
    private var streakAnalysisView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Análisis de Rachas")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(habitsService.habits.sorted(by: { $0.streak > $1.streak })) { habit in
                    StreakRow(habit: habit)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemGray6))
        )
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.purple)
            
            Text("Comienza tu jornada de hábitos")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Los pequeños cambios diarios pueden transformar tu vida como padre")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Agregar mi primer hábito") {
                showingAddHabit = true
            }
            .buttonStyle(HabitsPrimaryButtonStyle(color: .purple))
        }
        .padding()
    }
}

// MARK: - Habit Model
struct Habit: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let frequency: HabitFrequency
    let category: HabitCategory
    let startDate: Date
    var completedDays: Set<Date> = []
    var streak: Int = 0
    var difficulty: HabitDifficulty = .easy
    var priority: HabitPriority = .medium
    var motivation: String = ""
    var obstacles: [String] = []
    var rewards: [String] = []
    var isActive: Bool = true
    
    var isCompletedToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return completedDays.contains(today)
    }
    
    var completionRate: Double {
        let daysSinceStart = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 1
        return Double(completedDays.count) / Double(max(daysSinceStart, 1))
    }
    
    var weeklyCompletionRate: Double {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let weeklyCompletions = completedDays.filter { $0 >= weekAgo }.count
        return Double(weeklyCompletions) / 7.0
    }
    
    var monthlyCompletionRate: Double {
        let calendar = Calendar.current
        let monthAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let monthlyCompletions = completedDays.filter { $0 >= monthAgo }.count
        return Double(monthlyCompletions) / 30.0
    }
    
    var nextMilestone: String {
        let milestones = [7, 14, 30, 60, 90, 180, 365]
        for milestone in milestones {
            if streak < milestone {
                return "\(milestone) días"
            }
        }
        return "¡Increíble!"
    }
    
    var motivationQuote: String {
        switch streak {
        case 0...6:
            return "Los pequeños pasos llevan a grandes cambios"
        case 7...29:
            return "¡Excelente! Estás construyendo momentum"
        case 30...89:
            return "¡Increíble! Este hábito se está volviendo automático"
        default:
            return "¡Eres una inspiración! Sigue así"
        }
    }
    
    init(name: String, description: String, frequency: HabitFrequency, category: HabitCategory, startDate: Date, difficulty: HabitDifficulty = .easy, priority: HabitPriority = .medium, motivation: String = "", obstacles: [String] = [], rewards: [String] = []) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.frequency = frequency
        self.category = category
        self.startDate = startDate
        self.difficulty = difficulty
        self.priority = priority
        self.motivation = motivation
        self.obstacles = obstacles
        self.rewards = rewards
    }
}

enum HabitDifficulty: String, CaseIterable, Codable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    case expert = "expert"
    
    var title: String {
        switch self {
        case .easy: return "Fácil"
        case .medium: return "Medio"
        case .hard: return "Difícil"
        case .expert: return "Experto"
        }
    }
    
    var color: Color {
        switch self {
        case .easy: return .green
        case .medium: return .yellow
        case .hard: return .orange
        case .expert: return .red
        }
    }
}

enum HabitPriority: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
    
    var title: String {
        switch self {
        case .low: return "Baja"
        case .medium: return "Media"
        case .high: return "Alta"
        case .critical: return "Crítica"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .gray
        case .medium: return .blue
        case .high: return .orange
        case .critical: return .red
        }
    }
}

enum HabitFrequency: String, CaseIterable, Codable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    
    var title: String {
        switch self {
        case .daily: return "Diario"
        case .weekly: return "Semanal"
        case .monthly: return "Mensual"
        }
    }
}

enum HabitCategory: String, CaseIterable, Codable {
    case health = "health"
    case parenting = "parenting"
    case work = "work"
    case personal = "personal"
    case relationships = "relationships"
    
    var title: String {
        switch self {
        case .health: return "Salud"
        case .parenting: return "Paternidad"
        case .work: return "Trabajo"
        case .personal: return "Personal"
        case .relationships: return "Relaciones"
        }
    }
    
    var icon: String {
        switch self {
        case .health: return "heart.fill"
        case .parenting: return "person.2.fill"
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        case .relationships: return "link"
        }
    }
    
    var color: Color {
        switch self {
        case .health: return .red
        case .parenting: return .blue
        case .work: return .green
        case .personal: return .purple
        case .relationships: return .orange
        }
    }
}

// MARK: - Habit Card
struct HabitCard: View {
    @State var habit: Habit
    let onUpdate: (Habit) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: habit.category.icon)
                    .font(.title2)
                    .foregroundColor(habit.category.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(habit.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: toggleCompletion) {
                    Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(habit.isCompletedToday ? habit.category.color : .gray)
                }
            }
            
            // Progress and Stats
            VStack(alignment: .leading, spacing: 12) {
                // Progress Bar
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Progreso")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(habit.completionRate * 100))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(habit.category.color)
                    }
                    
                    ProgressView()
                        .progressViewStyle(LinearProgressViewStyle(tint: habit.category.color))
                }
                
                // Stats Row
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Racha")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(habit.streak) días")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(habit.category.color)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 2) {
                        Text("Dificultad")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        HStack(spacing: 2) {
                            Circle()
                                .fill(habit.difficulty.color)
                                .frame(width: 8, height: 8)
                            Text(habit.difficulty.title)
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Prioridad")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        HStack(spacing: 2) {
                            Circle()
                                .fill(habit.priority.color)
                                .frame(width: 8, height: 8)
                            Text(habit.priority.title)
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                // Motivation Quote
                if !habit.motivation.isEmpty {
                    Text(habit.motivation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                        .lineLimit(2)
                }
                
                // Next Milestone
                HStack {
                    Text("Próximo hito:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(habit.nextMilestone)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(habit.category.color)
                    
                    Spacer()
                    
                    Text(habit.frequency.title)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(habit.category.color.opacity(0.1))
                        .foregroundColor(habit.category.color)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: habit.category.color.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(habit.category.color.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func toggleCompletion() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if habit.isCompletedToday {
            habit.completedDays.remove(today)
        } else {
            habit.completedDays.insert(today)
        }
        
        // Update streak
        updateStreak()
        
        onUpdate(habit)
    }
    
    private func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        var streak = 0
        var currentDate = today
        
        while habit.completedDays.contains(currentDate) {
            streak += 1
            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        habit.streak = streak
    }
}

// MARK: - Add Habit View
struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var frequency = HabitFrequency.daily
    @State private var category = HabitCategory.personal
    @State private var difficulty = HabitDifficulty.easy
    @State private var priority = HabitPriority.medium
    @State private var motivation = ""
    @State private var obstacles = ""
    @State private var rewards = ""
    
    let onSave: (Habit) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información del hábito") {
                    TextField("Nombre del hábito", text: $name)
                    TextField("Descripción (opcional)", text: $description, axis: .vertical)
                }
                
                Section("Configuración") {
                    Picker("Frecuencia", selection: $frequency) {
                        ForEach(HabitFrequency.allCases, id: \.self) { freq in
                            Text(freq.title).tag(freq)
                        }
                    }
                    
                    Picker("Categoría", selection: $category) {
                        ForEach(HabitCategory.allCases, id: \.self) { cat in
                            HStack {
                                Image(systemName: cat.icon)
                                    .foregroundColor(cat.color)
                                Text(cat.title)
                            }.tag(cat)
                        }
                    }
                    
                    Picker("Dificultad", selection: $difficulty) {
                        ForEach(HabitDifficulty.allCases, id: \.self) { diff in
                            HStack {
                                Circle()
                                    .fill(diff.color)
                                    .frame(width: 12, height: 12)
                                Text(diff.title)
                            }.tag(diff)
                        }
                    }
                    
                    Picker("Prioridad", selection: $priority) {
                        ForEach(HabitPriority.allCases, id: \.self) { prio in
                            HStack {
                                Circle()
                                    .fill(prio.color)
                                    .frame(width: 12, height: 12)
                                Text(prio.title)
                            }.tag(prio)
                        }
                    }
                }
                
                Section("Motivación y Obstáculos") {
                    TextField("¿Por qué quieres este hábito?", text: $motivation, axis: .vertical)
                    TextField("¿Qué obstáculos podrías enfrentar?", text: $obstacles, axis: .vertical)
                    TextField("¿Cómo te recompensarás?", text: $rewards, axis: .vertical)
                }
            }
            .navigationTitle("Nuevo Hábito")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        let habit = Habit(
                            name: name,
                            description: description,
                            frequency: frequency,
                            category: category,
                            startDate: Date(),
                            difficulty: difficulty,
                            priority: priority,
                            motivation: motivation,
                            obstacles: obstacles.isEmpty ? [] : obstacles.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
                            rewards: rewards.isEmpty ? [] : rewards.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        )
                        onSave(habit)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// MARK: - Button Styles
struct HabitsPrimaryButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Supporting Views
struct HabitStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct InsightRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

struct WeeklyProgressRow: View {
    let habitName: String
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(habitName)
                    .font(.body)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            ProgressView()
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
        }
    }
}

struct CategoryCard: View {
    let category: HabitCategory
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

struct StreakRow: View {
    let habit: Habit
    
    var body: some View {
        HStack {
            Image(systemName: habit.category.icon)
                .foregroundColor(habit.category.color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .font(.body)
                
                Text(habit.motivationQuote)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(habit.streak)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(habit.category.color)
                
                Text("días")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct AchievementCard: View {
    let achievement: HabitAchievement
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: achievement.icon)
                .font(.system(size: 40))
                .foregroundColor(Color(achievement.color))
            
            Text(achievement.title)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text(achievement.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let unlockedAt = achievement.unlockedAt {
                Text("Desbloqueado: \(unlockedAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color(achievement.color).opacity(0.2), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(achievement.color).opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    HabitsTrackingView()
}
