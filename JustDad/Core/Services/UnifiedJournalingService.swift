//
//  UnifiedJournalingService.swift
//  JustDad - Unified Journaling Service
//
//  Combines intelligent and traditional journaling with SwiftData persistence
//

import Foundation
import SwiftData
import SwiftUI
import AVFoundation

@MainActor
public class UnifiedJournalingService: ObservableObject {
    public static let shared = UnifiedJournalingService()
    
    // MARK: - Published Properties
    @Published public var entries: [UnifiedJournalEntry] = []
    @Published public var isRecording = false
    @Published public var recordingDuration: TimeInterval = 0
    @Published public var isPlaying = false
    @Published public var currentPlayingEntry: UnifiedJournalEntry?
    @Published public var statistics: JournalStatistics?
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    
    // MARK: - Private Properties
    private let dataManager = JournalDataManager.shared
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingURL: URL?
    
    // MARK: - Initialization
        public init() {
        setupAudioSession()
        loadEntries()
        loadStatistics()
        
        // Perform migration if needed
        dataManager.migrateFromUserDefaults()
    }
    
    // MARK: - Audio Setup
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("❌ UnifiedJournalingService: Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - Data Loading
    public func loadEntries() {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            Task { @MainActor in
                let fetchedEntries = self.dataManager.fetchEntries()
                self.entries = fetchedEntries
                self.isLoading = false
                print("✅ UnifiedJournalingService: Loaded \(fetchedEntries.count) entries")
            }
        }
    }
    
