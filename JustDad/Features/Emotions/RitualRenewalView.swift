import SwiftUI

struct RitualRenewalView: View {
    @ObservedObject var ritualEngine: RitualEngine
    @State private var selectedVow: BehavioralVow?
    @State private var customVow = ""
    @State private var selectedDuration: VowDuration = .twentyFourHours
    @State private var selectedTime = Date()
    @State private var isRecording = false
    @State private var vowConfirmed = false
    
    var body: some View {
        VStack(spacing: 20) {
            titleSection
            contentSection
            confirmationSection
            Spacer()
            actionButtons
        }
    }
    
    // MARK: - View Components
    private var titleSection: some View {
        VStack(spacing: 12) {
            Text("Renovación")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Elige un voto conductual para los próximos días")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }
    
    private var contentSection: some View {
        ScrollView {
            VStack(spacing: 24) {
                suggestedVowsSection
                customVowSection
                if selectedVow != nil {
                    durationSection
                    deadlineSection
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var suggestedVowsSection: some View {
        VStack(spacing: 16) {
            Text("Votos Sugeridos")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(RitualContentPack.renewalVows, id: \.id) { vow in
                    VowCard(
                        vow: vow,
                        isSelected: selectedVow?.id == vow.id,
                        action: { selectedVow = vow }
                    )
                }
            }
        }
    }
    
    private var customVowSection: some View {
        VStack(spacing: 12) {
            Text("O crea tu propio voto")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("Escribe tu voto personalizado...", text: $customVow, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
            
            if !customVow.isEmpty {
                Button(action: {
                    selectedVow = BehavioralVow(
                        title: "Voto Personalizado",
                        description: customVow,
                        category: .custom,
                        isCustom: true
                    )
                }) {
                    Text("Usar Voto Personalizado")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.blue)
                        )
                }
            }
        }
    }
    
    private var durationSection: some View {
        VStack(spacing: 12) {
            Text("Duración del compromiso")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 8) {
                ForEach(VowDuration.allCases, id: \.self) { duration in
                    Button(action: {
                        selectedDuration = duration
                    }) {
                        HStack {
                            Text(duration.displayName)
                                .font(.body)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            if selectedDuration == duration {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Circle()
                                    .stroke(.white.opacity(0.3), lineWidth: 2)
                                    .frame(width: 20, height: 20)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedDuration == duration ? Color.green.opacity(0.2) : Color.clear)
                                .background(.ultraThinMaterial)
                        )
                    }
                }
            }
        }
    }
    
    private var deadlineSection: some View {
        VStack(spacing: 12) {
            Text("Completar antes de:")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            DatePicker(
                "Hora límite",
                selection: $selectedTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.compact)
            .colorScheme(.dark)
        }
    }
    
    private var confirmationSection: some View {
        Group {
            if let vow = selectedVow, vowConfirmed {
                VowConfirmationView(
                    vow: vow,
                    duration: selectedDuration,
                    deadline: selectedTime
                )
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            if selectedVow != nil && !vowConfirmed {
                confirmButton
            }
            
            if vowConfirmed && selectedVow != nil {
                VowRecordingSection(
                    vow: selectedVow!,
                    isRecording: $isRecording,
                    onComplete: {
                        ritualEngine.completeRenewal(
                            vow: selectedVow!,
                            duration: selectedDuration,
                            deadline: selectedTime
                        )
                    }
                )
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var confirmButton: some View {
        Button(action: {
            vowConfirmed = true
        }) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                
                Text("Confirmar Voto")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Vow Card
struct VowCard: View {
    let vow: BehavioralVow
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: vow.category.icon)
                        .font(.title3)
                        .foregroundColor(vow.category.color)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.green)
                    }
                }
                
                Text(vow.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Text(vow.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
            }
            .padding()
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? vow.category.color.opacity(0.2) : Color.clear)
                    .background(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? vow.category.color : .clear, lineWidth: 2)
                    )
            )
        }
    }
}

// MARK: - Vow Confirmation View
struct VowConfirmationView: View {
    let vow: BehavioralVow
    let duration: VowDuration
    let deadline: Date
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Tu Compromiso")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: vow.category.icon)
                        .foregroundColor(vow.category.color)
                    
                    Text(vow.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                Text(vow.description)
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text("Duración:")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(duration.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Antes de:")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(deadline, style: .time)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
        }
    }
}

// MARK: - Vow Recording Section
struct VowRecordingSection: View {
    let vow: BehavioralVow
    @Binding var isRecording: Bool
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Confirma tu voto en voz alta")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Me comprometo a: \(vow.description)")
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
            
            Button(action: {
                if isRecording {
                    onComplete()
                } else {
                    isRecording = true
                    // Simular grabación
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        onComplete()
                    }
                }
            }) {
                HStack {
                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.title3)
                    
                    Text(isRecording ? "Grabando..." : "Graba tu compromiso")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: isRecording ? [.red, .orange] : [.green, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Vow Duration Extension
extension VowDuration {
    var displayName: String {
        switch self {
        case .twentyFourHours:
            return "24 horas"
        case .fortyEightHours:
            return "48 horas"
        case .seventyTwoHours:
            return "72 horas"
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        LinearGradient(
            colors: [.purple.opacity(0.8), .indigo.opacity(0.6), .black],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        RitualRenewalView(ritualEngine: RitualEngine())
    }
}
