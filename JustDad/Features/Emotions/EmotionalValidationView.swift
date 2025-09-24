//
//  EmotionalValidationView.swift
//  JustDad - Emotional Validation Component
//
//  Componente para validación emocional en técnicas de liberación
//

import SwiftUI

struct EmotionalValidationView: View {
    @Binding var emotionalIntensity: HybridLiberationService.EmotionalIntensity
    @Binding var isReadyToContinue: Bool
    let technique: HybridLiberationService.HybridTechnique
    let stepTitle: String
    
    @State private var selectedIntensity: HybridLiberationService.EmotionalIntensity = .neutral
    @State private var emotionalNotes: String = ""
    @State private var showingPauseOptions = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 40))
                    .foregroundColor(technique.color)
                
                Text("Validación Emocional")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("¿Cómo te sientes en este momento?")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(technique.color.opacity(0.1))
            )
            
            // Emotional Intensity Selector
            VStack(alignment: .leading, spacing: 16) {
                Text("Intensidad Emocional")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    ForEach(HybridLiberationService.EmotionalIntensity.allCases, id: \.self) { intensity in
                        EmotionalIntensityCard(
                            intensity: intensity,
                            isSelected: selectedIntensity == intensity,
                            onSelect: {
                                selectedIntensity = intensity
                                emotionalIntensity = intensity
                                checkReadiness()
                            }
                        )
                    }
                }
            }
            
            // Emotional Notes
            VStack(alignment: .leading, spacing: 12) {
                Text("Notas Emocionales (Opcional)")
                    .font(.headline)
                
                TextEditor(text: $emotionalNotes)
                    .frame(minHeight: 80)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
            
            // Validation Status
            if isReadyToContinue {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Listo para continuar")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Text("Tu estado emocional es apropiado para continuar con esta técnica")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green.opacity(0.1))
                )
            } else if selectedIntensity == .veryHigh {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Intensidad muy alta")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Text("Te recomendamos tomar una pausa o usar técnicas de calma antes de continuar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Ver opciones de pausa") {
                        showingPauseOptions = true
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange.opacity(0.1))
                )
            }
            
            // Continue Button
            Button(action: {
                isReadyToContinue = true
            }) {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                    Text("Continuar")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isReadyToContinue ? technique.color : Color.gray)
                )
            }
            .disabled(!isReadyToContinue)
        }
        .sheet(isPresented: $showingPauseOptions) {
            PauseOptionsView(technique: technique)
        }
        .onAppear {
            selectedIntensity = emotionalIntensity
            checkReadiness()
        }
    }
    
    private func checkReadiness() {
        isReadyToContinue = selectedIntensity != .veryHigh
    }
}

// MARK: - Emotional Intensity Card
struct EmotionalIntensityCard: View {
    let intensity: HybridLiberationService.EmotionalIntensity
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Intensity Indicator
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { index in
                        Circle()
                            .fill(index <= intensityLevel ? intensity.color : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(intensity.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(intensity.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(intensity.color)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? intensity.color.opacity(0.1) : Color.gray.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? intensity.color : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var intensityLevel: Int {
        switch intensity {
        case .veryLow: return 1
        case .low: return 2
        case .neutral: return 3
        case .high: return 4
        case .veryHigh: return 5
        }
    }
}

// MARK: - Pause Options View
struct PauseOptionsView: View {
    let technique: HybridLiberationService.HybridTechnique
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Opciones de Pausa")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Tómate el tiempo que necesites para calmar tu estado emocional")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.orange.opacity(0.1))
                    )
                    
                    // Calming Techniques
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Técnicas de Calma")
                            .font(.headline)
                        
                        ForEach(calmingTechniques, id: \.name) { technique in
                            CalmingTechniqueCard(technique: technique)
                        }
                    }
                    
                    // Continue Button
                    Button("Continuar cuando estés listo") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(technique.color)
                }
                .padding()
            }
            .navigationTitle("Pausa Emocional")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var calmingTechniques: [CalmingTechnique] {
        [
            CalmingTechnique(
                name: "Respiración Profunda",
                description: "Técnica de respiración 4-7-8 para calmar el sistema nervioso",
                duration: "5-10 min",
                icon: "lungs.fill",
                color: .blue
            ),
            CalmingTechnique(
                name: "Meditación Guiada",
                description: "Meditación de atención plena para centrar la mente",
                duration: "10-15 min",
                icon: "brain.head.profile",
                color: .purple
            ),
            CalmingTechnique(
                name: "Relajación Muscular",
                description: "Tensión y relajación progresiva de grupos musculares",
                duration: "15-20 min",
                icon: "figure.walk",
                color: .green
            ),
            CalmingTechnique(
                name: "Visualización",
                description: "Imagina un lugar seguro y tranquilo",
                duration: "5-10 min",
                icon: "eye.fill",
                color: .orange
            )
        ]
    }
}

// MARK: - Calming Technique Model
struct CalmingTechnique {
    let name: String
    let description: String
    let duration: String
    let icon: String
    let color: Color
}

// MARK: - Calming Technique Card
struct CalmingTechniqueCard: View {
    let technique: CalmingTechnique
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: technique.icon)
                .font(.title2)
                .foregroundColor(technique.color)
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(technique.color.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(technique.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(technique.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(technique.duration)
                .font(.caption)
                .foregroundColor(technique.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(technique.color.opacity(0.1))
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

#Preview {
    EmotionalValidationView(
        emotionalIntensity: .constant(.neutral),
        isReadyToContinue: .constant(false),
        technique: .forgivenessTherapy,
        stepTitle: "Paso 1: Preparación"
    )
    .padding()
}


