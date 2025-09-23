import SwiftUI

struct RitualVerbalizationView: View {
    @ObservedObject var ritualEngine: RitualEngine
    @State private var currentBlock: VerbalizationBlock = .recognition
    @State private var completedBlocks: Set<VerbalizationBlock> = []
    @State private var isRecording = false
    @State private var validationResults: [VerbalizationBlock: RitualVoiceValidationResult] = [:]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Título
                VStack(spacing: 12) {
                    Text("Verbalización Terapéutica")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Lee en voz alta cada bloque para continuar")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                // Indicador de progreso
                VerbalizationProgressView(
                    currentBlock: currentBlock,
                    completedBlocks: completedBlocks
                )
                .padding(.horizontal, 20)
                
                // Bloque actual
                VerbalizationBlockView(
                    block: currentBlock,
                    isActive: true,
                    validationResult: validationResults[currentBlock],
                    isRecording: isRecording,
                    onRecordingStart: { startRecording() },
                    onRecordingComplete: { result in
                        validationResults[currentBlock] = result
                        if result.isValid {
                            completedBlocks.insert(currentBlock)
                            moveToNextBlock()
                        }
                    }
                )
                .padding(.horizontal, 20)
                
                // Bloques completados
                if !completedBlocks.isEmpty {
                    VStack(spacing: 12) {
                        Text("Bloques Completados")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(completedBlocks), id: \.self) { block in
                                    CompletedBlockCard(block: block)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                
                Spacer()
                
                // Botón de continuar (solo si todos los bloques están completados)
                if completedBlocks.count == VerbalizationBlock.allCases.count {
                    Button(action: {
                        ritualEngine.completeVerbalization(validationResults)
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                            
                            Text("Continuar al Corte")
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
            .padding(.bottom, 20) // Agregar padding al final para que no se corte
        }
    }
    
    private func startRecording() {
        isRecording = true
        // TODO: Implementar grabación real
    }
    
    private func moveToNextBlock() {
        guard let currentIndex = VerbalizationBlock.allCases.firstIndex(of: currentBlock) else { return }
        
        if currentIndex < VerbalizationBlock.allCases.count - 1 {
            currentBlock = VerbalizationBlock.allCases[currentIndex + 1]
        }
    }
}

// MARK: - Verbalization Progress View
struct VerbalizationProgressView: View {
    let currentBlock: VerbalizationBlock
    let completedBlocks: Set<VerbalizationBlock>
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(VerbalizationBlock.allCases, id: \.self) { block in
                VStack(spacing: 4) {
                    Circle()
                        .fill(blockColor(block))
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(.white, lineWidth: 2)
                                .opacity(block == currentBlock ? 1.0 : 0.0)
                        )
                    
                    Text(block.displayName)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.clear)
                .background(.ultraThinMaterial)
        )
    }
    
    private func blockColor(_ block: VerbalizationBlock) -> Color {
        if completedBlocks.contains(block) {
            return .green
        } else if block == currentBlock {
            return .orange
        } else {
            return .white.opacity(0.3)
        }
    }
}

// MARK: - Verbalization Block View
struct VerbalizationBlockView: View {
    let block: VerbalizationBlock
    let isActive: Bool
    let validationResult: RitualVoiceValidationResult?
    let isRecording: Bool
    let onRecordingStart: () -> Void
    let onRecordingComplete: (RitualVoiceValidationResult) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Título del bloque
            VStack(spacing: 8) {
                Text(block.displayName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(block.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            // Texto a leer
            ScrollView {
                Text(block.text)
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.clear)
                .background(.ultraThinMaterial)
            )
            
            // Frases clave
            VStack(spacing: 8) {
                Text("Frases clave a pronunciar:")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                
                ForEach(block.keyPhrases, id: \.self) { phrase in
                    HStack {
                        Image(systemName: "quote.bubble")
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text(phrase)
                            .font(.caption)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white.opacity(0.1))
                    )
                }
            }
            
            // Estado de validación
            if let result = validationResult {
                ValidationResultView(result: result)
            }
            
            // Botón de grabación
            if validationResult?.isValid != true {
                Button(action: {
                    if isRecording {
                        // Simular finalización de grabación con porcentaje suficiente
                        let simulatedResult = RitualVoiceValidationResult(
                            block: block,
                            validatedAnchors: ["te reconozco", "te perdono", "te libero"], // 3 de 3 = 100%
                            totalAnchors: 3,
                            isValid: true,
                            missingPhrases: []
                        )
                        onRecordingComplete(simulatedResult)
                    } else {
                        onRecordingStart()
                    }
                }) {
                    HStack {
                        Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.title3)
                        
                        Text(isRecording ? "Detener Grabación" : "Grabar Lectura")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: isRecording ? [.red, .orange] : [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isActive ? Color.blue.opacity(0.2) : Color.clear)
                .background(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isActive ? .blue : .clear, lineWidth: 2)
                )
        )
    }
}

// MARK: - Completed Block Card
struct CompletedBlockCard: View {
    let block: VerbalizationBlock
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundColor(.green)
            
            Text(block.displayName)
                .font(.caption)
                .foregroundColor(.white)
                .fontWeight(.medium)
        }
        .frame(width: 80, height: 60)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.green.opacity(0.2))
        )
    }
}

// MARK: - Validation Result View
struct ValidationResultView: View {
    let result: RitualVoiceValidationResult
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: result.isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(result.isValid ? .green : .red)
                
                Text(result.isValid ? "Validación exitosa" : "Faltan frases clave")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            
            if !result.isValid && !result.missingPhrases.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Frases faltantes:")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    ForEach(result.missingPhrases, id: \.self) { phrase in
                        Text("• \(phrase)")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(result.isValid ? .green.opacity(0.2) : .red.opacity(0.2))
        )
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        CosmicBackgroundView()
        RitualVerbalizationView(ritualEngine: RitualEngine())
    }
}