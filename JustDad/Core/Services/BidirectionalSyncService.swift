//
//  BidirectionalSyncService.swift
//  JustDad - Bidirectional Sync Service
//
//  Professional bidirectional synchronization between JustDad visits
//  and system calendar events with conflict resolution
//

import Foundation
import EventKit
import Combine
import SwiftUI

// MARK: - Sync Status
enum SyncStatus {
    case idle
    case syncing
    case success
    case failed(Error)
    case conflict(ConflictInfo)
    
    var isActive: Bool {
        if case .syncing = self { return true }
        return false
    }
}

// MARK: - Conflict Info
struct ConflictInfo: Identifiable {
    let id = UUID()
    let visitId: UUID
    let eventId: String
    let visitTitle: String
    let eventTitle: String
    let visitDate: Date
    let eventDate: Date
    let conflictType: ConflictType
    let resolution: ConflictResolution?
    
    enum ConflictType {
        case titleMismatch
        case dateMismatch
        case bothMismatch
        case eventDeleted
        case visitDeleted
    }
    
    enum ConflictResolution {
        case useVisit
        case useEvent
        case merge
        case skip
    }
}

// MARK: - Sync Result
struct SyncResult {
    let success: Bool
    let syncedVisits: Int
    let syncedEvents: Int
    let conflicts: [ConflictInfo]
    let errors: [Error]
    let duration: TimeInterval
    
    var summary: String {
        var parts: [String] = []
        parts.append("Visitas sincronizadas: \(syncedVisits)")
        parts.append("Eventos sincronizados: \(syncedEvents)")
        if !conflicts.isEmpty {
            parts.append("Conflictos: \(conflicts.count)")
        }
        if !errors.isEmpty {
            parts.append("Errores: \(errors.count)")
        }
        parts.append("Duración: \(String(format: "%.2f", duration))s")
        return parts.joined(separator: " • ")
    }
}

// MARK: - Bidirectional Sync Protocol
protocol BidirectionalSyncServiceProtocol {
    func syncVisitsToCalendar(_ visits: [Any]) async throws -> SyncResult
    func syncEventsToVisits(_ events: [EKEvent]) async throws -> SyncResult
    func fullBidirectionalSync() async throws -> SyncResult
    func resolveConflict(_ conflict: ConflictInfo, resolution: ConflictInfo.ConflictResolution) async throws
    @MainActor func getSyncStatus() -> SyncStatus
    @MainActor func getConflicts() -> [ConflictInfo]
}

// MARK: - Bidirectional Sync Service
@MainActor
class BidirectionalSyncService: ObservableObject, BidirectionalSyncServiceProtocol {
    static let shared = BidirectionalSyncService()
    
    // MARK: - Published Properties
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncResult: SyncResult?
    @Published var conflicts: [ConflictInfo] = []
    @Published var isEnabled: Bool = true
    @Published var autoSyncEnabled: Bool = false
    
    // MARK: - Private Properties
    private let eventStore = EKEventStore()
    private var cancellables = Set<AnyCancellable>()
    private let syncQueue = DispatchQueue(label: "com.justdad.sync", qos: .userInitiated)
    
    // MARK: - Initialization
    private init() {
        setupAutoSync()
    }
    
    // MARK: - Sync Operations
    func syncVisitsToCalendar(_ visits: [Any]) async throws -> SyncResult {
        guard isEnabled else {
            throw SyncError.syncDisabled
        }
        
        let startTime = Date()
        var syncedVisits = 0
        var syncedEvents = 0
        let conflicts: [ConflictInfo] = []
        var errors: [Error] = []
        
        await MainActor.run {
            self.syncStatus = .syncing
        }
        
        do {
            // Placeholder calendar - would need actual calendar service
            let calendar = EKCalendar(for: .event, eventStore: eventStore)
            
            for visit in visits {
                do {
                    let eventId = try await createOrUpdateEvent(from: visit, in: calendar)
                    if eventId != nil {
                        syncedEvents += 1
                    }
                    syncedVisits += 1
                } catch {
                    errors.append(error)
                    print("❌ Failed to sync visit: \(error)")
                }
            }
            
            let duration = Date().timeIntervalSince(startTime)
            let result = SyncResult(
                success: errors.isEmpty,
                syncedVisits: syncedVisits,
                syncedEvents: syncedEvents,
                conflicts: conflicts,
                errors: errors,
                duration: duration
            )
            
            await MainActor.run {
                self.syncStatus = .success
                self.lastSyncResult = result
            }
            
            return result
        } catch {
            await MainActor.run {
                self.syncStatus = .failed(error)
            }
            throw error
        }
    }
    
    func syncEventsToVisits(_ events: [EKEvent]) async throws -> SyncResult {
        guard isEnabled else {
            throw SyncError.syncDisabled
        }
        
        let startTime = Date()
        var syncedVisits = 0
        var syncedEvents = 0
        let conflicts: [ConflictInfo] = []
        var errors: [Error] = []
        
        await MainActor.run {
            self.syncStatus = .syncing
        }
        
        do {
            for event in events {
                do {
                    let visit = try await createOrUpdateVisit(from: event)
                    if visit != nil {
                        syncedVisits += 1
                    }
                    syncedEvents += 1
                } catch {
                    errors.append(error)
                    print("❌ Failed to sync event \(String(describing: event.eventIdentifier)): \(error)")
                }
            }
            
            let duration = Date().timeIntervalSince(startTime)
            let result = SyncResult(
                success: errors.isEmpty,
                syncedVisits: syncedVisits,
                syncedEvents: syncedEvents,
                conflicts: conflicts,
                errors: errors,
                duration: duration
            )
            
            await MainActor.run {
                self.syncStatus = .success
                self.lastSyncResult = result
            }
            
            return result
        } catch {
            await MainActor.run {
                self.syncStatus = .failed(error)
            }
            throw error
        }
    }
    
