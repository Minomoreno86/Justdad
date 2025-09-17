//
//  EventKitPermissionService.swift
//  JustDad - EventKit Permission Management
//
//  Professional EventKit permission management with comprehensive error handling,
//  status monitoring, and user-friendly permission requests
//

import Foundation
import EventKit
import UserNotifications
import Combine
import SwiftUI

// MARK: - Permission Status
@MainActor
class EventKitPermissionService: ObservableObject {
    static let shared = EventKitPermissionService()
    
    // MARK: - Published Properties
    @Published var calendarPermissionStatus: EKAuthorizationStatus = .notDetermined
    @Published var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined
    @Published var isCalendarAuthorized: Bool = false
    @Published var isNotificationAuthorized: Bool = false
    @Published var isFullyAuthorized: Bool = false
    @Published var lastPermissionCheck: Date = Date()
    
    // MARK: - Private Properties
    private let eventStore = EKEventStore()
    private let notificationCenter = UNUserNotificationCenter.current()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        checkAllPermissions()
        setupPermissionMonitoring()
    }
    
    // MARK: - Permission Checking
    func checkAllPermissions() {
        checkCalendarPermission()
        checkNotificationPermission()
        updateFullyAuthorizedStatus()
    }
    
    private func checkCalendarPermission() {
        calendarPermissionStatus = EKEventStore.authorizationStatus(for: .event)
        isCalendarAuthorized = isCalendarPermissionGranted(calendarPermissionStatus)
    }
    
    private func checkNotificationPermission() {
        Task {
            let settings = await notificationCenter.notificationSettings()
            await MainActor.run {
                notificationPermissionStatus = settings.authorizationStatus
                isNotificationAuthorized = settings.authorizationStatus == .authorized
                updateFullyAuthorizedStatus()
            }
        }
    }
    
    private func isCalendarPermissionGranted(_ status: EKAuthorizationStatus) -> Bool {
        if #available(iOS 17.0, *) {
            return status == .fullAccess
        } else {
            return status == .authorized
        }
    }
    
    private func updateFullyAuthorizedStatus() {
        isFullyAuthorized = isCalendarAuthorized && isNotificationAuthorized
        lastPermissionCheck = Date()
    }
    
    // MARK: - Permission Requesting
    func requestCalendarPermission() async -> Bool {
        let granted: Bool
        
        if #available(iOS 17.0, *) {
            do {
                granted = try await eventStore.requestFullAccessToEvents()
            } catch {
                print("❌ Failed to request full access to events: \(error)")
                granted = false
            }
        } else {
            granted = await withCheckedContinuation { continuation in
                eventStore.requestAccess(to: .event) { success, error in
                    if let error = error {
                        print("❌ Calendar permission request failed: \(error)")
                    }
                    continuation.resume(returning: success)
                }
            }
        }
        
        await MainActor.run {
            checkCalendarPermission()
        }
        
        return granted
    }
    
    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge, .provisional]
            )
            
            await MainActor.run {
                checkNotificationPermission()
            }
            
            return granted
        } catch {
            print("❌ Notification permission request failed: \(error)")
            return false
        }
    }
    
    func requestAllPermissions() async -> PermissionResult {
        let calendarGranted = await requestCalendarPermission()
        let notificationGranted = await requestNotificationPermission()
        
        return PermissionResult(
            calendar: calendarGranted,
            notification: notificationGranted,
            fullyAuthorized: calendarGranted && notificationGranted
        )
    }
    
    // MARK: - Permission Status Helpers
    func getPermissionStatusDescription() -> String {
        switch (isCalendarAuthorized, isNotificationAuthorized) {
        case (true, true):
            return "Todos los permisos están autorizados"
        case (true, false):
            return "Calendario autorizado, notificaciones pendientes"
        case (false, true):
            return "Notificaciones autorizadas, calendario pendiente"
        case (false, false):
            return "Permisos no autorizados"
        }
    }
    
    func getCalendarPermissionDescription() -> String {
        switch calendarPermissionStatus {
        case .notDetermined:
            return "Permisos de calendario no solicitados"
        case .denied:
            return "Permisos de calendario denegados"
        case .restricted:
            return "Permisos de calendario restringidos"
        case .authorized:
            return "Permisos de calendario autorizados"
        case .fullAccess:
            if #available(iOS 17.0, *) {
                return "Acceso completo al calendario autorizado"
            } else {
                return "Permisos de calendario autorizados"
            }
        case .writeOnly:
            if #available(iOS 17.0, *) {
                return "Solo escritura en calendario autorizada"
            } else {
                return "Permisos de calendario autorizados"
            }
        @unknown default:
            return "Estado de permisos de calendario desconocido"
        }
    }
    
    func getNotificationPermissionDescription() -> String {
        switch notificationPermissionStatus {
        case .notDetermined:
            return "Permisos de notificación no solicitados"
        case .denied:
            return "Permisos de notificación denegados"
        case .authorized:
            return "Permisos de notificación autorizados"
        case .provisional:
            return "Permisos de notificación provisionales"
        case .ephemeral:
            return "Permisos de notificación efímeros"
        @unknown default:
            return "Estado de permisos de notificación desconocido"
        }
    }
    
    // MARK: - Permission Monitoring
    private func setupPermissionMonitoring() {
        // Monitor calendar permission changes
        Timer.publish(every: 30.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkAllPermissions()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Settings Navigation
    func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
    }
    
    func openCalendarSettings() {
        if let settingsUrl = URL(string: "App-prefs:Privacy&path=CALENDARS") {
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            } else {
                openAppSettings()
            }
        }
    }
    
    func openNotificationSettings() {
        if let settingsUrl = URL(string: "App-prefs:NOTIFICATIONS_ID") {
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            } else {
                openAppSettings()
            }
        }
    }
}

// MARK: - Permission Result
struct PermissionResult {
    let calendar: Bool
    let notification: Bool
    let fullyAuthorized: Bool
    
    var description: String {
        switch (calendar, notification) {
        case (true, true):
            return "Todos los permisos autorizados"
        case (true, false):
            return "Calendario autorizado, notificaciones pendientes"
        case (false, true):
            return "Notificaciones autorizadas, calendario pendiente"
        case (false, false):
            return "Permisos no autorizados"
        }
    }
}

// MARK: - Permission Error
enum PermissionError: LocalizedError {
    case calendarDenied
    case notificationDenied
    case bothDenied
    case restricted
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .calendarDenied:
            return "Acceso al calendario denegado"
        case .notificationDenied:
            return "Permisos de notificación denegados"
        case .bothDenied:
            return "Permisos de calendario y notificaciones denegados"
        case .restricted:
            return "Permisos restringidos por configuración del dispositivo"
        case .unknown:
            return "Error desconocido al solicitar permisos"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .calendarDenied, .notificationDenied, .bothDenied:
            return "Por favor, ve a Configuración > JustDad y autoriza los permisos necesarios"
        case .restricted:
            return "Los permisos están restringidos. Contacta al administrador del dispositivo"
        case .unknown:
            return "Intenta reiniciar la aplicación o contacta al soporte"
        }
    }
}
