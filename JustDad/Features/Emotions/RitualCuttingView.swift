import SwiftUI

struct RitualCuttingView: View {
    @ObservedObject var ritualEngine: RitualEngine
    @State private var cordState: CordState = .active
    @State private var cuttingProgress: Double = 0.0
    @State private var isCutting = false
    @State private var showCuttingAnimation = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Título
            VStack(spacing: 12) {
                Text("Corte Simbólico del Lazo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Visualiza y corta el cordón energético")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            // Visualización del cordón
            CordVisualizationView(
                state: cordState,
                cuttingProgress: cuttingProgress,
                showAnimation: showCuttingAnimation
            )
            .frame(height: 300)
            .padding(.horizontal, 20)
            
            // Estado actual
            VStack(spacing: 12) {
                Text(cordState.displayName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(cordState.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Progreso del corte
            if isCutting {
                VStack(spacing: 8) {
                    Text("Progreso del corte")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ProgressView(value: cuttingProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .red))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .padding(.horizontal, 40)
                    
                    Text("\(Int(cuttingProgress * 100))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
            }
            
            Spacer()
            
            // Botón de acción principal
            if cordState != .released {
                Button(action: {
                    if cordState == .active && !isCutting {
                        startCutting()
                    } else if cordState == .cutting(progress: 1.0) {
                        completeCutting()
                    }
                }) {
                    HStack {
                        Image(systemName: "scissors")
                            .font(.title3)
                        
                        Text(buttonText)
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(buttonColor)
                    )
                }
                .disabled(isCutting)
                .padding(.horizontal, 20)
            }
            
            // Botón de continuar cuando el corte está completo
            if cordState == .released {
                VStack(spacing: 16) {
                    // Mensaje de éxito
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                        
                        Text("¡Cordón Liberado!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("El cordón energético ha sido cortado exitosamente")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    
                    // Botón de continuar
                    Button(action: {
                        ritualEngine.completeCutting()
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title3)
                            
                            Text("Continuar")
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
    
    private var buttonText: String {
        switch cordState {
        case .active:
            return "Cortar Cordón"
        case .cutting:
            return "Cortando..."
        case .released:
            return "Cordón Liberado"
        default:
            return "Cortar Cordón"
        }
    }
    
    private var buttonColor: LinearGradient {
        switch cordState {
        case .active:
            return LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)
        case .cutting:
            return LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing)
        case .released:
            return LinearGradient(colors: [.green, .blue], startPoint: .leading, endPoint: .trailing)
        default:
            return LinearGradient(colors: [.gray, .gray], startPoint: .leading, endPoint: .trailing)
        }
    }
    
    private func startCutting() {
        cordState = .cutting(progress: 0.0)
        isCutting = true
        showCuttingAnimation = true
        
        // Animación del corte
        withAnimation(.easeInOut(duration: 3.0)) {
            cuttingProgress = 1.0
            cordState = .cutting(progress: 1.0)
        }
        
        // Completar después de la animación
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            cordState = .released
            isCutting = false
            showCuttingAnimation = false
        }
    }
    
    private func completeCutting() {
        ritualEngine.completeCutting()
    }
}

// MARK: - Cord Visualization View
struct CordVisualizationView: View {
    let state: CordState
    let cuttingProgress: Double
    let showAnimation: Bool
    
    var body: some View {
        ZStack {
            // Fondo
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.3), .blue.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Nodos (Yo y Situación)
            HStack {
                // Nodo "Yo"
                CordNode(
                    label: "Yo",
                    color: .blue,
                    isActive: state != .released
                )
                
                Spacer()
                
                // Nodo "Situación"
                CordNode(
                    label: "Situación",
                    color: .red,
                    isActive: state != .released
                )
            }
            .padding(.horizontal, 40)
            
            // Cordón
            CordLine(
                state: state,
                cuttingProgress: cuttingProgress,
                showAnimation: showAnimation
            )
        }
    }
}

// MARK: - Cord Node
struct CordNode: View {
    let label: String
    let color: Color
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(isActive ? 0.8 : 0.3))
                    .frame(width: 60, height: 60)
                    .scaleEffect(isActive ? 1.0 : 0.8)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isActive)
                
                if isActive {
                    Circle()
                        .stroke(color, lineWidth: 2)
                        .frame(width: 80, height: 80)
                        .opacity(0.6)
                        .scaleEffect(1.2)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isActive)
                }
            }
            
            Text(label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Cord Line
struct CordLine: View {
    let state: CordState
    let cuttingProgress: Double
    let showAnimation: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let centerY = geometry.size.height / 2
            let startX = 80.0
            let endX = geometry.size.width - 80.0
            
            ZStack {
                // Línea base
                Path { path in
                    path.move(to: CGPoint(x: startX, y: centerY))
                    path.addLine(to: CGPoint(x: endX, y: centerY))
                }
                .stroke(
                    LinearGradient(
                        colors: [.purple.opacity(0.6), .blue.opacity(0.4)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .opacity(state == .released ? 0.3 : 1.0)
                
                // Efectos de energía
                if state == .active || isCuttingState(state) {
                    ForEach(0..<3, id: \.self) { index in
                        Path { path in
                            path.move(to: CGPoint(x: startX, y: centerY))
                            path.addLine(to: CGPoint(x: endX, y: centerY))
                        }
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.8), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round)
                        )
                        .offset(y: CGFloat(index - 1) * 4)
                        .opacity(showAnimation ? 0.8 : 0.4)
                        .animation(
                            .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                            value: showAnimation
                        )
                    }
                }
                
                // Punto de corte
                if case .cutting(let progress) = state {
                    let cutX = startX + (endX - startX) * progress
                    
                    Circle()
                        .fill(.red)
                        .frame(width: 20, height: 20)
                        .position(x: cutX, y: centerY)
                        .scaleEffect(showAnimation ? 1.5 : 1.0)
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: showAnimation)
                    
                    // Efecto de corte
                    Rectangle()
                        .fill(.red.opacity(0.6))
                        .frame(width: 4, height: 100)
                        .position(x: cutX, y: centerY)
                        .rotationEffect(.degrees(45))
                        .opacity(showAnimation ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.3), value: showAnimation)
                }
            }
        }
    }
}

// MARK: - Cord State Extension
extension CordState {
    var displayName: String {
        switch self {
        case .idle:
            return "Preparado"
        case .linking:
            return "Conectando"
        case .active:
            return "Cordón Activo"
        case .cutting:
            return "Cortando"
        case .released:
            return "Liberado"
        }
    }
    
    var description: String {
        switch self {
        case .idle:
            return "El cordón está listo para ser cortado"
        case .linking:
            return "Estableciendo la conexión energética"
        case .active:
            return "El cordón está activo. Presiona para cortarlo"
        case .cutting:
            return "El cordón se está cortando..."
        case .released:
            return "¡El cordón ha sido liberado exitosamente!"
        }
    }
}

// MARK: - Helper Functions
private func isCuttingState(_ state: CordState) -> Bool {
    if case .cutting = state {
        return true
    }
    return false
}

// MARK: - Preview
#Preview {
    ZStack {
        CosmicBackgroundView()
        RitualCuttingView(ritualEngine: RitualEngine())
    }
}
