import SwiftUI

struct BreathingCountdownView: View {
    let breathingPhase: BreathingPhase
    let isActive: Bool
    let onPhaseComplete: () -> Void
    
    @State private var countdownValue: Int = 4
    @State private var showCountdown: Bool = false
    @State private var animationProgress: Double = 0.0
    
    init(
        breathingPhase: BreathingPhase = .inhale,
        isActive: Bool = true,
        onPhaseComplete: @escaping () -> Void = {}
    ) {
        self.breathingPhase = breathingPhase
        self.isActive = isActive
        self.onPhaseComplete = onPhaseComplete
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Main countdown display
            ZStack {
                // Background circle
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                breathingPhase.color.opacity(0.3),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 8
                    )
                    .frame(width: 120, height: 120)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: animationProgress)
                    .stroke(
                        LinearGradient(
                            colors: [
                                breathingPhase.color,
                                breathingPhase.color.opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: breathingPhase.color, radius: 10)
                
                // Countdown number
                Text("\(countdownValue)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: breathingPhase.color, radius: 5)
                    .scaleEffect(showCountdown ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: showCountdown)
            }
            
            // Phase indicator
            VStack(spacing: 8) {
                Text(breathingPhase.displayName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: breathingPhase.color, radius: 5)
                
                Text(breathingPhase.instruction)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .shadow(color: breathingPhase.color, radius: 3)
            }
            
            // Animated arrows
            BreathingArrowsView(breathingPhase: breathingPhase, isActive: isActive)
            
            // Breathing rhythm indicator
            BreathingRhythmView(breathingPhase: breathingPhase, isActive: isActive)
        }
        .onAppear {
            if isActive {
                startCountdown()
            }
        }
        .onChange(of: breathingPhase) { _, _ in
            resetCountdown()
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                startCountdown()
            }
        }
    }
    
    private func startCountdown() {
        countdownValue = getCountdownValue(for: breathingPhase)
        showCountdown = true
        
        withAnimation(.linear(duration: getPhaseDuration())) {
            animationProgress = 1.0
        }
        
        // Countdown animation
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if countdownValue > 0 {
                countdownValue -= 1
                showCountdown.toggle()
            } else {
                timer.invalidate()
                onPhaseComplete()
            }
        }
        
        // Clean up timer after phase duration
        DispatchQueue.main.asyncAfter(deadline: .now() + getPhaseDuration()) {
            timer.invalidate()
        }
    }
    
    private func resetCountdown() {
        countdownValue = getCountdownValue(for: breathingPhase)
        animationProgress = 0.0
        showCountdown = false
    }
    
    private func getCountdownValue(for phase: BreathingPhase) -> Int {
        switch phase {
        case .inhale: return 6
        case .holdInhale: return 4
        case .exhale: return 8
        case .holdExhale: return 4
        }
    }
    
    private func getPhaseDuration() -> Double {
        switch breathingPhase {
        case .inhale: return 6.0
        case .holdInhale: return 4.0
        case .exhale: return 8.0
        case .holdExhale: return 4.0
        }
    }
}

// MARK: - Breathing Arrows View

struct BreathingArrowsView: View {
    let breathingPhase: BreathingPhase
    let isActive: Bool
    
    @State private var arrowScale: CGFloat = 1.0
    @State private var arrowOpacity: Double = 1.0
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: getArrowIcon())
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(breathingPhase.color)
                    .scaleEffect(arrowScale)
                    .opacity(arrowOpacity)
                    .animation(
                        .easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: arrowScale
                    )
            }
        }
        .onAppear {
            if isActive {
                startArrowAnimation()
            }
        }
        .onChange(of: breathingPhase) { _, _ in
            startArrowAnimation()
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                startArrowAnimation()
            }
        }
    }
    
    private func startArrowAnimation() {
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            arrowScale = 1.3
        }
        
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            arrowOpacity = 0.6
        }
    }
    
    private func getArrowIcon() -> String {
        switch breathingPhase {
        case .inhale:
            return "arrow.up.circle.fill"
        case .holdInhale:
            return "pause.circle.fill"
        case .exhale:
            return "arrow.down.circle.fill"
        case .holdExhale:
            return "circle.fill"
        }
    }
}

// MARK: - Breathing Rhythm View

struct BreathingRhythmView: View {
    let breathingPhase: BreathingPhase
    let isActive: Bool
    
    @State private var rhythmBars: [RhythmBar] = []
    @State private var animationTimer: Timer?
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(rhythmBars, id: \.id) { bar in
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [
                                breathingPhase.color.opacity(bar.opacity),
                                breathingPhase.color.opacity(bar.opacity * 0.5)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 8, height: bar.height)
                    .scaleEffect(bar.scale)
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever(autoreverses: true)
                        .delay(bar.delay),
                        value: bar.scale
                    )
            }
        }
        .onAppear {
            createRhythmBars()
            if isActive {
                startRhythmAnimation()
            }
        }
        .onDisappear {
            stopRhythmAnimation()
        }
        .onChange(of: breathingPhase) { _, _ in
            updateRhythmBars()
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                startRhythmAnimation()
            } else {
                stopRhythmAnimation()
            }
        }
    }
    
    private func createRhythmBars() {
        rhythmBars = (0..<8).map { index in
            RhythmBar(
                height: CGFloat.random(in: 20...60),
                opacity: Double.random(in: 0.4...0.8),
                scale: 1.0,
                delay: Double(index) * 0.1
            )
        }
    }
    
    private func startRhythmAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            updateRhythmBars()
        }
    }
    
    private func stopRhythmAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func updateRhythmBars() {
        for i in rhythmBars.indices {
            let intensity = getBreathingIntensity()
            rhythmBars[i].height = CGFloat.random(in: 20...60) * intensity
            rhythmBars[i].opacity = Double.random(in: 0.4...0.8) * intensity
            rhythmBars[i].scale = 1.0 + CGFloat.random(in: 0...0.3) * intensity
        }
    }
    
    private func getBreathingIntensity() -> CGFloat {
        switch breathingPhase {
        case .inhale:
            return 1.2
        case .holdInhale:
            return 0.8
        case .exhale:
            return 1.5
        case .holdExhale:
            return 0.6
        }
    }
}

struct RhythmBar: Identifiable {
    let id = UUID()
    var height: CGFloat
    var opacity: Double
    var scale: CGFloat
    let delay: Double
}

#Preview {
    ZStack {
        CosmicBackgroundView()
        BreathingCountdownView(breathingPhase: .inhale, isActive: true)
    }
}
