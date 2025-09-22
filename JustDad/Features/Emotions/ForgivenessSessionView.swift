//
//  ForgivenessSessionView.swift
//  JustDad - Forgiveness Therapy Session View
//
//  Vista de sesión con los 7 pasos de la Terapia del Perdón Pránica
//

import SwiftUI
import AVFoundation
import Speech
import UIKit

// MARK: - Speech Recognition States

enum SpeechState: Equatable {
    case idle
    case starting
    case recording
    case stopping
    case failed(String) // Using String instead of Error for Equatable conformance
    
    var isBusy: Bool {
        switch self {
        case .starting, .recording, .stopping:
            return true
        case .idle, .failed:
            return false
        }
    }
}

// MARK: - Energy Visualization Domain

enum CordState: Equatable {
    case idle, linking, active
    case cutting(progress: CGFloat)  // 0...1
    case released
}

protocol Haptics {
    func cordCutting()
}

protocol Audio {
    func playAmbient(_ name: String, volume: Double)
}

struct Theme {
    static let bg = LinearGradient(
        colors: [.purple.opacity(0.6), .indigo.opacity(0.4), .black],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let stroke = LinearGradient(
        colors: [.purple.opacity(0.6), .blue.opacity(0.4)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Energy Visualization ViewModel

final class EnergyVisualizationViewModel: ObservableObject {
    @Published var state: CordState = .active
    let haptics: Haptics
    let audio: Audio
    let reduceMotion: Bool

    init(haptics: Haptics, audio: Audio, reduceMotion: Bool) {
        self.haptics = haptics
        self.audio = audio
        self.reduceMotion = reduceMotion
    }

    func cutCord() {
        guard case .released = state else {
            withAnimation(.spring(duration: 0.6)) { state = .cutting(progress: 0) }
            audio.playAmbient("cut", volume: 0.8)
            haptics.cordCutting()
            
            // Simulación de progreso del corte
            let steps = 20
            for i in 1...steps {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.03 * Double(i)) {
                    withAnimation(.linear(duration: 0.03)) {
                        self.state = .cutting(progress: CGFloat(i) / CGFloat(steps))
                        if i == steps { self.state = .released }
                    }
                }
            }
            return
        }
    }

    var statusText: String {
        switch state {
        case .idle, .linking: return "Conectando…"
        case .active:         return "Cordón Energético Activo"
        case .cutting:        return "Cortando cordón…"
        case .released:       return "Cordón liberado"
        }
    }

    var statusColor: Color {
        switch state {
        case .active: return .green
        case .cutting: return .orange
        case .released: return .blue
        default: return .yellow
        }
    }
}

// MARK: - Protocol Implementations

extension HapticFeedbackManager: Haptics {
    // Already has cordCutting() method - protocol conformance satisfied
}

extension AudioPlayerService: Audio {
    func playAmbient(_ name: String, volume: Double) {
        playAmbientSound(filename: name, volume: Float(volume))
    }
}

struct ForgivenessSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var forgivenessService: ForgivenessService
    @StateObject private var journalingService: IntelligentJournalingService
    @StateObject private var speechService: RobustSpeechRecognitionService
    @StateObject private var audioService: AudioPlayerService
    @StateObject private var hapticManager: HapticFeedbackManager
    
    let phase: ForgivenessPhase
    let day: Int
    
    @State private var currentStep: ForgivenessSessionStep = .welcome
    
    // MARK: - Initializer
    init(phase: ForgivenessPhase, day: Int) {
        self.phase = phase
        self.day = day
        self._forgivenessService = StateObject(wrappedValue: ForgivenessService.shared)
        self._journalingService = StateObject(wrappedValue: IntelligentJournalingService.shared)
        self._speechService = StateObject(wrappedValue: RobustSpeechRecognitionService.shared)
        self._audioService = StateObject(wrappedValue: AudioPlayerService.shared)
        self._hapticManager = StateObject(wrappedValue: HapticFeedbackManager.shared)
        self._breathingSessionManager = StateObject(wrappedValue: BreathingSessionManager())
    }
    @State private var currentSession: ForgivenessSession?
    @State private var emotionalStateBefore: String = "neutral"
    @State private var peaceLevelBefore: Int = 5
    @State private var emotionalStateAfter: String = "neutral"
    @State private var peaceLevelAfter: Int = 5
    @State private var notes: String = ""
    @State private var isSessionCompleted = false
    @State private var showingCompletion = false
    
    // Debounce controls
    @State private var lastSpeechButtonTap: Date = .distantPast
    private let speechButtonDebounceInterval: TimeInterval = 1.0
    
    // Breathing state variables
    @State private var currentBreathingPhase: BreathingPhase = .inhale
    @State private var isBreathingActive = false
    @StateObject private var breathingSessionManager: BreathingSessionManager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Bar
                progressBarView
                
                // Current Step Content
                currentStepView
                
                // Navigation Buttons
                navigationButtonsView
            }
            .navigationTitle("Día \(day) - \(phase.title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                startSession()
            }
            .onDisappear {
                forgivenessService.stopBinauralAudio()
            }
            .sheet(isPresented: $showingCompletion) {
                ForgivenessSessionCompletionView(
                    session: currentSession,
                    improvement: peaceLevelAfter - peaceLevelBefore
                )
            }
        }
    }
    
    // MARK: - Progress Bar
    
    private var progressBarView: some View {
        VStack(spacing: 8) {
            HStack {
                Text(currentStep.title)
                    .font(.headline)
                Spacer()
                Text("\(currentStep.rawValue + 1)/\(ForgivenessSessionStep.allCases.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ProgressView()
                .progressViewStyle(LinearProgressViewStyle(tint: .pink))
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    // MARK: - Current Step View
    
    @ViewBuilder
    private var currentStepView: some View {
        ScrollView {
            VStack(spacing: 20) {
                switch currentStep {
                case .welcome:
                    welcomeStepView
                case .breathing:
                    breathingStepView
                case .selection:
                    selectionStepView
                case .letter:
                    letterStepView
                case .visualization:
                    visualizationStepView
                case .sealing:
                    sealingStepView
                case .reinforcement:
                    reinforcementStepView
                }
            }
            .padding()
        }
    }
    
    // MARK: - Welcome Step
    
    private var welcomeStepView: some View {
        ZStack {
            // Simple gradient background - no heavy effects
            LinearGradient(
                colors: [Color.purple.opacity(0.4), Color.blue.opacity(0.3), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            VStack(spacing: 40) {
                Spacer()
                
                // Simple icon - no heavy animations
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundColor(.cyan)
                    .padding(.bottom, 20)
                
                // Simple title - no heavy animations
                VStack(spacing: 16) {
                    Text("TERAPIA DEL PERDÓN")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("PRÁNICA")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.pink)
                        .multilineTextAlignment(.center)
                }
                
                // Simple subtitle
                Text("Ritual de Liberación Energética")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                
                // Simple description
                Text("El perdón no cambia el pasado, pero abre tu futuro. Prepárate para una experiencia transformadora de 15-20 minutos.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Simple energy indicator
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        ForEach(0..<5, id: \.self) { index in
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.cyan, .pink],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 10, height: 10)
                        }
                    }
                    
                    Text("Energía Pránica Fluyendo")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Simple button - no heavy effects
                Button(action: {
                    hapticManager.light()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = .breathing
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                        Text("Iniciar Ritual")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.pink, .purple, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.bottom, 80)
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Breathing Step (Super Premium)
    
    private var breathingStepView: some View {
        ZStack {
            // Simple gradient background - no heavy effects
            LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Text("Respiración y Anclaje")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Conecta con tu respiración para anclar la energía de sanación")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Simple breathing circle - reduced effects
                BreathingCircleView(
                    duration: 4.0,
                    isActive: isBreathingActive,
                    onBreathingPhaseChange: { phase in
                        currentBreathingPhase = phase
                        // Light haptic only
                        if phase == .inhale || phase == .exhale {
                            hapticManager.light()
                        }
                    }
                )
                
                // Simple breathing guide
                BreathingCountdownView(
                    breathingPhase: currentBreathingPhase,
                    isActive: isBreathingActive,
                    onPhaseComplete: {
                        // Light success haptic
                        hapticManager.light()
                    }
                )
                
                Spacer()
                
                // REPETITION CONTROL ONLY - Simple and clean
                VStack(spacing: 16) {
                    HStack {
                        Text("Repeticiones:")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            if breathingSessionManager.repetitions > 1 {
                                breathingSessionManager.repetitions -= 1
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.cyan)
                        }
                        
                        Text("\(breathingSessionManager.repetitions)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(minWidth: 30)
                        
                        Button(action: {
                            if breathingSessionManager.repetitions < 10 {
                                breathingSessionManager.repetitions += 1
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.cyan)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.black.opacity(0.4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.cyan.opacity(0.5), lineWidth: 1)
                            )
                    )
                    
                    // Progress indicator
                    if breathingSessionManager.isSessionActive {
                        HStack {
                            Text("Repetición \(breathingSessionManager.currentRepetition) de \(breathingSessionManager.repetitions)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                            
                            Spacer()
                            
                            ProgressView()
                                .progressViewStyle(LinearProgressViewStyle(tint: .cyan))
                                .frame(width: 100)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Simple control buttons
                    HStack(spacing: 20) {
                        // Start/Pause button
                        Button(action: {
                            if breathingSessionManager.isSessionActive {
                                breathingSessionManager.stopSession()
                                isBreathingActive = false
                            } else {
                                breathingSessionManager.startSession()
                                isBreathingActive = true
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: breathingSessionManager.isSessionActive ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.title3)
                                Text(breathingSessionManager.isSessionActive ? "Pausar" : "Iniciar")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(breathingSessionManager.isSessionActive ? Color.orange : Color.cyan)
                            )
                        }
                        
                        // Continue button
                        if !breathingSessionManager.isSessionActive {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentStep = .selection
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.title3)
                                    Text("Continuar")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.green)
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            isBreathingActive = true
        }
    }
    
    // MARK: - Selection Step
    
    private var selectionStepView: some View {
        ZStack {
            // Cosmic background
            CosmicBackgroundView()
            
            // Emotional particle effect
            if !emotionalStateBefore.isEmpty,
               let selectedEmotion = EmotionalState(rawValue: Int(emotionalStateBefore) ?? 3) {
                EmotionParticleEffect(
                    emotion: selectedEmotion,
                    isActive: true
                )
            }
            
            VStack(spacing: 30) {
                // Header section
                VStack(spacing: 16) {
                    Text("Selección de Escenario")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Conecta con tu estado emocional actual para personalizar tu experiencia de sanación")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Premium emotion cards
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 20) {
                    ForEach(EmotionalState.allCases) { emotion in
                        PremiumEmotionCard(
                            emotion: emotion,
                            isSelected: emotionalStateBefore == String(emotion.rawValue),
                            onTap: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    emotionalStateBefore = String(emotion.rawValue)
                                    peaceLevelBefore = getPeaceLevelForEmotion(emotion)
                                }
                                hapticManager.light()
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Selected state display
                if !emotionalStateBefore.isEmpty {
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                            
                            Text("Estado seleccionado:")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text(EmotionalState(rawValue: Int(emotionalStateBefore) ?? 3)?.displayName ?? "")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(EmotionalState(rawValue: Int(emotionalStateBefore) ?? 3)?.color ?? .white)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(EmotionalState(rawValue: Int(emotionalStateBefore) ?? 3)?.color ?? .white, lineWidth: 2)
                                )
                        )
                        
                        Text("Perfecto. Tu experiencia de perdón será personalizada para este estado emocional.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
                
                Spacer()
                
                // Emotional energy field
                if !emotionalStateBefore.isEmpty,
                   let selectedEmotion = EmotionalState(rawValue: Int(emotionalStateBefore) ?? 3) {
                    VStack(spacing: 8) {
                        Text("Campo Energético Emocional")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        EmotionalEnergyField(
                            emotion: selectedEmotion,
                            intensity: getEnergyIntensity(for: selectedEmotion)
                        )
                        .frame(height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal, 40)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
            }
            .padding(.vertical, 40)
        }
        .ignoresSafeArea(.all)
    }
    
    private func getEnergyIntensity(for emotion: EmotionalState) -> Double {
        switch emotion {
        case .verySad:
            return 0.3
        case .sad:
            return 0.5
        case .neutral:
            return 0.7
        case .happy:
            return 0.8
        case .veryHappy:
            return 1.0
        }
    }
    
    // MARK: - Letter Step
    
    private var letterStepView: some View {
        let letter = forgivenessService.getLetterForDay(day, phase: phase)
        
        return ZStack {
            // Premium gradient background
            LinearGradient(
                colors: [Color.purple.opacity(0.3), Color.pink.opacity(0.2), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            VStack(spacing: 24) {
                // Header with premium styling
                VStack(spacing: 12) {
                    Text("Carta del Perdón")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(letter.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.pink)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Premium letter container
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(letter.content)
                            .font(.body)
                            .lineSpacing(6)
                            .foregroundColor(.white)
                            .padding(24)
                            .background(
                                ZStack {
                                    // Glass morphism effect
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white.opacity(0.1))
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [.white.opacity(0.3), .clear],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                    
                                    // Subtle inner glow
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            RadialGradient(
                                                colors: [.pink.opacity(0.1), .clear],
                                                center: .center,
                                                startRadius: 0,
                                                endRadius: 200
                                            )
                                        )
                                }
                            )
                    }
                }
                .frame(maxHeight: 350)
                .padding(.horizontal, 20)
                
                // Premium instruction text
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.text.square")
                            .foregroundColor(.pink)
                        Text("Lee esta carta en voz alta")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    Text("para activar la integración emocional y liberar la energía bloqueada")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                
                // Premium speech recognition section
                VStack(spacing: 16) {
                    if speechService.isRecording {
                        // Recording indicator with premium styling
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: "mic.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .scaleEffect(speechService.isRecording ? 1.3 : 1.0)
                                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: speechService.isRecording)
                                
                                Text("Escuchando...")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [.red.opacity(0.8), .pink.opacity(0.6)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            
                            // Service state indicator
                            if speechService.isBusy {
                                VStack(spacing: 8) {
                                    HStack {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                        
                                        Text("Procesando...")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    
                                    if case .failed(let errorMessage) = speechService.state {
                                        Text("Error: \(errorMessage)")
                                            .font(.caption)
                                            .foregroundColor(.red.opacity(0.8))
                                            .padding(.horizontal, 20)
                                    }
                                }
                            }
                            
                            // Recognized text display
                            if !speechService.recognizedText.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Texto reconocido:")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Text(speechService.recognizedText)
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .padding(16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.black.opacity(0.3))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                )
                                        )
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    
                    // Premium action button with debounce
                    Button(action: {
                        let now = Date()
                        guard now.timeIntervalSince(lastSpeechButtonTap) >= speechButtonDebounceInterval else {
                            print("⚠️ Speech button tapped too quickly, ignoring")
                            return
                        }
                        lastSpeechButtonTap = now
                        
                        // Check if service is busy
                        guard !speechService.isBusy else {
                            print("⚠️ Speech service is busy, ignoring request")
                            return
                        }
                        
                        if speechService.isRecording {
                            speechService.stopRecording()
                            hapticManager.medium()
                            
                            // Calculate reading accuracy
                            let currentLetter = forgivenessService.getLetterForDay(day, phase: phase)
                            let accuracy = speechService.calculateReadingAccuracy(expectedText: currentLetter.content)
                            if accuracy > 0.7 {
                                hapticManager.success()
                            } else {
                                hapticManager.warning()
                            }
                        } else {
                            speechService.reset()
                            speechService.startRecording()
                            hapticManager.light()
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: speechService.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                .font(.title2)
                            Text(speechService.isRecording ? "Detener Grabación" : "Leer en Voz Alta")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: speechService.isRecording ? [.red, .orange] : [.pink, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .shadow(color: speechService.isRecording ? .red.opacity(0.3) : .pink.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .disabled(!speechService.hasPermission || speechService.isBusy)
                    .opacity(speechService.isBusy ? 0.6 : 1.0)
                    .padding(.horizontal, 40)
                }
                
                Spacer(minLength: 40)
            }
        }
    }
    
    // MARK: - Visualization Step
    
    private var visualizationStepView: some View {
        EnergyVisualizationView(
            vm: EnergyVisualizationViewModel(
                haptics: HapticFeedbackManager.shared,
                audio: AudioPlayerService.shared,
                reduceMotion: false // Will be set from environment
            )
        )
    }
    
    // MARK: - Visualization Components
    
    private var visualizationBackground: some View {
        LinearGradient(
            colors: [Color.purple.opacity(0.6), Color.indigo.opacity(0.4), Color.black],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea(.all)
    }
    
    private var visualizationHeader: some View {
        VStack(spacing: 12) {
            Text("Visualización Energética")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Conecta con el cordón energético que te une a esta situación")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .padding(.top, 20)
        .padding(.bottom, 20)
    }
    
    private func energyVisualizationContainer(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // Main energy visualization area - 90% of screen
            ZStack {
                // Energy field background
                energyFieldBackground
                
                // Central energy visualization
                centralEnergyVisualization
            }
            .frame(height: geometry.size.height * 0.9)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [.purple.opacity(0.6), .blue.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // Status indicator - compact
            energyStatusIndicator
                .padding(.horizontal, 32)
                .padding(.top, 12)
        }
    }
    
    private var energyStatusIndicator: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
                .scaleEffect(1.0 + sin(Date().timeIntervalSince1970 * 2) * 0.3)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: Date().timeIntervalSince1970)
            
            Text("Cordón Energético Activo")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
            
            Image(systemName: "bolt.fill")
                .foregroundColor(.yellow)
                .font(.system(size: 16))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }
    
    private var visualizationContainerBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [.purple.opacity(0.3), .blue.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
    
    // MARK: - New Energy Visualization Components
    
    private var energyFieldBackground: some View {
        ZStack {
            // Cosmic energy waves
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.purple.opacity(0.3), .blue.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: CGFloat(100 + index * 80), height: CGFloat(100 + index * 80))
                    .scaleEffect(1.0 + sin(Date().timeIntervalSince1970 * 0.5 + Double(index)) * 0.1)
                    .animation(
                        .easeInOut(duration: 3 + Double(index) * 0.5)
                        .repeatForever(autoreverses: true),
                        value: Date().timeIntervalSince1970
                    )
            }
            
            // Energy particles
            ForEach(0..<20, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.yellow.opacity(0.6), .orange.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 8, height: 8)
                    .offset(
                        x: CGFloat.random(in: -200...200),
                        y: CGFloat.random(in: -300...300)
                    )
                    .scaleEffect(0.5 + sin(Date().timeIntervalSince1970 * 2 + Double(index)) * 0.3)
                    .animation(
                        .easeInOut(duration: 2 + Double(index) * 0.1)
                        .repeatForever(autoreverses: true),
                        value: Date().timeIntervalSince1970
                    )
            }
        }
    }
    
    private var centralEnergyVisualization: some View {
        GeometryReader { geometry in
            ZStack {
                // Energy cord visualization - MUCH LARGER
                energyCordVisualization
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Energy flow indicators
                energyFlowIndicators
            }
        }
    }
    
    private var energyCordVisualization: some View {
        HStack(spacing: 60) {
            // You (left side)
            energyEntityView(
                color: .blue,
                icon: "person.fill",
                label: "TÚ",
                isActive: true
            )
            
            // Energy cord - CENTRAL and LARGE
            energyCordView
            
            // Situation (right side)
            energyEntityView(
                color: .red,
                icon: "exclamationmark.triangle.fill",
                label: "SITUACIÓN",
                isActive: true
            )
        }
        .padding(.horizontal, 40)
    }
    
    private func energyEntityView(color: Color, icon: String, label: String, isActive: Bool) -> some View {
        VStack(spacing: 16) {
            // Energy entity circle
            ZStack {
                // Outer glow
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .scaleEffect(isActive ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isActive)
                
                // Inner circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.8), color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .shadow(color: color.opacity(0.5), radius: 10, x: 0, y: 5)
            }
            
            // Label
            Text(label)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(color.opacity(0.2))
                        .overlay(
                            Capsule()
                                .stroke(color.opacity(0.5), lineWidth: 1)
                        )
                )
        }
    }
    
    private var energyCordView: some View {
        GeometryReader { geometry in
            ZStack {
                // Main energy cord
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: [.red.opacity(0.9), .orange.opacity(0.8), .red.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 250, height: 30)
                    .shadow(color: .red.opacity(0.6), radius: 15, x: 0, y: 8)
                    .overlay(
                        // Energy flow animation
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    colors: [.clear, .yellow.opacity(0.8), .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 250, height: 30)
                            .offset(x: sin(Date().timeIntervalSince1970 * 3) * 50)
                            .animation(
                                .linear(duration: 2)
                                .repeatForever(autoreverses: false),
                                value: Date().timeIntervalSince1970
                            )
                    )
                
                // Energy particles around cord
                ForEach(0..<12, id: \.self) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.yellow.opacity(0.9), .orange.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 16, height: 16)
                        .offset(
                            x: CGFloat.random(in: -120...120),
                            y: CGFloat.random(in: -40...40)
                        )
                        .scaleEffect(0.7 + sin(Date().timeIntervalSince1970 * 2 + Double(index)) * 0.3)
                        .animation(
                            .easeInOut(duration: 1.5 + Double(index) * 0.1)
                            .repeatForever(autoreverses: true),
                            value: Date().timeIntervalSince1970
                        )
                }
            }
        }
    }
    
    private var energyFlowIndicators: some View {
        VStack(spacing: 20) {
            // Top flow indicator
            HStack(spacing: 8) {
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(Color.blue.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .scaleEffect(0.8 + sin(Date().timeIntervalSince1970 * 3 + Double(index)) * 0.2)
                        .animation(
                            .easeInOut(duration: 1)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.1),
                            value: Date().timeIntervalSince1970
                        )
                }
            }
            
            Spacer()
            
            // Bottom flow indicator
            HStack(spacing: 8) {
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(Color.red.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .scaleEffect(0.8 + sin(Date().timeIntervalSince1970 * 3 + Double(index)) * 0.2)
                        .animation(
                            .easeInOut(duration: 1)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.1),
                            value: Date().timeIntervalSince1970
                        )
                }
            }
        }
        .padding(.horizontal, 60)
        .padding(.vertical, 40)
    }
    
    private var visualizationActionButtons: some View {
        VStack(spacing: 20) {
            // Instruction text
            Text("Libera la energía bloqueada cortando el cordón energético")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            // Cutting button - LARGE and PROMINENT
            cuttingButton
        }
        .padding(.bottom, 40)
        .background(
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
    }
    
    private var cuttingButton: some View {
        Button(action: {
            // Trigger cord cutting sequence
            hapticManager.cordCutting()
            
            // Play cutting sound effect
            audioService.playAmbientSound(filename: "cut", volume: 0.8)
            
            // Send notification to trigger cord cutting
            NotificationCenter.default.post(name: .init("CutCord"), object: nil)
        }) {
            HStack(spacing: 16) {
                Image(systemName: "scissors")
                    .font(.system(size: 24, weight: .bold))
                    .rotationEffect(.degrees(45))
                
                Text("CORTAR CORDÓN ENERGÉTICO")
                    .font(.system(size: 20, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color.red, Color.red.opacity(0.8), Color.orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .red.opacity(0.5), radius: 15, x: 0, y: 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
        }
        .padding(.horizontal, 40)
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: Date().timeIntervalSince1970)
    }
    
    // MARK: - Sealing Step
    
    private var sealingStepView: some View {
        VStack(spacing: 24) {
            Text("Sellado y Expansión")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Sella la liberación con luz dorada")
                .font(.body)
                .foregroundColor(.secondary)
            
            // Golden sphere visualization
            RoundedRectangle(cornerRadius: 150)
                .fill(
                    RadialGradient(
                        colors: [.yellow, .orange, .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .overlay(
                    Text("LIBERACIÓN")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            Text("Estoy libre. Estoy en paz. Mi corazón está abierto a nuevas posibilidades.")
                .font(.headline)
                .foregroundColor(.pink)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Reinforcement Step
    
    private var reinforcementStepView: some View {
        ZStack {
            // Fondo premium con gradiente
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.8),
                    Color.indigo.opacity(0.6),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header premium
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "sparkles")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.yellow)
                            
                            Text("Refuerzo Adictivo")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.yellow)
                        }
                        
                        Text("Consolida tu liberación emocional y celebra tu progreso")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 15)
                    
                    // Comparación antes/después
                    VStack(spacing: 16) {
                        Text("Comparación de Progreso")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 12) {
                            // Antes
                            VStack(spacing: 8) {
                                Text("ANTES")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.red.opacity(0.8))
                                
                                VStack(spacing: 6) {
                                    Text(EmotionalState(rawValue: Int(emotionalStateBefore) ?? 3)?.displayName ?? "Neutral")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    HStack {
                                        ForEach(1...10, id: \.self) { index in
                                            Circle()
                                                .fill(index <= peaceLevelBefore ? Color.red.opacity(0.8) : Color.gray.opacity(0.3))
                                                .frame(width: 8, height: 8)
                                        }
                                    }
                                    
                                    Text("\(peaceLevelBefore)/10")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.red.opacity(0.8))
                                }
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.black.opacity(0.4))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.red.opacity(0.3), lineWidth: 2)
                                    )
                            )
                            
                            // Flecha
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.yellow)
                            
                            // Después
                            VStack(spacing: 8) {
                                Text("DESPUÉS")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.green.opacity(0.8))
                                
                                VStack(spacing: 6) {
                                    Picker("Estado", selection: Binding(
                                        get: { EmotionalState(rawValue: Int(emotionalStateAfter) ?? 3) ?? .neutral },
                                        set: { emotionalStateAfter = String($0.rawValue) }
                                    )) {
                                        ForEach(EmotionalState.allCases) { emotion in
                                            Text(emotion.displayName).tag(emotion)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .foregroundColor(.white)
                                    
                                    HStack {
                                        ForEach(1...10, id: \.self) { index in
                                            Circle()
                                                .fill(index <= peaceLevelAfter ? Color.green.opacity(0.8) : Color.gray.opacity(0.3))
                                                .frame(width: 8, height: 8)
                                        }
                                    }
                                    
                                    Stepper(value: $peaceLevelAfter, in: 1...10) {
                                        Text("\(peaceLevelAfter)/10")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.green.opacity(0.8))
                                    }
                                }
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.black.opacity(0.4))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.green.opacity(0.3), lineWidth: 2)
                                    )
                            )
                        }
                    }
                    
                    // Mejora calculada
                    let improvement = peaceLevelAfter - peaceLevelBefore
                    VStack(spacing: 12) {
                        Text("Mejora Lograda")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 12) {
                            Image(systemName: improvement >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(improvement >= 0 ? .green : .red)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(improvement >= 0 ? "+" : "")\(improvement) puntos")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(improvement >= 0 ? .green : .red)
                                
                                Text(improvement >= 0 ? "¡Excelente progreso!" : "Sigue trabajando")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Spacer()
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black.opacity(0.4))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(improvement >= 0 ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 2)
                                )
                        )
                    }
                    
                    // Notas reflexivas
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Reflexión de la Sesión")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("¿Cómo te sientes después de esta experiencia de perdón?")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                            
                            TextField("Comparte tus pensamientos y sentimientos...", text: $notes, axis: .vertical)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black.opacity(0.3))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                                .lineLimit(3...6)
                        }
                    }
                    
                    // Sistema de puntos y logros
                    VStack(spacing: 16) {
                        Text("Logros Desbloqueados")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForgivenessAchievementCard(
                                icon: "heart.fill",
                                title: "Liberación",
                                description: "+50 pts",
                                color: .pink,
                                isUnlocked: true
                            )
                            
                            ForgivenessAchievementCard(
                                icon: "leaf.fill",
                                title: "Crecimiento",
                                description: "+30 pts",
                                color: .green,
                                isUnlocked: improvement > 0
                            )
                            
                            ForgivenessAchievementCard(
                                icon: "star.fill",
                                title: "Transformación",
                                description: "+40 pts",
                                color: .yellow,
                                isUnlocked: improvement >= 3
                            )
                            
                            ForgivenessAchievementCard(
                                icon: "sparkles",
                                title: "Maestría",
                                description: "+60 pts",
                                color: .purple,
                                isUnlocked: improvement >= 5
                            )
                        }
                    }
                    
                    // Próximos pasos
                    VStack(spacing: 12) {
                        Text("Próximos Pasos")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        
                        VStack(spacing: 8) {
                            ForgivenessNextStepCard(
                                icon: "calendar",
                                title: "Sesión de seguimiento",
                                description: "Programa tu próxima sesión en 3 días",
                                color: .blue
                            )
                            
                            ForgivenessNextStepCard(
                                icon: "book.fill",
                                title: "Diario de gratitud",
                                description: "Practica la gratitud diaria",
                                color: .orange
                            )
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - Navigation Buttons
    
    private var navigationButtonsView: some View {
        HStack(spacing: 16) {
            if currentStep.rawValue > 0 {
                Button("Anterior") {
                    withAnimation {
                        currentStep = ForgivenessSessionStep(rawValue: currentStep.rawValue - 1) ?? .welcome
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.pink, lineWidth: 1)
                )
                .foregroundColor(.pink)
            }
            
            Button(currentStep == .reinforcement ? "Completar Sesión" : "Siguiente") {
                if currentStep == .reinforcement {
                    completeSession()
                } else {
                    withAnimation {
                        currentStep = ForgivenessSessionStep(rawValue: currentStep.rawValue + 1) ?? .reinforcement
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.pink)
            )
            .foregroundColor(.white)
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    // MARK: - Helper Methods
    
    private func startSession() {
        currentSession = forgivenessService.startNewSession(
            day: day,
            phase: phase,
            emotionalState: emotionalStateBefore,
            peaceLevel: peaceLevelBefore
        )
        
        // Start binaural audio if enabled
        forgivenessService.playBinauralAudio()
    }
    
    private func completeSession() {
        guard let session = currentSession else { 
            print("❌ Error: currentSession is nil")
            return 
        }
        
        print("✅ Completing session for day \(session.day), phase \(session.phase)")
        
        forgivenessService.completeSession(
            session,
            emotionalStateAfter: emotionalStateAfter,
            peaceLevelAfter: peaceLevelAfter,
            notes: notes.isEmpty ? nil : notes
        )
        
        forgivenessService.stopBinauralAudio()
        showingCompletion = true
        
        print("✅ Session completed successfully")
    }
    
    private func getPeaceLevelForEmotion(_ emotion: EmotionalState) -> Int {
        switch emotion {
        case .veryHappy:
            return 9
        case .happy:
            return 7
        case .neutral:
            return 5
        case .sad:
            return 3
        case .verySad:
            return 1
        }
    }
}

// MARK: - Supporting Views


struct EnergyCordVisualizationView: View {
    @State private var cordVisible = true
    @State private var cordCut = false
    @State private var cuttingAnimation = false
    @State private var liberationParticles = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background energy field
                energyFieldBackground
                
                // Main visualization
                VStack(spacing: 40) {
                    // Energy entities and cord
                    HStack(spacing: 80) {
                        // You (left side)
                        energyEntityView(
                            color: .blue,
                            icon: "person.fill",
                            label: "TÚ",
                            isActive: !cordCut
                        )
                        
                        // Energy cord - CENTRAL and LARGE
                        if cordVisible && !cordCut {
                            energyCordView
                        }
                        
                        // Situation (right side)
                        energyEntityView(
                            color: .red,
                            icon: "exclamationmark.triangle.fill",
                            label: "SITUACIÓN",
                            isActive: !cordCut
                        )
                    }
                    
                    // Status message
                    if cordCut {
                        liberationMessage
                    } else {
                        activeStatusMessage
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(40)
            }
        }
        .onTapGesture {
            cutCord()
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("CutCord"))) { _ in
            cutCord()
        }
    }
    
    // MARK: - Energy Field Background
    private var energyFieldBackground: some View {
        ZStack {
            // Cosmic energy waves
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.purple.opacity(0.2), .blue.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .frame(width: CGFloat(150 + index * 100), height: CGFloat(150 + index * 100))
                    .scaleEffect(1.0 + sin(Date().timeIntervalSince1970 * 0.3 + Double(index)) * 0.05)
                    .animation(
                        .easeInOut(duration: 4 + Double(index) * 0.5)
                        .repeatForever(autoreverses: true),
                        value: Date().timeIntervalSince1970
                    )
            }
            
            // Energy particles
            ForEach(0..<25, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.yellow.opacity(0.4), .orange.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 6, height: 6)
                    .offset(
                        x: CGFloat.random(in: -300...300),
                        y: CGFloat.random(in: -400...400)
                    )
                    .scaleEffect(0.3 + sin(Date().timeIntervalSince1970 * 1.5 + Double(index)) * 0.2)
                    .animation(
                        .easeInOut(duration: 3 + Double(index) * 0.1)
                        .repeatForever(autoreverses: true),
                        value: Date().timeIntervalSince1970
                    )
            }
        }
    }
    
    // MARK: - Energy Entity View
    private func energyEntityView(color: Color, icon: String, label: String, isActive: Bool) -> some View {
        VStack(spacing: 20) {
            // Energy entity circle
            ZStack {
                // Outer glow
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 140, height: 140)
                    .scaleEffect(isActive ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isActive)
                
                // Inner circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.7), color.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .shadow(color: color.opacity(0.4), radius: 15, x: 0, y: 8)
            }
            
            // Label
            Text(label)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(color.opacity(0.15))
                        .overlay(
                            Capsule()
                                .stroke(color.opacity(0.4), lineWidth: 1)
                        )
                )
        }
    }
    
    // MARK: - Energy Cord View
    private var energyCordView: some View {
        ZStack {
            // Main energy cord - MUCH LARGER
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [.red.opacity(0.9), .orange.opacity(0.8), .red.opacity(0.9)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 300, height: 40) // MUCH LARGER
                .shadow(color: .red.opacity(0.7), radius: 20, x: 0, y: 10)
                .overlay(
                    // Energy flow animation
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [.clear, .yellow.opacity(0.9), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 300, height: 40)
                        .offset(x: sin(Date().timeIntervalSince1970 * 2) * 60)
                        .animation(
                            .linear(duration: 2.5)
                            .repeatForever(autoreverses: false),
                            value: Date().timeIntervalSince1970
                        )
                )
            
            // Energy particles around cord - LARGER
            if !cordCut {
                ForEach(0..<15, id: \.self) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.yellow.opacity(0.9), .orange.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 20, height: 20) // LARGER
                        .offset(
                            x: CGFloat.random(in: -150...150),
                            y: CGFloat.random(in: -60...60)
                        )
                        .scaleEffect(0.6 + sin(Date().timeIntervalSince1970 * 1.8 + Double(index)) * 0.4)
                        .animation(
                            .easeInOut(duration: 2 + Double(index) * 0.1)
                            .repeatForever(autoreverses: true),
                            value: Date().timeIntervalSince1970
                        )
                }
            }
            
            // Cutting effect - MORE VISIBLE
            if cuttingAnimation {
                Rectangle()
                    .fill(Color.white.opacity(0.95))
                    .frame(width: 12, height: 60) // LARGER
                    .offset(x: CGFloat.random(in: -100...100))
                    .shadow(color: .white.opacity(0.9), radius: 20, x: 0, y: 0)
                    .animation(.easeInOut(duration: 0.4), value: cuttingAnimation)
            }
        }
    }
    
    // MARK: - Status Messages
    private var activeStatusMessage: some View {
        VStack(spacing: 16) {
            Text("Cordón Energético Activo")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Presiona el botón para cortar el cordón")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }
    
    private var liberationMessage: some View {
        VStack(spacing: 24) {
            Text("¡CORDÓN LIBERADO! ✨")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.green)
                .scaleEffect(liberationParticles ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.6), value: liberationParticles)
            
            Text("La energía bloqueada ha sido liberada")
                .font(.title2)
                .foregroundColor(.green.opacity(0.9))
                .multilineTextAlignment(.center)
            
            // Liberation particles - LARGER
            if liberationParticles {
                ForEach(0..<16, id: \.self) { index in
                    Circle()
                        .fill(Color.yellow.opacity(0.9))
                        .frame(width: 20, height: 20) // LARGER
                        .offset(
                            x: cos(Double(index) * .pi / 8) * 120,
                            y: sin(Double(index) * .pi / 8) * 120
                        )
                        .scaleEffect(liberationParticles ? 0.0 : 1.0)
                        .animation(
                            .easeOut(duration: 2)
                            .delay(Double(index) * 0.05),
                            value: liberationParticles
                        )
                }
            }
        }
    }
    
    private func cutCord() {
        // Start cutting animation
        withAnimation(.easeInOut(duration: 0.3)) {
            cuttingAnimation = true
        }
        
        // After cutting animation, cut the cord
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.8)) {
                cordCut = true
                cordVisible = false
                cuttingAnimation = false
            }
            
            // Start liberation particles
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                liberationParticles = true
            }
        }
    }
}

