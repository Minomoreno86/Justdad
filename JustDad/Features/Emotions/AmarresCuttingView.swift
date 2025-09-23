//
//  AmarresCuttingView.swift
//  JustDad
//
//  Created by Jorge Vasquez on 2024.
//

import SwiftUI

struct AmarresCuttingView: View {
    @ObservedObject var amarresEngine: AmarresEngine
    @State private var cuttingProgress: Double = 0.0
    @State private var isCutting: Bool = false
    @State private var showCompletion: Bool = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "scissors")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
                
                Text("Corte de Amarres")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Visualiza el corte simbólico de todas las conexiones energéticas limitantes")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            
            // Energy Cord Visualization
            EnergyCordCuttingView(
                progress: cuttingProgress,
                isActive: isCutting
            )
            .frame(height: 300)
            
            // Instructions
            VStack(spacing: 12) {
                Text(instructionText)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .animation(.easeInOut, value: cuttingProgress)
                
                if isCutting {
                    Text("Siente cómo se liberan las conexiones que te limitan")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal)
            
            // Progress Bar
            if isCutting {
                VStack(spacing: 8) {
                    Text("Progreso del Corte")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ProgressView(value: cuttingProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .red))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .animation(.linear(duration: 0.5), value: cuttingProgress)
                }
                .padding(.horizontal)
            }
            
            // Action Button
            Button(action: {
                if !isCutting {
                    startCutting()
                } else if cuttingProgress < 1.0 {
                    // Continue cutting - progress is handled by timer
                } else {
                    completeCutting()
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
                .animation(.easeInOut, value: isCutting)
            }
            .disabled(isCutting && cuttingProgress >= 1.0)
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(
            LinearGradient(
                colors: [.red.opacity(0.1), .orange.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
            updateCuttingProgress()
        }
    }
    
    private var instructionText: String {
        if !isCutting {
            return "Cuando estés listo, presiona el botón para comenzar el corte energético"
        } else if cuttingProgress < 0.3 {
            return "Visualiza las conexiones energéticas que te limitan"
        } else if cuttingProgress < 0.7 {
            return "Imagina una espada de luz cortando cada conexión"
        } else {
            return "Siente la liberación de todas las energías limitantes"
        }
    }
    
    private var buttonText: String {
        if !isCutting {
            return "Iniciar Corte Energético"
        } else if cuttingProgress >= 1.0 {
            return "Corte Completado"
        } else {
            return "Cortando Conexiones..."
        }
    }
    
    private var buttonIcon: String {
        if !isCutting {
            return "scissors"
        } else if cuttingProgress >= 1.0 {
            return "checkmark"
        } else {
            return "sparkles"
        }
    }
    
    private var buttonColors: [Color] {
        if cuttingProgress >= 1.0 {
            return [.green, .mint]
        } else {
            return [.red, .orange]
        }
    }
    
    private func startCutting() {
        isCutting = true
        cuttingProgress = 0.0
        
        // Start the cutting animation
        withAnimation(.linear(duration: 5.0)) {
            cuttingProgress = 1.0
        }
    }
    
    private func updateCuttingProgress() {
        // Progress is handled by the animation in startCutting()
        // This method is called by the timer but the actual progress
        // is controlled by the withAnimation block
    }
    
    private func completeCutting() {
        showCompletion = true
        amarresEngine.transitionToNextState()
    }
}

struct EnergyCordCuttingView: View {
    let progress: Double
    let isActive: Bool
    
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
                
                // Energy cords
                ForEach(0..<5, id: \.self) { index in
                    EnergyCord(
                        index: index,
                        progress: progress,
                        isActive: isActive,
                        geometry: geometry
                    )
                }
                
                // Cutting effect
                if isActive && progress > 0.3 {
                    CuttingEffect(
                        progress: progress,
                        geometry: geometry
                    )
                }
                
                // Completion effect
                if progress >= 1.0 {
                    CompletionEffect(geometry: geometry)
                }
            }
        }
    }
}

struct EnergyCord: View {
    let index: Int
    let progress: Double
    let isActive: Bool
    let geometry: GeometryProxy
    
    private var cordPath: Path {
        let width = geometry.size.width
        let height = geometry.size.height
        
        let startX = CGFloat(index + 1) * width / 6
        let startY = height * 0.2
        let endX = CGFloat(index + 1) * width / 6
        let endY = height * 0.8
        
        var path = Path()
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: endX, y: endY))
        
        return path
    }
    
    private var cutPosition: CGFloat {
        return progress * 0.8 + 0.2 // From 20% to 100% of height
    }
    
    var body: some View {
        ZStack {
            // Cord before cutting
            if progress < 1.0 {
                Path { path in
                    let cutY = geometry.size.height * cutPosition
                    let startPoint = cordPath.boundingRect.origin
                    let endPoint = CGPoint(x: startPoint.x, y: cutY)
                    
                    path.move(to: startPoint)
                    path.addLine(to: endPoint)
                }
                .stroke(
                    LinearGradient(
                        colors: [.red.opacity(0.8), .orange.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .animation(.linear(duration: 0.5), value: progress)
            }
            
            // Cord after cutting (if any remains)
            if progress < 0.9 {
                Path { path in
                    let cutY = geometry.size.height * cutPosition
                    let startPoint = CGPoint(x: cordPath.boundingRect.origin.x, y: cutY)
                    let endPoint = CGPoint(x: startPoint.x, y: geometry.size.height * 0.8)
                    
                    path.move(to: startPoint)
                    path.addLine(to: endPoint)
                }
                .stroke(
                    Color.red.opacity(0.3),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5, 5])
                )
            }
        }
    }
}

struct CuttingEffect: View {
    let progress: Double
    let geometry: GeometryProxy
    
    var body: some View {
        ForEach(0..<3, id: \.self) { index in
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white.opacity(0.8), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 20
                    )
                )
                .frame(width: 40, height: 40)
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height * (progress * 0.8 + 0.2)
                )
                .scaleEffect(isActive ? 1.5 : 0.5)
                .opacity(isActive ? 0.8 : 0.0)
                .animation(
                    .easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                    value: isActive
                )
        }
    }
    
    private var isActive: Bool {
        return progress > 0.3 && progress < 1.0
    }
}

struct CompletionEffect: View {
    let geometry: GeometryProxy
    
    var body: some View {
        ForEach(0..<20, id: \.self) { index in
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.green.opacity(0.6), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 15
                    )
                )
                .frame(width: 30, height: 30)
                .position(
                    x: CGFloat.random(in: 0...geometry.size.width),
                    y: CGFloat.random(in: 0...geometry.size.height)
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

#Preview {
    AmarresCuttingView(amarresEngine: AmarresEngine())
}
