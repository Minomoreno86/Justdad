//
//  ProfessionalReportsView.swift
//  JustDad - Professional Financial Reports
//
//  Advanced report generation interface with multiple formats and customization options
//

import SwiftUI
import UIKit

struct ProfessionalReportsView: View {
    @StateObject private var reportService = ProfessionalFinancialReportService.shared
    @State private var selectedDateRange: DateRange = .thisMonth
    @State private var selectedReportType: ProfessionalFinancialReportService.ReportType = .pdf
    @State private var includeCharts = true
    @State private var includeAnalytics = true
    @State private var showingDatePicker = false
    @State private var showingShareSheet = false
    @State private var generatedReportURL: URL?
    @State private var showingError = false
    @State private var errorMessage = ""
    
    // Mock data for preview
    @State private var mockExpenses: [ReportMockExpense] = []
    @State private var totalAmount: Decimal = 0
    
    enum DateRange: String, CaseIterable {
        case thisWeek = "Esta Semana"
        case thisMonth = "Este Mes"
        case lastMonth = "Mes Anterior"
        case thisQuarter = "Este Trimestre"
        case thisYear = "Este Año"
        case custom = "Personalizado"
        
        var dateInterval: DateInterval? {
            let calendar = Calendar.current
            let now = Date()
            
            switch self {
            case .thisWeek:
                return calendar.dateInterval(of: .weekOfYear, for: now)
            case .thisMonth:
                return calendar.dateInterval(of: .month, for: now)
            case .lastMonth:
                guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) else { return nil }
                return calendar.dateInterval(of: .month, for: lastMonth)
            case .thisQuarter:
                let quarter = calendar.component(.month, from: now) / 3
                guard let startOfQuarter = calendar.date(from: DateComponents(year: calendar.component(.year, from: now), month: quarter * 3 - 2, day: 1)) else { return nil }
                return DateInterval(start: startOfQuarter, end: now)
            case .thisYear:
                return calendar.dateInterval(of: .year, for: now)
            case .custom:
                return nil
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Professional Background
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
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header Section
                        headerSection
                        
                        // Report Type Selection
                        reportTypeSection
                        
                        // Date Range Selection
                        dateRangeSection
                        
                        // Customization Options
                        customizationSection
                        
                        // Preview Section
                        previewSection
                        
                        // Generate Report Button
                        generateButton
                        
                        // Recent Reports
                        recentReportsSection
                        
                        // Bottom padding
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Reportes Profesionales")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .sheet(isPresented: $showingDatePicker) {
                CustomDateRangePicker(selectedRange: $selectedDateRange)
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = generatedReportURL {
                    ReportShareSheet(items: [url])
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
        .onAppear {
            loadMockData()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Generador de Reportes")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Crea reportes profesionales de tus finanzas")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Último Reporte")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let lastReport = reportService.lastReportGenerated {
                        Text(DateFormatter.relativeFormatter.string(from: lastReport))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    } else {
                        Text("Nunca")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Quick Stats
            HStack(spacing: 16) {
                ReportQuickStatCard(
                    title: "Total Gastos",
                    value: formatCurrency(totalAmount),
                    icon: "creditcard.fill",
                    color: .red
                )
                
                ReportQuickStatCard(
                    title: "Transacciones",
                    value: "\(mockExpenses.count)",
                    icon: "list.bullet",
                    color: .blue
                )
                
                ReportQuickStatCard(
                    title: "Categorías",
                    value: "\(Set(mockExpenses.map { $0.category }).count)",
                    icon: "chart.pie.fill",
                    color: .green
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Report Type Section
    private var reportTypeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tipo de Reporte")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(ProfessionalFinancialReportService.ReportType.allCases, id: \.self) { type in
                    ReportTypeCard(
                        type: type,
                        isSelected: selectedReportType == type,
                        action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedReportType = type
                            }
                        }
                    )
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Date Range Section
    private var dateRangeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Período del Reporte")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(DateRange.allCases, id: \.self) { range in
                    DateRangeCard(
                        range: range,
                        isSelected: selectedDateRange == range,
                        action: {
                            if range == .custom {
                                showingDatePicker = true
                            } else {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedDateRange = range
                                }
                            }
                        }
                    )
                }
            }
            
