//
//  ConflictJournalView.swift
//  JustDad - Conflict Wellness Journal
//
//  Bitácora de bienestar for conflict wellness
//

import SwiftUI

struct ConflictJournalView: View {
    @StateObject private var service = ConflictWellnessService.shared
    @State private var showingAddEntry = false
    @State private var selectedEntry: WellnessJournalEntry?
    @State private var showingExport = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Stats Section
                statsSection
                
                // Entries List
                entriesSection
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddEntry) {
            AddJournalEntryView { entry in
                service.addJournalEntry(entry)
            }
        }
        .sheet(item: $selectedEntry) { entry in
            JournalEntryDetailView(entry: entry)
        }
        .sheet(isPresented: $showingExport) {
            ExportJournalView()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Bitácora de Bienestar")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Menu {
                    Button("Exportar Datos") {
                        showingExport = true
                    }
                    
                    Button("Limpiar Todo") {
                        // TODO: Add confirmation
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            Text("Escribir libera tu mente y ayuda a detectar patrones")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(UIColor.systemBackground))
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: 16) {
            ConflictJournalStatCard(
                title: "Total Entradas",
                value: "\(service.journalEntries.count)",
                icon: "book.fill",
                color: .blue
            )
            
            ConflictJournalStatCard(
                title: "Este Mes",
                value: "\(monthlyEntries)",
                icon: "calendar",
                color: .green
            )
            
            ConflictJournalStatCard(
                title: "Promedio Emoción",
                value: String(format: "%.1f", averageEmotion),
                icon: "heart.fill",
                color: .red
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Entries Section
    private var entriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Registros Recientes")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { showingAddEntry = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            if service.journalEntries.isEmpty {
                emptyStateSection
            } else {
                entriesListSection
            }
        }
        .padding(.top)
    }
    
    private var emptyStateSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No hay entradas en tu bitácora")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Comienza registrando una interacción que te haya afectado hoy")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Agregar Primera Entrada") {
                showingAddEntry = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal)
    }
    
    private var entriesListSection: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(service.journalEntries.sorted(by: { $0.date > $1.date })) { entry in
                    ConflictJournalEntryRow(entry: entry) {
                        selectedEntry = entry
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Computed Properties
    private var monthlyEntries: Int {
        let calendar = Calendar.current
        let now = Date()
        return service.journalEntries.filter { entry in
            calendar.isDate(entry.date, equalTo: now, toGranularity: .month)
        }.count
    }
    
    private var averageEmotion: Double {
        guard !service.journalEntries.isEmpty else { return 0 }
        let sum = service.journalEntries.reduce(0) { $0 + $1.emotion }
        return Double(sum) / Double(service.journalEntries.count)
    }
}

// MARK: - Add Journal Entry View
struct AddJournalEntryView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (WellnessJournalEntry) -> Void
    
    @State private var selectedType: WellnessJournalEntry.InteractionType = .emotional
    @State private var description = ""
    @State private var emotionLevel = 3
    @State private var actionProxima = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Type Selection
                    typeSelectionSection
                    
                    // Description
                    descriptionSection
                    
                    // Emotion Level
                    emotionLevelSection
                    
                    // Next Action
                    nextActionSection
                }
                .padding()
            }
            .navigationTitle("Nueva Entrada")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveEntry()
                    }
                    .disabled(description.isEmpty || actionProxima.isEmpty)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "book.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Registra la Interacción")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Escribir sobre lo que pasó te ayuda a liberar tu mente y ver patrones")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var typeSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tipo de Interacción")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(WellnessJournalEntry.InteractionType.allCases, id: \.self) { type in
                    TypeSelectionCard(
                        type: type,
                        isSelected: selectedType == type
                    ) {
                        selectedType = type
                    }
                }
            }
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("¿Qué pasó?")
                .font(.headline)
                .fontWeight(.semibold)
            
            TextEditor(text: $description)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            Text("Describe brevemente la interacción que te afectó")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var emotionLevelSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("¿Cómo te sentiste?")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                Text("1")
                    .font(.caption)
                    .foregroundColor(.green)
                
                Slider(value: Binding(
                    get: { Double(emotionLevel) },
                    set: { emotionLevel = Int($0) }
                ), in: 1...5, step: 1)
                .tint(.blue)
                
                Text("5")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            HStack {
                Text("Tranquilo")
                    .font(.caption)
                    .foregroundColor(.green)
                
                Spacer()
                
                Text(emotionDescription)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(emotionColor)
                
                Spacer()
                
                Text("Muy Estresado")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var nextActionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("¿Qué harás distinto la próxima vez?")
                .font(.headline)
                .fontWeight(.semibold)
            
            TextEditor(text: $actionProxima)
                .frame(minHeight: 80)
                .padding(8)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            Text("Planifica una respuesta serena para situaciones similares")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var emotionDescription: String {
        switch emotionLevel {
        case 1: return "Tranquilo"
        case 2: return "Leve tensión"
        case 3: return "Moderado"
        case 4: return "Estresado"
        case 5: return "Muy estresado"
        default: return "Moderado"
        }
    }
    
    private var emotionColor: Color {
        switch emotionLevel {
        case 1: return .green
        case 2: return .yellow
        case 3: return .orange
        case 4: return .red
        case 5: return .red
        default: return .orange
        }
    }
    
    private func saveEntry() {
        let entry = WellnessJournalEntry(
            date: Date(),
            type: selectedType,
            description: description,
            emotion: emotionLevel,
            actionProxima: actionProxima
        )
        
        onSave(entry)
        dismiss()
    }
}

// MARK: - Supporting Views

struct ConflictJournalStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
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

struct TypeSelectionCard: View {
    let type: WellnessJournalEntry.InteractionType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : Color(type.color))
                
                Text(type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color(type.color) : Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ConflictJournalEntryRow: View {
    let entry: WellnessJournalEntry
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: entry.type.icon)
                        .foregroundColor(Color(entry.type.color))
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.type.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text(entry.date, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { index in
                            Circle()
                                .fill(index <= entry.emotion ? Color.red : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                
                Text(entry.description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text("Próxima acción: \(entry.actionProxima)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct JournalEntryDetailView: View {
    let entry: WellnessJournalEntry
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Details
                    detailsSection
                }
                .padding()
            }
            .navigationTitle("Detalle de Entrada")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: entry.type.icon)
                .font(.system(size: 50))
                .foregroundColor(Color(entry.type.color))
            
            Text(entry.type.rawValue)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(entry.date, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(entry.type.color).opacity(0.1))
        .cornerRadius(16)
    }
    
    private var detailsSection: some View {
        VStack(spacing: 16) {
            DetailCard(
                title: "Descripción",
                content: entry.description
            )
            
            DetailCard(
                title: "Nivel de Emoción",
                content: emotionDescription
            )
            
            DetailCard(
                title: "Acción Futura",
                content: entry.actionProxima
            )
        }
    }
    
    private var emotionDescription: String {
        switch entry.emotion {
        case 1: return "Tranquilo - Manejo la situación con serenidad"
        case 2: return "Leve tensión - Algo de estrés pero manejable"
        case 3: return "Moderado - Nivel de estrés intermedio"
        case 4: return "Estresado - Situación difícil de manejar"
        case 5: return "Muy estresado - Necesito apoyo y estrategias"
        default: return "No especificado"
        }
    }
}

struct DetailCard: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(content)
                .font(.body)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

struct ExportJournalView: View {
    @StateObject private var service = ConflictWellnessService.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Exportar Bitácora")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Tus datos son privados y solo para tu uso personal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button("Exportar como JSON") {
                    // TODO: Implement export
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ConflictJournalView()
}
