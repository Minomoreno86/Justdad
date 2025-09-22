//
//  RobustSpeechRecognitionService.swift
//  JustDad - Robust Speech Recognition Service
//
//  Servicio robusto de reconocimiento de voz con manejo completo de estados y cleanup
//

import Foundation
import Speech
import AVFoundation
import Combine

@MainActor
public class RobustSpeechRecognitionService: NSObject, ObservableObject {
    public static let shared = RobustSpeechRecognitionService()
    
    // MARK: - Published Properties
    @Published var state: SpeechState = .idle
    @Published var recognizedText = ""
    @Published var errorMessage: String?
    @Published var hasPermission = false
    
    // MARK: - Private Properties
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-ES"))
    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var inputNode: AVAudioInputNode?
    
    private let audioSession = AVAudioSession.sharedInstance()
    private var isHardResetInProgress = false
    
    // MARK: - Initialization
    private override init() {
        super.init()
        requestPermissions()
    }
    
    // MARK: - Permission Management
    private func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self?.hasPermission = true
                    self?.state = .idle
                case .denied:
                    self?.hasPermission = false
                    self?.state = .failed("Permisos de reconocimiento de voz denegados")
                    self?.errorMessage = "Permisos de reconocimiento de voz denegados"
                case .restricted:
                    self?.hasPermission = false
                    self?.state = .failed("Reconocimiento de voz restringido en este dispositivo")
                    self?.errorMessage = "Reconocimiento de voz restringido en este dispositivo"
                case .notDetermined:
                    self?.hasPermission = false
                    self?.state = .failed("Permisos de reconocimiento de voz no determinados")
                    self?.errorMessage = "Permisos de reconocimiento de voz no determinados"
                @unknown default:
                    self?.hasPermission = false
                    self?.state = .failed("Error de autorización de reconocimiento de voz desconocido")
                    self?.errorMessage = "Error de autorización de reconocimiento de voz desconocido"
                }
            }
        }
    }
    
    // MARK: - Main Interface
    public func startRecording() {
        // Prevent multiple simultaneous starts
        guard !state.isBusy && !isHardResetInProgress else {
            print("⚠️ Ignoring start request - service is busy or resetting")
            return
        }
        
        // Check permissions
        guard hasPermission else {
            state = .failed("No hay permisos para usar el reconocimiento de voz")
            errorMessage = "No hay permisos para usar el reconocimiento de voz"
            return
        }
        
        // Check if recognizer is available
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            state = .failed("El reconocimiento de voz no está disponible")
            errorMessage = "El reconocimiento de voz no está disponible"
            return
        }
        
        state = .starting
        
        // Always stop and cleanup first (idempotent)
        stopRecording()
        
        // Wait a bit for cleanup to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.performStartRecording()
        }
    }
    
    private func performStartRecording() {
        guard state == .starting else { return }
        
        do {
            // Configure audio session
            try configureAudioSession()
            
            // Create new audio engine and components
            try createAudioComponents()
            
            // Start the audio engine
            try audioEngine?.start()
            
            state = .recording
            recognizedText = ""
            errorMessage = nil
            
            print("✅ Speech recognition started successfully")
            
        } catch {
            print("❌ Failed to start speech recognition: \(error)")
            handleStartFailure(error)
        }
    }
    
    public func stopRecording() {
        guard state.isBusy else { return }
        
        state = .stopping
        
        // Stop audio engine
        audioEngine?.stop()
        
        // Remove tap from input node
        if let inputNode = inputNode {
            inputNode.removeTap(onBus: 0)
        }
        
        // End recognition request
        recognitionRequest?.endAudio()
        
        // Cancel recognition task
        recognitionTask?.cancel()
        
        // Clean up references
        cleanupComponents()
        
        // Reset audio session
        resetAudioSession()
        
        state = .idle
        print("✅ Speech recognition stopped and cleaned up")
    }
    
    public func reset() {
        stopRecording()
        recognizedText = ""
        errorMessage = nil
        isHardResetInProgress = false
    }
    
    // MARK: - Audio Configuration
    private func configureAudioSession() throws {
        try audioSession.setCategory(.record, mode: .measurement, options: [.duckOthers])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    private func resetAudioSession() {
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("⚠️ Error resetting audio session: \(error)")
        }
    }
    
    // MARK: - Audio Components Creation
    private func createAudioComponents() throws {
        // Create new audio engine
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else {
            throw NSError(domain: "RobustSpeechRecognitionService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Fallo al crear el motor de audio"])
        }
        
        // Get input node
        inputNode = audioEngine.inputNode
        guard let inputNode = inputNode else {
            throw NSError(domain: "RobustSpeechRecognitionService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Nodo de entrada de audio no disponible"])
        }
        
        // Create new recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "RobustSpeechRecognitionService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Fallo al crear la solicitud de reconocimiento"])
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Create recognition task
        guard let speechRecognizer = speechRecognizer else {
            throw NSError(domain: "RobustSpeechRecognitionService", code: 4, userInfo: [NSLocalizedDescriptionKey: "El reconocimiento de voz no está disponible"])
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor in
                await self?.handleRecognitionResult(result: result, error: error)
            }
        }
        
        // Install tap on input node
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        
        // Prepare audio engine
        audioEngine.prepare()
    }
    
    // MARK: - Recognition Result Handling
    private func handleRecognitionResult(result: SFSpeechRecognitionResult?, error: Error?) async {
        if let result = result {
            recognizedText = result.bestTranscription.formattedString
            
            if result.isFinal {
                stopRecording()
            }
        }
        
        if let error = error {
            print("❌ Recognition error: \(error)")
            handleStartFailure(error)
        }
    }
    
    // MARK: - Error Handling
    private func handleStartFailure(_ error: Error) {
        state = .failed(error.localizedDescription)
        errorMessage = error.localizedDescription
        
        // Perform hard reset
        performHardReset()
    }
    
    private func performHardReset() {
        guard !isHardResetInProgress else { return }
        
        isHardResetInProgress = true
        
        // Immediate cleanup
        cleanupComponents()
        resetAudioSession()
        
        // Wait before allowing new attempts
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.state = .idle
            self?.isHardResetInProgress = false
            print("✅ Hard reset completed, ready for new attempts")
        }
    }
    
    private func cleanupComponents() {
        // Stop and reset audio engine
        audioEngine?.stop()
        audioEngine?.reset()
        audioEngine = nil
        
        // Clean up input node
        inputNode = nil
        
        // Clean up recognition components
        recognitionRequest = nil
        recognitionTask = nil
    }
    
    // MARK: - Utility Methods
    public func calculateReadingAccuracy(expectedText: String) -> Double {
        let expectedWords = expectedText.lowercased().components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        let recognizedWords = recognizedText.lowercased().components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        
        guard !expectedWords.isEmpty else { return 0.0 }
        
        let matchingWords = expectedWords.filter { word in
            recognizedWords.contains { recognizedWord in
                word.contains(recognizedWord) || recognizedWord.contains(word)
            }
        }
        
        return Double(matchingWords.count) / Double(expectedWords.count)
    }
    
    public var isRecording: Bool {
        state == .recording
    }
    
    public var isBusy: Bool {
        state.isBusy || isHardResetInProgress
    }
}

// MARK: - Error Types
public enum SpeechError: LocalizedError {
    case permissionDenied
    case permissionRestricted
    case permissionNotDetermined
    case unknownPermissionError
    case recognizerUnavailable
    case audioEngineCreationFailed
    case inputNodeUnavailable
    case recognitionRequestCreationFailed
    
    public var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Permisos de reconocimiento de voz denegados"
        case .permissionRestricted:
            return "Reconocimiento de voz restringido en este dispositivo"
        case .permissionNotDetermined:
            return "Permisos de reconocimiento de voz no determinados"
        case .unknownPermissionError:
            return "Error de autorización de reconocimiento de voz desconocido"
        case .recognizerUnavailable:
            return "El reconocimiento de voz no está disponible en este dispositivo o idioma"
        case .audioEngineCreationFailed:
            return "Fallo al crear el motor de audio"
        case .inputNodeUnavailable:
            return "Nodo de entrada de audio no disponible"
        case .recognitionRequestCreationFailed:
            return "Fallo al crear la solicitud de reconocimiento"
        }
    }
}
