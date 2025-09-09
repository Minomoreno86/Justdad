//
//  DiaryView.swift
//  SoloPapá - Private diary
//
//  Private encrypted diary entries (text, audio, photos)
//

import SwiftUI

struct DiaryView: View {
    @State private var showingNewEntrySheet = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Buscar en tu diario...", text: $searchText)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Entries list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Placeholder entries
                        DiaryEntryCard(
                            title: "Un día especial con los niños",
                            date: "Hoy, 14:30",
                            preview: "Fuimos al parque y jugamos fútbol. Ver sus sonrisas me llenó el corazón...",
                            hasAudio: false,
                            hasPhotos: true,
                            moodEmoji: "😊"
                        )
                        
                        DiaryEntryCard(
                            title: "Reflexiones nocturnas",
                            date: "Ayer, 22:15",
                            preview: "A veces siento que no soy suficiente, pero luego recuerdo todos los pequeños momentos...",
                            hasAudio: true,
                            hasPhotos: false,
                            moodEmoji: "😔"
                        )
                        
                        DiaryEntryCard(
                            title: "Nueva rutina",
                            date: "2 días, 16:45",
                            preview: "Decidí empezar a hacer ejercicio en las mañanas. Necesito cuidar mi salud mental y física...",
                            hasAudio: false,
                            hasPhotos: false,
                            moodEmoji: "💪"
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                
                Spacer()
            }
            .navigationTitle("Mi Diario")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewEntrySheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewEntrySheet) {
                NewDiaryEntrySheet()
            }
        }
    }
}

// MARK: - Diary Entry Card
struct DiaryEntryCard: View {
    let title: String
    let date: String
    let preview: String
    let hasAudio: Bool
    let hasPhotos: Bool
    let moodEmoji: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(moodEmoji)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    if hasAudio {
                        Image(systemName: "waveform")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    if hasPhotos {
                        Image(systemName: "photo")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            // Preview
            Text(preview)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onTapGesture {
            // TODO: Open full diary entry
        }
    }
}

// MARK: - New Diary Entry Sheet
struct NewDiaryEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var entryTitle = ""
    @State private var entryContent = ""
    @State private var selectedMood = "😐"
    
    private let moods = ["😄", "😊", "😐", "😔", "😢", "😡", "💪", "🤔"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Mood selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("¿Cómo te sientes?")
                        .font(.headline)
                    
                    HStack {
                        ForEach(moods, id: \.self) { mood in
                            Button(action: {
                                selectedMood = mood
                            }) {
                                Text(mood)
                                    .font(.title2)
                                    .padding(8)
                                    .background(selectedMood == mood ? Color.blue.opacity(0.2) : Color.clear)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Título (opcional)")
                        .font(.headline)
                    
                    TextField("Ej: Un día especial...", text: $entryTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tu entrada")
                        .font(.headline)
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $entryContent)
                            .frame(minHeight: 200)
                            .padding(4)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        if entryContent.isEmpty {
                            Text("Escribe sobre tu día, tus sentimientos, o cualquier cosa que quieras recordar...")
                                .foregroundColor(.secondary)
                                .padding(.top, 12)
                                .padding(.leading, 8)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Media options (placeholder)
                HStack {
                    Button(action: {
                        // TODO: Add photo
                    }) {
                        HStack {
                            Image(systemName: "camera")
                            Text("Foto")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Button(action: {
                        // TODO: Add audio
                    }) {
                        HStack {
                            Image(systemName: "mic")
                            Text("Audio")
                        }
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                Spacer()
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
                        // TODO: Save encrypted diary entry
                        dismiss()
                    }
                    .disabled(entryContent.isEmpty)
                }
            }
        }
    }
}

#Preview {
    DiaryView()
}
