//
//  HabitsWeeklyReflectionView.swift
//  JustDad - Weekly Reflection Interface
//
//  User interface for weekly habit reflection system
//

import SwiftUI

struct HabitsWeeklyReflectionView: View {
    @StateObject private var reflectionService = HabitsWeeklyReflectionService.shared
    @StateObject private var habitsService = HabitsService.shared
    @State private var showingReflectionSheet = false
    @State private var selectedInsight: ReflectionInsight?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if reflectionService.isReflectionDue {
                        reflectionDueCard
                    }
                    
                    if let currentReflection = reflectionService.currentReflection {
                        currentWeekCard(currentReflection)
                        
                        if !currentReflection.insights.isEmpty {
                            insightsSection(currentReflection.insights)
                        }
                        
                        if !currentReflection.goals.isEmpty {
                            goalsSection(currentReflection.goals)
                        }
                        
                        if !currentReflection.wins.isEmpty || !currentReflection.challenges.isEmpty {
                            reflectionNotesSection(currentReflection)
                        }
                    }
                    
                    if !reflectionService.reflections.isEmpty {
                        previousReflectionsSection
                    }
                }
                .padding()
            }
            .navigationTitle("Reflexión Semanal")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Nueva Reflexión") {
                        showingReflectionSheet = true
                    }
                    .disabled(reflectionService.currentReflection?.isCompleted == true)
                }
            }
            .sheet(isPresented: $showingReflectionSheet) {
                if let currentReflection = reflectionService.currentReflection {
                    NewWeeklyReflectionView(reflection: currentReflection) { completedReflection in
                        reflectionService.completeReflection(completedReflection)
                    }
                }
            }
        }
    }
    
    // MARK: - Reflection Due Card
    private var reflectionDueCard: some View {
        Card_Simplified {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "clock.badge.exclamationmark")
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reflexión Pendiente")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("Es hora de revisar tu progreso semanal")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                PrimaryButton_Simplified("Comenzar Reflexión") {
                    showingReflectionSheet = true
                }
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [.orange.opacity(0.1), .yellow.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    // MARK: - Current Week Card
    private func currentWeekCard(_ reflection: WeeklyReflection) -> some View {
        Card_Simplified {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Semana \(reflection.weekNumber)")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text(reflection.weekRange)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(Int(reflection.completionRate * 100))%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("Completado")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                ProgressView(value: reflection.completionRate)
                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
                
                HStack(spacing: 20) {
                    ReflectionStatItem(
                        title: "Completados",
                        value: "\(reflection.completedHabits.count)",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    
                    ReflectionStatItem(
                        title: "Pendientes",
                        value: "\(reflection.missedHabits.count)",
                        icon: "circle",
                        color: .orange
                    )
                    
                    ReflectionStatItem(
                        title: "Insights",
                        value: "\(reflection.insights.count)",
                        icon: "lightbulb.fill",
                        color: .blue
                    )
                }
            }
            .padding()
        }
    }
    
    // MARK: - Insights Section
    private func insightsSection(_ insights: [ReflectionInsight]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights Generados")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            LazyVStack(spacing: 12) {
                ForEach(insights) { insight in
                    ReflectionInsightCard(insight: insight) {
                        selectedInsight = insight
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Goals Section
    private func goalsSection(_ goals: [WeeklyGoal]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Metas Semanales")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            LazyVStack(spacing: 12) {
                ForEach(goals) { goal in
                    WeeklyGoalCard(goal: goal)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Reflection Notes Section
    private func reflectionNotesSection(_ reflection: WeeklyReflection) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notas de Reflexión")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            if !reflection.wins.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("🎉 Victorias")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    ForEach(reflection.wins, id: \.self) { win in
                        Text("• \(win)")
                            .font(.body)
                            .padding(.leading)
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            if !reflection.challenges.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("⚠️ Desafíos")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    ForEach(reflection.challenges, id: \.self) { challenge in
                        Text("• \(challenge)")
                            .font(.body)
                            .padding(.leading)
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Previous Reflections Section
    private var previousReflectionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reflexiones Anteriores")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            LazyVStack(spacing: 12) {
                ForEach(reflectionService.reflections.filter { $0.isCompleted }.prefix(5)) { reflection in
                    PreviousReflectionCard(reflection: reflection)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Reflection Insight Card
struct ReflectionInsightCard: View {
    let insight: ReflectionInsight
    let onTap: () -> Void
    
    var body: some View {
        Card_Simplified {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: insight.type.icon)
                        .font(.title2)
                        .foregroundColor(insight.type.color)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(insight.title)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text(insight.type.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    PriorityBadge(priority: insight.priority)
                }
                
                Text(insight.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                if !insight.actionItems.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Acciones Sugeridas:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        ForEach(insight.actionItems.prefix(2), id: \.self) { item in
                            Text("• \(item)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if insight.actionItems.count > 2 {
                            Text("• ... y \(insight.actionItems.count - 2) más")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding()
        }
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Weekly Goal Card
struct WeeklyGoalCard: View {
    let goal: WeeklyGoal
    
    var body: some View {
        Card_Simplified {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(goal.title)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    if goal.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                
                Text(goal.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                ProgressView(value: goal.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                
                HStack {
                    Text("\(goal.currentValue) / \(goal.targetValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(goal.progress * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
    }
}

// MARK: - Previous Reflection Card
struct PreviousReflectionCard: View {
    let reflection: WeeklyReflection
    
    var body: some View {
        Card_Simplified {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Semana \(reflection.weekNumber)")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(reflection.weekRange)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(reflection.completionRate * 100))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("\(reflection.insights.count) insights")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }
}

// MARK: - Priority Badge
struct PriorityBadge: View {
    let priority: InsightPriority
    
    var body: some View {
        Text(priority.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(priority.color.opacity(0.2))
            .foregroundColor(priority.color)
            .cornerRadius(8)
    }
}

// MARK: - Reflection Stat Item
struct ReflectionStatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - New Weekly Reflection View
struct NewWeeklyReflectionView: View {
    let reflection: WeeklyReflection
    let onComplete: (WeeklyReflection) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var habitsService = HabitsService.shared
    @State private var wins: [String] = []
    @State private var challenges: [String] = []
    @State private var newWin: String = ""
    @State private var newChallenge: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("Reflexión de la Semana")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Revisa tu progreso y planifica la próxima semana")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // Wins Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🎉 Victorias de la Semana")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        ForEach(wins, id: \.self) { win in
                            HStack {
                                Text("• \(win)")
                                    .font(.body)
                                
                                Spacer()
                                
                                Button(action: { removeWin(win) }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        HStack {
                            TextField("Agregar victoria...", text: $newWin)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button("Agregar") {
                                addWin()
                            }
                            .disabled(newWin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                    
                    // Challenges Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("⚠️ Desafíos de la Semana")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        ForEach(challenges, id: \.self) { challenge in
                            HStack {
                                Text("• \(challenge)")
                                    .font(.body)
                                
                                Spacer()
                                
                                Button(action: { removeChallenge(challenge) }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        HStack {
                            TextField("Agregar desafío...", text: $newChallenge)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button("Agregar") {
                                addChallenge()
                            }
                            .disabled(newChallenge.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Nueva Reflexión")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Completar") {
                        completeReflection()
                    }
                }
            }
        }
        .onAppear {
            loadReflectionData()
        }
    }
    
    private func addWin() {
        let trimmedWin = newWin.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedWin.isEmpty {
            wins.append(trimmedWin)
            newWin = ""
        }
    }
    
    private func removeWin(_ win: String) {
        wins.removeAll { $0 == win }
    }
    
    private func addChallenge() {
        let trimmedChallenge = newChallenge.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedChallenge.isEmpty {
            challenges.append(trimmedChallenge)
            newChallenge = ""
        }
    }
    
    private func removeChallenge(_ challenge: String) {
        challenges.removeAll { $0 == challenge }
    }
    
    private func loadReflectionData() {
        wins = reflection.wins
        challenges = reflection.challenges
    }
    
    private func completeReflection() {
        let completedReflection = WeeklyReflection(
            id: reflection.id,
            weekStartDate: reflection.weekStartDate,
            weekEndDate: reflection.weekEndDate,
            completedHabits: reflection.completedHabits,
            missedHabits: reflection.missedHabits,
            insights: reflection.insights,
            goals: reflection.goals,
            challenges: challenges,
            wins: wins,
            isCompleted: true,
            completedAt: Date()
        )
        
        onComplete(completedReflection)
        dismiss()
    }
}

#Preview {
    HabitsWeeklyReflectionView()
}
