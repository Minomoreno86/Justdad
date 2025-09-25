//
//  IntelligentJournalingService.swift
//  JustDad - Smart Journaling System
//
//  Intelligent prompts and voice notes for emotional reflection
//

import Foundation
import SwiftUI
import AVFoundation
import SwiftData

// MARK: - Intelligent Journaling Service
public class IntelligentJournalingService: NSObject, ObservableObject, AVAudioPlayerDelegate {
    public static let shared = IntelligentJournalingService()
    
    @Published var journalEntries: [JournalEntry] = []
    @Published var emotionEntries: [EmotionEntry] = []
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var isPlaying = false
    @Published var currentPlayingEntry: JournalEntry?
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingTimer: Timer?
    private let persistenceService = PersistenceService.shared
    
    private override init() {
        super.init()
        loadJournalEntries()
        loadEmotionEntries()
    }
    
    // MARK: - Journal Entry Management
    public func addEntry(_ entry: JournalEntry) {
        journalEntries.append(entry)
        saveJournalEntries()
        print("✅ Journal entry saved: \(entry.prompt.text)")
        print("📊 Total entries: \(journalEntries.count)")
    }
    
    // MARK: - Persistence Methods (SwiftData)
    private func saveJournalEntries() {
        // Convert JournalEntry to DiaryEntry and save to SwiftData
        for journalEntry in journalEntries {
            let diaryEntry = DiaryEntry(
                content: journalEntry.content,
                title: journalEntry.prompt.text,
                mood: "😐", // Default emoji for now
                date: journalEntry.date
            )
            Task {
                do {
                    try await persistenceService.saveDiaryEntry(diaryEntry)
                } catch {
                    print("❌ Error saving journal entry: \(error)")
                }
            }
        }
    }
    
    private func saveEmotionEntries() {
        // Convert EmotionEntry to EmotionalEntry and save to SwiftData
        for emotionEntry in emotionEntries {
            let emotionalEntry = EmotionalEntry(
                mood: EmotionalEntry.MoodLevel(rawValue: emotionEntry.emotion.rawValue) ?? .neutral,
                note: emotionEntry.notes
            )
            Task {
                do {
                    try await persistenceService.saveEmotionalEntry(emotionalEntry)
                } catch {
                    print("❌ Error saving emotion entry: \(error)")
                }
            }
        }
    }
    
    // MARK: - Emotion Entry Management
    public func addEmotionEntry(_ emotion: EmotionalState, notes: String? = nil) {
        let newEntry = EmotionEntry(emotion: emotion, notes: notes)
        emotionEntries.insert(newEntry, at: 0) // Add to the beginning
        saveEmotionEntries()
        print("✅ Emotion entry saved: \(emotion.displayName)")
        print("📊 Total emotion entries: \(emotionEntries.count)")
    }
    
    public func updateEntry(_ entry: JournalEntry) {
        if let index = journalEntries.firstIndex(where: { $0.id == entry.id }) {
            journalEntries[index] = entry
            saveJournalEntries()
        }
    }
    
    public func deleteEntry(_ entry: JournalEntry) {
        journalEntries.removeAll { $0.id == entry.id }
        saveJournalEntries()
    }
    
    // MARK: - Intelligent Prompts
    public func getPrompt(for emotion: EmotionalState, context: JournalContext? = nil) -> JournalPrompt {
        let basePrompts = getBasePrompts(for: emotion)
        let contextualPrompts = getContextualPrompts(for: emotion, context: context)
        
        let allPrompts = basePrompts + contextualPrompts
        return allPrompts.randomElement() ?? basePrompts.first!
    }
    