// MARK: - Professional Energy Visualization View

struct EnergyVisualizationView: View {
    @StateObject var vm: EnergyVisualizationViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                HeaderView()

                // Campo energético + entidades
                VisualizationStage(state: vm.state, reduceMotion: reduceMotion)
                    .padding(.horizontal, 12)
                    .padding(.top, 12)

                StatusBadge(text: vm.statusText, dotColor: vm.statusColor)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                Spacer(minLength: 0)

                // Acciones
                VStack(spacing: 16) {
                    Text("Libera la energía bloqueada cortando el cordón energético")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    CutButton(state: vm.state) { vm.cutCord() }
                }
                .padding(.bottom, 30)
                .background(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Components

    struct HeaderView: View {
        var body: some View {
            VStack(spacing: 8) {
                Text("Visualización Energética")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Conecta con el cordón energético que te une a esta situación")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.vertical, 15)
            .accessibilityAddTraits(.isHeader)
        }
    }

struct VisualizationStage: View {
        let state: CordState
        let reduceMotion: Bool

        var body: some View {
            ZStack {
                // Fondo animado eficiente
                EnergyFieldCanvas(reduceMotion: reduceMotion)

                // Entidades + cordón
                EntitiesRow(state: state)
                    .padding(12)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Theme.stroke, lineWidth: 2)
                    )
            )
        }
    }

struct EntitiesRow: View {
    let state: CordState

