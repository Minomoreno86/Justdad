//
//  AmarresVoiceValidator.swift
//  JustDad - Validador de Voz para Corte de Amarres o Brujería
//
//  Maneja la validación de voz para los anclas específicas del ritual de amarres
//

import Foundation
import Speech
import AVFoundation
import Combine

// MARK: - Estados de Validación de Voz
public enum AmarresVoiceValidationState: String, CaseIterable, Codable {
    case idle = "idle"
    case starting = "starting"
    case recording = "recording"
    case stopping = "stopping"
    case failed = "failed"
    case completed = "completed"
    
    public var displayName: String {
        switch self {
        case .idle: return "Inactivo"
        case .starting: return "Iniciando"
        case .recording: return "Grabando"
        case .stopping: return "Deteniendo"
        case .failed: return "Fallido"
        case .completed: return "Completado"
        }
    }
}

// MARK: - Protocolo del Validador de Voz
protocol AmarresVoiceValidatorProtocol: ObservableObject {
    var currentState: AmarresVoiceValidationState { get }
    var currentBlock: AmarresReadingBlock? { get }
    var currentResult: AmarresVoiceValidation? { get }
    var isListening: Bool { get }
    var hasPermission: Bool { get }
    var errorMessage: String? { get }
    
    func requestPermission()
    func startListening(for block: AmarresReadingBlock)
    func stopListening()
    func updateValidationResult(_ result: AmarresVoiceValidation)
}

// MARK: - Validador de Voz de Amarres
@MainActor
public class AmarresVoiceValidator: NSObject, AmarresVoiceValidatorProtocol {
    @Published public var currentState: AmarresVoiceValidationState = .idle
    @Published public var currentBlock: AmarresReadingBlock?
    @Published public var currentResult: AmarresVoiceValidation?
    @Published public var isListening: Bool = false
    @Published public var hasPermission: Bool = false
    @Published public var errorMessage: String?
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine: AVAudioEngine?
    private let contentPack = AmarresContentPack.shared
    
    public override init() {
        super.init()
        setupSpeechRecognizer()
        requestPermission()
    }
    
    // MARK: - Configuración
    
    private func setupSpeechRecognizer() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-ES"))
        
        guard speechRecognizer != nil else {
            errorMessage = "El reconocimiento de voz no está disponible en español"
            return
        }
        
        speechRecognizer?.delegate = self
    }
    
    // MARK: - Permisos
    
    public func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self?.hasPermission = true
                    self?.errorMessage = nil
                case .denied:
                    self?.hasPermission = false
                    self?.errorMessage = "Permiso de reconocimiento de voz denegado"
                case .restricted:
                    self?.hasPermission = false
                    self?.errorMessage = "Reconocimiento de voz restringido"
                case .notDetermined:
                    self?.hasPermission = false
                    self?.errorMessage = "Permiso de reconocimiento de voz no determinado"
                @unknown default:
                    self?.hasPermission = false
                    self?.errorMessage = "Error desconocido con permisos de voz"
                }
            }
        }
    }
    
    // MARK: - Control de Grabación
    
    public func startListening(for block: AmarresReadingBlock) {
        guard hasPermission else {
            errorMessage = "No se tiene permiso para reconocimiento de voz"
            return
        }
        
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Reconocimiento de voz no disponible"
            return
        }
        
        // Cancelar tarea anterior si existe
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        currentBlock = block
        currentState = .starting
        
        // Configurar audio engine
        setupAudioEngine()
        
        // Crear request de reconocimiento
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            errorMessage = "No se pudo crear el request de reconocimiento"
            currentState = .failed
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Iniciar tarea de reconocimiento
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.handleRecognitionResult(result: result, error: error)
            }
        }
        
        // Configurar audio input
        guard let audioEngine = audioEngine else { return }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            currentState = .recording
            isListening = true
            errorMessage = nil
        } catch {
            errorMessage = "Error iniciando el motor de audio: \(error.localizedDescription)"
            currentState = .failed
        }
    }
    
    public func stopListening() {
        currentState = .stopping
        
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
        
        currentState = .completed
        isListening = false
    }
    
    // MARK: - Manejo de Resultados
    
    private func handleRecognitionResult(result: SFSpeechRecognitionResult?, error: Error?) {
        if let error = error {
            errorMessage = "Error en reconocimiento: \(error.localizedDescription)"
            currentState = .failed
            return
        }
        
        guard let result = result else { return }
        
        let spokenText = result.bestTranscription.formattedString.lowercased()
        
        // Validar anclas específicas del bloque actual
        if let block = currentBlock {
            validateAnchors(for: block, spokenText: spokenText)
        }
    }
    
    private func validateAnchors(for block: AmarresReadingBlock, spokenText: String) {
        guard let content = contentPack.getContent(for: block, approach: .secular) else { return }
        
        let anchors = content.anchors.map { $0.lowercased() }
        let normalizedSpokenText = normalizeText(spokenText)
        
        var detectedPhrases: [String] = []
        var missingPhrases: [String] = []
        
        for anchor in anchors {
            let normalizedAnchor = normalizeText(anchor)
            if normalizedSpokenText.contains(normalizedAnchor) {
                detectedPhrases.append(anchor)
            } else {
                missingPhrases.append(anchor)
            }
        }
        
        let isValid = detectedPhrases.count >= 2 // Mínimo 2 de 3 anclas
        let accuracy = Double(detectedPhrases.count) / Double(anchors.count)
        
        let validation = AmarresVoiceValidation(
            isValid: isValid,
            accuracy: accuracy,
            phrasesDetected: detectedPhrases,
            missingPhrases: missingPhrases
        )
        
        currentResult = validation
        updateValidationResult(validation)
    }
    
    private func normalizeText(_ text: String) -> String {
        return text
            .lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
            .replacingOccurrences(of: "[^a-z\\s]", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func updateValidationResult(_ result: AmarresVoiceValidation) {
        currentResult = result
        
        if result.isValid {
            currentState = .completed
            errorMessage = nil
        } else {
            currentState = .failed
            errorMessage = "Faltan anclas: \(result.missingPhrases.joined(separator: ", "))"
        }
    }
    
    // MARK: - Configuración de Audio
    
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        
        guard let audioEngine = audioEngine else { return }
        
        // Configurar sesión de audio
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Error configurando sesión de audio: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Limpieza
    
    deinit {
        // No podemos llamar stopListening() desde deinit porque es main actor isolated
        // La limpieza se manejará automáticamente cuando se libere el objeto
    }
}

// MARK: - Extensiones para SFSpeechRecognizerDelegate

extension AmarresVoiceValidator: SFSpeechRecognizerDelegate {
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        DispatchQueue.main.async {
            if !available {
                self.errorMessage = "Reconocimiento de voz no disponible"
                self.currentState = .failed
            }
        }
    }
}

