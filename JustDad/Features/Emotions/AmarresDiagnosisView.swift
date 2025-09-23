//
//  AmarresDiagnosisView.swift
//  JustDad
//
//  Created by Jorge Vasquez on 2024.
//

import SwiftUI

struct AmarresDiagnosisView: View {
    @ObservedObject var amarresEngine: AmarresEngine
    @State private var selectedSymptoms: Set<AmarresSymptom> = []
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "stethoscope")
                    .font(.system(size: 40))
                    .foregroundColor(.purple)
                
                Text("Diagnóstico de Amarres")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Identifica los síntomas que experimentas para personalizar tu ritual de liberación")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            
            // Symptoms Selection
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(AmarresSymptom.allCases, id: \.self) { symptom in
                        SymptomCard(
                            symptom: symptom,
                            isSelected: selectedSymptoms.contains(symptom)
                        ) {
                            if selectedSymptoms.contains(symptom) {
                                selectedSymptoms.remove(symptom)
                            } else {
                                selectedSymptoms.insert(symptom)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Continue Button
            Button(action: {
                amarresEngine.updateSymptoms(Array(selectedSymptoms))
                amarresEngine.transitionToNextState()
            }) {
                HStack {
                    Text("Continuar con el Diagnóstico")
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
            .disabled(selectedSymptoms.isEmpty)
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(
            LinearGradient(
                colors: [.purple.opacity(0.1), .indigo.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct SymptomCard: View {
    let symptom: AmarresSymptom
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: symptom.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .purple)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(symptom.title)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(symptom.description)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? 
                        LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing) :
                        LinearGradient(colors: [Color(.systemBackground)], startPoint: .leading, endPoint: .trailing)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AmarresDiagnosisView(amarresEngine: AmarresEngine())
}
