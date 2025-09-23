import SwiftUI

struct KarmicEvocationView: View {
    @ObservedObject var karmicEngine: KarmicEngine
    @State private var evocationText = ""
    @State private var isCompleted = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Text("Evocación del Vínculo")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Conecta conscientemente con la energía de este vínculo")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Información del vínculo
                if let session = karmicEngine.currentSession {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Vínculo identificado:")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text(session.bondName)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.purple)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tipo:")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text(session.bondType.displayName)
                                .font(.body)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Intensidad:")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("Intensidad: \(session.intensityBefore)")
                                .font(.body)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)
                }
                
                // Texto de evocación
                VStack(alignment: .leading, spacing: 16) {
                    Text("Guía de Evocación")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(getEvocationScript())
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .lineSpacing(4)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                }
                
                // Campo de texto personalizado
                VStack(alignment: .leading, spacing: 16) {
                    Text("Expresa tu conexión")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Escribe libremente sobre cómo sientes esta conexión en tu vida:")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $evocationText)
                            .frame(minHeight: 120)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        
                        if evocationText.isEmpty {
                            Text("Escribe aquí tu conexión con este vínculo...")
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .allowsHitTesting(false)
                        }
                    }
                }
                
                if !isCompleted {
                    Button("Continuar con la Evocación") {
                        karmicEngine.updateEvocationText(evocationText)
                        isCompleted = true
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
                    .disabled(evocationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(evocationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
                } else {
                    VStack(spacing: 16) {
                        Text("¡Evocación completada!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("Ahora procederemos con la liberación")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Button("Continuar al Reconocimiento") {
                            karmicEngine.completeEvocation()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.green, .blue],
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
    
    private func getEvocationScript() -> String {
        guard let session = karmicEngine.currentSession else {
            return "Conecta con la energía de este vínculo..."
        }
        
        return """
        En este momento, me permito reconocer la presencia de esta conexión en mi vida. 
        
        \(session.bondName) ha sido una fuerza significativa en mi experiencia, y ahora elijo 
        enfrentar esta conexión con valentía y compasión.
        
        Siento cómo esta energía se manifiesta en mi cuerpo, en mis emociones y en mis pensamientos. 
        No la juzgo, simplemente la reconozco.
        
        Este es el primer paso hacia la liberación: el reconocimiento consciente de lo que existe.
        """
    }
}

#Preview {
    KarmicEvocationView(karmicEngine: KarmicEngine())
}
