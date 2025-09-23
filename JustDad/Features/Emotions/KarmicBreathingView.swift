import SwiftUI

struct KarmicBreathingView: View {
    @ObservedObject var karmicEngine: KarmicEngine
    @State private var currentPhase: KarmicBreathingPhase = .inhale
    @State private var progress: Double = 0.0
    @State private var cycleCount = 0
    @State private var isCompleted = false
    
    private let totalCycles = 3
    private let phaseDuration: Double = 4.0 // 4 segundos por fase
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 16) {
                Text("Preparación Respiratoria")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Conecta con tu respiración para preparar la liberación")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            if !isCompleted {
                // Círculo de respiración
                ZStack {
                    // Círculo de fondo
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 4)
                        .frame(width: 200, height: 200)
                    
                    // Círculo de progreso
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [.purple, .indigo, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.1), value: progress)
                    
                    // Indicador de fase
                    VStack(spacing: 8) {
                        Text(phaseText)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("Ciclo \(cycleCount + 1) de \(totalCycles)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                // Instrucciones
                VStack(spacing: 8) {
                    Text("Sigue el ritmo visual")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(phaseInstruction)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
            } else {
                // Completado
                VStack(spacing: 24) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    Text("¡Excelente!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Tu respiración está preparada para la liberación")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    Button("Continuar") {
                        karmicEngine.completeBreathing()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.purple, .indigo],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .onAppear {
            startBreathingExercise()
        }
    }
    
    private var phaseText: String {
        switch currentPhase {
        case .inhale: return "Inhala"
        case .hold: return "Mantén"
        case .exhale: return "Exhala"
        case .pause: return "Pausa"
        }
    }
    
    private var phaseInstruction: String {
        switch currentPhase {
        case .inhale: return "Llena tus pulmones suavemente"
        case .hold: return "Mantén la respiración por un momento"
        case .exhale: return "Libera el aire lentamente"
        case .pause: return "Descansa un momento"
        }
    }
    
    private func startBreathingExercise() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            progress += 0.1 / phaseDuration
            
            if progress >= 1.0 {
                // Cambiar a la siguiente fase
                switch currentPhase {
                case .inhale:
                    currentPhase = .hold
                case .hold:
                    currentPhase = .exhale
                case .exhale:
                    currentPhase = .pause
                case .pause:
                    currentPhase = .inhale
                    cycleCount += 1
                    
                    if cycleCount >= totalCycles {
                        timer.invalidate()
                        isCompleted = true
                        return
                    }
                }
                progress = 0.0
            }
        }
    }
}

#Preview {
    KarmicBreathingView(karmicEngine: KarmicEngine())
}
