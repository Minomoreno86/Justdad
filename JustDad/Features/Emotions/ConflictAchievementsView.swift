//
//  ConflictAchievementsView.swift
//  JustDad - Conflict Achievements View
//
//  Achievements and badges for conflict wellness
//

import SwiftUI

struct ConflictAchievementsView: View {
    @StateObject private var service = ConflictWellnessService.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerSection
                
                // Stats Overview
                statsOverviewSection
                
                // Achievements Grid
                achievementsSection
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 50))
                .foregroundColor(.yellow)
            
            Text("Logros y Reconocimientos")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Celebra tu progreso en el manejo de conflictos")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var statsOverviewSection: some View {
        HStack(spacing: 16) {
            StatOverviewCard(
                title: "Logros Desbloqueados",
                value: "\(unlockedAchievementsCount)",
                total: "\(service.achievements.count)",
                icon: "trophy.fill",
                color: .yellow
            )
            
            StatOverviewCard(
                title: "Puntos Totales",
                value: "\(service.stats.totalPoints)",
                total: "",
                icon: "star.fill",
                color: .purple
            )
        }
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Insignias")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(service.achievements) { achievement in
                    AchievementBadgeCard(achievement: achievement)
                }
            }
        }
    }
    
    private var unlockedAchievementsCount: Int {
        service.achievements.filter { $0.isUnlocked }.count
    }
}

struct StatOverviewCard: View {
    let title: String
    let value: String
    let total: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            if !total.isEmpty {
                Text("de \(total)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

struct AchievementBadgeCard: View {
    let achievement: ConflictAchievementBadge
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: achievement.icon)
                .font(.system(size: 40))
                .foregroundColor(achievement.isUnlocked ? Color(achievement.color) : .gray)
            
            VStack(spacing: 4) {
                Text(achievement.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                    .multilineTextAlignment(.center)
                
                Text(achievement.criteria)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if achievement.isUnlocked {
                Text("✓ Desbloqueado")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
            } else {
                Text("Bloqueado")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(achievement.isUnlocked ? Color(achievement.color).opacity(0.1) : Color.gray.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(achievement.isUnlocked ? Color(achievement.color).opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    ConflictAchievementsView()
}
