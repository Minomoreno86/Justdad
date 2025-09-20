//
//  JournalModelContainer.swift
//  JustDad - Journal Model Container Configuration
//
//  SwiftData container configuration for journaling system
//

import Foundation
import SwiftData
import SwiftUI

public class JournalModelContainer {
    public static let shared = JournalModelContainer()
    
    private var _container: ModelContainer?
    
    private init() {}
    
    @MainActor
    public var container: ModelContainer {
        if let container = _container {
            return container
        }
        
        do {
            let schema = Schema([
                UnifiedJournalEntry.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true,
                cloudKitDatabase: .none // Disable CloudKit for now
            )
            
            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            _container = container
            print("✅ JournalModelContainer: Container initialized successfully")
            return container
        } catch {
            print("❌ JournalModelContainer: Failed to create container: \(error)")
            
            // Fallback to in-memory container
            do {
                let schema = Schema([
                    UnifiedJournalEntry.self
                ])
                
                let modelConfiguration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true
                )
                
                let container = try ModelContainer(
                    for: schema,
                    configurations: [modelConfiguration]
                )
                
                _container = container
                print("⚠️ JournalModelContainer: Using fallback in-memory container")
                return container
            } catch {
                fatalError("Failed to create fallback container: \(error)")
            }
        }
    }
    
    @MainActor
    public func reset() {
        _container = nil
        print("🔄 JournalModelContainer: Container reset")
    }
}

// MARK: - SwiftUI Environment
public struct JournalModelContainerKey: EnvironmentKey {
    public static let defaultValue: ModelContainer = {
        // Create a simple fallback container for environment key
        do {
            let schema = Schema([UnifiedJournalEntry.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to create environment container: \(error)")
        }
    }()
}

public extension EnvironmentValues {
    var journalModelContainer: ModelContainer {
        get { self[JournalModelContainerKey.self] }
        set { self[JournalModelContainerKey.self] = newValue }
    }
}

// MARK: - View Modifier
public struct JournalModelContainerModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .modelContainer(JournalModelContainer.shared.container)
            .environment(\.journalModelContainer, JournalModelContainer.shared.container)
    }
}

public extension View {
    func journalModelContainer() -> some View {
        modifier(JournalModelContainerModifier())
    }
}
