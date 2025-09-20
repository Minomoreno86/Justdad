//
//  FinancialGoalsView.swift
//  JustDad - Financial Goals View
//
//  Professional view for managing financial goals with achievements.
//

import SwiftUI
import SwiftData

struct FinancialGoalsView: View {
    @StateObject private var goalService = FinancialGoalService()
    @State private var showingCreateGoal = false
    @State private var showingPredefinedGoals = false
    @State private var selectedGoal: FinancialGoal?
    @State private var showingAchievement: GoalAchievement?
    @State private var selectedTab = 0
    
    private let tabs = ["Activas", "Completadas", "Logros"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.05),
                        Color.purple.opacity(0.02),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with stats
                    if !goalService.goals.isEmpty {
                        GoalStatsOverview(stats: goalService.getGoalStats())
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                    }
                    
                    // Tab selector
                    Picker("Tabs", selection: $selectedTab) {
                        ForEach(0..<tabs.count, id: \.self) { index in
                            Text(tabs[index]).tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Content based on selected tab
                    TabView(selection: $selectedTab) {
                        // Active Goals
                        activeGoalsTab
                            .tag(0)
                        
                        // Completed Goals
                        completedGoalsTab
                            .tag(1)
                        
                        // Achievements
                        achievementsTab
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Metas Financieras")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Meta Predefinida") {
                            showingPredefinedGoals = true
                        }
                        
                        Button("Meta Personalizada") {
                            showingCreateGoal = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateGoal) {
            GoalCreationForm(goalService: goalService)
        }
        .sheet(isPresented: $showingPredefinedGoals) {
            PredefinedGoalsSelectionView(goalService: goalService)
        }
        .sheet(item: $selectedGoal) { goal in
            GoalDetailView(goal: goal, goalService: goalService)
        }
        .fullScreenCover(item: $showingAchievement) { achievement in
            AchievementCelebrationView(
                achievement: achievement,
                isPresented: .constant(true)
            )
        }
        .onAppear {
            checkForNewAchievements()
        }
    }
    
    // MARK: - Active Goals Tab
    private var activeGoalsTab: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if goalService.activeGoals.isEmpty {
                    emptyActiveGoalsView
                } else {
                    ForEach(goalService.activeGoals) { goal in
                        GoalProgressCard(goal: goal) {
                            selectedGoal = goal
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    // MARK: - Completed Goals Tab
    private var completedGoalsTab: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if goalService.completedGoals.isEmpty {
                    emptyCompletedGoalsView
                } else {
                    ForEach(goalService.completedGoals) { goal in
                        CompletedGoalCard(goal: goal) {
                            selectedGoal = goal
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    // MARK: - Achievements Tab
    private var achievementsTab: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                if goalService.achievements.isEmpty {
                    emptyAchievementsView
                } else {
                    // Recent achievements
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Logros Recientes")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(goalService.recentAchievements) { achievement in
                                    GoalBadgeView(
                                        achievement: achievement,
                                        isAnimated: false,
                                        onCelebrate: {
                                            showingAchievement = achievement
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // All achievements grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Todos los Logros")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(goalService.achievements) { achievement in
                                GoalBadgeView(
                                    achievement: achievement,
                                    isAnimated: false,
                                    onCelebrate: {
                                        showingAchievement = achievement
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.top, 20)
        }
    }
    
    // MARK: - Empty States
    private var emptyActiveGoalsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(.blue.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No hay metas activas")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Crea tu primera meta financiera y comienza a ahorrar")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Crear Meta") {
                showingPredefinedGoals = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(.top, 60)
    }
    
    private var emptyCompletedGoalsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.green.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No hay metas completadas")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Completa tus metas para verlas aquí")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 60)
    }
    
    private var emptyAchievementsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy")
                .font(.system(size: 60))
                .foregroundColor(.yellow.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No hay logros aún")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Completa metas para desbloquear logros")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 60)
    }
    
    // MARK: - Helper Methods
    private func checkForNewAchievements() {
        // Check for uncelebrated achievements
        if let uncelebratedAchievement = goalService.uncelebratedAchievements.first {
            showingAchievement = uncelebratedAchievement
        }
    }
}

// MARK: - Completed Goal Card
struct CompletedGoalCard: View {
    let goal: FinancialGoal
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with completion badge
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    if let description = goal.goalDescription {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                    
                    Text("Completada")
                        .font(.caption2)
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                }
            }
            
            // Amount achieved
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ahorrado")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(goal.currentAmount, format: .currency(code: "USD"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Objetivo")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(goal.targetAmount, format: .currency(code: "USD"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
            
            // Completion date
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Completada el \(goal.updatedAt, formatter: dateFormatter)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
        .onTapGesture {
            onTap()
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}

// MARK: - Predefined Goals Selection View
struct PredefinedGoalsSelectionView: View {
    @ObservedObject var goalService: FinancialGoalService
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPredefinedGoal: PredefinedGoal?
    @State private var showingCustomization = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Metas Predefinidas")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Elige una meta sugerida y personalízala según tus necesidades")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Predefined goals grid
                    PredefinedGoalsGrid(
                        goalService: goalService,
                        onGoalSelected: { predefinedGoal in
                            selectedPredefinedGoal = predefinedGoal
                            showingCustomization = true
                        }
                    )
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Nueva Meta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingCustomization) {
            if let predefinedGoal = selectedPredefinedGoal {
                PredefinedGoalCustomizationView(
                    predefinedGoal: predefinedGoal,
                    goalService: goalService
                )
            }
        }
    }
}

// MARK: - Predefined Goal Customization View
struct PredefinedGoalCustomizationView: View {
    let predefinedGoal: PredefinedGoal
    @ObservedObject var goalService: FinancialGoalService
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var description: String
    @State private var targetAmount: String
    @State private var targetDate: Date
    @State private var isCreating = false
    
