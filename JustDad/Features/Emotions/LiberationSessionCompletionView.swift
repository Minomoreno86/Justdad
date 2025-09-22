//
//  LiberationSessionCompletionView.swift
//  JustDad - Liberation Session Completion View
//
//  Vista para completar y evaluar una sesión de liberación
//

import SwiftUI

struct LiberationSessionCompletionView: View {
    let technique: LiberationService.LiberationTechnique
    @Binding var notes: String
    @Binding var progress: Int
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("¡Sesión Completada!")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("¿Cómo te sientes después de esta técnica de liberación?")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.green.opacity(0.1))
                    )
                    
                    // Progress Slider
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Progreso de Liberación")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Muy bajo")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("\(progress)/10")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(technique.color)
                                
                                Spacer()
                                
                                Text("Muy alto")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Slider(value: Binding(
                                get: { Double(progress) },
                                set: { progress = Int($0) }
                            ), in: 1...10, step: 1)
                            .tint(technique.color)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.systemGray6))
                    )
                    
                    // Notes Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Reflexiones de la Sesión")
                            .font(.headline)
                        
                        TextEditor(text: $notes)
                            .frame(minHeight: 120)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(UIColor.systemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        
                        Text("Comparte tus pensamientos, emociones o insights de esta sesión de liberación.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.systemGray6))
                    )
                    
                    // Completion Button
                    Button(action: {
                        onComplete()
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                            Text("Guardar Sesión")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(technique.color)
                        )
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Completar Sesión")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    LiberationSessionCompletionView(
        technique: .forgivenessTherapy,
        notes: .constant(""),
        progress: .constant(5),
        onComplete: {}
    )
}
