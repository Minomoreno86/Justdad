//
//  SwiftDataTestView.swift
//  JustDad - SwiftData Testing View
//
//  Simple test view to validate SwiftData integration
//

import SwiftUI
import SwiftData

struct SwiftDataTestView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var visits: [SwiftDataVisit]
    
    @State private var showingAddVisit = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(visits) { visit in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(visit.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(visit.startDate.formatted(.dateTime))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let location = visit.location {
                            Text("📍 \(location)")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        if let notes = visit.notes {
                            Text(notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteVisits)
            }
            .navigationTitle("SwiftData Test")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Visit") {
                        addSampleVisit()
                    }
                }
            }
            .overlay {
                if visits.isEmpty {
                    VStack {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("No visits yet")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("Tap 'Add Visit' to create your first visit")
                            .font(.caption)
                            .foregroundColor(.tertiary)
                    }
                }
            }
        }
    }
    
    private func addSampleVisit() {
        let newVisit = SwiftDataVisit(
            title: "Test Visit #\(visits.count + 1)",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date(),
            type: "test",
            location: "Test Location",
            notes: "This is a test visit created at \(Date().formatted(.dateTime))"
        )
        
        modelContext.insert(newVisit)
        
        do {
            try modelContext.save()
            print("✅ Visit saved successfully")
        } catch {
            print("❌ Error saving visit: \(error)")
        }
    }
    
    private func deleteVisits(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(visits[index])
            }
            
            do {
                try modelContext.save()
                print("✅ Visit deleted successfully")
            } catch {
                print("❌ Error deleting visit: \(error)")
            }
        }
    }
}
