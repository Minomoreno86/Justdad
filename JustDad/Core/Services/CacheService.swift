//
//  CacheService.swift
//  JustDad - Intelligent Cache Service
//
//  Professional caching with automatic cleanup and optimization
//

import Foundation
import SwiftData
import Combine

@MainActor
class CacheService: ObservableObject {
    static let shared = CacheService()
    
    @Published var cacheSize: Int64 = 0
    @Published var cacheHitRate: Double = 0.0
    @Published var isCleaning = false
    
    private let persistenceService = PersistenceService.shared
    private let fileManager = FileManager.default
    private var cache = [String: CacheItem]()
    private var accessCounts = [String: Int]()
    private var lastAccessTimes = [String: Date]()
    
    private let maxCacheSize: Int64 = 100 * 1024 * 1024 // 100MB
    private let maxCacheAge: TimeInterval = 7 * 24 * 3600 // 7 days
    private let cleanupInterval: TimeInterval = 24 * 3600 // 24 hours
    
    private init() {
        setupCleanupTimer()
        loadCacheMetadata()
    }
    
    // MARK: - Cache Operations
    func get<T: Codable>(_ key: String, type: T.Type) -> T? {
        guard let item = cache[key] else {
            return nil
        }
        
        // Check if item is expired
        if Date().timeIntervalSince(item.createdAt) > maxCacheAge {
            remove(key)
            return nil
        }
        
        // Update access tracking
        accessCounts[key, default: 0] += 1
        lastAccessTimes[key] = Date()
        
        // Update hit rate
        updateHitRate()
        
        return item.data as? T
    }
    
    func set<T: Codable>(_ key: String, value: T, expiration: TimeInterval? = nil) {
        let item = CacheItem(
            key: key,
            data: value,
            createdAt: Date(),
            expiration: expiration ?? maxCacheAge
        )
        
        cache[key] = item
        accessCounts[key] = 1
        lastAccessTimes[key] = Date()
        
        // Check if we need to clean up
        if cacheSize > maxCacheSize {
            Task {
                await performCleanup()
            }
        }
    }
    
    func remove(_ key: String) {
        cache.removeValue(forKey: key)
        accessCounts.removeValue(forKey: key)
        lastAccessTimes.removeValue(forKey: key)
    }
    
    func clear() {
        cache.removeAll()
        accessCounts.removeAll()
        lastAccessTimes.removeAll()
        cacheSize = 0
    }
    
    // MARK: - Cache Management
    private func setupCleanupTimer() {
        Timer.scheduledTimer(withTimeInterval: cleanupInterval, repeats: true) { [weak self] _ in
            Task {
                await self?.performCleanup()
            }
        }
    }
    
    private func performCleanup() async {
        guard !isCleaning else { return }
        
        isCleaning = true
        
        // Remove expired items
        let now = Date()
        let expiredKeys = cache.compactMap { (key, item) -> String? in
            if now.timeIntervalSince(item.createdAt) > item.expiration {
                return key
            }
            return nil
        }
        
        for key in expiredKeys {
            remove(key)
        }
        
        // Remove least recently used items if still over limit
        if cacheSize > maxCacheSize {
            let sortedKeys = lastAccessTimes.sorted { $0.value < $1.value }
            let keysToRemove = Array(sortedKeys.prefix(10))
            
            for (key, _) in keysToRemove {
                remove(key)
            }
        }
        
        // Clean up old files
        await cleanupOldFiles()
        
        isCleaning = false
    }
    
    private func cleanupOldFiles() async {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let cachePath = documentsPath.appendingPathComponent("Cache")
        
        do {
            let files = try fileManager.contentsOfDirectory(at: cachePath, includingPropertiesForKeys: [.creationDateKey])
            
            for file in files {
                let attributes = try file.resourceValues(forKeys: [.creationDateKey])
                if let creationDate = attributes.creationDate,
                   Date().timeIntervalSince(creationDate) > maxCacheAge {
                    try fileManager.removeItem(at: file)
                }
            }
        } catch {
            print("Error cleaning up old files: \(error)")
        }
    }
    
    // MARK: - Cache Statistics
    private func updateHitRate() {
        let totalAccesses = accessCounts.values.reduce(0, +)
        let hits = cache.count
        cacheHitRate = totalAccesses > 0 ? Double(hits) / Double(totalAccesses) : 0.0
    }
    
    private func loadCacheMetadata() {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let metadataPath = documentsPath.appendingPathComponent("cache_metadata.json")
        
        do {
            let data = try Data(contentsOf: metadataPath)
            let metadata = try JSONDecoder().decode(CacheMetadata.self, from: data)
            
            cacheSize = metadata.cacheSize
            cacheHitRate = metadata.hitRate
        } catch {
            print("Error loading cache metadata: \(error)")
        }
    }
    
    private func saveCacheMetadata() {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let metadataPath = documentsPath.appendingPathComponent("cache_metadata.json")
        
        let metadata = CacheMetadata(
            cacheSize: cacheSize,
            hitRate: cacheHitRate,
            lastUpdated: Date()
        )
        
        do {
            let data = try JSONEncoder().encode(metadata)
            try data.write(to: metadataPath)
        } catch {
            print("Error saving cache metadata: \(error)")
        }
    }
    
    // MARK: - Cache Statistics
    func getCacheStatistics() -> CacheStatistics {
        return CacheStatistics(
            size: cacheSize,
            hitRate: cacheHitRate,
            itemCount: cache.count,
            isCleaning: isCleaning
        )
    }
    
    // MARK: - Memory Management
    func optimizeMemory() {
        // Remove items that haven't been accessed recently
        let cutoffDate = Date().addingTimeInterval(-maxCacheAge)
        let oldKeys = lastAccessTimes.compactMap { (key, date) -> String? in
            date < cutoffDate ? key : nil
        }
        
        for key in oldKeys {
            remove(key)
        }
    }
}

// MARK: - Supporting Types
struct CacheItem {
    let key: String
    let data: Any
    let createdAt: Date
    let expiration: TimeInterval
}

struct CacheMetadata: Codable {
    let cacheSize: Int64
    let hitRate: Double
    let lastUpdated: Date
}

struct CacheStatistics {
    let size: Int64
    let hitRate: Double
    let itemCount: Int
    let isCleaning: Bool
}
