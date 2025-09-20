//
//  FinanceView.swift
//  JustDad - Professional Financial Management
//
//  Advanced expense tracking, budgeting, and financial insights for fathers

import SwiftUI
#if os(iOS)
import UIKit
import VisionKit
#else
import AppKit
#endif

// Import the FinanceViewModel and related types
// These will be available from the FinanceViewModel.swift file

// MARK: - Color Extensions (Professional Design System)
extension Color {
    static var adaptiveLabel: Color {
        return Color.primary
    }
    
    static var adaptiveSecondarySystemBackground: Color {
        #if os(iOS)
        return Color(.systemBackground)
        #else
        return Color(NSColor.controlBackgroundColor)
        #endif
    }
    
    static var adaptiveTertiarySystemBackground: Color {
        #if os(iOS)
        return Color(.secondarySystemBackground)
        #else
        return Color(NSColor.controlBackgroundColor)
        #endif
    }
}

struct FinanceView: View {
    @StateObject private var viewModel = FinanceViewModel()
    @State private var showingProfessionalReports = false
    @State private var showingIncomeSheet = false
    @State private var showingChildSupportSheet = false
    @State private var showingEditExpenseSheet = false
    @State private var showingAnalyticsView = false
    @State private var showingBudgetView = false
    @State private var showingReceiptScanner = false
    @State private var showingAllTransactions = false
    @State private var showingNotificationSettings = false
    @State private var showingCategoryManagement = false
    @State private var showingAdvancedFilters = false
    @State private var showingFinancialGoals = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var selectedTab = 0
    
    @StateObject private var filterService = AdvancedFilterService()
    
    private let periods = ["Esta Semana", "Este Mes", "Este Año"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Professional Background Gradient
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.05),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Main Content with State Management
                ProfessionalStateContainer(
                    loadingState: viewModel.loadingState,
                    errorMessage: viewModel.errorMessage,
                    isEmpty: false,
                    retryAction: {
                        Task {
                            await viewModel.refreshExpenses()
                        }
                    }
                ) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            // Professional Header Section
                            professionalHeader
                            
                            // Financial Overview Cards
                            financialOverviewSection
                            
                            // Period Selector & Quick Stats
                            periodSelectorSection
                            
                            // Recent Transactions
                            recentTransactionsSection
                            
                            // Financial Insights
                            financialInsightsSection
                            
                            // Advanced Analytics Section
                            advancedAnalyticsSection
                            
                            // Export & Reports Section
                            reportsSection
                            
