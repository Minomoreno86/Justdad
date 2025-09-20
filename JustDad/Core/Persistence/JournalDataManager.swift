//
//  JournalDataManager.swift
//  JustDad - SwiftData Persistence Manager
//
//  Manages SwiftData persistence for unified journaling system
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
public class JournalDataManager: ObservableObject {
    public static let shared = JournalDataManager()
    
    private var modelContainer: ModelContainer?
    
    private init() {
        setupModelContainer()
    }
    
    // MARK: - Model Container Setup
    private func setupModelContainer() {
        do {
            let schema = Schema([
                UnifiedJournalEntry.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            print("✅ JournalDataManager: SwiftData container initialized successfully")
        } catch {
            print("❌ JournalDataManager: Failed to initialize SwiftData container: \(error)")
            // Fallback to in-memory storage for development
            setupFallbackContainer()
        }
    }
    
    private func setupFallbackContainer() {
        do {
            let schema = Schema([
                UnifiedJournalEntry.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )
            
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            print("⚠️ JournalDataManager: Using fallback in-memory container")
        } catch {
            print("❌ JournalDataManager: Failed to setup fallback container: \(error)")
        }
    }
    
    // MARK: - Public Interface
    public var container: ModelContainer? {
        return modelContainer
    }
    
    public var context: ModelContext? {
        return modelContainer?.mainContext
    }
    
    // MARK: - Data Operations
    public func save() {
        guard let context = context else {
            print("❌ JournalDataManager: No context available for save")
            return
        }
        
        do {
            try context.save()
            print("✅ JournalDataManager: Data saved successfully")
        } catch {
            print("❌ JournalDataManager: Failed to save data: \(error)")
        }
    }
    
    public func fetchEntries() -> [UnifiedJournalEntry] {
        guard let context = context else {
            print("❌ JournalDataManager: No context available for fetch")
            return []
        }
        
        do {
            let descriptor = FetchDescriptor<UnifiedJournalEntry>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            let entries = try context.fetch(descriptor)
            print("✅ JournalDataManager: Fetched \(entries.count) entries")
            return entries
        } catch {
            print("❌ JournalDataManager: Failed to fetch entries: \(error)")
            return []
        }
    }
    
    public func fetchEntries(by emotion: EmotionalState) -> [UnifiedJournalEntry] {
        guard let context = context else { return [] }
        
        do {
            // Fetch all entries and filter manually since SwiftData predicates don't support switch statements
            let descriptor = FetchDescriptor<UnifiedJournalEntry>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            let allEntries = try context.fetch(descriptor)
            
            return allEntries.filter { entry in
                switch entry.type {
                case .intelligent(let entryEmotion, _):
                    return entryEmotion == emotion
                case .traditional(_):
                    return false
                }
            }
        } catch {
            print("❌ JournalDataManager: Failed to fetch entries by emotion: \(error)")
            return []
        }
    }
    
    public func fetchEntries(in dateRange: ClosedRange<Date>) -> [UnifiedJournalEntry] {
        guard let context = context else { return [] }
        
        do {
            let descriptor = FetchDescriptor<UnifiedJournalEntry>(
                predicate: #Predicate { entry in
                    entry.date >= dateRange.lowerBound && entry.date <= dateRange.upperBound
                },
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            return try context.fetch(descriptor)
        } catch {
            print("❌ JournalDataManager: Failed to fetch entries in date range: \(error)")
            return []
        }
    }
    
    public func fetchEntries(with tags: [String]) -> [UnifiedJournalEntry] {
        guard let context = context else { return [] }
        
        do {
            let descriptor = FetchDescriptor<UnifiedJournalEntry>(
                predicate: #Predicate { entry in
                    tags.allSatisfy { tag in
                        entry.tags.contains(tag)
                    }
                },
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            return try context.fetch(descriptor)
        } catch {
            print("❌ JournalDataManager: Failed to fetch entries with tags: \(error)")
            return []
        }
    }
    
    public func deleteEntry(_ entry: UnifiedJournalEntry) {
        guard let context = context else { return }
        
        context.delete(entry)
        save()
        print("✅ JournalDataManager: Entry deleted successfully")
    }
    
    public func deleteAllEntries() {
        guard let context = context else { return }
        
        do {
            let descriptor = FetchDescriptor<UnifiedJournalEntry>()
            let allEntries = try context.fetch(descriptor)
            
            for entry in allEntries {
                context.delete(entry)
            }
            
            save()
            print("✅ JournalDataManager: All entries deleted successfully")
        } catch {
            print("❌ JournalDataManager: Failed to delete all entries: \(error)")
        }
    }
    
    // MARK: - Statistics
    public func getStatistics() -> JournalStatistics {
        let allEntries = fetchEntries()
        let now = Date()
        let calendar = Calendar.current
        
        // Calculate date ranges
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        let entriesThisWeek = allEntries.filter { $0.date >= startOfWeek }.count
        let entriesThisMonth = allEntries.filter { $0.date >= startOfMonth }.count
        
        // Calculate average words per entry
        let totalWords = allEntries.reduce(0) { total, entry in
            total + entry.content.components(separatedBy: .whitespaces).count
        }
        let averageWordsPerEntry = allEntries.isEmpty ? 0.0 : Double(totalWords) / Double(allEntries.count)
        
        // Get most used tags
        let allTags = allEntries.flatMap { $0.tags }
        let tagCounts = Dictionary(grouping: allTags, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        let mostUsedTags = Array(tagCounts.prefix(5)).map { $0.key }
        
        // Calculate emotion trends (for intelligent journaling entries)
        let intelligentEntries = allEntries.compactMap { entry -> (Date, EmotionalState)? in
            switch entry.type {
            case .intelligent(let emotion, _):
                return (entry.date, emotion)
            case .traditional(_):
                return nil
            }
        }
        
        let emotionTrends = Dictionary(grouping: intelligentEntries) { entry in
            calendar.startOfDay(for: entry.0)
        }.map { date, entries in
            let emotionCounts = Dictionary(grouping: entries) { $0.1 }
                .mapValues { $0.count }
            
            // Get the most common emotion for this day
            if let mostCommonEmotion = emotionCounts.max(by: { $0.value < $1.value })?.key {
                return EmotionTrend(date: date, emotion: mostCommonEmotion, count: mostCommonEmotion.rawValue)
            }
            return nil
        }.compactMap { $0 }
        
        // Calculate streaks
        let (longestStreak, currentStreak) = calculateStreaks(from: allEntries)
        
        return JournalStatistics(
            totalEntries: allEntries.count,
            entriesThisWeek: entriesThisWeek,
            entriesThisMonth: entriesThisMonth,
            averageWordsPerEntry: averageWordsPerEntry,
            mostUsedTags: mostUsedTags,
            emotionTrends: emotionTrends,
            longestStreak: longestStreak,
            currentStreak: currentStreak
        )
    }
    
    private func calculateStreaks(from entries: [UnifiedJournalEntry]) -> (Int, Int) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get unique dates with entries, sorted in descending order
        let entryDates = Set(entries.map { calendar.startOfDay(for: $0.date) })
            .sorted(by: >)
        
        guard !entryDates.isEmpty else { return (0, 0) }
        
        var longestStreak = 1
        var currentStreak = 0
        
        var currentStreakStart = today
        var tempStreak = 1
        
        for i in 0..<entryDates.count {
            let currentDate = entryDates[i]
            
            if i > 0 {
                let previousDate = entryDates[i - 1]
                let daysDifference = calendar.dateComponents([.day], from: currentDate, to: previousDate).day ?? 0
                
                if daysDifference == 1 {
                    tempStreak += 1
                } else {
                    longestStreak = max(longestStreak, tempStreak)
                    tempStreak = 1
                }
            }
            
            // Calculate current streak
            if currentDate == today || 
               (currentStreak > 0 && calendar.dateComponents([.day], from: currentDate, to: currentStreakStart).day == 1) {
                if currentStreak == 0 {
                    currentStreakStart = currentDate
                }
                currentStreak += 1
            } else if currentDate < today {
                break
            }
        }
        
        longestStreak = max(longestStreak, tempStreak)
        
        return (longestStreak, currentStreak)
    }
    
    // MARK: - Migration Helpers
    public func migrateFromUserDefaults() {
        print("🔄 JournalDataManager: Starting migration from UserDefaults...")
        
        // Check if migration is needed
        let migrationKey = "journal_migration_completed"
        if UserDefaults.standard.bool(forKey: migrationKey) {
            print("✅ JournalDataManager: Migration already completed")
            return
        }
        
        // Migrate intelligent journaling entries
        migrateIntelligentJournalingEntries()
        
        // Mark migration as completed
        UserDefaults.standard.set(true, forKey: migrationKey)
        print("✅ JournalDataManager: Migration completed successfully")
    }
    
    private func migrateIntelligentJournalingEntries() {
        guard let context = context else { return }
        
        // Get existing entries from UserDefaults
        let userDefaultsKey = "journal_entries"
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let entries = try? JSONDecoder().decode([JournalEntry].self, from: data) else {
            print("⚠️ JournalDataManager: No existing entries found in UserDefaults")
            return
        }
        
        print("🔄 JournalDataManager: Migrating \(entries.count) entries from UserDefaults...")
        
        for entry in entries {
            // Create new unified entry
            let unifiedEntry = UnifiedJournalEntry(
                emotion: entry.emotion,
                prompt: entry.prompt,
                content: entry.content,
                audioURL: entry.audioURL,
                tags: entry.tags,
                isEncrypted: false
            )
            
            // Set the original date if available
            unifiedEntry.date = entry.date ?? Date()
            
            context.insert(unifiedEntry)
        }
        
        save()
        print("✅ JournalDataManager: Migrated \(entries.count) entries successfully")
    }
}