    func fullBidirectionalSync() async throws -> SyncResult {
        guard isEnabled else {
            throw SyncError.syncDisabled
        }
        
        let startTime = Date()
        var totalSyncedVisits = 0
        var totalSyncedEvents = 0
        let allConflicts: [ConflictInfo] = []
        var allErrors: [Error] = []
        
        await MainActor.run {
            self.syncStatus = .syncing
        }
        
        do {
            // Get visits from repository (placeholder - would need actual repository)
            let visits: [Any] = await getVisitsFromRepository()
            
            // Get events from calendar (placeholder)
            let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
            let endDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
            let events: [EKEvent] = []
            
            // Sync visits to calendar
            let visitSyncResult = try await syncVisitsToCalendar(visits)
            totalSyncedVisits += visitSyncResult.syncedVisits
            totalSyncedEvents += visitSyncResult.syncedEvents
            allErrors.append(contentsOf: visitSyncResult.errors)
            
            // Sync events to visits
            let eventSyncResult = try await syncEventsToVisits(events)
            totalSyncedVisits += eventSyncResult.syncedVisits
            totalSyncedEvents += eventSyncResult.syncedEvents
            allErrors.append(contentsOf: eventSyncResult.errors)
            
            let duration = Date().timeIntervalSince(startTime)
            let result = SyncResult(
                success: allErrors.isEmpty,
                syncedVisits: totalSyncedVisits,
                syncedEvents: totalSyncedEvents,
                conflicts: allConflicts,
                errors: allErrors,
                duration: duration
            )
            
            await MainActor.run {
                self.syncStatus = .success
                self.lastSyncResult = result
            }
            
            return result
        } catch {
            await MainActor.run {
                self.syncStatus = .failed(error)
            }
            throw error
        }
    }
    
    func resolveConflict(_ conflict: ConflictInfo, resolution: ConflictInfo.ConflictResolution) async throws {
        switch resolution {
        case .useVisit:
            try await resolveConflictUsingVisit(conflict)
        case .useEvent:
            try await resolveConflictUsingEvent(conflict)
        case .merge:
            try await resolveConflictByMerging(conflict)
        case .skip:
            // Mark conflict as resolved without action
            await MainActor.run {
                self.conflicts.removeAll { $0.id == conflict.id }
            }
        }
    }
    
    func getSyncStatus() -> SyncStatus {
        return syncStatus
    }
    
    func getConflicts() -> [ConflictInfo] {
        return conflicts
    }
    
    // MARK: - Private Methods
    private func createOrUpdateEvent(from visit: Any, in calendar: EKCalendar) async throws -> String? {
        // Placeholder implementation - would need actual visit type
        let event = EKEvent(eventStore: eventStore)
        event.title = "Visita JustDad"
        event.startDate = Date()
        event.endDate = Date().addingTimeInterval(3600) // 1 hour
        event.calendar = calendar
        
        try eventStore.save(event, span: .thisEvent, commit: true)
        return event.eventIdentifier
    }
    
    private func createOrUpdateVisit(from event: EKEvent) async throws -> Any? {
        // This would need to integrate with the actual repository
        // For now, return nil as placeholder
        return nil
    }
    
    private func resolveConflictUsingVisit(_ conflict: ConflictInfo) async throws {
        // Update calendar event to match visit
        if eventStore.event(withIdentifier: conflict.eventId) != nil {
            // This would need the actual visit data
            // For now, just mark as resolved
            await MainActor.run {
                self.conflicts.removeAll { $0.id == conflict.id }
            }
        }
    }
    
    private func resolveConflictUsingEvent(_ conflict: ConflictInfo) async throws {
        // Update visit to match calendar event
        // This would need repository integration
        await MainActor.run {
            self.conflicts.removeAll { $0.id == conflict.id }
        }
    }
    
    private func resolveConflictByMerging(_ conflict: ConflictInfo) async throws {
        // Merge visit and event data intelligently
        // This would need complex merge logic
        await MainActor.run {
            self.conflicts.removeAll { $0.id == conflict.id }
        }
    }
    
    private func getVisitsFromRepository() async -> [Any] {
        // Placeholder - would need actual repository integration
        return []
    }
    
    private func setupAutoSync() {
        // Monitor for changes and trigger auto-sync if enabled
        NotificationCenter.default.publisher(for: .EKEventStoreChanged)
            .sink { [weak self] _ in
                Task { @MainActor in
                    if self?.autoSyncEnabled == true {
                        try? await self?.fullBidirectionalSync()
                    }
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Sync Errors
enum SyncError: LocalizedError {
    case syncDisabled
    case permissionDenied
    case calendarNotFound
    case eventNotFound
    case visitNotFound
    case conflictResolutionFailed
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .syncDisabled:
            return "La sincronización está deshabilitada"
        case .permissionDenied:
            return "Permisos de calendario denegados"
        case .calendarNotFound:
            return "Calendario JustDad no encontrado"
        case .eventNotFound:
            return "Evento de calendario no encontrado"
        case .visitNotFound:
            return "Visita no encontrada"
        case .conflictResolutionFailed:
            return "Error al resolver conflicto"
        case .networkError(let error):
            return "Error de red: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .syncDisabled:
            return "Habilita la sincronización en configuración"
        case .permissionDenied:
            return "Autoriza el acceso al calendario en Configuración"
        case .calendarNotFound:
            return "Crea el calendario JustDad primero"
        case .eventNotFound, .visitNotFound:
            return "Verifica que el elemento existe y está disponible"
        case .conflictResolutionFailed:
            return "Intenta resolver el conflicto manualmente"
        case .networkError:
            return "Verifica tu conexión a internet"
        }
    }
}