                            // Bottom padding for tab bar
                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                }
            }
            #if os(iOS)
            .toolbar(.hidden, for: .navigationBar)
            #endif
            .sheet(isPresented: $viewModel.showingNewExpenseSheet) {
                ProfessionalNewExpenseSheet(viewModel: viewModel)
            }
        .sheet(isPresented: $showingIncomeSheet) {
            ProfessionalIncomeSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showingChildSupportSheet) {
            ProfessionalChildSupportSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showingEditExpenseSheet) {
            if let editingExpense = viewModel.editingExpense {
                ProfessionalEditExpenseSheet(
                    viewModel: viewModel,
                    expense: editingExpense
                )
            }
        }
        .sheet(isPresented: $showingAnalyticsView) {
            RealProfessionalAnalyticsView(
                expenses: viewModel.expenses,
                monthlyIncome: viewModel.monthlyIncome,
                monthlyBudget: viewModel.monthlyBudget,
                categoryBreakdown: viewModel.categoryBreakdown,
                totalAmount: viewModel.totalAmount,
                balanceAmount: viewModel.balanceAmount
            )
        }
        .sheet(isPresented: $showingProfessionalReports) {
            ProfessionalReportsView()
        }
        .sheet(isPresented: $showingBudgetView) {
            ProfessionalBudgetView(financeViewModel: viewModel)
        }
        .sheet(isPresented: $showingReceiptScanner) {
            ReceiptScannerSheet(isPresented: $showingReceiptScanner) { receiptData in
                Task {
                    do {
                        let receiptProcessingService = ReceiptProcessingService.shared
                        let _ = try await receiptProcessingService.processReceipt(receiptData)
                        await MainActor.run {
                            viewModel.loadExpenses()
                        }
                    } catch {
                        print("Error processing receipt: \(error)")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAllTransactions) {
            AllTransactionsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingNotificationSettings) {
            FinancialNotificationSettingsView()
        }
        .sheet(isPresented: $showingCategoryManagement) {
            CustomCategoryManagementView()
        }
        .sheet(isPresented: $showingFinancialGoals) {
            FinancialGoalsView()
        }
        .sheet(isPresented: $showingAdvancedFilters) {
            AdvancedFilterView(filterService: filterService)
        }
        .alert("Información", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            if viewModel.expenses.isEmpty {
                viewModel.loadExpenses()
            }
            // Schedule financial reminders on app launch
            viewModel.scheduleFinancialReminders()
        }
        .onChange(of: viewModel.totalAmount) { _, _ in
            // Check budget alerts when expenses change
            viewModel.checkBudgetAlerts()
        }
        }
    }
    
    // MARK: - Professional Header
    private var professionalHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Control Financiero")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.adaptiveLabel)
                    
                    Text("Gestiona tus gastos con inteligencia")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { showingIncomeSheet = true }) {
                    Image(systemName: "dollarsign.circle")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { viewModel.showNewExpenseSheet() }) {
                    Image(systemName: "plus")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Circle())
                        .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Financial Overview Section
    private var financialOverviewSection: some View {
        VStack(spacing: 16) {
            // Main Balance Card
            ProfessionalFinanceCard(
                title: "Balance del Mes",
                amount: formatCurrency(viewModel.balanceAmount),
                trend: viewModel.monthlyTrend == .up ? "+12%" : viewModel.monthlyTrend == .down ? "-5%" : "0%",
                trendDirection: convertTrendDirection(viewModel.monthlyTrend),
                icon: "creditcard.fill",
                gradientColors: [Color.blue, Color.purple],
                isMainCard: true
            )
            .accessibleCard(
                title: "Balance del Mes",
                content: "Balance financiero actual del mes",
                value: formatCurrency(viewModel.balanceAmount)
            )
            
            // Secondary Cards
            HStack(spacing: 12) {
                   Button(action: { showingChildSupportSheet = true }) {
                       ProfessionalFinanceCard(
                           title: "Manutención",
                           amount: formatCurrency(viewModel.childSupportAmount),
                           trend: "Fijo",
                           trendDirection: .neutral,
                           icon: "house.fill",
                           gradientColors: [Color.orange, Color.red],
                           isMainCard: false
                       )
                   }
                   .buttonStyle(PlainButtonStyle())
                   .accessibleButton(
                       label: "Manutención",
                       hint: "Toca para agregar gastos de manutención",
                       action: "Agregar manutención"
                   )
                
                Button(action: { viewModel.showNewExpenseSheet() }) {
                    ProfessionalFinanceCard(
                        title: "Extras",
                        amount: formatCurrency(viewModel.extrasAmount),
                        trend: "+25%",
                        trendDirection: .up,
                        icon: "cart.fill",
                        gradientColors: [Color.green, Color.blue],
                        isMainCard: false
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .accessibleButton(
                    label: "Extras",
                    hint: "Toca para agregar gastos adicionales",
                    action: "Agregar gastos"
                )
            }
        }
    }
    
    // MARK: - Period Selector Section
    private var periodSelectorSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Período de Análisis")
                    .font(.headline)
                    .foregroundColor(Color.adaptiveLabel)
                
                Spacer()
            }
            
            // Professional Period Selector
            HStack(spacing: 0) {
                ForEach(Array(periods.enumerated()), id: \.offset) { index, period in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            let financePeriod: FinancePeriod
                            switch period {
                            case "Esta Semana": financePeriod = .thisWeek
                            case "Este Mes": financePeriod = .thisMonth
                            case "Este Año": financePeriod = .thisYear
                            default: financePeriod = .thisMonth
                            }
                            viewModel.setPeriod(financePeriod)
                        }
                    }) {
                        Text(period)
                            .font(.subheadline)
                            .foregroundColor(viewModel.selectedPeriod.displayName == period ? .white : Color.adaptiveLabel)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                viewModel.selectedPeriod.displayName == period ? 
                                LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .background(Color.adaptiveSecondarySystemBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - Recent Transactions Section
    private var recentTransactionsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Transacciones Recientes")
                    .font(.headline)
                    .foregroundColor(Color.adaptiveLabel)
                    .accessibleHeading(1)
                
                Spacer()
                
                HStack(spacing: 12) {
                    // Filter Button
                    Button(action: {
                        showingAdvancedFilters = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            
                            Text("Filtros")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibleButton(
                        label: "Filtros",
                        hint: "Toca para aplicar filtros avanzados a las transacciones",
                        action: "Abrir filtros"
                    )
                    
                    Button("Ver Todo") {
                        showingAllTransactions = true
                    }
                    .font(.subheadline)
                    .foregroundColor(Color.blue)
                    .accessibleButton(
                        label: "Ver Todo",
                        hint: "Toca para ver todas las transacciones",
                        action: "Ver todas las transacciones"
                    )
                }
            }
            
            // Filter Bar
            FilterBarView(
                filterService: filterService,
                onTap: {
                    showingAdvancedFilters = true
                }
            )
            
            ProfessionalStateContainer(
                loadingState: viewModel.loadingState,
                errorMessage: viewModel.errorMessage,
                isEmpty: viewModel.recentExpenses.isEmpty,
                retryAction: {
                    Task {
                        await viewModel.refreshExpenses()
                    }
                },
                emptyStateAction: {
                    viewModel.showNewExpenseSheet()
                }
            ) {
                AccessibleList(
                    data: Array(filterService.applyFilter(to: viewModel.recentExpenses).prefix(5)),
                    accessibilityLabel: "Lista de transacciones recientes"
                ) { expense in
                    ProfessionalExpenseRow(
                        title: expense.title,
                        category: expense.category.displayName,
                        amount: Double(truncating: NSDecimalNumber(decimal: expense.amount)),
                        date: expense.date,
                        icon: expenseIcon(for: expense.category),
                        color: expenseColor(for: expense.category)
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            Task {
                                await viewModel.deleteExpense(expense)
                            }
                        } label: {
                            Label("Eliminar", systemImage: "trash.fill")
                        }
                        .accessibilityLabel("Eliminar transacción")
                        .accessibilityHint("Elimina esta transacción de la lista")
                        
                        Button {
                            viewModel.editingExpense = expense
                            viewModel.showEditExpenseSheet()
                        } label: {
                            Label("Editar", systemImage: "pencil")
                        }
                        .tint(.blue)
                        .accessibilityLabel("Editar transacción")
                        .accessibilityHint("Edita los detalles de esta transacción")
                    }
                }
                .frame(height: CGFloat(min(viewModel.recentExpenses.count, 5)) * 80) // Ajustar altura dinámicamente
            }
        }
    }
    
    // MARK: - Financial Insights Section
    private var financialInsightsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Insights Financieros")
                    .font(.headline)
                    .foregroundColor(Color.adaptiveLabel)
                
                Spacer()
            }
            
            ProfessionalStateContainer(
                loadingState: viewModel.loadingState,
                errorMessage: viewModel.errorMessage,
                isEmpty: false,
                retryAction: {
                    Task {
                        await viewModel.refreshExpenses()
                    }
                }
            ) {
                HStack(spacing: 12) {
                    FinancialInsightCard(
                        title: "Gastos Totales",
                        value: formatCurrency(viewModel.totalAmount),
                        icon: "creditcard.fill",
                        color: .blue
                    )
                    
                    FinancialInsightCard(
                        title: "Progreso Presupuesto",
                        value: String(format: "%.0f%%", viewModel.budgetProgress * 100),
                        icon: "target",
                        color: .green
                    )
                }
            }
        }
    }
    
    // MARK: - Advanced Analytics Section
    private var advancedAnalyticsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Analytics Avanzados")
                    .font(.headline)
                    .foregroundColor(Color.adaptiveLabel)
                
                Spacer()
                
                Button("Ver Todo") {
                    showingAnalyticsView = true
                }
                .font(.subheadline)
                .foregroundColor(Color.blue)
            }
            
            VStack(spacing: 12) {
                Button(action: { showingAnalyticsView = true }) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Análisis Profesional")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("Datos reales, gráficos claros y análisis útiles")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(20)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Quick Analytics Preview
                HStack(spacing: 16) {
                    AnalyticsPreviewCard(
                        title: "Gastos por Categoría",
                        value: "\(viewModel.categoryBreakdown.count)",
                        icon: "chart.pie.fill",
                        color: .blue
                    )
                    
                    AnalyticsPreviewCard(
                        title: "Tendencia",
                        value: calculateTrendText(),
                        icon: "chart.line.uptrend.xyaxis",
                        color: .green
                    )
                    
                    AnalyticsPreviewCard(
                        title: "Promedio Diario",
                        value: formatCurrency(calculateDailyAverage()),
                        icon: "calendar",
                        color: .orange
                    )
                }
            }
        }
    }
    
    // MARK: - Reports Section
    private var reportsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Herramientas Financieras")
                    .font(.headline)
                    .foregroundColor(Color.adaptiveLabel)
                    .accessibleHeading(2)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                // Budget Management Button
                Button(action: { showingBudgetView = true }) {
                    HStack {
                        Image(systemName: "chart.pie.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Presupuestos Inteligentes")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("Configuración, alertas, seguimiento automático")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 2) {
                            Image(systemName: "arrow.right")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            Text("NUEVO")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(16)
                    .background(
                        LinearGradient(
                            colors: [Color.green, Color.blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
                .accessibleButton(
                    label: "Presupuestos Inteligentes",
                    hint: "Toca para configurar y gestionar presupuestos automáticos",
                    action: "Abrir presupuestos"
                )
                
                // Professional Reports Button
                Button(action: { showingProfessionalReports = true }) {
                    HStack {
                        Image(systemName: "chart.bar.doc.horizontal.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Reportes Profesionales")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("PDF, Excel, CSV con gráficos y análisis")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 2) {
                            Image(systemName: "arrow.right")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            Text("NUEVO")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(16)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Receipt Scanner Button
                Button(action: {
                    #if os(iOS)
                    if VNDocumentCameraViewController.isSupported {
                        showingReceiptScanner = true
                    } else {
                        alertMessage = "El escáner de documentos no está disponible en este dispositivo."
                        showingAlert = true
                    }
                    #else
                    alertMessage = "El escáner no está disponible en esta plataforma."
                    showingAlert = true
                    #endif
                }) {
                    HStack {
                        Image(systemName: "doc.text.viewfinder")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Escanear Factura")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("OCR automático, monto, fecha, comercio")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 2) {
                            Image(systemName: "arrow.right")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            Text("NUEVO")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(16)
                    .background(
                        LinearGradient(
                            colors: [Color.purple, Color.pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.purple.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Financial Notifications Button
                Button(action: { showingNotificationSettings = true }) {
                    HStack {
                        Image(systemName: "bell.badge.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Notificaciones Financieras")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("Alertas de presupuesto y recordatorios inteligentes")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 2) {
                            Image(systemName: "arrow.right")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            Text("NUEVO")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(16)
                    .background(
                        LinearGradient(
                            colors: [Color.orange, Color.red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Category Management Button
                Button(action: { showingCategoryManagement = true }) {
                    HStack {
                        Image(systemName: "tag.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Gestionar Categorías")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("Crear y personalizar categorías de gastos")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 2) {
                            Image(systemName: "arrow.right")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            Text("NUEVO")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(16)
                    .background(
                        LinearGradient(
                            colors: [Color.teal, Color.cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.teal.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Financial Goals Button
                Button(action: { showingFinancialGoals = true }) {
                    HStack {
                        Image(systemName: "target")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Metas Financieras")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("Establece y cumple objetivos de ahorro")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 2) {
                            Image(systemName: "arrow.right")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            Text("NUEVO")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(16)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Helper Functions
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "es_US")
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }
    
    private func convertTrendDirection(_ trend: TrendDirection) -> ProfessionalFinanceCard.TrendDirection {
        switch trend {
        case .up: return .up
        case .down: return .down
        case .neutral: return .neutral
        }
    }
    
    private func expenseIcon(for category: FinancialEntry.ExpenseCategory) -> String {
        switch category {
        case .education: return "book.fill"
        case .health: return "cross.fill"
        case .food: return "fork.knife"
        case .transportation: return "car.fill"
        case .entertainment: return "gamecontroller.fill"
        case .clothing: return "tshirt.fill"
        case .gifts: return "gift.fill"
        case .childSupport: return "house.fill"
        case .other: return "dollarsign.circle.fill"
        }
    }
    
    private func expenseColor(for category: FinancialEntry.ExpenseCategory) -> Color {
        switch category {
        case .education: return .blue
        case .health: return .red
        case .food: return .green
        case .transportation: return .orange
        case .entertainment: return .purple
        case .clothing: return .pink
        case .gifts: return .yellow
        case .childSupport: return .orange
        case .other: return .gray
        }
    }
    
    private func shareFile(url: URL) {
        #if os(iOS)
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
        #endif
    }
    
    private func exportToCSV() {
        Task {
            do {
                let url = try await viewModel.exportToCSV()
                await MainActor.run {
                    shareFile(url: url)
                }
            } catch {
                print("Error al exportar CSV: \(error.localizedDescription)")
            }
        }
    }
}
// MARK: - Professional Finance Card
struct ProfessionalFinanceCard: View {
    let title: String
    let amount: String
    let trend: String
    let trendDirection: TrendDirection
    let icon: String
    let gradientColors: [Color]
    let isMainCard: Bool
    
    enum TrendDirection {
        case up, down, neutral
        
        var icon: String {
            switch self {
            case .up: return "arrow.up"
            case .down: return "arrow.down"
            case .neutral: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .neutral: return .gray
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: isMainCard ? 16 : 12) {
            HStack {
                Image(systemName: icon)
                    .font(isMainCard ? .title2 : .title3)
                    .foregroundColor(.white)
                    .frame(width: isMainCard ? 50 : 40, height: isMainCard ? 50 : 40)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.2))
                    )
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: trendDirection.icon)
                        .font(.caption)
                    Text(trend)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(trendDirection.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(isMainCard ? .subheadline : .caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(amount)
                    .font(isMainCard ? .title : .title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .padding(isMainCard ? 20 : 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: gradientColors[0].opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Professional Expense Row
struct ProfessionalExpenseRow: View {
    let title: String
    let category: String
    let amount: Double
    let date: Date
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon Container
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.adaptiveLabel)
                
                Text(category)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount and Date
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "$%.2f", abs(amount)))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(amount < 0 ? .red : .green)
                
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color.adaptiveSecondarySystemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Financial Insight Card
struct FinancialInsightCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(color.opacity(0.1))
                )
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color.adaptiveLabel)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.adaptiveSecondarySystemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Export Button
struct ExportButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Professional New Expense Sheet
struct ProfessionalNewExpenseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FinanceViewModel
    @StateObject private var categoryService = CustomCategoryService.shared
    @State private var expenseTitle = ""
    @State private var expenseAmount = ""
    @State private var expenseCategory: FinancialEntry.ExpenseCategory = .other
    @State private var selectedCustomCategory: CustomCategory? = nil
    @State private var expenseType: FinancialEntry.ExpenseType? = .variable
    @State private var expenseDate = Date()
    @State private var expenseNotes = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showingSuccess = false
    @State private var showingCategoryManagement = false
    
    private let categories = FinancialEntry.ExpenseCategory.allCases
    private let expenseTypes = FinancialEntry.ExpenseType.allCases
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Nuevo Gasto")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color.adaptiveLabel)
                            
                            Text("Registra un nuevo gasto para tu control financiero")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top)
                        
                        // Form Sections
                        VStack(spacing: 20) {
                            // Basic Information
                            formSection(title: "Información Básica") {
                                VStack(spacing: 16) {
                                    CustomTextField(
                                        title: "Descripción",
                                        text: $expenseTitle,
                                        placeholder: "Ej: Útiles escolares",
                                        icon: "text.cursor"
                                    )
                                    
                                    CustomTextField(
                                        title: "Monto",
                                        text: $expenseAmount,
                                        placeholder: "0.00",
                                        icon: "dollarsign"
                                    )
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        EnhancedCategoryPicker(
                                            title: "Categoría",
                                            selectedCategory: $expenseCategory,
                                            selectedCustomCategory: $selectedCustomCategory,
                                            categoryService: categoryService
                                        )
                                        
                                        // Quick access to category management
                                        Button(action: {
                                            showingCategoryManagement = true
                                        }) {
                                            HStack {
                                                Image(systemName: "tag.badge.plus")
                                                    .font(.caption)
                                                    .foregroundColor(.blue)
                                                
                                                Text("Gestionar Categorías")
                                                    .font(.caption)
                                                    .foregroundColor(.blue)
                                                
                                                Spacer()
                                                
                                                Image(systemName: "arrow.right")
                                                    .font(.caption2)
                                                    .foregroundColor(.blue)
                                            }
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(Color.blue.opacity(0.1))
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                    
                                    CustomExpenseTypePicker(
                                        title: "Tipo de Gasto",
                                        selection: $expenseType,
                                        expenseTypes: expenseTypes
                                    )
                                }
                            }
                            
                            // Date and Notes
                            formSection(title: "Detalles Adicionales") {
                                VStack(spacing: 16) {
                                    CustomDatePicker(
                                        title: "Fecha",
                                        selection: $expenseDate
                                    )
                                    
                                    CustomTextEditor(
                                        title: "Notas",
                                        text: $expenseNotes,
                                        placeholder: "Notas adicionales (opcional)"
                                    )
                                }
                            }
                        }
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                saveExpense()
                            }) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "checkmark.circle.fill")
                                    }
                                    Text("Guardar Gasto")
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .disabled(expenseTitle.isEmpty || expenseAmount.isEmpty || isLoading)
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: { dismiss() }) {
                                Text("Cancelar")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.adaptiveSecondarySystemBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
                }
            }
            #if os(iOS)
            .toolbar(.hidden, for: .navigationBar)
            #else
            #endif
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .overlay(
                Group {
                    if showingSuccess {
                        ProfessionalSuccessState(
                            title: "¡Gasto Guardado!",
                            message: "Tu gasto se ha registrado exitosamente",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        .transition(.scale.combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: showingSuccess)
                    }
                }
            )
            .sheet(isPresented: $showingCategoryManagement) {
                CustomCategoryManagementView()
            }
        }
    }
    
    private func saveExpense() {
        guard let amount = Double(expenseAmount), amount > 0 else {
            errorMessage = "Por favor ingresa un monto válido"
            showingError = true
            return
        }
        
        isLoading = true
        
        Task {
            let newExpense = FinancialEntry(
                title: expenseTitle,
                amount: Decimal(amount),
                category: expenseCategory,
                expenseType: expenseType,
                date: expenseDate,
                notes: expenseNotes.isEmpty ? nil : expenseNotes
            )
            
            // Set custom category if selected
            if let customCategory = selectedCustomCategory {
                newExpense.customCategory = customCategory
                // Update usage count
                customCategory.updateUsageCount()
            }
            
            await viewModel.addExpense(newExpense)
            
            await MainActor.run {
                self.isLoading = false
                if viewModel.errorMessage == nil {
                    // Show success state briefly before dismissing
                    self.showingSuccess = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.dismiss()
                    }
                } else {
                    self.errorMessage = viewModel.errorMessage ?? "Error desconocido"
                    self.showingError = true
                }
            }
        }
    }
    
    @ViewBuilder
    private func formSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color.adaptiveLabel)
            
            content()
        }
        .padding(20)
        .background(Color.adaptiveSecondarySystemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Professional Reports Sheet
struct ProfessionalReportsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedReportType = "Mensual"
    @State private var selectedFormat = "PDF"
    
    private let reportTypes = ["Semanal", "Mensual", "Anual"]
    private let formats = ["PDF", "Excel", "CSV"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                reportContent
            }
            #if os(iOS)
            .toolbar(.hidden, for: .navigationBar)
            #endif
        }
    }
    
    private var backgroundGradient: some View {
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
    }
    
    private var reportContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                
                VStack(spacing: 20) {
                    reportTypeSection
                    formatSection
                }
                .padding(20)
                .background(Color.adaptiveSecondarySystemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                
                actionButtons
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 50)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Generar Reporte")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.adaptiveLabel)
            
            Text("Crea reportes detallados de tus finanzas")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top)
    }
    
    private var reportTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tipo de Reporte")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color.adaptiveLabel)
            
            HStack(spacing: 0) {
                ForEach(reportTypes, id: \.self) { type in
                    reportTypeButton(for: type)
                }
            }
            .background(Color.adaptiveSecondarySystemBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private func reportTypeButton(for type: String) -> some View {
        Button(action: {
            selectedReportType = type
        }) {
            Text(type)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(selectedReportType == type ? .white : Color.adaptiveLabel)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    selectedReportType == type ?
                    LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing) :
                    LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var formatSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Formato")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color.adaptiveLabel)
            
            HStack(spacing: 12) {
                ForEach(formats, id: \.self) { format in
                    formatButton(for: format)
                }
            }
        }
    }
    
    private func formatButton(for format: String) -> some View {
        Button(action: {
            selectedFormat = format
        }) {
            Text(format)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(selectedFormat == format ? .white : Color.adaptiveLabel)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    selectedFormat == format ?
                    AnyShapeStyle(LinearGradient(colors: [Color.green, Color.blue], startPoint: .leading, endPoint: .trailing)) :
                    AnyShapeStyle(Color.adaptiveSecondarySystemBackground)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            generateButton
            cancelButton
        }
    }
    
    private var generateButton: some View {
        Button(action: {
            // TODO: Generate report
            dismiss()
        }) {
            HStack {
                Image(systemName: "doc.text.fill")
                Text("Generar Reporte")
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.blue, Color.purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var cancelButton: some View {
        Button(action: { dismiss() }) {
            Text("Cancelar")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.adaptiveSecondarySystemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Custom Form Components
struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let icon: String
    #if os(iOS)
    var keyboardType: UIKeyboardType = .default
    
    init(title: String, text: Binding<String>, placeholder: String, icon: String, keyboardType: UIKeyboardType = .default) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.icon = icon
        self.keyboardType = keyboardType
    }
    #else
    init(title: String, text: Binding<String>, placeholder: String, icon: String) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.icon = icon
    }
    #endif
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color.adaptiveLabel)
            
            HStack {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                TextField(placeholder, text: $text)
                    .font(.subheadline)
                    #if os(iOS)
                    .keyboardType(keyboardType)
                    #endif
            }
            .padding(12)
            .background(Color.adaptiveTertiarySystemBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

struct CustomCategoryPicker: View {
    let title: String
    @Binding var selection: FinancialEntry.ExpenseCategory
    let categories: [FinancialEntry.ExpenseCategory]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color.adaptiveLabel)
            
            Menu {
                ForEach(categories, id: \.self) { category in
                    Button(category.displayName) {
                        selection = category
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "tag.fill")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .frame(width: 20)
                    
                    Text(selection.displayName)
                        .font(.subheadline)
                        .foregroundColor(Color.adaptiveLabel)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .background(Color.adaptiveTertiarySystemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

// MARK: - Enhanced Category Picker with Custom Categories
struct EnhancedCategoryPicker: View {
    let title: String
    @Binding var selectedCategory: FinancialEntry.ExpenseCategory
    @Binding var selectedCustomCategory: CustomCategory?
    @ObservedObject var categoryService: CustomCategoryService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color.adaptiveLabel)
            
            Menu {
                // Show custom categories if available, otherwise show default categories
                if !categoryService.getActiveCategories().isEmpty {
                    // Custom Categories Section (Primary)
                    ForEach(categoryService.getActiveCategories(), id: \.id) { customCategory in
                        Button(action: {
                            selectedCustomCategory = customCategory
                            selectedCategory = .other // Set to other as fallback
                        }) {
                            HStack {
                                Image(systemName: customCategory.systemIcon)
                                    .foregroundColor(customCategory.swiftUIColor)
                                Text(customCategory.displayName)
                                
                                if customCategory.usageCount > 0 {
                                    Spacer()
                                    Text("\(customCategory.usageCount)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                } else {
                    // Default Categories Section (Fallback when no custom categories)
                    ForEach(FinancialEntry.ExpenseCategory.allCases, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                            selectedCustomCategory = nil
                        }) {
                            HStack {
                                Image(systemName: categoryIcon(for: category))
                                    .foregroundColor(categoryColor(for: category))
                                Text(category.displayName)
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    // Icon
                    Image(systemName: currentIcon)
                        .font(.subheadline)
                        .foregroundColor(currentColor)
                        .frame(width: 20)
                    
                    // Category Name
                    Text(currentDisplayName)
                        .font(.subheadline)
                        .foregroundColor(Color.adaptiveLabel)
                    
                    Spacer()
                    
                    // Usage count for custom categories
                    if let customCategory = selectedCustomCategory, customCategory.usageCount > 0 {
                        Text("\(customCategory.usageCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.secondary.opacity(0.1))
                            )
                    }
                    
                    // Chevron
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .background(Color.adaptiveTertiarySystemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    // MARK: - Computed Properties
    private var currentDisplayName: String {
        if let customCategory = selectedCustomCategory {
            return customCategory.displayName
        } else {
            return selectedCategory.displayName
        }
    }
    
    private var currentIcon: String {
        if let customCategory = selectedCustomCategory {
            return customCategory.systemIcon
        } else {
            return categoryIcon(for: selectedCategory)
        }
    }
    
    private var currentColor: Color {
        if let customCategory = selectedCustomCategory {
            return customCategory.swiftUIColor
        } else {
            return categoryColor(for: selectedCategory)
        }
    }
    
    // MARK: - Helper Functions
    private func categoryIcon(for category: FinancialEntry.ExpenseCategory) -> String {
        switch category {
        case .education: return "book.fill"
        case .health: return "cross.fill"
        case .food: return "fork.knife"
        case .transportation: return "car.fill"
        case .entertainment: return "gamecontroller.fill"
        case .clothing: return "tshirt.fill"
        case .gifts: return "gift.fill"
        case .childSupport: return "house.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    private func categoryColor(for category: FinancialEntry.ExpenseCategory) -> Color {
        switch category {
        case .education: return .blue
        case .health: return .red
        case .food: return .orange
        case .transportation: return .green
        case .entertainment: return .purple
        case .clothing: return .pink
        case .gifts: return .yellow
        case .childSupport: return .brown
        case .other: return .gray
        }
    }
}

struct CustomDatePicker: View {
    let title: String
    @Binding var selection: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color.adaptiveLabel)
            
            DatePicker("", selection: $selection, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
        }
    }
}

struct CustomTextEditor: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color.adaptiveLabel)
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .font(.subheadline)
                    .frame(minHeight: 80)
                
                if text.isEmpty {
                    Text(placeholder)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .allowsHitTesting(false)
                }
            }
            .padding(8)
            .background(Color.adaptiveTertiarySystemBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

// MARK: - Professional Income Sheet
struct ProfessionalIncomeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FinanceViewModel
    @State private var monthlyIncome = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Ingreso Mensual")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color.adaptiveLabel)
                            
                            Text("Configura tu ingreso mensual para un mejor control financiero")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top)
                        
                        // Form Section
                        VStack(spacing: 20) {
                            CustomTextField(
                                title: "Ingreso Mensual",
                                text: $monthlyIncome,
                                placeholder: "0.00",
                                icon: "dollarsign"
                            )
                            
                            Text("Este monto se usará para calcular tu balance mensual y progreso del presupuesto.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(20)
                        .background(Color.adaptiveSecondarySystemBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                saveIncome()
                            }) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "checkmark.circle.fill")
                                    }
                                    Text("Guardar Ingreso")
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .disabled(monthlyIncome.isEmpty || isLoading)
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: { dismiss() }) {
                                Text("Cancelar")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.adaptiveSecondarySystemBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
                }
            }
            #if os(iOS)
            .toolbar(.hidden, for: .navigationBar)
            #endif
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveIncome() {
        guard let amount = Double(monthlyIncome), amount > 0 else {
            errorMessage = "Por favor ingresa un monto válido"
            showingError = true
            return
        }
        
        isLoading = true
        
        Task {
            await MainActor.run {
                viewModel.setMonthlyIncome(Decimal(amount))
                self.isLoading = false
                self.dismiss()
            }
        }
    }
}

// MARK: - Professional Child Support Sheet
struct ProfessionalChildSupportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FinanceViewModel
    @State private var childSupportAmount = ""
    @State private var childSupportDate = Date()
    @State private var childSupportNotes = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showingSuccess = false
    @State private var showingCategoryManagement = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(
                    colors: [
                        Color.orange.opacity(0.05),
                        Color.red.opacity(0.02),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.orange)
                            
                            Text("Agregar Manutención")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color.adaptiveLabel)
                            
                            Text("Registra el pago de manutención para tus hijos")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top)
                        
                        // Form Section
                        VStack(spacing: 20) {
                            CustomTextField(
                                title: "Monto de Manutención",
                                text: $childSupportAmount,
                                placeholder: "0.00",
                                icon: "dollarsign"
                            )
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Fecha de Pago")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.adaptiveLabel)
                                
                                DatePicker("", selection: $childSupportDate, displayedComponents: .date)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .padding(12)
                                    .background(Color.adaptiveTertiarySystemBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notas (Opcional)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.adaptiveLabel)
                                
                                TextField("Ej: Pago mensual de manutención", text: $childSupportNotes)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .padding(12)
                                    .background(Color.adaptiveTertiarySystemBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .padding(20)
                        .background(Color.adaptiveSecondarySystemBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                saveChildSupport()
                            }) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "house.fill")
                                    }
                                    Text("Guardar Manutención")
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color.orange, Color.red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .disabled(childSupportAmount.isEmpty || isLoading)
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: { dismiss() }) {
                                Text("Cancelar")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.adaptiveSecondarySystemBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
                }
            }
            #if os(iOS)
            .toolbar(.hidden, for: .navigationBar)
            #endif
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .overlay(
                Group {
                    if showingSuccess {
                        ProfessionalSuccessState(
                            title: "¡Manutención Guardada!",
                            message: "El pago de manutención se ha registrado exitosamente",
                            icon: "house.fill",
                            color: .orange
                        )
                        .transition(.scale.combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: showingSuccess)
                    }
                }
            )
        }
    }
    
    private func saveChildSupport() {
        guard let amount = Double(childSupportAmount), amount > 0 else {
            errorMessage = "Por favor ingresa un monto válido"
            showingError = true
            return
        }
        
        isLoading = true
        
        Task {
            let newChildSupport = FinancialEntry(
                title: "Manutención",
                amount: Decimal(amount),
                category: .childSupport,
                expenseType: .fixed,
                date: childSupportDate,
                notes: childSupportNotes.isEmpty ? nil : childSupportNotes
            )
            
            await viewModel.addExpense(newChildSupport)
            
            await MainActor.run {
                self.isLoading = false
                if viewModel.errorMessage == nil {
                    // Show success state briefly before dismissing
                    self.showingSuccess = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.dismiss()
                    }
                } else {
                    self.errorMessage = viewModel.errorMessage ?? "Error desconocido"
                    self.showingError = true
                }
            }
        }
    }
}

// MARK: - Custom Expense Type Picker
struct CustomExpenseTypePicker: View {
    let title: String
    @Binding var selection: FinancialEntry.ExpenseType?
    let expenseTypes: [FinancialEntry.ExpenseType]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color.adaptiveLabel)
            
            HStack(spacing: 12) {
                ForEach(expenseTypes, id: \.self) { expenseType in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selection = expenseType
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: expenseType.icon)
                                .font(.subheadline)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(expenseType.displayName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text(expenseType.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selection == expenseType {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .foregroundColor(selection == expenseType ? .blue : Color.adaptiveLabel)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selection == expenseType ? Color.blue.opacity(0.1) : Color.adaptiveSecondarySystemBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selection == expenseType ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

// MARK: - Professional Edit Expense Sheet
struct ProfessionalEditExpenseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FinanceViewModel
    let expense: FinancialEntry
    
    @State private var expenseTitle = ""
    @State private var expenseAmount = ""
    @State private var expenseCategory: FinancialEntry.ExpenseCategory = .other
    @State private var expenseType: FinancialEntry.ExpenseType? = .variable
    @State private var expenseDate = Date()
    @State private var expenseNotes = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showingSuccess = false
    @State private var showingCategoryManagement = false
    
    private let categories = FinancialEntry.ExpenseCategory.allCases
    private let expenseTypes = FinancialEntry.ExpenseType.allCases
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        formSection
                        actionButtons
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .overlay(successOverlay)
        }
        .onAppear {
            loadExpenseData()
        }
    }
    
    private var backgroundGradient: some View {
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
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "pencil.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text("Editar Gasto")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.adaptiveLabel)
            
            Text("Modifica los detalles del gasto seleccionado")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }
    
    private var formSection: some View {
        VStack(spacing: 20) {
            CustomTextField(
                title: "Título del Gasto",
                text: $expenseTitle,
                placeholder: "Ej: Compra de supermercado",
                icon: "textformat"
            )
            
            CustomTextField(
                title: "Monto",
                text: $expenseAmount,
                placeholder: "0.00",
                icon: "dollarsign"
            )
            
            CustomCategoryPicker(
                title: "Categoría",
                selection: $expenseCategory,
                categories: categories
            )
            
            CustomExpenseTypePicker(
                title: "Tipo de Gasto",
                selection: $expenseType,
                expenseTypes: expenseTypes
            )
            
            datePickerSection
            notesSection
        }
        .padding(20)
        .background(Color.adaptiveSecondarySystemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var datePickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Fecha")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color.adaptiveLabel)
            
            DatePicker("", selection: $expenseDate, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .padding(12)
                .background(Color.adaptiveTertiarySystemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notas (Opcional)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color.adaptiveLabel)
            
            TextField("Agregar notas adicionales", text: $expenseNotes)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(12)
                .background(Color.adaptiveTertiarySystemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: updateExpense) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                    }
                    Text("Actualizar Gasto")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(expenseTitle.isEmpty || expenseAmount.isEmpty || isLoading)
            .buttonStyle(PlainButtonStyle())
            
            Button(action: { dismiss() }) {
                Text("Cancelar")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.adaptiveSecondarySystemBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var successOverlay: some View {
        Group {
            if showingSuccess {
                ProfessionalSuccessState(
                    title: "¡Gasto Actualizado!",
                    message: "El gasto se ha actualizado exitosamente",
                    icon: "checkmark.circle.fill"
                )
            }
        }
    }
    
    private func loadExpenseData() {
        expenseTitle = expense.title
        expenseAmount = String(describing: expense.amount)
        expenseCategory = expense.category
        expenseType = expense.expenseType ?? .variable
        expenseDate = expense.date
        expenseNotes = expense.notes ?? ""
    }
    
    private func updateExpense() {
        guard let amount = Double(expenseAmount), amount > 0 else {
            errorMessage = "Por favor ingresa un monto válido"
            showingError = true
            return
        }
        
        isLoading = true
        
        Task {
            expense.title = expenseTitle
            expense.amount = Decimal(amount)
            expense.category = expenseCategory
            expense.expenseType = expenseType
            expense.date = expenseDate
            expense.notes = expenseNotes.isEmpty ? nil : expenseNotes
            expense.updatedAt = Date()
            
            await viewModel.updateExpense(expense)
            
            await MainActor.run {
                self.isLoading = false
                if viewModel.errorMessage == nil {
                    self.showingSuccess = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.dismiss()
                    }
                } else {
                    self.errorMessage = viewModel.errorMessage ?? "Error desconocido"
                    self.showingError = true
                }
            }
        }
    }
}

// MARK: - Analytics Preview Card
struct AnalyticsPreviewCard: View {
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
                .foregroundColor(Color.adaptiveLabel)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.adaptiveTertiarySystemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Helper Functions
extension FinanceView {
    private func calculateTrendText() -> String {
        // Simple trend calculation based on recent expenses
        let recentExpenses = viewModel.recentExpenses.prefix(5)
        let olderExpenses = viewModel.expenses.dropFirst(5).prefix(5)
        
        let recentTotal = recentExpenses.reduce(0) { $0 + Double(truncating: NSDecimalNumber(decimal: $1.amount)) }
        let olderTotal = olderExpenses.reduce(0) { $0 + Double(truncating: NSDecimalNumber(decimal: $1.amount)) }
        
        guard olderTotal > 0 else { return "N/A" }
        
        let change = ((recentTotal - olderTotal) / olderTotal) * 100
        
        if change > 5 {
            return "↗️ +\(String(format: "%.0f", change))%"
        } else if change < -5 {
            return "↘️ \(String(format: "%.0f", change))%"
        } else {
            return "➡️ Estable"
        }
    }
    
    private func calculateDailyAverage() -> Decimal {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let days = calendar.dateComponents([.day], from: startOfMonth, to: now).day ?? 1
        
        let monthlyExpenses = viewModel.expenses.filter { expense in
            calendar.isDate(expense.date, equalTo: now, toGranularity: .month)
        }
        
        let total = monthlyExpenses.reduce(0) { $0 + $1.amount }
        return total / Decimal(days)
    }
}

#Preview {
    FinanceView()
}
