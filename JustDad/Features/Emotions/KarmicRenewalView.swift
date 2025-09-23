import SwiftUI

struct KarmicRenewalView: View {
    @ObservedObject var karmicEngine: KarmicEngine
    @State private var selectedVow: KarmicBehavioralVow?
    @State private var customVowText = ""
    @State private var vowDuration: KarmicBehavioralVow.VowDuration = .twentyFourHours
    @State private var isCompleted = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Text("Renovación y Compromiso")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Establece un compromiso de comportamiento para consolidar la liberación")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Información sobre el voto
                VStack(alignment: .leading, spacing: 16) {
                    Text("¿Qué es un voto de comportamiento?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Un voto de comportamiento es un compromiso consciente que te ayuda a consolidar la liberación. Es una promesa que te haces a ti mismo para mantenerte en tu nueva energía liberada.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .lineSpacing(4)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                }
                
                // Votos sugeridos
                VStack(alignment: .leading, spacing: 16) {
                    Text("Votos Sugeridos")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    let suggestedVows = karmicEngine.getSuggestedVows()
                    
                    ForEach(suggestedVows, id: \.id) { vow in
                            KarmicVowCard(
                            vow: vow,
                            isSelected: selectedVow?.id == vow.id,
                            onSelect: { selectedVow = vow }
                        )
                    }
                }
                
                // Voto personalizado
                VStack(alignment: .leading, spacing: 16) {
                    Text("O crea tu propio voto")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $customVowText)
                            .frame(minHeight: 100)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        
                        if customVowText.isEmpty {
                            Text("Escribe aquí tu voto personalizado...")
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .allowsHitTesting(false)
                        }
                    }
                    
                    if !customVowText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Button("Usar voto personalizado") {
                            selectedVow = KarmicBehavioralVow(
                                title: "Voto personalizado",
                                duration: vowDuration,
                                category: .selfCare,
                                isCustom: true,
                                reminderDate: nil
                            )
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.purple.opacity(0.8))
                        .cornerRadius(12)
                    }
                }
                
                // Duración del voto
                if selectedVow != nil {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Duración del voto")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Picker("Duración", selection: $vowDuration) {
                            ForEach(VowDuration.allCases, id: \.self) { duration in
                                Text(duration.displayName).tag(duration)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                // Resumen del voto
                if let vow = selectedVow {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tu Compromiso")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Voto:")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            
                            Text(vow.title)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(8)
                            
                            HStack {
                                Text("Duración:")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Spacer()
                                
                                Text(vowDuration.displayName)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.purple)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }
                }
                
                // Botón de confirmación
                if selectedVow != nil && !isCompleted {
                    Button(action: confirmVow) {
                        HStack {
                            Image(systemName: "heart.fill")
                            Text("Confirmar Voto de Comportamiento")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.purple, .indigo],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                }
                
                // Completado
                if isCompleted {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                            .symbolEffect(.bounce)
                        
                        Text("¡Voto establecido!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("Tu compromiso de comportamiento está activo. Recibirás recordatorios para mantenerte en tu nueva energía liberada.")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        Button("Finalizar Ritual") {
                            karmicEngine.completeRenewal()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.green, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                }
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func confirmVow() {
        guard let vow = selectedVow else { return }
        
        let updatedVow = KarmicBehavioralVow(
            title: vow.title,
            duration: vowDuration,
            category: vow.category,
            isCustom: vow.isCustom,
            reminderDate: vow.reminderDate
        )
        
        karmicEngine.setBehavioralVow(updatedVow)
        isCompleted = true
    }
}

struct KarmicVowCard: View {
    let vow: KarmicBehavioralVow
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(vow.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                
                Text(vow.title)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text(vow.duration.displayName)
                        .font(.caption)
                        .foregroundColor(.purple)
                    
                    Spacer()
                    
                    Text("Voto de Comportamiento")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.purple.opacity(0.3) : Color.white.opacity(0.1))
                    .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    KarmicRenewalView(karmicEngine: KarmicEngine())
}
