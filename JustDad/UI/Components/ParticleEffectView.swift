import SwiftUI

struct ParticleEffectView: View {
    let particleCount: Int
    let colors: [Color]
    let animationDuration: Double
    let particleSize: CGFloat
    
    @State private var particles: [Particle] = []
    @State private var animationTimer: Timer?
    
    init(
        particleCount: Int = 50,
        colors: [Color] = [.pink, .purple, .blue, .cyan],
        animationDuration: Double = 3.0,
        particleSize: CGFloat = 4.0
    ) {
        self.particleCount = particleCount
        self.colors = colors
        self.animationDuration = animationDuration
        self.particleSize = particleSize
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles, id: \.id) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .opacity(particle.opacity)
                        .position(particle.position)
                        .scaleEffect(particle.scale)
                        .blur(radius: particle.blur)
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
                startAnimation()
            }
            .onDisappear {
                stopAnimation()
            }
        }
        .clipped()
    }
    
    private func createParticles(in size: CGSize) {
        particles = (0..<particleCount).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                ),
                color: colors.randomElement() ?? .pink,
                size: particleSize * CGFloat.random(in: 0.5...1.5),
                opacity: Double.random(in: 0.3...1.0),
                scale: CGFloat.random(in: 0.5...1.5),
                blur: CGFloat.random(in: 0...2),
                velocity: CGPoint(
                    x: CGFloat.random(in: -20...20),
                    y: CGFloat.random(in: -30...10)
                )
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
        withAnimation(.linear(duration: 0.016)) {
            for i in particles.indices {
                particles[i].position.x += particles[i].velocity.x * 0.016
                particles[i].position.y += particles[i].velocity.y * 0.016
                
                // Wrap around screen
                if particles[i].position.x < 0 {
                    particles[i].position.x = UIScreen.main.bounds.width
                } else if particles[i].position.x > UIScreen.main.bounds.width {
                    particles[i].position.x = 0
                }
                
                if particles[i].position.y < 0 {
                    particles[i].position.y = UIScreen.main.bounds.height
                } else if particles[i].position.y > UIScreen.main.bounds.height {
                    particles[i].position.y = 0
                }
                
                // Update opacity for floating effect
                let time = Date().timeIntervalSince1970
                particles[i].opacity = 0.5 + 0.5 * sin(time * 2 + Double(i))
                particles[i].scale = 0.8 + 0.4 * sin(time * 1.5 + Double(i))
            }
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let color: Color
    let size: CGFloat
    var opacity: Double
    var scale: CGFloat
    var blur: CGFloat
    let velocity: CGPoint
}

// MARK: - Specialized Particle Effects

struct CosmicParticleEffect: View {
    var body: some View {
        ParticleEffectView(
            particleCount: 80,
            colors: [.cyan, .blue, .purple, .pink, .white],
            animationDuration: 4.0,
            particleSize: 3.0
        )
    }
}

struct HealingParticleEffect: View {
    var body: some View {
        ParticleEffectView(
            particleCount: 60,
            colors: [.green, .mint, .yellow, .orange],
            animationDuration: 3.5,
            particleSize: 4.0
        )
    }
}

struct LiberationParticleEffect: View {
    var body: some View {
        ParticleEffectView(
            particleCount: 100,
            colors: [.yellow, .orange, .pink, .red],
            animationDuration: 2.5,
            particleSize: 2.5
        )
    }
}

#Preview {
    ZStack {
        Color.black
        CosmicParticleEffect()
    }
}
