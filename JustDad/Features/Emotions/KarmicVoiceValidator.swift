//
//  KarmicVoiceValidator.swift
//  JustDad - Karmic Bonds Voice Validation
//
//  Validador de anclas de voz para el módulo de Vínculos Pesados
//

import Foundation
import Speech
import AVFoundation
import Combine

// MARK: - Karmic Voice Validator
public class KarmicVoiceValidator: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published public var isRecording: Bool = false
    @Published public var isAuthorized: Bool = false
    @Published public var currentValidation: KarmicVoiceValidation?
    @Published public var recognitionError: String?
    @Published public var validationProgress: Double = 0.0
    
    // MARK: - Private Properties
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    
    private let audioSession = AVAudioSession.sharedInstance()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Configuration
    private let requiredThreshold: Double = 2.0/3.0 // ≥ 2/3 required
    private let normalizationEnabled: Bool = true
    
    // MARK: - Initialization
    public override init() {
        super.init()
        setupSpeechRecognizer()
        requestAuthorization()
    }
    
    // MARK: - Public Methods
    
    /// Inicia la validación de voz para un bloque específico
    public func startValidation(for block: KarmicReadingBlock, anchors: [String]) {
        guard isAuthorized else {
            recognitionError = "Autorización de micrófono requerida"
            return
        }
        
        guard !isRecording else {
            recognitionError = "Ya hay una validación en curso"
            return
        }
        
        startRecording { [weak self] recognizedText in
            self?.processValidation(block: block, anchors: anchors, recognizedText: recognizedText)
        }
    }
    
    /// Detiene la validación actual
    public func stopValidation() {
        stopRecording()
    }
    
    /// Valida texto manualmente (para casos sin micrófono)
    public func validateManually(block: KarmicReadingBlock, anchors: [String], text: String) -> KarmicVoiceValidation {
        let validatedAnchors = findValidatedAnchors(in: text, anchors: anchors)
        return KarmicVoiceValidation(
            block: block,
            validatedAnchors: validatedAnchors,
            totalAnchors: anchors
        )
    }
    
    /// Simula una validación exitosa (para testing)
    public func simulateSuccessfulValidation(block: KarmicReadingBlock, anchors: [String]) -> KarmicVoiceValidation {
        let validatedAnchors = Array(anchors.prefix(Int(ceil(Double(anchors.count) * requiredThreshold))))
        return KarmicVoiceValidation(
            block: block,
            validatedAnchors: validatedAnchors,
            totalAnchors: anchors
        )
    }
    
    // MARK: - Private Methods
    
    private func setupSpeechRecognizer() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-ES"))
        
        guard let speechRecognizer = speechRecognizer else {
            recognitionError = "Reconocimiento de voz no disponible en español"
            return
        }
        
        speechRecognizer.delegate = self
    }
    
    private func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self?.isAuthorized = true
                case .denied:
                    self?.isAuthorized = false
                    self?.recognitionError = "Acceso al micrófono denegado"
                case .restricted:
                    self?.isAuthorized = false
                    self?.recognitionError = "Reconocimiento de voz restringido"
                case .notDetermined:
                    self?.isAuthorized = false
                    self?.recognitionError = "Autorización pendiente"
                @unknown default:
                    self?.isAuthorized = false
                    self?.recognitionError = "Estado de autorización desconocido"
                }
            }
        }
    }
    
    private func startRecording(completion: @escaping (String) -> Void) {
        // Cancel previous task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            recognitionError = "Error configurando sesión de audio: \(error.localizedDescription)"
            return
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            recognitionError = "No se pudo crear solicitud de reconocimiento"
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = false
        
        // Setup audio engine
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else {
            recognitionError = "No se pudo crear motor de audio"
            return
        }
        
        inputNode = audioEngine.inputNode
        guard let inputNode = inputNode else {
            recognitionError = "No se pudo acceder al nodo de entrada"
            return
        }
        
        // Setup recognition task
        guard let speechRecognizer = speechRecognizer else {
            recognitionError = "Reconocimiento de voz no disponible"
            return
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            DispatchQueue.main.async {
                if let result = result {
                    let recognizedText = result.bestTranscription.formattedString
                    completion(recognizedText)
                    
                    if result.isFinal {
                        self?.stopRecording()
                    }
                }
                
                if let error = error {
                    self?.recognitionError = "Error de reconocimiento: \(error.localizedDescription)"
                    self?.stopRecording()
                }
            }
        }
        
        // Setup audio format
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isRecording = true
            validationProgress = 0.0
        } catch {
            recognitionError = "Error iniciando motor de audio: \(error.localizedDescription)"
        }
    }
    
    private func stopRecording() {
        audioEngine?.stop()
        inputNode?.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        isRecording = false
        validationProgress = 1.0
        
        // Deactivate audio session
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Error desactivando sesión de audio: \(error.localizedDescription)")
        }
    }
    
    private func processValidation(block: KarmicReadingBlock, anchors: [String], recognizedText: String) {
        let validatedAnchors = findValidatedAnchors(in: recognizedText, anchors: anchors)
        
        let validation = KarmicVoiceValidation(
            block: block,
            validatedAnchors: validatedAnchors,
            totalAnchors: anchors
        )
        
        currentValidation = validation
        
        // Update progress
        validationProgress = validation.validationPercentage
        
        print("🎤 Validación completada: \(validatedAnchors.count)/\(anchors.count) anclas detectadas")
    }
    
    private func findValidatedAnchors(in text: String, anchors: [String]) -> [String] {
        let normalizedText = normalizeText(text)
        var validatedAnchors: [String] = []
        
        for anchor in anchors {
            let normalizedAnchor = normalizeText(anchor)
            
            if normalizedText.contains(normalizedAnchor) {
                validatedAnchors.append(anchor)
            }
        }
        
        return validatedAnchors
    }
    
    private func normalizeText(_ text: String) -> String {
        guard normalizationEnabled else { return text }
        
        return text
            .lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
            .replacingOccurrences(of: "[^a-z0-9\\s]", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Utility Methods
    
    /// Obtiene el estado de validación como string legible
    public func getValidationStatus(_ validation: KarmicVoiceValidation) -> String {
        let percentage = Int(validation.validationPercentage * 100)
        let status = validation.success ? "✅ Exitoso" : "❌ Insuficiente"
        return "\(status) - \(percentage)% (\(validation.validatedAnchors.count)/\(validation.totalAnchors.count) anclas)"
    }
    
    /// Obtiene las anclas faltantes para completar la validación
    public func getMissingAnchors(_ validation: KarmicVoiceValidation) -> [String] {
        return validation.totalAnchors.filter { !validation.validatedAnchors.contains($0) }
    }
    
    /// Verifica si una validación cumple con el umbral requerido
    public func meetsThreshold(_ validation: KarmicVoiceValidation) -> Bool {
        return validation.validationPercentage >= requiredThreshold
    }
    
    /// Obtiene el umbral requerido como porcentaje
    public func getRequiredThresholdPercentage() -> Int {
        return Int(requiredThreshold * 100)
    }
}

// MARK: - SFSpeechRecognizerDelegate
extension KarmicVoiceValidator: SFSpeechRecognizerDelegate {
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        DispatchQueue.main.async { [weak self] in
            if !available {
                self?.recognitionError = "Reconocimiento de voz no disponible"
                self?.stopRecording()
            }
        }
    }
}

