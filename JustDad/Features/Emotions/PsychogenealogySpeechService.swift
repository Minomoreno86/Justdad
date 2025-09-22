//
//  PsychogenealogySpeechService.swift
//  JustDad - Psychogenealogy Speech Service
//
//  Servicio de reconocimiento de voz para cartas de Psicogenealogía
//  Created by Jorge Vasquez Rodriguez
//

import SwiftUI
import Speech
import AVFoundation
import UIKit
import Combine

class PsychogenealogySpeechService: ObservableObject {
    static let shared = PsychogenealogySpeechService()
    
    @Published var isListening = false
    @Published var recognizedText = ""
    @Published var detectedAnchors: [String] = []
    @Published var currentAnchorStatus: [String: Bool] = [:]
    @Published var error: String?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-ES"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private init() {}
    
    // MARK: - Speech Recognition
    
    func startRecording(forAnchors anchors: [String]) throws {
        // Reset previous state
        reset()
        
        // Check authorization
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            throw NSError(domain: "PsychogenealogySpeechService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No tienes permisos para usar el reconocimiento de voz"])
        }
        
        // Check if speech recognizer is available
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            throw NSError(domain: "PsychogenealogySpeechService", code: 2, userInfo: [NSLocalizedDescriptionKey: "El reconocimiento de voz no está disponible"])
        }
        
        // Stop any previous recognition task
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // Create recognition request
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = false
        
        self.recognitionRequest = recognitionRequest
        
        // Create recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor in
                if let result = result {
                    self?.recognizedText = result.bestTranscription.formattedString
                    self?.processRecognizedText(for: anchors)
                }
                
                if let error = error {
                    self?.error = error.localizedDescription
                    self?.stopRecording()
                }
            }
        }
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Set up audio engine
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        isListening = true
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        isListening = false
        
        // Reset audio session
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    func reset() {
        stopRecording()
        recognizedText = ""
        detectedAnchors = []
        currentAnchorStatus = [:]
        error = nil
    }
    
    // MARK: - Text Processing
    
    private func processRecognizedText(for anchors: [String]) {
        let lowercasedText = recognizedText.lowercased()
        
        for anchor in anchors {
            let lowercasedAnchor = anchor.lowercased()
            
            // Check for exact match or partial match
            if lowercasedText.contains(lowercasedAnchor) {
                if !detectedAnchors.contains(anchor) {
                    detectedAnchors.append(anchor)
                    currentAnchorStatus[anchor] = true
                    
                    // Trigger haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .rigid)
                    impactFeedback.impactOccurred()
                }
            }
        }
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        return await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    var authorizationStatus: SFSpeechRecognizerAuthorizationStatus {
        return SFSpeechRecognizer.authorizationStatus()
    }
}

// MARK: - Speech Error
// Using SpeechError from RobustSpeechRecognitionService

