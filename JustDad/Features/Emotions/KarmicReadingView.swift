import SwiftUI

struct KarmicReadingView: View {
    @ObservedObject var karmicEngine: KarmicEngine
    let block: KarmicReadingBlock
    
    @State private var isReading = false
    @State private var validationResult: KarmicVoiceValidation?
    @State private var showingValidationResult = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Text(block.displayName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(getBlockDescription())
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Texto del bloque
                VStack(alignment: .leading, spacing: 16) {
                    Text("Texto para leer en voz alta:")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(getBlockText())
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .lineSpacing(6)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                }
                
                // Anclas de voz
                VStack(alignment: .leading, spacing: 16) {
                    Text("Anclas de voz importantes:")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 12) {
                        ForEach(getVoiceAnchors(), id: \.self) { anchor in
                            HStack {
                                Image(systemName: "quote.bubble")
                                    .foregroundColor(.purple)
                                
                                Text("\"\(anchor)\"")
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .italic()
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(8)
                        }
                    }
                }
                
                // Instrucciones
                VStack(alignment: .leading, spacing: 12) {
                    Text("Instrucciones:")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        InstructionRow(number: 1, text: "Lee el texto completo en voz alta")
                        InstructionRow(number: 2, text: "Asegúrate de incluir las anclas de voz")
                        InstructionRow(number: 3, text: "Habla con claridad y intención")
                        InstructionRow(number: 4, text: "El sistema validará tu lectura")
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                }
                
                // Botón de lectura
                if !isReading && !showingValidationResult {
                    Button(action: startReading) {
                        HStack {
                            Image(systemName: "mic.fill")
                            Text("Comenzar Lectura en Voz Alta")
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
                
                // Estado de lectura
                if isReading {
                    VStack(spacing: 16) {
                        Image(systemName: "mic.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                            .symbolEffect(.pulse)
                        
                        Text("Leyendo...")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Habla claramente y asegúrate de incluir las anclas de voz")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                        
                        Button("Finalizar Lectura") {
                            stopReading()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(16)
                    }
                }
                
                // Resultado de validación
                if showingValidationResult, let result = validationResult {
                    VStack(spacing: 16) {
                        if result.success {
                            VStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.green)
                                
                                Text("¡Lectura exitosa!")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                
                                Text("Validación: \(Int(result.validationPercentage * 100))%")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.orange)
                                
                                Text("Lectura incompleta")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                                
                                Text("Necesitas incluir más anclas de voz")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                        }
                        
                        Button(result.success ? "Continuar" : "Intentar de nuevo") {
                            if result.success {
                                karmicEngine.completeReadingBlock(block)
                            } else {
                                showingValidationResult = false
                                isReading = false
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: result.success ? [.green, .blue] : [.orange, .red],
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
    
    private func getBlockDescription() -> String {
        switch block {
        case .recognition:
            return "Reconoce la presencia y el impacto de este vínculo"
        case .liberation:
            return "Libera la energía atrapada en esta conexión"
        case .returning:
            return "Devuelve la energía que no te pertenece"
        }
    }
    
    private func getBlockText() -> String {
        guard karmicEngine.currentSession != nil else {
            return "Texto no disponible"
        }
        
        let script = karmicEngine.getCurrentScript()
        
        switch block {
        case .recognition:
            return script.recognitionBlock.text
        case .liberation:
            return script.liberationBlock.text
        case .returning:
            return script.returningBlock.text
        }
    }
    
    private func getVoiceAnchors() -> [String] {
        guard karmicEngine.currentSession != nil else {
            return []
        }
        
        let script = karmicEngine.getCurrentScript()
        
        switch block {
        case .recognition:
            return script.recognitionBlock.voiceAnchors
        case .liberation:
            return script.liberationBlock.voiceAnchors
        case .returning:
            return script.returningBlock.voiceAnchors
        }
    }
    
    private func startReading() {
        isReading = true
        karmicEngine.startVoiceValidation(for: block)
    }
    
    private func stopReading() {
        isReading = false
        validationResult = karmicEngine.stopVoiceValidation(for: block)
        showingValidationResult = true
    }
}

struct InstructionRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.purple)
                .clipShape(Circle())
            
            Text(text)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
    }
}

#Preview {
    KarmicReadingView(karmicEngine: KarmicEngine(), block: .recognition)
}
