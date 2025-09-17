//
//  CalendarManagementService.swift
//  JustDad - Calendar Management Service
//
//  Professional calendar management with multi-calendar support,
//  calendar selection, and robust error handling
//

import Foundation
import EventKit
import Combine
import SwiftUI

// MARK: - Calendar Management Protocol
protocol CalendarManagementServiceProtocol {
    func getAvailableCalendars() async throws -> [CalendarInfo]
    func getJustDadCalendar() async throws -> EKCalendar
    func createJustDadCalendar() async throws -> EKCalendar
    func selectCalendar(_ calendar: EKCalendar) async throws
    @MainActor func getSelectedCalendar() -> EKCalendar?
    @MainActor func isCalendarWritable(_ calendar: EKCalendar) -> Bool
    func getCalendarEvents(from startDate: Date, to endDate: Date, calendar: EKCalendar?) async throws -> [EKEvent]
}

// MARK: - Calendar Info
struct CalendarInfo: Identifiable, Hashable {
    let id: String
    let title: String
    let color: Color
    let isWritable: Bool
    let source: String
    let calendar: EKCalendar
    
    init(from calendar: EKCalendar) {
        self.id = calendar.calendarIdentifier
        self.title = calendar.title
        self.color = Color(calendar.cgColor ?? CGColor(red: 0, green: 0, blue: 1, alpha: 1))
        self.isWritable = calendar.allowsContentModifications
        self.source = calendar.source.title
        self.calendar = calendar
    }
}

// MARK: - Calendar Management Service
@MainActor
class CalendarManagementService: ObservableObject, CalendarManagementServiceProtocol {
    static let shared = CalendarManagementService()
    
    // MARK: - Published Properties
    @Published var availableCalendars: [CalendarInfo] = []
    @Published var selectedCalendar: EKCalendar?
    @Published var justDadCalendar: EKCalendar?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let eventStore = EKEventStore()
    private let justDadCalendarTitle = "JustDad Visitas"
    private let justDadCalendarColor = Color.blue
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    private init() {
        setupCalendarMonitoring()
    }
    
    // MARK: - Calendar Management
    func getAvailableCalendars() async throws -> [CalendarInfo] {
        isLoading = true
        defer { isLoading = false }
        
        let calendars = eventStore.calendars(for: .event)
        let calendarInfos = calendars.map { CalendarInfo(from: $0) }
        
        await MainActor.run {
            self.availableCalendars = calendarInfos
            self.errorMessage = nil
        }
        
        return calendarInfos
    }
    
    func getJustDadCalendar() async throws -> EKCalendar {
        if let existingCalendar = justDadCalendar {
            return existingCalendar
        }
        
        // Look for existing JustDad calendar
        let calendars = eventStore.calendars(for: .event)
        if let existingCalendar = calendars.first(where: { $0.title == justDadCalendarTitle }) {
            await MainActor.run {
                self.justDadCalendar = existingCalendar
            }
            return existingCalendar
        }
        
        // Create new JustDad calendar
        return try await createJustDadCalendar()
    }
    
    func createJustDadCalendar() async throws -> EKCalendar {
        isLoading = true
        defer { isLoading = false }
        
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = justDadCalendarTitle
        calendar.cgColor = CGColor(red: 0, green: 0, blue: 1, alpha: 1)
        
        // Find appropriate source
        let sources = eventStore.sources
        let preferredSource = sources.first { $0.sourceType == .local } ??
                             sources.first { $0.sourceType == .calDAV } ??
                             sources.first { $0.sourceType == .exchange } ??
                             sources.first
        
        guard let source = preferredSource else {
            throw CalendarManagementError.noSuitableSource
        }
        
        calendar.source = source
        
        try eventStore.saveCalendar(calendar, commit: true)
        
        await MainActor.run {
            self.justDadCalendar = calendar
            self.errorMessage = nil
        }
        
        // Refresh available calendars
        _ = try await getAvailableCalendars()
        
        return calendar
    }
    
    func selectCalendar(_ calendar: EKCalendar) async throws {
        guard isCalendarWritable(calendar) else {
            throw CalendarManagementError.calendarNotWritable
        }
        
        await MainActor.run {
            self.selectedCalendar = calendar
            self.errorMessage = nil
        }
    }
    
    func getSelectedCalendar() -> EKCalendar? {
        return selectedCalendar
    }
    
    func isCalendarWritable(_ calendar: EKCalendar) -> Bool {
        return calendar.allowsContentModifications
    }
    
    func getCalendarEvents(from startDate: Date, to endDate: Date, calendar: EKCalendar? = nil) async throws -> [EKEvent] {
        let calendars = calendar != nil ? [calendar!] : nil
        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: calendars
        )
        
