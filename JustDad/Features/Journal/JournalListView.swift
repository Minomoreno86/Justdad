//
//  JournalListView.swift
//  JustDad - Journal list screen
//
//  Display journal entries with mood tracking
//

import SwiftUI

struct JournalListView: View {
    @StateObject private var router = NavigationRouter.shared
    @State private var searchText = ""
    
    private var entries: [MockJournalEntry] {
        MockData.journal
    }
    
    private var filteredEntries: [MockJournalEntry] {
        if searchText.isEmpty {
            return entries
        } else {
            return entries.filter { entry in
                entry.title.localizedCaseInsensitiveContains(searchText) ||
                entry.content.localizedCaseInsensitiveContains(searchText)
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
                    // Search bar
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
                                router.push(.journalDetail(entryId: entry.id.uuidString))
                            }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { router.push(.journalNew) }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

// MARK: - Journal Entry Row
struct JournalEntryRow: View {
    let entry: MockJournalEntry
    
    private var moodEmoji: String {
        switch entry.mood {
        case .happy: return "😊"
        case .neutral: return "😐"
        case .stressed: return "😔"
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.title)
                        .font(Typography.headline)
                        .foregroundColor(Palette.textPrimary)
                    
                    Spacer()
                    
                    Text(moodEmoji)
                        .font(.title2)
                }
                
                Text(entry.content)
                    .font(Typography.body)
                    .foregroundColor(Palette.textSecondary)
                    .lineLimit(2)
                
                HStack {
                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                        .font(Typography.caption)
                        .foregroundColor(Palette.textSecondary)
                    
                    Spacer()
                    
                    ForEach(entry.tags.prefix(2), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(Typography.caption)
                            .foregroundColor(Palette.primary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: entry.kind.iconName)
                .foregroundColor(Palette.primary)
                .font(.title3)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Kind Extension
extension MockJournalEntry.Kind {
    var iconName: String {
        switch self {
        case .text: return "doc.text"
        case .audio: return "waveform"
        case .photo: return "photo"
        }
    }
}

#Preview {
    JournalListView()
}