//
//  AgendaTypes.swift
//  JustDad - Core Agenda Domain Models
//
//  Canonical agenda types for visit management and calendar integration
//

import Foundation
import EventKit

// MARK: - Visit Type Enum
public enum AgendaVisitType: String, CaseIterable, Codable {
    case weekend
    case dinner  
    case activity
    case school
    case medical
    case emergency
    case general
    
    public var displayName: String {
        switch self {
        case .weekend: return NSLocalizedString("visit.type.weekend", comment: "Weekend visit")
        case .dinner: return NSLocalizedString("visit.type.dinner", comment: "Dinner visit")
        case .activity: return "Actividad"
        case .school: return "Escuela"
        case .medical: return "Médico"
        case .emergency: return NSLocalizedString("visit.type.emergency", comment: "Emergency visit")
        case .general: return NSLocalizedString("visit.type.general", comment: "General visit")
        }
    }
    
    public var color: String {
        switch self {
        case .weekend: return "blue"
        case .dinner: return "green"
        case .activity: return "purple"
        case .school: return "yellow"
        case .medical: return "orange"
        case .emergency: return "red"
        case .general: return "gray"
        }
    }
    
    public var systemIcon: String {
        switch self {
        case .weekend: return "house.fill"
        case .dinner: return "fork.knife"
        case .activity: return "gamecontroller.fill"
        case .school: return "book.fill"
        case .medical: return "stethoscope"
        case .emergency: return "exclamationmark.triangle.fill"
        case .general: return "calendar"
        }
    }
}

// MARK: - Recurrence Rule
public struct RecurrenceRule: Codable, Equatable {
    public enum Frequency: String, Codable, CaseIterable {
        case none
        case daily
        case weekly
        case monthly
        
        public var displayName: String {
            switch self {
            case .none: return "Sin repetir"
            case .daily: return NSLocalizedString("recurrence.daily", comment: "Daily")
            case .weekly: return NSLocalizedString("recurrence.weekly", comment: "Weekly")
            case .monthly: return NSLocalizedString("recurrence.monthly", comment: "Monthly")
            }
        }
    }
    
    public var frequency: Frequency
    public var interval: Int
    public var byWeekdays: [Int]? // 1..7 (Mon..Sun), opcional
    
    public init(frequency: Frequency = .none, interval: Int = 1, byWeekdays: [Int]? = nil) {
        self.frequency = frequency
        self.interval = interval
        self.byWeekdays = byWeekdays
    }
    
    // Factory methods para acceso simple
    public static let weekly = RecurrenceRule(frequency: .weekly)
    public static let daily = RecurrenceRule(frequency: .daily)
    public static let monthly = RecurrenceRule(frequency: .monthly)
    
    public var displayName: String {
        return frequency.displayName
    }
}

// MARK: - Visit Domain Model
public struct AgendaVisit: Identifiable, Codable, Equatable {
    public let id: UUID
    public var title: String
    public var startDate: Date
    public var endDate: Date
    public var location: String?
    public var notes: String?
    public var reminderMinutes: Int?
    public var isRecurring: Bool
    public var recurrenceRule: RecurrenceRule?
    public var visitType: AgendaVisitType
    public var eventKitIdentifier: String? // For EventKit integration
    
    public init(
        id: UUID = UUID(),
        title: String,
        startDate: Date,
        endDate: Date,
        location: String? = nil,
        notes: String? = nil,
        reminderMinutes: Int? = nil,
        isRecurring: Bool = false,
        recurrenceRule: RecurrenceRule? = nil,
        visitType: AgendaVisitType = .activity,
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

// MARK: - Calendar View Mode
public enum CalendarViewMode: String, CaseIterable, Codable {
    case month
    case week  
    case list
    
    public var displayName: String {
        switch self {
        case .month: return NSLocalizedString("calendar.view.month", comment: "Month")
        case .week: return NSLocalizedString("calendar.view.week", comment: "Week")
        case .list: return NSLocalizedString("calendar.view.list", comment: "List")
        }
    }
    
    public var systemIcon: String {
        switch self {
        case .month: return "calendar"
        case .week: return "calendar.day.timeline.left"
        case .list: return "list.bullet"
        }
    }
}

// MARK: - Permission Status
public enum AgendaPermissionStatus: String, Codable {
    case notDetermined
    case denied
    case authorized
    
    public var isAuthorized: Bool {
        return self == .authorized
    }
    
    public static func from(ekStatus: EKAuthorizationStatus) -> AgendaPermissionStatus {
        switch ekStatus {
        case .notDetermined:
            return .notDetermined
        case .denied, .restricted:
            return .denied
        case .authorized, .fullAccess:
            return .authorized
        case .writeOnly:
            return .authorized
        @unknown default:
            return .denied
        }
    }
}

// MARK: - Agenda Errors
public enum AgendaError: Error {
    case permissionDenied
    case eventKitUnavailable
    case syncFailed
    case visitNotFound
    case conversionFailed
    
    public var localizedDescription: String {
        switch self {
        case .permissionDenied:
            return NSLocalizedString("agenda.error.permission_denied", comment: "Permission denied")
        case .eventKitUnavailable:
            return NSLocalizedString("agenda.error.eventkit_unavailable", comment: "EventKit unavailable")
        case .syncFailed:
            return NSLocalizedString("agenda.error.sync_failed", comment: "Sync failed")
        case .visitNotFound:
            return NSLocalizedString("agenda.error.visit_not_found", comment: "Visit not found")
        case .conversionFailed:
            return "Failed to convert visit data"
        }
    }
}

// MARK: - Repository Protocol
public protocol AgendaRepositoryProtocol {
    func getVisits(for dateRange: DateInterval?) async throws -> [AgendaVisit]
    func createVisit(_ visit: AgendaVisit) async throws -> AgendaVisit
    func updateVisit(_ visit: AgendaVisit) async throws -> AgendaVisit
    func deleteVisit(withId id: UUID) async throws
    func requestCalendarPermission() async throws
    var permissionStatus: AgendaPermissionStatus { get }
}
