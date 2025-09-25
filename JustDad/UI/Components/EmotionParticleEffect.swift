import SwiftUI

struct EmotionParticleEffect: View {
    let emotion: EmotionalState
    let isActive: Bool
    let particleCount: Int = 15
    
    @State private var particles: [EmotionParticle] = []
    @State private var animationTimer: Timer?
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [emotion.color, emotion.color.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: particle.size / 2
                        )
                    )
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
                    .blur(radius: particle.blur)
            }
        }
        .onAppear {
            generateParticles()
            if isActive {
                startAnimation()
            }
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                startAnimation()
            } else {
                stopAnimation()
            }
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    private func generateParticles() {
        particles = (0..<particleCount).map { _ in
            EmotionParticle(
                id: UUID(),
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                ),
                size: CGFloat.random(in: 4...12),
                opacity: Double.random(in: 0.3...0.8),
                scale: Double.random(in: 0.5...1.2),
                blur: CGFloat.random(in: 0...3),
                speed: Double.random(in: 0.5...2.0),
                direction: Double.random(in: 0...(2 * .pi))
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
        for i in 0..<particles.count {
            let particle = particles[i]
            
            // Update position
            let newX = particle.position.x + cos(particle.direction) * particle.speed
            let newY = particle.position.y + sin(particle.direction) * particle.speed
            
            // Wrap around screen
            let wrappedX = newX.truncatingRemainder(dividingBy: UIScreen.main.bounds.width)
            let wrappedY = newY.truncatingRemainder(dividingBy: UIScreen.main.bounds.height)
            
            // Update opacity with breathing effect
            let time = Date().timeIntervalSince1970
            let breathingOpacity = 0.5 + 0.3 * sin(time * 2.0 + Double(i) * 0.5)
            
            particles[i] = EmotionParticle(
                id: particle.id,
                position: CGPoint(x: wrappedX, y: wrappedY),
                size: particle.size,
                opacity: breathingOpacity,
                scale: particle.scale,
                blur: particle.blur,
                speed: particle.speed,
                direction: particle.direction
            )
        }
    }
}

struct EmotionParticle: Identifiable {
    let id: UUID
    var position: CGPoint
    let size: CGFloat
    var opacity: Double
    let scale: Double
    let blur: CGFloat
    let speed: Double
    let direction: Double
}

// MARK: - Emotional Energy Field

struct EmotionalEnergyField: View {
    let emotion: EmotionalState
    let intensity: Double // 0.0 to 1.0
    
    @State private var waveOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Multiple wave layers
            ForEach(0..<3, id: \.self) { layer in
                WaveLayer(
                    emotion: emotion,
                    offset: waveOffset + CGFloat(layer) * 0.3,
                    intensity: intensity,
                    speed: 1.0 + Double(layer) * 0.5
                )
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                waveOffset = .pi * 2
            }
        }
    }
}

struct WaveLayer: View {
    let emotion: EmotionalState
    let offset: CGFloat
    let intensity: Double
    let speed: Double
    
    var body: some View {
        Canvas { context, size in
            let path = Path { path in
                let waveHeight = size.height * 0.1 * intensity
                let frequency = 3.0
                
                path.move(to: CGPoint(x: 0, y: size.height / 2))
                
                for x in stride(from: 0, through: size.width, by: 1) {
                    let relativeX = x / size.width
                    let sine = sin(relativeX * frequency * .pi + offset * speed)
                    let y = size.height / 2 + sine * waveHeight
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            
            context.stroke(
                path,
                with: .linearGradient(
                    Gradient(colors: [
                        emotion.color.opacity(0.8 * intensity),
                        emotion.color.opacity(0.3 * intensity),
                        Color.clear
                    ]),
                    startPoint: CGPoint(x: 0, y: 0),
                    endPoint: CGPoint(x: 0, y: size.height)
                ),
                lineWidth: 2
            )
        }
    }
}

#Preview {
    ZStack {
        CosmicBackgroundView()
        
        VStack {
            EmotionParticleEffect(
                emotion: .happy,
                isActive: true
            )
            
            EmotionalEnergyField(
                emotion: .sad,
                intensity: 0.7
            )
        }
    }
}
