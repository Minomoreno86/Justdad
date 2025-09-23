import SwiftUI

struct RitualSealingView: View {
    @ObservedObject var ritualEngine: RitualEngine
    @State private var sealingProgress: Double = 0.0
    @State private var isSealing = false
    @State private var showSealingAnimation = false
    @State private var isRecording = false
    @State private var sealingComplete = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Título
                VStack(spacing: 12) {
                    Text("Sellado y Protección")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Sella el cierre y protégete energéticamente")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                // Visualización de la esfera dorada
                GoldenSphereView(
                    progress: sealingProgress,
                    showAnimation: showSealingAnimation,
                    isComplete: sealingComplete
                )
                .frame(height: 250)
                .padding(.horizontal, 20)
                
                // Texto de sellado
                VStack(spacing: 16) {
                    Text("Afirmación de Sellado")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 12) {
                        ForEach(sealingAffirmations, id: \.self) { affirmation in
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                                
                                Text(affirmation)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.white.opacity(0.1))
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Grabación de voz
                if !sealingComplete {
                    VoiceSealingSection(
                        isRecording: $isRecording,
                        onComplete: {
                            sealingComplete = true
                            startSealingAnimation()
                        }
                    )
                    .padding(.horizontal, 20)
                }
                
                // Estado de sellado
                if sealingComplete {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                            
                            Text("Sellado Completado")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        
                        Text("Has sido protegido energéticamente")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.green.opacity(0.2))
                    )
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Botón de continuar
                if sealingComplete {
                    Button(action: {
                        ritualEngine.completeSealing()
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title3)
                            
                            Text("Continuar a Renovación")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [.green, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 20) // Agregar padding al final para que no se corte
        }
    }
    
    private let sealingAffirmations = [
        "Estoy libre",
        "Estoy en paz",
        "El pasado no me gobierna",
        "Soy un padre presente",
        "Eligo mi camino con libertad"
    ]
    
    private func startSealingAnimation() {
        isSealing = true
        showSealingAnimation = true
        
        withAnimation(.easeInOut(duration: 3.0)) {
            sealingProgress = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isSealing = false
        }
    }
}

// MARK: - Golden Sphere View
struct GoldenSphereView: View {
    let progress: Double
    let showAnimation: Bool
    let isComplete: Bool
    
    var body: some View {
        ZStack {
            // Fondo
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [.yellow.opacity(0.2), .orange.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Esfera dorada
            ZStack {
                // Esfera principal
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .yellow.opacity(0.9),
                                .orange.opacity(0.7),
                                .red.opacity(0.5)
                            ],
                            center: .topLeading,
                            startRadius: 10,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(isComplete ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isComplete)
                
                // Anillos de energía
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.yellow.opacity(0.8), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 3, dash: [5, 5])
                        )
                        .frame(width: 180 + CGFloat(index * 20), height: 180 + CGFloat(index * 20))
                        .scaleEffect(showAnimation ? 1.2 : 1.0)
                        .opacity(showAnimation ? 0.6 : 0.3)
                        .animation(
                            .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: showAnimation
                        )
                }
                
                // Partículas doradas
                if showAnimation {
                    ForEach(0..<8, id: \.self) { index in
                        Circle()
                            .fill(.yellow)
                            .frame(width: 4, height: 4)
                            .offset(
                                x: cos(Double(index) * .pi / 4) * 100,
                                y: sin(Double(index) * .pi / 4) * 100
                            )
                            .opacity(showAnimation ? 0.8 : 0.0)
                            .animation(
                                .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                                value: showAnimation
                            )
                    }
                }
            }
        }
    }
}

// MARK: - Voice Sealing Section
struct VoiceSealingSection: View {
    @Binding var isRecording: Bool
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Pronuncia la afirmación de sellado")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                Text("Estoy libre")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                
                // Botón de grabación
                Button(action: {
                    if isRecording {
                        // Simular finalización de grabación
                        onComplete()
                    } else {
                        isRecording = true
                        // Simular grabación después de 2 segundos
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            onComplete()
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.title3)
                        
                        Text(isRecording ? "Grabando..." : "Graba tu afirmación")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: isRecording ? [.red, .orange] : [.yellow, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        CosmicBackgroundView()
        RitualSealingView(ritualEngine: RitualEngine())
    }
}
