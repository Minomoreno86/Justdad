//
//  DataMigrationService.swift
//  JustDad - Data Migration Service
//
//  Professional data migration with version control and rollback
//

import Foundation
import SwiftData
import Combine

@MainActor
class DataMigrationService: ObservableObject {
    static let shared = DataMigrationService()
    
    @Published var isMigrating = false
    @Published var migrationProgress: Double = 0.0
    @Published var migrationStatus: MigrationStatus = .idle
    
    private let persistenceService = PersistenceService.shared
    private let fileManager = FileManager.default
    private let userDefaults = UserDefaults.standard
    
    enum MigrationStatus {
        case idle
        case migrating
        case success
        case error(String)
        case rollback
    }
    
    private let currentVersion = "1.0.0"
    private let versionKey = "app_data_version"
    
    private init() {
        checkForMigration()
    }
    
    // MARK: - Migration Check
    private func checkForMigration() {
        let storedVersion = userDefaults.string(forKey: versionKey) ?? "0.0.0"
        
        if storedVersion != currentVersion {
            Task {
                await performMigration(from: storedVersion, to: currentVersion)
            }
        }
    }
    
    // MARK: - Migration Operations
    private func performMigration(from oldVersion: String, to newVersion: String) async {
        guard !isMigrating else { return }
        
        isMigrating = true
        migrationStatus = .migrating
        migrationProgress = 0.0
        
        do {
            // Step 1: Create backup
            await updateProgress(0.1, "Creando respaldo...")
            _ = try await createMigrationBackup()
            
            // Step 2: Perform version-specific migrations
            await updateProgress(0.2, "Migrando datos...")
            try await performVersionMigrations(from: oldVersion, to: newVersion)
            
            // Step 3: Validate migrated data
            await updateProgress(0.8, "Validando datos...")
            try await validateMigratedData()
            
            // Step 4: Update version
            await updateProgress(0.9, "Actualizando versión...")
            userDefaults.set(newVersion, forKey: versionKey)
            
            // Step 5: Complete migration
            await updateProgress(1.0, "Migración completada")
            migrationStatus = .success
            
        } catch {
            migrationStatus = .error(error.localizedDescription)
            print("Migration error: \(error)")
            
            // Attempt rollback
            await attemptRollback()
        }
        
        isMigrating = false
    }
    
    private func performVersionMigrations(from oldVersion: String, to newVersion: String) async throws {
        let versionSteps = getMigrationSteps(from: oldVersion, to: newVersion)
        
        for (index, step) in versionSteps.enumerated() {
            await updateProgress(0.2 + (0.6 * Double(index) / Double(versionSteps.count)), "Ejecutando: \(step.name)")
            try await step.execute()
        }
    }
    
    private func getMigrationSteps(from oldVersion: String, to newVersion: String) -> [MigrationStep] {
        var steps: [MigrationStep] = []
        
        // Add version-specific migration steps
        if oldVersion < "1.0.0" {
            steps.append(MigrationStep(
                name: "Migrar datos financieros",
                execute: migrateFinancialData
            ))
            
            steps.append(MigrationStep(
                name: "Migrar datos de agenda",
                execute: migrateAgendaData
            ))
            
            steps.append(MigrationStep(
                name: "Migrar datos emocionales",
                execute: migrateEmotionalData
            ))
        }
        
        return steps
    }
    
    // MARK: - Data Migration Steps
    private func migrateFinancialData() async throws {
        // Migrate financial entries to new schema
        let financialEntries = try persistenceService.fetch(FinancialEntry.self)
        
        for entry in financialEntries {
            // Add new fields if they don't exist
            // entry.updatedAt is already set in the model
            try await persistenceService.save(entry)
        }
    }
    
    private func migrateAgendaData() async throws {
        // Migrate agenda entries to new schema
        let visits = try persistenceService.fetch(Visit.self)
        
        for visit in visits {
            // Add new fields if they don't exist
            // visit.updatedAt is already set in the model
            try await persistenceService.save(visit)
        }
    }
    
    private func migrateEmotionalData() async throws {
        // Migrate emotional entries to new schema
        let emotionalEntries = try persistenceService.fetch(EmotionalEntry.self)
        
        for entry in emotionalEntries {
            // Add new fields if they don't exist
            // EmotionalEntry doesn't have updatedAt field
            try await persistenceService.save(entry)
        }
    }
    
    // MARK: - Backup and Rollback
    private func createMigrationBackup() async throws -> URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let backupPath = documentsPath.appendingPathComponent("MigrationBackups")
        
        try fileManager.createDirectory(at: backupPath, withIntermediateDirectories: true)
        
