import SwiftUI

struct RitualMetricsView: View {
    @StateObject private var metricsService = RitualMetricsService()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with level and points
                headerSection
                
                // Tab selector
                tabSelector
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    statsTab
                        .tag(0)
                    achievementsTab
                        .tag(1)
                    progressTab
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Mi Progreso")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                LinearGradient(
                    colors: [Color.purple.opacity(0.1), Color.indigo.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Nivel \(metricsService.points.level)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("\(metricsService.points.totalPoints) puntos")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Racha: \(metricsService.streak.currentStreak) días")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Text("Mejor: \(metricsService.streak.longestStreak) días")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            // Progress bar to next level
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Experiencia")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(metricsService.points.totalExperience)/\(metricsService.points.level * 100)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: Double(metricsService.points.totalExperience % 100), total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Tab Selector
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(["Estadísticas", "Logros", "Progreso"], id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = ["Estadísticas", "Logros", "Progreso"].firstIndex(of: tab) ?? 0
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(tab)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedTab == ["Estadísticas", "Logros", "Progreso"].firstIndex(of: tab) ? .primary : .secondary)
                        
                        Rectangle()
                            .fill(selectedTab == ["Estadísticas", "Logros", "Progreso"].firstIndex(of: tab) ? Color.purple : Color.clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Stats Tab
    
    private var statsTab: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Main Stats Cards
                HStack(spacing: 16) {
                    MetricsStatCard(
                        title: "Rituales Completados",
                        value: "\(metricsService.stats.totalRitualsCompleted)",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    
                    MetricsStatCard(
                        title: "Tiempo Total",
                        value: formatTime(metricsService.stats.totalTimeSpent),
                        icon: "clock.fill",
                        color: .blue
                    )
                }
                
                HStack(spacing: 16) {
                    MetricsStatCard(
                        title: "Mejora Emocional",
                        value: String(format: "%.1f", metricsService.stats.averageEmotionalImprovement),
                        icon: "heart.fill",
                        color: .pink
                    )
                    
                    MetricsStatCard(
                        title: "Cumplimiento Votos",
                        value: "\(Int(metricsService.stats.vowCompletionRate * 100))%",
                        icon: "checkmark.seal.fill",
                        color: .orange
                    )
                }
                
                // Detailed Stats
                VStack(alignment: .leading, spacing: 16) {
                    Text("Detalles")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        StatRow(title: "Enfoque Favorito", value: metricsService.stats.favoriteFocus.displayName)
                        StatRow(title: "Patrón de Respiración", value: metricsService.stats.mostUsedBreathingPattern)
                        StatRow(title: "Tasa de Finalización", value: "\(Int(metricsService.stats.completionRate * 100))%")
                        StatRow(title: "Puntos Esta Semana", value: "\(metricsService.points.pointsThisWeek)")
                        StatRow(title: "Puntos Este Mes", value: "\(metricsService.points.pointsThisMonth)")
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Achievements Tab
    
    private var achievementsTab: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Recent Achievements
                if !metricsService.getRecentAchievements().isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Logros Recientes")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(metricsService.getRecentAchievements()) { achievement in
                                    RecentAchievementCard(achievement: achievement)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // All Achievements
                VStack(alignment: .leading, spacing: 12) {
                    Text("Todos los Logros")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(metricsService.achievements) { achievement in
                            AchievementRow(achievement: achievement)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Progress Tab
    
    private var progressTab: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Weekly Progress Chart
                VStack(alignment: .leading, spacing: 16) {
                    Text("Progreso Semanal")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    WeeklyProgressChart(data: metricsService.getWeeklyStats())
                        .padding(.horizontal)
                }
                .padding(.vertical)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Monthly Progress Chart
                VStack(alignment: .leading, spacing: 16) {
                    Text("Progreso Mensual")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    MonthlyProgressChart(data: metricsService.getMonthlyStats())
                        .padding(.horizontal)
                }
                .padding(.vertical)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Streak Visualization
                VStack(alignment: .leading, spacing: 16) {
                    Text("Historial de Rachas")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    StreakVisualization(streak: metricsService.streak)
                        .padding(.horizontal)
                }
                .padding(.vertical)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Supporting Views

struct MetricsStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}

struct RecentAchievementCard: View {
    let achievement: MetricsAchievement
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: achievement.icon)
                .font(.title)
                .foregroundColor(Color(achievement.color))
            
            Text(achievement.title)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 80, height: 80)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct AchievementRow: View {
    let achievement: MetricsAchievement
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundColor(achievement.isUnlocked ? Color(achievement.color) : .gray)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                if achievement.isUnlocked {
                    Text("+\(achievement.reward.points) puntos")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "lock.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct WeeklyProgressChart: View {
    let data: [String: Int]
    
    private let days = ["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(days, id: \.self) { day in
                    VStack(spacing: 4) {
                        Rectangle()
                            .fill(Color.purple.opacity(0.7))
                            .frame(width: 20, height: CGFloat((data[day] ?? 0) * 10))
                            .cornerRadius(4)
                        
                        Text(day)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 100)
            
            Text("Rituales completados por día")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct MonthlyProgressChart: View {
    let data: [String: Int]
    
    var body: some View {
        VStack(spacing: 12) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(1...31, id: \.self) { day in
                    let dayKey = "\(day)"
                    let count = data[dayKey] ?? 0
                    
                    Rectangle()
                        .fill(count > 0 ? Color.purple.opacity(Double(count) / 3.0) : Color.gray.opacity(0.2))
                        .frame(height: 12)
                        .cornerRadius(2)
                }
            }
            
            HStack {
                Text("Menos")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 2) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 8, height: 8)
                    Rectangle()
                        .fill(Color.purple.opacity(0.3))
                        .frame(width: 8, height: 8)
                    Rectangle()
                        .fill(Color.purple.opacity(0.6))
                        .frame(width: 8, height: 8)
                    Rectangle()
                        .fill(Color.purple.opacity(0.9))
                        .frame(width: 8, height: 8)
                }
                
                Text("Más")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text("Rituales completados este mes")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct StreakVisualization: View {
    let streak: RitualStreak
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                VStack {
                    Text("\(streak.currentStreak)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Text("Días Actuales")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(streak.longestStreak)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    
                    Text("Mejor Racha")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let lastDate = streak.lastRitualDate {
                Text("Último ritual: \(lastDate, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    RitualMetricsView()
}
