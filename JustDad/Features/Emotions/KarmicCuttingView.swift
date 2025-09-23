import SwiftUI

struct KarmicCuttingView: View {
    @ObservedObject var karmicEngine: KarmicEngine
    @State private var cuttingProgress: Double = 0.0
    @State private var isCutting = false
    @State private var isCompleted = false
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 16) {
                Text("Corte Simbólico")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Corta simbólicamente los lazos que te atan")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            // Visualización del cordón
            ZStack {
                // Fondo cósmico
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.purple.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                
                // Cordón energético
                if !isCompleted {
                    KarmicCordVisualization(
                        progress: cuttingProgress,
                        isCutting: isCutting
                    )
                } else {
                    // Cordón cortado
                    VStack(spacing: 16) {
                        Image(systemName: "link.badge.plus")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                            .symbolEffect(.bounce)
                        
                        Text("Cordón Liberado")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
            }
            
            // Instrucciones
            if !isCompleted {
                VStack(spacing: 16) {
                    Text("Visualiza el cordón energético")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Imagina un cordón de energía que te conecta con \(karmicEngine.currentSession?.bondName ?? "este vínculo"). Visualiza cómo lo cortas con intención y compasión.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Botón de corte
                if !isCutting {
                    Button(action: startCutting) {
                        HStack {
                            Image(systemName: "scissors")
                            Text("Cortar Cordón Energético")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.red, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                } else {
                    // Progreso de corte
                    VStack(spacing: 16) {
                        Text("Cortando cordón...")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ProgressView(value: cuttingProgress, total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle(tint: .red))
                            .frame(height: 8)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(4)
                        
                        Text("\(Int(cuttingProgress * 100))%")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal, 40)
                }
            } else {
                // Completado
                VStack(spacing: 16) {
                    Text("¡Liberación completada!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("Has cortado simbólicamente el cordón energético. Ahora procederemos con el sellado.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    Button("Continuar al Sellado") {
                        karmicEngine.completeCutting()
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
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    private func startCutting() {
        isCutting = true
        cuttingProgress = 0.0
        
        // Simular el proceso de corte
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            cuttingProgress += 0.02
            
            if cuttingProgress >= 1.0 {
                timer.invalidate()
                isCutting = false
                isCompleted = true
            }
        }
    }
}

struct KarmicCordVisualization: View {
    let progress: Double
    let isCutting: Bool
    
    var body: some View {
        ZStack {
            // Cordón principal
            Path { path in
                path.move(to: CGPoint(x: -100, y: 0))
                path.addLine(to: CGPoint(x: 100, y: 0))
            }
            .stroke(
                LinearGradient(
                    colors: [.purple, .blue, .cyan],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 8, lineCap: .round)
            )
            .opacity(1.0 - progress)
            
            // Efecto de corte
            if isCutting {
                Rectangle()
                    .fill(Color.red.opacity(0.8))
                    .frame(width: 4, height: 20)
                    .offset(x: -100 + (200 * progress))
                    .symbolEffect(.pulse)
            }
            
            // Partículas de liberación
            if progress > 0.5 {
                ForEach(0..<10, id: \.self) { _ in
                    Circle()
                        .fill(Color.green.opacity(0.6))
                        .frame(width: 4, height: 4)
                        .offset(
                            x: CGFloat.random(in: -120...120),
                            y: CGFloat.random(in: -30...30)
                        )
                        .symbolEffect(.bounce)
                }
            }
        }
        .frame(width: 250, height: 50)
    }
}

#Preview {
    KarmicCuttingView(karmicEngine: KarmicEngine())
}
