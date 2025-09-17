//
//  EventKitErrorHandler.swift
//  JustDad - EventKit Error Handler
//
//  Professional error handling for EventKit operations with
//  user-friendly messages and recovery suggestions
//

import Foundation
import EventKit
import SwiftUI

// MARK: - EventKit Error Types
enum EventKitError: LocalizedError, Identifiable {
    case permissionDenied(String)
    case calendarAccessDenied
    case eventStoreError(Error)
    case calendarNotFound(String)
    case eventNotFound(String)
    case eventCreationFailed(Error)
    case eventUpdateFailed(Error)
    case eventDeletionFailed(Error)
    case syncError(Error)
    case validationError(String)
    case networkError(Error)
    case unknownError(Error)
    
    var id: String {
        switch self {
        case .permissionDenied(let message):
            return "permission_\(message)"
        case .calendarAccessDenied:
            return "calendar_access_denied"
        case .eventStoreError(let error):
            return "event_store_\(error.localizedDescription)"
        case .calendarNotFound(let id):
            return "calendar_not_found_\(id)"
        case .eventNotFound(let id):
            return "event_not_found_\(id)"
        case .eventCreationFailed(let error):
            return "event_creation_\(error.localizedDescription)"
        case .eventUpdateFailed(let error):
            return "event_update_\(error.localizedDescription)"
        case .eventDeletionFailed(let error):
            return "event_deletion_\(error.localizedDescription)"
        case .syncError(let error):
            return "sync_\(error.localizedDescription)"
        case .validationError(let message):
            return "validation_\(message)"
        case .networkError(let error):
            return "network_\(error.localizedDescription)"
        case .unknownError(let error):
            return "unknown_\(error.localizedDescription)"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied(let message):
            return message
        case .calendarAccessDenied:
            return "Acceso al calendario denegado"
        case .eventStoreError(let error):
            return "Error del almacén de eventos: \(error.localizedDescription)"
        case .calendarNotFound(let calendarName):
            return "Calendario '\(calendarName)' no encontrado"
        case .eventNotFound(let eventId):
            return "Evento '\(eventId)' no encontrado"
        case .eventCreationFailed(let error):
            return "Error al crear evento: \(error.localizedDescription)"
        case .eventUpdateFailed(let error):
            return "Error al actualizar evento: \(error.localizedDescription)"
        case .eventDeletionFailed(let error):
            return "Error al eliminar evento: \(error.localizedDescription)"
        case .syncError(let error):
            return "Error de sincronización: \(error.localizedDescription)"
        case .validationError(let message):
            return "Error de validación: \(message)"
        case .networkError(let error):
            return "Error de red: \(error.localizedDescription)"
        case .unknownError(let error):
            return "Error desconocido: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .permissionDenied:
            return "Ve a Configuración > JustDad y autoriza el acceso al calendario"
        case .calendarAccessDenied:
            return "Verifica que el calendario existe y tienes permisos para editarlo"
        case .eventStoreError:
            return "Reinicia la aplicación y verifica que el calendario esté funcionando"
        case .calendarNotFound:
            return "Crea el calendario JustDad o selecciona un calendario diferente"
        case .eventNotFound:
            return "El evento puede haber sido eliminado. Intenta crear uno nuevo"
        case .eventCreationFailed, .eventUpdateFailed, .eventDeletionFailed:
            return "Verifica que tienes permisos de escritura en el calendario seleccionado"
        case .syncError:
            return "Intenta sincronizar nuevamente o verifica tu conexión"
        case .validationError:
            return "Verifica que los datos ingresados sean válidos"
        case .networkError:
            return "Verifica tu conexión a internet y vuelve a intentar"
        case .unknownError:
            return "Contacta al soporte técnico si el problema persiste"
        }
    }
    
    var severity: EventKitErrorSeverity {
        switch self {
        case .permissionDenied, .calendarAccessDenied:
            return .critical
        case .eventStoreError, .calendarNotFound:
            return .high
        case .eventNotFound, .eventCreationFailed, .eventUpdateFailed, .eventDeletionFailed:
            return .medium
        case .syncError, .validationError:
            return .low
        case .networkError:
            return .medium
        case .unknownError:
            return .high
        }
    }
    
    var canRetry: Bool {
        switch self {
        case .permissionDenied, .calendarAccessDenied:
            return false
        case .eventStoreError, .calendarNotFound:
            return true
        case .eventNotFound, .eventCreationFailed, .eventUpdateFailed, .eventDeletionFailed:
            return true
        case .syncError, .networkError:
            return true
        case .validationError:
            return false
        case .unknownError:
            return true
        }
    }
}

// MARK: - EventKit Error Severity
enum EventKitErrorSeverity: Int, CaseIterable {
    case low = 1
    case medium = 2
    case high = 3
    case critical = 4
    
