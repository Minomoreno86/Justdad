import SwiftUI

struct RitualMainView: View {
    @StateObject private var ritualEngine = RitualEngine()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismiss) private var dismiss
    @State private var showingMetrics = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo cósmico
                CosmicBackgroundView()
                
                VStack(spacing: 0) {
                    // Barra de progreso
                    ProgressBarView(
                        progress: ritualEngine.progress,
                        currentPhase: ritualEngine.currentState.phaseName,
                        totalPhases: 8
                    )
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Contenido principal según el estado
                    Group {
                        switch ritualEngine.currentState {
                        case .idle:
                            RitualWelcomeView(ritualEngine: ritualEngine)
                        case .preparation:
                            RitualPreparationView(ritualEngine: ritualEngine)
                        case .evocation:
                            RitualEvocationView(ritualEngine: ritualEngine)
                        case .verbalization:
                            RitualVerbalizationView(ritualEngine: ritualEngine)
                        case .cutting:
                            RitualCuttingView(ritualEngine: ritualEngine)
                        case .sealing:
                            RitualSealingView(ritualEngine: ritualEngine)
                        case .renewal:
                            RitualRenewalView(ritualEngine: ritualEngine)
                        case .integration:
                            RitualIntegrationView(ritualEngine: ritualEngine)
                        case .completed:
                            RitualIntegrationView(ritualEngine: ritualEngine)
                        case .abandoned:
                            RitualWelcomeView(ritualEngine: ritualEngine)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Controles de navegación
                    RitualNavigationControls(ritualEngine: ritualEngine, showingMetrics: $showingMetrics)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
                
            }
            .navigationBarHidden(true)
            .onAppear {
                ritualEngine.configure(reduceMotion: reduceMotion)
            }
        }
    }
}

// MARK: - Progress Bar
struct ProgressBarView: View {
    let progress: Double
    let currentPhase: String
    let totalPhases: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(currentPhase)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(progress * Double(totalPhases)))/\(totalPhases)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .white))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Navigation Controls
struct RitualNavigationControls: View {
    @ObservedObject var ritualEngine: RitualEngine
    @Binding var showingMetrics: Bool
    @State private var showingExitAlert = false
    
    var body: some View {
        HStack(spacing: 20) {
            // Botón de métricas
            Button(action: {
                showingMetrics = true
            }) {
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            // Botón de ayuda
            Button(action: {
                // Ayuda general del ritual
            }) {
                Image(systemName: "questionmark.circle")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Botón de pausa/reanudar
            Button(action: {
                if ritualEngine.isPaused {
                    ritualEngine.resumeRitual()
                } else {
                    ritualEngine.pauseRitual()
                }
            }) {
                Image(systemName: ritualEngine.isPaused ? "play.circle.fill" : "pause.circle")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Botón de salir
            Button(action: {
                showingExitAlert = true
            }) {
                Image(systemName: "xmark.circle")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .sheet(isPresented: $showingMetrics) {
            RitualMetricsView()
        }
        .alert("¿Salir del ritual?", isPresented: $showingExitAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Salir", role: .destructive) {
                ritualEngine.exitRitual()
            }
        } message: {
            Text("Tu progreso se guardará automáticamente.")
        }
    }
}

// MARK: - Preview
#Preview {
    RitualMainView()
}
