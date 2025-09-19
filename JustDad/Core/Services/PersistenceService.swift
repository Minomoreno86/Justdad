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
            // Create a model container with all required models
            let schema = Schema([
                Visit.self,
                VisitAttachment.self,
                EmergencyContact.self,
                AppSettings.self,
                FinancialEntry.self,
                ReceiptAttachment.self,
                EmotionalEntry.self,
                DiaryEntry.self,
                DiaryAttachment.self,
                CommunityPost.self,
                UserPreferences.self
            ])
            
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
    
    func saveFinancialEntry(_ entry: FinancialEntry) async throws {
        modelContext.insert(entry)
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