//
//  NotificationService.swift
//  JustDad - Notification management service
//
//  Handles local notifications for visits, reminders, and app features
//

import Foundation
import UserNotifications
import Combine

@MainActor
class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var isEnabled: Bool = true
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        notificationCenter.delegate = self
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
            checkAuthorizationStatus()
            return granted
        } catch {
            print("Failed to request notification permission: \(error)")
            return false
        }
    }
    
    private func checkAuthorizationStatus() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatus = settings.authorizationStatus
                self?.isEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Visit Notifications
    func scheduleVisitReminder(for visit: AgendaVisit) {
        guard isEnabled else { return }
        
        // Calculate reminder time based on visit's reminderMinutes setting
        let reminderMinutes = visit.reminderMinutes ?? 15 // Default to 15 minutes
        let reminderDate = visit.startDate.addingTimeInterval(-TimeInterval(reminderMinutes * 60))
        
        // Don't schedule if reminder time is in the past
        guard reminderDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Recordatorio de Visita"
        content.body = "\(visit.title) - \(visit.startDate.formatted(date: .omitted, time: .shortened))"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "VISIT_REMINDER"
        
        // Add visit info to userInfo
        content.userInfo = [
            "visitId": visit.id.uuidString,
            "visitTitle": visit.title,
            "visitType": visit.visitType.rawValue,
            "visitStartDate": visit.startDate.timeIntervalSince1970
        ]
        
        // Schedule notification at calculated reminder time
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "visit_\(visit.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule visit reminder: \(error)")
            } else {
                print("✅ Scheduled reminder for visit: \(visit.title) at \(reminderDate.formatted())")
            }
        }
    }
    
    func cancelVisitReminder(for visitId: UUID) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["visit_\(visitId.uuidString)"])
    }
    
    func scheduleRemindersForVisits(_ visits: [AgendaVisit]) {
        for visit in visits {
            scheduleVisitReminder(for: visit)
        }
    }
    
    func cancelAllVisitReminders() {
        notificationCenter.getPendingNotificationRequests { requests in
            let visitIdentifiers = requests
                .filter { $0.identifier.hasPrefix("visit_") }
                .map { $0.identifier }
            
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: visitIdentifiers)
        }
    }
    
    func rescheduleAllVisitReminders(for visits: [AgendaVisit]) {
        // Cancel all existing visit reminders
        cancelAllVisitReminders()
        
        // Schedule new reminders
        scheduleRemindersForVisits(visits)
    }
    
    // MARK: - Daily Reminders
    func scheduleDailyReminder(at time: Date) {
        guard isEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "¡Hola! 👋"
        content.body = "¿Cómo te sientes hoy? Registra tu estado de ánimo en JustDad"
        content.sound = .default
        content.categoryIdentifier = "DAILY_REMINDER"
        
        let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_reminder",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule daily reminder: \(error)")
            }
        }
    }
    
    func cancelDailyReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["daily_reminder"])
    }
    
    // MARK: - Weekly Summary
    func scheduleWeeklySummary() {
        guard isEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Resumen Semanal 📊"
        content.body = "Revisa tu semana en JustDad y planifica la próxima"
        content.sound = .default
        content.categoryIdentifier = "WEEKLY_SUMMARY"
        
        // Schedule for Sunday at 8 PM
        var dateComponents = DateComponents()
        dateComponents.weekday = 1 // Sunday
        dateComponents.hour = 20
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "weekly_summary",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule weekly summary: \(error)")
            }
        }
    }
    
    func cancelWeeklySummary() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["weekly_summary"])
    }
    
    // MARK: - Backup Reminders
    func scheduleBackupReminder() {
        guard isEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Respaldo de Datos 💾"
        content.body = "Recuerda hacer un respaldo de tus datos importantes"
        content.sound = .default
        content.categoryIdentifier = "BACKUP_REMINDER"
        
        // Schedule for the 1st of each month at 9 AM
        var dateComponents = DateComponents()
        dateComponents.day = 1
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "backup_reminder",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule backup reminder: \(error)")
            }
        }
    }
    
    func cancelBackupReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["backup_reminder"])
    }
    
    // MARK: - Emergency Notifications
    func scheduleEmergencyCheckIn() {
        guard isEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "¿Todo bien? 🤔"
        content.body = "Hace tiempo que no usas la app. ¿Necesitas ayuda?"
        content.sound = .default
        content.categoryIdentifier = "EMERGENCY_CHECKIN"
        
        // Schedule for 3 days of inactivity
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3 * 24 * 60 * 60, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "emergency_checkin",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule emergency check-in: \(error)")
            }
        }
    }
    
    func cancelEmergencyCheckIn() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["emergency_checkin"])
    }
    
    // MARK: - Notification Categories
    func setupNotificationCategories() {
        let visitReminderCategory = UNNotificationCategory(
            identifier: "VISIT_REMINDER",
            actions: [
                UNNotificationAction(identifier: "VIEW_VISIT", title: "Ver Cita", options: [.foreground]),
                UNNotificationAction(identifier: "SNOOZE", title: "Posponer 10 min", options: [])
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let dailyReminderCategory = UNNotificationCategory(
            identifier: "DAILY_REMINDER",
            actions: [
                UNNotificationAction(identifier: "LOG_MOOD", title: "Registrar Estado", options: [.foreground]),
                UNNotificationAction(identifier: "DISMISS", title: "Descartar", options: [])
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let weeklySummaryCategory = UNNotificationCategory(
            identifier: "WEEKLY_SUMMARY",
            actions: [
                UNNotificationAction(identifier: "VIEW_ANALYTICS", title: "Ver Resumen", options: [.foreground]),
                UNNotificationAction(identifier: "DISMISS", title: "Descartar", options: [])
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let backupReminderCategory = UNNotificationCategory(
            identifier: "BACKUP_REMINDER",
            actions: [
                UNNotificationAction(identifier: "BACKUP_NOW", title: "Respaldar Ahora", options: [.foreground]),
                UNNotificationAction(identifier: "REMIND_LATER", title: "Recordar Más Tarde", options: [])
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let emergencyCheckInCategory = UNNotificationCategory(
            identifier: "EMERGENCY_CHECKIN",
            actions: [
                UNNotificationAction(identifier: "I_AM_OK", title: "Estoy Bien", options: []),
                UNNotificationAction(identifier: "NEED_HELP", title: "Necesito Ayuda", options: [.foreground])
            ],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([
            visitReminderCategory,
            dailyReminderCategory,
            weeklySummaryCategory,
            backupReminderCategory,
            emergencyCheckInCategory
        ])
    }
    
    // MARK: - Cleanup
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }
    
    func cancelNotification(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // MARK: - Debug
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }
    
    func getDeliveredNotifications() async -> [UNNotification] {
        return await notificationCenter.deliveredNotifications()
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        switch response.actionIdentifier {
        case "VIEW_VISIT":
            // Handle view visit action
            if let visitId = userInfo["visitId"] as? String {
                // Navigate to visit detail
                print("Navigate to visit: \(visitId)")
            }
        case "LOG_MOOD":
            // Handle log mood action
            print("Navigate to emotions view")
        case "VIEW_ANALYTICS":
            // Handle view analytics action
            print("Navigate to analytics view")
        case "BACKUP_NOW":
            // Handle backup now action
            print("Start backup process")
        case "NEED_HELP":
            // Handle need help action
            print("Navigate to SOS view")
        default:
            break
        }
        
        completionHandler()
    }
    
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .badge, .sound])
        } else {
            completionHandler([.alert, .badge, .sound])
        }
    }
}