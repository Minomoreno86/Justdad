//
//  UnifiedJournalEntryDetailView.swift
//  JustDad - Unified Journal Entry Detail View
//
//  Detailed view for viewing, editing, and managing individual journal entries.
//

import SwiftUI
import AVFoundation

struct UnifiedJournalEntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var journalingService = UnifiedJournalingService()
    
    let entry: UnifiedJournalEntry
    
    @State private var isEditing = false
    @State private var editedContent = ""
    @State private var editedTitle = ""
    @State private var editedTags: Set<String> = []
    @State private var showingDeleteAlert = false
    @State private var showingShareSheet = false
    @State private var shareText = ""
    
    private var entryIcon: String {
        switch entry.type {
        case .intelligent(let emotion, _):
            return emotion.icon
        case .traditional(_):
            return "book.closed.fill"
        }
    }
    
    private var entryColor: Color {
        switch entry.type {
        case .intelligent(let emotion, _):
            return emotion.color
        case .traditional(_):
            return .blue
        }
    }
    
    private var entryTitle: String {
        switch entry.type {
        case .intelligent(let emotion, let prompt):
            return prompt.text ?? emotion.displayName
        case .traditional(let title):
            return title ?? "Entrada tradicional"
        }
    }
    
    private var entrySubtitle: String {
        switch entry.type {
        case .intelligent(let emotion, _):
            return "Journaling Inteligente • \(emotion.displayName)"
        case .traditional(_):
            return "Journaling Tradicional"
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: entry.date)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Card
                    headerCard
                    
                    // Content Card
                    contentCard
                    
                    // Tags Card
                    if !entry.tags.isEmpty {
                        tagsCard
                    }
                    
                    // Media Card
                    if entry.audioURLString != nil || !entry.photoURLStrings.isEmpty {
                        mediaCard
                    }
                    
                    // Metadata Card
                    metadataCard
                }
                .padding()
            }
            .navigationTitle("Entrada del Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        router.pop()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { isEditing = true }) {
                            Label("Editar", systemImage: "pencil")
                        }
                        
                        Button(action: { prepareShareContent() }) {
                            Label("Compartir", systemImage: "square.and.arrow.up")
                        }
                        
                        Divider()
                        
                        Button(action: { showingDeleteAlert = true }) {
                            Label("Eliminar", systemImage: "trash")
                        }
                        .foregroundColor(.red)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            editEntrySheet
        }
        .sheet(isPresented: $showingShareSheet) {
            JournalShareSheet(items: [shareText])
        }
        .alert("Eliminar entrada", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                deleteEntry()
            }
        } message: {
            Text("¿Estás seguro de que quieres eliminar esta entrada? Esta acción no se puede deshacer.")
        }
        .onAppear {
            editedContent = entry.content
            editedTitle = entry.title ?? ""
            editedTags = Set(entry.tags)
        }
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: entryIcon)
                    .font(.title)
                    .foregroundColor(entryColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(entryTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(entrySubtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if entry.isEncrypted {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(entryColor.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(entryColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Content Card
    private var contentCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contenido")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(entry.content)
                .font(.body)
                .foregroundColor(.primary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
    
    // MARK: - Tags Card
    private var tagsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Etiquetas")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(entry.tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.blue.opacity(0.1))
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
    
    // MARK: - Media Card
    private var mediaCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Multimedia")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                // Audio Player
                if entry.audioURLString != nil {
                    audioPlayerView
                }
                
                // Photos
                if !entry.photoURLStrings.isEmpty {
                    photosView
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
    
    // MARK: - Audio Player View
    private var audioPlayerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Nota de voz")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            HStack {
                Button(action: {
                    if journalingService.isPlaying && journalingService.currentPlayingEntry?.id == entry.id {
                        journalingService.stopAudio()
                    } else {
                        journalingService.playAudio(for: entry)
                    }
                }) {
                    Image(systemName: journalingService.isPlaying && journalingService.currentPlayingEntry?.id == entry.id ? 
                          "stop.fill" : "play.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.blue)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Grabación de voz")
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    if journalingService.isPlaying && journalingService.currentPlayingEntry?.id == entry.id {
                        Text("Reproduciendo...")
                            .font(.caption)
                            .foregroundColor(.blue)
                    } else {
                        Text("Toca para reproducir")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Photos View
    private var photosView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Fotos (\(entry.photoURLStrings.count))")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(entry.photoURLStrings, id: \.self) { photoURLString in
                        if let photoURL = URL(string: photoURLString) {
                            AsyncImage(url: photoURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color(.systemGray5))
                                    .overlay(
                                        ProgressView()
                                    )
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(.horizontal, 1)
            }
        }
    }
    
    // MARK: - Metadata Card
    private var metadataCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Información")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                metadataRow(title: "Creado", value: entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                metadataRow(title: "Actualizado", value: entry.updatedAt.formatted(date: .abbreviated, time: .shortened))
                metadataRow(title: "ID", value: entry.id.uuidString)
                metadataRow(title: "Encriptado", value: entry.isEncrypted ? "Sí" : "No")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
    
    private func metadataRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .foregroundColor(.primary)
                .fontWeight(.medium)
        }
    }
    
    // MARK: - Edit Entry Sheet
    private var editEntrySheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Título")
                        .font(.headline)
                    
                    TextField("Título de la entrada", text: $editedTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Contenido")
                        .font(.headline)
                    
                    TextEditor(text: $editedContent)
                        .frame(minHeight: 200)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(UIColor.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                        )
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Editar entrada")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        isEditing = false
                        editedContent = entry.content
                        editedTitle = entry.title ?? ""
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func saveChanges() {
        // Update the existing entry directly
        entry.content = editedContent
        entry.title = editedTitle.isEmpty ? nil : editedTitle
        entry.tags = Array(editedTags)
        entry.updatedAt = Date()
        
        journalingService.updateEntry(entry)
        isEditing = false
    }
    
    private func deleteEntry() {
        journalingService.deleteEntry(entry)
        router.pop()
    }
    
    private func prepareShareContent() {
        var content = ""
        
        if let title = entry.title, !title.isEmpty {
            content += "\(title)\n\n"
        }
        
        content += entry.content
        
        if !entry.tags.isEmpty {
            content += "\n\nEtiquetas: \(entry.tags.map { "#\($0)" }.joined(separator: " "))"
        }
        
        content += "\n\nCompartido desde JustDad"
        
        shareText = content
        showingShareSheet = true
    }
}

// MARK: - Share Sheet
struct JournalShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    UnifiedJournalEntryDetailView(
        entry: UnifiedJournalEntry(
            emotion: .happy,
            prompt: JournalPrompt(text: "¿Qué te hizo sonreír hoy?", category: .gratitude, estimatedTime: "5 min"),
            content: "Hoy fue un día increíble. Fuimos al parque con los niños y jugamos fútbol. Ver sus sonrisas me llenó el corazón de alegría. Esos momentos son los que realmente importan en la vida.",
            tags: ["familia", "parque", "diversión", "gratitud"]
        )
    )
}
