//
//  ConflictCommunicationComponents.swift
//  JustDad - Conflict Communication Components
//
//  Supporting views for communication training
//

import SwiftUI

// MARK: - Communication Rules View
struct CommunicationRulesView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Rules List
                    rulesListSection
                    
                    // Examples Section
                    examplesSection
                }
                .padding()
            }
            .navigationTitle("Reglas de Comunicación Serena")
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
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Método BIFF")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Breve • Clara • Amable • Firme")
                .font(.headline)
                .foregroundColor(.blue)
            
            Text("Respuestas que protegen tu bienestar y el de tus hijos")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var rulesListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Las 8 Reglas de Oro")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 12) {
                ForEach(ConflictWellnessContentPack.communicationRules) { rule in
                    RuleDetailCard(rule: rule)
                }
            }
        }
    }
    
    private var examplesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ejemplos Prácticos")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ExampleCard(
                    title: "Ataque Personal",
                    attack: "Eres un inútil, nadie te quiere",
                    badResponse: "No, tú eres la que no sirve para nada",
                    goodResponse: "Mañana a las 9 a.m. pasaré a recoger a los niños"
                )
                
                ExampleCard(
                    title: "Acusación Económica",
                    attack: "Nunca pagas lo que debes",
                    badResponse: "Siempre me acusas de lo mismo, tú eres la que gasta mal",
                    goodResponse: "El apoyo mensual se transfirió el día 5; puedes revisarlo en tu cuenta"
                )
                
                ExampleCard(
                    title: "Manipulación con Hijos",
                    attack: "Los niños no quieren verte",
                    badResponse: "Tú los estás manipulando contra mí",
                    goodResponse: "Estaré este sábado a las 10 a.m. en el punto de encuentro"
                )
            }
        }
    }
}

// MARK: - Communication Result View
struct CommunicationResultView: View {
    let result: CommunicationTrainingResult
    let onContinue: () -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Score Header
                    scoreHeaderSection
                    
                    // BIFF Analysis
                    biffAnalysisSection
                    
                    // Feedback
                    feedbackSection
                    
                    // Continue Button
                    continueButton
                }
                .padding()
            }
            .navigationTitle("Resultado")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var scoreHeaderSection: some View {
        VStack(spacing: 12) {
            Image(systemName: result.isSerena ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(result.isSerena ? .green : .orange)
            
            Text(result.isSerena ? "¡Excelente!" : "Buen intento")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Puntuación: \(result.score) puntos")
                .font(.headline)
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(result.isSerena ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var biffAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Análisis BIFF")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                BiffCheckCard(
                    letter: "B",
                    word: "Breve",
                    isChecked: result.isBreve,
                    feedback: result.isBreve ? "Perfecto, respuesta concisa" : "Intenta acortar tu respuesta"
                )
                
                BiffCheckCard(
                    letter: "I",
                    word: "Clara",
                    isChecked: result.isClara,
                    feedback: result.isClara ? "Excelente, información específica" : "Incluye fechas, horas o hechos concretos"
                )
                
                BiffCheckCard(
                    letter: "A",
                    word: "Amable",
                    isChecked: result.isAmable,
                    feedback: result.isAmable ? "Muy bien, tono neutro" : "Evita palabras negativas y preguntas"
                )
                
                BiffCheckCard(
                    letter: "F",
                    word: "Firme",
                    isChecked: result.isFirme,
                    feedback: result.isFirme ? "Perfecto, cierra el tema" : "Termina con punto o palabra de cierre"
                )
            }
        }
    }
    
    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tu Respuesta")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(result.userResponse)
                .font(.body)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
            
            Text("Ejemplo de Respuesta Serena")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(result.example.responseSerena)
                .font(.body)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
        }
    }
    
    private var continueButton: some View {
        Button(action: onContinue) {
            Text("Continuar Practicando")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
}

// MARK: - Supporting Views

struct RuleDetailCard: View {
    let rule: CommunicationRule
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(rule.title)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(rule.description)
                .font(.body)
                .foregroundColor(.primary)
            
            if let example = rule.example {
                Text(example)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

struct ExampleCard: View {
    let title: String
    let attack: String
    let badResponse: String
    let goodResponse: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Ataque:")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                
                Text("\"\(attack)\"")
                    .font(.body)
                    .italic()
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("❌ Respuesta Reactiva:")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                
                Text(badResponse)
                    .font(.body)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("✅ Respuesta Serena:")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
                
                Text(goodResponse)
                    .font(.body)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

struct BiffCheckCard: View {
    let letter: String
    let word: String
    let isChecked: Bool
    let feedback: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(letter)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(isChecked ? Color.green : Color.red)
                    .clipShape(Circle())
                
                Text(word)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            Text(feedback)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    CommunicationRulesView()
}
