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
class InMemoryAgendaRepository: ObservableObject, @preconcurrency AgendaRepositoryProtocol {
    @Published private var visits: [AgendaVisit] = []
    @Published var permissionStatus: AgendaPermissionStatus = .notDetermined
    
    private let userDefaults = UserDefaults.standard
    private let visitsKey = "stored_visits"
    
    init() {
        loadStoredVisits()
    }
    
    // MARK: - Repository Protocol Implementation
    
    func getVisits(in dateRange: DateInterval) async throws -> [AgendaVisit] {
        let allVisits = visits.sorted { $0.startDate < $1.startDate }
        
        return allVisits.filter { visit in
            dateRange.contains(visit.startDate) || dateRange.contains(visit.endDate) ||
            (visit.startDate <= dateRange.start && visit.endDate >= dateRange.end)
        }
    }
    
    func createVisit(_ visit: AgendaVisit) async throws -> AgendaVisit {
        // Since id is a let constant, we need to create a new visit with a new UUID
        let newVisit = AgendaVisit(
            id: UUID(),
            title: visit.title,
            startDate: visit.startDate,
            endDate: visit.endDate,
            location: visit.location,
            notes: visit.notes,
            reminderMinutes: visit.reminderMinutes,
            isRecurring: visit.isRecurring,
            recurrenceRule: visit.recurrenceRule,
            visitType: visit.visitType,
            eventKitIdentifier: visit.eventKitIdentifier
        )
        visits.append(newVisit)
        saveVisits()
        return newVisit
    }
    
    func updateVisit(_ visit: AgendaVisit) async throws -> AgendaVisit {
        guard let index = visits.firstIndex(where: { $0.id == visit.id }) else {
            throw AgendaError.visitNotFound
        }
        visits[index] = visit
        saveVisits()
        return visit
    }
    
    func deleteVisit(_ visitId: UUID) async throws {
        guard let index = visits.firstIndex(where: { $0.id == visitId }) else {
            throw AgendaError.visitNotFound
        }
        visits.remove(at: index)
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
    
}
