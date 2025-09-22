import Foundation
import AVFoundation
import Combine

public class AudioPlayerService: NSObject, ObservableObject {
    public static let shared = AudioPlayerService()
    
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var volume: Float = 1.0
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    private override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }
    }
    
    public func playBinauralAudio(frequency: Double = 528.0) {
        // Generate binaural tone
        let sampleRate = 44100.0
        let duration = 60.0 // 1 minute
        let frameCount = UInt32(sampleRate * duration)
        
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        
        let leftChannel = buffer.floatChannelData![0]
        let rightChannel = buffer.floatChannelData![1]
        
        for i in 0..<Int(frameCount) {
            let time = Double(i) / sampleRate
            let leftFreq = frequency
            let rightFreq = frequency + 10.0 // Beat frequency
            
            leftChannel[i] = Float(sin(2.0 * .pi * leftFreq * time) * 0.3)
            rightChannel[i] = Float(sin(2.0 * .pi * rightFreq * time) * 0.3)
        }
        
        // Play the generated audio
        playBuffer(buffer)
    }
    
    public func playAmbientSound(filename: String, volume: Float = 0.5) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "mp3") else {
            print("Audio file not found: \(filename)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.volume = volume
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            isPlaying = true
            duration = audioPlayer?.duration ?? 0
            
            startTimer()
        } catch {
            print("Error playing audio: \(error)")
        }
    }
    
    private func playBuffer(_ buffer: AVAudioPCMBuffer) {
        // For binaural audio, we'll use a simpler approach with system sounds
        // In a real implementation, you'd use AVAudioEngine for more control
        playAmbientSound(filename: "silence", volume: 0.1) // Placeholder
    }
    
    public func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentTime = 0
        stopTimer()
    }
    
    public func pauseAudio() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
    }
    
    public func resumeAudio() {
        audioPlayer?.play()
        isPlaying = true
        startTimer()
    }
    
    public func setVolume(_ volume: Float) {
        self.volume = max(0.0, min(1.0, volume))
        audioPlayer?.volume = self.volume
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.currentTime = self?.audioPlayer?.currentTime ?? 0
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension AudioPlayerService: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        currentTime = 0
        stopTimer()
    }
    
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio decode error: \(error?.localizedDescription ?? "Unknown error")")
        isPlaying = false
        stopTimer()
    }
}
