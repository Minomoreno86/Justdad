//
//  DataExportService.swift
//  JustDad - Data export service
//
//  Handles data export in various formats (PDF, CSV, JSON)
//

import Foundation
import SwiftData
import PDFKit
import UniformTypeIdentifiers

// MARK: - Data Models
struct ExportData {
    var visits: [Any] = []
    var financialEntries: [Any] = []
    var emotionalEntries: [Any] = []
    var diaryEntries: [Any] = []
    var emergencyContacts: [Any] = []
    var exportDate: Date = Date()
}

@MainActor
class DataExportService: ObservableObject {
    static let shared = DataExportService()
    
    @Published var isExporting = false
    @Published var exportProgress: Double = 0.0
    @Published var lastExportDate: Date?
    
    private let persistenceService = PersistenceService.shared
    private let securityService = SecurityService.shared
    
    private init() {}
    
    // MARK: - Export Methods
    func exportToPDF(for dateRange: DateInterval) async throws -> URL {
        isExporting = true
        exportProgress = 0.0
        
        defer {
            isExporting = false
            exportProgress = 0.0
        }
        
        let data = try await gatherAllData(for: dateRange)
        exportProgress = 0.3
        
        let pdfDocument = try await generatePDF(from: data, dateRange: dateRange)
        exportProgress = 0.7
        
        let url = try savePDFToDocuments(pdfDocument)
        exportProgress = 1.0
        
        lastExportDate = Date()
        return url
    }
    
    func exportToCSV(for dateRange: DateInterval) async throws -> URL {
        isExporting = true
        exportProgress = 0.0
        
        defer {
            isExporting = false
            exportProgress = 0.0
        }
        
        let data = try await gatherAllData(for: dateRange)
        exportProgress = 0.5
        
        let csvContent = generateCSV(from: data)
        exportProgress = 0.8
        
        let url = try saveCSVToDocuments(csvContent, dateRange: dateRange)
        exportProgress = 1.0
        
        lastExportDate = Date()
        return url
    }
    
    func exportToJSON(for dateRange: DateInterval) async throws -> URL {
        isExporting = true
        exportProgress = 0.0
        
        defer {
            isExporting = false
            exportProgress = 0.0
        }
        
        let data = try await gatherAllData(for: dateRange)
        exportProgress = 0.5
        
        let jsonData = try JSONSerialization.data(withJSONObject: [
            "visits": data.visits.map { visit in
                if let visit = visit as? Visit {
                    return [
                        "id": visit.id.uuidString,
                        "title": visit.title,
                        "startDate": visit.startDate.timeIntervalSince1970,
                        "endDate": visit.endDate.timeIntervalSince1970,
                        "location": visit.location,
                        "notes": visit.notes,
                        "type": visit.type
                    ]
                }
                return [:]
            },
            "financialEntries": data.financialEntries.map { entry in
                if let entry = entry as? FinancialEntry {
                    return [
                        "id": entry.id.uuidString,
                        "title": entry.title,
                        "amount": entry.amount,
                        "category": entry.category.rawValue,
                        "date": entry.date.timeIntervalSince1970,
                        "notes": entry.notes
                    ]
                }
                return [:]
            },
            "emotionalEntries": data.emotionalEntries.map { entry in
                if let entry = entry as? EmotionalEntry {
                    return [
                        "id": entry.id.uuidString,
                        "mood": entry.mood,
                        "energyLevel": entry.energyLevel,
                        "date": entry.date.timeIntervalSince1970,
                        "note": entry.note
                    ]
                }
                return [:]
            },
            "diaryEntries": data.diaryEntries.map { entry in
                if let entry = entry as? DiaryEntry {
                    return [
                        "id": entry.id.uuidString,
                        "title": entry.title,
                        "content": entry.content,
                        "date": entry.date.timeIntervalSince1970,
                        "mood": entry.mood
                    ]
                }
                return [:]
            },
            "exportDate": data.exportDate.timeIntervalSince1970
        ], options: .prettyPrinted)
        exportProgress = 0.8
        
        let url = try saveJSONToDocuments(jsonData, dateRange: dateRange)
        exportProgress = 1.0
        
        lastExportDate = Date()
        return url
    }
    
