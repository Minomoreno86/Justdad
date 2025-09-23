import SwiftUI

struct RitualEvocationView: View {
    @ObservedObject var ritualEngine: RitualEngine
    @State private var selectedFocus: RitualFocus = .exPartner
    @State private var evocationText = ""
    @State private var isRecording = false
    @State private var recordedText = ""
    @State private var showingVoicePrompt = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Título y descripción
                VStack(spacing: 16) {
                    Text("Evocación Guiada")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Nombra en voz alta lo que vas a liberar hoy")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Selector de foco
                VStack(spacing: 16) {
                    Text("¿Qué vas a liberar?")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 12) {
                        ForEach(RitualFocus.allCases, id: \.self) { focus in
                            FocusCard(
                                focus: focus,
                                isSelected: selectedFocus == focus,
                                action: { selectedFocus = focus }
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Prompt de evocación
                VStack(spacing: 20) {
                    Text(selectedFocus.evocationPrompt)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        )
                        .padding(.horizontal, 20)
                    
                    // Campo de texto opcional
                    VStack(spacing: 12) {
                        Text("Puedes escribir tus pensamientos (opcional)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                        
                        TextField("Escribe lo que sientes...", text: $evocationText, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                            .padding(.horizontal, 20)
                    }
                }
                
                Spacer()
                
                // Grabación de voz
                VStack(spacing: 20) {
                    if showingVoicePrompt {
                        VoiceRecordingSection(
                            isRecording: $isRecording,
                            recordedText: $recordedText,
                            onComplete: {
                                showingVoicePrompt = false
                                ritualEngine.completeEvocation(
                                    focus: selectedFocus,
                                    text: evocationText,
                                    voiceText: recordedText
                                )
                            }
                        )
                    } else {
                        // Botón para grabar
                        Button(action: {
                            showingVoicePrompt = true
                        }) {
                            HStack {
                                Image(systemName: "mic.circle.fill")
                                    .font(.title2)
                                
                                Text("Graba tu evocación")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [.orange, .red],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Botón para saltar grabación
                    if !showingVoicePrompt {
                        Button(action: {
                            ritualEngine.completeEvocation(
                                focus: selectedFocus,
                                text: evocationText,
                                voiceText: ""
                            )
                        }) {
                            Text("Continuar sin grabar")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
            }
            .padding(.bottom, 20) // Agregar padding al final para que no se corte
        }
    }
}

// MARK: - Focus Card
struct FocusCard: View {
    let focus: RitualFocus
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: focus.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(focus.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(focus.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.orange.opacity(0.2) : Color.clear)
                    .background(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? .orange : .clear, lineWidth: 2)
                    )
            )
        }
    }
}

// MARK: - Voice Recording Section
struct VoiceRecordingSection: View {
    @Binding var isRecording: Bool
    @Binding var recordedText: String
    let onComplete: () -> Void
    
    @State private var recordingDuration = 0
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 20) {
            // Estado de grabación
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isRecording ? .red.opacity(0.3) : .white.opacity(0.1))
                        .frame(width: 100, height: 100)
                        .scaleEffect(isRecording ? 1.2 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                            value: isRecording
                        )
                    
                    Image(systemName: isRecording ? "mic.fill" : "mic")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                
                Text(isRecording ? "Grabando..." : "Presiona para grabar")
                    .font(.headline)
                    .foregroundColor(.white)
                
                if isRecording {
                    Text("\(recordingDuration)s")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
            }
            
            // Controles
            HStack(spacing: 20) {
                // Botón de grabar/pausar
                Button(action: {
                    if isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                }) {
                    Image(systemName: isRecording ? "stop.circle.fill" : "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(isRecording ? .red : .green)
                }
                
                // Botón de completar (solo si hay grabación)
                if !recordedText.isEmpty {
                    Button(action: onComplete) {
                        Text("Completar")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.blue)
                            )
                    }
                }
            }
            
            // Texto transcrito
            if !recordedText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Texto transcrito:")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(recordedText)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.ultraThinMaterial)
                        )
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func startRecording() {
        isRecording = true
        recordingDuration = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            recordingDuration += 1
        }
        
        // TODO: Implementar grabación real con Speech framework
        // Por ahora simulamos la grabación
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            recordedText = "Texto simulado de la evocación grabada"
        }
    }
    
    private func stopRecording() {
        isRecording = false
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        CosmicBackgroundView()
        RitualEvocationView(ritualEngine: RitualEngine())
    }
}