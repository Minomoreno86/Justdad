import SwiftUI

struct BreathingCircleView: View {
    let duration: Double
    let isActive: Bool
    let onBreathingPhaseChange: (BreathingPhase) -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.8
    @State private var currentPhase: BreathingPhase = .inhale
    @State private var animationTimer: Timer?
    @State private var phaseProgress: Double = 0.0
    
    init(
        duration: Double = 4.0,
        isActive: Bool = true,
        onBreathingPhaseChange: @escaping (BreathingPhase) -> Void = { _ in }
    ) {
        self.duration = duration
        self.isActive = isActive
        self.onBreathingPhaseChange = onBreathingPhaseChange
    }
    
    var body: some View {
        ZStack {
            backgroundGlowView
            mainCircleView
            energyParticlesView
            phaseIndicatorView
        }
        .frame(width: 200, height: 200)
        .onAppear {
            if isActive {
                startBreathingAnimation()
            }
        }
        .onDisappear {
            stopBreathingAnimation()
        }
        .onChange(of: isActive) { newValue in
            if newValue {
                startBreathingAnimation()
            } else {
                stopBreathingAnimation()
            }
        }
    }
    
    private var backgroundGlowView: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        currentPhase.color.opacity(0.3),
                        currentPhase.color.opacity(0.1),
                        .clear
                    ],
                    center: .center,
                    startRadius: 50,
                    endRadius: 150
                )
            )
            .scaleEffect(scale * 1.2)
            .opacity(opacity * 0.5)
            .blur(radius: 10)
    }
    
    private var mainCircleView: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [
                        currentPhase.color.opacity(0.8),
                        currentPhase.color.opacity(0.4),
                        currentPhase.color.opacity(0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                currentPhase.color,
                                currentPhase.color.opacity(0.5),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
            )
            .scaleEffect(scale)
            .opacity(opacity)
            .shadow(color: currentPhase.color, radius: 20)
            .shadow(color: currentPhase.color, radius: 40, x: 0, y: 0)
    }
    
    private var energyParticlesView: some View {
        ZStack {
            energyParticle(at: 0)
            energyParticle(at: 1)
            energyParticle(at: 2)
            energyParticle(at: 3)
            energyParticle(at: 4)
            energyParticle(at: 5)
            energyParticle(at: 6)
            energyParticle(at: 7)
        }
    }
    
    private func energyParticle(at index: Int) -> some View {
        Circle()
            .fill(currentPhase.color.opacity(0.6))
            .frame(width: 4, height: 4)
            .offset(
                x: cos(Double(index) * .pi / 4 + phaseProgress * .pi * 2) * (scale * 60),
                y: sin(Double(index) * .pi / 4 + phaseProgress * .pi * 2) * (scale * 60)
            )
            .scaleEffect(scale * 0.8)
            .opacity(opacity * 0.8)
    }
    
    private var phaseIndicatorView: some View {
        VStack(spacing: 8) {
            Text(currentPhase.displayName)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .shadow(color: currentPhase.color, radius: 5)
            
            Text(currentPhase.instruction)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .shadow(color: currentPhase.color, radius: 3)
        }
        .scaleEffect(scale * 0.9)
        .opacity(opacity)
    }
    
    private func startBreathingAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateBreathingAnimation()
        }
    }
    
    private func stopBreathingAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func updateBreathingAnimation() {
        let currentTime = Date().timeIntervalSince1970
        let cycleTime = 22.0 // Complete inhale + exhale cycle (6+4+8+4 = 22 seconds)
        let normalizedTime = (currentTime.truncatingRemainder(dividingBy: cycleTime)) / cycleTime
        
        // Update phase progress
        phaseProgress = normalizedTime
        
        // Determine current phase (6+4+8+4 = 22 seconds total)
        let newPhase: BreathingPhase
        if normalizedTime < (6.0/22.0) { // 0-6 seconds
            newPhase = .inhale
        } else if normalizedTime < (10.0/22.0) { // 6-10 seconds
            newPhase = .holdInhale
        } else if normalizedTime < (18.0/22.0) { // 10-18 seconds
            newPhase = .exhale
        } else { // 18-22 seconds
            newPhase = .holdExhale
        }
        
        // Update phase if changed
        if newPhase != currentPhase {
            currentPhase = newPhase
            onBreathingPhaseChange(newPhase)
        }
        
        // Calculate scale and opacity based on phase
        let phaseProgress = getPhaseProgress(normalizedTime: normalizedTime)
        
        withAnimation(.easeInOut(duration: 0.016)) {
            switch currentPhase {
            case .inhale:
                scale = 1.0 + phaseProgress * 0.3
                opacity = 0.8 + phaseProgress * 0.2
            case .holdInhale:
                scale = 1.3
                opacity = 1.0
            case .exhale:
                scale = 1.3 - phaseProgress * 0.3
                opacity = 1.0 - phaseProgress * 0.2
            case .holdExhale:
                scale = 1.0
                opacity = 0.8
            }
        }
    }
    
    private func getPhaseProgress(normalizedTime: Double) -> Double {
        let phaseStart: Double
        let phaseDuration: Double
        
        switch currentPhase {
        case .inhale:
            phaseStart = 0.0
            phaseDuration = 6.0/22.0 // 6 seconds out of 22
        case .holdInhale:
            phaseStart = 6.0/22.0
            phaseDuration = 4.0/22.0 // 4 seconds out of 22
        case .exhale:
            phaseStart = 10.0/22.0
            phaseDuration = 8.0/22.0 // 8 seconds out of 22
        case .holdExhale:
            phaseStart = 18.0/22.0
            phaseDuration = 4.0/22.0 // 4 seconds out of 22
        }
        
        let phaseTime = normalizedTime - phaseStart
        return max(0, min(1, phaseTime / phaseDuration))
    }
}