    public func loadStatistics() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            Task { @MainActor in
                let stats = self.dataManager.getStatistics()
                self.statistics = stats
            }
        }
    }
    
    // MARK: - Entry Management
    public func addEntry(_ entry: UnifiedJournalEntry) {
        guard let context = dataManager.context else {
            errorMessage = "No data context available"
            return
        }
        
        context.insert(entry)
        dataManager.save()
        
        entries.insert(entry, at: 0) // Insert at beginning for newest first
        loadStatistics() // Refresh statistics
        
        print("✅ UnifiedJournalingService: Added new entry")
    }
    
    public func updateEntry(_ entry: UnifiedJournalEntry) {
        dataManager.save()
        
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
        }
        
        loadStatistics()
        print("✅ UnifiedJournalingService: Updated entry")
    }
    
    public func deleteEntry(_ entry: UnifiedJournalEntry) {
        dataManager.deleteEntry(entry)
        
        entries.removeAll { $0.id == entry.id }
        loadStatistics()
        
        print("✅ UnifiedJournalingService: Deleted entry")
    }
    
    // MARK: - Intelligent Journaling
    public func createIntelligentEntry(
        emotion: EmotionalState,
        prompt: JournalPrompt,
        content: String,
        tags: [String] = [],
        audioURL: URL? = nil
    ) -> UnifiedJournalEntry {
        let entry = UnifiedJournalEntry(
            emotion: emotion,
            prompt: prompt,
            content: content,
            audioURL: audioURL,
            tags: tags,
            isEncrypted: false
        )
        
        addEntry(entry)
        return entry
    }
    
    public func getPrompt(for emotion: EmotionalState, context: JournalContext? = nil) -> JournalPrompt {
        // This will be enhanced with AI-generated prompts in the future
        return getBasePrompt(for: emotion)
    }
    
    private func getBasePrompt(for emotion: EmotionalState) -> JournalPrompt {
        let prompts = getBasePrompts(for: emotion)
        return prompts.randomElement() ?? JournalPrompt(
            text: "¿Cómo te sientes en este momento?",
            category: .selfAwareness,
            estimatedTime: "5 min"
        )
    }
    
    private func getBasePrompts(for emotion: EmotionalState) -> [JournalPrompt] {
        switch emotion {
        case .verySad:
            return [
                JournalPrompt(
                    text: "¿Qué está causando esta tristeza profunda? ¿Hay algo específico que puedas identificar?",
                    category: .selfAwareness,
                    estimatedTime: "7 min"
                ),
                JournalPrompt(
                    text: "¿Qué te ha dado fuerza en momentos difíciles anteriores?",
                    category: .growth,
                    estimatedTime: "6 min"
                )
            ]
        case .sad:
            return [
                JournalPrompt(
                    text: "Describe tres cosas por las que estés agradecido, aunque sea difícil encontrarlas ahora.",
                    category: .gratitude,
                    estimatedTime: "5 min"
                ),
                JournalPrompt(
                    text: "¿Qué necesitas en este momento para sentirte mejor?",
                    category: .selfCare,
                    estimatedTime: "4 min"
                )
            ]
        case .neutral:
            return [
                JournalPrompt(
                    text: "¿Qué pequeños momentos de hoy te trajeron paz o satisfacción?",
                    category: .selfAwareness,
                    estimatedTime: "5 min"
                ),
                JournalPrompt(
                    text: "¿Cómo te sientes respecto a tu rol como padre hoy?",
                    category: .parenting,
                    estimatedTime: "6 min"
                )
            ]
        case .happy:
            return [
                JournalPrompt(
                    text: "¿Qué logros, por pequeños que sean, has alcanzado hoy?",
                    category: .celebration,
                    estimatedTime: "5 min"
                ),
                JournalPrompt(
                    text: "¿Cómo puedes mantener esta energía positiva?",
                    category: .growth,
                    estimatedTime: "4 min"
                )
            ]
        case .veryHappy:
            return [
                JournalPrompt(
                    text: "¿Qué momentos especiales con tus hijos quieres recordar para siempre?",
                    category: .celebration,
                    estimatedTime: "6 min"
                ),
                JournalPrompt(
                    text: "¿Cómo puedes compartir esta felicidad con otros?",
                    category: .connection,
                    estimatedTime: "5 min"
                )
            ]
        }
    }
    
    // MARK: - Traditional Journaling
    public func createTraditionalEntry(
        title: String?,
        content: String,
        mood: String,
        tags: [String] = [],
        audioURL: URL? = nil,
        photoURLs: [URL] = []
    ) -> UnifiedJournalEntry {
        let entry = UnifiedJournalEntry(
            title: title,
            content: content,
            mood: mood,
            audioURL: audioURL,
            photoURLs: photoURLs,
            tags: tags,
            isEncrypted: false
        )
        
        addEntry(entry)
        return entry
    }
    
    // MARK: - Audio Recording
    public func startRecording() {
        guard !isRecording else { return }
        
        // Request microphone permission
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.beginRecording()
                } else {
                    self?.errorMessage = "Microphone permission denied"
                }
            }
        }
    }
    
    private func beginRecording() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("recording_\(UUID().uuidString).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            // audioRecorder?.delegate = self // TODO: Implement delegate after SwiftData integration
            audioRecorder?.record()
            
            recordingURL = audioFilename
            isRecording = true
            
            print("✅ UnifiedJournalingService: Started recording")
        } catch {
            print("❌ UnifiedJournalingService: Failed to start recording: \(error)")
            errorMessage = "Failed to start recording"
        }
    }
    
    public func stopRecording() -> URL? {
        guard isRecording else { return nil }
        
        audioRecorder?.stop()
        isRecording = false
        
        let url = recordingURL
        recordingURL = nil
        
        print("✅ UnifiedJournalingService: Stopped recording")
        return url
    }
    
    // MARK: - Audio Playback
    public func playAudio(for entry: UnifiedJournalEntry) {
        guard let audioURL = entry.audioURL else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            // audioPlayer?.delegate = self // TODO: Implement delegate after SwiftData integration
            audioPlayer?.play()
            
            currentPlayingEntry = entry
            isPlaying = true
            
            print("✅ UnifiedJournalingService: Started playing audio")
        } catch {
            print("❌ UnifiedJournalingService: Failed to play audio: \(error)")
            errorMessage = "Failed to play audio"
        }
    }
    
    public func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentPlayingEntry = nil
        isPlaying = false
        
        print("✅ UnifiedJournalingService: Stopped audio")
    }
    
    // MARK: - Search and Filtering
    public func searchEntries(query: String) -> [UnifiedJournalEntry] {
        return entries.filter { entry in
            entry.content.localizedCaseInsensitiveContains(query) ||
            entry.title?.localizedCaseInsensitiveContains(query) == true ||
            entry.tags.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    
    public func filterEntries(by emotion: EmotionalState) -> [UnifiedJournalEntry] {
        return entries.filter { entry in
            switch entry.type {
            case .intelligent(let entryEmotion, _):
                return entryEmotion == emotion
            case .traditional(_):
                return false
            }
        }
    }
    
    public func filterEntries(in dateRange: ClosedRange<Date>) -> [UnifiedJournalEntry] {
        return entries.filter { entry in
            dateRange.contains(entry.date)
        }
    }
    
    public func filterEntries(with tags: [String]) -> [UnifiedJournalEntry] {
        return entries.filter { entry in
            tags.allSatisfy { tag in
                entry.tags.contains(tag)
            }
        }
    }
    
    // MARK: - Prompt Generation
    public func generatePrompt(for emotion: EmotionalState) -> JournalPrompt {
        let prompts: [JournalPrompt]
        switch emotion {
        case .verySad:
            prompts = [
                JournalPrompt(
                    text: "¿Qué está causando esta tristeza profunda? ¿Hay algo específico que puedas identificar?",
                    category: .selfAwareness,
                    estimatedTime: "7 min"
                ),
                JournalPrompt(
                    text: "¿Qué te ha dado fuerza en momentos difíciles anteriores?",
                    category: .growth,
                    estimatedTime: "6 min"
                )
            ]
        case .sad:
            prompts = [
                JournalPrompt(
                    text: "Describe tres cosas por las que estés agradecido, aunque sea difícil encontrarlas ahora.",
                    category: .gratitude,
                    estimatedTime: "5 min"
                ),
                JournalPrompt(
                    text: "¿Qué pequeña acción puedes tomar hoy para mejorar tu estado de ánimo?",
                    category: .selfCare,
                    estimatedTime: "4 min"
                )
            ]
        case .neutral:
            prompts = [
                JournalPrompt(
                    text: "¿Qué pequeños momentos de hoy te trajeron paz o satisfacción?",
                    category: .selfAwareness,
                    estimatedTime: "5 min"
                ),
                JournalPrompt(
                    text: "¿Cómo te sientes respecto a tu rol como padre hoy?",
                    category: .parenting,
                    estimatedTime: "6 min"
                )
            ]
        case .happy:
            prompts = [
                JournalPrompt(
                    text: "¿Qué te hizo sonreír hoy? Describe el momento en detalle.",
                    category: .gratitude,
                    estimatedTime: "5 min"
                ),
                JournalPrompt(
                    text: "¿Cómo puedes compartir esta felicidad con tus hijos o seres queridos?",
                    category: .connection,
                    estimatedTime: "6 min"
                )
            ]
        case .veryHappy:
            prompts = [
                JournalPrompt(
                    text: "¿Qué logro o experiencia te hace sentir más orgulloso hoy?",
                    category: .celebration,
                    estimatedTime: "7 min"
                ),
                JournalPrompt(
                    text: "¿Cómo puedes mantener esta energía positiva en los próximos días?",
                    category: .planning,
                    estimatedTime: "6 min"
                )
            ]
        }
        return prompts.randomElement() ?? JournalPrompt(text: "Escribe sobre tu día.", category: .reflection, estimatedTime: "5 min")
    }
    
    // MARK: - Export
    public func exportEntries() -> Data? {
        let exportData = entries.map { entry in
            [
                "id": entry.id.uuidString,
                "date": ISO8601DateFormatter().string(from: entry.date),
                "type": entry.type.displayName,
                "title": entry.title ?? "",
                "content": entry.content,
                "tags": entry.tags.joined(separator: ", "),
                "audioAvailable": entry.audioURL != nil,
                "photosCount": entry.photoURLs.count
            ]
        }
        
        do {
            return try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
        } catch {
            print("❌ UnifiedJournalingService: Failed to export entries: \(error)")
            errorMessage = "Failed to export entries"
            return nil
        }
    }
}

// MARK: - Audio Delegates (Simplified for now)
// TODO: Implement proper audio delegates after SwiftData integration is complete
