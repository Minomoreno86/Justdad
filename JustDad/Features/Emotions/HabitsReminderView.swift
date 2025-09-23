//
//  HabitsReminderView.swift
//  JustDad - Habit Reminders Management UI
//
//  User interface for managing habit reminders
//

import SwiftUI

struct HabitsReminderView: View {
    @StateObject private var reminderService = HabitsReminderService.shared
    @StateObject private var habitsService = HabitsService.shared
    @State private var showingAddReminder = false
    @State private var selectedHabit: Habit?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                headerView
                
                if !reminderService.isPermissionGranted {
                    permissionView
                } else if reminderService.reminders.isEmpty {
                    emptyStateView
                } else {
                    remindersListView
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddReminder) {
                if let habit = selectedHabit {
                    AddReminderView(habit: habit) { reminder in
                        reminderService.addReminder(reminder)
                    }
                }
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Recordatorios")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                if !reminderService.reminders.isEmpty {
                    Text("\(reminderService.reminders.filter { $0.isEnabled }.count) activos")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .background(Color(UIColor.systemBackground))
    }
    
    // MARK: - Permission View
    private var permissionView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            VStack(spacing: 12) {
                Text("Notificaciones Desactivadas")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Activa las notificaciones para recibir recordatorios de tus hábitos y mantener tu consistencia.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Activar Notificaciones") {
                Task {
                    await reminderService.requestNotificationPermission()
                }
            }
            .buttonStyle(HabitsPrimaryButtonStyle(color: .blue))
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "bell")
                .font(.system(size: 60))
                .foregroundColor(.purple)
            
            VStack(spacing: 12) {
                Text("Sin Recordatorios")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Agrega recordatorios para mantener tus hábitos y nunca perderte una oportunidad de mejorar.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Agregar Recordatorio") {
                if let firstHabit = habitsService.habits.first {
                    selectedHabit = firstHabit
                    showingAddReminder = true
                }
            }
            .buttonStyle(HabitsPrimaryButtonStyle(color: .purple))
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Reminders List
    private var remindersListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Quick Actions
                quickActionsView
                
                // Reminders by Habit
                ForEach(habitsService.habits) { habit in
                    let habitReminders = reminderService.getRemindersForHabit(habit.id)
                    if !habitReminders.isEmpty {
                        HabitReminderSection(
                            habit: habit,
                            reminders: habitReminders,
                            onToggle: { reminder in
                                reminderService.toggleReminder(reminder)
                            },
                            onEdit: { reminder in
                                // TODO: Implement edit functionality
                            },
                            onDelete: { reminder in
                                reminderService.deleteReminder(reminder)
                            }
                        )
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Quick Actions
    private var quickActionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Acciones Rápidas")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Agregar",
                    icon: "plus.circle.fill",
                    color: .green
                ) {
                    if let firstHabit = habitsService.habits.first {
                        selectedHabit = firstHabit
                        showingAddReminder = true
                    }
                }
                
                QuickActionButton(
                    title: "Configurar",
                    icon: "gear",
                    color: .blue
                ) {
                    // TODO: Implement settings
                }
                
                QuickActionButton(
                    title: "Estadísticas",
                    icon: "chart.bar.fill",
                    color: .purple
                ) {
                    // TODO: Implement statistics
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

// MARK: - Habit Reminder Section
struct HabitReminderSection: View {
    let habit: Habit
    let reminders: [HabitsReminder]
    let onToggle: (HabitsReminder) -> Void
    let onEdit: (HabitsReminder) -> Void
    let onDelete: (HabitsReminder) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: habit.category.icon)
                    .foregroundColor(habit.category.color)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(habit.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("\(reminders.count) recordatorio(s)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            ForEach(reminders) { reminder in
                ReminderRow(
                    reminder: reminder,
                    onToggle: { onToggle(reminder) },
                    onEdit: { onEdit(reminder) },
                    onDelete: { onDelete(reminder) }
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: habit.category.color.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(habit.category.color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Reminder Row
struct ReminderRow: View {
    let reminder: HabitsReminder
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Toggle
            Button(action: onToggle) {
                Image(systemName: reminder.isEnabled ? "bell.fill" : "bell.slash.fill")
                    .font(.title3)
                    .foregroundColor(reminder.isEnabled ? reminder.reminderType.color : .gray)
            }
            
            // Reminder Info
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(reminder.formattedTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(reminder.daysOfWeekText)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 8) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.systemGray6))
        )
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
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
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
            )
        }
    }
}

// MARK: - Add Reminder View
struct AddReminderView: View {
    @Environment(\.dismiss) private var dismiss
    let habit: Habit
    let onSave: (HabitsReminder) -> Void
    
    @State private var title = ""
    @State private var message = ""
    @State private var selectedTime = Date()
    @State private var selectedDays: Set<Int> = [1, 2, 3, 4, 5, 6, 7]
    @State private var reminderType = ReminderType.daily
    @State private var customMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información del Recordatorio") {
                    TextField("Título", text: $title)
                    TextField("Mensaje (opcional)", text: $message, axis: .vertical)
                }
                
                Section("Horario") {
                    DatePicker("Hora", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    
                    Picker("Tipo", selection: $reminderType) {
                        ForEach(ReminderType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                    .foregroundColor(type.color)
                                Text(type.title)
                            }.tag(type)
                        }
                    }
                }
                
                Section("Días de la Semana") {
                    ForEach(0..<7, id: \.self) { day in
                        let dayName = Calendar.current.weekdaySymbols[day]
                        Toggle(dayName, isOn: Binding(
                            get: { selectedDays.contains(day + 1) },
                            set: { isOn in
                                if isOn {
                                    selectedDays.insert(day + 1)
                                } else {
                                    selectedDays.remove(day + 1)
                                }
                            }
                        ))
                    }
                }
                
                Section("Mensaje Personalizado") {
                    TextField("Mensaje personalizado (opcional)", text: $customMessage, axis: .vertical)
                }
            }
            .navigationTitle("Nuevo Recordatorio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        let reminder = HabitsReminder(
                            habitId: habit.id,
                            title: title.isEmpty ? "¡Es hora de \(habit.name)!" : title,
                            message: message.isEmpty ? "Recuerda mantener tu hábito diario." : message,
                            time: selectedTime,
                            daysOfWeek: selectedDays,
                            reminderType: reminderType,
                            customMessage: customMessage.isEmpty ? nil : customMessage
                        )
                        onSave(reminder)
                        dismiss()
                    }
                    .disabled(title.isEmpty && message.isEmpty)
                }
            }
            .onAppear {
                title = "¡Es hora de \(habit.name)!"
                message = "Recuerda mantener tu hábito diario."
            }
        }
    }
}

#Preview {
    HabitsReminderView()
}
