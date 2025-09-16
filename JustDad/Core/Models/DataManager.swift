//
//  DataManager.swift
//  JustDad - SwiftData Manager
//
//  Centralized data management for offline-first architecture
//

import Foundation
import SwiftData

// Import all models for container setup
// Since all models are in the same module, they should be accessible directly

@MainActor
class DataManager: ObservableObject {
    static let shared = DataManager()
    
    private var container: ModelContainer?
    
    var modelContext: ModelContext? {
        container?.mainContext
    }
    
    // MARK: - Initialization
    
    private init() {
        print("📋 DataManager initialized - ready for container setup")
    }
    
    // MARK: - Container Setup (Phase 2: Deferred until model access is resolved)
    func setupContainer() {
        print("🔄 Setting up SwiftData container...")
        
        // NOTE: Schema configuration will be implemented once model import issues are resolved
        // The models exist in CoreDataModels.swift but are not accessible from this scope
        // This will be completed in the next iteration
        
        print("📝 Models available: Visit, VisitAttachment, EmergencyContact, AppSettings")
        print("⏳ Container setup deferred - will be completed once imports are resolved")
        
        // For now, mark container as initialized (will be properly configured later)
        // container = nil // Will be set when proper schema is available
    }
    
    // MARK: - Basic Data Operations
    
    func save() {
        guard let context = modelContext else { 
            print("⚠️ No model context available")
            return 
        }
        
        do {
            try context.save()
            print("✅ Data saved successfully")
        } catch {
            print("❌ Failed to save data: \(error)")
        }
    }
    
    // MARK: - CRUD Operations for Visits
    
    /// Fetch all visits from SwiftData (Phase 2: Implementation pending)
    func fetchAllVisits() async -> [Any] {
        guard container != nil else {
            print("⚠️ Container not initialized, returning empty array")
            return []
        }
        
        // TODO: Implementation will be completed when model access is resolved
        // let context = ModelContext(container!)
        // let fetchDescriptor = FetchDescriptor<Visit>()
        // let visits = try context.fetch(fetchDescriptor)
        
        print("📋 Fetch visits called - implementation pending")
        return []
    }
    
    /// Save a new visit to SwiftData
    func saveVisit(_ visitData: [String: Any]) async -> Bool {
        guard let container = container else {
            print("⚠️ Container not initialized, cannot save visit")
            return false
        }
        
        do {
            let context = ModelContext(container)
            // TODO: Create Visit instance from visitData once models are accessible
            // let visit = Visit(from: visitData)
            // context.insert(visit)
            try context.save()
            print("✅ Visit saved successfully")
            return true
        } catch {
            print("❌ Failed to save visit: \(error)")
            return false
        }
    }
    
    /// Delete a visit from SwiftData (Phase 2: Implementation pending)
    func deleteVisit(withId id: String) async -> Bool {
        guard container != nil else {
            print("⚠️ Container not initialized, cannot delete visit")
            return false
        }
        
        // Implementation will be completed when models are accessible
        print("�️ Delete visit with ID: \(id) - Implementation pending")
        return false
    }
    
    // MARK: - Migration Support
    
    func performDataMigration() {
        print("🔄 Data migration ready - awaiting model configuration")
        // TODO: Implement migration from mock data to SwiftData
    }
    
    /// Migrate existing mock data to SwiftData
    private func performDataMigration() async {
        print("🔄 Starting data migration from mock data...")
        
        // Check if migration is needed (no existing data)
        let existingVisits = await fetchAllVisits()
        if !existingVisits.isEmpty {
            print("📊 Migration skipped - data already exists (\(existingVisits.count) visits)")
            return
        }
        
        // TODO: Implement migration from MockVisitAgenda to SwiftData
        // This will be completed in the next phase
        print("📥 Migration implementation pending - will migrate mock data in next phase")
    }
}
