import SwiftUI

// MARK: - Psychogenealogy Ritual View
struct PsychogenealogyRitualView: View {
    let letter: PsychogenealogyLetter
    @ObservedObject var psychogenealogyService: PsychogenealogyService
    // Speech service removed for simplicity
    @State private var currentPhase: RitualPhase = .preparation
    @State private var showLetter = false
    @State private var showAffirmations = false
    @State private var ritualProgress: CGFloat = 0.0
    @State private var energyFieldIntensity: CGFloat = 0.0
    @State private var animationTime: Double = 0
    
    enum RitualPhase: CaseIterable {
        case preparation, reading, visualization, integration
        
        var title: String {
            switch self {
            case .preparation: return "Preparación"
            case .reading: return "Lectura Sagrada"
            case .visualization: return "Visualización"
            case .integration: return "Integración"
            }
        }
        
        var description: String {
            switch self {
            case .preparation: return "Prepara tu espacio sagrado y tu intención"
            case .reading: return "Lee la carta con presencia y amor"
            case .visualization: return "Visualiza la liberación de los patrones"
            case .integration: return "Integra la sanación en tu ser"
            }
        }
        
        var icon: String {
            switch self {
            case .preparation: return "leaf.fill"
            case .reading: return "book.fill"
            case .visualization: return "eye.fill"
            case .integration: return "heart.fill"
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Cosmic background
                CosmicRitualBackground(animationTime: animationTime)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with progress
                    ritualHeaderView(geometry: geometry)
                    
                    // Main content area
                    ScrollView {
                        VStack(spacing: 32) {
                            // Current phase content
                            phaseContentView(geometry: geometry)
                            
                            // Letter content (when reading phase)
                            if showLetter && currentPhase == .reading {
                                letterContentView
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .scale),
                                        removal: .opacity
                                    ))
                            }
                            
                            // Affirmations (when integration phase)
                            if showAffirmations && currentPhase == .integration {
                                affirmationsView
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .scale),
                                        removal: .opacity
                                    ))
                            }
                        }
                        .padding()
                    }
                    
                    // Bottom controls
                    ritualControlsView
                }
            }
        }
        .onAppear {
            startRitualAnimation()
        }
        .onChange(of: currentPhase) { phase in
            handlePhaseTransition(to: phase)
        }
    }
    
    // MARK: - Ritual Header
    private func ritualHeaderView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 16) {
            // Progress indicator
            HStack(spacing: 12) {
                ForEach(RitualPhase.allCases, id: \.self) { phase in
                    Circle()
                        .fill(currentPhase == phase ? .white : .white.opacity(0.3))
                        .frame(width: 12, height: 12)
                        .scaleEffect(currentPhase == phase ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3), value: currentPhase)
                }
            }
            .padding(.horizontal)
            
            // Phase title and description
            VStack(spacing: 8) {
                Text(currentPhase.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(currentPhase.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 20)
        .background(
            LinearGradient(
                colors: [.purple.opacity(0.8), .blue.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Phase Content
    private func phaseContentView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 24) {
            switch currentPhase {
            case .preparation:
                preparationPhaseView(geometry: geometry)
            case .reading:
                readingPhaseView(geometry: geometry)
            case .visualization:
                visualizationPhaseView(geometry: geometry)
            case .integration:
                integrationPhaseView(geometry: geometry)
            }
        }
    }
    
    // MARK: - Preparation Phase
    private func preparationPhaseView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 24) {
            // Sacred space setup
            VStack(spacing: 16) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.green)
                    .scaleEffect(1.0 + sin(animationTime * 2) * 0.1)
                
                Text("Prepara tu Espacio Sagrado")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 12) {
                    PreparationStep(
                        icon: "moon.fill",
                        title: "Silencio",
                        description: "Encuentra un lugar tranquilo sin distracciones"
                    )
                    
                    PreparationStep(
                        icon: "flame.fill",
                        title: "Intención",
                        description: "Conecta con tu deseo de sanación y liberación"
                    )
                    
                    PreparationStep(
                        icon: "heart.fill",
                        title: "Presencia",
                        description: "Lleva tu atención al momento presente"
                    )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(radius: 10)
            )
            
            // Breathing preparation
            BreathingPreparationView(animationTime: animationTime)
        }
    }
    
    // MARK: - Reading Phase
    private func readingPhaseView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 24) {
            // Letter introduction
            VStack(spacing: 16) {
                Image(systemName: "book.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.purple)
                    .scaleEffect(1.0 + sin(animationTime * 1.5) * 0.1)
                
                Text("Carta de Liberación")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(letter.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
                
                Text("Lee esta carta con presencia y amor. Permite que las palabras resuenen en tu corazón.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(radius: 10)
            )
            
            // Voice anchors section
            if !letter.voiceAnchors.isEmpty {
                VoiceAnchorsSection(
                    anchors: letter.voiceAnchors,
                    animationTime: animationTime
                )
            }
        }
    }
    
    // MARK: - Visualization Phase
    private func visualizationPhaseView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 24) {
            // Energy field visualization
            VStack(spacing: 16) {
                Text("Visualización Energética")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                EnergyFieldVisualization(
                    intensity: energyFieldIntensity,
                    animationTime: animationTime,
                    geometry: geometry
                )
                
                Text("Visualiza la energía de liberación fluyendo a través de tu árbol familiar, sanando los patrones ancestrales.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(radius: 10)
            )
        }
    }
    
    // MARK: - Integration Phase
    private func integrationPhaseView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 24) {
            // Integration guidance
            VStack(spacing: 16) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.pink)
                    .scaleEffect(1.0 + sin(animationTime * 2.5) * 0.1)
                
                Text("Integración")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Permite que la sanación se integre en tu ser. Siente la paz y la liberación en cada célula de tu cuerpo.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(radius: 10)
            )
            
            // Gratitude section
            GratitudeIntegrationView(animationTime: animationTime)
        }
    }
    
    // MARK: - Letter Content
    private var letterContentView: some View {
        VStack(spacing: 20) {
            Text(letter.content)
                .font(.body)
                .lineSpacing(8)
                .foregroundColor(.primary)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(radius: 5)
                )
            
            // Reading controls
            HStack(spacing: 16) {
                Button(action: {
                    // Speech recognition functionality
                }) {
                    HStack {
                        Image(systemName: "mic.circle.fill")
                        Text("Leer en Voz Alta")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.purple)
                    )
                }
            }
        }
    }
    
    // MARK: - Affirmations
    private var affirmationsView: some View {
        VStack(spacing: 16) {
            Text("Afirmaciones de Integración")
                .font(.headline)
                .fontWeight(.bold)
            
            ForEach(letter.affirmations, id: \.self) { affirmation in
                AffirmationCard(
                    text: affirmation,
                    animationTime: animationTime
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(radius: 5)
        )
    }
    
    // MARK: - Ritual Controls
    private var ritualControlsView: some View {
        HStack(spacing: 16) {
            // Previous phase button
            Button(action: {
                withAnimation(.easeInOut) {
                    if let currentIndex = RitualPhase.allCases.firstIndex(of: currentPhase),
                       currentIndex > 0 {
                        currentPhase = RitualPhase.allCases[currentIndex - 1]
                    }
                }
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Anterior")
                }
                .foregroundColor(.primary)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
            }
            .disabled(currentPhase == .preparation)
            
            Spacer()
            
            // Next phase button
            Button(action: {
                withAnimation(.easeInOut) {
                    if let currentIndex = RitualPhase.allCases.firstIndex(of: currentPhase),
                       currentIndex < RitualPhase.allCases.count - 1 {
                        currentPhase = RitualPhase.allCases[currentIndex + 1]
                    } else {
                        completeRitual()
                    }
                }
            }) {
                HStack {
                    Text(currentPhase == .integration ? "Completar" : "Siguiente")
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.purple)
                )
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.clear, .black.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Helper Methods
    private func startRitualAnimation() {
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
            animationTime = .pi * 2
        }
        
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            energyFieldIntensity = 1.0
        }
    }
    
    private func handlePhaseTransition(to phase: RitualPhase) {
        switch phase {
        case .preparation:
            showLetter = false
            showAffirmations = false
        case .reading:
            showLetter = true
            showAffirmations = false
        case .visualization:
            showLetter = false
            showAffirmations = false
        case .integration:
            showLetter = false
            showAffirmations = true
        }
        
        withAnimation(.easeInOut(duration: 0.5)) {
            ritualProgress = CGFloat(RitualPhase.allCases.firstIndex(of: phase) ?? 0) / CGFloat(RitualPhase.allCases.count - 1)
        }
    }
    
    private func completeRitual() {
        let sessionId = UUID()
        psychogenealogyService.completeSession(sessionId)
        
        // Show completion animation or navigate back
        // This would typically show a success screen or return to the previous view
    }
}

// MARK: - Supporting Views

struct PreparationStep: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.purple)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct BreathingPreparationView: View {
    let animationTime: Double
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Ejercicio de Respiración")
                .font(.headline)
                .fontWeight(.bold)
            
