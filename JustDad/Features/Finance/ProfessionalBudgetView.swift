//
//  ProfessionalBudgetView.swift
//  JustDad - Professional Budget Management
//
//  Main interface for intelligent budget management with alerts and insights
//

import SwiftUI
import Charts

struct ProfessionalBudgetView: View {
    @StateObject private var budgetService = ProfessionalBudgetService.shared
    @ObservedObject var financeViewModel: FinanceViewModel
    @State private var showingCreateBudget = false
    @State private var showingBudgetInsights = false
    @State private var selectedBudget: Budget?
    @State private var showingEditBudget = false
    @State private var showingIncomeSheet = false
    @State private var selectedTab = 0
    
    init(financeViewModel: FinanceViewModel) {
        self.financeViewModel = financeViewModel
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with Quick Stats
                headerSection
                
                // Tab Selector
                tabSelector
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    // Budgets Tab
                    budgetsTab
                        .tag(0)
                    
                    // Insights Tab
                    insightsTab
                        .tag(1)
                    
                    // Alerts Tab
                    alertsTab
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Presupuestos Inteligentes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingIncomeSheet = true }) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateBudget = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .onAppear {
                budgetService.refreshBudgetData()
            }
            .sheet(isPresented: $showingCreateBudget) {
                BudgetCreationForm(isPresented: $showingCreateBudget) { budget in
                    budgetService.createBudget(
                        for: budget.category,
                        amount: budget.amount,
                        period: budget.period,
                        alertThresholds: budget.alertThresholds
                    )
                }
            }
            .sheet(isPresented: $showingEditBudget) {
                if let budget = selectedBudget {
                    BudgetEditForm(budget: budget, isPresented: $showingEditBudget) { updatedBudget in
                        budgetService.updateBudget(updatedBudget)
                    }
                }
            }
            .sheet(isPresented: $showingIncomeSheet) {
                IncomeConfigurationSheet(isPresented: $showingIncomeSheet) { income in
                    budgetService.setMonthlyIncome(income)
                }
            }
            .onAppear {
                Task {
                    await budgetService.generateBudgetInsights()
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Quick Stats
            HStack(spacing: 16) {
                BudgetQuickStatCard(
                    title: "Ingreso Mensual",
                    value: NumberFormatter.currency.string(from: budgetService.getTotalIncome() as NSDecimalNumber) ?? "$0",
                    icon: "dollarsign.circle.fill",
                    color: .green
                )
                
                BudgetQuickStatCard(
                    title: "Total Presupuestado",
                    value: NumberFormatter.currency.string(from: totalBudgetedAmount as NSDecimalNumber) ?? "$0",
                    icon: "banknote.fill",
                    color: .blue
                )
                
                BudgetQuickStatCard(
                    title: "Utilización Promedio",
                    value: "\(Int(averageUtilization * 100))%",
                    icon: "chart.pie.fill",
                    color: averageUtilization > 0.9 ? .red : .orange
                )
            }
            
            // Budget Health Indicator
            budgetHealthIndicator
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
    
    private var budgetHealthIndicator: some View {
        HStack {
            Image(systemName: budgetHealthIcon)
                .foregroundColor(budgetHealthColor)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Salud del Presupuesto")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(budgetHealthText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(Int(averageUtilization * 100))%")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(budgetHealthColor)
        }
        .padding(12)
        .background(budgetHealthColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Tab Selector
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(0..<3) { index in
                Button(action: { selectedTab = index }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabIcons[index])
                            .font(.title3)
                        
                        Text(tabTitles[index])
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedTab == index ? .blue : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    // MARK: - Budgets Tab
    
    private var budgetsTab: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if budgetService.budgets.isEmpty {
                    emptyBudgetsState
                } else {
                    ForEach(budgetService.budgets) { budget in
                        BudgetCard(
                            budget: budget,
                            progress: budgetService.getBudgetProgress(for: budget),
                            status: budgetService.getBudgetStatus(for: budget),
                            remainingAmount: budgetService.getRemainingAmount(for: budget),
                            onEdit: {
                                selectedBudget = budget
                                showingEditBudget = true
                            },
                            onToggle: {
                                budgetService.toggleBudget(budget)
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
    
    private var emptyBudgetsState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.pie")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("Sin Presupuestos")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Crea tu primer presupuesto para comenzar a controlar tus gastos de manera inteligente")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: { showingCreateBudget = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Crear Presupuesto")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.vertical, 40)
    }
    
    // MARK: - Insights Tab
    
    private var insightsTab: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if let insights = budgetService.budgetInsights {
                    BudgetInsightsCard(insights: insights, isLoading: budgetService.isGeneratingInsights)
                } else {
                    BudgetInsightsCard(
                        insights: BudgetInsights(
                            totalBudgetedAmount: 0,
                            totalSpent: 0,
                            averageUtilization: 0,
                            topOverSpendingCategories: [],
                            recommendations: [],
                            monthlyTrend: [],
                            projectedOverspend: 0
                        ),
                        isLoading: budgetService.isGeneratingInsights
                    )
                }
                
                // Refresh Button
                Button(action: {
                    Task {
                        await budgetService.generateBudgetInsights()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Actualizar Análisis")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.vertical, 8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Alerts Tab
    
    private var alertsTab: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if budgetService.budgetAlerts.isEmpty {
                    emptyAlertsState
                } else {
                    ForEach(budgetService.budgetAlerts) { alert in
                        if let budget = budgetService.budgets.first(where: { $0.id == alert.budgetId }) {
                            BudgetAlertCard(alert: alert, budget: budget)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
    
    private var emptyAlertsState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("Sin Alertas")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("No hay alertas activas. Las alertas aparecerán cuando te acerques a los límites de tus presupuestos")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 40)
    }
    
    // MARK: - Computed Properties
    
    private var totalBudgetedAmount: Decimal {
        budgetService.budgets.filter { $0.isActive }.reduce(0) { $0 + $1.amount }
    }
    
    private var averageUtilization: Double {
        let activeBudgets = budgetService.budgets.filter { $0.isActive }
        guard !activeBudgets.isEmpty else { return 0 }
        
        let totalUtilization = activeBudgets.reduce(0.0) { total, budget in
            total + budgetService.getBudgetProgress(for: budget)
        }
        
        return totalUtilization / Double(activeBudgets.count)
    }
    
    private var budgetHealthIcon: String {
        if averageUtilization >= 1.0 {
            return "exclamationmark.triangle.fill"
        } else if averageUtilization >= 0.9 {
            return "exclamationmark.circle.fill"
        } else {
            return "checkmark.circle.fill"
        }
    }
    
    private var budgetHealthColor: Color {
        if averageUtilization >= 1.0 {
            return .red
        } else if averageUtilization >= 0.9 {
            return .orange
        } else {
            return .green
        }
    }
    
    private var budgetHealthText: String {
        if averageUtilization >= 1.0 {
            return "Presupuesto excedido - Revisa tus gastos"
        } else if averageUtilization >= 0.9 {
            return "Cerca del límite - Monitorea de cerca"
        } else {
            return "Presupuesto saludable - Continúa así"
        }
    }
    
    private let tabIcons = ["chart.pie.fill", "chart.bar.fill", "bell.fill"]
    private let tabTitles = ["Presupuestos", "Análisis", "Alertas"]
}

// MARK: - Budget Edit Form

struct BudgetEditForm: View {
    let budget: Budget
    @Binding var isPresented: Bool
    @State private var amount: String
    @State private var selectedPeriod: BudgetPeriod
    @State private var isActive: Bool
    
    let onSave: (Budget) -> Void
    
    init(budget: Budget, isPresented: Binding<Bool>, onSave: @escaping (Budget) -> Void) {
        self.budget = budget
        self._isPresented = isPresented
        self.onSave = onSave
        self._amount = State(initialValue: NumberFormatter.currency.string(from: budget.amount as NSDecimalNumber) ?? "0")
        self._selectedPeriod = State(initialValue: budget.period)
        self._isActive = State(initialValue: budget.isActive)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Configuración del Presupuesto") {
                    HStack {
                        Text("Categoría")
                        Spacer()
                        Text(budget.category)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Monto")
                        Spacer()
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Período", selection: $selectedPeriod) {
                        ForEach(BudgetPeriod.allCases, id: \.self) { period in
                            Text(period.displayName).tag(period)
                        }
                    }
                    
                    Toggle("Activo", isOn: $isActive)
                }
            }
            .navigationTitle("Editar Presupuesto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveBudget()
                    }
                    .disabled(amount.isEmpty || Decimal(string: amount) == nil)
                }
            }
        }
    }
    
    private func saveBudget() {
        guard let amountDecimal = Decimal(string: amount) else { return }
        
        let updatedBudget = Budget(
            id: budget.id,
            category: budget.category,
            amount: amountDecimal,
            period: selectedPeriod,
            alertThresholds: budget.alertThresholds,
            createdAt: budget.createdAt,
            isActive: isActive
        )
        
        onSave(updatedBudget)
        isPresented = false
    }
}

// MARK: - Budget Alert Card

struct BudgetAlertCard: View {
    let alert: BudgetAlert
    let budget: Budget
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: alert.isTriggered ? "exclamationmark.triangle.fill" : "bell.fill")
                .font(.title2)
                .foregroundColor(alert.isTriggered ? .red : .orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(budget.category)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(alertText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Umbral: \(Int(truncating: NSDecimalNumber(decimal: alert.threshold * 100)))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if alert.isTriggered {
                Text("¡ACTIVO!")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var alertText: String {
        if alert.isTriggered {
            return "Alerta activada - Has alcanzado el umbral de gasto"
        } else {
            return "Alerta configurada - Se activará al alcanzar el umbral"
        }
    }
}

// MARK: - Budget Quick Stat Card

struct BudgetQuickStatCard: View {
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
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Income Configuration Sheet

struct IncomeConfigurationSheet: View {
    @Binding var isPresented: Bool
    @State private var incomeAmount: String = ""
    @State private var showingSuccess = false
    
    let onSave: (Decimal) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.green)
                    
                    VStack(spacing: 8) {
                        Text("Configurar Ingreso Mensual")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Establece tu ingreso mensual para calcular el porcentaje de utilización de presupuestos")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ingreso Mensual")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("0.00", text: $incomeAmount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.title2)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: saveIncome) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Guardar Ingreso")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(incomeAmount.isEmpty || Decimal(string: incomeAmount) == nil)
                    
                    Button("Cancelar") {
                        isPresented = false
                    }
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Ingreso Mensual")
            .navigationBarTitleDisplayMode(.inline)
            .alert("¡Ingreso Guardado!", isPresented: $showingSuccess) {
                Button("OK") {
                    isPresented = false
                }
            } message: {
                Text("Tu ingreso mensual ha sido configurado correctamente.")
            }
        }
    }
    
    private func saveIncome() {
        guard let amount = Decimal(string: incomeAmount) else { return }
        onSave(amount)
        showingSuccess = true
    }
}

// MARK: - Extensions

extension NumberFormatter {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter
    }()
}
