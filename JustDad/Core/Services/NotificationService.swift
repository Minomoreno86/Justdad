//
//  NotificationService.swift
//  JustDad
//
//  Professional notification management service for visit reminders
//

import Foundation
import UserNotifications

// Import local agenda types - will be resolved when types are properly integrated
// For now we'll use protocol-based approach to handle visit data

// MARK: - Visit Protocol for Notification Service
protocol NotificationVisitProtocol {
    var id: UUID { get }
    var title: String { get }
    var startDate: Date { get }
    var endDate: Date { get }
    var location: String? { get }
    var reminderMinutes: Int? { get }
    var isRecurring: Bool { get }
}

@MainActor
class NotificationService: ObservableObject {
    
    static let shared = NotificationService()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var isEnabled: Bool = false
    
    private let center = UNUserNotificationCenter.current()
    
    private init() {
        checkAuthorizationStatus()
        setupNotificationCategories()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            checkAuthorizationStatus()
            return granted
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }
    
    func checkAuthorizationStatus() {
        Task {
            let settings = await center.notificationSettings()
            await MainActor.run {
                self.authorizationStatus = settings.authorizationStatus
                self.isEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Visit Reminders (Generic Implementation)
    
    func scheduleVisitReminder(
        visitId: UUID,
        title: String,
        startDate: Date,
        location: String?,
        reminderMinutes: Int
    ) async {
        guard isEnabled else {
            print("Notifications not authorized")
            return
        }
        
        // Clear any existing notifications for this visit
        await cancelVisitReminder(for: visitId)
        
        // Schedule primary reminder
        await scheduleNotification(
            visitId: visitId,
            title: title,
            startDate: startDate,
            location: location,
            minutesBefore: reminderMinutes,
            identifier: "\(visitId.uuidString)_reminder"
        )
        
        // Schedule a second reminder 15 minutes before if the main reminder is more than 30 minutes
        if reminderMinutes > 30 {
            await scheduleNotification(
                visitId: visitId,
                title: title,
                startDate: startDate,
                location: location,
                minutesBefore: 15,
                identifier: "\(visitId.uuidString)_final_reminder"
            )
        }
    }
    
    private func scheduleNotification(
        visitId: UUID,
        title: String,
        startDate: Date,
        location: String?,
        minutesBefore: Int,
        identifier: String
    ) async {
        let content = UNMutableNotificationContent()
        content.title = "Recordatorio de Visita"
        content.body = "\(title) en \(minutesBefore) minutos"
        content.sound = .default
        content.badge = 1
        
        // Add action buttons
        content.categoryIdentifier = "VISIT_REMINDER"
        
        // Add location if available
        if let location = location {
            content.subtitle = "📍 \(location)"
        }
        
        // Add user info for deep linking
        content.userInfo = [
            "visitId": visitId.uuidString,
            "type": "visit_reminder"
        ]
        
        // Calculate trigger date
        let triggerDate = startDate.addingTimeInterval(-TimeInterval(minutesBefore * 60))
        
        // Only schedule if the trigger date is in the future
        guard triggerDate > Date() else { return }
        
        let triggerComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerComponents,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("Scheduled notification: \(identifier) for \(triggerDate)")
        } catch {
            print("Error scheduling notification: \(error)")
        }
    }
    
    func scheduleRecurringReminder(
        visitId: UUID,
        title: String,
        startDate: Date,
        location: String?,
        reminderMinutes: Int,
        frequency: RecurrenceFrequency,
        interval: Int = 1
    ) async {
        guard isEnabled else { return }
        
        // Schedule up to 10 future occurrences
        let calendar = Calendar.current
        
        for i in 1...10 {
            let nextDate: Date?
            
            switch frequency {
            case .daily:
                nextDate = calendar.date(byAdding: .day, value: interval * i, to: startDate)
            case .weekly:
                nextDate = calendar.date(byAdding: .weekOfYear, value: interval * i, to: startDate)
            case .monthly:
                nextDate = calendar.date(byAdding: .month, value: interval * i, to: startDate)
            }
            
            guard let date = nextDate, date > Date() else { continue }
            
            await scheduleNotification(
                visitId: UUID(), // New UUID for recurring instance
                title: title,
                startDate: date,
                location: location,
                minutesBefore: reminderMinutes,
                identifier: "\(visitId.uuidString)_recurring_\(i)"
            )
        }
    }
    
    func cancelVisitReminder(for visitId: UUID) async {
        var identifiers = [
            "\(visitId.uuidString)_reminder",
            "\(visitId.uuidString)_final_reminder"
        ]
        
        // Also cancel recurring reminders
        for i in 1...10 {
            identifiers.append("\(visitId.uuidString)_recurring_\(i)")
        }
        
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("Cancelled notifications for visit: \(visitId)")
    }
    
    // MARK: - Daily Summary
    
    func scheduleDailySummary() async {
        guard isEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Resumen Diario - JustDad"
        content.body = "Revisa las visitas programadas para hoy"
        content.sound = .default
        content.categoryIdentifier = "DAILY_SUMMARY"
        
        // Schedule for 8:00 AM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "daily_summary",
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("Scheduled daily summary notification")
        } catch {
            print("Error scheduling daily summary: \(error)")
        }
    }
    
    // MARK: - Utility
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await center.pendingNotificationRequests()
    }
    
    func removeAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
}

// MARK: - Recurrence Frequency Enum
enum RecurrenceFrequency {
    case daily
    case weekly
    case monthly
}

// MARK: - Notification Categories
extension NotificationService {
    
    func setupNotificationCategories() {
        let visitReminderCategory = UNNotificationCategory(
            identifier: "VISIT_REMINDER",
            actions: [
                UNNotificationAction(
                    identifier: "VIEW_VISIT",
                    title: "Ver Visita",
                    options: [.foreground]
                ),
                UNNotificationAction(
                    identifier: "SNOOZE_REMINDER",
                    title: "Recordar en 10 min",
                    options: []
                )
            ],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        let dailySummaryCategory = UNNotificationCategory(
            identifier: "DAILY_SUMMARY",
            actions: [
                UNNotificationAction(
                    identifier: "OPEN_AGENDA",
                    title: "Abrir Agenda",
                    options: [.foreground]
                )
            ],
            intentIdentifiers: [],
            options: []
        )
        
        center.setNotificationCategories([
            visitReminderCategory,
            dailySummaryCategory
        ])
    }
}
