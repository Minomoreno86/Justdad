//
//  InMemoryAgendaRepository.swift
//  JustDad - In-memory Agenda Repository
//
//  Offline-first agenda repository with mock data persistence
//

import Foundation

// Import core agenda types
// AgendaTypes should be imported via the module system

@MainActor
class InMemoryAgendaRepository: ObservableObject, AgendaRepositoryProtocol {
    @Published private var visits: [Visit] = []
    @Published var permissionStatus: AgendaPermissionStatus = .notDetermined
    
    private let userDefaults = UserDefaults.standard
    private let visitsKey = "stored_visits"
    
    init() {
        loadStoredVisits()
        generateMockVisits()
    }
    
    // MARK: - Repository Protocol Implementation
    
    func getAllVisits() async throws -> [Visit] {
        return visits.sorted { $0.startDate < $1.startDate }
    }
    
    func getVisits(for date: Date) async throws -> [Visit] {
        let calendar = Calendar.current
        return visits.filter { visit in
            calendar.isDate(visit.startDate, inSameDayAs: date)
        }.sorted { $0.startDate < $1.startDate }
    }
    
    func getVisits(from startDate: Date, to endDate: Date) async throws -> [Visit] {
        return visits.filter { visit in
            visit.startDate >= startDate && visit.startDate <= endDate
        }.sorted { $0.startDate < $1.startDate }
    }
    
    func createVisit(_ visit: Visit) async throws -> Visit {
        visits.append(visit)
        saveVisits()
        return visit
    }
    
    func updateVisit(_ visit: Visit) async throws -> Visit {
        if let index = visits.firstIndex(where: { $0.id == visit.id }) {
            visits[index] = visit
            saveVisits()
            return visit
        } else {
            throw AgendaError.visitNotFound
        }
    }
    
    func deleteVisit(id: UUID) async throws {
        visits.removeAll { $0.id == id }
        saveVisits()
    }
    
    func requestCalendarPermission() async -> Bool {
        // Simulate permission request
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
        permissionStatus = .authorized
        return true
    }
    
    func syncWithEventKit() async throws {
        // In-memory repository doesn't sync with EventKit
        // This is handled by EventKitAgendaRepository
        print("📅 InMemoryRepository: EventKit sync not available (offline mode)")
    }
    
    // MARK: - Persistence
    
    private func loadStoredVisits() {
        guard let data = userDefaults.data(forKey: visitsKey),
              let decodedVisits = try? JSONDecoder().decode([Visit].self, from: data) else {
            return
        }
        visits = decodedVisits
    }
    
    private func saveVisits() {
        if let encoded = try? JSONEncoder().encode(visits) {
            userDefaults.set(encoded, forKey: visitsKey)
        }
    }
    
    // MARK: - Mock Data Generation
    
    private func generateMockVisits() {
        guard visits.isEmpty else { return }
        
        let calendar = Calendar.current
        let today = Date()
        
        let mockVisits = [
            Visit(
                title: NSLocalizedString("mock.visit.weekend.title", comment: "Weekend with kids"),
                startDate: calendar.date(byAdding: .day, value: 2, to: today) ?? today,
                endDate: calendar.date(byAdding: .hour, value: 8, to: calendar.date(byAdding: .day, value: 2, to: today) ?? today) ?? today,
                location: NSLocalizedString("mock.visit.weekend.location", comment: "My apartment"),
                notes: NSLocalizedString("mock.visit.weekend.notes", comment: "Plan activities and prepare lunch"),
                reminderMinutes: 60,
                visitType: .weekend
            ),
            Visit(
                title: NSLocalizedString("mock.visit.dinner.title", comment: "Weekday dinner"),
                startDate: calendar.date(byAdding: .day, value: 5, to: today) ?? today,
                endDate: calendar.date(byAdding: .hour, value: 2, to: calendar.date(byAdding: .day, value: 5, to: today) ?? today) ?? today,
                location: NSLocalizedString("mock.visit.dinner.location", comment: "Downtown restaurant"),
                notes: NSLocalizedString("mock.visit.dinner.notes", comment: "Try the new kids menu"),
                reminderMinutes: 30,
                visitType: .dinner
            ),
            Visit(
                title: NSLocalizedString("mock.visit.event.title", comment: "School event"),
                startDate: calendar.date(byAdding: .day, value: 8, to: today) ?? today,
                endDate: calendar.date(byAdding: .hour, value: 3, to: calendar.date(byAdding: .day, value: 8, to: today) ?? today) ?? today,
                location: NSLocalizedString("mock.visit.event.location", comment: "School auditorium"),
                notes: NSLocalizedString("mock.visit.event.notes", comment: "Annual school presentation"),
                reminderMinutes: 120,
                visitType: .event
            ),
            Visit(
                title: NSLocalizedString("mock.visit.recurring.title", comment: "Weekly pickup"),
                startDate: calendar.date(byAdding: .day, value: 1, to: today) ?? today,
                endDate: calendar.date(byAdding: .hour, value: 1, to: calendar.date(byAdding: .day, value: 1, to: today) ?? today) ?? today,
                location: NSLocalizedString("mock.visit.recurring.location", comment: "School"),
                notes: NSLocalizedString("mock.visit.recurring.notes", comment: "Regular school pickup"),
                reminderMinutes: 15,
                isRecurring: true,
                recurrenceRule: .weekly,
                visitType: .general
            )
        ]
        
        visits = mockVisits
        saveVisits()
    }
}

// MARK: - Repository Errors
enum AgendaError: LocalizedError {
    case visitNotFound
    case permissionDenied
    case eventKitNotAvailable
    case syncFailed
    
    var errorDescription: String? {
        switch self {
        case .visitNotFound:
            return NSLocalizedString("agenda.error.visit_not_found", comment: "Visit not found")
        case .permissionDenied:
            return NSLocalizedString("agenda.error.permission_denied", comment: "Calendar permission denied")
        case .eventKitNotAvailable:
            return NSLocalizedString("agenda.error.eventkit_unavailable", comment: "EventKit not available")
        case .syncFailed:
            return NSLocalizedString("agenda.error.sync_failed", comment: "Calendar sync failed")
        }
    }
}
