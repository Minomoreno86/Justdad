//
//  HabitsGoalCardsView.swift
//  JustDad - Goal Cards UI
//
//  Tarjetas para mostrar metas activas y completadas
//

import SwiftUI

// MARK: - Goal Card
struct HabitsGoalCard: View {
    let goal: HabitsGoal
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Image(systemName: goal.category.icon)
                        .font(.title2)
                        .foregroundColor(goal.category.color)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(goal.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        HStack(spacing: 8) {
                            Text(goal.category.title)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(goal.category.color.opacity(0.1))
                                .foregroundColor(goal.category.color)
                                .cornerRadius(6)
                            
                            HStack(spacing: 4) {
                                Image(systemName: goal.priority.icon)
                                    .font(.caption)
                                Text(goal.priority.title)
                                    .font(.caption)
                            }
                            .foregroundColor(goal.priority.color)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        if goal.isOverdue {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.title3)
                        } else {
                            Image(systemName: goal.status.icon)
                                .foregroundColor(goal.status.color)
                                .font(.title3)
                        }
                        
                        if let daysRemaining = goal.daysRemaining {
                            Text("\(daysRemaining) días")
                                .font(.caption2)
                                .foregroundColor(goal.isOverdue ? .red : .orange)
                        }
                    }
                }
                
                // Description
                Text(goal.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                // Progress Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Progreso")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(goal.progressPercentage))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(goal.category.color)
                    }
                    
                    ProgressView(value: goal.currentProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: goal.category.color))
                        .scaleEffect(y: 1.5)
                    
                    HStack {
                        Text("\(Int(goal.currentProgress * goal.targetValue)) / \(Int(goal.targetValue)) \(goal.unit)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if let deadline = goal.deadline {
                            Text("Vence: \(deadline.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Milestones
                if !goal.milestones.isEmpty {
                    MilestonesSection(milestones: goal.milestones)
                }
                
                // Related Habits
                if !goal.relatedHabits.isEmpty {
                    RelatedHabitsSection(habitIds: goal.relatedHabits)
                }
                
                // Actions
                HStack(spacing: 12) {
                    if goal.status == .active {
                        Button("Actualizar Progreso") {
                            // TODO: Show progress update sheet
                        }
                        .font(.caption)
                        .foregroundColor(.purple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.purple.opacity(0.1))
                        )
                        
                        Button("Pausar") {
                            // TODO: Pause goal
                        }
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.orange.opacity(0.1))
                        )
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(goal.isOverdue ? Color.red.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
                    .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Completed Goal Card
struct HabitsCompletedGoalCard: View {
    let goal: HabitsGoal
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Image(systemName: goal.category.icon)
                        .font(.title2)
                        .foregroundColor(goal.category.color)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(goal.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .strikethrough(true, color: .green)
                        
                        HStack(spacing: 8) {
                            Text(goal.category.title)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(goal.category.color.opacity(0.1))
                                .foregroundColor(goal.category.color)
                                .cornerRadius(6)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            
                            Text("Completada")
                                .font(.caption)
                                .foregroundColor(.green)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                            .font(.title3)
                        
                        if let completedAt = goal.completedAt {
                            Text(completedAt.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Description
                Text(goal.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // Completion Stats
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Objetivo alcanzado:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(goal.targetValue)) \(goal.unit)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    
                    // Completion timeline
                    if let completedAt = goal.completedAt {
                        let duration = Calendar.current.dateComponents([.day], from: goal.createdAt, to: completedAt).day ?? 0
                        
                        HStack {
                            Text("Tiempo total:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(duration) días")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // Milestones (completed)
                if !goal.milestones.isEmpty {
                    CompletedMilestonesSection(milestones: goal.milestones)
                }
                
                // Celebration
                HStack {
                    Image(systemName: "party.popper.fill")
                        .foregroundColor(.yellow)
                    
                    Text("¡Felicidades por completar esta meta!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.green.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.green.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Milestones Section
struct MilestonesSection: View {
    let milestones: [GoalMilestone]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hitos")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            LazyVStack(spacing: 6) {
                ForEach(milestones.prefix(3)) { milestone in
                    MilestoneRow(milestone: milestone)
                }
                
                if milestones.count > 3 {
                    Text("+ \(milestones.count - 3) hitos más")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.leading, 24)
                }
            }
        }
    }
}

// MARK: - Completed Milestones Section
struct CompletedMilestonesSection: View {
    let milestones: [GoalMilestone]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hitos completados")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            LazyVStack(spacing: 6) {
                ForEach(milestones.filter { $0.isCompleted }) { milestone in
                    CompletedMilestoneRow(milestone: milestone)
                }
            }
        }
    }
}

// MARK: - Milestone Row
struct MilestoneRow: View {
    let milestone: GoalMilestone
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: milestone.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(milestone.isCompleted ? .green : .gray)
                .font(.caption)
            
            Text(milestone.title)
                .font(.caption)
                .foregroundColor(milestone.isCompleted ? .secondary : .primary)
                .strikethrough(milestone.isCompleted)
            
            Spacer()
            
            Text("\(Int(milestone.currentValue))/\(Int(milestone.targetValue))")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(milestone.isCompleted ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
        )
    }
}

// MARK: - Completed Milestone Row
struct CompletedMilestoneRow: View {
    let milestone: GoalMilestone
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.caption)
            
            Text(milestone.title)
                .font(.caption)
                .foregroundColor(.secondary)
                .strikethrough(true)
            
            Spacer()
            
            if let completedAt = milestone.completedAt {
                Text(completedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.green.opacity(0.1))
        )
    }
}

// MARK: - Related Habits Section
struct RelatedHabitsSection: View {
    let habitIds: [UUID]
    @StateObject private var habitsService = HabitsService.shared
    
    var relatedHabits: [Habit] {
        habitsService.habits.filter { habitIds.contains($0.id) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hábitos relacionados")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 6) {
                ForEach(relatedHabits.prefix(4)) { habit in
                    RelatedHabitChip(habit: habit)
                }
            }
            
            if relatedHabits.count > 4 {
                Text("+ \(relatedHabits.count - 4) hábitos más")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
            }
        }
    }
}

// MARK: - Related Habit Chip
struct RelatedHabitChip: View {
    let habit: Habit
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: habit.category.icon)
                .font(.caption2)
                .foregroundColor(habit.category.color)
            
            Text(habit.name)
                .font(.caption2)
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(habit.category.color.opacity(0.1))
        )
    }
}

// MARK: - Insight Row
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
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        HabitsGoalCard(goal: HabitsGoal(
            title: "Ejercicio diario",
            description: "Hacer ejercicio 30 minutos todos los días para mejorar mi salud física",
            category: .health,
            priority: .high,
            targetValue: 30,
            unit: "días",
            deadline: Calendar.current.date(byAdding: .day, value: 30, to: Date())
        )) {
            // Preview action
        }
        
        HabitsCompletedGoalCard(goal: {
            var goal = HabitsGoal(
                title: "Leer libros",
                description: "Leer 12 libros este año para desarrollar mi conocimiento",
                category: .learning,
                priority: .medium,
                targetValue: 12,
                unit: "libros"
            )
            goal.status = .completed
            goal.currentProgress = 1.0
            goal.completedAt = Date()
            return goal
        }()) {
            // Preview action
        }
    }
    .padding()
}