    private func getBasePrompts(for emotion: EmotionalState) -> [JournalPrompt] {
        switch emotion {
        case .verySad:
            return [
                JournalPrompt(
                    text: "¿Qué necesitas escuchar hoy?",
                    category: .selfCompassion,
                    estimatedTime: "3-5 min"
                ),
                JournalPrompt(
                    text: "Escribe sobre una pequeña victoria que hayas tenido esta semana",
                    category: .gratitude,
                    estimatedTime: "2-3 min"
                ),
                JournalPrompt(
                    text: "¿Qué te está enseñando este momento difícil sobre ti mismo?",
                    category: .growth,
                    estimatedTime: "5-7 min"
                )
            ]
        case .sad:
            return [
                JournalPrompt(
                    text: "¿Qué está realmente molestándote en este momento?",
                    category: .reflection,
                    estimatedTime: "4-6 min"
                ),
                JournalPrompt(
                    text: "Escribe sobre algo por lo que estés agradecido, por pequeño que sea",
                    category: .gratitude,
                    estimatedTime: "2-4 min"
                ),
                JournalPrompt(
                    text: "¿Qué necesitas para sentirte mejor hoy?",
                    category: .selfCare,
                    estimatedTime: "3-5 min"
                )
            ]
        case .neutral:
            return [
                JournalPrompt(
                    text: "¿Qué quieres recordar de este momento?",
                    category: .reflection,
                    estimatedTime: "3-5 min"
                ),
                JournalPrompt(
                    text: "Escribe sobre una conversación reciente con tus hijos que te haya gustado",
                    category: .parenting,
                    estimatedTime: "4-6 min"
                ),
                JournalPrompt(
                    text: "¿Qué hábito te gustaría desarrollar esta semana?",
                    category: .growth,
                    estimatedTime: "3-5 min"
                )
            ]
        case .happy:
            return [
                JournalPrompt(
                    text: "¿Qué te hizo sentir así de bien hoy?",
                    category: .celebration,
                    estimatedTime: "3-5 min"
                ),
                JournalPrompt(
                    text: "Escribe sobre un momento especial que compartiste con tus hijos",
                    category: .parenting,
                    estimatedTime: "4-6 min"
                ),
                JournalPrompt(
                    text: "¿Cómo puedes recrear esta sensación en el futuro?",
                    category: .growth,
                    estimatedTime: "3-5 min"
                )
            ]
        case .veryHappy:
            return [
                JournalPrompt(
                    text: "¡Celebra este momento! ¿Qué quieres recordar para siempre?",
                    category: .celebration,
                    estimatedTime: "4-6 min"
                ),
                JournalPrompt(
                    text: "Escribe una carta de agradecimiento a ti mismo por llegar hasta aquí",
                    category: .selfCompassion,
                    estimatedTime: "5-7 min"
                ),
                JournalPrompt(
                    text: "¿Cómo puedes compartir esta alegría con otros?",
                    category: .connection,
                    estimatedTime: "3-5 min"
                )
            ]
        }
    }
    
    private func getContextualPrompts(for emotion: EmotionalState, context: JournalContext?) -> [JournalPrompt] {
        guard let context = context else { return [] }
        
        switch context {
        case .afterTest(let testType):
            return [
                JournalPrompt(
                    text: "¿Qué aprendiste sobre ti mismo en el test de \(testType)?",
                    category: .growth,
                    estimatedTime: "5-7 min"
                ),
                JournalPrompt(
                    text: "¿Cómo te sientes sobre los resultados y qué vas a hacer al respecto?",
                    category: .reflection,
                    estimatedTime: "4-6 min"
                )
            ]
        case .afterExercise(let exerciseType):
            return [
                JournalPrompt(
                    text: "¿Cómo te sentiste después de hacer \(exerciseType)?",
                    category: .reflection,
                    estimatedTime: "3-5 min"
                ),
                JournalPrompt(
                    text: "¿Notas alguna diferencia en tu estado de ánimo?",
                    category: .selfAwareness,
                    estimatedTime: "2-4 min"
                )
            ]
        case .endOfDay:
            return [
                JournalPrompt(
                    text: "¿Cuál fue el momento más significativo del día?",
                    category: .reflection,
                    estimatedTime: "4-6 min"
                ),
                JournalPrompt(
                    text: "¿Qué harías diferente mañana?",
                    category: .growth,
                    estimatedTime: "3-5 min"
                )
            ]
        case .weekendReflection:
            return [
                JournalPrompt(
                    text: "¿Cómo fue tu tiempo con tus hijos este fin de semana?",
                    category: .parenting,
                    estimatedTime: "5-7 min"
                ),
                JournalPrompt(
                    text: "¿Qué te gustaría planificar para la próxima semana?",
                    category: .planning,
                    estimatedTime: "4-6 min"
                )
            ]
        }
    }
    