enum BreathingPhase: CaseIterable {
    case inhale
    case holdInhale
    case exhale
    case holdExhale
    
    var displayName: String {
        switch self {
        case .inhale: return "INSPIRA"
        case .holdInhale: return "MANTÉN"
        case .exhale: return "EXPIRA"
        case .holdExhale: return "PAUSA"
        }
    }
    
    var instruction: String {
        switch self {
        case .inhale: return "Llena tus pulmones"
        case .holdInhale: return "Retén la respiración"
        case .exhale: return "Libera el aire"
        case .holdExhale: return "Momento de calma"
        }
    }
    
    var color: Color {
        switch self {
        case .inhale: return .cyan
        case .holdInhale: return .blue
        case .exhale: return .purple
        case .holdExhale: return .pink
        }
    }
    
    var hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .inhale: return .light
        case .holdInhale: return .medium
        case .exhale: return .heavy
        case .holdExhale: return .light
        }
    }
}

// MARK: - Breathing Guide View

struct BreathingGuideView: View {
    @State private var currentPhase: BreathingPhase = .inhale
    @State private var isBreathingActive = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Title
            Text("Respiración + Anclaje Energético")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .shadow(color: .cyan, radius: 5)
            
            // Breathing circle
            BreathingCircleView(
                duration: 4.0,
                isActive: isBreathingActive,
                onBreathingPhaseChange: { phase in
                    currentPhase = phase
                }
            )
            
            // Breathing instructions
            VStack(spacing: 16) {
                Text("Sigue el ritmo de respiración para preparar tu energía")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Phase progress indicator
                HStack(spacing: 12) {
                    ForEach(BreathingPhase.allCases, id: \.self) { phase in
                        Circle()
                            .fill(phase == currentPhase ? phase.color : Color.white.opacity(0.3))
                            .frame(width: 12, height: 12)
                            .scaleEffect(phase == currentPhase ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: currentPhase)
                    }
                }
            }
            
            // Control buttons
            HStack(spacing: 20) {
                Button(action: {
                    isBreathingActive.toggle()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: isBreathingActive ? "pause.circle.fill" : "play.circle.fill")
                            .font(.title2)
                        Text(isBreathingActive ? "Pausar" : "Iniciar")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [.cyan, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .cyan, radius: 10)
                    )
                }
                
                Button(action: {
                    // Reset breathing
                    isBreathingActive = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isBreathingActive = true
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.title2)
                        Text("Reiniciar")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .purple, radius: 10)
                    )
                }
            }
        }
        .padding()
    }
}

#Preview {
    ZStack {
        CosmicBackgroundView()
        BreathingGuideView()
    }
}