// MARK: - Karmic Voice Validation Extensions
extension KarmicVoiceValidation {
    
    /// Verifica si la validación es exitosa
    public var isSuccessful: Bool {
        return success
    }
    
    /// Obtiene el porcentaje de validación como string
    public var percentageString: String {
        return "\(Int(validationPercentage * 100))%"
    }
    
    /// Obtiene el número de anclas validadas
    public var validatedCount: Int {
        return validatedAnchors.count
    }
    
    /// Obtiene el número total de anclas
    public var totalCount: Int {
        return totalAnchors.count
    }
    
    /// Obtiene el tiempo transcurrido desde la validación
    public var timeElapsed: TimeInterval {
        return Date().timeIntervalSince(timestamp)
    }
}

// MARK: - Preview Helpers
#if DEBUG
extension KarmicVoiceValidator {
    
    /// Crea una instancia para previews
    public static func preview() -> KarmicVoiceValidator {
        let validator = KarmicVoiceValidator()
        validator.isAuthorized = true
        return validator
    }
    
    /// Crea una validación de ejemplo
    public static func sampleValidation() -> KarmicVoiceValidation {
        return KarmicVoiceValidation(
            block: .recognition,
            validatedAnchors: ["reconozco lo que vivimos", "me afectó"],
            totalAnchors: ["reconozco lo que vivimos", "me afectó", "no necesito seguir atado"]
        )
    }
}
#endif
