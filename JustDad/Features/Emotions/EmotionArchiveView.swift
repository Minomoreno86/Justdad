//
//  EmotionArchiveView.swift
//  JustDad - Emotion Archive View
//
//  Vista principal del archivo de emociones con funcionalidad completa de editar y borrar.
//

import SwiftUI
import SwiftData

#if os(iOS)
import UIKit
#endif

struct EmotionArchiveView: View {
    @StateObject private var journalingService = IntelligentJournalingService.shared
    @State private var searchText = ""
    @State private var selectedFilter: EmotionFilter = .all
    @State private var showingDeleteAlert = false
    @State private var entryToDelete: JournalEntry?
    @State private var showingEditSheet = false
    @State private var entryToEdit: JournalEntry?
    
    enum EmotionFilter: String, CaseIterable {
        case all = "Todas"
        case verySad = "Muy Triste"
        case sad = "Triste"
        case neutral = "Neutral"
        case happy = "Feliz"
        case veryHappy = "Muy Feliz"
        
        var emotion: EmotionalState? {
            switch self {
            case .all: return nil
            case .verySad: return .verySad
            case .sad: return .sad
            case .neutral: return .neutral
            case .happy: return .happy
            case .veryHappy: return .veryHappy
            }
        }
    }
    
    var filteredEntries: [JournalEntry] {
        var entries = journalingService.journalEntries
        
        // Filter by emotion
        if let emotion = selectedFilter.emotion {
            entries = entries.filter { entry in
                entry.emotion == emotion
            }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            entries = entries.filter { entry in
                entry.content.localizedCaseInsensitiveContains(searchText) ||
                entry.prompt.text.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort by date (newest first)
        return entries.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with statistics
            headerView
            
            // Search and filter bar
            searchAndFilterView
            
            // Content
            if journalingService.journalEntries.isEmpty {
                emptyStateView
            } else if filteredEntries.isEmpty {
                noResultsView
            } else {
                entriesListView
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Exportar todo", action: exportAllEntries)
                    Button("Limpiar archivo", action: clearArchive)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Eliminar entrada", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                if let entry = entryToDelete {
                    deleteEntry(entry)
                }
            }
        } message: {
            Text("¿Estás seguro de que quieres eliminar esta entrada? Esta acción no se puede deshacer.")
        }
        .sheet(isPresented: $showingEditSheet) {
            if let entry = entryToEdit {
                EmotionArchiveEditView(entry: entry) { updatedEntry in
                    updateEntry(updatedEntry)
                }
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(journalingService.journalEntries.count)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Entradas totales")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(journalingService.journalEntries.count > 0 ? journalingService.journalEntries.count : 0)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("Este mes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            // Quick stats
            HStack(spacing: 16) {
                EmotionArchiveStatCard(
                    title: "Racha actual",
                    value: "\(currentStreak)",
                    icon: "flame.fill",
                    color: .orange
                )
                
                EmotionArchiveStatCard(
                    title: "Emoción frecuente",
                    value: mostFrequentEmotion,
                    icon: "heart.fill",
                    color: .pink
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    // MARK: - Search and Filter View
    private var searchAndFilterView: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Buscar en entradas...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button("Limpiar") {
                        searchText = ""
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            
            // Filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(EmotionFilter.allCases, id: \.self) { filter in
                        EmotionArchiveFilterChip(
                            title: filter.rawValue,
                            isSelected: selectedFilter == filter,
                            action: { selectedFilter = filter }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(Color(UIColor.systemBackground))
    }
    
    // MARK: - Entries List View
    private var entriesListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredEntries) { entry in
                    EmotionArchiveEntryCard(
                        entry: entry,
                        onEdit: { entryToEdit = entry; showingEditSheet = true },
                        onDelete: { entryToDelete = entry; showingDeleteAlert = true }
                    )
                }
            }
            .padding()
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "archivebox")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No hay entradas en el archivo")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Las entradas de tu journaling aparecerán aquí")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Ir a Journaling") {
                // Navigate to journaling tab
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - No Results View
    private var noResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No se encontraron resultados")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Intenta con otros términos de búsqueda o filtros")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Computed Properties
    private var currentStreak: Int {
        // Calculate current streak logic
        return 0 // Placeholder
    }
    
    private var mostFrequentEmotion: String {
        let emotionCounts = Dictionary(grouping: journalingService.journalEntries, by: { $0.emotion })
            .mapValues { $0.count }
        
        if let mostFrequent = emotionCounts.max(by: { $0.value < $1.value }) {
            switch mostFrequent.key {
            case .verySad: return "Muy Triste"
            case .sad: return "Triste"
            case .neutral: return "Neutral"
            case .happy: return "Feliz"
            case .veryHappy: return "Muy Feliz"
            }
        }
        return "N/A"
    }
    
    // MARK: - Actions
    private func deleteEntry(_ entry: JournalEntry) {
        journalingService.deleteEntry(entry)
        entryToDelete = nil
    }
    
    private func updateEntry(_ entry: JournalEntry) {
        journalingService.updateEntry(entry)
        entryToEdit = nil
    }
    
    private func exportAllEntries() {
        // Export functionality
    }
    
    private func clearArchive() {
        // Clear archive functionality
    }
}

// MARK: - Supporting Views

struct EmotionArchiveStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

struct EmotionArchiveFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? .blue : Color(UIColor.systemGray5))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    EmotionArchiveView()
}