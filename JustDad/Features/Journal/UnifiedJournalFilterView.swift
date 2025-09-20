//
//  UnifiedJournalFilterView.swift
//  JustDad - Unified Journal Filter Interface
//
//  Advanced filtering options for journal entries.
//

import SwiftUI

struct UnifiedJournalFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: NavigationRouter
    @Binding var selectedFilter: JournalFilter
    
    @State private var tempFilter: JournalFilter = .all
    @State private var dateRange: DateRange = .all
    @State private var selectedEmotions: Set<EmotionalState> = []
    @State private var selectedTags: Set<String> = []
    @State private var hasAudio: Bool? = nil
    @State private var hasPhotos: Bool? = nil
    @State private var isEncrypted: Bool? = nil
    
    private let availableTags = [
        "Paternidad", "Trabajo", "Familia", "Ejercicio", "Meditación",
        "Lectura", "Música", "Naturaleza", "Amigos", "Futuro",
        "Pasado", "Presente", "Gratitud", "Crecimiento", "Desafío"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                // Quick Filters Section
                Section("Filtros Rápidos") {
                    ForEach(QuickFilter.allCases, id: \.self) { filter in
                        Button(action: {
                            tempFilter = filter.journalFilter
                        }) {
                            HStack {
                                Image(systemName: filter.icon)
                                    .foregroundColor(filter.color)
                                
                                Text(filter.displayName)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if tempFilter == filter.journalFilter {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                // Date Range Section
                Section("Rango de Fechas") {
                    Picker("Período", selection: $dateRange) {
                        ForEach(DateRange.allCases, id: \.self) { range in
                            Text(range.displayName).tag(range)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Emotions Section
                Section("Emociones") {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(EmotionalState.allCases) { emotion in
                            EmotionFilterChip(
                                emotion: emotion,
                                isSelected: selectedEmotions.contains(emotion)
                            ) {
                                if selectedEmotions.contains(emotion) {
                                    selectedEmotions.remove(emotion)
                                } else {
                                    selectedEmotions.insert(emotion)
                                }
                            }
                        }
                    }
                }
                
                // Tags Section
                Section("Etiquetas") {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(availableTags, id: \.self) { tag in
                            TagFilterChip(
                                tag: tag,
                                isSelected: selectedTags.contains(tag)
                            ) {
                                if selectedTags.contains(tag) {
                                    selectedTags.remove(tag)
                                } else {
                                    selectedTags.insert(tag)
                                }
                            }
                        }
                    }
                }
                
                // Media Section
                Section("Contenido Multimedia") {
                    Toggle("Con audio", isOn: Binding(
                        get: { hasAudio ?? false },
                        set: { hasAudio = $0 ? true : nil }
                    ))
                    
                    Toggle("Con fotos", isOn: Binding(
                        get: { hasPhotos ?? false },
                        set: { hasPhotos = $0 ? true : nil }
                    ))
                    
                    Toggle("Encriptado", isOn: Binding(
                        get: { isEncrypted ?? false },
                        set: { isEncrypted = $0 ? true : nil }
                    ))
                }
            }
            .navigationTitle("Filtros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Limpiar") {
                        clearAllFilters()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Aplicar") {
                        applyFilters()
                        router.pop()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            tempFilter = selectedFilter
        }
    }
    
    private func clearAllFilters() {
        tempFilter = .all
        dateRange = .all
        selectedEmotions.removeAll()
        selectedTags.removeAll()
        hasAudio = nil
        hasPhotos = nil
        isEncrypted = nil
    }
    
    private func applyFilters() {
        selectedFilter = tempFilter
        // TODO: Apply additional filters when implementing advanced filtering
    }
}

// MARK: - Supporting Types

enum QuickFilter: CaseIterable {
    case all
    case intelligent
    case traditional
    case withAudio
    case withPhotos
    case thisWeek
    case thisMonth
    case happy
    case sad
    
    var displayName: String {
        switch self {
        case .all: return "Todas las entradas"
        case .intelligent: return "Journaling Inteligente"
        case .traditional: return "Journaling Tradicional"
        case .withAudio: return "Con audio"
        case .withPhotos: return "Con fotos"
        case .thisWeek: return "Esta semana"
        case .thisMonth: return "Este mes"
        case .happy: return "Entradas felices"
        case .sad: return "Entradas tristes"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .intelligent: return "brain.head.profile"
        case .traditional: return "book.closed.fill"
        case .withAudio: return "waveform"
        case .withPhotos: return "photo"
        case .thisWeek: return "calendar"
        case .thisMonth: return "calendar.badge.clock"
        case .happy: return "face.smiling"
        case .sad: return "face.dashed"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return .blue
        case .intelligent: return .purple
        case .traditional: return .green
        case .withAudio: return .orange
        case .withPhotos: return .pink
        case .thisWeek: return .cyan
        case .thisMonth: return .indigo
        case .happy: return .yellow
        case .sad: return .gray
        }
    }
    
    var journalFilter: JournalFilter {
        switch self {
        case .all: return .all
        case .intelligent: return .intelligent
        case .traditional: return .traditional
        case .withAudio: return .withAudio
        case .withPhotos: return .withPhotos
        case .happy: return .emotion(.happy)
        case .sad: return .emotion(.sad)
        default: return .all
        }
    }
}

enum DateRange: CaseIterable {
    case all
    case today
    case yesterday
    case thisWeek
    case lastWeek
    case thisMonth
    case lastMonth
    case thisYear
    case custom
    
    var displayName: String {
        switch self {
        case .all: return "Todas las fechas"
        case .today: return "Hoy"
        case .yesterday: return "Ayer"
        case .thisWeek: return "Esta semana"
        case .lastWeek: return "Semana pasada"
        case .thisMonth: return "Este mes"
        case .lastMonth: return "Mes pasado"
        case .thisYear: return "Este año"
        case .custom: return "Rango personalizado"
        }
    }
}

// MARK: - Filter Chip Views

struct EmotionFilterChip: View {
    let emotion: EmotionalState
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: emotion.icon)
                    .font(.caption)
                
                Text(emotion.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : emotion.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? emotion.color : emotion.color.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(emotion.color, lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TagFilterChip: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? .blue : Color(UIColor.systemGray5))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? .blue : .clear, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    UnifiedJournalFilterView(selectedFilter: .constant(.all))
}