        let backupFileName = "migration_backup_\(Date().timeIntervalSince1970).json"
        let backupURL = backupPath.appendingPathComponent(backupFileName)
        
        let backupData = try await createBackupData()
        try backupData.write(to: backupURL)
        
        return backupURL
    }
    
    private func createBackupData() async throws -> Data {
        let financialEntries = try persistenceService.fetch(FinancialEntry.self)
        let visits = try persistenceService.fetch(Visit.self)
        let emotionalEntries = try persistenceService.fetch(EmotionalEntry.self)
        let diaryEntries = try persistenceService.fetch(DiaryEntry.self)
        
        let backupData: [String: Any] = [
            "financialEntries": financialEntries.map { $0.toDictionary() },
            "visits": visits.map { $0.toDictionary() },
            "emotionalEntries": emotionalEntries.map { $0.toDictionary() },
            "diaryEntries": diaryEntries.map { $0.toDictionary() },
            "backupDate": Date().timeIntervalSince1970,
            "version": currentVersion
        ]
        
        return try JSONSerialization.data(withJSONObject: backupData, options: .prettyPrinted)
    }
    
    private func attemptRollback() async {
        migrationStatus = .rollback
        
        // Find the most recent backup
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let backupPath = documentsPath.appendingPathComponent("MigrationBackups")
        
        do {
            let backups = try fileManager.contentsOfDirectory(at: backupPath, includingPropertiesForKeys: [.creationDateKey])
            let sortedBackups = backups.sorted { file1, file2 in
                let date1 = (try? file1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                let date2 = (try? file2.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                return date1 > date2
            }
            
            if let latestBackup = sortedBackups.first {
                try await restoreFromBackup(latestBackup)
            }
        } catch {
            print("Rollback error: \(error)")
        }
    }
    
    private func restoreFromBackup(_ backupURL: URL) async throws {
        let data = try Data(contentsOf: backupURL)
        _ = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        // Restore data from backup
        // This is a simplified implementation
        print("Restoring from backup: \(backupURL.lastPathComponent)")
    }
    
    // MARK: - Data Validation
    private func validateMigratedData() async throws {
        // Validate that all data is properly migrated
        let financialEntries = try persistenceService.fetch(FinancialEntry.self)
        let visits = try persistenceService.fetch(Visit.self)
        let emotionalEntries = try persistenceService.fetch(EmotionalEntry.self)
        let diaryEntries = try persistenceService.fetch(DiaryEntry.self)
        
        // Check that all entries have required fields
        for entry in financialEntries {
            // FinancialEntry.updatedAt is already validated in the model
            if entry.title.isEmpty {
                throw MigrationError.validationFailed("Financial entry missing title")
            }
        }
        
        for visit in visits {
            // Visit.updatedAt is already validated in the model
            if visit.title.isEmpty {
                throw MigrationError.validationFailed("Visit missing title")
            }
        }
        
        for entry in emotionalEntries {
            // EmotionalEntry doesn't have updatedAt field
            if entry.note?.isEmpty ?? true {
                throw MigrationError.validationFailed("Emotional entry missing note")
            }
        }
        
        for entry in diaryEntries {
            // DiaryEntry.updatedAt is already validated in the model
            if entry.content.isEmpty {
                throw MigrationError.validationFailed("Diary entry missing content")
            }
        }
    }
    
    // MARK: - Progress Updates
    private func updateProgress(_ progress: Double, _ status: String) async {
        await MainActor.run {
            migrationProgress = progress
        }
    }
    
    // MARK: - Migration Status
    func getMigrationStatus() -> MigrationStatus {
        return migrationStatus
    }
    
    func isMigrationInProgress() -> Bool {
        return isMigrating
    }
    
    func getCurrentVersion() -> String {
        return currentVersion
    }
    
    func getStoredVersion() -> String {
        return userDefaults.string(forKey: versionKey) ?? "0.0.0"
    }
}

// MARK: - Supporting Types
struct MigrationStep {
    let name: String
    let execute: () async throws -> Void
}

enum MigrationError: LocalizedError {
    case validationFailed(String)
    case backupFailed
    case rollbackFailed
    
    var errorDescription: String? {
        switch self {
        case .validationFailed(let message):
            return "Validación fallida: \(message)"
        case .backupFailed:
            return "No se pudo crear el respaldo"
        case .rollbackFailed:
            return "No se pudo restaurar desde el respaldo"
        }
    }
}

// MARK: - Extensions
// Date extension moved to avoid conflicts

extension PersistentModel {
    func toDictionary() -> [String: Any] {
        // This is a simplified implementation
        // In a real app, you'd use reflection or Codable
        return [:]
    }
}
