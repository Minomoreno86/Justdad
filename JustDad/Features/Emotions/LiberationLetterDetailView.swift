//
//  LiberationLetterDetailView.swift
//  JustDad - Liberation Letter Detail View
//
//  Vista detallada para leer cartas de liberación con detección de voz
//

import SwiftUI

struct LiberationLetterDetailView: View {
    let letter: LiberationLetter
    @StateObject private var liberationService = LiberationLetterService.shared
    @StateObject private var speechService = LiberationLetterSpeechService.shared
    @State private var isReading = false
    @State private var showingCompletion = false
    @State private var detectedAnchors: [String] = []
    @State private var emotionalState: EmotionalState = .neutral
    @State private var notes = ""
    @State private var sessionStartTime: Date?
    @State private var showingEmotionalStateSelection = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [letter.phase.color.opacity(0.1), .black.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if showingCompletion {
                    completionView
                } else {
                    letterContentView
                }
            }
            .navigationTitle("Día \(letter.day)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        if isReading {
                            stopReading()
                        }
                        dismiss()
                    }
                }
                
                if !showingCompletion {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(isReading ? "Pausar" : "Leer") {
                            if isReading {
                                pauseReading()
                            } else {
                                startReading()
                            }
                        }
                        .foregroundColor(letter.phase.color)
                        .disabled(speechService.isListening)
                    }
                }
            }
        }
        .onAppear {
            liberationService.startSession(for: letter.day)
        }
        .onDisappear {
            if isReading {
                stopReading()
            }
        }
    }
    
    // MARK: - Letter Content View
    private var letterContentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerView
                
                // Voice Anchors
                voiceAnchorsView
                
                // Letter Content
                letterTextView
                
                // Reading Controls
                readingControlsView
                
                Spacer(minLength: 100)
            }
            .padding()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            // Phase indicator
            HStack {
                Image(systemName: letter.phase.icon)
                    .font(.title2)
                    .foregroundColor(letter.phase.color)
                
                Text(letter.phase.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(letter.duration)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(letter.phase.color.opacity(0.1))
                    )
            }
            
            // Title
            Text(letter.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Voice Anchors View
    private var voiceAnchorsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "waveform")
                    .font(.title3)
                    .foregroundColor(letter.phase.color)
                
                Text("Anclas de Voz")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("Detectadas: \(detectedAnchors.count)/\(letter.voiceAnchors.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(letter.voiceAnchors, id: \.self) { anchor in
                    AnchorChip(
                        text: anchor,
                        isDetected: detectedAnchors.contains(anchor),
                        color: letter.phase.color
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Letter Text View
    private var letterTextView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.title3)
                    .foregroundColor(letter.phase.color)
                
                Text("Carta de Liberación")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            ScrollView {
                Text(letter.content)
                    .font(.body)
                    .lineSpacing(8)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 300)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Reading Controls View
    private var readingControlsView: some View {
        VStack(spacing: 16) {
            if isReading {
                // Reading status
                HStack {
                    Circle()
                        .fill(.green)
                        .frame(width: 12, height: 12)
                        .scaleEffect(speechService.isListening ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.5).repeatForever(), value: speechService.isListening)
                    
                    Text("Leyendo en voz alta...")
                        .font(.subheadline)
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    if let startTime = sessionStartTime {
                        Text(formatElapsedTime(Date().timeIntervalSince(startTime)))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .monospacedDigit()
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.green.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.green.opacity(0.3), lineWidth: 1)
                        )
                )
                
                // Detected anchors feedback
                if !detectedAnchors.isEmpty {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        
                        Text("Anclas detectadas: \(detectedAnchors.joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
            
            // Action buttons
            HStack(spacing: 16) {
                if !isReading && detectedAnchors.count >= 2 {
                    Button("Completar Sesión") {
                        showingCompletion = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(letter.phase.color)
                    .frame(maxWidth: .infinity)
                } else if !isReading {
                    Button("Comenzar Lectura") {
                        startReading()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(letter.phase.color)
                    .frame(maxWidth: .infinity)
                } else {
                    Button("Pausar") {
                        pauseReading()
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                    
                    Button("Detener") {
                        stopReading()
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Completion View
    private var completionView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Success animation
            ZStack {
                Circle()
                    .fill(.green.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Circle()
                    .fill(.green)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                Text("¡Sesión Completada!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Has detectado \(detectedAnchors.count) de \(letter.voiceAnchors.count) anclas de voz")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Affirmations
            VStack(spacing: 8) {
                Text("Afirmaciones")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                ForEach(letter.affirmations, id: \.self) { affirmation in
                    Text("• \(affirmation)")
                        .font(.body)
                        .foregroundColor(letter.phase.color)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(letter.phase.color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(letter.phase.color.opacity(0.3), lineWidth: 1)
                    )
            )
            
            Spacer()
            
            // Finalize button
            Button("Finalizar y Continuar") {
                completeSession()
            }
            .buttonStyle(.borderedProminent)
            .tint(letter.phase.color)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
        .padding()
    }
    
    // MARK: - Methods
    private func startReading() {
        sessionStartTime = Date()
        isReading = true
        detectedAnchors = []
        
        speechService.startListening(for: letter.voiceAnchors) { result in
            DispatchQueue.main.async {
                detectedAnchors = result.detectedAnchors
                isReading = false
                
                // Show completion if enough anchors detected
                if result.isValid {
                    showingCompletion = true
                }
            }
        }
    }
    
    private func pauseReading() {
        speechService.pauseListening()
        isReading = false
    }
    
    private func stopReading() {
        speechService.stopListening()
        isReading = false
        sessionStartTime = nil
    }
    
    private func completeSession() {
        let completionTime = sessionStartTime?.timeIntervalSinceNow.magnitude ?? 0
        liberationService.completeSession(
            detectedAnchors: detectedAnchors,
            emotionalState: emotionalState,
            notes: notes,
            completionTime: completionTime
        )
        dismiss()
    }
    
    private func formatElapsedTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval / 60)
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Anchor Chip
struct AnchorChip: View {
    let text: String
    let isDetected: Bool
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(isDetected ? .white : color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(isDetected ? color : color.opacity(0.1))
                    .overlay(
                        Capsule()
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(isDetected ? 1.1 : 1.0)
            .animation(.spring(response: 0.3), value: isDetected)
    }
}

#Preview {
    LiberationLetterDetailView(
        letter: LiberationLetterDataProvider.shared.getLetter(for: 1)!
    )
}
