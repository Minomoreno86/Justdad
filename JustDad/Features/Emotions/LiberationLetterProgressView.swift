//
//  LiberationLetterProgressView.swift
//  JustDad - Liberation Letter Progress View
//
//  Vista de progreso detallado para las Cartas de Liberación
//

import SwiftUI
import Charts

struct LiberationLetterProgressView: View {
    @StateObject private var liberationService = LiberationLetterService.shared
    @Environment(\.dismiss) private var dismiss
    
    private var statistics: LiberationLetterStatistics {
        liberationService.getDetailedStatistics()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerView
                    
                    // Overall Progress
                    overallProgressView
                    
                    // Phase Progress
                    phaseProgressView
                    
                    // Statistics
                    statisticsView
                    
                    // Recent Sessions
                    recentSessionsView
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [.blue.opacity(0.05), .purple.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("Progreso Detallado")
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
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.8), .purple.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text("\(statistics.completedSessions)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
            
            VStack(spacing: 8) {
                Text("Progreso de Liberación")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("\(statistics.completedSessions) de 21 cartas completadas")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Overall Progress View
    private var overallProgressView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Progreso General")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(Int(statistics.completionRate * 100))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            ProgressView()
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(y: 3)
            
            HStack {
                ProgressStatCard(
                    title: "Completadas",
                    value: "\(statistics.completedSessions)",
                    color: .green
                )
                
                ProgressStatCard(
                    title: "Promedio",
                    value: statistics.formattedAverageTime,
                    color: .orange
                )
                
                ProgressStatCard(
                    title: "Actual",
                    value: "Día \(statistics.currentDay)",
                    color: .blue
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Phase Progress View
    private var phaseProgressView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progreso por Fases")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(LiberationLetterPhase.allCases) { phase in
                let phaseProgress = liberationService.getProgress(for: phase)
                
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: phase.icon)
                            .font(.title3)
                            .foregroundColor(phase.color)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(phase.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text(phase.dayRange)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(phaseProgress.completedDays)/\(phaseProgress.totalDays)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(phase.color)
                            
                            if phaseProgress.isPhaseCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    
                    ProgressView()
                        .progressViewStyle(LinearProgressViewStyle(tint: phase.color))
                        .scaleEffect(y: 2)
                    
                    if let lastCompletedDay = phaseProgress.lastCompletedDay {
                        HStack {
                            Text("Último completado: Día \(lastCompletedDay)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(formatTime(phaseProgress.averageCompletionTime))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Statistics View
    private var statisticsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Estadísticas")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                LiberationStatCard(
                    icon: "clock.fill",
                    title: "Tiempo Total",
                    value: formatTotalTime(),
                    color: .blue
                )
                
                LiberationStatCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Tasa de Completado",
                    value: "\(Int(statistics.completionRate * 100))%",
                    color: .green
                )
                
                LiberationStatCard(
                    icon: "heart.fill",
                    title: "Estado Emocional",
                    value: statistics.mostCommonEmotionalState?.displayName ?? "N/A",
                    color: .red
                )
                
                LiberationStatCard(
                    icon: "calendar",
                    title: "Sesiones Totales",
                    value: "\(statistics.totalSessions)",
                    color: .purple
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Recent Sessions View
    private var recentSessionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sesiones Recientes")
                .font(.headline)
                .fontWeight(.semibold)
            
            let recentSessions = liberationService.sessions
                .sorted { $0.date > $1.date }
                .prefix(5)
            
            if recentSessions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("No hay sesiones completadas")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(Array(recentSessions), id: \.id) { session in
                    SessionRow(session: session)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Helper Methods
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval / 60)
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func formatTotalTime() -> String {
        let totalTime = liberationService.sessions
            .filter { $0.isCompleted }
            .map { $0.completionTime }
            .reduce(0, +)
        
        let hours = Int(totalTime / 3600)
        let minutes = Int((totalTime.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Progress Stat Card
struct ProgressStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Liberation Stat Card
struct LiberationStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Session Row
struct SessionRow: View {
    let session: LiberationLetterSession
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: session.date, relativeTo: Date())
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Day indicator
            ZStack {
                Circle()
                    .fill(session.isCompleted ? .green : .gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                
                if session.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(session.letter.day)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            // Session info
            VStack(alignment: .leading, spacing: 4) {
                Text(session.letter.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                HStack {
                    Text(timeAgo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if session.isCompleted {
                        Text("• \(formatTime(session.completionTime))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Detected anchors
                if !session.detectedAnchors.isEmpty {
                    HStack {
                        ForEach(session.detectedAnchors.prefix(2), id: \.self) { anchor in
                            Text(anchor)
                                .font(.caption2)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(.blue.opacity(0.1))
                                )
                        }
                        
                        if session.detectedAnchors.count > 2 {
                            Text("+\(session.detectedAnchors.count - 2)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Emotional state
            if let emotionalState = session.emotionalState {
                Image(systemName: emotionalState.icon)
                    .font(.title3)
                    .foregroundColor(emotionalState.color)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval / 60)
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    LiberationLetterProgressView()
}
