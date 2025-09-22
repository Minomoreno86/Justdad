import SwiftUI

struct BreathingParticleEffect: View {
    let breathingPhase: BreathingPhase
    let isActive: Bool
    let particleCount: Int
    
    @State private var particles: [BreathingParticle] = []
    @State private var animationTimer: Timer?
    
    init(
        breathingPhase: BreathingPhase = .inhale,
        isActive: Bool = true,
        particleCount: Int = 30
    ) {
        self.breathingPhase = breathingPhase
        self.isActive = isActive
        self.particleCount = particleCount
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles, id: \.id) { particle in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    particle.color.opacity(particle.opacity),
                                    particle.color.opacity(particle.opacity * 0.3),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: particle.size / 2
                            )
                        )
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .scaleEffect(particle.scale)
                        .blur(radius: particle.blur)
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
                if isActive {
                    startAnimation()
                }
            }
            .onDisappear {
                stopAnimation()
            }
            .onChange(of: breathingPhase) { _ in
                updateParticleBehavior()
            }
            .onChange(of: isActive) { newValue in
                if newValue {
                    startAnimation()
                } else {
                    stopAnimation()
                }
            }
        }
        .clipped()
    }
    
    private func createParticles(in size: CGSize) {
        particles = (0..<particleCount).map { _ in
            BreathingParticle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                ),
                color: breathingPhase.color,
                size: CGFloat.random(in: 2...6),
                opacity: Double.random(in: 0.3...0.8),
                scale: CGFloat.random(in: 0.5...1.2),
                blur: CGFloat.random(in: 0...2),
                velocity: CGPoint(
                    x: CGFloat.random(in: -10...10),
                    y: CGFloat.random(in: -15...5)
                ),
                breathingIntensity: Double.random(in: 0.5...1.0)
            )
        }
    }
    
    private func startAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateParticles()
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func updateParticles() {
        let time = Date().timeIntervalSince1970
        
        for i in particles.indices {
            let particle = particles[i]
            let breathingEffect = getBreathingEffect(for: particle, time: time)
            
            // Update position with breathing flow
            particles[i].position.x += particle.velocity.x * 0.016 * breathingEffect.flowIntensity
            particles[i].position.y += particle.velocity.y * 0.016 * breathingEffect.flowIntensity
            
            // Apply breathing effects
            particles[i].scale = particle.scale * breathingEffect.scaleMultiplier
            particles[i].opacity = particle.opacity * breathingEffect.opacityMultiplier
            particles[i].blur = particle.blur * breathingEffect.blurMultiplier
            
            // Update color based on breathing phase
            particles[i].color = breathingPhase.color
            
            // Wrap around screen
            if particles[i].position.x < -50 {
                particles[i].position.x = UIScreen.main.bounds.width + 50
            } else if particles[i].position.x > UIScreen.main.bounds.width + 50 {
                particles[i].position.x = -50
            }
            
            if particles[i].position.y < -50 {
                particles[i].position.y = UIScreen.main.bounds.height + 50
            } else if particles[i].position.y > UIScreen.main.bounds.height + 50 {
                particles[i].position.y = -50
            }
        }
    }
    
    private func updateParticleBehavior() {
        // Update particle colors and behavior based on new breathing phase
        for i in particles.indices {
            particles[i].color = breathingPhase.color
            particles[i].breathingIntensity = Double.random(in: 0.5...1.0)
        }
    }
    
    private func getBreathingEffect(for particle: BreathingParticle, time: Double) -> BreathingEffect {
        let breathingCycle = sin(time * 2 + Double(particle.id.hashValue) * 0.1) * 0.5 + 0.5
        
        switch breathingPhase {
        case .inhale:
            return BreathingEffect(
                scaleMultiplier: 1.0 + breathingCycle * 0.3 * particle.breathingIntensity,
                opacityMultiplier: 0.7 + breathingCycle * 0.3 * particle.breathingIntensity,
                blurMultiplier: 1.0 - breathingCycle * 0.3,
                flowIntensity: 1.0 + breathingCycle * 0.5
            )
        case .holdInhale:
            return BreathingEffect(
                scaleMultiplier: 1.2 + sin(time * 4) * 0.1 * particle.breathingIntensity,
                opacityMultiplier: 1.0,
                blurMultiplier: 0.8,
                flowIntensity: 0.5
            )
        case .exhale:
            return BreathingEffect(
                scaleMultiplier: 1.3 - breathingCycle * 0.4 * particle.breathingIntensity,
                opacityMultiplier: 1.0 - breathingCycle * 0.4 * particle.breathingIntensity,
                blurMultiplier: 0.8 + breathingCycle * 0.4,
                flowIntensity: 1.5 + breathingCycle * 0.8
            )
        case .holdExhale:
            return BreathingEffect(
                scaleMultiplier: 0.9 + sin(time * 3) * 0.1 * particle.breathingIntensity,
                opacityMultiplier: 0.6,
                blurMultiplier: 1.2,
                flowIntensity: 0.3
            )
        }
    }
}