    init(predefinedGoal: PredefinedGoal, goalService: FinancialGoalService) {
        self.predefinedGoal = predefinedGoal
        self.goalService = goalService
        self._title = State(initialValue: predefinedGoal.title)
        self._description = State(initialValue: predefinedGoal.description)
        self._targetAmount = State(initialValue: predefinedGoal.suggestedAmount.formatted())
        self._targetDate = State(initialValue: Calendar.current.date(byAdding: .month, value: predefinedGoal.suggestedMonths, to: Date()) ?? Date())
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Detalles de la Meta") {
                    TextField("Título", text: $title)
                    TextField("Descripción", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Objetivo") {
                    HStack {
                        Text("Monto objetivo")
                        Spacer()
                        TextField("0.00", text: $targetAmount)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    DatePicker("Fecha límite", selection: $targetDate, in: Date()..., displayedComponents: .date)
                }
                
                Section("Información") {
                    HStack {
                        Text("Categoría")
                        Spacer()
                        HStack {
                            Image(systemName: predefinedGoal.category.iconName)
                                .foregroundStyle(predefinedGoal.category.gradient)
                            Text(predefinedGoal.category.displayName)
                        }
                    }
                    
                    HStack {
                        Text("Prioridad")
                        Spacer()
                        HStack {
                            Image(systemName: predefinedGoal.priority.iconName)
                                .foregroundColor(predefinedGoal.priority.color)
                            Text(predefinedGoal.priority.displayName)
                        }
                    }
                }
            }
            .navigationTitle("Personalizar Meta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Crear") {
                        createGoal()
                    }
                    .disabled(title.isEmpty || targetAmount.isEmpty || isCreating)
                }
            }
        }
    }
    
    private func createGoal() {
        guard let amount = Decimal(string: targetAmount) else { return }
        
        isCreating = true
        
        Task {
            do {
                try await goalService.createGoal(
                    title: title,
                    description: description.isEmpty ? nil : description,
                    targetAmount: amount,
                    targetDate: targetDate,
                    category: predefinedGoal.category,
                    priority: predefinedGoal.priority
                )
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isCreating = false
                }
            }
        }
    }
}

// MARK: - Goal Detail View
struct GoalDetailView: View {
    let goal: FinancialGoal
    @ObservedObject var goalService: FinancialGoalService
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditGoal = false
    @State private var amountToAdd = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Goal progress card
                    GoalProgressCard(goal: goal) { }
                    
                    // Add amount section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Agregar Ahorro")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        HStack {
                            TextField("Monto a agregar", text: $amountToAdd)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                            
                            Button("Agregar") {
                                addAmount()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(amountToAdd.isEmpty)
                        }
                    }
                    .padding(16)
                    .background(Color.adaptiveSecondarySystemBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Goal details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Detalles")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        DetailRow(title: "Categoría", value: goal.category.displayName, icon: goal.category.iconName)
                        DetailRow(title: "Prioridad", value: goal.priority.displayName, icon: goal.priority.iconName)
                        DetailRow(title: "Creada", value: goal.createdAt.formatted(date: .abbreviated, time: .omitted), icon: "calendar")
                        DetailRow(title: "Actualizada", value: goal.updatedAt.formatted(date: .abbreviated, time: .omitted), icon: "clock")
                    }
                    .padding(16)
                    .background(Color.adaptiveSecondarySystemBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(20)
            }
            .navigationTitle(goal.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Editar") {
                        showingEditGoal = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditGoal) {
            // Edit goal sheet would go here
            Text("Edit Goal Sheet")
        }
    }
    
    private func addAmount() {
        guard let amount = Decimal(string: amountToAdd) else { return }
        
        Task {
            try? await goalService.addAmountToGoal(goal, amount: amount)
            await MainActor.run {
                amountToAdd = ""
            }
        }
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    FinancialGoalsView()
}
