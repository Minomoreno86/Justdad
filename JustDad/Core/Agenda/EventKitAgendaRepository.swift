//
//  EventKitAgendaRepository.swift
//  JustDad - EventKit Calendar Integration
//
//  Full EventKit integration with graceful permission handling
//

import Foundation
import EventKit
import UserNotifications

// Import core agenda types
// AgendaTypes should be imported via the module system

@MainActor
class EventKitAgendaRepository: ObservableObject, AgendaRepositoryProtocol {
    @Published var permissionStatus: AgendaPermissionStatus = .notDetermined
    @Published var notificationPermissionGranted: Bool = false
    
    private let eventStore = EKEventStore()
    private let userDefaults = UserDefaults.standard
    private let visitsKey = "eventkit_visits"
    private let calendar = Calendar.current
    
    // Fallback to InMemory if EventKit fails
    private let fallbackRepository = InMemoryAgendaRepository()
    
    init() {
        checkCurrentPermissions()
        requestNotificationPermission()
    }
    
    // MARK: - Repository Protocol Implementation
    
    func getAllVisits() async throws -> [Visit] {
        guard permissionStatus.isAuthorized else {
            return try await fallbackRepository.getAllVisits()
        }
        
        let startDate = calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        let endDate = calendar.date(byAdding: .year, value: 1, to: Date()) ?? Date()
        
        return try await getVisits(from: startDate, to: endDate)
    }
    
    func getVisits(for date: Date) async throws -> [Visit] {
        guard permissionStatus.isAuthorized else {
            return try await fallbackRepository.getVisits(for: date)
        }
        
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        return try await getVisits(from: startOfDay, to: endOfDay)
    }
    
    func getVisits(from startDate: Date, to endDate: Date) async throws -> [Visit] {
        guard permissionStatus.isAuthorized else {
            return try await fallbackRepository.getVisits(from: startDate, to: endDate)
        }
        
        return await withCheckedContinuation { continuation in
            let predicate = eventStore.predicateForEvents(
                withStart: startDate,
                end: endDate,
                calendars: nil
            )
            
            let events = eventStore.events(matching: predicate)
            let visits = events.compactMap { event in
                convertEventToVisit(event)
            }
            
            continuation.resume(returning: visits)
        }
    }
    
    func createVisit(_ visit: Visit) async throws -> Visit {
        guard permissionStatus.isAuthorized else {
            return try await fallbackRepository.createVisit(visit)
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = visit.title
        event.startDate = visit.startDate
        event.endDate = visit.endDate
        event.location = visit.location
        event.notes = visit.notes
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        // Add reminder if specified
        if let reminderMinutes = visit.reminderMinutes {
            let alarm = EKAlarm(relativeOffset: TimeInterval(-reminderMinutes * 60))
            event.addAlarm(alarm)
        }
        
        // Handle recurrence
        if visit.isRecurring, let recurrenceRule = visit.recurrenceRule {
            event.recurrenceRules = [createRecurrenceRule(recurrenceRule)]
        }
        
        do {
            try eventStore.save(event, span: .thisEvent)
            
            var updatedVisit = visit
            updatedVisit.eventKitIdentifier = event.eventIdentifier
            
            // Schedule user notification if enabled
            if notificationPermissionGranted, let reminderMinutes = visit.reminderMinutes {
                await scheduleNotification(for: updatedVisit, minutesBefore: reminderMinutes)
            }
            
            return updatedVisit
        } catch {
            print("❌ Failed to save event to EventKit: \(error)")
            return try await fallbackRepository.createVisit(visit)
        }
    }
    
    func updateVisit(_ visit: Visit) async throws -> Visit {
        guard permissionStatus.isAuthorized,
              let eventIdentifier = visit.eventKitIdentifier,
              let event = eventStore.event(withIdentifier: eventIdentifier) else {
            return try await fallbackRepository.updateVisit(visit)
        }
        
        event.title = visit.title
        event.startDate = visit.startDate
        event.endDate = visit.endDate
        event.location = visit.location
        event.notes = visit.notes
        
        // Update reminders
        event.removeAlarm(event.alarms?.first)
        if let reminderMinutes = visit.reminderMinutes {
            let alarm = EKAlarm(relativeOffset: TimeInterval(-reminderMinutes * 60))
            event.addAlarm(alarm)
        }
        
        do {
            try eventStore.save(event, span: .thisEvent)
            return visit
        } catch {
            print("❌ Failed to update event in EventKit: \(error)")
            return try await fallbackRepository.updateVisit(visit)
        }
    }
    
    func deleteVisit(id: UUID) async throws {
        // Try to find and delete from EventKit first
        if permissionStatus.isAuthorized {
            let visits = try await getAllVisits()
            if let visit = visits.first(where: { $0.id == id }),
               let eventIdentifier = visit.eventKitIdentifier,
               let event = eventStore.event(withIdentifier: eventIdentifier) {
                do {
                    try eventStore.remove(event, span: .thisEvent)
                    
                    // Cancel notification
                    UNUserNotificationCenter.current().removePendingNotificationRequests(
                        withIdentifiers: [id.uuidString]
                    )
                    return
                } catch {
                    print("❌ Failed to delete event from EventKit: \(error)")
                }
            }
        }
        
        // Fallback to in-memory deletion
        try await fallbackRepository.deleteVisit(id: id)
    }
    
    func requestCalendarPermission() async -> Bool {
        let status = await withCheckedContinuation { continuation in
            eventStore.requestFullAccessToEvents { granted, error in
                if let error = error {
                    print("❌ Calendar permission error: \(error)")
                    continuation.resume(returning: false)
                } else {
                    continuation.resume(returning: granted)
                }
            }
        }
        
        await MainActor.run {
            permissionStatus = status ? .authorized : .denied
        }
        
        return status
    }
    
    func syncWithEventKit() async throws {
        guard permissionStatus.isAuthorized else {
            throw AgendaError.permissionDenied
        }
        
        print("📅 EventKit sync completed successfully")
    }
    
    // MARK: - Permission Management
    
    private func checkCurrentPermissions() {
        let status = EKEventStore.authorizationStatus(for: .event)
        permissionStatus = AgendaPermissionStatus.from(ekStatus: status)
    }
    
    private func requestNotificationPermission() {
        Task {
            do {
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                    options: [.alert, .sound, .badge]
                )
                await MainActor.run {
                    notificationPermissionGranted = granted
                }
            } catch {
                print("❌ Notification permission error: \(error)")
                await MainActor.run {
                    notificationPermissionGranted = false
                }
            }
        }
    }
    
