import SwiftUI

struct PremiumEmotionCard: View {
    let emotion: EmotionalState
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var pulseAnimation = false
    @State private var glowAnimation = false
    
    var body: some View {
        Button(action: {
            onTap()
        }) {
            VStack(spacing: 16) {
                // Emotion icon with premium effects
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [emotion.color.opacity(0.3), emotion.color.opacity(0.1), Color.clear],
                                center: .center,
                                startRadius: 5,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)
                        .scaleEffect(glowAnimation ? 1.2 : 1.0)
                        .opacity(glowAnimation ? 0.6 : 0.3)
                        .animation(
                            .easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                            value: glowAnimation
                        )
                    
                    // Pulse ring
                    Circle()
                        .stroke(emotion.color.opacity(0.6), lineWidth: 2)
                        .frame(width: 60, height: 60)
                        .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                        .opacity(pulseAnimation ? 0.0 : 0.8)
                        .animation(
                            .easeOut(duration: 1.5)
                            .repeatForever(autoreverses: false),
                            value: pulseAnimation
                        )
                    
                    // Main icon
                    Image(systemName: emotion.icon)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)
                        .shadow(color: emotion.color, radius: 10)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isSelected)
                }
                
                // Emotion name and description
                VStack(spacing: 6) {
                    Text(emotion.displayName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(getEmotionDescription())
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                
                // Energy level indicator
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        Circle()
                            .fill(index < getEnergyLevel() ? emotion.color : Color.white.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
            }
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .background(
                ZStack {
                    // Base gradient
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: isSelected ? 
                                    [emotion.color.opacity(0.3), emotion.color.opacity(0.1)] :
                                    [Color.black.opacity(0.4), Color.black.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Border gradient
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: isSelected ? 
                                    [emotion.color, emotion.color.opacity(0.5)] :
                                    [Color.white.opacity(0.2), Color.white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isSelected ? 2 : 1
                        )
                    
                    // Shimmer effect when selected
                    if isSelected {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [Color.clear, emotion.color.opacity(0.3), Color.clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .scaleEffect(x: 2, y: 1)
                            .offset(x: -200)
                            .animation(
                                .linear(duration: 2.0)
                                .repeatForever(autoreverses: false),
                                value: Date().timeIntervalSince1970
                            )
                    }
                }
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(
                color: isSelected ? emotion.color.opacity(0.5) : Color.black.opacity(0.3),
                radius: isSelected ? 15 : 8,
                x: 0,
                y: isSelected ? 8 : 4
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
        .onAppear {
            glowAnimation = true
            pulseAnimation = true
        }
    }
    
    private func getEmotionDescription() -> String {
        switch emotion {
        case .verySad:
            return "Profunda tristeza que necesita sanación"
        case .sad:
            return "Melancolía y dolor emocional"
        case .neutral:
            return "Estado equilibrado y centrado"
        case .happy:
            return "Alegría y bienestar emocional"
        case .veryHappy:
            return "Éxtasis y plenitud total"
        }
    }
    
    private func getEnergyLevel() -> Int {
        switch emotion {
        case .verySad:
            return 1
        case .sad:
            return 2
        case .neutral:
            return 3
        case .happy:
            return 4
        case .veryHappy:
            return 5
        }
    }
}

#Preview {
    ZStack {
        CosmicBackgroundView()
        
        VStack(spacing: 20) {
            PremiumEmotionCard(
                emotion: .sad,
                isSelected: false,
                onTap: {}
            )
            
            PremiumEmotionCard(
                emotion: .happy,
                isSelected: true,
                onTap: {}
            )
        }
        .padding()
    }
}