    var displayName: String {
        switch self {
        case .low: return "Bajo"
        case .medium: return "Medio"
        case .high: return "Alto"
        case .critical: return "Crítico"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
}

// MARK: - EventKit Error Handler
@MainActor
class EventKitErrorHandler: ObservableObject {
    static let shared = EventKitErrorHandler()
    
    // MARK: - Published Properties
    @Published var activeError: EventKitError?
    @Published var errorHistory: [EventKitError] = []
    @Published var showingErrorAlert: Bool = false
    @Published var retryCount: [String: Int] = [:]
    
    // MARK: - Private Properties
    private let maxRetries = 3
    private let maxHistorySize = 100
    
    private init() {}
    
    // MARK: - Error Handling
    func handle(_ error: EventKitError) {
        activeError = error
        showingErrorAlert = true
        
        // Add to history
        addToHistory(error)
        
        // Log error
        logError(error)
    }
    
    func handle(error: Error) {
        let eventKitError = mapToEventKitError(error)
        handle(eventKitError)
    }
    
    func dismissError() {
        activeError = nil
        showingErrorAlert = false
    }
    
    func retryLastError() async throws {
        guard let error = activeError else {
            throw EventKitError.unknownError(NSError(domain: "NoError", code: 0))
        }
        
        guard error.canRetry else {
            throw EventKitError.unknownError(NSError(domain: "CannotRetry", code: 0))
        }
        
        let errorId = error.id
        let currentRetries = retryCount[errorId] ?? 0
        
        guard currentRetries < maxRetries else {
            throw EventKitError.unknownError(NSError(domain: "MaxRetriesExceeded", code: 0))
        }
        
        retryCount[errorId] = currentRetries + 1
        
        // Perform retry logic based on error type
        try await performRetry(for: error)
    }
    
    func clearErrorHistory() {
        errorHistory.removeAll()
        retryCount.removeAll()
    }
    
    func getErrorsBySeverity(_ severity: EventKitErrorSeverity) -> [EventKitError] {
        return errorHistory.filter { $0.severity == severity }
    }
    
    func getRecentErrors(limit: Int = 10) -> [EventKitError] {
        return Array(errorHistory.prefix(limit))
    }
    
    // MARK: - Private Methods
    private func mapToEventKitError(_ error: Error) -> EventKitError {
        if let eventKitError = error as? EventKitError {
            return eventKitError
        }
        
        if let nsError = error as? NSError {
            switch nsError.domain {
            case "EKErrorDomain":
                return mapEKError(nsError)
            case "NSCocoaErrorDomain":
                return mapCocoaError(nsError)
            case "NSURLErrorDomain":
                return .networkError(error)
            default:
                return .unknownError(error)
            }
        }
        
        return .unknownError(error)
    }
    
    private func mapEKError(_ error: NSError) -> EventKitError {
        switch error.code {
        case EKError.eventNotMutable.rawValue:
            return .eventUpdateFailed(error)
        case EKError.noStartDate.rawValue:
            return .validationError("Fecha de inicio requerida")
        case EKError.noEndDate.rawValue:
            return .validationError("Fecha de fin requerida")
        case EKError.datesInverted.rawValue:
            return .validationError("La fecha de inicio debe ser anterior a la fecha de fin")
        case EKError.invalidSpan.rawValue:
            return .validationError("Período de tiempo inválido")
        case EKError.calendarHasNoSource.rawValue:
            return .calendarNotFound("Sin fuente")
        case EKError.calendarSourceCannotBeModified.rawValue:
            return .calendarAccessDenied
        case EKError.calendarIsImmutable.rawValue:
            return .calendarAccessDenied
        case EKError.calendarDoesNotAllowEvents.rawValue:
            return .calendarAccessDenied
        case EKError.calendarDoesNotAllowReminders.rawValue:
            return .calendarAccessDenied
        case EKError.sourceDoesNotAllowCalendarAddDelete.rawValue:
            return .calendarAccessDenied
        case EKError.recurringReminderRequiresDueDate.rawValue:
            return .validationError("Recordatorio recurrente requiere fecha de vencimiento")
        default:
            return .eventStoreError(error)
        }
    }
    
    private func mapCocoaError(_ error: NSError) -> EventKitError {
        switch error.code {
        case NSUserCancelledError:
            return .permissionDenied("Usuario canceló la operación")
        case NSFileReadNoPermissionError:
            return .permissionDenied("Sin permisos de lectura")
        case NSFileWriteNoPermissionError:
            return .permissionDenied("Sin permisos de escritura")
        default:
            return .unknownError(error)
        }
    }
    
    private func addToHistory(_ error: EventKitError) {
        errorHistory.insert(error, at: 0)
        
        // Keep history size manageable
        if errorHistory.count > maxHistorySize {
            errorHistory = Array(errorHistory.prefix(maxHistorySize))
        }
    }
    
    private func logError(_ error: EventKitError) {
        let severity = error.severity.displayName
        let message = error.localizedDescription
        print("🚨 [EventKit Error - \(severity)]: \(message)")
        
        if let suggestion = error.recoverySuggestion {
            print("💡 Sugerencia: \(suggestion)")
        }
    }
    
    private func performRetry(for error: EventKitError) async throws {
        // This would contain the actual retry logic
        // For now, just simulate a retry
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // In a real implementation, this would retry the specific operation
        // that caused the error
        print("🔄 Retrying operation for error: \(error.localizedDescription)")
    }
}

// MARK: - Error Recovery Actions
extension EventKitErrorHandler {
    func openSettings() {
        if let settingsUrl = URL(string: "app-settings:") {
            // Placeholder - would need actual implementation
            print("Opening settings: \(settingsUrl)")
        }
    }
    
    func requestCalendarPermission() async {
        // Placeholder - would need actual permission service
        print("Requesting calendar permission...")
    }
    
    func createJustDadCalendar() async {
        // Placeholder - would need actual calendar service
        print("Creating JustDad calendar...")
    }
}