        let events = eventStore.events(matching: predicate)
        return events
    }
    
    // MARK: - Calendar Operations
    func refreshCalendars() async {
        do {
            _ = try await getAvailableCalendars()
        } catch {
            print("❌ Failed to refresh calendars: \(error)")
        }
    }
    
    func deleteJustDadCalendar() async throws {
        guard let calendar = justDadCalendar else {
            throw CalendarManagementError.calendarNotFound
        }
        
        do {
            try eventStore.removeCalendar(calendar, commit: true)
            
            await MainActor.run {
                self.justDadCalendar = nil
                self.selectedCalendar = nil
            }
            
            // Refresh available calendars
            _ = try await getAvailableCalendars()
        } catch {
            throw CalendarManagementError.failedToDeleteCalendar(error)
        }
    }
    
    func updateJustDadCalendar(title: String? = nil, color: Color? = nil) async throws {
        guard let calendar = justDadCalendar else {
            throw CalendarManagementError.calendarNotFound
        }
        
        if let newTitle = title {
            calendar.title = newTitle
        }
        
        if color != nil {
            calendar.cgColor = CGColor(red: 0, green: 0, blue: 1, alpha: 1)
        }
        
        try eventStore.saveCalendar(calendar, commit: true)
        
        // Refresh available calendars
        _ = try await getAvailableCalendars()
    }
    
    // MARK: - Calendar Monitoring
    private func setupCalendarMonitoring() {
        // Monitor calendar changes
        NotificationCenter.default.publisher(for: .EKEventStoreChanged)
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.refreshCalendars()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Helper Methods
    func getCalendarById(_ identifier: String) -> EKCalendar? {
        return availableCalendars.first { $0.id == identifier }?.calendar
    }
    
    func getWritableCalendars() -> [CalendarInfo] {
        return availableCalendars.filter { $0.isWritable }
    }
    
    func getCalendarUsageStats() -> CalendarUsageStats {
        let totalCalendars = availableCalendars.count
        let writableCalendars = availableCalendars.filter { $0.isWritable }.count
        let justDadExists = justDadCalendar != nil
        
        return CalendarUsageStats(
            totalCalendars: totalCalendars,
            writableCalendars: writableCalendars,
            justDadCalendarExists: justDadExists,
            selectedCalendarTitle: selectedCalendar?.title
        )
    }
}

// MARK: - Calendar Usage Stats
struct CalendarUsageStats {
    let totalCalendars: Int
    let writableCalendars: Int
    let justDadCalendarExists: Bool
    let selectedCalendarTitle: String?
    
    var description: String {
        var stats = ["Total de calendarios: \(totalCalendars)"]
        stats.append("Calendarios editables: \(writableCalendars)")
        stats.append("Calendario JustDad: \(justDadCalendarExists ? "Creado" : "No creado")")
        if let selected = selectedCalendarTitle {
            stats.append("Calendario seleccionado: \(selected)")
        }
        return stats.joined(separator: "\n")
    }
}

// MARK: - Calendar Management Errors
enum CalendarManagementError: LocalizedError {
    case failedToFetchCalendars(Error)
    case failedToCreateCalendar(Error)
    case failedToUpdateCalendar(Error)
    case failedToDeleteCalendar(Error)
    case failedToFetchEvents(Error)
    case calendarNotFound
    case calendarNotWritable
    case noSuitableSource
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .failedToFetchCalendars(let error):
            return "Error al obtener calendarios: \(error.localizedDescription)"
        case .failedToCreateCalendar(let error):
            return "Error al crear calendario: \(error.localizedDescription)"
        case .failedToUpdateCalendar(let error):
            return "Error al actualizar calendario: \(error.localizedDescription)"
        case .failedToDeleteCalendar(let error):
            return "Error al eliminar calendario: \(error.localizedDescription)"
        case .failedToFetchEvents(let error):
            return "Error al obtener eventos: \(error.localizedDescription)"
        case .calendarNotFound:
            return "Calendario no encontrado"
        case .calendarNotWritable:
            return "El calendario seleccionado no es editable"
        case .noSuitableSource:
            return "No se encontró una fuente de calendario adecuada"
        case .permissionDenied:
            return "Permisos de calendario denegados"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .failedToFetchCalendars, .failedToCreateCalendar, .failedToUpdateCalendar, .failedToDeleteCalendar, .failedToFetchEvents:
            return "Verifica que tengas permisos de calendario y que el dispositivo esté funcionando correctamente"
        case .calendarNotFound:
            return "Asegúrate de que el calendario existe y está disponible"
        case .calendarNotWritable:
            return "Selecciona un calendario diferente que permita modificaciones"
        case .noSuitableSource:
            return "Configura una cuenta de calendario en Configuración > Calendarios"
        case .permissionDenied:
            return "Ve a Configuración > JustDad y autoriza el acceso al calendario"
        }
    }
}
