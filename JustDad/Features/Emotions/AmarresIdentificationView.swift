//
//  AmarresIdentificationView.swift
//  JustDad
//
//  Created by Jorge Vasquez on 2024.
//

import SwiftUI

struct AmarresIdentificationView: View {
    @ObservedObject var amarresEngine: AmarresEngine
    @State private var bindings: [String] = []
    @State private var newBinding: String = ""
    @State private var showAddBinding: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "link")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
                
                Text("Identificación de Amarres")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Identifica las conexiones energéticas que necesitas liberar")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            
            // Instructions
            VStack(spacing: 8) {
                Text("¿Con quién o qué sientes que tienes una conexión energética que te limita?")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Puede ser una persona, situación, lugar o patrón de comportamiento")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            // Bindings List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(Array(bindings.enumerated()), id: \.offset) { index, binding in
                        BindingCard(
                            binding: binding,
                            onRemove: {
                                bindings.remove(at: index)
                                amarresEngine.updateBindings(bindings)
                            }
                        )
                    }
                    
                    if showAddBinding {
                        AddBindingCard(
                            binding: $newBinding,
                            onSave: {
                                if !newBinding.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    bindings.append(newBinding)
                                    amarresEngine.updateBindings(bindings)
                                    newBinding = ""
                                    showAddBinding = false
                                }
                            },
                            onCancel: {
                                newBinding = ""
                                showAddBinding = false
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Add Binding Button
            if !showAddBinding {
                Button(action: {
                    showAddBinding = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Agregar Conexión")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.red, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                }
            }
            
            // Continue Button
            Button(action: {
                amarresEngine.transitionToNextState()
            }) {
                HStack {
                    Text("Continuar con la Identificación")
                    Image(systemName: "arrow.right")
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
                .cornerRadius(12)
            }
            .disabled(bindings.isEmpty)
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(
            LinearGradient(
                colors: [.red.opacity(0.1), .pink.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct BindingCard: View {
    let binding: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "link.circle")
                .font(.title2)
                .foregroundColor(.red)
            
            Text(binding)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.red)
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

struct AddBindingCard: View {
    @Binding var binding: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            TextField("Describe la conexión energética...", text: $binding)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Text("Cancelar")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
                
                Button(action: onSave) {
                    Text("Guardar")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.red, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(8)
                }
                .disabled(binding.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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

#Preview {
    AmarresIdentificationView(amarresEngine: AmarresEngine())
}
