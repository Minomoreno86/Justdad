//
//  PersistenceService.swift
//  JustDad - Data persistence service
//
//  Handles SwiftData operations and data management
//

import Foundation
import SwiftData
import Combine

@MainActor
class PersistenceService: ObservableObject {
    static let shared = PersistenceService()
    
    let modelContainer: ModelContainer
    let modelContext: ModelContext
    
    @Published var isDataLoaded = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {
        do {
            // Create a simple model container with basic schema
            let schema = Schema([])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            
            self.modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            self.modelContext = modelContainer.mainContext
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    // MARK: - Data Loading
    func loadInitialData() async {
        isLoading = true
        errorMessage = nil
        
        // Basic data loading - will be expanded later
        isDataLoaded = true
        isLoading = false
    }
    
    // MARK: - Generic Data Operations
    func save<T: PersistentModel>(_ item: T) async throws {
        modelContext.insert(item)
        try modelContext.save()
    }
    
    func delete<T: PersistentModel>(_ item: T) async throws {
        modelContext.delete(item)
        try modelContext.save()
    }
    
    func fetch<T: PersistentModel>(_ type: T.Type) throws -> [T] {
        let descriptor = FetchDescriptor<T>()
        return try modelContext.fetch(descriptor)
    }
    
    // MARK: - Data Export
    func exportAllData() async throws -> Data {
        // Simplified export - will be expanded later
        let data = ["message": "Data export not yet implemented"]
        return try JSONSerialization.data(withJSONObject: data)
    }
    
    // MARK: - Data Cleanup
    func clearAllData() async throws {
        // Simplified cleanup - will be expanded later
        try modelContext.save()
    }
}