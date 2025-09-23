//
//  AmarresBreathingView.swift
//  JustDad
//
//  Created by Jorge Vasquez on 2024.
//

import SwiftUI

struct AmarresBreathingView: View {
    @ObservedObject var amarresEngine: AmarresEngine
    @State private var currentPhase: AmarresBreathingPhase = .inhale
    @State private var progress: Double = 0.0
    @State private var isActive: Bool = false
    @State private var remainingTime: Int = 300 // 5 minutes
    
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "wind")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text("Preparación Respiratoria")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Respira profundamente para preparar tu energía antes del ritual de liberación")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            
            // Breathing Circle
            AmarresBreathingCircleView(
                phase: currentPhase,
                progress: progress,
                isActive: isActive
            )
            .frame(width: 200, height: 200)
            
            // Instructions
            VStack(spacing: 8) {
                Text(phaseInstruction)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Sigue el círculo con tu respiración")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Timer
            VStack(spacing: 8) {
                Text("Tiempo restante")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(timeString)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            // Controls
            HStack(spacing: 20) {
                Button(action: {
                    if isActive {
                        pauseBreathing()
                    } else {
                        startBreathing()
                    }
                }) {
                    HStack {
                        Image(systemName: isActive ? "pause.fill" : "play.fill")
                        Text(isActive ? "Pausar" : "Iniciar")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                }
                
                Button(action: {
                    completeBreathing()
                }) {
                    HStack {
                        Text("Continuar")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.purple, .indigo],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                }
                .disabled(!isActive && remainingTime == 300)
            }
            .padding(.bottom, 20)
        }
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.1), .cyan.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onReceive(timer) { _ in
            updateBreathing()
        }
    }
    
    private var phaseInstruction: String {
        switch currentPhase {
        case .inhale:
            return "Inhala profundamente"
        case .hold:
            return "Mantén la respiración"
        case .exhale:
            return "Exhala lentamente"
        case .pause:
            return "Pausa natural"
        }
    }
    
    private var timeString: String {
        let minutes = remainingTime / 60
        let seconds = remainingTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func startBreathing() {
        isActive = true
        amarresEngine.resumeRitual()
    }
    
    private func pauseBreathing() {
        isActive = false
        amarresEngine.pauseRitual()
    }
    
    private func completeBreathing() {
        isActive = false
        amarresEngine.transitionToNextState()
    }
    
    private func updateBreathing() {
        guard isActive else { return }
        
        let cycleDuration: Double = 8.0 // 8 seconds per cycle
        let elapsedTime = Double(300 - remainingTime)
        let cycleProgress = elapsedTime.truncatingRemainder(dividingBy: cycleDuration)
        
        progress = cycleProgress / cycleDuration
        
        // Update phase based on progress
        if progress < 0.25 {
            currentPhase = .inhale
        } else if progress < 0.5 {
            currentPhase = .hold
        } else if progress < 0.75 {
            currentPhase = .exhale
        } else {
            currentPhase = .pause
        }
        
        // Update timer
        if remainingTime > 0 {
            remainingTime -= 1
        } else {
            completeBreathing()
        }
    }
}

enum AmarresBreathingPhase {
    case inhale, hold, exhale, pause
}

struct AmarresBreathingCircleView: View {
    let phase: AmarresBreathingPhase
    let progress: Double
    let isActive: Bool
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                .frame(width: 180, height: 180)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: phaseColor,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 180, height: 180)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            // Phase indicator
            VStack(spacing: 8) {
                Image(systemName: phaseIcon)
                    .font(.system(size: 30))
                    .foregroundColor(phaseColor.first ?? .blue)
                
                Text(phaseText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
        }
        .scaleEffect(isActive ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.3), value: isActive)
    }
    
    private var phaseColor: [Color] {
        switch phase {
        case .inhale:
            return [.blue, .cyan]
        case .hold:
            return [.green, .mint]
        case .exhale:
            return [.orange, .yellow]
        case .pause:
            return [.purple, .indigo]
        }
    }
    
    private var phaseIcon: String {
        switch phase {
        case .inhale:
            return "arrow.up"
        case .hold:
            return "minus"
        case .exhale:
            return "arrow.down"
        case .pause:
            return "circle"
        }
    }
    
    private var phaseText: String {
        switch phase {
        case .inhale:
            return "INHALA"
        case .hold:
            return "MANTÉN"
        case .exhale:
            return "EXHALA"
        case .pause:
            return "PAUSA"
        }
    }
}

#Preview {
    AmarresBreathingView(amarresEngine: AmarresEngine())
}
