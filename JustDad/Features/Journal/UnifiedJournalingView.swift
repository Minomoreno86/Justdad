//
//  UnifiedJournalingView.swift
//  JustDad - Unified Journaling Interface
//
//  Combines both intelligent and traditional journaling into a single, cohesive experience.
//

import SwiftUI
import SwiftData

struct UnifiedJournalingView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var journalingService = UnifiedJournalingService()
    
    @State private var searchText = ""
    @State private var selectedFilter: JournalFilter = .all
    
    // MARK: - Computed Properties
    private var filteredEntries: [UnifiedJournalEntry] {
        var entries = journalingService.entries
        
        // Filter by search text
        if !searchText.isEmpty {
            entries = entries.filter { entry in
                entry.content.localizedCaseInsensitiveContains(searchText) ||
                entry.title?.localizedCaseInsensitiveContains(searchText) == true ||
                entry.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Filter by selected filter
        switch selectedFilter {
        case .all:
            break
        case .intelligent:
            entries = entries.filter { entry in
                switch entry.type {
                case .intelligent(_, _):
                    return true
                case .traditional(_):
                    return false
                }
            }
        case .traditional:
            entries = entries.filter { entry in
                switch entry.type {
                case .intelligent(_, _):
                    return false
                case .traditional(_):
                    return true
                }
            }
        case .emotion(let emotion):
            entries = entries.filter { entry in
                switch entry.type {
                case .intelligent(let entryEmotion, _):
                    return entryEmotion == emotion
                case .traditional(_):
                    return false
                }
            }
        case .withAudio:
            entries = entries.filter { $0.audioURLString != nil }
        case .withPhotos:
            entries = entries.filter { !$0.photoURLStrings.isEmpty }
        }
        
        return entries.sorted { $0.date > $1.date }
    }
    
    private var statisticsCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Estadísticas")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Ver más") {
                    // TODO: Navigate to detailed statistics
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            HStack(spacing: 20) {
                StatisticCard(
                    title: "Total",
                    value: "\(journalingService.statistics?.totalEntries ?? 0)",
                    icon: "book.fill",
                    color: .blue
                )
                
                StatisticCard(
                    title: "Esta semana",
                    value: "\(weeklyEntriesCount)",
                    icon: "calendar",
                    color: .green
                )
                
                StatisticCard(
                    title: "Racha actual",
                    value: "\(journalingService.statistics?.currentStreak ?? 0) días",
                    icon: "heart.fill",
                    color: .red
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemGray6))
        )
    }
    
    private var weeklyEntriesCount: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return filteredEntries.filter { $0.date >= weekAgo }.count
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if journalingService.isLoading {
                    VStack {
                        ProgressView()
                        Text("Cargando entradas...")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                } else if filteredEntries.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text(searchText.isEmpty ? "No hay entradas aún" : "Sin resultados")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(searchText.isEmpty ? 
                            "Comienza tu viaje de reflexión creando tu primera entrada de journal." :
                            "Intenta con otros términos de búsqueda o filtros.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(searchText.isEmpty ? "Nueva entrada" : "Limpiar búsqueda") {
                            if searchText.isEmpty {
                                router.push(.unifiedJournalNew)
                            } else {
                                searchText = ""
                                selectedFilter = .all
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Statistics Card
                            statisticsCard
                                .padding(.horizontal)
                                .padding(.top)
                            
                            // Search and Filter Bar
                            searchAndFilterBar
                                .padding(.horizontal)
                            
                            // Entries List
                            LazyVStack(spacing: 12) {
                                ForEach(filteredEntries) { entry in
                                    UnifiedJournalEntryCard(entry: entry) {
                                        router.push(.unifiedJournalDetail(entryId: entry.id.uuidString))
                                    }
                                    .onTapGesture {
                                        router.push(.unifiedJournalDetail(entryId: entry.id.uuidString))
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 100) // Space for floating button
                        }
                    }
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { router.push(.unifiedJournalNew) }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.blue, .purple],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                                )
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Mi Journal")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { router.push(.unifiedJournalFilter) }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .onAppear {
            journalingService.loadEntries()
        }
        .refreshable {
            journalingService.loadEntries()
            journalingService.loadStatistics()
        }
    }
    
    // MARK: - Search and Filter Bar
    private var searchAndFilterBar: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Buscar en entradas...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemGray6))
            )
            
            // Filter Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    JournalFilterChip(
                        title: "Todos",
                        isSelected: selectedFilter == .all,
                        action: { selectedFilter = .all }
                    )
                    
                    JournalFilterChip(
                        title: "Inteligente",
                        isSelected: selectedFilter == .intelligent,
                        action: { selectedFilter = .intelligent }
                    )
                    
                    JournalFilterChip(
                        title: "Tradicional",
                        isSelected: selectedFilter == .traditional,
                        action: { selectedFilter = .traditional }
                    )
                    
                    JournalFilterChip(
                        title: "Con audio",
                        isSelected: selectedFilter == .withAudio,
                        action: { selectedFilter = .withAudio }
                    )
                    
                    JournalFilterChip(
                        title: "Con fotos",
                        isSelected: selectedFilter == .withPhotos,
                        action: { selectedFilter = .withPhotos }
                    )
                    
                    // Emotion filters
                    ForEach(EmotionalState.allCases) { emotion in
                        JournalFilterChip(
                            title: emotion.displayName,
                            isSelected: selectedFilter == .emotion(emotion),
                            action: { selectedFilter = .emotion(emotion) }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Supporting Views

struct StatisticCard: View {
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
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct JournalFilterChip: View {
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
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? .blue : Color(.systemGray5))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Journal Filter
enum JournalFilter: Equatable, Hashable {
    case all
    case intelligent
    case traditional
    case emotion(EmotionalState)
    case withAudio
    case withPhotos
    
    var displayName: String {
        switch self {
        case .all: return "Todos"
        case .intelligent: return "Inteligente"
        case .traditional: return "Tradicional"
        case .emotion(let emotion): return emotion.displayName
        case .withAudio: return "Con audio"
        case .withPhotos: return "Con fotos"
        }
    }
}

#Preview {
    UnifiedJournalingView()
}
