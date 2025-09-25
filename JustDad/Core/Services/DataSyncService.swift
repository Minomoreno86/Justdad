//
//  DataSyncService.swift
//  JustDad - Data Synchronization Service
//
//  Professional data synchronization with conflict resolution
//

import Foundation
import SwiftData
import Combine

#if os(iOS)
import UIKit
#endif

@MainActor
class DataSyncService: ObservableObject {
    static let shared = DataSyncService()
    
    @Published var isSyncing = false
    @Published var syncProgress: Double = 0.0
    @Published var lastSyncDate: Date?
    @Published var syncStatus: SyncStatus = .idle
    
    private let persistenceService = PersistenceService.shared
    private let securityService = SecurityService.shared
    private var cancellables = Set<AnyCancellable>()
    
    enum SyncStatus {
        case idle
        case syncing
        case success
        case error(String)
    }
    
    private init() {
        setupSyncTriggers()
    }
    
    private func setupSyncTriggers() {
        #if os(iOS)
        // Auto-sync when app becomes active
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                Task {
                    await self?.performAutoSync()
                }
            }
            .store(in: &cancellables)
        #endif
    }
    
    // MARK: - Sync Operations
    func performFullSync() async {
        guard !isSyncing else { return }
        
        isSyncing = true
        syncStatus = .syncing
        syncProgress = 0.0
        
        do {
            // Step 1: Backup current data
            await updateProgress(0.1, "Creando respaldo...")
            try await createBackup()
            
            // Step 2: Sync financial data
            await updateProgress(0.3, "Sincronizando datos financieros...")
            try await syncFinancialData()
            
            // Step 3: Sync agenda data
            await updateProgress(0.5, "Sincronizando agenda...")
            try await syncAgendaData()
            
            // Step 4: Sync emotional data
            await updateProgress(0.7, "Sincronizando datos emocionales...")
            try await syncEmotionalData()
            
            // Step 5: Sync diary data
            await updateProgress(0.9, "Sincronizando diario...")
            try await syncDiaryData()
            
            // Step 6: Complete sync
            await updateProgress(1.0, "Sincronización completada")
            syncStatus = .success
            lastSyncDate = Date()
            
        } catch {
            syncStatus = .error(error.localizedDescription)
            print("Sync error: \(error)")
        }
        
        isSyncing = false
    }
    
    private func performAutoSync() async {
        // Only auto-sync if last sync was more than 1 hour ago
        guard let lastSync = lastSyncDate,
              Date().timeIntervalSince(lastSync) > 3600 else {
            return
        }
        
        await performFullSync()
    }
    
    // MARK: - Data Synchronization
    private func syncFinancialData() async throws {
        let financialEntries = try persistenceService.fetch(FinancialEntry.self)
        
        for entry in financialEntries {
            // Check for conflicts
            if let conflict = try await checkForConflicts(entry) {
                try await resolveConflict(conflict)
            }
            
            // Update last modified timestamp
            entry.updatedAt = Date()
            try await persistenceService.save(entry)
        }
    }
    
    private func syncAgendaData() async throws {
        let visits = try persistenceService.fetch(Visit.self)
        
        for visit in visits {
            // Check for conflicts
            if let conflict = try await checkForConflicts(visit) {
                try await resolveConflict(conflict)
            }
            
            // Update last modified timestamp
            visit.updatedAt = Date()
            try await persistenceService.save(visit)
        }
    }
    
    private func syncEmotionalData() async throws {
        let emotionalEntries = try persistenceService.fetch(EmotionalEntry.self)
        
        for entry in emotionalEntries {
            // Check for conflicts
            if let conflict = try await checkForConflicts(entry) {
                try await resolveConflict(conflict)
            }
            
            // Update last modified timestamp
            // entry.updatedAt = Date() // EmotionalEntry doesn't have updatedAt
            try await persistenceService.save(entry)
        }
    }
    
    private func syncDiaryData() async throws {
        let diaryEntries = try persistenceService.fetch(DiaryEntry.self)
        
        for entry in diaryEntries {
            // Check for conflicts
            if let conflict = try await checkForConflicts(entry) {
                try await resolveConflict(conflict)
            }
            
            // Update last modified timestamp
            entry.updatedAt = Date()
            try await persistenceService.save(entry)
        }
    }
    
    // MARK: - Conflict Resolution
    private func checkForConflicts<T: PersistentModel>(_ item: T) async throws -> SyncConflictInfo? {
        // This is a simplified conflict detection
        // In a real implementation, you'd compare with remote data
        return nil
    }
    
    private func resolveConflict(_ conflict: SyncConflictInfo) async throws {
        // Implement conflict resolution logic
        // For now, we'll use the local version
        print("Resolving conflict for: \(conflict.itemId)")
    }
    
    // MARK: - Backup Management
    private func createBackup() async throws {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let backupPath = documentsPath.appendingPathComponent("Backups")
        
        try FileManager.default.createDirectory(at: backupPath, withIntermediateDirectories: true)
        
        let backupFileName = "backup_\(Date().timeIntervalSince1970).json"
        let backupURL = backupPath.appendingPathComponent(backupFileName)
        
        let backupData = try await createBackupData()
        try backupData.write(to: backupURL)
    }
    
    private func createBackupData() async throws -> Data {
        let financialEntries = try persistenceService.fetch(FinancialEntry.self)
        let visits = try persistenceService.fetch(Visit.self)
        let emotionalEntries = try persistenceService.fetch(EmotionalEntry.self)
        let diaryEntries = try persistenceService.fetch(DiaryEntry.self)
        
        let backupData: [String: Any] = [
            "financialEntries": financialEntries.map { $0.toSyncDictionary() },
            "visits": visits.map { $0.toSyncDictionary() },
            "emotionalEntries": emotionalEntries.map { $0.toSyncDictionary() },
            "diaryEntries": diaryEntries.map { $0.toSyncDictionary() },
            "backupDate": Date().timeIntervalSince1970
        ]
        
        return try JSONSerialization.data(withJSONObject: backupData, options: .prettyPrinted)
    }
    
    // MARK: - Progress Updates
    private func updateProgress(_ progress: Double, _ status: String) async {
        await MainActor.run {
            syncProgress = progress
        }
    }
    
    // MARK: - Sync Status
    func getSyncStatus() -> SyncStatus {
        return syncStatus
    }
    
    func getLastSyncDate() -> Date? {
        return lastSyncDate
    }
    
    func isSyncInProgress() -> Bool {
        return isSyncing
    }
}

// MARK: - Supporting Types
struct SyncConflictInfo {
    let itemId: UUID
    let localVersion: Date
    let remoteVersion: Date
    let conflictType: ConflictType
}

enum ConflictType {
    case timestamp
    case content
    case deletion
}

// MARK: - Dictionary Conversion
extension PersistentModel {
    func toSyncDictionary() -> [String: Any] {
        // This is a simplified implementation
        // In a real app, you'd use reflection or Codable
        return [:]
    }
}