    var body: some View {
        HStack(spacing: 20) {
            EnergyEntity(
                color: .blue,
                icon: "person.fill",
                label: "TÚ",
                pulse: isActive
            )
            CordView(state: state)
                .frame(width: 120, height: 20)
            EnergyEntity(
                color: .red,
                icon: "exclamationmark.triangle.fill",
                label: "SITUACIÓN",
                pulse: isActive
            )
        }
        .padding(.horizontal, 12)
    }

    private var isActive: Bool {
        if case .released = state { return false }
        return true
    }
}

struct EnergyEntity: View {
    let color: Color
    let icon: String
    let label: String
    let pulse: Bool

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.18))
                    .frame(width: 60, height: 60)
                    .scaleEffect(pulse ? 1.06 : 1.0)
                    .animation(
                        pulse ? .easeInOut(duration: 1.6).repeatForever(autoreverses: true) : .default,
                        value: pulse
                    )

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.85), color.opacity(0.65)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 45, height: 45)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .shadow(color: color.opacity(0.45), radius: 6, x: 0, y: 3)
            }

            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(color)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(color.opacity(0.18))
                        .overlay(
                            Capsule()
                                .stroke(color.opacity(0.45), lineWidth: 1)
                        )
                )
                .accessibilityLabel(Text(label))
        }
    }
}

