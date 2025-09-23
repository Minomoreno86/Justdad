//
//  AmarresCleansingView.swift
//  JustDad
//
//  Created by Jorge Vasquez on 2024.
//

import SwiftUI

struct AmarresCleansingView: View {
    @ObservedObject var amarresEngine: AmarresEngine
    @State private var cleansingElements: [String] = []
    @State private var currentElement: String = ""
    @State private var showElementInput: Bool = false
    @State private var currentStep: Int = 0
    
    private let defaultElements = [
        "Sal marina",
        "Incienso de sándalo",
        "Agua bendita",
        "Cristales de cuarzo",
        "Velas blancas",
        "Sahumerio de ruda"
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundColor(.yellow)
                
                Text("Preparación de Elementos")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Selecciona los elementos de limpieza energética que tienes disponibles")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            
            // Progress
            VStack(spacing: 8) {
                Text("Paso \(currentStep + 1) de 3")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ProgressView(value: Double(currentStep), total: 2)
                    .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            .padding(.horizontal)
            
            // Current Step Content
            switch currentStep {
            case 0:
                elementSelectionStep
            case 1:
                preparationStep
            case 2:
                cleansingStep
            default:
                EmptyView()
            }
            
            // Navigation
            HStack(spacing: 20) {
                if currentStep > 0 {
                    Button(action: {
                        currentStep -= 1
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("Anterior")
                        }
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray5))
                        .cornerRadius(20)
                    }
                }
                
                Button(action: {
                    if currentStep < 2 {
                        currentStep += 1
                    } else {
                        completeCleansing()
                    }
                }) {
                    HStack {
                        Text(currentStep < 2 ? "Siguiente" : "Continuar")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                }
                .disabled(currentStep == 0 && cleansingElements.isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(
            LinearGradient(
                colors: [.yellow.opacity(0.1), .orange.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var elementSelectionStep: some View {
        VStack(spacing: 16) {
            Text("Elementos de Limpieza Disponibles")
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(defaultElements, id: \.self) { element in
                        ElementCard(
                            element: element,
                            isSelected: cleansingElements.contains(element)
                        ) {
                            if cleansingElements.contains(element) {
                                cleansingElements.removeAll { $0 == element }
                            } else {
                                cleansingElements.append(element)
                            }
                            amarresEngine.updateCleansingElements(cleansingElements)
                        }
                    }
                    
                    if showElementInput {
                        CustomElementInput(
                            element: $currentElement,
                            onSave: {
                                if !currentElement.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    cleansingElements.append(currentElement)
                                    amarresEngine.updateCleansingElements(cleansingElements)
                                    currentElement = ""
                                    showElementInput = false
                                }
                            },
                            onCancel: {
                                currentElement = ""
                                showElementInput = false
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            if !showElementInput {
                Button(action: {
                    showElementInput = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Agregar Elemento Personalizado")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var preparationStep: some View {
        VStack(spacing: 16) {
            Text("Preparación del Espacio")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 12) {
                AmarresPreparationStep(
                    icon: "house",
                    title: "Limpia el espacio",
                    description: "Asegúrate de que el lugar esté ordenado y tranquilo"
                )
                
                AmarresPreparationStep(
                    icon: "moon",
                    title: "Apaga las luces",
                    description: "Crea un ambiente de calma con luz tenue"
                )
                
                AmarresPreparationStep(
                    icon: "speaker.wave.2",
                    title: "Música relajante",
                    description: "Pon música suave o mantén silencio"
                )
                
                AmarresPreparationStep(
                    icon: "person",
                    title: "Postura cómoda",
                    description: "Siéntate o acuéstate en una posición cómoda"
                )
            }
            .padding(.horizontal)
        }
    }
    
    private var cleansingStep: some View {
        VStack(spacing: 16) {
            Text("Visualización de Limpieza")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Imagina una luz dorada envolviendo cada uno de los elementos seleccionados, purificándolos con energía positiva")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if !cleansingElements.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tus elementos de limpieza:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    ForEach(cleansingElements, id: \.self) { element in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(element)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                .padding(.horizontal)
            }
        }
    }
    
    private func completeCleansing() {
        amarresEngine.transitionToNextState()
    }
}

struct ElementCard: View {
    let element: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "leaf")
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .yellow)
                
                Text(element)
                    .font(.body)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? 
                        LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing) :
                        LinearGradient(colors: [Color(.systemBackground)], startPoint: .leading, endPoint: .trailing)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CustomElementInput: View {
    @Binding var element: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            TextField("Elemento personalizado...", text: $element)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Text("Cancelar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
                
                Button(action: onSave) {
                    Text("Guardar")
                        .font(.caption)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(8)
                }
                .disabled(element.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

struct AmarresPreparationStep: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.yellow)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    AmarresCleansingView(amarresEngine: AmarresEngine())
}
