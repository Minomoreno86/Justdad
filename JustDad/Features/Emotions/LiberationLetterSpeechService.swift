//
//  LiberationLetterSpeechService.swift
//  JustDad - Liberation Letter Speech Recognition Service
//
//  Servicio para detectar anclas de voz durante la lectura de cartas
//

import Foundation
import Speech
import AVFoundation
import SwiftUI
import UIKit

// MARK: - Speech Recognition Service
@MainActor
class LiberationLetterSpeechService: NSObject, ObservableObject {
    static let shared = LiberationLetterSpeechService()
    
    // MARK: - Published Properties
    @Published var isListening = false
    @Published var recognizedText = ""
    @Published var detectedAnchors: [String] = []
    @Published var speechAccuracy: Double = 0.0
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private var audioEngine = AVAudioEngine()
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-ES"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var targetAnchors: [String] = []
    private var startTime: Date?
    private var onCompletion: ((VoiceAnchorDetectionResult) -> Void)?
    
    private override init() {
        super.init()
        setupAudioSession()
    }
    
    // MARK: - Public Methods
    func startListening(for anchors: [String], completion: @escaping (VoiceAnchorDetectionResult) -> Void) {
        guard !isListening else { return }
        
        // Reset state
        targetAnchors = anchors
        detectedAnchors = []
        recognizedText = ""
        speechAccuracy = 0.0
        errorMessage = nil
        onCompletion = completion
        startTime = Date()
        
        // Request permissions
        requestSpeechPermissions { [weak self] granted in
            if granted {
                self?.startSpeechRecognition()
            } else {
                self?.errorMessage = "Permisos de reconocimiento de voz no concedidos"
            }
        }
    }
    
    func stopListening() {
        guard isListening else { return }
        
        isListening = false
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        // Generate result
        if let completion = onCompletion {
            let result = VoiceAnchorDetectionResult(
                detectedAnchors: detectedAnchors,
                totalAnchors: targetAnchors
            )
            completion(result)
        }
    }
    
    func calculateReadingAccuracy(expectedText: String) -> Double {
        let expectedWords = expectedText.lowercased().components(separatedBy: .whitespacesAndNewlines)
        let recognizedWords = recognizedText.lowercased().components(separatedBy: .whitespacesAndNewlines)
        
        guard !expectedWords.isEmpty else { return 0.0 }
        
        let matchedWords = Set(expectedWords).intersection(Set(recognizedWords))
        return Double(matchedWords.count) / Double(expectedWords.count)
    }
    
    // MARK: - Private Methods
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Error setting up audio session: \(error)")
        }
    }
    
    private func requestSpeechPermissions(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }
    
    private func startSpeechRecognition() {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Reconocimiento de voz no disponible"
            return
        }
        
        do {
            // Cancel previous task
            recognitionTask?.cancel()
            recognitionTask = nil
            
            // Create recognition request
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else {
                errorMessage = "No se pudo crear la solicitud de reconocimiento"
                return
            }
            
            recognitionRequest.shouldReportPartialResults = true
            
            // Setup audio engine
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
                self?.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            isListening = true
            
            // Start recognition task
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                DispatchQueue.main.async {
                    if let result = result {
                        self?.recognizedText = result.bestTranscription.formattedString
                        self?.detectAnchors(in: result.bestTranscription.formattedString)
                        self?.speechAccuracy = self?.calculateReadingAccuracy(expectedText: result.bestTranscription.formattedString) ?? 0.0
                    }
                    
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        self?.stopListening()
                    }
                    
                    if result?.isFinal == true {
                        self?.stopListening()
                    }
                }
            }
            
        } catch {
            errorMessage = "Error iniciando reconocimiento de voz: \(error.localizedDescription)"
        }
    }
    
    private func detectAnchors(in text: String) {
        let lowercaseText = text.lowercased()
        
        for anchor in targetAnchors {
            let lowercaseAnchor = anchor.lowercased()
            if lowercaseText.contains(lowercaseAnchor) && !detectedAnchors.contains(anchor) {
                detectedAnchors.append(anchor)
                
                // Provide haptic feedback for detected anchor
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }
        }
    }
}

// MARK: - Speech Recognition Permission Helper
extension LiberationLetterSpeechService {
    static func requestPermissions() async -> Bool {
        return await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    static func getPermissionStatus() -> SFSpeechRecognizerAuthorizationStatus {
        return SFSpeechRecognizer.authorizationStatus()
    }
}

// MARK: - Voice Anchor Detection Utilities
extension LiberationLetterSpeechService {
    
    /// Normaliza el texto para mejor detección de anclas
    private func normalizeText(_ text: String) -> String {
        return text.lowercased()
            .replacingOccurrences(of: "á", with: "a")
            .replacingOccurrences(of: "é", with: "e")
            .replacingOccurrences(of: "í", with: "i")
            .replacingOccurrences(of: "ó", with: "o")
            .replacingOccurrences(of: "ú", with: "u")
            .replacingOccurrences(of: "ñ", with: "n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Detecta anclas con tolerancia a variaciones
    private func detectAnchorsWithTolerance(in text: String, anchors: [String]) -> [String] {
        let normalizedText = normalizeText(text)
        var detected: [String] = []
        
        for anchor in anchors {
            let normalizedAnchor = normalizeText(anchor)
            
            // Exact match
            if normalizedText.contains(normalizedAnchor) {
                detected.append(anchor)
                continue
            }
            
            // Fuzzy match (80% similarity)
            let words = normalizedAnchor.components(separatedBy: .whitespaces)
            let matchedWords = words.filter { word in
                normalizedText.contains(word) || 
                normalizedText.components(separatedBy: .whitespaces).contains { $0.hasPrefix(word) || word.hasPrefix($0) }
            }
            
            let similarity = Double(matchedWords.count) / Double(words.count)
            if similarity >= 0.8 {
                detected.append(anchor)
            }
        }
        
        return detected
    }
}

// MARK: - Audio Session Management
extension LiberationLetterSpeechService {
    
    func pauseListening() {
        audioEngine.pause()
        isListening = false
    }
    
    func resumeListening() {
        do {
            try audioEngine.start()
            isListening = true
        } catch {
            errorMessage = "Error resumiendo el reconocimiento: \(error.localizedDescription)"
        }
    }
    
    func resetSession() {
        stopListening()
        audioEngine.reset()
        recognizedText = ""
        detectedAnchors = []
        speechAccuracy = 0.0
        errorMessage = nil
        targetAnchors = []
        onCompletion = nil
        startTime = nil
    }
}
