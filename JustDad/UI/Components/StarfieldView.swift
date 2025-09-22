import SwiftUI

struct StarfieldView: View {
    let starCount: Int
    let animationSpeed: Double
    
    @State private var stars: [Star] = []
    @State private var animationTimer: Timer?
    
    init(starCount: Int = 100, animationSpeed: Double = 1.0) {
        self.starCount = starCount
        self.animationSpeed = animationSpeed
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(stars, id: \.id) { star in
                    Circle()
                        .fill(star.color)
                        .frame(width: star.size, height: star.size)
                        .opacity(star.opacity)
                        .position(star.position)
                        .blur(radius: star.blur)
                }
            }
            .onAppear {
                createStars(in: geometry.size)
                startAnimation()
            }
            .onDisappear {
                stopAnimation()
            }
        }
        .clipped()
    }
    
    private func createStars(in size: CGSize) {
        stars = (0..<starCount).map { _ in
            Star(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                ),
                size: CGFloat.random(in: 1...4),
                opacity: Double.random(in: 0.3...1.0),
                color: [.white, .cyan, .blue, .purple].randomElement() ?? .white,
                blur: CGFloat.random(in: 0...1),
                twinklePhase: Double.random(in: 0...(.pi * 2))
            )
        }
    }
    
    private func startAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateStars()
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func updateStars() {
        let time = Date().timeIntervalSince1970 * animationSpeed
        
        for i in stars.indices {
            // Twinkling effect
            stars[i].opacity = 0.3 + 0.7 * sin(time * 2 + stars[i].twinklePhase)
            
            // Subtle movement
            let drift = sin(time * 0.5 + Double(i) * 0.1) * 2
            stars[i].position.y += drift * 0.016
        }
    }
}

struct Star: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    var opacity: Double
    let color: Color
    let blur: CGFloat
    let twinklePhase: Double
}

struct ShootingStarView: View {
    @State private var shootingStars: [ShootingStar] = []
    @State private var animationTimer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(shootingStars, id: \.id) { star in
                    Path { path in
                        path.move(to: star.startPoint)
                        path.addLine(to: star.endPoint)
                    }
                    .stroke(
                        LinearGradient(
                            colors: [star.color, .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: star.lineWidth, lineCap: .round)
                    )
                    .opacity(star.opacity)
                }
            }
            .onAppear {
                startShootingStars(in: geometry.size)
            }
            .onDisappear {
                stopAnimation()
            }
        }
        .clipped()
    }
    
    private func startShootingStars(in size: CGSize) {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            createShootingStar(in: size)
        }
    }
    
    private func createShootingStar(in size: CGSize) {
        let startX = CGFloat.random(in: 0...size.width * 0.3)
        let startY = CGFloat.random(in: 0...size.height * 0.3)
        let endX = startX + CGFloat.random(in: 100...200)
        let endY = startY + CGFloat.random(in: 100...200)
        
        let shootingStar = ShootingStar(
            startPoint: CGPoint(x: startX, y: startY),
            endPoint: CGPoint(x: endX, y: endY),
            color: [.white, .cyan, .blue].randomElement() ?? .white,
            lineWidth: CGFloat.random(in: 1...3),
            opacity: 1.0,
            duration: Double.random(in: 0.5...1.5)
        )
        
        shootingStars.append(shootingStar)
        
        // Animate the shooting star
        withAnimation(.linear(duration: shootingStar.duration)) {
            if let index = shootingStars.firstIndex(where: { $0.id == shootingStar.id }) {
                shootingStars[index].opacity = 0
            }
        }
        
        // Remove after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + shootingStar.duration) {
            shootingStars.removeAll { $0.id == shootingStar.id }
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
}

struct ShootingStar: Identifiable {
    let id = UUID()
    let startPoint: CGPoint
    let endPoint: CGPoint
    let color: Color
    let lineWidth: CGFloat
    var opacity: Double
    let duration: Double
}

struct CosmicBackgroundView: View {
    var body: some View {
        ZStack {
            // Base cosmic gradient
            RadialGradient(
                colors: [.black, .purple.opacity(0.3), .black],
                center: .center,
                startRadius: 50,
                endRadius: 400
            )
            
            // Starfield
            StarfieldView(starCount: 80, animationSpeed: 0.5)
            
            // Shooting stars
            ShootingStarView()
            
            // Nebula effects
            RadialGradient(
                colors: [.cyan.opacity(0.1), .clear],
                center: .topLeading,
                startRadius: 50,
                endRadius: 200
            )
            
            RadialGradient(
                colors: [.pink.opacity(0.1), .clear],
                center: .bottomTrailing,
                startRadius: 50,
                endRadius: 200
            )
        }
    }
}

#Preview {
    CosmicBackgroundView()
        .frame(width: 400, height: 800)
}
