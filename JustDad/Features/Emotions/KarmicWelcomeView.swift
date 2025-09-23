import SwiftUI

struct KarmicWelcomeView: View {
    @ObservedObject var karmicEngine: KarmicEngine
    let onStart: () -> Void
    
    @State private var selectedFocus: KarmicApproach = .secular
    @State private var bondName = ""
    @State private var bondType: KarmicBondType = .exPartner
    @State private var intensity: Int = 3
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "link.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.purple)
                    
                    Text("Vínculos del Pasado")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Liberación de Conexiones Kármicas y Vínculos del Alma")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Selección de enfoque
                VStack(alignment: .leading, spacing: 16) {
                    Text("Enfoque del Ritual")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 16) {
                        KarmicFocusCard(
                            title: "Secular",
                            description: "Enfoque terapéutico y psicológico",
                            isSelected: selectedFocus == .secular,
                            onTap: { selectedFocus = .secular }
                        )
                        
                        KarmicFocusCard(
                            title: "Espiritual",
                            description: "Enfoque energético y transpersonal",
                            isSelected: selectedFocus == .spiritual,
                            onTap: { selectedFocus = .spiritual }
                        )
                    }
                }
                
                // Información del vínculo
                VStack(alignment: .leading, spacing: 16) {
                    Text("Identifica tu Vínculo")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 16) {
                        // Nombre del vínculo
                        VStack(alignment: .leading, spacing: 8) {
                            Text("¿Cómo llamas a esta conexión?")
                                .foregroundColor(.white.opacity(0.9))
                            
                            TextField("Ej: Mi ex-pareja, Mi madre, Mi jefe...", text: $bondName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .foregroundColor(.white)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        // Tipo de vínculo
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tipo de vínculo")
                                .foregroundColor(.white.opacity(0.9))
                            
                            Picker("Tipo", selection: $bondType) {
                                ForEach(KarmicBondType.allCases, id: \.self) { type in
                                    Text(type.displayName).tag(type)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        // Intensidad emocional
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Intensidad emocional")
                                .foregroundColor(.white.opacity(0.9))
                            
                            Picker("Intensidad", selection: $intensity) {
                                ForEach(1...5, id: \.self) { level in
                                    Text("Nivel \(level)").tag(level)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)
                }
                
                // Información del ritual
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sobre este ritual")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        KarmicInfoRow(icon: "clock", text: "Duración: 10-15 minutos")
                        KarmicInfoRow(icon: "mic", text: "Incluye lectura en voz alta")
                        KarmicInfoRow(icon: "shield", text: "Proceso seguro y guiado")
                        KarmicInfoRow(icon: "heart", text: "Liberación emocional profunda")
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                }
                
                // Botón de inicio
                Button(action: {
                    karmicEngine.configureSession(
                        focus: selectedFocus,
                        bondName: bondName.isEmpty ? bondType.displayName : bondName,
                        bondType: bondType,
                        intensity: intensity
                    )
                    
                    // Iniciar el ritual
                    karmicEngine.startKarmicRitual(
                        bondType: bondType,
                        approach: selectedFocus,
                        bondName: bondName.isEmpty ? bondType.displayName : bondName,
                        intensityBefore: intensity
                    )
                    
                    onStart()
                }) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                        Text("Iniciar Ritual de Liberación")
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
                }
                .disabled(bondName.isEmpty)
                .opacity(bondName.isEmpty ? 0.6 : 1.0)
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
    }
}

struct KarmicFocusCard: View {
    let title: String
    let description: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.purple.opacity(0.3) : Color.white.opacity(0.1))
                    .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct KarmicInfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .frame(width: 20)
            
            Text(text)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
    }
}

#Preview {
    KarmicWelcomeView(
        karmicEngine: KarmicEngine(),
        onStart: {}
    )
}
