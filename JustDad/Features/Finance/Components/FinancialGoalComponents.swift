//
//  FinancialGoalComponents.swift
//  JustDad - Financial Goal Components
//
//  Professional UI components for financial goals with SF Symbols.
//

import SwiftUI
import SwiftData

// MARK: - Goal Badge View
struct GoalBadgeView: View {
    let achievement: GoalAchievement
    let isAnimated: Bool
    let onCelebrate: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background circle with gradient
                Circle()
                    .fill(achievement.achievementType.gradient)
                    .frame(width: 60, height: 60)
                    .shadow(color: achievement.achievementType.shadowColor.opacity(0.3), radius: 8, x: 0, y: 4)
                
                // Icon
                Image(systemName: achievement.badgeIcon)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .scaleEffect(isAnimated ? 1.2 : 1.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAnimated)
            }
            
            VStack(spacing: 2) {
                Text(achievement.badgeTitle)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(achievement.badgeDescription)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .onTapGesture {
            onCelebrate()
        }
    }
}

// MARK: - Goal Progress Card
struct GoalProgressCard: View {
    let goal: FinancialGoal
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    if let description = goal.goalDescription {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                // Category icon
                Image(systemName: goal.category.iconName)
                    .font(.title2)
                    .foregroundStyle(goal.category.gradient)
                    .frame(width: 32, height: 32)
            }
            
