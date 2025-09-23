//
//  HabitsStackDetailView.swift
//  JustDad - Habit Stack Detail
//
//  Detailed view for individual habit stacks
//

import SwiftUI

struct HabitsStackDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var stackingService = HabitsStackingService.shared
    @StateObject private var habitsService = HabitsService.shared
    
    let stack: HabitStack
    
    @State private var showingEditStack = false
    @State private var showingCompletionConfirmation = false
    
    private var stackHabits: [Habit] {
        habitsService.habits.filter { stack.habitIds.contains($0.id) }
    }
    
    private var nextHabitToComplete: Habit? {
        // Find the first habit in the stack that hasn't been completed today
        for habitId in stack.habitIds {
            if let habit = habitsService.habits.first(where: { $0.id == habitId && !$0.isCompletedToday }) {
                return habit
            }
        }
        return nil
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Stack Progress
                    progressSection
                    
                    // Habits in Stack
                    habitsSection
                    
                    // Stack Stats
                    statsSection
                    
                    // Recent Activity
                    activitySection
                }
                .padding()
            }
            .navigationTitle(stack.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Editar") {
                        showingEditStack = true
                    }
                }
            }
            .sheet(isPresented: $showingEditStack) {
                HabitsEditStackView(stack: stack) { updatedStack in
                    stackingService.updateStack(updatedStack)
                }
            }
            .confirmationDialog("Completar Stack", isPresented: $showingCompletionConfirmation) {
                Button("Completar Stack Completo") {
                    completeFullStack()
                }
                
                Button("Completar Solo Hábitos Pendientes") {
                    completeRemainingHabits()
                }
                
                Button("Cancelar", role: .cancel) { }
            } message: {
                Text("¿Cómo quieres completar este stack?")
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: stack.category.icon)
                    .font(.title)
                    .foregroundColor(stack.category.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(stack.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(stack.category.title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if stack.isCompletedToday {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }
            
            if !stack.description.isEmpty {
                Text(stack.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            // Trigger
            VStack(alignment: .leading, spacing: 4) {
                Text("Trigger:")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(stack.trigger)
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Button(action: {
                    showingCompletionConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text(stack.isCompletedToday ? "Stack Completado" : "Completar Stack")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(stack.isCompletedToday ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                    .foregroundColor(stack.isCompletedToday ? .green : .blue)
                    .cornerRadius(12)
                }
                .disabled(stack.isCompletedToday)
                
                Button(action: {
                    // TODO: Implement quick complete for next habit
                }) {
                    HStack {
                        Image(systemName: "forward.fill")
                        Text("Siguiente")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.2))
                    .foregroundColor(.orange)
                    .cornerRadius(12)
                }
                .disabled(nextHabitToComplete == nil)
            }
        }
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progreso")
                .font(.headline)
            
            VStack(spacing: 12) {
                // Streak
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Racha Actual")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(stack.streak) días")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    Text(stack.motivationQuote)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                }
                
                // Completion Rate
                HStack {
                    Image(systemName: "chart.pie.fill")
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Tasa de Completado")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(stack.completionRate * 100))%")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    // Progress bar
                    VStack(alignment: .trailing, spacing: 4) {
                        ProgressView(value: stack.completionRate)
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(width: 100)
                        
                        Text("\(stack.completedDays.count) de \(max(1, Calendar.current.dateComponents([.day], from: stack.createdAt, to: Date()).day ?? 1)) días")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Weekly Progress
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(.green)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Esta Semana")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(stack.weeklyCompletionRate * 100))%")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    Text("\(Int(stack.weeklyCompletionRate * 7))/7 días")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Habits Section
    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hábitos en el Stack")
                .font(.headline)
            
            LazyVStack(spacing: 8) {
                ForEach(Array(stackHabits.enumerated()), id: \.element.id) { index, habit in
                    StackHabitRow(
                        habit: habit,
                        position: index + 1,
                        isCompletedToday: habit.isCompletedToday
                    ) {
                        habitsService.toggleHabitCompletion(habit)
                    }
                }
            }
        }
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Estadísticas")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StackingStatCard(
                    title: "Total Completados",
                    value: "\(stack.completedDays.count)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StackingStatCard(
                    title: "Mejor Racha",
                    value: "\(stack.streak) días",
                    icon: "flame.fill",
                    color: .orange
                )
                
                StackingStatCard(
                    title: "Tamaño del Stack",
                    value: "\(stack.habitIds.count) hábitos",
                    icon: "square.stack.3d.up.fill",
                    color: .blue
                )
                
                StackingStatCard(
                    title: "Creado",
                    value: DateFormatter.shortDate.string(from: stack.createdAt),
                    icon: "calendar.badge.plus",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Activity Section
    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Actividad Reciente")
                .font(.headline)
            
            if stack.completedDays.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text("No hay actividad aún")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("Completa este stack para ver tu progreso aquí")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(Array(stack.completedDays.sorted(by: >).prefix(7)), id: \.self) { date in
                        ActivityRow(date: date)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func completeFullStack() {
        stackingService.completeStack(stack.id)
        
        // Also complete all habits in the stack
        for habit in stackHabits where !habit.isCompletedToday {
            habitsService.toggleHabitCompletion(habit)
        }
    }
    
    private func completeRemainingHabits() {
        for habit in stackHabits where !habit.isCompletedToday {
            habitsService.toggleHabitCompletion(habit)
        }
    }
}

// MARK: - Supporting Views

struct StackHabitRow: View {
    let habit: Habit
    let position: Int
    let isCompletedToday: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // Position indicator
                Text("\(position)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(Color.blue)
                    .clipShape(Circle())
                
                // Habit icon
                Image(systemName: habit.category.icon)
                    .foregroundColor(habit.category.color)
                    .frame(width: 24)
                
                // Habit info
                VStack(alignment: .leading, spacing: 2) {
                    Text(habit.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(habit.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Completion status
                Image(systemName: isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompletedToday ? .green : .gray)
            }
            .padding()
            .background(isCompletedToday ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StackingStatCard: View {
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
                .font(.title3)
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

struct ActivityRow: View {
    let date: Date
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private var isYesterday: Bool {
        Calendar.current.isDateInYesterday(date)
    }
    
    private var dateText: String {
        if isToday {
            return "Hoy"
        } else if isYesterday {
            return "Ayer"
        } else {
            return DateFormatter.shortDate.string(from: date)
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            
            Text("Stack completado")
                .font(.subheadline)
            
            Spacer()
            
            Text(dateText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Extensions
extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

#Preview {
    let sampleStack = HabitStack(
        name: "Rutina Matutina",
        description: "Una rutina completa para empezar el día con energía",
        trigger: "Después de levantarme de la cama",
        habitIds: [],
        category: .morning
    )
    
    HabitsStackDetailView(stack: sampleStack)
}
