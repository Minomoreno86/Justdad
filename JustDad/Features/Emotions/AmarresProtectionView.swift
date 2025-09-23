//
//  AmarresProtectionView.swift
//  JustDad
//
//  Created by Jorge Vasquez on 2024.
//

import SwiftUI

struct AmarresProtectionView: View {
    @ObservedObject var amarresEngine: AmarresEngine
    @State private var selectedVow: ProtectionVow?
    @State private var customVowText: String = ""
    @State private var showCustomVow: Bool = false
    
    private let suggestedVows = [
        ProtectionVow(
            title: "Protección Diaria",
            description: "Renovaré mi protección energética cada día al despertar",
            duration: .daily
        ),
        ProtectionVow(
            title: "Protección Semanal",
            description: "Mantendré mi escudo energético activo durante toda la semana",
            duration: .weekly
        ),
        ProtectionVow(
            title: "Protección Permanente",
            description: "Sellaré mi campo energético con protección permanente",
            duration: .permanent
        )
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text("Protección Energética")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Establece un compromiso de protección para mantener tu campo energético limpio")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            
            // Instructions
            VStack(spacing: 8) {
                Text("Selecciona un voto de protección que te comprometas a cumplir")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Este compromiso te ayudará a mantener tu energía protegida después del ritual")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            // Protection Vows
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(suggestedVows, id: \.title) { vow in
                        ProtectionVowCard(
                            vow: vow,
                            isSelected: selectedVow?.title == vow.title
                        ) {
                            selectedVow = vow
                            showCustomVow = false
                        }
                    }
                    
                    // Custom Vow Option
                    Button(action: {
                        showCustomVow = true
                        selectedVow = nil
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.blue)
                            Text("Crear Voto Personalizado")
                                .foregroundColor(.blue)
                            Spacer()
                            Image(systemName: showCustomVow ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(showCustomVow ? .blue : .gray)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(showCustomVow ? 
                                    LinearGradient(colors: [.blue.opacity(0.1), .cyan.opacity(0.1)], startPoint: .leading, endPoint: .trailing) :
                                    LinearGradient(colors: [Color(.systemBackground)], startPoint: .leading, endPoint: .trailing)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Custom Vow Input
                    if showCustomVow {
                        CustomVowInput(
                            customVowText: $customVowText,
                            onSave: {
                                if !customVowText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    let customVow = ProtectionVow(
                                        title: "Voto Personalizado",
                                        description: customVowText,
                                        duration: .daily
                                    )
                                    selectedVow = customVow
                                }
                            },
                            onCancel: {
                                customVowText = ""
                                showCustomVow = false
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Selected Vow Display
            if let vow = selectedVow {
                VStack(spacing: 8) {
                    Text("Tu Compromiso de Protección")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(vow.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                    
                    Text("Duración: \(vow.duration.displayName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }
            
            // Continue Button
            Button(action: {
                if let vow = selectedVow {
                    amarresEngine.setProtectionVow(vow)
                    amarresEngine.scheduleProtectionReminder()
                }
                amarresEngine.transitionToNextState()
            }) {
                HStack {
                    Text("Establecer Protección")
                    Image(systemName: "arrow.right")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.blue, .cyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .disabled(selectedVow == nil)
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.1), .cyan.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct ProtectionVowCard: View {
    let vow: ProtectionVow
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "shield")
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : .blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(vow.title)
                            .font(.headline)
                            .foregroundColor(isSelected ? .white : .primary)
                        
                        Text("Duración: \(vow.duration.displayName)")
                            .font(.caption)
                            .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : .gray)
                }
                
                Text(vow.description)
                    .font(.body)
                    .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? 
                        LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing) :
                        LinearGradient(colors: [Color(.systemBackground)], startPoint: .leading, endPoint: .trailing)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CustomVowInput: View {
    @Binding var customVowText: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            TextField("Describe tu compromiso de protección...", text: $customVowText, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
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
                                colors: [.blue, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(8)
                }
                .disabled(customVowText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
    AmarresProtectionView(amarresEngine: AmarresEngine())
}
