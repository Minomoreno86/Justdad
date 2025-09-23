//
//  AmarresMainView.swift
//  JustDad - Vista Principal del Módulo de Corte de Amarres o Brujería
//
//  Vista principal que orquesta el flujo completo del ritual de liberación
//

import SwiftUI

// MARK: - Vista Principal de Amarres
struct AmarresMainView: View {
    @StateObject private var amarresEngine = AmarresEngine()
    @State private var showingWelcome = true
    
    var body: some View {
        ZStack {
            // Fondo mágico
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.8),
                    Color.indigo.opacity(0.6),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if showingWelcome {
                AmarresWelcomeView(
                    amarresEngine: amarresEngine,
                    onStart: {
                        showingWelcome = false
                    }
                )
            } else {
                AmarresRitualFlowView(amarresEngine: amarresEngine)
            }
        }
        .onAppear {
            // Setup inicial completado en init
        }
    }
}

// MARK: - Flujo del Ritual de Amarres
struct AmarresRitualFlowView: View {
    @ObservedObject var amarresEngine: AmarresEngine
    
    var body: some View {
        ZStack {
            // Fondo mágico
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.8),
                    Color.indigo.opacity(0.6),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            switch amarresEngine.currentState {
            case .idle:
                EmptyView()
                
            case .preparation:
                EmptyView() // Ya no mostramos la vista de bienvenida aquí
                
            case .diagnosis:
                AmarresDiagnosisView(amarresEngine: amarresEngine)
                
            case .breathing:
                AmarresBreathingView(amarresEngine: amarresEngine)
                
            case .identification:
                AmarresIdentificationView(amarresEngine: amarresEngine)
                
            case .cleansing:
                AmarresCleansingView(amarresEngine: amarresEngine)
                
            case .cutting:
                AmarresCuttingView(amarresEngine: amarresEngine)
                
            case .protection:
                AmarresProtectionView(amarresEngine: amarresEngine)
                
            case .sealing:
                AmarresSealingView(amarresEngine: amarresEngine)
                
            case .completion:
                AmarresSummaryView(amarresEngine: amarresEngine)
                
            case .abandoned:
                AmarresAbandonedView(amarresEngine: amarresEngine)
            }
        }
    }
}

// MARK: - Vista de Bienvenida
struct AmarresWelcomeView: View {
    @ObservedObject var amarresEngine: AmarresEngine
    let onStart: () -> Void
    
    @State private var selectedApproach: AmarresApproach = .secular
    @State private var selectedIntensity: AttachmentIntensity = .medium
    @State private var selectedBindingType: AmarresType = .unknownBinding
    @State private var selectedWitchcraftType: BrujeriaType = .unknownWork
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "scissors.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.purple)
                    
                    Text("Corte de Amarres o Brujería")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Libera amarres, maldiciones y trabajos de brujería energética")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Enfoque del ritual
                VStack(alignment: .leading, spacing: 12) {
                    Text("Enfoque del Ritual")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ForEach(AmarresApproach.allCases) { approach in
                        AmarresApproachCard(
                            approach: approach,
                            isSelected: selectedApproach == approach
                        ) {
                            selectedApproach = approach
                        }
                    }
                }
                
