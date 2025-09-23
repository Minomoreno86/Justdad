//
//  HabitsReminderService.swift
//  JustDad - Habit Reminders Management
//
//  Advanced reminder system for habit tracking
//

import Foundation
import UserNotifications
import SwiftUI

// MARK: - Habit Reminder Model
struct HabitsReminder: Identifiable, Codable {
    let id: UUID
    let habitId: UUID
    let title: String
    let message: String
    let time: Date
    let daysOfWeek: Set<Int> // 0 = Sunday, 1 = Monday, etc.
    var isEnabled: Bool
    let reminderType: ReminderType
    let customMessage: String?
    
    init(habitId: UUID, title: String, message: String, time: Date, daysOfWeek: Set<Int> = [1, 2, 3, 4, 5, 6, 7], isEnabled: Bool = true, reminderType: ReminderType = .daily, customMessage: String? = nil) {
        self.id = UUID()
        self.habitId = habitId
        self.title = title
        self.message = message
        self.time = time
        self.daysOfWeek = daysOfWeek
        self.isEnabled = isEnabled
        self.reminderType = reminderType
        self.customMessage = customMessage
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
    
    var daysOfWeekText: String {
        if daysOfWeek.count == 7 {
            return "Todos los días"
        } else if daysOfWeek == Set([1, 2, 3, 4, 5]) {
            return "Días laborales"
        } else if daysOfWeek == Set([6, 7]) {
            return "Fines de semana"
        } else {
            let dayNames = ["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"]
            let selectedDays = daysOfWeek.sorted().map { dayNames[$0] }
            return selectedDays.joined(separator: ", ")
        }
    }
}

enum ReminderType: String, CaseIterable, Codable {
    case daily = "daily"
    case weekly = "weekly"
    case milestone = "milestone"
    case motivational = "motivational"
    
    var title: String {
        switch self {
        case .daily: return "Diario"
        case .weekly: return "Semanal"
        case .milestone: return "Hitos"
        case .motivational: return "Motivacional"
        }
    }
    
    var icon: String {
        switch self {
        case .daily: return "bell.fill"
        case .weekly: return "calendar.badge.clock"
        case .milestone: return "star.fill"
        case .motivational: return "heart.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .daily: return .blue
        case .weekly: return .green
        case .milestone: return .orange
        case .motivational: return .purple
        }
    }
}

// MARK: - Habits Reminder Service
@MainActor
class HabitsReminderService: ObservableObject {
    static let shared = HabitsReminderService()
    
    @Published var reminders: [HabitsReminder] = []
    @Published var isPermissionGranted: Bool = false
    
    private init() {
        loadReminders()
        checkNotificationPermission()
    }
    
    // MARK: - Permission Management
    func requestNotificationPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            isPermissionGranted = granted
            
            if granted {
                await MainActor.run {
                    // Schedule existing reminders
                    scheduleAllReminders()
                }
            }
        } catch {
            print("Error requesting notification permission: \(error)")
        }
    }
    
    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Reminder Management
    func addReminder(_ reminder: HabitsReminder) {
        reminders.append(reminder)
        saveReminders()
        scheduleReminder(reminder)
    }
    
    func updateReminder(_ reminder: HabitsReminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
            saveReminders()
            unscheduleReminder(reminder.id)
            scheduleReminder(reminder)
        }
    }
    
    func deleteReminder(_ reminder: HabitsReminder) {
        reminders.removeAll { $0.id == reminder.id }
        saveReminders()
        unscheduleReminder(reminder.id)
    }
    
    func toggleReminder(_ reminder: HabitsReminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index].isEnabled.toggle()
            saveReminders()
            
            if reminders[index].isEnabled {
                scheduleReminder(reminders[index])
            } else {
                unscheduleReminder(reminder.id)
            }
        }
    }
    
    // MARK: - Scheduling
    private func scheduleReminder(_ reminder: HabitsReminder) {
        guard isPermissionGranted && reminder.isEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.customMessage ?? reminder.message
        content.sound = .default
        content.badge = 1
        
        // Add habit ID to user info for tracking
        content.userInfo = ["habitId": reminder.habitId.uuidString]
        
        // Create date components for the reminder time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminder.time)
        
        // Schedule for each day of the week
        for dayOfWeek in reminder.daysOfWeek {
            var dateComponents = DateComponents()
            dateComponents.weekday = dayOfWeek
            dateComponents.hour = components.hour
            dateComponents.minute = components.minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "\(reminder.id.uuidString)-\(dayOfWeek)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling reminder: \(error)")
                }
            }
        }
    }
    
    private func unscheduleReminder(_ reminderId: UUID) {
        // Get all pending notifications
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiersToRemove = requests
                .filter { $0.identifier.hasPrefix(reminderId.uuidString) }
                .map { $0.identifier }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }
    }
    
    private func scheduleAllReminders() {
        for reminder in reminders {
            scheduleReminder(reminder)
        }
    }
    
    // MARK: - Smart Reminders
    func createSmartReminder(for habit: Habit) -> HabitsReminder {
        let defaultTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        
        let title = "¡Es hora de \(habit.name)!"
        let message = generateMotivationalMessage(for: habit)
        
        return HabitsReminder(
            habitId: habit.id,
            title: title,
            message: message,
            time: defaultTime,
            reminderType: .daily
        )
    }
    
    private func generateMotivationalMessage(for habit: Habit) -> String {
        let messages = [
            "Cada pequeño paso te acerca a tu meta. ¡Tú puedes!",
            "La consistencia es la clave del éxito. ¡Vamos!",
            "Recuerda por qué empezaste este hábito. ¡Sigue adelante!",
            "Hoy es un nuevo día para ser mejor que ayer.",
            "Los hábitos atómicos crean cambios extraordinarios.",
            "Tu futuro yo te lo agradecerá. ¡Hazlo ahora!",
            "La disciplina es el puente entre metas y logros."
        ]
        
        return messages.randomElement() ?? "¡Es hora de mantener tu racha!"
    }
    
    func getRemindersForHabit(_ habitId: UUID) -> [HabitsReminder] {
        return reminders.filter { $0.habitId == habitId }
    }
    
    // MARK: - Persistence
    private func saveReminders() {
        if let data = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(data, forKey: "habit_reminders")
        }
    }
    
    private func loadReminders() {
        if let data = UserDefaults.standard.data(forKey: "habit_reminders"),
           let loadedReminders = try? JSONDecoder().decode([HabitsReminder].self, from: data) {
            reminders = loadedReminders
        }
    }
    
    // MARK: - Analytics
    func getReminderStats() -> (total: Int, enabled: Int, byType: [ReminderType: Int]) {
        let enabled = reminders.filter { $0.isEnabled }.count
        var byType: [ReminderType: Int] = [:]
        
        for reminder in reminders {
            byType[reminder.reminderType, default: 0] += 1
        }
        
        return (reminders.count, enabled, byType)
    }
}

// MARK: - Reminder Templates
extension HabitsReminderService {
    static let defaultReminders: [HabitsReminder] = [
        HabitsReminder(
            habitId: UUID(),
            title: "Recordatorio Diario",
            message: "¡Es hora de mantener tus hábitos!",
            time: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date(),
            reminderType: .daily
        ),
        HabitsReminder(
            habitId: UUID(),
            title: "Reflexión Semanal",
            message: "Tómate un momento para revisar tu progreso esta semana.",
            time: Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date(),
            daysOfWeek: [1], // Sunday
            reminderType: .weekly
        )
    ]
}
