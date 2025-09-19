//
//  SyncStatusService.swift
//  JustDad - Sync Status Service
//
//  Professional sync status management with real-time updates and notifications
//

import Foundation
import Combine
import EventKit

// MARK: - Simple Sync Status Enum
enum SimpleSyncStatus: String, CaseIterable {
    case idle = "idle"
    case syncing = "syncing"
    case success = "success"
    case failed = "failed"
    case conflict = "conflict"
}

// MARK: - Sync Status Service Protocol
protocol SyncStatusServiceProtocol: ObservableObject {
    var syncStatus: SimpleSyncStatus { get }
    var lastSyncDate: Date? { get }
    var syncProgress: Double { get }
    var syncMessage: String { get }
    var hasError: Bool { get }
    var lastError: Error? { get }
    var isConflictDetected: Bool { get }
    
    func startSync()
    func retrySync()
    func resolveConflict()
    func stopSync()
}

// MARK: - Mock Sync Status Service
class MockSyncStatusService: SyncStatusServiceProtocol {
    @Published var syncStatus: SimpleSyncStatus = .idle
    @Published var lastSyncDate: Date? = Date().addingTimeInterval(-300) // 5 minutes ago
    @Published var syncProgress: Double = 0.0
    @Published var syncMessage: String = "Listo para sincronizar"
    @Published var hasError: Bool = false
    @Published var lastError: Error? = nil
    @Published var isConflictDetected: Bool = false
    
    func startSync() {
        syncStatus = .syncing
        syncProgress = 0.0
        syncMessage = "Sincronizando con EventKit..."
        
        // Simulate sync process
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.syncStatus = .success
            self.syncProgress = 1.0
            self.syncMessage = "Sincronización completada"
            self.lastSyncDate = Date()
        }
    }
    
    func retrySync() {
        startSync()
    }
    
    func resolveConflict() {
        isConflictDetected = false
        syncStatus = .idle
        syncMessage = "Conflicto resuelto"
    }
    
    func stopSync() {
        syncStatus = .idle
        syncProgress = 0.0
        syncMessage = "Sincronización detenida"
    }
}

// MARK: - Sync Status Manager
class SyncStatusManager: ObservableObject {
    // MARK: - Singleton
    static let shared = SyncStatusManager()
    
    // MARK: - Published Properties
    @Published var isVisible: Bool = false
    @Published var showError: Bool = false
    @Published var showConflict: Bool = false
    
    // MARK: - Private Properties
    private let syncStatusService: MockSyncStatusService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    private init() {
        self.syncStatusService = MockSyncStatusService()
        setupSubscriptions()
    }
    
    // MARK: - Setup
    private func setupSubscriptions() {
        syncStatusService.$syncStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.handleStatusChange(status)
            }
            .store(in: &cancellables)
        
        syncStatusService.$hasError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hasError in
                self?.showError = hasError
            }
            .store(in: &cancellables)
        
        syncStatusService.$isConflictDetected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConflict in
                self?.showConflict = isConflict
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func startSync() {
        syncStatusService.startSync()
    }
    
    func retrySync() {
        syncStatusService.retrySync()
    }
    
    func resolveConflict() {
        syncStatusService.resolveConflict()
    }
    
    func dismissError() {
        showError = false
    }
    
    func dismissConflict() {
        showConflict = false
    }
    
    // MARK: - Computed Properties
    var syncService: MockSyncStatusService {
        return self.syncStatusService
    }
    
    // MARK: - Private Methods
    private func handleStatusChange(_ status: SimpleSyncStatus) {
        switch status {
        case .idle:
            isVisible = false
        case .syncing:
            isVisible = true
        case .success:
            isVisible = true
            // Hide after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.isVisible = false
            }
        case .failed, .conflict:
            isVisible = true
        }
    }
}
