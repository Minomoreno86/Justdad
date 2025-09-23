//
//  HabitsEditStackView.swift
//  JustDad - Edit Habit Stack
//
//  User interface for editing existing habit stacks
//

import SwiftUI

struct HabitsEditStackView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var habitsService = HabitsService.shared
    
    let stack: HabitStack
    let onSave: (HabitStack) -> Void
    
    @State private var stackName: String
    @State private var stackDescription: String
    @State private var stackTrigger: String
    @State private var selectedCategory: StackCategory
    @State private var selectedHabits: Set<UUID>
    @State private var showingHabitSelection = false
    @State private var showingDeleteConfirmation = false
    
    private var availableHabits: [Habit] {
        habitsService.habits.filter { $0.isActive }
    }
    
    private var selectedHabitsList: [Habit] {
        availableHabits.filter { selectedHabits.contains($0.id) }
    }
    
    private var isFormValid: Bool {
        !stackName.isEmpty && !stackTrigger.isEmpty && !selectedHabits.isEmpty
    }
    
    private var hasChanges: Bool {
        stackName != stack.name ||
        stackDescription != stack.description ||
        stackTrigger != stack.trigger ||
        selectedCategory != stack.category ||
        selectedHabits != Set(stack.habitIds)
    }
    
    init(stack: HabitStack, onSave: @escaping (HabitStack) -> Void) {
        self.stack = stack
        self.onSave = onSave
        
        _stackName = State(initialValue: stack.name)
        _stackDescription = State(initialValue: stack.description)
        _stackTrigger = State(initialValue: stack.trigger)
        _selectedCategory = State(initialValue: stack.category)
        _selectedHabits = State(initialValue: Set(stack.habitIds))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Basic Info
                    basicInfoSection
                    
                    // Trigger Section
                    triggerSection
                    
                    // Category Selection
                    categorySection
                    
                    // Habit Selection
                    habitSelectionSection
                    
                    // Selected Habits Preview
                    if !selectedHabits.isEmpty {
                        selectedHabitsSection
                    }
                    
                    // Danger Zone
                    dangerZoneSection
                }
                .padding()
            }
            .navigationTitle("Editar Stack")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveStack()
                    }
                    .disabled(!isFormValid || !hasChanges)
                }
            }
            .sheet(isPresented: $showingHabitSelection) {
                EditStackHabitSelectionView(
                    selectedHabits: $selectedHabits,
                    availableHabits: availableHabits
                )
            }
            .confirmationDialog("Eliminar Stack", isPresented: $showingDeleteConfirmation) {
                Button("Eliminar", role: .destructive) {
                    deleteStack()
                }
                
                Button("Cancelar", role: .cancel) { }
            } message: {
                Text("¿Estás seguro de que quieres eliminar este stack? Esta acción no se puede deshacer.")
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.stack.3d.up.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Editar Stack de Hábitos")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Modifica tu stack para que funcione mejor para ti")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
    }
    
    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Información Básica")
                .font(.headline)
            
            VStack(spacing: 12) {
                // Stack Name
                VStack(alignment: .leading, spacing: 4) {
                    Text("Nombre del Stack")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Ej: Rutina Matutina", text: $stackName)
                        .textFieldStyle(.roundedBorder)
                }
                
                // Stack Description
                VStack(alignment: .leading, spacing: 4) {
                    Text("Descripción")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Describe qué logra este stack...", text: $stackDescription, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                }
            }
        }
    }
    
    // MARK: - Trigger Section
    private var triggerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trigger (Desencadenador)")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("¿Cuándo quieres ejecutar este stack?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("Ej: Después de levantarme de la cama...", text: $stackTrigger)
                    .textFieldStyle(.roundedBorder)
                
                Text("💡 Tip: Usa el formato 'Después de [X], haré [Y]'")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
    }
    
    // MARK: - Category Section
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Categoría")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(StackCategory.allCases, id: \.self) { category in
                    EditStackCategoryCard(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
        }
    }
    
    // MARK: - Habit Selection Section
    private var habitSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Hábitos")
                    .font(.headline)
                
                Spacer()
                
                Text("\(selectedHabits.count) seleccionados")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if availableHabits.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    Text("No tienes hábitos activos")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("Crea algunos hábitos primero para poder incluirlos en un stack")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            } else {
                Button(action: {
                    showingHabitSelection = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Seleccionar Hábitos")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
                }
            }
        }
    }
    
    // MARK: - Selected Habits Section
    private var selectedHabitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hábitos Seleccionados")
                .font(.headline)
            
            LazyVStack(spacing: 8) {
                ForEach(Array(selectedHabitsList.enumerated()), id: \.element.id) { index, habit in
                    EditStackSelectedHabitRow(
                        habit: habit,
                        position: index + 1,
                        onRemove: {
                            selectedHabits.remove(habit.id)
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Danger Zone Section
    private var dangerZoneSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Zona de Peligro")
                .font(.headline)
                .foregroundColor(.red)
            
            Button(action: {
                showingDeleteConfirmation = true
            }) {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Eliminar Stack")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func saveStack() {
        var updatedStack = stack
        updatedStack.name = stackName
        updatedStack.description = stackDescription
        updatedStack.trigger = stackTrigger
        updatedStack.category = selectedCategory
        updatedStack.habitIds = selectedHabitsList.map { $0.id }
        updatedStack.updatedAt = Date()
        
        onSave(updatedStack)
        dismiss()
    }
    
    private func deleteStack() {
        HabitsStackingService.shared.deleteStack(stack)
        dismiss()
    }
}

// MARK: - Supporting Views (Reusing from CreateStackView)

struct EditStackCategoryCard: View {
    let category: StackCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : category.color)
                
                Text(category.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? category.color : Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EditStackSelectedHabitRow: View {
    let habit: Habit
    let position: Int
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Position indicator
            Text("\(position)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Color.blue)
                .clipShape(Circle())
            
            // Habit info
            Image(systemName: habit.category.icon)
                .foregroundColor(habit.category.color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(habit.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct EditStackHabitSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedHabits: Set<UUID>
    let availableHabits: [Habit]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(availableHabits) { habit in
                    EditStackHabitSelectionRow(
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
            .navigationTitle("Seleccionar Hábitos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                }
            })
        }
    }
}

struct EditStackHabitSelectionRow: View {
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
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(habit.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    let sampleStack = HabitStack(
        name: "Rutina Matutina",
        description: "Una rutina completa para empezar el día con energía",
        trigger: "Después de levantarme de la cama",
        habitIds: [],
        category: .morning
    )
    
    HabitsEditStackView(stack: sampleStack) { _ in }
}