                // Tipo de amarre
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tipo de Amarre")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(AmarresType.allCases) { bindingType in
                            AmarresTypeCard(
                                bindingType: bindingType,
                                isSelected: selectedBindingType == bindingType
                            ) {
                                selectedBindingType = bindingType
                            }
                        }
                    }
                }
                
                // Tipo de brujería
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tipo de Brujería")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(BrujeriaType.allCases) { witchcraftType in
                            BrujeriaTypeCard(
                                witchcraftType: witchcraftType,
                                isSelected: selectedWitchcraftType == witchcraftType
                            ) {
                                selectedWitchcraftType = witchcraftType
                            }
                        }
                    }
                }
                
                // Intensidad del apego
                VStack(alignment: .leading, spacing: 12) {
                    Text("Intensidad del Apego")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 8) {
                        ForEach(AttachmentIntensity.allCases) { intensity in
                            AmarresIntensityCard(
                                intensity: intensity,
                                isSelected: selectedIntensity == intensity
                            ) {
                                selectedIntensity = intensity
                            }
                        }
                    }
                }
                
                // Información del ritual
                VStack(alignment: .leading, spacing: 12) {
                    Text("Información del Ritual")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    AmarresInfoCard(
                        approach: selectedApproach,
                        bindingType: selectedBindingType,
                        witchcraftType: selectedWitchcraftType,
                        intensity: selectedIntensity
                    )
                }
                
                // Botón de inicio
                Button(action: {
                    amarresEngine.startRitual(
                        approach: selectedApproach,
                        intensity: selectedIntensity
                    )
                    onStart()
                }) {
                    HStack {
                        Image(systemName: "scissors")
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
                .padding(.top, 20)
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Tarjeta de Enfoque
struct AmarresApproachCard: View {
    let approach: AmarresApproach
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(approach.displayName)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(approach.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .green : .white.opacity(0.5))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isSelected ? 0.2 : 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.green : Color.white.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
    }
}

// MARK: - Tarjeta de Tipo de Amarre
struct AmarresTypeCard: View {
    let bindingType: AmarresType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: bindingType.icon)
                    .font(.title2)
                    .foregroundColor(bindingType.color)
                
                Text(bindingType.displayName)
                    .font(.caption)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isSelected ? 0.2 : 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? bindingType.color : Color.white.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
    }
}

// MARK: - Tarjeta de Tipo de Brujería
struct BrujeriaTypeCard: View {
    let witchcraftType: BrujeriaType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: witchcraftType.icon)
                    .font(.title2)
                    .foregroundColor(witchcraftType.color)
                
                Text(witchcraftType.displayName)
                    .font(.caption)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isSelected ? 0.2 : 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? witchcraftType.color : Color.white.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
    }
}

// MARK: - Tarjeta de Intensidad
struct AmarresIntensityCard: View {
    let intensity: AttachmentIntensity
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Circle()
                    .fill(intensity.color)
                    .frame(width: 20, height: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(intensity.displayName)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Intensidad: \(intensity.numericValue)/10")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .green : .white.opacity(0.5))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isSelected ? 0.2 : 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? intensity.color : Color.white.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
    }
}

// MARK: - Tarjeta de Información
struct AmarresInfoCard: View {
    let approach: AmarresApproach
    let bindingType: AmarresType
    let witchcraftType: BrujeriaType
    let intensity: AttachmentIntensity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AmarresInfoRow(
                icon: "clock",
                title: "Duración Estimada",
                value: "15-20 minutos"
            )
            
            AmarresInfoRow(
                icon: "target",
                title: "Enfoque",
                value: approach.displayName
            )
            
            AmarresInfoRow(
                icon: bindingType.icon,
                title: "Tipo de Amarre",
                value: bindingType.displayName
            )
            
            AmarresInfoRow(
                icon: witchcraftType.icon,
                title: "Tipo de Brujería",
                value: witchcraftType.displayName
            )
            
            AmarresInfoRow(
                icon: "gauge",
                title: "Intensidad",
                value: intensity.displayName
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Fila de Información
struct AmarresInfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 20)
            
            Text(title)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .foregroundColor(.white)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Vista de Abandono
struct AmarresAbandonedView: View {
    @ObservedObject var amarresEngine: AmarresEngine
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.red)
            
            Text("Ritual Abandonado")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("El ritual ha sido abandonado. Puedes reiniciarlo cuando estés listo.")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Button(action: {
                // Reiniciar el ritual
                amarresEngine.reset()
            }) {
                Text("Reiniciar Ritual")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(16)
            }
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Preview
#Preview {
    AmarresMainView()
}
