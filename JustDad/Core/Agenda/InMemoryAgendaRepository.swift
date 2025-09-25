//
//  InMemoryAgendaRepository.swift
//  JustDad - SwiftData Agenda Repository
//
//  Offline-first agenda repository with SwiftData persistence
//

import Foundation
import SwiftData

@MainActor
class InMemoryAgendaRepository: ObservableObject, @preconcurrency AgendaRepositoryProtocol {
    @Published private var visits: [AgendaVisit] = []
    @Published var permissionStatus: AgendaPermissionStatus = .notDetermined
    
    private let persistenceService = PersistenceService.shared
    
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
        // Create SwiftData Visit from AgendaVisit
        let swiftDataVisit = Visit(
            title: visit.title,
            startDate: visit.startDate,
            endDate: visit.endDate,
            type: visit.visitType.rawValue,
            location: visit.location,
            notes: visit.notes
        )
        
        // Save to SwiftData
        try await persistenceService.saveVisit(swiftDataVisit)
        
        // Update local cache
        visits.append(visit)
        return visit
    }
    
    func updateVisit(_ visit: AgendaVisit) async throws -> AgendaVisit {
        guard let index = visits.firstIndex(where: { $0.id == visit.id }) else {
            throw AgendaError.visitNotFound
        }
        
        // Update in SwiftData
        let swiftDataVisits = try persistenceService.fetchVisits()
        if let swiftDataVisit = swiftDataVisits.first(where: { $0.id == visit.id }) {
            swiftDataVisit.title = visit.title
            swiftDataVisit.startDate = visit.startDate
            swiftDataVisit.endDate = visit.endDate
            swiftDataVisit.location = visit.location
            swiftDataVisit.notes = visit.notes
            swiftDataVisit.type = visit.visitType.rawValue
            
            try await persistenceService.save(swiftDataVisit)
        }
        
        // Update local cache
        visits[index] = visit
        return visit
    }
    
    func deleteVisit(_ visitId: UUID) async throws {
        guard let index = visits.firstIndex(where: { $0.id == visitId }) else {
            throw AgendaError.visitNotFound
        }
        
        // Delete from SwiftData
        let swiftDataVisits = try persistenceService.fetchVisits()
        if let swiftDataVisit = swiftDataVisits.first(where: { $0.id == visitId }) {
            try await persistenceService.delete(swiftDataVisit)
        }
        
        // Update local cache
        visits.remove(at: index)
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
        do {
            let swiftDataVisits = try persistenceService.fetchVisits()
            visits = swiftDataVisits.map { swiftDataVisit in
                AgendaVisit(
                    id: swiftDataVisit.id,
                    title: swiftDataVisit.title,
                    startDate: swiftDataVisit.startDate,
                    endDate: swiftDataVisit.endDate,
                    location: swiftDataVisit.location,
                    notes: swiftDataVisit.notes,
                    reminderMinutes: 0, // Default value since Visit model doesn't have this
                    isRecurring: false, // Default value since Visit model doesn't have this
                    recurrenceRule: nil, // Default value since Visit model doesn't have this
                    visitType: AgendaVisitType(rawValue: swiftDataVisit.type) ?? .medical,
                    eventKitIdentifier: nil // Default value since Visit model doesn't have this
                )
            }
        } catch {
            print("Error loading visits from SwiftData: \(error)")
            visits = []
        }
    }
    
}