            ZStack {
                Circle()
                    .stroke(Color.purple.opacity(0.3), lineWidth: 4)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .fill(Color.purple.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .scaleEffect(1.0 + sin(animationTime * 2) * 0.3)
                
                Image(systemName: "wind")
                    .font(.title)
                    .foregroundColor(.purple)
            }
            
            Text("Inhala profundamente y exhala lentamente. Conecta con tu respiración.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

struct VoiceAnchorsSection: View {
    let anchors: [String]
    let animationTime: Double
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Anclas de Voz")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("Pronuncia estas palabras con intención y presencia:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(anchors, id: \.self) { anchor in
                    Text(anchor)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.purple.opacity(0.8))
                        )
                        .scaleEffect(1.0 + sin(animationTime * 3 + Double(anchor.hashValue)) * 0.05)
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

struct EnergyFieldVisualization: View {
    let intensity: CGFloat
    let animationTime: Double
    let geometry: GeometryProxy
    
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let maxRadius = min(size.width, size.height) / 2
            
            // Draw concentric energy rings
            for i in 0..<5 {
                let radius = maxRadius * (0.2 + 0.15 * CGFloat(i))
                let opacity = intensity * (0.8 - 0.15 * CGFloat(i))
                
                context.stroke(
                    Circle().path(in: CGRect(
                        x: center.x - radius,
                        y: center.y - radius,
                        width: radius * 2,
                        height: radius * 2
                    )),
                    with: .color(.purple.opacity(opacity)),
                    lineWidth: 2
                )
            }
            
            // Draw energy particles
            for i in 0..<20 {
                let angle = Double(i) * .pi * 2 / 20 + animationTime
                let distance = maxRadius * (0.3 + 0.4 * CGFloat(sin(animationTime * 2 + Double(i) * 0.3)))
                
                let x = center.x + distance * cos(angle)
                let y = center.y + distance * sin(angle)
                
                context.fill(
                    Circle().path(in: CGRect(x: x - 3, y: y - 3, width: 6, height: 6)),
                    with: .color(.white.opacity(0.8))
                )
            }
        }
        .frame(height: 200)
        .background(Color.black.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct GratitudeIntegrationView: View {
    let animationTime: Double
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Expresión de Gratitud")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("Expresa gratitud por la sanación recibida y por tus ancestros que te han llevado hasta aquí.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 20) {
                GratitudeButton(
                    text: "Gracias",
                    icon: "heart.fill",
                    animationTime: animationTime,
                    delay: 0
                )
                
                GratitudeButton(
                    text: "Amor",
                    icon: "heart.circle.fill",
                    animationTime: animationTime,
                    delay: 0.5
                )
                
                GratitudeButton(
                    text: "Paz",
                    icon: "leaf.fill",
                    animationTime: animationTime,
                    delay: 1.0
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

struct GratitudeButton: View {
    let text: String
    let icon: String
    let animationTime: Double
    let delay: Double
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.pink)
                .scaleEffect(1.0 + sin(animationTime * 2 + delay) * 0.1)
            
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.pink.opacity(0.1))
        )
    }
}

struct AffirmationCard: View {
    let text: String
    let animationTime: Double
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .scaleEffect(1.0 + sin(animationTime * 2 + Double(text.hashValue)) * 0.05)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.green.opacity(0.1))
        )
    }
}

