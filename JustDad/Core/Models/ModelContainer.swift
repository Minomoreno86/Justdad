//
//  ModelContainer.swift
//  JustDad - SwiftData Container Configuration
//
//  Centralized container setup with proper model access
//

import Foundation
import SwiftData

@MainActor
class ModelContainerManager {
    static let shared = ModelContainerManager()
    
    private var _container: ModelContainer?
    
    var container: ModelContainer? {
        return _container
    }
    
    private init() {}
    
    func initializeContainer() throws {
        guard _container == nil else { return }
        
        let schema = Schema([
            Visit.self,
            VisitAttachment.self,
            EmergencyContact.self,
            AppSettings.self,
            FinancialEntry.self,
            EmotionalEntry.self,
            DiaryEntry.self,
            DiaryAttachment.self,
            CommunityPost.self,
            UserPreferences.self,
            CustomCategory.self,
            FinancialGoal.self,
            GoalAchievement.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
            _container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            print("✅ SwiftData container initialized successfully")
        } catch {
            print("❌ Error initializing SwiftData container: \(error)")
            // Fallback to in-memory storage if persistent storage fails
            let fallbackConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true,
                allowsSave: true
            )
            _container = try ModelContainer(
                for: schema,
                configurations: [fallbackConfiguration]
            )
            print("⚠️ Using in-memory storage as fallback")
        }
    }
    
    func getContext() -> ModelContext? {
        guard let container = _container else {
            print("❌ Container not initialized")
            return nil
        }
        return ModelContext(container)
    }
    
    func resetDatabase() {
        print("🔄 Resetting database...")
        _container = nil
        
        // Clear any existing database files
        clearDatabaseFiles()
        
        // Reinitialize container
        do {
            try initializeContainer()
            print("✅ Database reset successfully")
        } catch {
            print("❌ Failed to reset database: \(error)")
        }
    }
    
    private func clearDatabaseFiles() {
        let fileManager = FileManager.default
        
        // Get the application support directory
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            print("❌ Could not find application support directory")
            return
        }
        
        // Clear SwiftData files
        let swiftDataURL = appSupportURL.appendingPathComponent("default.store")
        let swiftDataShmURL = appSupportURL.appendingPathComponent("default.store-shm")
        let swiftDataWalURL = appSupportURL.appendingPathComponent("default.store-wal")
        
        let filesToDelete = [swiftDataURL, swiftDataShmURL, swiftDataWalURL]
        
        for fileURL in filesToDelete {
            if fileManager.fileExists(atPath: fileURL.path) {
                do {
                    try fileManager.removeItem(at: fileURL)
                    print("🗑️ Deleted: \(fileURL.lastPathComponent)")
                } catch {
                    print("⚠️ Could not delete \(fileURL.lastPathComponent): \(error)")
                }
            }
        }
    }
}
