import SwiftUI

struct RitualWelcomeView: View {
    @ObservedObject var ritualEngine: RitualEngine
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icono del ritual
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple.opacity(0.3), .blue.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(
                            .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .opacity(isAnimating ? 0.8 : 1.0)
                        .animation(
                            .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
                
                Text("Ritual de Liberación")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            
            // Mensaje principal
            VStack(spacing: 16) {
                Text("Este ritual no justifica el pasado")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Te libera para elegir mejor hoy")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            
            // Información del ritual
            VStack(spacing: 12) {
                RitualInfoRow(
                    icon: "clock",
                    title: "Duración",
                    value: "10-15 minutos"
                )
                
                RitualInfoRow(
                    icon: "waveform",
                    title: "Incluye",
                    value: "Respiración guiada y voz"
                )
                
                RitualInfoRow(
                    icon: "shield.checkered",
                    title: "Privacidad",
                    value: "Todo se guarda localmente"
                )
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Botón de comenzar
            Button(action: {
                ritualEngine.startRitual()
            }) {
                HStack {
                    Text("Comenzar Ritual")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Image(systemName: "arrow.right")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            .padding(.horizontal, 20)
            .scaleEffect(isAnimating ? 1.02 : 1.0)
            .animation(
                .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                value: isAnimating
            )
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Info Row Component
struct RitualInfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        CosmicBackgroundView()
        RitualWelcomeView(ritualEngine: RitualEngine())
    }
}