struct CordView: View {
    let state: CordState

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let progress = cutProgress

            ZStack {
                RoundedRectangle(cornerRadius: h/2)
                    .fill(
                        LinearGradient(
                            colors: [.red.opacity(0.9), .orange.opacity(0.8), .red.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        // "brillo" de flujo que recorre el cordón, pausado cuando released
                        TimelineView(.animation) { timeline in
                            let t = timeline.date.timeIntervalSinceReferenceDate
                            let offset = (sin(t * 2.0) * (w * 0.18))
                            RoundedRectangle(cornerRadius: h/2)
                                .fill(
                                    LinearGradient(
                                        colors: [.clear, .yellow.opacity(isReleased ? 0.0 : 0.85), .clear],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: w, height: h)
                                .offset(x: isReleased ? 0 : offset)
                        }
                    )
                    .mask(
                        // máscara que "come" el cordón según el progreso de corte
                        HStack(spacing: 0) {
                            Rectangle().frame(width: w * (1.0 - progress))
                            Rectangle().fill(Color.clear)
                        }
                    )
                    .shadow(color: .red.opacity(isReleased ? 0.2 : 0.55), radius: 12, x: 0, y: 6)

                // Partículas cerca del cordón (baratas)
                if !isReleased {
                    TimelineView(.animation) { timeline in
                        let t = timeline.date.timeIntervalSinceReferenceDate
                        ParticlesStrip(t: t, width: w, height: h)
                    }
                }
            }
        }
    }

    private var cutProgress: CGFloat {
        if case .cutting(let p) = state { return min(max(p, 0), 1) }
        return state == .released ? 1 : 0
    }
    private var isReleased: Bool { state == .released }
}

struct ParticlesStrip: View {
    let t: TimeInterval
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Canvas { ctx, size in
            let n = 10
            for i in 0..<n {
                let phase = Double(i) * 0.5
                let y = height/2 + CGFloat(sin(t*2.0 + phase)) * (height*0.35)
                var rect = CGRect(
                    x: CGFloat.random(in: (width*0.1)...(width*0.9)),
                    y: y,
                    width: 8,
                    height: 8
                )
                rect.origin.x.formTruncatingRemainder(dividingBy: width) // bounded
                let alpha = 0.6 + 0.3 * sin(t*3.0 + phase)
                ctx.fill(
                    Path(ellipseIn: rect),
                    with: .linearGradient(
                        Gradient(colors: [Color.yellow.opacity(alpha), Color.orange.opacity(alpha*0.8)]),
                        startPoint: CGPoint.zero,
                        endPoint: CGPoint(x: 1, y: 1)
                    )
                )
            }
        }
    }
}

