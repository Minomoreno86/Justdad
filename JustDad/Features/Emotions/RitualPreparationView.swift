import SwiftUI

struct RitualPreparationView: View {
    @ObservedObject var ritualEngine: RitualEngine
    @State private var selectedPattern: RitualBreathingPattern = .fourSevenEight
    @State private var isBreathingActive = false
    @State private var isBreathingCompleted = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Título y descripción
            VStack(spacing: 16) {
                Text("Preparación Respiratoria")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Relájate y prepara tu mente para el ritual")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Selector de patrón respiratorio
            VStack(spacing: 16) {
                Text("Elige tu ritmo respiratorio")
                    .font(.headline)
                    .foregroundColor(.white)
                
                VStack(spacing: 12) {
                    BreathingPatternCard(
                        pattern: RitualBreathingPattern.fourSevenEight,
                        isSelected: selectedPattern == .fourSevenEight,
                        action: { selectedPattern = .fourSevenEight }
                    )
                    
                    BreathingPatternCard(
                        pattern: RitualBreathingPattern.fiveFive,
                        isSelected: selectedPattern == .fiveFive,
                        action: { selectedPattern = .fiveFive }
                    )
                }
            }
            .padding(.horizontal, 20)
            
            // Ejercicio de respiración
            VStack(spacing: 20) {
                if isBreathingActive {
                    SimpleBreathingCircle(
                        pattern: selectedPattern,
                        isActive: isBreathingActive,
                        onComplete: {
                            isBreathingActive = false
                            isBreathingCompleted = true
                        }
                    )
                } else if isBreathingCompleted {
                    // Mensaje de completado
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("¡Excelente!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Has completado la preparación respiratoria. Ahora estás listo para continuar con el ritual.")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
                    .padding(.horizontal, 20)
                } else {
                    // Instrucciones
                    VStack(spacing: 12) {
                        Text("Instrucciones")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(selectedPattern.description)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
                    .padding(.horizontal, 20)
                }
            }
            
            Spacer()
            
            // Botón de acción
            if isBreathingCompleted {
                // Botón para continuar al siguiente paso
                Button(action: {
                    ritualEngine.completePreparation()
                }) {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title3)
                        
                        Text("Continuar al Siguiente Paso")
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
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .padding(.horizontal, 20)
            } else {
                // Botón para comenzar/detener respiración
                Button(action: {
                    if isBreathingActive {
                        isBreathingActive = false
                    } else {
                        isBreathingActive = true
                        ritualEngine.configure(reduceMotion: false)
                        ritualEngine.startRitual()
                    }
                }) {
                    HStack {
                        Image(systemName: isBreathingActive ? "stop.circle.fill" : "play.circle.fill")
                            .font(.title3)
                        
                        Text(isBreathingActive ? "Detener" : "Comenzar Respiración")
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
    }
}

// MARK: - Breathing Pattern Card
struct BreathingPatternCard: View {
    let pattern: RitualBreathingPattern
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(pattern.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(pattern.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                } else {
                    Circle()
                        .stroke(.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.green.opacity(0.2) : Color.clear)
                    .background(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? .green : .clear, lineWidth: 2)
                    )
            )
        }
    }
}

// MARK: - Simple Breathing Circle
struct SimpleBreathingCircle: View {
    let pattern: RitualBreathingPattern
    let isActive: Bool
    let onComplete: () -> Void
    
    @State private var progress: Double = 0.0
    @State private var cycleCount = 0
    
    private let targetCycles = 7
    
    var body: some View {
        VStack(spacing: 30) {
            // Círculo de respiración
            ZStack {
                // Círculo de fondo
                Circle()
                    .stroke(.white.opacity(0.2), lineWidth: 8)
                    .frame(width: 200, height: 200)
                
                // Círculo de progreso
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: progress)
                
                // Contenido central
                VStack(spacing: 8) {
                    Text("Respira")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Información del ciclo
            VStack(spacing: 8) {
                Text("Ciclo \(cycleCount + 1) de \(targetCycles)")
                    .font(.headline)
                    .foregroundColor(.white)
                
                if cycleCount >= targetCycles {
                    Text("¡Excelente! Preparado para continuar")
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
            }
            
            // Auto-completar cuando llegue a los 7 ciclos
            if cycleCount >= targetCycles {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    
                    Text("¡Listo para continuar!")
                        .font(.headline)
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                }
                .onAppear {
                    // Auto-completar después de un breve delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        onComplete()
                    }
                }
            }
        }
        .onAppear {
            if isActive {
                startBreathingCycle()
            }
        }
    }
    
    private func startBreathingCycle() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            progress += 0.1
            
            if progress >= 1.0 {
                cycleCount += 1
                progress = 0.0
                
                if cycleCount >= targetCycles {
                    timer.invalidate()
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        LinearGradient(
            colors: [.purple.opacity(0.8), .indigo.opacity(0.6), .black],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        RitualPreparationView(ritualEngine: RitualEngine())
    }
}