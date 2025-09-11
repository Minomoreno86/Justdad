//
//  FinanceView.swift
//  JustDad - Professional Financial Management
//
//  Advanced expense tracking, budgeting, and financial insights for fathers

import SwiftUI
#if os(iOS)
import UIKit
#else
import AppKit
#endif

// MARK: - Color Extensions
extension Color {
    static var adaptiveLabel: Color {
        #if os(iOS)
        return Color(UIColor.label)
        #else
        return Color.primary
        #endif
    }
    
    static var adaptiveSecondarySystemBackground: Color {
        #if os(iOS)
        return Color(UIColor.secondarySystemBackground)
        #else
        return Color(NSColor.controlBackgroundColor)
        #endif
    }
    
    static var adaptiveTertiarySystemBackground: Color {
        #if os(iOS)
        return Color(UIColor.tertiarySystemBackground)
        #else
        return Color(NSColor.tertiarySystemFill)
        #endif
    }
}

struct FinanceView: View {
    @State private var showingNewExpenseSheet = false
    @State private var selectedPeriod = "Este Mes"
    @State private var expenses: [MockExpense] = MockExpense.sampleExpenses
    @State private var showingReportsSheet = false
    @State private var selectedTab = 0
    
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
                        
                        // Export & Reports Section
                        reportsSection
                        
                        // Bottom padding for tab bar
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            #if os(iOS)
            .toolbar(.hidden, for: .navigationBar)
            #endif
            .sheet(isPresented: $showingNewExpenseSheet) {
                ProfessionalNewExpenseSheet()
            }
            .sheet(isPresented: $showingReportsSheet) {
                ProfessionalReportsSheet()
            }
        }
    }
    
    // MARK: - Professional Header
    private var professionalHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Control Financiero")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.adaptiveLabel)
                    
                    Text("Gestiona tus gastos con inteligencia")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { showingNewExpenseSheet = true }) {
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
                amount: "$2,450",
                trend: "+12%",
                trendDirection: .down,
                icon: "creditcard.fill",
                gradientColors: [Color.blue, Color.purple],
                isMainCard: true
            )
            
            // Secondary Cards
            HStack(spacing: 12) {
                ProfessionalFinanceCard(
                    title: "Manutención",
                    amount: "$1,200",
                    trend: "Fijo",
                    trendDirection: .neutral,
                    icon: "house.fill",
                    gradientColors: [Color.orange, Color.red],
                    isMainCard: false
                )
                
                ProfessionalFinanceCard(
                    title: "Extras",
                    amount: "$1,250",
                    trend: "+25%",
                    trendDirection: .up,
                    icon: "cart.fill",
                    gradientColors: [Color.green, Color.blue],
                    isMainCard: false
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
                    .fontWeight(.semibold)
                    .foregroundColor(Color.adaptiveLabel)
                
                Spacer()
            }
            
            // Professional Period Selector
            HStack(spacing: 0) {
                ForEach(Array(periods.enumerated()), id: \.offset) { index, period in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedPeriod = period
                        }
                    }) {
                        Text(period)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedPeriod == period ? .white : Color.adaptiveLabel)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                selectedPeriod == period ? 
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
                    .fontWeight(.semibold)
                    .foregroundColor(Color.adaptiveLabel)
                
                Spacer()
                
                Button("Ver Todo") {
                    // TODO: Navigate to full expenses list
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.blue)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(Array(MockExpense.sampleExpenses.prefix(5))) { expense in
                    ProfessionalExpenseRow(
                        title: expense.title,
                        category: expense.category,
                        amount: expense.amount,
                        date: expense.date,
                        icon: expense.icon,
                        color: expense.color
                    )
                }
            }
        }
    }
    
    // MARK: - Financial Insights Section
    private var financialInsightsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Insights Financieros")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.adaptiveLabel)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                FinancialInsightCard(
                    title: "Ahorro Mensual",
                    value: "$850",
                    icon: "piggybank.fill",
                    color: .green
                )
                
                FinancialInsightCard(
                    title: "Meta Cumplida",
                    value: "78%",
                    icon: "target",
                    color: .blue
                )
            }
        }
    }
    
    // MARK: - Reports Section
    private var reportsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Reportes y Exportación")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.adaptiveLabel)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                Button(action: { showingReportsSheet = true }) {
                    HStack {
                        Image(systemName: "chart.bar.doc.horizontal.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Generar Reporte Completo")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("PDF con análisis detallado")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .font(.subheadline)
                            .foregroundColor(.white)
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
                
                HStack(spacing: 12) {
                    ExportButton(
                        title: "CSV",
                        icon: "tablecells.fill",
                        color: .green
                    ) {
                        // TODO: Export CSV
                    }
                    
                    ExportButton(
                        title: "Excel",
                        icon: "doc.spreadsheet.fill",
                        color: .orange
                    ) {
                        // TODO: Export Excel
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func expenseIcon(for category: String) -> String {
        switch category.lowercased() {
        case "educación": return "book.fill"
        case "salud": return "cross.fill"
        case "alimentación": return "fork.knife"
        case "transporte": return "car.fill"
        case "entretenimiento": return "gamecontroller.fill"
        default: return "dollarsign.circle.fill"
        }
    }
    
    private func expenseColor(for category: String) -> Color {
        switch category.lowercased() {
        case "educación": return .blue
        case "salud": return .red
        case "alimentación": return .green
        case "transporte": return .orange
        case "entretenimiento": return .purple
        default: return .gray
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
    @State private var expenseTitle = ""
    @State private var expenseAmount = ""
    @State private var expenseCategory = "Otros"
    @State private var expenseDate = Date()
    @State private var expenseNotes = ""
    
    private let categories = ["Educación", "Salud", "Alimentación", "Vestimenta", "Transporte", "Entretenimiento", "Regalos", "Otros"]
    
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
                                    
                                    CustomCategoryPicker(
                                        title: "Categoría",
                                        selection: $expenseCategory,
                                        categories: categories
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
                                // TODO: Save expense
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
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
                            .disabled(expenseTitle.isEmpty || expenseAmount.isEmpty)
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
    @Binding var selection: String
    let categories: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color.adaptiveLabel)
            
            Menu {
                ForEach(categories, id: \.self) { category in
                    Button(category) {
                        selection = category
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "tag.fill")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .frame(width: 20)
                    
                    Text(selection)
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

#Preview {
    FinanceView()
}