    // MARK: - Voice Recording
    public func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        #if os(iOS)
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
        #else
        // On macOS, assume permission is granted for simulator
        completion(true)
        #endif
    }
    
    public func startRecording() {
        requestMicrophonePermission { [weak self] granted in
            guard let self = self else { return }
            
            if !granted {
                print("Microphone permission denied")
                return
            }
            
            do {
                #if os(iOS)
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(.playAndRecord, mode: .default)
                try audioSession.setActive(true)
                #endif
                
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let audioFilename = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
                
                print("🎤 Starting recording to: \(audioFilename.path)")
                print("📁 Documents directory: \(documentsPath.path)")
                
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
                
                self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                self.audioRecorder?.record()
                
                self.isRecording = true
                self.recordingDuration = 0
                
                self.recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    self.recordingDuration += 0.1
                }
                
            } catch {
                print("Error starting recording: \(error)")
            }
        }
    }
    
    public func stopRecording() -> URL? {
        audioRecorder?.stop()
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        let url = audioRecorder?.url
        print("🎤 Recording stopped. URL: \(url?.path ?? "nil")")
        
        if let url = url {
            let fileExists = FileManager.default.fileExists(atPath: url.path)
            print("📁 File exists: \(fileExists)")
            if fileExists {
                let fileSize = try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64
                print("📊 File size: \(fileSize ?? 0) bytes")
            }
        }
        
        audioRecorder = nil
        recordingDuration = 0
        
        return url
    }
    
    // MARK: - Data Persistence (SwiftData)
    public func loadJournalEntries() {
        Task { @MainActor in
            do {
                let diaryEntries = try persistenceService.fetchDiaryEntries()
                // Convert DiaryEntry to JournalEntry format
                journalEntries = diaryEntries.map { diaryEntry in
                    JournalEntry(
                        emotion: .neutral, // Convert from emoji to EmotionalState later
                        prompt: JournalPrompt(
                            text: diaryEntry.title ?? "Reflexión",
                            category: .reflection,
                            estimatedTime: "5 min"
                        ),
                        content: diaryEntry.content,
                        audioURL: nil,
                        tags: []
                    )
                }
                print("✅ Loaded \(journalEntries.count) journal entries from SwiftData")
            } catch {
                print("❌ Error loading journal entries: \(error)")
                journalEntries = []
            }
        }
    }
    
    public func loadEmotionEntries() {
        Task { @MainActor in
            do {
                let emotionalEntries = try persistenceService.fetchEmotionalEntries()
                // Convert EmotionalEntry to EmotionEntry format
                emotionEntries = emotionalEntries.map { emotionalEntry in
                    EmotionEntry(
                        emotion: EmotionalState(rawValue: emotionalEntry.mood.rawValue) ?? .neutral,
                        notes: emotionalEntry.note
                    )
                }
                print("✅ Loaded \(emotionEntries.count) emotion entries from SwiftData")
            } catch {
                print("❌ Error loading emotion entries: \(error)")
                emotionEntries = []
            }
        }
    }
    
    // MARK: - Audio Playback
    public func playAudio(for entry: JournalEntry) {
        guard let audioURL = entry.audioURL else {
            print("❌ No audio URL found for entry")
            return
        }
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            print("❌ Audio file does not exist at path: \(audioURL.path)")
            return
        }
        
        // Debug audio session before attempting to play
        debugAudioSession()
        
        do {
            // Stop any currently playing audio
            stopAudio()
            
            // Configure audio session for playback
            #if os(iOS)
            let audioSession = AVAudioSession.sharedInstance()
            
            // First deactivate the session
            try audioSession.setActive(false)
            
            // Then set the category
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth, .defaultToSpeaker])
            
            // Finally activate the session
            try audioSession.setActive(true)
            #endif
            
            // Create audio player
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.delegate = self
            
            // Check if the player is ready
            guard audioPlayer?.prepareToPlay() == true else {
                print("❌ Failed to prepare audio player")
                return
            }
            
            // Start playing
            guard audioPlayer?.play() == true else {
                print("❌ Failed to start audio playback")
                return
            }
            
            isPlaying = true
            currentPlayingEntry = entry
            
            print("🎵 Successfully playing audio for entry: \(entry.prompt.text)")
            print("📁 Audio file path: \(audioURL.path)")
            print("⏱️ Audio duration: \(audioPlayer?.duration ?? 0) seconds")
        } catch {
            print("❌ Error playing audio: \(error.localizedDescription)")
            print("❌ Error details: \(error)")
            print("❌ Error code: \((error as NSError).code)")
        }
    }
    
    public func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentPlayingEntry = nil
    }
    
    // MARK: - Audio Session Debug
    private func debugAudioSession() {
        #if os(iOS)
        let audioSession = AVAudioSession.sharedInstance()
        print("🔍 Audio Session Debug:")
        print("   Category: \(audioSession.category.rawValue)")
        print("   Mode: \(audioSession.mode.rawValue)")
        print("   Options: \(audioSession.categoryOptions.rawValue)")
        print("   Is Active: \(audioSession.isOtherAudioPlaying)")
        print("   Available Categories: [ambient, soloAmbient, playback, record, playAndRecord, multiRoute]")
        #endif
    }
    
    func pauseAudio() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    func resumeAudio() {
        audioPlayer?.play()
        isPlaying = true
    }
    
    public func playAudioFromURL(_ url: URL) {
        do {
            // Stop any currently playing audio
            stopAudio()
            
            // Configure audio session for playback
            #if os(iOS)
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            #endif
            
            // Create and configure audio player
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            
            // Prepare and play
            guard audioPlayer?.prepareToPlay() == true else {
                print("❌ Failed to prepare audio for playback")
                return
            }
            
            guard audioPlayer?.play() == true else {
                print("❌ Failed to start audio playback")
                return
            }
            
            isPlaying = true
            currentPlayingEntry = nil // No specific entry for URL playback
            print("🎵 Successfully playing audio from URL: \(url.path)")
            print("⏱️ Audio duration: \(audioPlayer?.duration ?? 0) seconds")
            
        } catch {
            print("❌ Error playing audio from URL: \(error.localizedDescription)")
        }
    }
    
    // MARK: - AVAudioPlayerDelegate
    @objc public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        currentPlayingEntry = nil
        print("🎵 Audio playback finished")
    }
    
    @objc public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("❌ Audio decode error: \(error?.localizedDescription ?? "Unknown error")")
        isPlaying = false
        currentPlayingEntry = nil
    }
}