struct BreathingParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var color: Color
    let size: CGFloat
    var opacity: Double
    var scale: CGFloat
    var blur: CGFloat
    let velocity: CGPoint
    var breathingIntensity: Double
}

struct BreathingEffect {
    let scaleMultiplier: Double
    let opacityMultiplier: Double
    let blurMultiplier: Double
    let flowIntensity: Double
}

// MARK: - Breathing Flow Visualization

struct BreathingFlowView: View {
    let breathingPhase: BreathingPhase
    let isActive: Bool
    
    @State private var flowParticles: [FlowParticle] = []
    @State private var animationTimer: Timer?
    
    init(breathingPhase: BreathingPhase = .inhale, isActive: Bool = true) {
        self.breathingPhase = breathingPhase
        self.isActive = isActive
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Flow lines
                ForEach(flowParticles, id: \.id) { particle in
                    Path { path in
                        path.move(to: particle.startPoint)
                        path.addLine(to: particle.endPoint)
                    }
                    .stroke(
                        LinearGradient(
                            colors: [
                                breathingPhase.color.opacity(particle.opacity),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: particle.lineWidth, lineCap: .round)
                    )
                    .opacity(particle.opacity)
                }
            }
            .onAppear {
                createFlowParticles(in: geometry.size)
                if isActive {
                    startFlowAnimation()
                }
            }
            .onDisappear {
                stopFlowAnimation()
            }
            .onChange(of: breathingPhase) { _ in
                updateFlowDirection()
            }
            .onChange(of: isActive) { newValue in
                if newValue {
                    startFlowAnimation()
                } else {
                    stopFlowAnimation()
                }
            }
        }
        .clipped()
    }
    
    private func createFlowParticles(in size: CGSize) {
        flowParticles = (0..<20).map { _ in
            let startX = CGFloat.random(in: 0...size.width)
            let startY = CGFloat.random(in: 0...size.height)
            
            return FlowParticle(
                startPoint: CGPoint(x: startX, y: startY),
                endPoint: CGPoint(x: startX + CGFloat.random(in: -50...50), y: startY + CGFloat.random(in: -50...50)),
                lineWidth: CGFloat.random(in: 1...3),
                opacity: Double.random(in: 0.3...0.7),
                duration: Double.random(in: 2...4)
            )
        }
    }
    
    private func startFlowAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            updateFlowParticles()
        }
    }
    
    private func stopFlowAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func updateFlowParticles() {
        for i in flowParticles.indices {
            // Animate flow particles
            withAnimation(.linear(duration: flowParticles[i].duration)) {
                flowParticles[i].opacity = 0
            }
            
            // Reset particle after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + flowParticles[i].duration) {
                if i < flowParticles.count {
                    resetFlowParticle(at: i)
                }
            }
        }
    }
    
    private func resetFlowParticle(at index: Int) {
        let size = UIScreen.main.bounds.size
        let startX = CGFloat.random(in: 0...size.width)
        let startY = CGFloat.random(in: 0...size.height)
        
        flowParticles[index] = FlowParticle(
            startPoint: CGPoint(x: startX, y: startY),
            endPoint: CGPoint(x: startX + CGFloat.random(in: -50...50), y: startY + CGFloat.random(in: -50...50)),
            lineWidth: CGFloat.random(in: 1...3),
            opacity: Double.random(in: 0.3...0.7),
            duration: Double.random(in: 2...4)
        )
    }
    
    private func updateFlowDirection() {
        // Update flow direction based on breathing phase
        for i in flowParticles.indices {
            let flowDirection = getFlowDirection(for: breathingPhase)
            flowParticles[i].endPoint = CGPoint(
                x: flowParticles[i].startPoint.x + flowDirection.x * 50,
                y: flowParticles[i].startPoint.y + flowDirection.y * 50
            )
        }
    }
    
    private func getFlowDirection(for phase: BreathingPhase) -> CGPoint {
        switch phase {
        case .inhale:
            return CGPoint(x: 0, y: -1) // Flow inward/upward
        case .holdInhale:
            return CGPoint(x: 0, y: 0) // Minimal flow
        case .exhale:
            return CGPoint(x: 0, y: 1) // Flow outward/downward
        case .holdExhale:
            return CGPoint(x: 0, y: 0) // Minimal flow
        }
    }
}

struct FlowParticle: Identifiable {
    let id = UUID()
    var startPoint: CGPoint
    var endPoint: CGPoint
    let lineWidth: CGFloat
    var opacity: Double
    let duration: Double
}

#Preview {
    ZStack {
        CosmicBackgroundView()
        BreathingParticleEffect(breathingPhase: .inhale, isActive: true)
    }
}
