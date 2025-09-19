//
//  ReceiptStorageService.swift
//  JustDad - Receipt file storage and thumbnails
//

import Foundation
#if os(iOS)
import UIKit
#endif

@MainActor
final class ReceiptStorageService {
    static let shared = ReceiptStorageService()
    private init() {}
    
    // Directory for receipts
    private var receiptsDirectoryURL: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("Receipts", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    
    // Save UIImage as JPEG and return file path
    #if os(iOS)
    func save(image: UIImage, filename: String? = nil, compression: CGFloat = 0.8) throws -> (filePath: String, thumbnailPath: String) {
        let id = filename ?? UUID().uuidString
        let fileURL = receiptsDirectoryURL.appendingPathComponent("\(id).jpg")
        let thumbURL = receiptsDirectoryURL.appendingPathComponent("\(id)_thumb.jpg")
        
        guard let data = image.jpegData(compressionQuality: compression) else {
            throw NSError(domain: "ReceiptStorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No se pudo convertir la imagen a JPEG"])
        }
        try data.write(to: fileURL, options: .atomic)
        
        // Generate thumbnail
        let thumbnail = generateThumbnail(from: image, maxDimension: 300)
        guard let thumbData = thumbnail.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "ReceiptStorageService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No se pudo generar la miniatura"])
        }
        try thumbData.write(to: thumbURL, options: .atomic)
        
        return (fileURL.path, thumbURL.path)
    }
    #endif
    
    func delete(at path: String) {
        try? FileManager.default.removeItem(atPath: path)
    }
    
    // MARK: - Helpers
    #if os(iOS)
    private func generateThumbnail(from image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let scale = min(maxDimension / max(size.width, size.height), 1)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    #endif
}


