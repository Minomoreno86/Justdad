import SwiftUI

struct BreathingRepetitionControl: View {
    @Binding var repetitions: Int
    @Binding var currentRepetition: Int
    let isActive: Bool
    
    private let maxRepetitions = 10
    private let minRepetitions = 1
    
    var body: some View {
        VStack(spacing: 16) {
            repetitionCounterView
            progressBarView
            if !isActive {
                repetitionSelectorView
            }
        }
        .padding()
        .background(backgroundView)
    }
    
    private var repetitionCounterView: some View {
        HStack(spacing: 12) {
            Image(systemName: "repeat.circle.fill")
                .font(.title2)
                .foregroundColor(.cyan)
            
            Text("Repetición \(currentRepetition) de \(repetitions)")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
    
    private var progressBarView: some View {
        ProgressView()
            .progressViewStyle(LinearProgressViewStyle(tint: .cyan))
            .scaleEffect(x: 1, y: 2, anchor: .center)
            .background(Color.white.opacity(0.2))
            .cornerRadius(4)
    }
    
    private var repetitionSelectorView: some View {
        HStack(spacing: 20) {
            Text("Repeticiones:")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            HStack(spacing: 12) {
                minusButton
                repetitionCounter
                plusButton
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(selectorBackground)
    }
    
    private var minusButton: some View {
        Button(action: {
            if repetitions > minRepetitions {
                repetitions -= 1
                currentRepetition = 1
            }
        }) {
            Image(systemName: "minus.circle.fill")
                .font(.title2)
                .foregroundColor(repetitions > minRepetitions ? .cyan : .gray)
        }
        .disabled(repetitions <= minRepetitions)
    }
    
    private var repetitionCounter: some View {
        Text("\(repetitions)")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(minWidth: 30)
    }
    
    private var plusButton: some View {
        Button(action: {
            if repetitions < maxRepetitions {
                repetitions += 1
                currentRepetition = 1
            }
        }) {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundColor(repetitions < maxRepetitions ? .cyan : .gray)
        }
        .disabled(repetitions >= maxRepetitions)
    }
    
    private var selectorBackground: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
            )
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.black.opacity(0.3))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.cyan.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Breathing Session Manager

class BreathingSessionManager: ObservableObject {
    @Published var repetitions: Int = 3
    @Published var currentRepetition: Int = 1
    @Published var isSessionActive: Bool = false
    @Published var sessionCompleted: Bool = false
    
    private var breathingTimer: Timer?
    private var cycleCount: Int = 0
    private let totalCyclesPerRepetition = 1 // One complete breathing cycle per repetition
    
    func startSession() {
        isSessionActive = true
        sessionCompleted = false
        currentRepetition = 1
        cycleCount = 0
        startBreathingCycle()
    }
    
    func stopSession() {
        isSessionActive = false
        breathingTimer?.invalidate()
        breathingTimer = nil
    }
    
    func resetSession() {
        stopSession()
        currentRepetition = 1
        cycleCount = 0
        sessionCompleted = false
    }
    
    private func startBreathingCycle() {
        // Each breathing cycle is 22 seconds (6+4+8+4)
        breathingTimer = Timer.scheduledTimer(withTimeInterval: 22.0, repeats: true) { _ in
            self.completeBreathingCycle()
        }
    }
    
    private func completeBreathingCycle() {
        cycleCount += 1
        
        if cycleCount >= totalCyclesPerRepetition {
            // Complete current repetition
            currentRepetition += 1
            
            if currentRepetition > repetitions {
                // Session completed
                completeSession()
            } else {
                // Start next repetition
                cycleCount = 0
            }
        }
    }
    
    private func completeSession() {
        stopSession()
        sessionCompleted = true
        currentRepetition = repetitions
    }
    
    var progressPercentage: Double {
        guard repetitions > 0 else { return 0 }
        return Double(currentRepetition - 1) / Double(repetitions)
    }
    
    var isLastRepetition: Bool {
        return currentRepetition >= repetitions
    }
}

#Preview {
    ZStack {
        CosmicBackgroundView()
        
        VStack(spacing: 20) {
            BreathingRepetitionControl(
                repetitions: .constant(5),
                currentRepetition: .constant(2),
                isActive: false
            )
            
            BreathingRepetitionControl(
                repetitions: .constant(3),
                currentRepetition: .constant(3),
                isActive: true
            )
        }
        .padding()
    }
}
