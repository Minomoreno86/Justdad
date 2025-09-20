//
//  JournalListView.swift
//  JustDad - Journal list screen
//
//  Display journal entries with mood tracking
//

import SwiftUI

struct JournalListView: View {
    @StateObject private var router = NavigationRouter.shared
    @StateObject private var journalingService = IntelligentJournalingService.shared
    @State private var searchText = ""
    
    private var entries: [JournalEntry] {
        let sortedEntries = journalingService.journalEntries.sorted { $0.date > $1.date }
        print("📋 JournalListView - Total entries: \(sortedEntries.count)")
        return sortedEntries
    }
    
    private var filteredEntries: [JournalEntry] {
        if searchText.isEmpty {
            return entries
        } else {
            return entries.filter { entry in
                entry.prompt.text.localizedCaseInsensitiveContains(searchText) ||
                entry.content.localizedCaseInsensitiveContains(searchText) ||
                entry.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if filteredEntries.isEmpty {
                    EmptyStateView(
                        title: "No journal entries yet",
                        message: "Capture your moments with your kids or your progress.",
                        actionTitle: "New entry",
                        action: { router.push(.journalNew) }
                    )
                } else {
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search entries...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    // Entries list
                    List(filteredEntries) { entry in
                        JournalEntryRow(entry: entry)
                            .onTapGesture {
                                // TODO: Navigate to detail view
                            }
                    }
                    .listStyle(PlainListStyle())
                }
        }
        .navigationTitle("Journal")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { 
                    journalingService.loadJournalEntries()
                    print("🔄 Manual refresh - Total entries: \(journalingService.journalEntries.count)")
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { router.push(.journalNew) }) {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            print("🔄 JournalListView appeared - Total entries: \(journalingService.journalEntries.count)")
            journalingService.loadJournalEntries()
        }
        }
    }
}

// MARK: - Journal Entry Row
struct JournalEntryRow: View {
    let entry: JournalEntry
    
    private var moodEmoji: String {
        switch entry.emotion {
        case .verySad: return "😢"
        case .sad: return "😔"
        case .neutral: return "😐"
        case .happy: return "😊"
        case .veryHappy: return "🎉"
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.prompt.text)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(moodEmoji)
                        .font(.title2)
                }
                
                Text(entry.content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if entry.audioURL != nil {
                        Image(systemName: "waveform")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    ForEach(entry.tags.prefix(2), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: entry.prompt.category.icon)
                .foregroundColor(entry.prompt.category.color)
                .font(.title3)
        }
        .padding(.vertical, 8)
    }
}