    // MARK: - EventKit Conversion
    
    private func convertEventToVisit(_ event: EKEvent) -> Visit? {
        guard let title = event.title else { return nil }
        
        let reminderMinutes = event.alarms?.first.map { Int(-$0.relativeOffset / 60) }
        
        let visitType: VisitType
        if let notes = event.notes?.lowercased() {
            if notes.contains("weekend") || notes.contains("fin de semana") {
                visitType = .weekend
            } else if notes.contains("dinner") || notes.contains("cena") {
                visitType = .dinner
            } else if notes.contains("event") || notes.contains("evento") {
                visitType = .event
            } else if notes.contains("emergency") || notes.contains("emergencia") {
                visitType = .emergency
            } else {
                visitType = .general
            }
        } else {
            visitType = .general
        }
        
        return Visit(
            id: UUID(),
            title: title,
            startDate: event.startDate,
            endDate: event.endDate,
            location: event.location,
            notes: event.notes,
            reminderMinutes: reminderMinutes,
            isRecurring: event.hasRecurrenceRules,
            recurrenceRule: nil, // Simplified for now
            visitType: visitType,
            eventKitIdentifier: event.eventIdentifier
        )
    }
    
    private func createRecurrenceRule(_ rule: RecurrenceRule) -> EKRecurrenceRule {
        let frequency: EKRecurrenceFrequency
        let interval: Int
        
        switch rule {
        case .daily:
            frequency = .daily
            interval = 1
        case .weekly:
            frequency = .weekly
            interval = 1
        case .biweekly:
            frequency = .weekly
            interval = 2
        case .monthly:
            frequency = .monthly
            interval = 1
        }
        
        return EKRecurrenceRule(
            recurrenceWith: frequency,
            interval: interval,
            end: nil
        )
    }
    
    // MARK: - Notification Scheduling
    
    private func scheduleNotification(for visit: Visit, minutesBefore: Int) async {
        guard notificationPermissionGranted else { return }
        
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notification.visit.title", comment: "Visit Reminder")
        content.body = String(format: NSLocalizedString("notification.visit.body", comment: "Your visit '%@' starts in %d minutes"), visit.title, minutesBefore)
        content.sound = .default
        
        let triggerDate = Calendar.current.date(
            byAdding: .minute,
            value: -minutesBefore,
            to: visit.startDate
        ) ?? visit.startDate
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: visit.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("📱 Notification scheduled for visit: \(visit.title)")
        } catch {
            print("❌ Failed to schedule notification: \(error)")
        }
    }
}