            // Progress bar
            VStack(spacing: 8) {
                HStack {
                    Text("Progreso")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(goal.progressPercentage * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                ProgressView()
                    .progressViewStyle(LinearProgressViewStyle(tint: goal.category.color))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            
            // Amount and date info
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ahorrado")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(goal.currentAmount, format: .currency(code: "USD"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Objetivo")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(goal.targetAmount, format: .currency(code: "USD"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
            
            // Time remaining
            HStack {
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundColor(goal.isOverdue ? .red : .secondary)
                
                Text(goal.isOverdue ? "Vencida" : "\(goal.daysRemaining) días restantes")
                    .font(.caption)
                    .foregroundColor(goal.isOverdue ? .red : .secondary)
                
                Spacer()
                
                // Priority indicator
                HStack(spacing: 4) {
                    Image(systemName: goal.priority.iconName)
                        .font(.caption)
                        .foregroundColor(goal.priority.color)
                    
                    Text(goal.priority.displayName)
                        .font(.caption)
                        .foregroundColor(goal.priority.color)
                }
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Goal Creation Form
struct GoalCreationForm: View {
    @ObservedObject var goalService: FinancialGoalService
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var targetAmount = ""
    @State private var targetDate = Date()
    @State private var selectedCategory: GoalCategory = .custom
    @State private var selectedPriority: GoalPriority = .medium
    @State private var isCreating = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Detalles de la Meta") {
                    TextField("Título de la meta", text: $title)
                    
                    TextField("Descripción (opcional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Objetivo") {
                    HStack {
                        Text("Monto objetivo")
                        Spacer()
                        TextField("0.00", text: $targetAmount)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    DatePicker("Fecha límite", selection: $targetDate, in: Date()..., displayedComponents: .date)
                }
                
                Section("Categoría") {
                    Picker("Categoría", selection: $selectedCategory) {
                        ForEach(GoalCategory.allCases) { category in
                            HStack {
                                Image(systemName: category.iconName)
                                    .foregroundStyle(category.gradient)
                                Text(category.displayName)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Prioridad") {
                    Picker("Prioridad", selection: $selectedPriority) {
                        ForEach(GoalPriority.allCases) { priority in
                            HStack {
                                Image(systemName: priority.iconName)
                                    .foregroundColor(priority.color)
                                Text(priority.displayName)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Nueva Meta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Crear") {
                        createGoal()
                    }
                    .disabled(title.isEmpty || targetAmount.isEmpty || isCreating)
                }
            }
        }
    }
    
    private func createGoal() {
        guard let amount = Decimal(string: targetAmount) else { return }
        
        isCreating = true
        
        Task {
            do {
                try await goalService.createGoal(
                    title: title,
                    description: description.isEmpty ? nil : description,
                    targetAmount: amount,
                    targetDate: targetDate,
                    category: selectedCategory,
                    priority: selectedPriority
                )
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isCreating = false
                }
            }
        }
    }
}

// MARK: - Predefined Goals Grid
struct PredefinedGoalsGrid: View {
    @ObservedObject var goalService: FinancialGoalService
    let onGoalSelected: (PredefinedGoal) -> Void
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(FinancialGoalService.predefinedGoals, id: \.title) { predefinedGoal in
                PredefinedGoalCard(
                    predefinedGoal: predefinedGoal,
                    onTap: {
                        onGoalSelected(predefinedGoal)
                    }
                )
            }
        }
    }
}

// MARK: - Predefined Goal Card
struct PredefinedGoalCard: View {
    let predefinedGoal: PredefinedGoal
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with icon
            HStack {
                Image(systemName: predefinedGoal.category.iconName)
                    .font(.title2)
                    .foregroundStyle(predefinedGoal.category.gradient)
                    .frame(width: 32, height: 32)
                
                Spacer()
                
                Image(systemName: predefinedGoal.priority.iconName)
                    .font(.caption)
                    .foregroundColor(predefinedGoal.priority.color)
            }
            
            // Title and description
            VStack(alignment: .leading, spacing: 4) {
                Text(predefinedGoal.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(predefinedGoal.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            Spacer()
            
            // Suggested amount and time
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Sugerido:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(predefinedGoal.suggestedAmount, format: .currency(code: "USD"))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Text("Tiempo:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(predefinedGoal.suggestedMonths) meses")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Goal Stats Overview
struct GoalStatsOverview: View {
    let stats: GoalStats
    
    var body: some View {
        VStack(spacing: 16) {
            // Overall progress
            VStack(spacing: 8) {
                HStack {
                    Text("Progreso General")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(Int(stats.overallProgress * 100))%")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                ProgressView()
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(x: 1, y: 3, anchor: .center)
            }
            
            // Stats grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                GoalStatCard(
                    title: "Metas Activas",
                    value: "\(stats.activeGoals)",
                    icon: "target",
                    color: .blue
                )
                
                GoalStatCard(
                    title: "Completadas",
                    value: "\(stats.completedGoals)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                GoalStatCard(
                    title: "Ahorrado",
                    value: stats.totalCurrentAmount,
                    icon: "dollarsign.circle.fill",
                    color: .green,
                    isCurrency: true
                )
                
                GoalStatCard(
                    title: "Objetivo",
                    value: stats.totalTargetAmount,
                    icon: "flag.fill",
                    color: .orange,
                    isCurrency: true
                )
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Goal Stat Card
struct GoalStatCard: View {
    let title: String
    let value: Any
    let icon: String
    let color: Color
    let isCurrency: Bool
    
    init(title: String, value: Any, icon: String, color: Color, isCurrency: Bool = false) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
        self.isCurrency = isCurrency
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 2) {
                if isCurrency, let decimalValue = value as? Decimal {
                    Text(decimalValue, format: .currency(code: "USD"))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                } else {
                    Text("\(value)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Achievement Celebration View
struct AchievementCelebrationView: View {
    let achievement: GoalAchievement
    @Binding var isPresented: Bool
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            // Celebration content
            VStack(spacing: 24) {
                // Badge with animation
                GoalBadgeView(
                    achievement: achievement,
                    isAnimated: isAnimating,
                    onCelebrate: {
                        isPresented = false
                    }
                )
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).repeatForever(autoreverses: true), value: isAnimating)
                
                VStack(spacing: 8) {
                    Text("¡Felicidades!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(achievement.badgeDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Button("¡Genial!") {
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(32)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 32)
        }
        .onAppear {
            isAnimating = true
        }
    }
}
