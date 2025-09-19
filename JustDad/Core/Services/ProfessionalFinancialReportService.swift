//
//  ProfessionalFinancialReportService.swift
//  JustDad - Professional Financial Report Generation
//
//  Advanced report generation with PDF, Excel, CSV exports including charts and analytics
//

import Foundation
import SwiftUI
import PDFKit
import Charts
import UniformTypeIdentifiers

@MainActor
class ProfessionalFinancialReportService: ObservableObject {
    static let shared = ProfessionalFinancialReportService()
    
    @Published var isGeneratingReport = false
    @Published var reportProgress: Double = 0.0
    @Published var lastReportGenerated: Date?
    @Published var currentReportType: ReportType = .pdf
    
    private let persistenceService = PersistenceService.shared
    // private let analyticsService = ProfessionalFinancialAnalyticsService.shared // TODO: Implement analytics service
    
    private init() {}
    
    // MARK: - Report Types
    enum ReportType: String, CaseIterable {
        case pdf = "PDF"
        case excel = "Excel"
        case csv = "CSV"
        case summary = "Resumen"
        
        var icon: String {
            switch self {
            case .pdf: return "doc.fill"
            case .excel: return "tablecells.fill"
            case .csv: return "doc.text.fill"
            case .summary: return "chart.bar.doc.horizontal.fill"
            }
        }
        
        var fileExtension: String {
            switch self {
            case .pdf: return "pdf"
            case .excel: return "xlsx"
            case .csv: return "csv"
            case .summary: return "pdf"
            }
        }
    }
    
    // MARK: - Report Generation
    func generateReport(
        type: ReportType,
        dateRange: DateInterval,
        includeCharts: Bool = true,
        includeAnalytics: Bool = true
    ) async throws -> URL {
        isGeneratingReport = true
        reportProgress = 0.0
        currentReportType = type
        
        defer {
            isGeneratingReport = false
            reportProgress = 0.0
        }
        
        // Gather financial data
        let financialData = try await gatherFinancialData(for: dateRange)
        reportProgress = 0.2
        
        // Generate analytics if requested
        let analytics = includeAnalytics ? try await generateAnalytics(for: financialData, dateRange: dateRange) : nil
        reportProgress = 0.4
        
        // Generate report based on type
        let url: URL
        switch type {
        case .pdf:
            url = try await generatePDFReport(
                data: financialData,
                analytics: analytics,
                dateRange: dateRange,
                includeCharts: includeCharts
            )
        case .excel:
            url = try await generateExcelReport(
                data: financialData,
                analytics: analytics,
                dateRange: dateRange
            )
        case .csv:
            url = try await generateCSVReport(
                data: financialData,
                dateRange: dateRange
            )
        case .summary:
            url = try await generateSummaryReport(
                data: financialData,
                analytics: analytics,
                dateRange: dateRange
            )
        }
        
        reportProgress = 1.0
        lastReportGenerated = Date()
        return url
    }
    
    // MARK: - Data Gathering
    private func gatherFinancialData(for dateRange: DateInterval) async throws -> FinancialReportData {
        // TODO: Implement when PersistenceService has fetchFinancialEntries method
        // For now, return mock data
        let mockExpenses: [Any] = []
        let totalExpenses: Decimal = 0
        let categoryBreakdown: [String: Decimal] = [:]
        let monthlyBreakdown: [Date: Decimal] = [:]
        
        return FinancialReportData(
            expenses: mockExpenses,
            totalAmount: totalExpenses,
            categoryBreakdown: categoryBreakdown,
            monthlyBreakdown: monthlyBreakdown,
            dateRange: dateRange,
            generatedDate: Date()
        )
    }
    
    // MARK: - Analytics Generation
    private func generateAnalytics(for data: FinancialReportData, dateRange: DateInterval) async throws -> FinancialAnalytics {
        // TODO: Implement analytics service integration
        return FinancialAnalytics(
            totalExpenses: data.totalAmount,
            averageDaily: data.totalAmount / Decimal(Calendar.current.dateComponents([.day], from: dateRange.start, to: dateRange.end).day ?? 1),
            topCategory: data.categoryBreakdown.max(by: { $0.value < $1.value })?.key,
            expenseTrend: calculateExpenseTrend(data: data),
            insights: generateInsights(data: data)
        )
    }
    
    // MARK: - PDF Report Generation
    private func generatePDFReport(
        data: FinancialReportData,
        analytics: FinancialAnalytics?,
        dateRange: DateInterval,
        includeCharts: Bool
    ) async throws -> URL {
        reportProgress = 0.6
        
        let pdfDocument = PDFDocument()
        
        // Title Page
        let titlePage = createPDFTitlePage(data: data, dateRange: dateRange)
        pdfDocument.insert(titlePage, at: 0)
        
        // Executive Summary
        if let analytics = analytics {
            let summaryPage = createPDFSummaryPage(analytics: analytics)
            pdfDocument.insert(summaryPage, at: pdfDocument.pageCount)
        }
        
        // Financial Overview
        let overviewPage = createPDFOverviewPage(data: data)
        pdfDocument.insert(overviewPage, at: pdfDocument.pageCount)
        
        // Category Breakdown
        let categoryPage = createPDFCategoryPage(data: data)
        pdfDocument.insert(categoryPage, at: pdfDocument.pageCount)
        
        // Monthly Trends
        let trendsPage = createPDFTrendsPage(data: data)
        pdfDocument.insert(trendsPage, at: pdfDocument.pageCount)
        
        // Detailed Transactions
        let transactionsPage = createPDFTransactionsPage(data: data)
        pdfDocument.insert(transactionsPage, at: pdfDocument.pageCount)
        
        // Save PDF
        reportProgress = 0.8
        let url = try savePDFToDocuments(pdfDocument, dateRange: dateRange)
        return url
    }
    
