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
    @Published private var visits: [AgendaVisit] = []
    @Published var permissionStatus: AgendaPermissionStatus = .notDetermined
    
    private let userDefaults = UserDefaults.standard
    private let visitsKey = "stored_visits"
    
    init() {
        loadStoredVisits()
        generateMockVisits()
    }
    
    // MARK: - Repository Protocol Implementation
    
    func getVisits(for dateRange: DateInterval?) async throws -> [AgendaVisit] {
        let allVisits = visits.sorted { $0.startDate < $1.startDate }
        
        guard let range = dateRange else {
            return allVisits
        }
        
        return allVisits.filter { visit in
            visit.startDate >= range.start && visit.startDate <= range.end
        }
    }
    
    // Convenience method for getting all visits
    func getAllVisits() async throws -> [AgendaVisit] {
        return try await getVisits(for: nil)
    }
    
    func getVisits(for date: Date) async throws -> [AgendaVisit] {
        let calendar = Calendar.current
        return visits.filter { visit in
            calendar.isDate(visit.startDate, inSameDayAs: date)
        }.sorted { $0.startDate < $1.startDate }
    }
    
    func getVisits(from startDate: Date, to endDate: Date) async throws -> [AgendaVisit] {
        return visits.filter { visit in
            visit.startDate >= startDate && visit.startDate <= endDate
        }.sorted { $0.startDate < $1.startDate }
    }
    
    func createVisit(_ visit: AgendaVisit) async throws -> AgendaVisit {
        visits.append(visit)
        saveVisits()
        return visit
    }
    
    func updateVisit(_ visit: AgendaVisit) async throws -> AgendaVisit {
        if let index = visits.firstIndex(where: { $0.id == visit.id }) {
            visits[index] = visit
            saveVisits()
            return visit
        } else {
            throw AgendaError.visitNotFound
        }
    }
    
    func deleteVisit(withId id: UUID) async throws {
        visits.removeAll { $0.id == id }
        saveVisits()
    }
    
    func requestCalendarPermission() async throws {
        // Simulate permission request
        do {
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
            permissionStatus = .authorized
        } catch {
            permissionStatus = .denied
            throw AgendaError.permissionDenied
        }
    }
    
    func syncWithEventKit() async throws {
        // In-memory repository doesn't sync with EventKit
        // This is handled by EventKitAgendaRepository
        print("📅 InMemoryRepository: EventKit sync not available (offline mode)")
    }
    
    // MARK: - Persistence
    
    private func loadStoredVisits() {
        guard let data = userDefaults.data(forKey: visitsKey),
              let decodedVisits = try? JSONDecoder().decode([AgendaVisit].self, from: data) else {
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
            AgendaVisit(
                title: NSLocalizedString("mock.visit.weekend.title", comment: "Weekend with kids"),
                startDate: calendar.date(byAdding: .day, value: 2, to: today) ?? today,
                endDate: calendar.date(byAdding: .hour, value: 8, to: calendar.date(byAdding: .day, value: 2, to: today) ?? today) ?? today,
                location: NSLocalizedString("mock.visit.weekend.location", comment: "My apartment"),
                notes: NSLocalizedString("mock.visit.weekend.notes", comment: "Plan activities and prepare lunch"),
                reminderMinutes: 60,
                visitType: .weekend
            ),
            AgendaVisit(
                title: NSLocalizedString("mock.visit.dinner.title", comment: "Weekday dinner"),
                startDate: calendar.date(byAdding: .day, value: 5, to: today) ?? today,
                endDate: calendar.date(byAdding: .hour, value: 2, to: calendar.date(byAdding: .day, value: 5, to: today) ?? today) ?? today,
                location: NSLocalizedString("mock.visit.dinner.location", comment: "Downtown restaurant"),
                notes: NSLocalizedString("mock.visit.dinner.notes", comment: "Try the new kids menu"),
                reminderMinutes: 30,
                visitType: .school
            ),
            AgendaVisit(
                title: NSLocalizedString("mock.visit.event.title", comment: "School event"),
                startDate: calendar.date(byAdding: .day, value: 8, to: today) ?? today,
                endDate: calendar.date(byAdding: .hour, value: 3, to: calendar.date(byAdding: .day, value: 8, to: today) ?? today) ?? today,
                location: NSLocalizedString("mock.visit.event.location", comment: "School auditorium"),
                notes: NSLocalizedString("mock.visit.event.notes", comment: "Annual school presentation"),
                reminderMinutes: 120,
                visitType: .general
            ),
            AgendaVisit(
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
