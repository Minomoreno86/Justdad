//
//  ReceiptStorageService.swift
//  JustDad - Receipt Storage Service
//

import Foundation
import SwiftData
import Vision

#if os(iOS)
import UIKit
#endif

@MainActor
class ReceiptStorageService: ObservableObject {
    static let shared = ReceiptStorageService()
    
    @Published var isProcessing = false
    @Published var processingProgress: Double = 0.0
    
    private let persistenceService = PersistenceService.shared
    private let fileManager = FileManager.default
    
    private init() {
        createStorageDirectories()
    }
    
    private func createStorageDirectories() {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let receiptsPath = documentsPath.appendingPathComponent("Receipts")
        let thumbnailsPath = documentsPath.appendingPathComponent("Thumbnails")
        
        try? fileManager.createDirectory(at: receiptsPath, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: thumbnailsPath, withIntermediateDirectories: true)
    }
    
    func processReceipt(_ image: UIImage, for financialEntry: FinancialEntry) async throws -> ReceiptAttachment {
        isProcessing = true
        processingProgress = 0.0
        
        defer {
            isProcessing = false
            processingProgress = 0.0
        }
        
        let originalPath = try await saveReceiptImage(image)
        let thumbnailPath = try await generateThumbnail(from: image)
        let extractedData = try await extractReceiptData(from: image)
        
        let receiptAttachment = ReceiptAttachment(
            filePath: originalPath.path,
            thumbnailPath: thumbnailPath.path,
            pagesCount: 1,
            extractedAmount: extractedData.amount,
            extractedDate: extractedData.date,
            merchant: extractedData.merchant,
            currencyCode: extractedData.currencyCode,
            rawText: extractedData.rawText
        )
        
        receiptAttachment.financialEntry = financialEntry
        financialEntry.receipt = receiptAttachment
        
        try await persistenceService.save(receiptAttachment)
        try await persistenceService.save(financialEntry)
        
        return receiptAttachment
    }
    
    private func saveReceiptImage(_ image: UIImage) async throws -> URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let receiptsPath = documentsPath.appendingPathComponent("Receipts")
        
        let fileName = "receipt_\(UUID().uuidString).jpg"
        let fileURL = receiptsPath.appendingPathComponent(fileName)
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw ReceiptError.imageProcessingFailed
        }
        
        try imageData.write(to: fileURL)
        return fileURL
    }
    
    private func generateThumbnail(from image: UIImage) async throws -> URL {
        let thumbnailSize = CGSize(width: 200, height: 200)
        let thumbnail = image.resized(to: thumbnailSize)
        
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let thumbnailsPath = documentsPath.appendingPathComponent("Thumbnails")
        
        let fileName = "thumb_\(UUID().uuidString).jpg"
        let fileURL = thumbnailsPath.appendingPathComponent(fileName)
        
        guard let thumbnailData = thumbnail.jpegData(compressionQuality: 0.7) else {
            throw ReceiptError.thumbnailGenerationFailed
        }
        
        try thumbnailData.write(to: fileURL)
        return fileURL
    }
    
    private func extractReceiptData(from image: UIImage) async throws -> ExtractedReceiptData {
        guard let cgImage = image.cgImage else {
            throw ReceiptError.imageProcessingFailed
        }
        
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        var extractedText = ""
        var extractedAmount: Decimal?
        var extractedDate: Date?
        var extractedMerchant: String?
        var currencyCode: String?
        
        do {
            try handler.perform([request])
            
            if let observations = request.results {
                for observation in observations {
                    let text = observation.topCandidates(1).first?.string ?? ""
                    extractedText += text + "\n"
                    
                    if let amount = extractAmount(from: text) {
                        extractedAmount = amount
                    }
                    
                    if let date = extractDate(from: text) {
                        extractedDate = date
                    }
                    
                    if let merchant = extractMerchant(from: text) {
                        extractedMerchant = merchant
                    }
                }
            }
        } catch {
            print("Text extraction error: \(error)")
        }
        
        return ExtractedReceiptData(
            rawText: extractedText,
            amount: extractedAmount,
            date: extractedDate,
            merchant: extractedMerchant,
            currencyCode: currencyCode
        )
    }
    
    private func extractAmount(from text: String) -> Decimal? {
        let patterns = [
            "\\$?([0-9,]+\\.[0-9]{2})",
            "([0-9,]+\\.[0-9]{2})",
            "\\$([0-9,]+)",
            "([0-9,]+)"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
               let range = Range(match.range(at: 1), in: text) {
                let amountString = String(text[range]).replacingOccurrences(of: ",", with: "")
                if let amount = Decimal(string: amountString) {
                    return amount
                }
            }
        }
        return nil
    }
    
    private func extractDate(from text: String) -> Date? {
        let formatters = [
            "MM/dd/yyyy",
            "dd/MM/yyyy",
            "yyyy-MM-dd",
            "MMM dd, yyyy",
            "dd MMM yyyy"
        ]
        
        for format in formatters {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            
            if let date = formatter.date(from: text) {
                return date
            }
        }
        return nil
    }
    
    private func extractMerchant(from text: String) -> String? {
        let lines = text.components(separatedBy: .newlines)
        return lines.first { line in
            line.count > 3 && line.count < 50 && !line.contains("$") && !line.contains("Total")
        }
    }
    
    func getReceipts(for financialEntry: FinancialEntry) -> [ReceiptAttachment] {
        do {
            let receipts = try persistenceService.fetch(ReceiptAttachment.self)
            return receipts.filter { $0.financialEntry?.id == financialEntry.id }
        } catch {
            print("Error fetching receipts: \(error)")
            return []
        }
    }
    
    func deleteReceipt(_ receipt: ReceiptAttachment) async throws {
        try? fileManager.removeItem(atPath: receipt.filePath)
        if let thumbnailPath = receipt.thumbnailPath {
            try? fileManager.removeItem(atPath: thumbnailPath)
        }
        
        try await persistenceService.delete(receipt)
    }
    
    func getReceiptImage(for receipt: ReceiptAttachment) -> UIImage? {
        let fileURL = URL(fileURLWithPath: receipt.filePath)
        
        guard fileManager.fileExists(atPath: receipt.filePath) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data)
        } catch {
            print("Error loading receipt image: \(error)")
            return nil
        }
    }
    
    func getReceiptThumbnail(for receipt: ReceiptAttachment) -> UIImage? {
        guard let thumbnailPath = receipt.thumbnailPath else { return nil }
        
        let fileURL = URL(fileURLWithPath: thumbnailPath)
        
        guard fileManager.fileExists(atPath: thumbnailPath) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data)
        } catch {
            print("Error loading receipt thumbnail: \(error)")
            return nil
        }
    }
}

struct ExtractedReceiptData {
    let rawText: String
    let amount: Decimal?
    let date: Date?
    let merchant: String?
    let currencyCode: String?
}

enum ReceiptError: LocalizedError {
    case imageProcessingFailed
    case thumbnailGenerationFailed
    case encryptionFailed
    case fileNotFound
    case invalidImageFormat
    
    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "No se pudo procesar la imagen del recibo"
        case .thumbnailGenerationFailed:
            return "No se pudo generar la miniatura"
        case .encryptionFailed:
            return "No se pudo cifrar el archivo"
        case .fileNotFound:
            return "Archivo no encontrado"
        case .invalidImageFormat:
            return "Formato de imagen no válido"
        }
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}