//
//  CalendarSyncService.swift
//  JustDad
//
//  Professional calendar synchronization service for system integration
//

import Foundation
import EventKit
import Combine
import SwiftUI

// MARK: - Calendar Sync Protocol
protocol CalendarSyncServiceProtocol {
    func requestAuthorization() async -> Bool
    func syncVisitToCalendar(visitId: UUID, title: String, startDate: Date, endDate: Date, location: String?, notes: String?) async throws -> String?
    func updateCalendarEvent(eventId: String, visitId: UUID, title: String, startDate: Date, endDate: Date, location: String?, notes: String?) async throws
    func removeFromCalendar(eventId: String) async throws
    func getCalendarEvents(from startDate: Date, to endDate: Date) async throws -> [CalendarEventData]
}

// MARK: - Calendar Event Data Structure
struct CalendarEventData {
    let eventId: String
    let title: String
    let startDate: Date
    let endDate: Date
    let location: String?
    let notes: String?
    let isAllDay: Bool
}

@MainActor
class CalendarSyncService: ObservableObject, CalendarSyncServiceProtocol {
    
    static let shared = CalendarSyncService()
    
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published var isEnabled: Bool = false
    @Published var syncInProgress: Bool = false
    @Published var lastSyncDate: Date?
    
    private let eventStore = EKEventStore()
    private let justDadCalendarTitle = "JustDad Visitas"
    private var justDadCalendar: EKCalendar?
    
    private init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        let granted: Bool
        
        if #available(iOS 17.0, *) {
            granted = try! await eventStore.requestFullAccessToEvents()
        } else {
            granted = await withCheckedContinuation { continuation in
                eventStore.requestAccess(to: .event) { success, error in
                    continuation.resume(returning: success && error == nil)
                }
            }
        }
        
        await MainActor.run {
            self.authorizationStatus = EKEventStore.authorizationStatus(for: .event)
            if #available(iOS 17.0, *) {
                self.isEnabled = self.authorizationStatus == .fullAccess
            } else {
                self.isEnabled = self.authorizationStatus == .authorized
            }
        }
        
        if granted {
            await setupJustDadCalendar()
        }
        
        return granted
    }
    
    private func checkAuthorizationStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        if #available(iOS 17.0, *) {
            isEnabled = authorizationStatus == .fullAccess
        } else {
            isEnabled = authorizationStatus == .authorized
        }
        
        if isEnabled {
            Task {
                await setupJustDadCalendar()
            }
        }
    }
    
    // MARK: - Calendar Setup
    
    private func setupJustDadCalendar() async {
        guard isEnabled else { return }
        
        // Look for existing JustDad calendar
        let calendars = eventStore.calendars(for: .event)
        if let existingCalendar = calendars.first(where: { $0.title == justDadCalendarTitle }) {
            justDadCalendar = existingCalendar
            print("📅 Found existing JustDad calendar: \(existingCalendar.calendarIdentifier)")
            return
        }
        
        // Create new JustDad calendar
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = justDadCalendarTitle
        if let blueColor = Color.blue.cgColor {
            calendar.cgColor = blueColor
        }
        
        // Find a source that supports event creation
        let sources = eventStore.sources
        if let source = sources.first(where: { $0.sourceType == .local }) ?? 
                        sources.first(where: { $0.sourceType == .calDAV }) ??
                        sources.first {
            calendar.source = source
            
            do {
                try eventStore.saveCalendar(calendar, commit: true)
                justDadCalendar = calendar
                print("📅 Created new JustDad calendar: \(calendar.calendarIdentifier)")
            } catch {
                print("❌ Failed to create JustDad calendar: \(error)")
                // Fallback to default calendar
                justDadCalendar = eventStore.defaultCalendarForNewEvents
            }
        } else {
            print("❌ No suitable source found for calendar creation")
            justDadCalendar = eventStore.defaultCalendarForNewEvents
        }
    }
    
    // MARK: - Calendar Sync Operations
    
    func syncVisitToCalendar(
        visitId: UUID,
        title: String,
        startDate: Date,
        endDate: Date,
        location: String?,
        notes: String?
    ) async throws -> String? {
        guard isEnabled else {
            throw CalendarSyncError.unauthorized
        }
        
        await ensureCalendarSetup()
        
        guard let calendar = justDadCalendar else {
            throw CalendarSyncError.calendarNotFound
        }
        
        syncInProgress = true
        defer { syncInProgress = false }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.location = location
        event.notes = notes
        event.calendar = calendar
        
        // Add custom properties to identify JustDad events
        event.url = URL(string: "justdad://visit/\(visitId.uuidString)")
        
        do {
            try eventStore.save(event, span: .thisEvent)
            lastSyncDate = Date()
            print("📅 Synced visit to calendar: \(event.eventIdentifier ?? "unknown")")
            return event.eventIdentifier
        } catch {
            print("❌ Failed to sync visit to calendar: \(error)")
            throw CalendarSyncError.syncFailed(error)
        }
    }
    
    func updateCalendarEvent(
        eventId: String,
        visitId: UUID,
        title: String,
        startDate: Date,
        endDate: Date,
        location: String?,
        notes: String?
    ) async throws {
        guard isEnabled else {
            throw CalendarSyncError.unauthorized
        }
        
        guard let event = eventStore.event(withIdentifier: eventId) else {
            throw CalendarSyncError.eventNotFound
        }
        
        syncInProgress = true
        defer { syncInProgress = false }
        
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.location = location
        event.notes = notes
        event.url = URL(string: "justdad://visit/\(visitId.uuidString)")
        
        do {
            try eventStore.save(event, span: .thisEvent)
            lastSyncDate = Date()
            print("📅 Updated calendar event: \(eventId)")
        } catch {
            print("❌ Failed to update calendar event: \(error)")
            throw CalendarSyncError.syncFailed(error)
        }
    }
    
    func removeFromCalendar(eventId: String) async throws {
        guard isEnabled else {
            throw CalendarSyncError.unauthorized
        }
        
        guard let event = eventStore.event(withIdentifier: eventId) else {
            throw CalendarSyncError.eventNotFound
        }
        
        syncInProgress = true
        defer { syncInProgress = false }
        
        do {
            try eventStore.remove(event, span: .thisEvent)
            lastSyncDate = Date()
            print("📅 Removed event from calendar: \(eventId)")
        } catch {
            print("❌ Failed to remove calendar event: \(error)")
            throw CalendarSyncError.syncFailed(error)
        }
    }
    
    func getCalendarEvents(from startDate: Date, to endDate: Date) async throws -> [CalendarEventData] {
        guard isEnabled else {
            throw CalendarSyncError.unauthorized
        }
        
        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: justDadCalendar != nil ? [justDadCalendar!] : nil
        )
        
        let events = eventStore.events(matching: predicate)
        
        return events.map { event in
            CalendarEventData(
                eventId: event.eventIdentifier,
                title: event.title,
                startDate: event.startDate,
                endDate: event.endDate,
                location: event.location,
                notes: event.notes,
                isAllDay: event.isAllDay
            )
        }
    }
    
    // MARK: - Utility Methods
    
    private func ensureCalendarSetup() async {
        guard justDadCalendar == nil else { return }
        await setupJustDadCalendar()
    }
    
    func syncAllPendingVisits() async {
        // This method can be called to sync any pending visits
        // Implementation would depend on how the app stores pending sync items
        guard isEnabled else { return }
        
        print("📅 Starting sync of all pending visits...")
        lastSyncDate = Date()
    }
    
    func getJustDadCalendar() -> EKCalendar? {
        return justDadCalendar
    }
}

