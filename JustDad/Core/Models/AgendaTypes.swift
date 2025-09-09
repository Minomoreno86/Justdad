//
//  AgendaTypes.swift
//  JustDad - Core Agenda Domain Models
//
//  Canonical agenda types for visit management and calendar integration
//

import Foundation
import EventKit

// MARK: - Visit Domain Model
struct Visit: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var location: String?
    var notes: String?
    var reminderMinutes: Int?
    var isRecurring: Bool
    var recurrenceRule: RecurrenceRule?
    var visitType: VisitType
    var eventKitIdentifier: String? // For EventKit integration
    
    init(
        id: UUID = UUID(),
        title: String,
        startDate: Date,
        endDate: Date,
        location: String? = nil,
        notes: String? = nil,
        reminderMinutes: Int? = nil,
        isRecurring: Bool = false,
        recurrenceRule: RecurrenceRule? = nil,
        visitType: VisitType = .general,
        eventKitIdentifier: String? = nil
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.notes = notes
        self.reminderMinutes = reminderMinutes
        self.isRecurring = isRecurring
        self.recurrenceRule = recurrenceRule
        self.visitType = visitType
        self.eventKitIdentifier = eventKitIdentifier
    }
}

// MARK: - Visit Type Classification
enum VisitType: String, CaseIterable, Codable {
    case weekend = "weekend"
    case dinner = "dinner"
    case event = "event"
    case general = "general"
    case emergency = "emergency"
    
    var displayName: String {
        switch self {
        case .weekend: return NSLocalizedString("visit.type.weekend", comment: "Weekend visit")
        case .dinner: return NSLocalizedString("visit.type.dinner", comment: "Dinner visit")
        case .event: return NSLocalizedString("visit.type.event", comment: "Special event")
        case .general: return NSLocalizedString("visit.type.general", comment: "General visit")
        case .emergency: return NSLocalizedString("visit.type.emergency", comment: "Emergency visit")
        }
    }
    
    var color: String {
        switch self {
        case .weekend: return "blue"
        case .dinner: return "green"
        case .event: return "orange"
        case .general: return "purple"
        case .emergency: return "red"
        }
    }
    
    var systemIcon: String {
        switch self {
        case .weekend: return "house.fill"
        case .dinner: return "fork.knife"
        case .event: return "star.fill"
        case .general: return "calendar"
        case .emergency: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - Recurrence Pattern
enum RecurrenceRule: String, CaseIterable, Codable {
    case daily = "daily"
    case weekly = "weekly"
    case biweekly = "biweekly"
    case monthly = "monthly"
    
    var displayName: String {
        switch self {
        case .daily: return NSLocalizedString("recurrence.daily", comment: "Daily")
        case .weekly: return NSLocalizedString("recurrence.weekly", comment: "Weekly")
        case .biweekly: return NSLocalizedString("recurrence.biweekly", comment: "Bi-weekly")
        case .monthly: return NSLocalizedString("recurrence.monthly", comment: "Monthly")
        }
    }
    
    func nextOccurrence(from date: Date) -> Date? {
        let calendar = Calendar.current
        switch self {
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: date)
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date)
        case .biweekly:
            return calendar.date(byAdding: .weekOfYear, value: 2, to: date)
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date)
        }
    }
}

// MARK: - Calendar View Mode
enum CalendarViewMode: CaseIterable {
    case month
    case week
    case list
    
    var displayName: String {
        switch self {
        case .month: return NSLocalizedString("calendar.view.month", comment: "Month view")
        case .week: return NSLocalizedString("calendar.view.week", comment: "Week view")
        case .list: return NSLocalizedString("calendar.view.list", comment: "List view")
        }
    }
    
    var systemIcon: String {
        switch self {
        case .month: return "calendar"
        case .week: return "calendar.day.timeline.left"
        case .list: return "list.bullet"
        }
    }
}

// MARK: - Agenda Repository Protocol
protocol AgendaRepositoryProtocol {
    func getAllVisits() async throws -> [Visit]
    func getVisits(for date: Date) async throws -> [Visit]
    func getVisits(from startDate: Date, to endDate: Date) async throws -> [Visit]
    func createVisit(_ visit: Visit) async throws -> Visit
    func updateVisit(_ visit: Visit) async throws -> Visit
    func deleteVisit(id: UUID) async throws
    func requestCalendarPermission() async -> Bool
    func syncWithEventKit() async throws
}

// MARK: - Agenda Permission Status
enum AgendaPermissionStatus {
    case notDetermined
    case denied
    case authorized
    case restricted
    
    static func from(ekStatus: EKAuthorizationStatus) -> AgendaPermissionStatus {
        switch ekStatus {
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .fullAccess, .writeOnly: return .authorized
        case .restricted: return .restricted
        @unknown default: return .notDetermined
        }
    }
    
    var isAuthorized: Bool {
        return self == .authorized
    }
}