struct CosmicRitualBackground: View {
    let animationTime: Double
    
    var body: some View {
        Canvas { context, size in
            // Draw stars
            for i in 0..<100 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let brightness = CGFloat.random(in: 0.3...1.0)
                
                context.fill(
                    Circle().path(in: CGRect(x: x, y: y, width: 2, height: 2)),
                    with: .color(.white.opacity(brightness))
                )
            }
            
            // Draw cosmic energy waves
            for i in 0..<3 {
                let waveY = size.height * (0.2 + 0.3 * CGFloat(i))
                let amplitude: CGFloat = 30
                let frequency: CGFloat = 0.01
                
                var path = Path()
                path.move(to: CGPoint(x: 0, y: waveY))
                
                for x in stride(from: 0, through: size.width, by: 2) {
                    let y = waveY + amplitude * sin(frequency * x + animationTime * 2 + Double(i) * 0.5)
                    path.addLine(to: CGPoint(x: x, y: y))
                }
                
                context.stroke(
                    path,
                    with: .color(.purple.opacity(0.3 - 0.1 * CGFloat(i))),
                    lineWidth: 2
                )
            }
        }
        .background(
            LinearGradient(
                colors: [
                    Color.black,
                    Color.purple.opacity(0.1),
                    Color.blue.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Preview
#Preview {
    let sampleLetter = PsychogenealogyLetter(
        type: .paternalLineage,
        title: "Carta al Linaje Paterno",
        content: "Hoy me dirijo al linaje paterno de mi familia...",
        voiceAnchors: ["te reconozco", "te libero", "honro mi camino"],
        affirmations: ["Soy un hombre libre", "Me sostengo en mi fuerza"],
        duration: 15,
        targetPattern: .absence,
        isUnlocked: true,
        unlockedAt: Date()
    )
    
    PsychogenealogyRitualView(
        letter: sampleLetter,
        psychogenealogyService: PsychogenealogyService.shared
    )
}
