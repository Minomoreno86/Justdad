//
//  AmarresSealingView.swift
//  JustDad
//
//  Created by Jorge Vasquez on 2024.
//

import SwiftUI

struct AmarresSealingView: View {
    @ObservedObject var amarresEngine: AmarresEngine
    @State private var sealingProgress: Double = 0.0
    @State private var isSealing: Bool = false
    @State private var currentAffirmation: String = ""
    @State private var affirmationIndex: Int = 0
    
    private let affirmations = [
        "Mi campo energético está completamente limpio y protegido",
        "Soy libre de todas las conexiones limitantes del pasado",
        "Mi energía fluye libre y pura en todas las direcciones",
        "Estoy protegido contra futuras influencias negativas",
        "Mi aura brilla con luz dorada de protección divina",
        "Soy soberano de mi propia energía y destino"
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 40))
                    .foregroundColor(.purple)
                
                Text("Sellado de Protección")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Sella tu campo energético con afirmaciones de protección y fortaleza")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            
            // Protection Sphere Visualization
            ProtectionSphereView(
                progress: sealingProgress,
                isActive: isSealing,
                affirmation: currentAffirmation
            )
            .frame(height: 250)
            
            // Current Affirmation
            if !currentAffirmation.isEmpty {
                VStack(spacing: 12) {
                    Text("Afirmación de Protección")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(currentAffirmation)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        ))
                }
                .padding(.horizontal)
            }
            
            // Progress
            if isSealing {
                VStack(spacing: 8) {
                    Text("Progreso del Sellado")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ProgressView(value: sealingProgress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .animation(.linear(duration: 0.5), value: sealingProgress)
                    
                    Text("\(Int(sealingProgress * 100))% Completado")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }
            
            // Instructions
            VStack(spacing: 8) {
                Text(instructionText)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                if isSealing {
                    Text("Repite cada afirmación mentalmente mientras visualizas la esfera de protección")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal)
            
            // Action Button
            Button(action: {
                if !isSealing {
                    startSealing()
                } else if sealingProgress >= 1.0 {
                    completeSealing()
                }
            }) {
                HStack {
                    Image(systemName: buttonIcon)
                    Text(buttonText)
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: buttonColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .animation(.easeInOut, value: isSealing)
            }
            .disabled(isSealing && sealingProgress >= 1.0)
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(
            LinearGradient(
                colors: [.purple.opacity(0.1), .indigo.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onReceive(Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()) { _ in
            updateSealingProgress()
        }
    }
    
    private var instructionText: String {
        if !isSealing {
            return "Cuando estés listo, presiona el botón para comenzar el sellado energético"
        } else if sealingProgress >= 1.0 {
            return "¡Protección sellada exitosamente!"
        } else {
            return "Visualiza una esfera dorada envolviendo tu cuerpo"
        }
    }
    
    private var buttonText: String {
        if !isSealing {
            return "Iniciar Sellado"
        } else if sealingProgress >= 1.0 {
            return "Sellado Completado"
        } else {
            return "Sellando Protección..."
        }
    }
    
    private var buttonIcon: String {
        if !isSealing {
            return "lock.shield"
        } else if sealingProgress >= 1.0 {
            return "checkmark.shield"
        } else {
            return "sparkles"
        }
    }
    
    private var buttonColors: [Color] {
        if sealingProgress >= 1.0 {
            return [.green, .mint]
        } else {
            return [.purple, .indigo]
        }
    }
    
    private func startSealing() {
        isSealing = true
        sealingProgress = 0.0
        affirmationIndex = 0
        currentAffirmation = affirmations[0]
        
        // Start the sealing animation
        withAnimation(.linear(duration: 12.0)) {
            sealingProgress = 1.0
        }
    }
    
    private func updateSealingProgress() {
        guard isSealing && sealingProgress < 1.0 else { return }
        
        // Update affirmation based on progress
        let progressPerAffirmation = 1.0 / Double(affirmations.count)
        let newAffirmationIndex = Int(sealingProgress / progressPerAffirmation)
        
        if newAffirmationIndex != affirmationIndex && newAffirmationIndex < affirmations.count {
            affirmationIndex = newAffirmationIndex
            withAnimation(.easeInOut(duration: 0.5)) {
                currentAffirmation = affirmations[affirmationIndex]
            }
        }
    }
    
    private func completeSealing() {
        isSealing = false
        amarresEngine.transitionToNextState()
    }
}

struct ProtectionSphereView: View {
    let progress: Double
    let isActive: Bool
    let affirmation: String
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [.black.opacity(0.8), .purple.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Protection Sphere
                ProtectionSphere(
                    progress: progress,
                    isActive: isActive,
                    size: min(geometry.size.width, geometry.size.height) * 0.6
                )
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                // Energy Particles
                if isActive {
                    ForEach(0..<15, id: \.self) { index in
                        EnergyParticle(
                            index: index,
                            progress: progress,
                            geometry: geometry
                        )
                    }
                }
                
                // Completion Effect
                if progress >= 1.0 {
                    CompletionGlow(geometry: geometry)
                }
            }
        }
    }
}

struct ProtectionSphere: View {
    let progress: Double
    let isActive: Bool
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Outer sphere
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            .gold.opacity(0.8),
                            .purple.opacity(0.6),
                            .blue.opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 6
                )
                .frame(width: size, height: size)
                .scaleEffect(progress)
                .opacity(progress * 0.8 + 0.2)
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            // Inner sphere
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.3),
                            .gold.opacity(0.2),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size / 2
                    )
                )
                .frame(width: size * 0.8, height: size * 0.8)
                .scaleEffect(progress * 0.9 + 0.1)
                .opacity(progress * 0.6 + 0.4)
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            // Pulsing effect
            if isActive {
                Circle()
                    .stroke(
                        Color.gold.opacity(0.4),
                        lineWidth: 2
                    )
                    .frame(width: size * 1.2, height: size * 1.2)
                    .scaleEffect(1.0 + sin(Date().timeIntervalSince1970 * 2) * 0.1)
                    .opacity(0.6)
            }
        }
    }
}

struct EnergyParticle: View {
    let index: Int
    let progress: Double
    let geometry: GeometryProxy
    
    private var particlePosition: CGPoint {
        let angle = Double(index) * (2 * .pi / 15) + progress * 2 * .pi
        let radius = min(geometry.size.width, geometry.size.height) * 0.35
        
        return CGPoint(
            x: geometry.size.width / 2 + CoreGraphics.cos(angle) * radius,
            y: geometry.size.height / 2 + CoreGraphics.sin(angle) * radius
        )
    }
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [.gold.opacity(0.8), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 8
                )
            )
            .frame(width: 16, height: 16)
            .position(particlePosition)
            .scaleEffect(progress > 0.5 ? 1.0 : 0.5)
            .opacity(progress > 0.3 ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.5), value: progress)
    }
}

struct CompletionGlow: View {
    let geometry: GeometryProxy
    
    var body: some View {
        ForEach(0..<8, id: \.self) { index in
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.gold.opacity(0.6), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 30
                    )
                )
                .frame(width: 60, height: 60)
                .position(
                    x: geometry.size.width / 2 + cos(Double(index) * .pi / 4) * 50,
                    y: geometry.size.height / 2 + sin(Double(index) * .pi / 4) * 50
                )
                .scaleEffect(0.0)
                .opacity(0.0)
                .animation(
                    .easeOut(duration: 1.0).delay(Double(index) * 0.1),
                    value: UUID()
                )
        }
    }
}

extension Color {
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
}

#Preview {
    AmarresSealingView(amarresEngine: AmarresEngine())
}
