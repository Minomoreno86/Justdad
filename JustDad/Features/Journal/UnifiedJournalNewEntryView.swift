//
//  UnifiedJournalNewEntryView.swift
//  JustDad - Unified New Journal Entry Interface
//
//  Combined interface for creating both intelligent and traditional journal entries.
//

import SwiftUI
import AVFoundation

struct UnifiedJournalNewEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var journalingService = UnifiedJournalingService()
    
    @State private var selectedMode: JournalEntryMode = .intelligent
    @State private var selectedEmotion: EmotionalState?
    @State private var currentPrompt: JournalPrompt?
    @State private var journalText = ""
    @State private var entryTitle = ""
    @State private var selectedTags: Set<String> = []
    @State private var showingEmotionPicker = false
    @State private var showingTagPicker = false
    @State private var audioURL: URL?
    @State private var microphonePermissionDenied = false
    @State private var showingPermissionAlert = false
    
    // MARK: - Available Tags
    private let availableTags = [
        "Paternidad", "Trabajo", "Familia", "Ejercicio", "Meditación",
        "Lectura", "Música", "Naturaleza", "Amigos", "Futuro",
        "Pasado", "Presente", "Gratitud", "Crecimiento", "Desafío",
        "Alegría", "Tristeza", "Ansiedad", "Paz", "Amor"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Mode Selection
                    modeSelectionView
                    
                    // Content based on selected mode
                    if selectedMode == .intelligent {
                        intelligentJournalingView
                    } else {
                        traditionalJournalingView
                    }
                    
                    // Common sections
                    audioRecordingSection
                    tagSelectionSection
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
                        saveJournalEntry()
                    }
                    .disabled(!canSave)
                }
            }
        }
        .sheet(isPresented: $showingEmotionPicker) {
            EmotionPickerView { emotion in
                selectedEmotion = emotion
                generatePrompt()
                showingEmotionPicker = false
            }
        }
        .sheet(isPresented: $showingTagPicker) {
            TagPickerView(
                availableTags: availableTags,
                selectedTags: $selectedTags
            )
        }
        .alert("Permisos del Micrófono", isPresented: $showingPermissionAlert) {
            Button("Configuración") {
                #if os(iOS)
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
                #endif
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("JustDad necesita acceso al micrófono para grabar notas de voz. Por favor, ve a Configuración y permite el acceso al micrófono.")
        }
    }
    
    // MARK: - Mode Selection View
    private var modeSelectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tipo de entrada")
                .font(.headline)
            
            HStack(spacing: 12) {
                ModeSelectionCard(
                    mode: .intelligent,
                    isSelected: selectedMode == .intelligent,
                    action: { selectedMode = .intelligent }
                )
                
                ModeSelectionCard(
                    mode: .traditional,
                    isSelected: selectedMode == .traditional,
                    action: { selectedMode = .traditional }
                )
            }
        }
    }
    
    // MARK: - Intelligent Journaling View
    private var intelligentJournalingView: some View {
        VStack(spacing: 20) {
            // Emotion Selection
            if selectedEmotion == nil {
                VStack(spacing: 16) {
                    Text("¿Cómo te sientes hoy?")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(EmotionalState.allCases) { emotion in
                            EmotionSelectionCard(emotion: emotion) {
                                selectedEmotion = emotion
                                generatePrompt()
                            }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(UIColor.systemGray6))
                )
            } else if let emotion = selectedEmotion, let prompt = currentPrompt {
                // Prompt Display
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: emotion.icon)
                            .font(.title2)
                            .foregroundColor(emotion.color)
                        
                        VStack(alignment: .leading) {
                            Text(emotion.displayName)
                                .font(.headline)
                                .foregroundColor(emotion.color)
                            
                            Text(prompt.category.title)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(prompt.estimatedTime)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(emotion.color.opacity(0.1))
                            .foregroundColor(emotion.color)
                            .cornerRadius(8)
                    }
                    
                    Text(prompt.text)
                        .font(.title3)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(emotion.color.opacity(0.1))
                )
            }
            
            // Text Input
            VStack(alignment: .leading, spacing: 12) {
                Text("Tu reflexión")
                    .font(.headline)
                
                TextEditor(text: $journalText)
                    .frame(minHeight: 200)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
        }
    }
    
    // MARK: - Traditional Journaling View
    private var traditionalJournalingView: some View {
        VStack(spacing: 20) {
            // Title Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Título (opcional)")
                    .font(.headline)
                
                TextField("Ej: Un día especial...", text: $entryTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Text Input
            VStack(alignment: .leading, spacing: 12) {
                Text("Tu entrada")
                    .font(.headline)
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $journalText)
                        .frame(minHeight: 200)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(UIColor.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    if journalText.isEmpty {
                        Text("Escribe sobre tu día, tus sentimientos, o cualquier cosa que quieras recordar...")
                            .foregroundColor(.secondary)
                            .padding(.top, 20)
                            .padding(.leading, 16)
                            .allowsHitTesting(false)
                    }
                }
            }
        }
    }
    
    // MARK: - Audio Recording Section
    private var audioRecordingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nota de voz (opcional)")
                .font(.headline)
            
            HStack {
                Button(action: {
                    if journalingService.isRecording {
                        audioURL = journalingService.stopRecording()
                    } else {
                        startVoiceRecording()
                    }
                }) {
                    HStack {
                        Image(systemName: journalingService.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text(journalingService.isRecording ? "Detener grabación" : "Grabar nota de voz")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(journalingService.isRecording ? .red : .blue)
                    )
                }
                
                if journalingService.isRecording {
                    Text(formatDuration(journalingService.recordingDuration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            if audioURL != nil {
                HStack {
                    Image(systemName: "waveform")
                        .foregroundColor(.green)
                    Text("Nota de voz guardada")
                        .font(.caption)
                        .foregroundColor(.green)
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Tag Selection Section
    private var tagSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Etiquetas")
                    .font(.headline)
                
                Spacer()
                
                Button("Seleccionar") {
                    showingTagPicker = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            if selectedTags.isEmpty {
                Text("Sin etiquetas seleccionadas")
                    .font(.body)
                    .foregroundColor(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(selectedTags), id: \.self) { tag in
                            TagChip(
                                text: tag,
                                isSelected: true,
                                color: .blue
                            ) {
                                selectedTags.remove(tag)
                            }
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var canSave: Bool {
        if selectedMode == .intelligent {
            return selectedEmotion != nil && !journalText.isEmpty
        } else {
            return !journalText.isEmpty
        }
    }
    
    // MARK: - Helper Methods
    private func generatePrompt() {
        guard let emotion = selectedEmotion else { return }
        currentPrompt = journalingService.generatePrompt(for: emotion)
    }
    
    private func saveJournalEntry() {
        let entry: UnifiedJournalEntry
        
        if selectedMode == .intelligent {
            guard let emotion = selectedEmotion, let prompt = currentPrompt else { return }
            entry = UnifiedJournalEntry(
                emotion: emotion,
                prompt: prompt,
                content: journalText,
                audioURL: audioURL,
                tags: Array(selectedTags)
            )
        } else {
            entry = UnifiedJournalEntry(
                title: entryTitle.isEmpty ? nil : entryTitle,
                content: journalText,
                mood: "general",
                audioURL: audioURL,
                tags: Array(selectedTags)
            )
        }
        
        journalingService.addEntry(entry)
        router.pop()
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startVoiceRecording() {
        journalingService.startRecording()
    }
}

// MARK: - Supporting Types and Views

enum JournalEntryMode: CaseIterable {
    case intelligent
    case traditional
    
    var displayName: String {
        switch self {
        case .intelligent: return "Inteligente"
        case .traditional: return "Tradicional"
        }
    }
    
    var description: String {
        switch self {
        case .intelligent: return "Con prompts personalizados"
        case .traditional: return "Entrada libre"
        }
    }
    
    var icon: String {
        switch self {
        case .intelligent: return "brain.head.profile"
        case .traditional: return "book.closed.fill"
        }
    }
}

struct ModeSelectionCard: View {
    let mode: JournalEntryMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: mode.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(mode.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(mode.description)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? .blue : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? .blue : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TagChip: View {
    let text: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? color : color.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color, lineWidth: isSelected ? 0 : 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Tag Picker View
struct TagPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let availableTags: [String]
    @Binding var selectedTags: Set<String>
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Selecciona las etiquetas que mejor describan tu entrada")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(availableTags, id: \.self) { tag in
                        TagChip(
                            text: tag,
                            isSelected: selectedTags.contains(tag),
                            color: .blue
                        ) {
                            if selectedTags.contains(tag) {
                                selectedTags.remove(tag)
                            } else {
                                selectedTags.insert(tag)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Etiquetas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    UnifiedJournalNewEntryView()
}
