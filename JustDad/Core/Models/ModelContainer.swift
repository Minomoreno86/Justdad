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
            CustomCategory.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        _container = try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )
        
        print("✅ SwiftData container initialized successfully")
    }
    
    func getContext() -> ModelContext? {
        guard let container = _container else {
            print("❌ Container not initialized")
            return nil
        }
        return ModelContext(container)
    }
}
