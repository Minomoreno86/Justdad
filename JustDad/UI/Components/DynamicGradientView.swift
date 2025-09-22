import SwiftUI

struct DynamicGradientView: View {
    let colors: [Color]
    let startPoint: UnitPoint
    let endPoint: UnitPoint
    let animationDuration: Double
    
    @State private var animationPhase: Double = 0
    
    init(
        colors: [Color] = [.purple, .blue, .cyan, .pink],
        startPoint: UnitPoint = .topLeading,
        endPoint: UnitPoint = .bottomTrailing,
        animationDuration: Double = 3.0
    ) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.animationDuration = animationDuration
    }
    
    var body: some View {
        LinearGradient(
            colors: animatedColors,
            startPoint: animatedStartPoint,
            endPoint: animatedEndPoint
        )
        .onAppear {
            startAnimation()
        }
    }
    
    private var animatedColors: [Color] {
        colors.map { color in
            color.opacity(0.7 + 0.3 * sin(animationPhase))
        }
    }
    
    private var animatedStartPoint: UnitPoint {
        let offset = sin(animationPhase * 0.5) * 0.2
        return UnitPoint(
            x: max(0, min(1, startPoint.x + offset)),
            y: max(0, min(1, startPoint.y + offset))
        )
    }
    
    private var animatedEndPoint: UnitPoint {
        let offset = cos(animationPhase * 0.5) * 0.2
        return UnitPoint(
            x: max(0, min(1, endPoint.x - offset)),
            y: max(0, min(1, endPoint.y - offset))
        )
    }
    
    private func startAnimation() {
        withAnimation(.linear(duration: animationDuration).repeatForever(autoreverses: false)) {
            animationPhase = .pi * 2
        }
    }
}

// MARK: - Specialized Gradient Views

struct CosmicGradient: View {
    var body: some View {
        DynamicGradientView(
            colors: [.black, .purple, .blue, .cyan, .black],
            startPoint: .topLeading,
            endPoint: .bottomTrailing,
            animationDuration: 4.0
        )
    }
}

struct HealingGradient: View {
    var body: some View {
        DynamicGradientView(
            colors: [.mint, .green, .yellow, .orange],
            startPoint: .center,
            endPoint: .topTrailing,
            animationDuration: 3.5
        )
    }
}

struct LiberationGradient: View {
    var body: some View {
        DynamicGradientView(
            colors: [.yellow, .orange, .pink, .red, .purple],
            startPoint: .bottomLeading,
            endPoint: .topTrailing,
            animationDuration: 2.5
        )
    }
}

struct DepthBackgroundView: View {
    var body: some View {
        ZStack {
            // Base gradient
            CosmicGradient()
            
            // Overlay gradient for depth
            RadialGradient(
                colors: [.clear, .black.opacity(0.3)],
                center: .center,
                startRadius: 50,
                endRadius: 300
            )
            
            // Additional depth layers
            RadialGradient(
                colors: [.cyan.opacity(0.1), .clear],
                center: .topLeading,
                startRadius: 20,
                endRadius: 200
            )
            
            RadialGradient(
                colors: [.pink.opacity(0.1), .clear],
                center: .bottomTrailing,
                startRadius: 20,
                endRadius: 200
            )
        }
    }
}

#Preview {
    ZStack {
        DepthBackgroundView()
        Text("Preview")
            .foregroundColor(.white)
            .font(.title)
    }
}
