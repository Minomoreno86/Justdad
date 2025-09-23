//
//  ConflictChildrenView.swift
//  JustDad - Conflict Children Support View
//
//  Children support and validation tools
//

import SwiftUI

struct ConflictChildrenView: View {
    @StateObject private var service = ConflictWellnessService.shared
    @State private var selectedScript: ChildrenSupportScript?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerSection
                
                // Quick Actions
                quickActionsSection
                
                // Scripts Section
                scriptsSection
                
                // Validation Section
                validationSection
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 50))
                .foregroundColor(.green)
            
            Text("Bienestar de los Hijos")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Protege la salud emocional de tus hijos durante el conflicto")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Acciones Rápidas")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ConflictChildrenQuickActionCard(
                    title: "Validar Emociones",
                    subtitle: "Reconocer sentimientos",
                    icon: "heart.fill",
                    color: .red
                ) {
                    service.recordChildValidation()
                }
                
                ConflictChildrenQuickActionCard(
                    title: "Rutina Estable",
                    subtitle: "Horarios consistentes",
                    icon: "clock.fill",
                    color: .blue
                ) {
                    // TODO: Show routine guide
                }
            }
        }
    }
    
    private var scriptsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Guiones de Apoyo")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 12) {
                ForEach(ConflictWellnessContentPack.childrenSupportScripts) { script in
                    ChildrenScriptCard(script: script)
                }
            }
        }
    }
    
    private var validationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Frases de Validación")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ValidationPhraseCard(
                    phrase: "Lo que sientes es válido. Aquí conmigo estás seguro.",
                    icon: "shield.fill"
                )
                
                ValidationPhraseCard(
                    phrase: "Te quiero y voy a cuidarte. Podemos hablar cuando quieras.",
                    icon: "heart.fill"
                )
                
                ValidationPhraseCard(
                    phrase: "A veces los adultos discuten; tú no tienes la culpa.",
                    icon: "person.fill"
                )
                
                ValidationPhraseCard(
                    phrase: "Entiendo que esto es confuso. No es tu culpa.",
                    icon: "questionmark.circle.fill"
                )
            }
        }
    }
}

struct ConflictChildrenQuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ChildrenScriptCard: View {
    let script: ChildrenSupportScript
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(script.situation)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("❌ No digas:")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                
                Text(script.dontSay)
                    .font(.body)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("✅ Mejor di:")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
                
                Text(script.doSay)
                    .font(.body)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Text(script.explanation)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

struct ValidationPhraseCard: View {
    let phrase: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title2)
            
            Text(phrase)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    ConflictChildrenView()
}
