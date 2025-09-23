import SwiftUI

struct RitualIntegrationView: View {
    @ObservedObject var ritualEngine: RitualEngine
    @State private var beforeEmotionalState: Double = 0.5
    @State private var afterEmotionalState: Double = 0.5
    @State private var showingSummary = false
    @State private var ritualComplete = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Título
            VStack(spacing: 12) {
                Text("Integración y Cierre")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Reflexiona sobre tu transformación")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            // Estado emocional antes/después
            VStack(spacing: 24) {
                Text("Tu Estado Emocional")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    // Antes
                    EmotionalStateSlider(
                        title: "Antes del ritual",
                        value: $beforeEmotionalState,
                        isEditable: false
                    )
                    
                    // Después
                    EmotionalStateSlider(
                        title: "Después del ritual",
                        value: $afterEmotionalState,
                        isEditable: true
                    )
                }
                
                // Progreso
                if afterEmotionalState != beforeEmotionalState {
                    EmotionalProgressView(
                        before: beforeEmotionalState,
                        after: afterEmotionalState
                    )
                }
            }
            .padding(.horizontal, 20)
            
            // Resumen del ritual
            VStack(spacing: 16) {
                Text("Resumen del Ritual")
                    .font(.headline)
                    .foregroundColor(.white)
                
                RitualSummaryCard(ritualEngine: ritualEngine)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Afirmación final
            VStack(spacing: 16) {
                Text("Afirmación Final")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Soy libre, estoy en paz, y elijo mi camino con sabiduría y amor")
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
            }
            .padding(.horizontal, 20)
            
            // Opciones de exportación
            if ritualComplete {
                VStack(spacing: 12) {
                    Text("¿Deseas exportar un resumen privado?")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            exportSummary()
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Exportar")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.blue)
                            )
                        }
                        
                        Button(action: {
                            // No exportar
                        }) {
                            HStack {
                                Image(systemName: "xmark")
                                Text("No, gracias")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.gray.opacity(0.3))
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Botón final
            Button(action: {
                if !ritualComplete {
                    ritualComplete = true
                    ritualEngine.completeIntegration(
                        beforeState: beforeEmotionalState,
                        afterState: afterEmotionalState
                    )
                } else {
                    ritualEngine.finishRitual()
                }
            }) {
                HStack {
                    Image(systemName: ritualComplete ? "checkmark.circle.fill" : "heart.circle.fill")
                        .font(.title3)
                    
                    Text(ritualComplete ? "Finalizar Ritual" : "Completar Integración")
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
                                colors: ritualComplete ? [.green, .blue] : [.purple, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    private func exportSummary() {
        // TODO: Implementar exportación de resumen
        print("Exportando resumen del ritual...")
    }
}

// MARK: - Emotional State Slider
struct EmotionalStateSlider: View {
    let title: String
    @Binding var value: Double
    let isEditable: Bool
    
    private let emotionalLabels = ["Dolor", "Tristeza", "Neutral", "Paz", "Alegría"]
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
            
            HStack {
                Text("Dolor")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Slider(value: $value, in: 0...1)
                    .disabled(!isEditable)
                    .accentColor(isEditable ? .blue : .gray)
                
                Text("Alegría")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Text(emotionalLabels[Int(value * 4)])
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Emotional Progress View
struct EmotionalProgressView: View {
    let before: Double
    let after: Double
    
    private var progress: Double {
        return max(0, after - before)
    }
    
    private var progressPercentage: Int {
        return Int(progress * 100)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Progreso Emocional")
                .font(.subheadline)
                .foregroundColor(.white)
            
            HStack {
                Text("+\(progressPercentage)%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Spacer()
                
                if progress > 0.3 {
                    Text("¡Excelente progreso!")
                        .font(.caption)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                } else if progress > 0.1 {
                    Text("Buen progreso")
                        .font(.caption)
                        .foregroundColor(.yellow)
                        .fontWeight(.medium)
                } else {
                    Text("Progreso positivo")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.green.opacity(0.2))
        )
    }
}

// MARK: - Ritual Summary Card
struct RitualSummaryCard: View {
    @ObservedObject var ritualEngine: RitualEngine
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Duración total:")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Text("12 minutos")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            
            HStack {
                Text("Fases completadas:")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Text("8/8")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            }
            
            HStack {
                Text("Anclas de voz:")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Text("12/12")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            }
            
            HStack {
                Text("Voto establecido:")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Text("Sí")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        CosmicBackgroundView()
        RitualIntegrationView(ritualEngine: RitualEngine())
    }
}