    // MARK: - Excel Report Generation
    private func generateExcelReport(
        data: FinancialReportData,
        analytics: FinancialAnalytics?,
        dateRange: DateInterval
    ) async throws -> URL {
        reportProgress = 0.6
        
        // Create Excel content (simplified - in real implementation would use a proper Excel library)
        let excelContent = createExcelContent(data: data, analytics: analytics, dateRange: dateRange)
        
        reportProgress = 0.8
        let url = try saveExcelToDocuments(excelContent, dateRange: dateRange)
        return url
    }
    
    // MARK: - CSV Report Generation
    private func generateCSVReport(
        data: FinancialReportData,
        dateRange: DateInterval
    ) async throws -> URL {
        reportProgress = 0.6
        
        let csvContent = createCSVContent(data: data)
        
        reportProgress = 0.8
        let url = try saveCSVToDocuments(csvContent, dateRange: dateRange)
        return url
    }
    
    // MARK: - Summary Report Generation
    private func generateSummaryReport(
        data: FinancialReportData,
        analytics: FinancialAnalytics?,
        dateRange: DateInterval
    ) async throws -> URL {
        reportProgress = 0.6
        
        let pdfDocument = PDFDocument()
        
        // Summary Title Page
        let titlePage = createPDFTitlePage(data: data, dateRange: dateRange, isSummary: true)
        pdfDocument.insert(titlePage, at: 0)
        
        // Key Metrics Summary
        if let analytics = analytics {
            let summaryPage = createPDFSummaryPage(analytics: analytics, isDetailed: true)
            pdfDocument.insert(summaryPage, at: pdfDocument.pageCount)
        }
        
        reportProgress = 0.8
        let url = try savePDFToDocuments(pdfDocument, dateRange: dateRange, isSummary: true)
        return url
    }
    
    // MARK: - PDF Page Creation
    private func createPDFTitlePage(data: FinancialReportData, dateRange: DateInterval, isSummary: Bool = false) -> PDFPage {
        let page = PDFPage()
        // In a real implementation, this would use Core Graphics to draw the title page
        return page
    }
    
    private func createPDFSummaryPage(analytics: FinancialAnalytics, isDetailed: Bool = false) -> PDFPage {
        let page = PDFPage()
        // In a real implementation, this would use Core Graphics to draw the summary
        return page
    }
    
    private func createPDFOverviewPage(data: FinancialReportData) -> PDFPage {
        let page = PDFPage()
        // In a real implementation, this would use Core Graphics to draw the overview
        return page
    }
    
    private func createPDFCategoryPage(data: FinancialReportData) -> PDFPage {
        let page = PDFPage()
        // In a real implementation, this would use Core Graphics to draw the category breakdown
        return page
    }
    
    private func createPDFTrendsPage(data: FinancialReportData) -> PDFPage {
        let page = PDFPage()
        // In a real implementation, this would use Core Graphics to draw the trends
        return page
    }
    
    private func createPDFTransactionsPage(data: FinancialReportData) -> PDFPage {
        let page = PDFPage()
        // In a real implementation, this would use Core Graphics to draw the transactions table
        return page
    }
    
    // MARK: - Content Generation
    private func createExcelContent(data: FinancialReportData, analytics: FinancialAnalytics?, dateRange: DateInterval) -> String {
        var content = "JustDad - Reporte Financiero\n"
        content += "Período: \(DateFormatter.reportDateFormatter.string(from: dateRange.start)) - \(DateFormatter.reportDateFormatter.string(from: dateRange.end))\n"
        content += "Generado: \(DateFormatter.reportDateFormatter.string(from: Date()))\n\n"
        
        // Summary Section
        content += "RESUMEN EJECUTIVO\n"
        content += "================\n"
        content += "Total de Gastos: $\(formatCurrency(data.totalAmount))\n"
        content += "Número de Transacciones: \(data.expenses.count)\n"
        if let analytics = analytics {
            content += "Promedio Diario: $\(formatCurrency(analytics.averageDaily))\n"
            content += "Categoría Principal: \(analytics.topCategory ?? "N/A")\n"
        }
        content += "\n"
        
        // Category Breakdown
        content += "DESGLOSE POR CATEGORÍA\n"
        content += "=====================\n"
        for (category, amount) in data.categoryBreakdown.sorted(by: { $0.value > $1.value }) {
            let percentage = (amount / data.totalAmount) * 100
            content += "\(category): $\(formatCurrency(amount)) (\(String(format: "%.1f", Double(truncating: NSDecimalNumber(decimal: percentage))))%)\n"
        }
        content += "\n"
        
        // Monthly Breakdown
        content += "DESGLOSE MENSUAL\n"
        content += "===============\n"
        for (month, amount) in data.monthlyBreakdown.sorted(by: { $0.key < $1.key }) {
            content += "\(DateFormatter.monthYearFormatter.string(from: month)): $\(formatCurrency(amount))\n"
        }
        content += "\n"
        
        // Detailed Transactions
        content += "TRANSACCIONES DETALLADAS\n"
        content += "=======================\n"
        content += "Fecha,Título,Categoría,Tipo,Monto,Notas\n"
        // TODO: Implement when FinancialEntry is available
        content += "Datos de transacciones no disponibles en esta versión\n"
        
        return content
    }
    