struct EnergyFieldCanvas: View {
    let reduceMotion: Bool
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                // Ondas concéntricas
                let center = CGPoint(x: size.width/2, y: size.height/2)
                for k in 0..<4 {
                    let base = CGFloat(60 + k*50)
                    let amp: CGFloat = reduceMotion ? 0.02 : 0.1
                    let scale = 1.0 + CGFloat(sin(t*0.5 + Double(k))) * amp
                    let r = base * scale
                    var path = Path()
                    path.addEllipse(in: CGRect(x: center.x - r/2, y: center.y - r/2, width: r, height: r))
                    ctx.stroke(
                        path,
                        with: .linearGradient(
                            Gradient(colors: [.purple.opacity(0.3), .blue.opacity(0.2)]),
                            startPoint: CGPoint.zero,
                            endPoint: CGPoint(x: 1, y: 1)
                        ),
                        lineWidth: 2
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct StatusBadge: View {
        let text: String
        let dotColor: Color
        
        var body: some View {
            HStack(spacing: 10) {
                Circle()
                    .fill(dotColor)
                    .frame(width: 6, height: 6)
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                    .accessibilityHidden(true)
                Text(text)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                Image(systemName: "bolt.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 14))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.15), lineWidth: 1)
                )
        )
        .accessibilityLabel(Text(text))
    }
}

struct CutButton: View {
    let state: CordState
    let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack(spacing: 10) {
                    Image(systemName: "scissors")
                        .font(.system(size: 18, weight: .bold))
                        .rotationEffect(.degrees(45))
                    Text(buttonTitle)
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .red.opacity(0.5), radius: 10, x: 0, y: 6)
                )
            }
            .padding(.horizontal, 30)
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.6 : 1.0)
            .accessibilityHint(Text("Activa la secuencia de corte del cordón"))
        }

    private var isDisabled: Bool { 
        state == .released || (state.isCutting && progress == 0) 
    }
    
    private var gradientColors: [Color] {
        state == .released ? [.blue, .indigo] : [Color.red, Color.red.opacity(0.85), Color.orange]
    }
    
    private var buttonTitle: String {
        switch state {
        case .released: return "CORDÓN LIBERADO"
        case .cutting:  return "CORTANDO…"
        default:        return "CORTAR CORDÓN ENERGÉTICO"
        }
    }
    
    private var progress: CGFloat {
        if case .cutting(let p) = state { return p } else { return 0 }
    }
}

private extension CordState {
    var isCutting: Bool {
        if case .cutting = self { return true }
        return false
    }
}

// MARK: - Achievement and Next Step Components

struct ForgivenessAchievementCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? color.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isUnlocked ? color : Color.gray)
            }
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(isUnlocked ? .white : Color.gray)
                
                Text(description)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isUnlocked ? color : Color.gray)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isUnlocked ? Color.black.opacity(0.3) : Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isUnlocked ? color.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
        .scaleEffect(isUnlocked ? 1.0 : 0.95)
        .opacity(isUnlocked ? 1.0 : 0.6)
        .animation(.easeInOut(duration: 0.3), value: isUnlocked)
    }
}

struct ForgivenessNextStepCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 35, height: 35)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ForgivenessSessionView(phase: .selfForgiveness, day: 1)
}