// MARK: - Utilidades de Validación

public extension AmarresVoiceValidator {
    
    /// Obtiene las anclas específicas para un bloque dado
    func getAnchors(for block: AmarresReadingBlock, approach: AmarresApproach) -> [String] {
        guard let content = contentPack.getContent(for: block, approach: approach) else {
            return []
        }
        return content.anchors
    }
    
    /// Valida si el texto hablado contiene las anclas necesarias
    func validateText(_ spokenText: String, for block: AmarresReadingBlock, approach: AmarresApproach) -> AmarresVoiceValidation {
        let anchors = getAnchors(for: block, approach: approach)
        let normalizedSpokenText = normalizeText(spokenText)
        
        var detectedPhrases: [String] = []
        var missingPhrases: [String] = []
        
        for anchor in anchors {
            let normalizedAnchor = normalizeText(anchor)
            if normalizedSpokenText.contains(normalizedAnchor) {
                detectedPhrases.append(anchor)
            } else {
                missingPhrases.append(anchor)
            }
        }
        
        let isValid = detectedPhrases.count >= 2 // Mínimo 2 de 3 anclas
        let accuracy = Double(detectedPhrases.count) / Double(anchors.count)
        
        return AmarresVoiceValidation(
            isValid: isValid,
            accuracy: accuracy,
            phrasesDetected: detectedPhrases,
            missingPhrases: missingPhrases
        )
    }
    
    /// Obtiene el progreso de validación actual
    func getValidationProgress() -> Double {
        guard let result = currentResult else { return 0.0 }
        return result.accuracy
    }
    
    /// Verifica si la validación actual es exitosa
    func isValidationSuccessful() -> Bool {
        return currentResult?.isValid ?? false
    }
    
    /// Obtiene las frases faltantes para completar la validación
    func getMissingPhrases() -> [String] {
        return currentResult?.missingPhrases ?? []
    }
    
    /// Reinicia el validador para una nueva sesión
    func reset() {
        stopListening()
        currentState = .idle
        currentBlock = nil
        currentResult = nil
        errorMessage = nil
    }
}

// MARK: - Anclas Específicas por Bloque

public extension AmarresVoiceValidator {
    
    /// Anclas para el bloque de diagnóstico
    static let diagnosisAnchors = [
        "Me observo con amor",
        "Identifico mis síntomas",
        "Reconozco mi realidad"
    ]
    
    /// Anclas para el bloque de respiración
    static let breathingAnchors = [
        "Respiro profundamente",
        "Me centro en mi respiración",
        "Relajo mi cuerpo"
    ]
    
    /// Anclas para el bloque de identificación
    static let identificationAnchors = [
        "Identifico mis amarres",
        "Reconozco los vínculos tóxicos",
        "Nombro lo que me ata"
    ]
    
    /// Anclas para el bloque de limpieza
    static let cleansingAnchors = [
        "Visualizo luz blanca",
        "Limpio mi campo energético",
        "Purifico mi aura"
    ]
    
    /// Anclas para el bloque de corte
    static let cuttingAnchors = [
        "Visualizo tijeras de luz",
        "Corto los vínculos con amor",
        "Siento la liberación"
    ]
    
    /// Anclas para el bloque de protección
    static let protectionAnchors = [
        "Visualizo un escudo de luz",
        "Envuelvo mi campo energético",
        "Establezco límites claros"
    ]
    
    /// Anclas para el bloque de sellado
    static let sealingAnchors = [
        "Sello el proceso con gratitud",
        "Establezco compromisos de autocuidado",
        "Visualizo el futuro libre"
    ]
}

// MARK: - Configuración de Validación

public struct AmarresValidationConfig {
    public let minimumAnchorsRequired: Int
    public let accuracyThreshold: Double
    public let timeoutSeconds: TimeInterval
    
    public static let defaultConfig = AmarresValidationConfig(
        minimumAnchorsRequired: 2,
        accuracyThreshold: 0.67,
        timeoutSeconds: 30.0
    )
    
    public init(
        minimumAnchorsRequired: Int,
        accuracyThreshold: Double,
        timeoutSeconds: TimeInterval
    ) {
        self.minimumAnchorsRequired = minimumAnchorsRequired
        self.accuracyThreshold = accuracyThreshold
        self.timeoutSeconds = timeoutSeconds
    }
}