    private func createCSVContent(data: FinancialReportData) -> String {
        var content = "Fecha,Título,Categoría,Tipo,Monto,Notas\n"
        // TODO: Implement when FinancialEntry is available
        content += "Datos de transacciones no disponibles en esta versión\n"
        return content
    }
    
    // MARK: - Helper Functions
    private func calculateExpenseTrend(data: FinancialReportData) -> ExpenseTrend {
        let sortedMonths = data.monthlyBreakdown.sorted(by: { $0.key < $1.key })
        guard sortedMonths.count >= 2 else { return .stable }
        
        let recent = sortedMonths.last?.value ?? 0
        let previous = sortedMonths[sortedMonths.count - 2].value
        
        if previous == 0 { return .stable }
        
        let change = ((recent - previous) / previous) * 100
        
        if change > 10 { return .increasing }
        else if change < -10 { return .decreasing }
        else { return .stable }
    }
    
    private func generateInsights(data: FinancialReportData) -> [String] {
        var insights: [String] = []
        
        // Top spending category insight
        if let topCategory = data.categoryBreakdown.max(by: { $0.value < $1.value }) {
            let percentage = (topCategory.value / data.totalAmount) * 100
            insights.append("Tu categoría de mayor gasto es \(topCategory.key) con \(String(format: "%.1f", Double(truncating: NSDecimalNumber(decimal: percentage))))% del total")
        }
        
        // Spending pattern insight
        if data.expenses.count > 10 {
            let averageAmount = data.totalAmount / Decimal(data.expenses.count)
            insights.append("Tu gasto promedio por transacción es de \(formatCurrency(averageAmount))")
        }
        
        // Monthly trend insight
        let trend = calculateExpenseTrend(data: data)
        switch trend {
        case .increasing:
            insights.append("Tus gastos han aumentado en el período analizado")
        case .decreasing:
            insights.append("Tus gastos han disminuido en el período analizado")
        case .stable:
            insights.append("Tus gastos se han mantenido estables en el período analizado")
        }
        
        return insights
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "es_US")
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }
    
    // MARK: - File Saving
    private func savePDFToDocuments(_ pdfDocument: PDFDocument, dateRange: DateInterval, isSummary: Bool = false) throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = isSummary ? 
            "JustDad_Resumen_\(DateFormatter.fileNameFormatter.string(from: Date())).pdf" :
            "JustDad_Reporte_\(DateFormatter.fileNameFormatter.string(from: Date())).pdf"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        guard pdfDocument.write(to: fileURL) else {
            throw ReportError.fileWriteFailed
        }
        
        return fileURL
    }
    
    private func saveExcelToDocuments(_ content: String, dateRange: DateInterval) throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "JustDad_Reporte_\(DateFormatter.fileNameFormatter.string(from: Date())).xlsx"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
    
    private func saveCSVToDocuments(_ content: String, dateRange: DateInterval) throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "JustDad_Transacciones_\(DateFormatter.fileNameFormatter.string(from: Date())).csv"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
}

// MARK: - Data Models
struct FinancialReportData {
    let expenses: [Any] // TODO: Replace with FinancialEntry when available
    let totalAmount: Decimal
    let categoryBreakdown: [String: Decimal] // TODO: Replace with FinancialEntry.ExpenseCategory
    let monthlyBreakdown: [Date: Decimal]
    let dateRange: DateInterval
    let generatedDate: Date
}

struct FinancialAnalytics {
    let totalExpenses: Decimal
    let averageDaily: Decimal
    let topCategory: String? // TODO: Replace with FinancialEntry.ExpenseCategory
    let expenseTrend: ExpenseTrend
    let insights: [String]
}

enum ExpenseTrend {
    case increasing
    case decreasing
    case stable
}

enum ReportError: LocalizedError {
    case fileWriteFailed
    case dataGatheringFailed
    case reportGenerationFailed
    
    var errorDescription: String? {
        switch self {
        case .fileWriteFailed:
            return "No se pudo escribir el archivo del reporte"
        case .dataGatheringFailed:
            return "No se pudo recopilar los datos para el reporte"
        case .reportGenerationFailed:
            return "No se pudo generar el reporte"
        }
    }
}

// MARK: - Date Formatters
extension DateFormatter {
    static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()
    
    static let csvDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