    // MARK: - Data Gathering
    private func gatherAllData(for dateRange: DateInterval) async throws -> ExportData {
        var exportData = ExportData()
        
        // Gather visits
        do {
            let allVisits = try persistenceService.fetchVisits()
            exportData.visits = allVisits.filter { visit in
                dateRange.contains(visit.startDate) || dateRange.contains(visit.endDate)
            }
        } catch {
            print("Error fetching visits: \(error)")
        }
        
        // Gather financial entries
        do {
            let allFinancialEntries = try persistenceService.fetchFinancialEntries()
            exportData.financialEntries = allFinancialEntries.filter { entry in
                dateRange.contains(entry.date)
            }
        } catch {
            print("Error fetching financial entries: \(error)")
        }
        
        // Gather emotional entries
        do {
            let allEmotionalEntries = try persistenceService.fetchEmotionalEntries()
            exportData.emotionalEntries = allEmotionalEntries.filter { entry in
                dateRange.contains(entry.date)
            }
        } catch {
            print("Error fetching emotional entries: \(error)")
        }
        
        // Gather diary entries
        do {
            let allDiaryEntries = try persistenceService.fetchDiaryEntries()
            exportData.diaryEntries = allDiaryEntries.filter { entry in
                dateRange.contains(entry.date)
            }
        } catch {
            print("Error fetching diary entries: \(error)")
        }
        
        // Gather emergency contacts
        do {
            let emergencyContacts = try persistenceService.fetch(EmergencyContact.self)
            exportData.emergencyContacts = emergencyContacts
        } catch {
            print("Error fetching emergency contacts: \(error)")
        }
        
        return exportData
    }
    
    // MARK: - PDF Generation
    private func generatePDF(from data: ExportData, dateRange: DateInterval) async throws -> PDFDocument {
        let pdfDocument = PDFDocument()
        
        // Title page
        let titlePage = createTitlePage(dateRange: dateRange)
        pdfDocument.insert(titlePage, at: 0)
        
        // Visits page
        if !data.visits.isEmpty {
            let visitsPage = createVisitsPage(visits: data.visits)
            pdfDocument.insert(visitsPage, at: pdfDocument.pageCount)
        }
        
        // Financial page
        if !data.financialEntries.isEmpty {
            let financialPage = createFinancialPage(entries: data.financialEntries)
            pdfDocument.insert(financialPage, at: pdfDocument.pageCount)
        }
        
        // Emotional page
        if !data.emotionalEntries.isEmpty {
            let emotionalPage = createEmotionalPage(entries: data.emotionalEntries)
            pdfDocument.insert(emotionalPage, at: pdfDocument.pageCount)
        }
        
        // Diary page
        if !data.diaryEntries.isEmpty {
            let diaryPage = createDiaryPage(entries: data.diaryEntries)
            pdfDocument.insert(diaryPage, at: pdfDocument.pageCount)
        }
        
        // Emergency contacts page
        if !data.emergencyContacts.isEmpty {
            let contactsPage = createEmergencyContactsPage(contacts: data.emergencyContacts)
            pdfDocument.insert(contactsPage, at: pdfDocument.pageCount)
        }
        
        return pdfDocument
    }
    
    private func createTitlePage(dateRange: DateInterval) -> PDFPage {
        _ = CGRect(x: 0, y: 0, width: 612, height: 792) // Letter size
        let page = PDFPage()
        
        // This is a simplified version - in a real implementation, you'd use Core Graphics
        // to draw the content on the PDF page
        
        return page
    }
    
    private func createVisitsPage(visits: [Any]) -> PDFPage {
        let page = PDFPage()
        // Implementation for visits page
        return page
    }
    
