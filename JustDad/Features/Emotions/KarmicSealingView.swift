import SwiftUI

struct KarmicSealingView: View {
    @ObservedObject var karmicEngine: KarmicEngine
    @State private var sealingProgress: Double = 0.0
    @State private var isSealing = false
    @State private var isCompleted = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Text("Sellado y Protección")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Sella la liberación y crea una esfera de protección")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Visualización del sellado
                ZStack {
                    // Esfera de protección
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.green, .blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 250, height: 250)
                        .opacity(isCompleted ? 1.0 : 0.3)
                        .scaleEffect(isCompleted ? 1.0 : 0.8)
                        .animation(.easeInOut(duration: 0.5), value: isCompleted)
                    
                    // Progreso del sellado
                    if isSealing {
                        Circle()
                            .trim(from: 0, to: sealingProgress)
                            .stroke(
                                LinearGradient(
                                    colors: [.green, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 250, height: 250)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.1), value: sealingProgress)
                    }
                    
                    // Centro de la esfera
                    VStack(spacing: 8) {
                        if isCompleted {
                            Image(systemName: "shield.checkered")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                                .symbolEffect(.bounce)
                        } else {
                            Image(systemName: "shield")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Text(isCompleted ? "Protegido" : "Sellando...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                
                // Texto del sellado
                VStack(alignment: .leading, spacing: 16) {
                    Text("Afirmación de Sellado")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(getSealingAffirmation())
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .lineSpacing(6)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                }
                
                // Instrucciones
                VStack(alignment: .leading, spacing: 16) {
                    Text("Proceso de Sellado")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        SealingStepRow(
                            number: 1,
                            text: "Visualiza una esfera dorada de luz a tu alrededor",
                            isCompleted: sealingProgress > 0.2
                        )
                        
                        SealingStepRow(
                            number: 2,
                            text: "Imagina que esta esfera te protege de energías negativas",
                            isCompleted: sealingProgress > 0.5
                        )
                        
                        SealingStepRow(
                            number: 3,
                            text: "Repite mentalmente la afirmación de sellado",
                            isCompleted: sealingProgress > 0.8
                        )
                        
                        SealingStepRow(
                            number: 4,
                            text: "Siente cómo la protección se activa completamente",
                            isCompleted: isCompleted
                        )
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                }
                
                // Botón de sellado
                if !isSealing && !isCompleted {
                    Button(action: startSealing) {
                        HStack {
                            Image(systemName: "shield.lefthalf.filled")
                            Text("Iniciar Sellado de Protección")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.green, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                }
                
                // Estado de sellado
                if isSealing {
                    VStack(spacing: 16) {
                        Text("Sellando protección...")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ProgressView(value: sealingProgress, total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle(tint: .green))
                            .frame(height: 8)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(4)
                        
                        Text("\(Int(sealingProgress * 100))%")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal, 40)
                }
                
                // Completado
                if isCompleted {
                    VStack(spacing: 16) {
                        Text("¡Protección activada!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("Tu esfera de protección está activa. Ahora procederemos con la renovación.")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        Button("Continuar a la Renovación") {
                            karmicEngine.completeSealing()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.green, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                }
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func getSealingAffirmation() -> String {
        return """
        "Me rodeo con una esfera de luz dorada que me protege de todas las energías negativas. 
        Esta protección es permanente y se activa cada vez que la necesite. 
        Estoy seguro, protegido y en paz. 
        Solo las energías positivas y amorosas pueden entrar en mi espacio sagrado."
        """
    }
    
    private func startSealing() {
        isSealing = true
        sealingProgress = 0.0
        
        // Simular el proceso de sellado
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            sealingProgress += 0.02
            
            if sealingProgress >= 1.0 {
                timer.invalidate()
                isSealing = false
                isCompleted = true
            }
        }
    }
}

struct SealingStepRow: View {
    let number: Int
    let text: String
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.green : Color.white.opacity(0.2))
                    .frame(width: 24, height: 24)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else {
                    Text("\(number)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            Text(text)
                .font(.body)
                .foregroundColor(isCompleted ? .green : .white.opacity(0.9))
            
            Spacer()
        }
    }
}

#Preview {
    KarmicSealingView(karmicEngine: KarmicEngine())
}
