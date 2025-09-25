import Foundation
import SwiftData
#if os(iOS)
import UIKit
#endif

@MainActor
class ReceiptProcessingService: ObservableObject {
    static let shared = ReceiptProcessingService()
    
    private let persistenceService = PersistenceService.shared
    private let receiptStorageService = ReceiptStorageService.shared
    
    private init() {}
    
    // MARK: - Process Receipt
    
    func processReceipt(_ receiptData: ReceiptData) async throws -> FinancialEntry {
        // Crear el gasto en la categoría "Extras" (other)
        let financialEntry = FinancialEntry(
            title: receiptData.extractedMerchant ?? "Gasto escaneado",
            amount: receiptData.extractedAmount ?? 0,
            category: .other,
            expenseType: .variable,
            date: receiptData.extractedDate ?? Date(),
            notes: "Factura escaneada automáticamente"
        )
        
        // Guardar la imagen del recibo si existe
        #if os(iOS)
        if let image = receiptData.originalImage {
            do {
                let receiptAttachment = try await receiptStorageService.processReceipt(image, for: financialEntry)
                print("✅ Receipt processed successfully")
            } catch {
                print("Error processing receipt: \(error)")
                // Continuar sin el attachment si hay error
            }
        }
        #endif
        
        // Guardar el gasto en SwiftData
        try await persistenceService.saveFinancialEntry(financialEntry)
        
        return financialEntry
    }
    
    // MARK: - Get Receipt Image
    
    #if os(iOS)
    func getReceiptImage(for financialEntry: FinancialEntry) -> UIImage? {
        guard let attachment = financialEntry.receipt else { return nil }
        return UIImage(contentsOfFile: attachment.filePath)
    }
    
    func getReceiptThumbnail(for financialEntry: FinancialEntry) -> UIImage? {
        guard let attachment = financialEntry.receipt,
              let thumbnailPath = attachment.thumbnailPath else { return nil }
        return UIImage(contentsOfFile: thumbnailPath)
    }
    #endif
    
    // MARK: - Delete Receipt
    
    func deleteReceipt(for financialEntry: FinancialEntry) async {
        guard let attachment = financialEntry.receipt else { return }
        
        do {
            try await receiptStorageService.deleteReceipt(attachment)
            print("✅ Receipt deleted successfully")
        } catch {
            print("Error deleting receipt: \(error)")
        }
    }
    
    // MARK: - Get Receipts Count
    
    func getReceiptsCount() -> Int {
        do {
            let context = persistenceService.modelContext
            let descriptor = FetchDescriptor<FinancialEntry>(
                predicate: #Predicate { $0.receipt != nil }
            )
            return try context.fetch(descriptor).count
        } catch {
            print("Error fetching receipts count: \(error)")
            return 0
        }
    }
    
    // MARK: - Get Recent Receipts
    
    func getRecentReceipts(limit: Int = 10) -> [FinancialEntry] {
        do {
            let context = persistenceService.modelContext
            var descriptor = FetchDescriptor<FinancialEntry>(
                predicate: #Predicate { $0.receipt != nil },
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            descriptor.fetchLimit = limit
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching recent receipts: \(error)")
            return []
        }
    }
}

// MARK: - Receipt Storage Error
enum ReceiptStorageError: Error, LocalizedError {
    case directoryNotFound
    case imageConversionFailed
    case fileWriteFailed
    case fileReadFailed
    case fileDeleteFailed
    
    var errorDescription: String? {
        switch self {
        case .directoryNotFound:
            return "No se pudo encontrar el directorio de almacenamiento"
        case .imageConversionFailed:
            return "No se pudo convertir la imagen"
        case .fileWriteFailed:
            return "No se pudo escribir el archivo"
        case .fileReadFailed:
            return "No se pudo leer el archivo"
        case .fileDeleteFailed:
            return "No se pudo eliminar el archivo"
        }
    }
}
