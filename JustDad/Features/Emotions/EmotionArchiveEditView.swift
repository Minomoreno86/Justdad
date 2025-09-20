//
//  EmotionArchiveEditView.swift
//  JustDad - Emotion Archive Edit View
//
//  Vista para editar entradas existentes del archivo de emociones.
//

import SwiftUI

struct EmotionArchiveEditView: View {
    @State private var editedEntry: JournalEntry
    let onSave: (JournalEntry) -> Void
    @Environment(\.dismiss) private var dismiss
    
    init(entry: JournalEntry, onSave: @escaping (JournalEntry) -> Void) {
        self._editedEntry = State(initialValue: entry)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Emotion info (read-only)
                    emotionInfoSection
                    
                    // Content editing
                    contentSection
                    
                    // Tags editing
                    tagsSection
                    
                    // Audio section
                    audioSection
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("Editar Entrada")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
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
    
    // MARK: - Emotion Info Section
    private var emotionInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Estado Emocional")
                .font(.headline)
            
            HStack(spacing: 12) {
                emotionIcon
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(emotionText)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Prompt: \(editedEntry.prompt.text)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
                
                Spacer()
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contenido")
                .font(.headline)
            
            TextEditor(text: $editedEntry.content)
                .frame(minHeight: 200)
                .padding(12)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                )
            
            // Word count
            HStack {
                Spacer()
                Text("\(editedEntry.content.split(separator: " ").count) palabras")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Tags Section
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Etiquetas")
                .font(.headline)
            
            // Current tags
            if !editedEntry.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(editedEntry.tags, id: \.self) { tag in
                            HStack(spacing: 4) {
                                Text("#\(tag)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                
                                Button {
                                    removeTag(tag)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            
            // Add new tag
            HStack {
                TextField("Agregar etiqueta", text: $newTag)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Agregar") {
                    addTag()
                }
                .disabled(newTag.isEmpty)
            }
        }
    }
    
    // MARK: - Audio Section
    private var audioSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Audio")
                .font(.headline)
            
            HStack {
                if editedEntry.hasAudio {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "waveform")
                                .foregroundColor(.blue)
                            
                            Text("Audio adjunto")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Button("Eliminar") {
                                removeAudio()
                            }
                            .font(.caption)
                            .foregroundColor(.red)
                        }
                        
                        Button("Reproducir") {
                            playAudio()
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "mic")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("No hay audio adjunto")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    @State private var newTag = ""
    
    private var emotionIcon: some View {
        Group {
            switch editedEntry.emotion {
            case .verySad:
                Image(systemName: "face.dashed.fill")
                    .foregroundColor(.purple)
            case .sad:
                Image(systemName: "face.dashed")
                    .foregroundColor(.blue)
            case .neutral:
                Image(systemName: "face.smiling")
                    .foregroundColor(.gray)
            case .happy:
                Image(systemName: "face.smiling.fill")
                    .foregroundColor(.green)
            case .veryHappy:
                Image(systemName: "face.smiling.inverse")
                    .foregroundColor(.yellow)
            }
        }
        .font(.title2)
    }
    
    private var emotionText: String {
        switch editedEntry.emotion {
        case .verySad: return "Muy Triste"
        case .sad: return "Triste"
        case .neutral: return "Neutral"
        case .happy: return "Feliz"
        case .veryHappy: return "Muy Feliz"
        }
    }
    
    // MARK: - Actions
    
    private func saveChanges() {
        // Update the entry with current changes
        editedEntry.date = Date() // Update modification date
        onSave(editedEntry)
        dismiss()
    }
    
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !editedEntry.tags.contains(trimmedTag) {
            editedEntry.tags.append(trimmedTag)
            newTag = ""
        }
    }
    
    private func removeTag(_ tag: String) {
        editedEntry.tags.removeAll { $0 == tag }
    }
    
    private func removeAudio() {
        editedEntry.audioURLString = nil
        // TODO: Remove actual audio file
    }
    
    private func playAudio() {
        // TODO: Implement audio playback
    }
}

#Preview {
    EmotionArchiveEditView(
        entry: JournalEntry(
            emotion: .happy,
            prompt: JournalPrompt(
                text: "¿Qué te hizo sonreír hoy?",
                category: .gratitude,
                estimatedTime: "5 min"
            ),
            content: "Hoy fue un día increíble. Fuimos al parque con los niños y jugamos fútbol. Ver sus sonrisas me llenó el corazón de alegría.",
            tags: ["familia", "parque"]
        )
    ) { _ in }
}