// MARK: - Journal Entry Model
public struct JournalEntry: Identifiable, Codable {
    public let id: UUID
    var date: Date
    let emotion: EmotionalState
    let prompt: JournalPrompt
    var content: String
    var audioURLString: String?
    var tags: [String]
    
    var audioURL: URL? {
        guard let audioURLString = audioURLString else { return nil }
        
        // If it's a file URL, try to reconstruct the path
        if audioURLString.hasPrefix("file://") {
            // Extract just the filename from the stored path
            let filename = URL(string: audioURLString)?.lastPathComponent ?? ""
            if !filename.isEmpty {
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                return documentsPath.appendingPathComponent(filename)
            }
        }
        
        // Fallback to original behavior
        return URL(string: audioURLString)
    }
    
    var hasAudio: Bool {
        return audioURL != nil
    }
    
    public init(emotion: EmotionalState, prompt: JournalPrompt, content: String, audioURL: URL? = nil, tags: [String] = []) {
        self.id = UUID()
        self.date = Date()
        self.emotion = emotion
        self.prompt = prompt
        self.content = content
        self.audioURLString = audioURL?.absoluteString
        self.tags = tags
    }
}

// MARK: - Journal Prompt Model
public struct JournalPrompt: Identifiable, Codable {
    public let id: UUID
    public let text: String
    public let category: PromptCategory
    public let estimatedTime: String
    
    public init(text: String, category: PromptCategory, estimatedTime: String) {
        self.id = UUID()
        self.text = text
        self.category = category
        self.estimatedTime = estimatedTime
    }
}

public enum PromptCategory: String, CaseIterable, Codable {
    case reflection = "reflection"
    case gratitude = "gratitude"
    case growth = "growth"
    case selfCompassion = "self_compassion"
    case selfCare = "self_care"
    case celebration = "celebration"
    case parenting = "parenting"
    case connection = "connection"
    case selfAwareness = "self_awareness"
    case planning = "planning"
    
    var title: String {
        switch self {
        case .reflection: return "Reflexión"
        case .gratitude: return "Gratitud"
        case .growth: return "Crecimiento"
        case .selfCompassion: return "Autocompasión"
        case .selfCare: return "Autocuidado"
        case .celebration: return "Celebración"
        case .parenting: return "Paternidad"
        case .connection: return "Conexión"
        case .selfAwareness: return "Autoconocimiento"
        case .planning: return "Planificación"
        }
    }
    
    var icon: String {
        switch self {
        case .reflection: return "brain.head.profile"
        case .gratitude: return "heart.fill"
        case .growth: return "chart.line.uptrend.xyaxis"
        case .selfCompassion: return "person.circle.fill"
        case .selfCare: return "leaf.fill"
        case .celebration: return "party.popper.fill"
        case .parenting: return "person.2.fill"
        case .connection: return "link"
        case .selfAwareness: return "eye.fill"
        case .planning: return "calendar"
        }
    }
    
    var color: Color {
        switch self {
        case .reflection: return .blue
        case .gratitude: return .green
        case .growth: return .purple
        case .selfCompassion: return .pink
        case .selfCare: return .mint
        case .celebration: return .yellow
        case .parenting: return .orange
        case .connection: return .cyan
        case .selfAwareness: return .indigo
        case .planning: return .brown
        }
    }
}

// MARK: - Journal Context
public enum JournalContext {
    case afterTest(String)
    case afterExercise(String)
    case endOfDay
    case weekendReflection
}
