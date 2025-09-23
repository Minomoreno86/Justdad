//
//  HabitsCreateStackView.swift
//  JustDad - Create Habit Stack
//
//  User interface for creating new habit stacks
//

import SwiftUI

struct HabitsCreateStackView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var habitsService = HabitsService.shared
    
    let onSave: (HabitStack) -> Void
    
    @State private var stackName = ""
    @State private var stackDescription = ""
    @State private var stackTrigger = ""
    @State private var selectedCategory: StackCategory = .morning
    @State private var selectedHabits: Set<UUID> = []
    @State private var showingHabitSelection = false
    
    private var availableHabits: [Habit] {
        habitsService.habits.filter { $0.isActive }
    }
    
    private var selectedHabitsList: [Habit] {
        availableHabits.filter { selectedHabits.contains($0.id) }
    }
    
    private var isFormValid: Bool {
        !stackName.isEmpty && !stackTrigger.isEmpty && !selectedHabits.isEmpty
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
                }
                .padding()
            }
            .navigationTitle("Crear Stack")
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
                    .disabled(!isFormValid)
                }
            }
            .sheet(isPresented: $showingHabitSelection) {
                CreateStackHabitSelectionView(
                    selectedHabits: $selectedHabits,
                    availableHabits: availableHabits
                )
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.stack.3d.up.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Crea tu Stack de Hábitos")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Conecta hábitos para crear rutinas automáticas más efectivas")
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
                    CreateStackCategoryCard(
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
                    CreateStackSelectedHabitRow(
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
    
    // MARK: - Helper Methods
    private func saveStack() {
        let stack = HabitStack(
            name: stackName,
            description: stackDescription,
            trigger: stackTrigger,
            habitIds: selectedHabitsList.map { $0.id },
            category: selectedCategory
        )
        
        onSave(stack)
        dismiss()
    }
}

// MARK: - Supporting Views

struct CreateStackCategoryCard: View {
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

struct CreateStackSelectedHabitRow: View {
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

struct CreateStackHabitSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedHabits: Set<UUID>
    let availableHabits: [Habit]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(availableHabits) { habit in
                    CreateStackHabitSelectionRow(
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CreateStackHabitSelectionRow: View {
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
    HabitsCreateStackView { _ in }
}
