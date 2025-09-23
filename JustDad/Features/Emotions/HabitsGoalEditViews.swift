//
//  HabitsGoalEditViews.swift
//  JustDad - Goal Edit UI
//
//  Vistas auxiliares para editar metas y actualizar progreso
//

import SwiftUI

// MARK: - Edit Goal View
struct EditGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var habitsService = HabitsService.shared
    
    @State private var title: String
    @State private var description: String
    @State private var selectedCategory: HabitsGoalCategory
    @State private var selectedPriority: HabitsGoalPriority
    @State private var targetValue: String
    @State private var unit: String
    @State private var hasDeadline: Bool
    @State private var deadline: Date
    @State private var motivation: String
    @State private var obstacles: String
    @State private var rewards: String
    @State private var selectedHabits: Set<UUID>
    @State private var isPublic: Bool
    
    let goal: HabitsGoal
    let onSave: (HabitsGoal) -> Void
    
    init(goal: HabitsGoal, onSave: @escaping (HabitsGoal) -> Void) {
        self.goal = goal
        self.onSave = onSave
        
        self._title = State(initialValue: goal.title)
        self._description = State(initialValue: goal.description)
        self._selectedCategory = State(initialValue: goal.category)
        self._selectedPriority = State(initialValue: goal.priority)
        self._targetValue = State(initialValue: String(Int(goal.targetValue)))
        self._unit = State(initialValue: goal.unit)
        self._hasDeadline = State(initialValue: goal.deadline != nil)
        self._deadline = State(initialValue: goal.deadline ?? Date())
        self._motivation = State(initialValue: goal.motivation)
        self._obstacles = State(initialValue: goal.obstacles.joined(separator: ", "))
        self._rewards = State(initialValue: goal.rewards.joined(separator: ", "))
        self._selectedHabits = State(initialValue: Set(goal.relatedHabits))
        self._isPublic = State(initialValue: goal.isPublic)
    }
    
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
            }
            .navigationTitle("Editar Meta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveGoal()
                    }
                    .disabled(title.isEmpty || description.isEmpty || targetValue.isEmpty)
                }
            }
        }
    }
    
    private func saveGoal() {
        var updatedGoal = goal
        updatedGoal.title = title
        updatedGoal.description = description
        updatedGoal.category = selectedCategory
        updatedGoal.priority = selectedPriority
        updatedGoal.targetValue = Double(targetValue) ?? 0
        updatedGoal.unit = unit
        updatedGoal.deadline = hasDeadline ? deadline : nil
        updatedGoal.relatedHabits = Array(selectedHabits)
        updatedGoal.motivation = motivation
        updatedGoal.obstacles = obstacles.isEmpty ? [] : obstacles.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        updatedGoal.rewards = rewards.isEmpty ? [] : rewards.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        updatedGoal.isPublic = isPublic
        
        onSave(updatedGoal)
        dismiss()
    }
}

// MARK: - Progress Update View
struct ProgressUpdateView: View {
    @Environment(\.dismiss) private var dismiss
    
    let goal: HabitsGoal
    let onUpdate: (Double) -> Void
    
    @State private var progressValue: Double
    @State private var progressText: String
    @State private var notes: String = ""
    
    init(goal: HabitsGoal, onUpdate: @escaping (Double) -> Void) {
        self.goal = goal
        self.onUpdate = onUpdate
        self._progressValue = State(initialValue: goal.currentProgress)
        self._progressText = State(initialValue: String(Int(goal.currentProgress * goal.targetValue)))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Progreso Actual") {
                    HStack {
                        Text("Progreso actual:")
                        Spacer()
                        Text("\(Int(goal.currentProgress * goal.targetValue)) / \(Int(goal.targetValue)) \(goal.unit)")
                            .fontWeight(.semibold)
                            .foregroundColor(goal.category.color)
                    }
                    
                    ProgressView(value: goal.currentProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: goal.category.color))
                        .scaleEffect(y: 2)
                }
                
                Section("Actualizar Progreso") {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Nuevo valor:")
                            Spacer()
                            TextField("Valor", text: $progressText)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 100)
                            Text(goal.unit)
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $progressValue, in: 0...1, step: 0.01)
                            .accentColor(goal.category.color)
                            .onChange(of: progressValue) { newValue in
                                progressText = String(Int(newValue * goal.targetValue))
                            }
                            .onChange(of: progressText) { newValue in
                                if let value = Double(newValue) {
                                    progressValue = min(value / goal.targetValue, 1.0)
                                }
                            }
                        
                        Text("Progreso: \(Int(progressValue * 100))%")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(goal.category.color)
                    }
                }
                
                Section("Notas (Opcional)") {
                    TextField("¿Cómo te sientes con este progreso?", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Vista Previa") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Progreso actualizado:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("\(Int(progressValue * goal.targetValue)) / \(Int(goal.targetValue)) \(goal.unit)")
                                .font(.body)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text("\(Int(progressValue * 100))%")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(goal.category.color)
                        }
                        
                        ProgressView(value: progressValue)
                            .progressViewStyle(LinearProgressViewStyle(tint: goal.category.color))
                            .scaleEffect(y: 1.5)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.systemGray6))
                    )
                }
            }
            .navigationTitle("Actualizar Progreso")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Actualizar") {
                        onUpdate(progressValue)
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Milestone Detail View
struct MilestoneDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    let milestone: GoalMilestone
    let onComplete: (GoalMilestone) -> Void
    
    @State private var currentValue: Double
    @State private var notes: String = ""
    
    init(milestone: GoalMilestone, onComplete: @escaping (GoalMilestone) -> Void) {
        self.milestone = milestone
        self.onComplete = onComplete
        self._currentValue = State(initialValue: milestone.currentValue)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información del Hito") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(milestone.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(milestone.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("Objetivo:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(Int(milestone.targetValue))")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                Section("Progreso") {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Valor actual:")
                            Spacer()
                            Text("\(Int(currentValue))")
                                .fontWeight(.semibold)
                                .foregroundColor(.purple)
                        }
                        
                        Slider(value: $currentValue, in: 0...milestone.targetValue, step: 1)
                            .accentColor(.purple)
                        
                        HStack {
                            Text("0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(Int(milestone.targetValue))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        ProgressView(value: currentValue / milestone.targetValue)
                            .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                            .scaleEffect(y: 2)
                    }
                }
                
                Section("Notas") {
                    TextField("Notas sobre este hito...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                if currentValue >= milestone.targetValue && !milestone.isCompleted {
                    Section {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                                
                                Text("¡Hito completado!")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }
                            
                            Text("Has alcanzado el objetivo de este hito. ¿Quieres marcarlo como completado?")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
            }
            .navigationTitle("Detalle del Hito")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if currentValue >= milestone.targetValue && !milestone.isCompleted {
                        Button("Completar") {
                            completeMilestone()
                        }
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                    }
                }
            }
        }
    }
    
    private func completeMilestone() {
        var updatedMilestone = milestone
        updatedMilestone.currentValue = currentValue
        updatedMilestone.isCompleted = true
        updatedMilestone.completedAt = Date()
        
        onComplete(updatedMilestone)
        dismiss()
    }
}

#Preview {
    EditGoalView(goal: HabitsGoal(
        title: "Ejercicio diario",
        description: "Hacer ejercicio 30 minutos todos los días",
        category: .health,
        priority: .high,
        targetValue: 30,
        unit: "días"
    )) { _ in }
}
