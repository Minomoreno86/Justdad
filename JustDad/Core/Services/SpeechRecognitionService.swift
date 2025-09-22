import Foundation
import Speech
import AVFoundation
import Combine

public class SpeechRecognitionService: NSObject, ObservableObject {
    public static let shared = SpeechRecognitionService()
    
    @Published var isRecording = false
    @Published var recognizedText = ""
    @Published var hasPermission = false
    @Published var errorMessage: String?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-ES"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private override init() {
        super.init()
        requestPermissions()
    }
    
    private func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self?.hasPermission = true
                case .denied, .restricted, .notDetermined:
                    self?.hasPermission = false
                    self?.errorMessage = "Permisos de micrófono no otorgados"
                @unknown default:
                    self?.hasPermission = false
                }
            }
        }
    }
    
    public func startRecording() {
        guard hasPermission else {
            errorMessage = "No hay permisos para usar el micrófono"
            return
        }
        
        // Cancel any previous task
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Error configurando audio: \(error.localizedDescription)"
            return
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            errorMessage = "No se pudo crear la solicitud de reconocimiento"
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Create recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            DispatchQueue.main.async {
                if let result = result {
                    self?.recognizedText = result.bestTranscription.formattedString
                }
                
                if let error = error {
                    self?.errorMessage = "Error de reconocimiento: \(error.localizedDescription)"
                    self?.stopRecording()
                }
            }
        }
        
        // Configure audio engine
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            isRecording = true
            recognizedText = ""
        } catch {
            errorMessage = "Error iniciando grabación: \(error.localizedDescription)"
        }
    }
    
    public func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask = nil
        
        isRecording = false
        
        // Reset audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Error resetting audio session: \(error)")
        }
    }
    
    public func reset() {
        recognizedText = ""
        errorMessage = nil
    }
    
    public func calculateReadingAccuracy(expectedText: String) -> Double {
        let expectedWords = expectedText.lowercased().components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        let recognizedWords = recognizedText.lowercased().components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        
        guard !expectedWords.isEmpty else { return 0.0 }
        
        let matchingWords = expectedWords.filter { word in
            recognizedWords.contains { recognizedWord in
                // Simple similarity check - could be improved with fuzzy matching
                word.contains(recognizedWord) || recognizedWord.contains(word)
            }
        }
        
        return Double(matchingWords.count) / Double(expectedWords.count)
    }
}