    private func createFinancialPage(entries: [Any]) -> PDFPage {
        let page = PDFPage()
        // Implementation for financial page
        return page
    }
    
    private func createEmotionalPage(entries: [Any]) -> PDFPage {
        let page = PDFPage()
        // Implementation for emotional page
        return page
    }
    
    private func createDiaryPage(entries: [Any]) -> PDFPage {
        let page = PDFPage()
        // Implementation for diary page
        return page
    }
    
    private func createEmergencyContactsPage(contacts: [Any]) -> PDFPage {
        let page = PDFPage()
        // Implementation for emergency contacts page
        return page
    }
    
    // MARK: - CSV Generation
    private func generateCSV(from data: ExportData) -> String {
        var csvContent = "Tipo,Fecha,Título,Descripción,Valor\n"
        
        // Simplified CSV generation - will be implemented later
        csvContent += "Datos,\(Date()),JustDad Export,Exportación de datos,0\n"
        
        return csvContent
    }
    
    // MARK: - File Saving
    private func savePDFToDocuments(_ pdfDocument: PDFDocument) throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "JustDad_Export_\(DateFormatter.fileNameFormatter.string(from: Date())).pdf"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        guard pdfDocument.write(to: fileURL) else {
            throw ExportError.fileWriteFailed
        }
        
        return fileURL
    }
    
    private func saveCSVToDocuments(_ csvContent: String, dateRange: DateInterval) throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "JustDad_Export_\(DateFormatter.fileNameFormatter.string(from: Date())).csv"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
    
    private func saveJSONToDocuments(_ jsonData: Data, dateRange: DateInterval) throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "JustDad_Export_\(DateFormatter.fileNameFormatter.string(from: Date())).json"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        try jsonData.write(to: fileURL)
        return fileURL
    }
    
    // MARK: - File Management
    func getExportHistory() -> [ExportFile] {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: [.creationDateKey], options: [])
            let exportFiles = files
                .filter { $0.pathExtension == "pdf" || $0.pathExtension == "csv" || $0.pathExtension == "json" }
                .compactMap { url -> ExportFile? in
                    let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
                    let creationDate = attributes?[.creationDate] as? Date ?? Date()
                    let fileSize = attributes?[.size] as? Int64 ?? 0
                    
                    return ExportFile(
                        url: url,
                        name: url.lastPathComponent,
                        size: fileSize,
                        creationDate: creationDate,
                        type: ExportFileType(rawValue: url.pathExtension) ?? .json
                    )
                }
                .sorted { $0.creationDate > $1.creationDate }
            
            return exportFiles
        } catch {
            return []
        }
    }
    
    func deleteExportFile(_ file: ExportFile) throws {
        try FileManager.default.removeItem(at: file.url)
    }
    
    func shareExportFile(_ file: ExportFile) -> [Any] {
        return [file.url]
    }
}

// MARK: - Supporting Types
enum ExportError: LocalizedError {
    case fileWriteFailed
    case dataGatheringFailed
    case pdfGenerationFailed
    
    var errorDescription: String? {
        switch self {
        case .fileWriteFailed:
            return "No se pudo escribir el archivo"
        case .dataGatheringFailed:
            return "No se pudo recopilar los datos"
        case .pdfGenerationFailed:
            return "No se pudo generar el PDF"
        }
    }
}

struct ExportFile: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let size: Int64
    let creationDate: Date
    let type: ExportFileType
    
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}

enum ExportFileType: String, CaseIterable {
    case pdf = "pdf"
    case csv = "csv"
    case json = "json"
    
    var displayName: String {
        switch self {
        case .pdf: return "PDF"
        case .csv: return "CSV"
        case .json: return "JSON"
        }
    }
    
    var utType: UTType {
        switch self {
        case .pdf: return .pdf
        case .csv: return .commaSeparatedText
        case .json: return .json
        }
    }
}

// MARK: - DateFormatter Extensions
extension DateFormatter {
    static let csvFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()
    
    static let fileNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter
    }()
}