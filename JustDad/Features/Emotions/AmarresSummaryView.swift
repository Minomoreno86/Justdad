//
//  AmarresSummaryView.swift
//  JustDad
//
//  Created by Jorge Vasquez on 2024.
//

import SwiftUI

struct AmarresSummaryView: View {
    @ObservedObject var amarresEngine: AmarresEngine
    @State private var showAchievements: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "checkmark.shield")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
                
                Text("Ritual Completado")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("¡Has completado exitosamente el ritual de liberación de amarres!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Session Summary
                    if let session = amarresEngine.currentSession {
                        AmarresSessionSummaryCard(session: session)
                    }
                    
                    // Stats
                    AmarresStatsCard(stats: amarresEngine.stats)
                    
                    // Points
                    AmarresPointsCard(points: amarresEngine.points)
                    
                    // Achievements
                    if !amarresEngine.achievements.isEmpty {
                        AmarresAchievementsCard(
                            achievements: amarresEngine.achievements,
                            showAchievements: $showAchievements
                        )
                    }
                    
                    // Next Steps
                    AmarresNextStepsCard()
                }
                .padding(.horizontal)
            }
            
            // Action Buttons
            VStack(spacing: 12) {
                Button(action: {
                    amarresEngine.completeRitual()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Finalizar Ritual")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                
                Button(action: {
                    amarresEngine.abandonRitual()
                }) {
                    Text("Volver al Menú Principal")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(
            LinearGradient(
                colors: [.green.opacity(0.1), .mint.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .sheet(isPresented: $showAchievements) {
            AmarresAchievementsDetailView(achievements: amarresEngine.achievements)
        }
    }
}

struct AmarresSessionSummaryCard: View {
    let session: AmarresSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resumen de la Sesión")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Enfoque")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(session.approach.displayName)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Intensidad")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(session.intensityBefore.displayName)
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
            
            if !session.symptoms.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Síntomas Identificados")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(session.symptoms.count) síntomas")
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
            
            if !session.identifiedBindings.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Conexiones Liberadas")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(session.identifiedBindings.count) conexiones")
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

struct AmarresStatsCard: View {
    let stats: AmarresStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Estadísticas")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                StatItem(
                    title: "Rituales",
                    value: "\(stats.completedSessions)",
                    icon: "scissors"
                )
                
                StatItem(
                    title: "Racha",
                    value: "\(stats.currentStreak)",
                    icon: "flame"
                )
                
                StatItem(
                    title: "Liberaciones",
                    value: "\(stats.bindingsBroken)",
                    icon: "checkmark.shield"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct AmarresPointsCard: View {
    let points: AmarresPoints
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Puntos Ganados")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(points.totalPoints)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
            }
            
            HStack(spacing: 20) {
                PointsItem(
                    title: "Limpieza",
                    value: points.cleansingPoints,
                    color: .blue
                )
                
                PointsItem(
                    title: "Protección",
                    value: points.protectionPoints,
                    color: .purple
                )
                
                PointsItem(
                    title: "Liberación",
                    value: points.liberationPoints,
                    color: .red
                )
                
                PointsItem(
                    title: "Maestría",
                    value: points.masteryPoints,
                    color: .green
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

struct PointsItem: View {
    let title: String
    let value: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct AmarresAchievementsCard: View {
    let achievements: [AmarresAchievement]
    @Binding var showAchievements: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Logros Desbloqueados")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    showAchievements = true
                }) {
                    Text("Ver Todos")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(achievements.prefix(3)) { achievement in
                        AchievementBadge(achievement: achievement)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

struct AchievementBadge: View {
    let achievement: AmarresAchievement
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundColor(.yellow)
            
            Text(achievement.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [.yellow.opacity(0.1), .orange.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

struct AmarresNextStepsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Próximos Pasos")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                NextStepItem(
                    icon: "bell",
                    title: "Recordatorio de Protección",
                    description: "Recibirás notificaciones según tu voto de protección"
                )
                
                NextStepItem(
                    icon: "calendar",
                    title: "Próximo Ritual",
                    description: "Recomendamos realizar otro ritual en 7 días"
                )
                
                NextStepItem(
                    icon: "heart",
                    title: "Mantén tu Energía",
                    description: "Practica técnicas de protección diariamente"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

struct NextStepItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct AmarresAchievementsDetailView: View {
    let achievements: [AmarresAchievement]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(achievements) { achievement in
                        AchievementDetailCard(achievement: achievement)
                    }
                }
                .padding()
            }
            .navigationTitle("Logros Desbloqueados")
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
}

struct AchievementDetailCard: View {
    let achievement: AmarresAchievement
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: achievement.icon)
                .font(.title)
                .foregroundColor(.yellow)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(achievement.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("Recompensa: \(achievement.reward.description)")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    AmarresSummaryView(amarresEngine: AmarresEngine())
}
