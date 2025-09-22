//
//  ForgivenessSessionCompletionView.swift
//  JustDad - Forgiveness Session Completion
//
//  Vista de finalización y celebración de sesión de Terapia del Perdón
//

import SwiftUI

struct ForgivenessSessionCompletionView: View {
    @Environment(\.dismiss) private var dismiss
    let session: ForgivenessSession?
    let improvement: Int
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Celebration Header
                    celebrationHeaderView
                    
                    // Session Summary
                    sessionSummaryView
                    
                    // Progress Rewards
                    progressRewardsView
                    
                    // Motivational Message
                    motivationalMessageView
                    
                    // Action Buttons
                    actionButtonsView
                }
                .padding()
            }
            .navigationTitle("¡Sesión Completada!")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Celebration Header
    
    private var celebrationHeaderView: some View {
        VStack(spacing: 20) {
            // Animated celebration
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.yellow, .orange, .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(0))
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: UUID())
            }
            
            Text("¡Liberación Completada!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.pink)
            
            Text("Has dado un paso más hacia tu sanación")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Session Summary
    
    private var sessionSummaryView: some View {
        VStack(spacing: 16) {
            Text("Resumen de la Sesión")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                if let session = session {
                    sessionSummaryRow(
                        title: "Día",
                        value: "\(session.day)",
                        icon: "calendar"
                    )
                    
                    sessionSummaryRow(
                        title: "Fase",
                        value: session.phase.title,
                        icon: session.phase.icon
                    )
                    
                    sessionSummaryRow(
                        title: "Duración",
                        value: formatDuration(session.duration),
                        icon: "clock"
                    )
                    
                    sessionSummaryRow(
                        title: "Mejora en Paz",
                        value: improvement > 0 ? "+\(improvement)" : "\(improvement)",
                        valueColor: improvement > 0 ? .green : .red,
                        icon: "heart.fill"
                    )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemGroupedBackground))
            )
        }
    }
    
    private func sessionSummaryRow(title: String, value: String, valueColor: Color = .primary, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.pink)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(valueColor)
        }
    }
    
    // MARK: - Progress Rewards
    
    private var progressRewardsView: some View {
        VStack(spacing: 16) {
            Text("Recompensas Ganadas")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                // Liberation Points
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "leaf.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                    
                    Text("+50")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("Puntos de\nLiberación")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                
                // Lotus Flower
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.pink.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "flower")
                            .font(.title2)
                            .foregroundColor(.pink)
                    }
                    
                    Text("+1")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                    
                    Text("Flor de\nLoto")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                
                // Peace Level
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "heart.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    Text("+\(improvement)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("Nivel de\nPaz")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Motivational Message
    
    private var motivationalMessageView: some View {
        VStack(spacing: 16) {
            Text("Mensaje de Motivación")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            let message = getMotivationalMessage()
            
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [.pink.opacity(0.1), .blue.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtonsView: some View {
        VStack(spacing: 12) {
            Button(action: {
                // Continue to next day or view progress
                dismiss()
            }) {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                    Text("Continuar el Viaje")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.pink)
                )
            }
            
            Button(action: {
                // Share progress
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Compartir Progreso")
                }
                .font(.subheadline)
                .foregroundColor(.pink)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.pink, lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func getMotivationalMessage() -> String {
        let messages = [
            "Cada paso hacia el perdón es un paso hacia la libertad. ¡Sigue así!",
            "Tu valentía para enfrentar el pasado te está llevando hacia un futuro más brillante.",
            "El perdón es un regalo que te das a ti mismo. ¡Estás haciendo un trabajo increíble!",
            "Cada sesión te acerca más a la paz interior. ¡Tu progreso es admirable!",
            "La sanación es un proceso, y cada día cuenta. ¡Continúa con esta hermosa transformación!"
        ]
        
        return messages.randomElement() ?? messages[0]
    }
}

#Preview {
    ForgivenessSessionCompletionView(
        session: nil,
        improvement: 3
    )
}