            if selectedDateRange == .custom, let interval = selectedDateRange.dateInterval {
                HStack {
                    Text("Período seleccionado:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(DateFormatter.reportDateFormatter.string(from: interval.start)) - \(DateFormatter.reportDateFormatter.string(from: interval.end))")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Customization Section
    private var customizationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Opciones de Personalización")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                CustomizationRow(
                    title: "Incluir Gráficos",
                    subtitle: "Agregar visualizaciones al reporte",
                    isEnabled: $includeCharts,
                    icon: "chart.bar.fill"
                )
                
                CustomizationRow(
                    title: "Incluir Analytics",
                    subtitle: "Agregar análisis e insights",
                    isEnabled: $includeAnalytics,
                    icon: "brain.head.profile"
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Preview Section
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Vista Previa del Reporte")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                PreviewRow(
                    title: "Tipo de Archivo",
                    value: selectedReportType.rawValue,
                    icon: selectedReportType.icon
                )
                
                PreviewRow(
                    title: "Período",
                    value: selectedDateRange.rawValue,
                    icon: "calendar"
                )
                
                PreviewRow(
                    title: "Transacciones Incluidas",
                    value: "\(filteredExpenses.count)",
                    icon: "list.bullet"
                )
                
                PreviewRow(
                    title: "Tamaño Estimado",
                    value: estimatedFileSize,
                    icon: "doc.fill"
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Generate Button
    private var generateButton: some View {
        VStack(spacing: 12) {
            Button(action: generateReport) {
                HStack {
                    if reportService.isGeneratingReport {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "doc.badge.plus")
                    }
                    
                    Text(reportService.isGeneratingReport ? "Generando..." : "Generar Reporte")
                }
                .font(.headline)
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
            .disabled(reportService.isGeneratingReport || selectedDateRange.dateInterval == nil)
            .buttonStyle(PlainButtonStyle())
            
            if reportService.isGeneratingReport {
                ProgressView(value: reportService.reportProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(y: 2)
            }
        }
    }
    
    // MARK: - Recent Reports Section
    private var recentReportsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reportes Recientes")
                .font(.headline)
                .foregroundColor(.primary)
            
            // This would show recent generated reports
            Text("No hay reportes recientes")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Computed Properties
    private var filteredExpenses: [ReportMockExpense] {
        guard let dateInterval = selectedDateRange.dateInterval else { return [] }
        return mockExpenses.filter { dateInterval.contains($0.date) }
    }
    
    private var estimatedFileSize: String {
        let baseSize = filteredExpenses.count * 50 // Base size per transaction
        let chartSize = includeCharts ? 50000 : 0
        let analyticsSize = includeAnalytics ? 10000 : 0
        let totalBytes = baseSize + chartSize + analyticsSize
        
        if totalBytes < 1024 {
            return "\(totalBytes) B"
        } else if totalBytes < 1024 * 1024 {
            return "\(totalBytes / 1024) KB"
        } else {
            return "\(totalBytes / (1024 * 1024)) MB"
        }
    }
    
    // MARK: - Actions
    private func generateReport() {
        guard let dateInterval = selectedDateRange.dateInterval else { return }
        
        Task {
            do {
                let url = try await reportService.generateReport(
                    type: selectedReportType,
                    dateRange: dateInterval,
                    includeCharts: includeCharts,
                    includeAnalytics: includeAnalytics
                )
                
                await MainActor.run {
                    generatedReportURL = url
                    showingShareSheet = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    private func loadMockData() {
        // Load mock data for preview
        mockExpenses = [
            ReportMockExpense(title: "Supermercado", amount: 150.00, category: "Alimentación", date: Date()),
            ReportMockExpense(title: "Gasolina", amount: 80.00, category: "Transporte", date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()),
            ReportMockExpense(title: "Renta", amount: 1200.00, category: "Vivienda", date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date())
        ]
        
        totalAmount = mockExpenses.reduce(0) { $0 + $1.amount }
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "es_US")
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }
}

// MARK: - Supporting Views
struct ReportQuickStatCard: View {
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
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ReportTypeCard: View {
    let type: ProfessionalFinancialReportService.ReportType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: type.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                isSelected ?
                LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing) :
                LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DateRangeCard: View {
    let range: ProfessionalReportsView.DateRange
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(range.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                isSelected ?
                LinearGradient(colors: [Color.green, Color.blue], startPoint: .leading, endPoint: .trailing) :
                LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CustomizationRow: View {
    let title: String
    let subtitle: String
    @Binding var isEnabled: Bool
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
        .padding(.vertical, 4)
    }
}

struct PreviewRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Custom Date Range Picker
struct CustomDateRangePicker: View {
    @Binding var selectedRange: ProfessionalReportsView.DateRange
    @State private var startDate = Date()
    @State private var endDate = Date()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Seleccionar Período Personalizado")
                    .font(.headline)
                    .padding()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Fecha de Inicio")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    DatePicker("", selection: $startDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Fecha de Fin")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    DatePicker("", selection: $endDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Aplicar") {
                        // Set custom date range
                        selectedRange = .custom
                        dismiss()
                    }
                }
                #endif
            }
        }
    }
}

// MARK: - Share Sheet
struct ReportShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Mock Data
struct ReportMockExpense {
    let title: String
    let amount: Decimal
    let category: String
    let date: Date
}

// MARK: - Date Formatters
extension DateFormatter {
    static let relativeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    static let reportDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()
}

#Preview {
    ProfessionalReportsView()
}