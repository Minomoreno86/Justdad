import SwiftUI

struct KarmicMainView: View {
    @StateObject private var karmicEngine = KarmicEngine()
    @State private var showingWelcome = true
    
    var body: some View {
        ZStack {
            // Fondo cósmico
            LinearGradient(
                colors: [Color.purple.opacity(0.8), Color.indigo.opacity(0.6), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if showingWelcome {
                KarmicWelcomeView(
                    karmicEngine: karmicEngine,
                    onStart: {
                        showingWelcome = false
                        // El ritual se iniciará desde el botón en KarmicWelcomeView
                    }
                )
            } else {
                KarmicRitualFlowView(karmicEngine: karmicEngine)
            }
        }
        .onAppear {
            // Setup inicial completado en init
        }
    }
}

struct KarmicRitualFlowView: View {
    @ObservedObject var karmicEngine: KarmicEngine
    
    var body: some View {
        ZStack {
            // Fondo cósmico
            LinearGradient(
                colors: [Color.purple.opacity(0.8), Color.indigo.opacity(0.6), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            switch karmicEngine.currentState {
            case .idle:
                EmptyView()
            case .preparation:
                EmptyView() // Ya no mostramos la vista de bienvenida aquí
            case .breathing:
                KarmicBreathingView(karmicEngine: karmicEngine)
            case .evocation:
                KarmicEvocationView(karmicEngine: karmicEngine)
            case .recognition:
                KarmicReadingView(karmicEngine: karmicEngine, block: .recognition)
            case .liberation:
                KarmicReadingView(karmicEngine: karmicEngine, block: .liberation)
            case .returning:
                KarmicReadingView(karmicEngine: karmicEngine, block: .returning)
            case .cutting:
                KarmicCuttingView(karmicEngine: karmicEngine)
            case .sealing:
                KarmicSealingView(karmicEngine: karmicEngine)
            case .renewal:
                KarmicRenewalView(karmicEngine: karmicEngine)
            case .completed:
                KarmicSummaryView(karmicEngine: karmicEngine)
            case .abandoned:
                Text("Ritual Abandonado")
                    .foregroundColor(.white)
                    .font(.title)
            }
        }
    }
}

#Preview {
    KarmicMainView()
}
