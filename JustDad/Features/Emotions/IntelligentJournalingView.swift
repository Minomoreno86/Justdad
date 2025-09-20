//
//  IntelligentJournalingView.swift
//  JustDad - Smart Journaling Interface
//
//  Intelligent prompts and voice notes for emotional reflection
//

import SwiftUI
import AVFoundation

#if os(iOS)
import UIKit
#endif


struct IntelligentJournalingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var journalingService = IntelligentJournalingService.shared
    
    @State private var selectedEmotion: EmotionalState?
    @State private var currentPrompt: JournalPrompt?
    @State private var journalText = ""
    @State private var selectedTags: Set<String> = []
    @State private var showingEmotionPicker = false
    @State private var showingVoiceRecorder = false
    @State private var audioURL: URL?
    @State private var microphonePermissionDenied = false
    @State private var showingPermissionAlert = false
    @State private var selectedTab = 0
    
    let context: JournalContext?
    
    init(context: JournalContext? = nil) {
        self.context = context
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab selector
                Picker("Pestañas", selection: $selectedTab) {
                    Text("Journal").tag(0)
                    Text("Archivo").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Content based on selected tab
                if selectedTab == 0 {
                    journalingTabView
                } else {
                    EmotionArchiveView()
                }
            }
            .navigationTitle("Journaling Inteligente")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                journalingService.loadJournalEntries()
                print("🔄 IntelligentJournalingView appeared - Total entries: \(journalingService.journalEntries.count)")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                if selectedTab == 0 && currentPrompt != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Guardar") {
                            saveJournalEntry()
                        }
                        .disabled(journalText.isEmpty)
                    }
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
        .sheet(isPresented: $showingVoiceRecorder) {
            VoiceRecorderView { url in
                audioURL = url
                showingVoiceRecorder = false
            }
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
        .onAppear {
            if let context = context {
                // Auto-generate prompt based on context
                if let emotion = getEmotionFromContext(context) {
                    selectedEmotion = emotion
                    generatePrompt()
                }
            }
        }
    }
    
    // MARK: - Journaling Tab View
    private var journalingTabView: some View {
        VStack(spacing: 0) {
            if currentPrompt == nil {
                emotionSelectionView
            } else {
                journalingInterface
            }
        }
    }
    
    private var emotionSelectionView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "book.pages.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("¿Cómo te sientes hoy?")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Selecciona tu estado emocional para recibir un prompt personalizado")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            
            // Quick access to archive
            if !journalingService.journalEntries.isEmpty {
                Button(action: {
                    selectedTab = 1 // Switch to Archive tab
                }) {
                    HStack {
                        Image(systemName: "archivebox.fill")
                            .foregroundColor(.orange)
                        Text("Ver Archivo (\(journalingService.journalEntries.count) entradas)")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(EmotionalState.allCases) { emotion in
                    EmotionSelectionCard(emotion: emotion) {
                        selectedEmotion = emotion
                        generatePrompt()
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private var journalingInterface: some View {
        VStack(spacing: 0) {
            // Prompt Header
            if let prompt = currentPrompt, let emotion = selectedEmotion {
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
                .padding(.horizontal)
                .padding(.top)
            }
            
            
            // Journaling Interface
            ScrollView {
                VStack(spacing: 20) {
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
                    
                    // Voice Recording
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Nota de voz (opcional)")
                            .font(.headline)
                        
                        HStack {
                            Button(action: {
                                if journalingService.isRecording {
                                    audioURL = journalingService.stopRecording()
                                    print("🎤 Recording stopped. Audio URL: \(audioURL?.path ?? "nil")")
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
                                
                                Button(action: {
                                    if let url = audioURL {
                                        journalingService.playAudioFromURL(url)
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: journalingService.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                            .font(.caption)
                                        Text(journalingService.isPlaying ? "Reproduciendo" : "Reproducir")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.blue)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    // Tags
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Etiquetas (opcional)")
                            .font(.headline)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach(availableTags, id: \.self) { tag in
                                TagButton(
                                    text: tag,
                                    isSelected: selectedTags.contains(tag),
                                    color: selectedEmotion?.color ?? .blue
                                ) {
                                    toggleTag(tag)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var availableTags: [String] {
        [
            "Paternidad", "Trabajo", "Familia", "Ejercicio", "Meditación",
            "Lectura", "Música", "Naturaleza", "Amigos", "Futuro",
            "Pasado", "Presente", "Gratitud", "Crecimiento", "Desafío"
        ]
    }
    
    private func getEmotionFromContext(_ context: JournalContext) -> EmotionalState? {
        // This would be determined based on the context
        // For now, return neutral as default
        return .neutral
    }
    
    private func generatePrompt() {
        guard let emotion = selectedEmotion else { return }
        currentPrompt = journalingService.getPrompt(for: emotion, context: context)
    }
    
    private func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
    
    private func saveJournalEntry() {
        guard let emotion = selectedEmotion,
              let prompt = currentPrompt else { 
            print("❌ Cannot save: missing emotion or prompt")
            return 
        }
        
        print("💾 Saving journal entry:")
        print("   Emotion: \(emotion.displayName)")
        print("   Prompt: \(prompt.text)")
        print("   Content: \(journalText)")
        print("   Audio URL: \(audioURL?.path ?? "nil")")
        print("   Tags: \(Array(selectedTags))")
        
        let entry = JournalEntry(
            emotion: emotion,
            prompt: prompt,
            content: journalText,
            audioURL: audioURL,
            tags: Array(selectedTags)
        )
        
        journalingService.addEntry(entry)
        dismiss()
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startVoiceRecording() {
        journalingService.requestMicrophonePermission { granted in
            if granted {
                journalingService.startRecording()
            } else {
                microphonePermissionDenied = true
                showingPermissionAlert = true
            }
        }
    }
}

// MARK: - Emotion Selection Card
struct EmotionSelectionCard: View {
    let emotion: EmotionalState
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: emotion.icon)
                    .font(.title)
                    .foregroundColor(emotion.color)
                
                Text(emotion.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(emotion.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: emotion.color.opacity(0.2), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(emotion.color.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Tag Button
struct TagButton: View {
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

// MARK: - Emotion Picker View
struct EmotionPickerView: View {
    let onEmotionSelected: (EmotionalState) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Selecciona tu estado emocional")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(EmotionalState.allCases) { emotion in
                        EmotionSelectionCard(emotion: emotion) {
                            onEmotionSelected(emotion)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Estado Emocional")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Voice Recorder View
struct VoiceRecorderView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var journalingService = IntelligentJournalingService.shared
    @State private var showingPermissionAlert = false
    
    let onRecordingComplete: (URL?) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "mic.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(journalingService.isRecording ? .red : .blue)
                
                Text(journalingService.isRecording ? "Grabando..." : "Listo para grabar")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if journalingService.isRecording {
                    Text(formatDuration(journalingService.recordingDuration))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                
                Text("Toca el botón para comenzar o detener la grabación")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 20) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .buttonStyle(JournalSecondaryButtonStyle())
                    
                    Button(journalingService.isRecording ? "Detener" : "Grabar") {
                        if journalingService.isRecording {
                            let url = journalingService.stopRecording()
                            onRecordingComplete(url)
                            dismiss()
                        } else {
                            startVoiceRecording()
                        }
                    }
                    .buttonStyle(JournalPrimaryButtonStyle(color: journalingService.isRecording ? .red : .blue))
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Grabar Nota de Voz")
            .navigationBarTitleDisplayMode(.inline)
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
    }
    
    private func startVoiceRecording() {
        journalingService.requestMicrophonePermission { granted in
            if granted {
                journalingService.startRecording()
            } else {
                showingPermissionAlert = true
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Button Styles
struct JournalPrimaryButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct JournalSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.primary)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Emotion Archive Card
struct EmotionArchiveCard: View {
    let entry: JournalEntry
    @StateObject private var journalingService = IntelligentJournalingService.shared
    
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(moodEmoji)
                    .font(.title2)
                
                Spacer()
                
                if entry.audioURL != nil {
                    Button(action: {
                        if journalingService.isPlaying && journalingService.currentPlayingEntry?.id == entry.id {
                            journalingService.stopAudio()
                        } else {
                            journalingService.playAudio(for: entry)
                        }
                    }) {
                        Image(systemName: journalingService.isPlaying && journalingService.currentPlayingEntry?.id == entry.id ? "stop.fill" : "play.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Text(entry.prompt.text)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
                .foregroundColor(.primary)
            
            Text(entry.content)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .frame(width: 120, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(entry.emotion.color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(entry.emotion.color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    IntelligentJournalingView()
}