// MARK: - Calendar Sync Errors
enum CalendarSyncError: LocalizedError {
    case unauthorized
    case calendarNotFound
    case eventNotFound
    case syncFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Calendar access not authorized"
        case .calendarNotFound:
            return "JustDad calendar not found"
        case .eventNotFound:
            return "Calendar event not found"
        case .syncFailed(let error):
            return "Calendar sync failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - Calendar Integration Extensions
extension CalendarSyncService {
    
    /// Convenience method for scheduling visit with automatic calendar sync
    func scheduleVisitWithSync(
        visitId: UUID,
        title: String,
        startDate: Date,
        endDate: Date,
        location: String?,
        notes: String?,
        reminderMinutes: Int?
    ) async throws -> String? {
        // Sync to calendar
        let eventId = try await syncVisitToCalendar(
            visitId: visitId,
            title: title,
            startDate: startDate,
            endDate: endDate,
            location: location,
            notes: notes
        )
        
        // Schedule notification if reminder is set
        if let reminderMinutes = reminderMinutes {
            // TODO: Integrate with NotificationService when available
            print("📱 Would schedule notification for visit \(visitId) with \(reminderMinutes) minutes reminder")
            /*
            let notificationService = NotificationService.shared
            await notificationService.scheduleVisitReminder(
                visitId: visitId,
                title: title,
                startDate: startDate,
                location: location,
                reminderMinutes: reminderMinutes
            )
            */
        }
        
        return eventId
    }
    
    /// Convenience method for updating visit with automatic calendar sync
    func updateVisitWithSync(
        eventId: String,
        visitId: UUID,
        title: String,
        startDate: Date,
        endDate: Date,
        location: String?,
        notes: String?,
        reminderMinutes: Int?
    ) async throws {
        // Update calendar
        try await updateCalendarEvent(
            eventId: eventId,
            visitId: visitId,
            title: title,
            startDate: startDate,
            endDate: endDate,
            location: location,
            notes: notes
        )
        
        // Update notification
        // TODO: Integrate with NotificationService when available
        print("📱 Would cancel and reschedule notification for visit \(visitId)")
        /*
        let notificationService = NotificationService.shared
        await notificationService.cancelVisitReminder(for: visitId)
        
        if let reminderMinutes = reminderMinutes {
            await notificationService.scheduleVisitReminder(
                visitId: visitId,
                title: title,
                startDate: startDate,
                location: location,
                reminderMinutes: reminderMinutes
            )
        }
        */
    }
    
    /// Convenience method for deleting visit with automatic cleanup
    func deleteVisitWithSync(eventId: String, visitId: UUID) async throws {
        // Remove from calendar
        try await removeFromCalendar(eventId: eventId)
        
        // Cancel notifications
        // TODO: Integrate with NotificationService when available
        print("📱 Would cancel notifications for visit \(visitId)")
        /*
        let notificationService = NotificationService.shared
        await notificationService.cancelVisitReminder(for: visitId)
        */
    }
}
