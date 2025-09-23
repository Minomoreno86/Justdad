//
//  HabitsCreateGoalView.swift
//  JustDad - Create Goal UI
//
//  Vista para crear nuevas metas y objetivos
//

import SwiftUI

struct CreateGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var habitsService = HabitsService.shared
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory = HabitsGoalCategory.personal
    @State private var selectedPriority = HabitsGoalPriority.medium
    @State private var targetValue = ""
    @State private var unit = ""
    @State private var hasDeadline = false
    @State private var deadline = Date()
    @State private var motivation = ""
    @State private var obstacles = ""
    @State private var rewards = ""
    @State private var selectedHabits: Set<UUID> = []
    @State private var isPublic = false
    
    let onSave: (HabitsGoal) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información Básica") {
                    TextField("Título de la meta", text: $title)
                    
                    TextField("Descripción", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Configuración") {
                    Picker("Categoría", selection: $selectedCategory) {
                        ForEach(HabitsGoalCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.title)
                            }.tag(category)
                        }
                    }
                    
                    Picker("Prioridad", selection: $selectedPriority) {
                        ForEach(HabitsGoalPriority.allCases, id: \.self) { priority in
                            HStack {
                                Image(systemName: priority.icon)
                                    .foregroundColor(priority.color)
                                Text(priority.title)
                            }.tag(priority)
                        }
                    }
                }
                
                Section("Objetivo") {
                    HStack {
                        TextField("Valor objetivo", text: $targetValue)
                            .keyboardType(.decimalPad)
                        
                        TextField("Unidad", text: $unit)
                            .frame(width: 80)
                    }
                    
                    Toggle("Tiene fecha límite", isOn: $hasDeadline)
                    
                    if hasDeadline {
                        DatePicker("Fecha límite", selection: $deadline, in: Date()..., displayedComponents: .date)
                    }
                }
                
                Section("Hábitos Relacionados") {
                    if habitsService.habits.isEmpty {
                        Text("No tienes hábitos creados aún")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    } else {
                        ForEach(habitsService.habits) { habit in
                            HabitSelectionRow(
                                habit: habit,
                                isSelected: selectedHabits.contains(habit.id)
                            ) {
                                if selectedHabits.contains(habit.id) {
                                    selectedHabits.remove(habit.id)
                                } else {
                                    selectedHabits.insert(habit.id)
                                }
                            }
                        }
                    }
                }
                
                Section("Motivación y Obstáculos") {
                    TextField("¿Por qué es importante esta meta?", text: $motivation, axis: .vertical)
                        .lineLimit(2...4)
                    
                    TextField("¿Qué obstáculos podrías enfrentar?", text: $obstacles, axis: .vertical)
                        .lineLimit(2...4)
                    
                    TextField("¿Cómo te recompensarás al completarla?", text: $rewards, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section("Configuración Adicional") {
                    Toggle("Meta pública", isOn: $isPublic)
                        .help("Las metas públicas pueden ser vistas por otros usuarios")
                }
                
                Section("Vista Previa") {
                    GoalPreviewCard(
                        title: title.isEmpty ? "Mi nueva meta" : title,
                        description: description.isEmpty ? "Descripción de la meta" : description,
                        category: selectedCategory,
                        priority: selectedPriority,
                        targetValue: Double(targetValue) ?? 0,
                        unit: unit.isEmpty ? "unidades" : unit,
                        deadline: hasDeadline ? deadline : nil
                    )
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
                    .disabled(title.isEmpty || description.isEmpty || targetValue.isEmpty)
                }
            }
        }
    }
    
    private func createGoal() {
        let goal = HabitsGoal(
            title: title,
            description: description,
            category: selectedCategory,
            priority: selectedPriority,
            targetValue: Double(targetValue) ?? 0,
            unit: unit.isEmpty ? "unidades" : unit,
            deadline: hasDeadline ? deadline : nil,
            relatedHabits: Array(selectedHabits),
            motivation: motivation,
            obstacles: obstacles.isEmpty ? [] : obstacles.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            rewards: rewards.isEmpty ? [] : rewards.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            isPublic: isPublic
        )
        
        onSave(goal)
        dismiss()
    }
}

// MARK: - Habit Selection Row
struct HabitSelectionRow: View {
    let habit: Habit
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                Image(systemName: habit.category.icon)
                    .foregroundColor(habit.category.color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(habit.name)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(habit.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .green : .gray)
                    .font(.title3)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Goal Preview Card
struct GoalPreviewCard: View {
    let title: String
    let description: String
    let category: HabitsGoalCategory
    let priority: HabitsGoalPriority
    let targetValue: Double
    let unit: String
    let deadline: Date?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(category.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 8) {
                        Text(category.title)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(category.color.opacity(0.1))
                            .foregroundColor(category.color)
                            .cornerRadius(6)
                        
                        HStack(spacing: 4) {
                            Image(systemName: priority.icon)
                                .font(.caption)
                            Text(priority.title)
                                .font(.caption)
                        }
                        .foregroundColor(priority.color)
                    }
                }
                
                Spacer()
            }
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
            
            HStack {
                Text("Objetivo:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(Int(targetValue)) \(unit)")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if let deadline = deadline {
                    Text("Vence: \(deadline.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            // Progress Bar Placeholder
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Progreso")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("0%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(category.color)
                }
                
                ProgressView()
                    .progressViewStyle(LinearProgressViewStyle(tint: category.color))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemGray6))
        )
    }
}

#Preview {
    CreateGoalView { _ in }
}
