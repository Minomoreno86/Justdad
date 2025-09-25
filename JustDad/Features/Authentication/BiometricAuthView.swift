//
//  BiometricAuthView.swift
//  JustDad - Biometric Authentication View
//
//  Handles Face ID/Touch ID authentication flow
//

import SwiftUI
import LocalAuthentication

struct BiometricAuthView: View {
    @Binding var isAuthenticated: Bool
    let onSuccess: () -> Void
    
    @StateObject private var securityService = SecurityService.shared
    @State private var isAuthenticating = false
    @State private var authenticationError: String?
    @State private var showingError = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    SuperDesign.Tokens.colors.primary.opacity(0.1),
                    SuperDesign.Tokens.colors.surface
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // App Icon and Title
                VStack(spacing: 16) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 80))
                        .foregroundColor(SuperDesign.Tokens.colors.primary)
                        .symbolEffect(.bounce, value: isAuthenticating)
                    
                    Text("JustDad")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                    
                    Text("Acceso Seguro")
                        .font(.title2)
                        .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                }
                
                // Biometric Authentication Section
                VStack(spacing: 24) {
                    if securityService.isBiometricAuthenticationAvailable() {
                        VStack(spacing: 16) {
                            Image(systemName: biometricIcon)
                                .font(.system(size: 60))
                                .foregroundColor(SuperDesign.Tokens.colors.primary)
                                .symbolEffect(.pulse, value: isAuthenticating)
                            
                            Text(biometricTitle)
                                .font(.headline)
                                .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                            
                            Text(biometricDescription)
                                .font(.body)
                                .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: authenticate) {
                            HStack {
                                if isAuthenticating {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: biometricIcon)
                                        .font(.title3)
                                }
                                
                                Text(isAuthenticating ? "Autenticando..." : "Usar \(biometricTitle)")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [
                                        SuperDesign.Tokens.colors.primary,
                                        SuperDesign.Tokens.colors.primary.opacity(0.8)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: SuperDesign.Tokens.colors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(isAuthenticating)
                        .scaleEffect(isAuthenticating ? 0.95 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isAuthenticating)
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(SuperDesign.Tokens.colors.warning)
                            
                            Text("Autenticación Biométrica No Disponible")
                                .font(.headline)
                                .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                            
                            Text("Tu dispositivo no soporta Face ID o Touch ID. Por favor, configura la autenticación biométrica en Configuración.")
                                .font(.body)
                                .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: {
                            isAuthenticated = true
                            onSuccess()
                        }) {
                            Text("Continuar Sin Autenticación")
                                .fontWeight(.semibold)
                                .foregroundColor(SuperDesign.Tokens.colors.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(SuperDesign.Tokens.colors.primary, lineWidth: 2)
                                )
                        }
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Security Notice
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "shield.checkered")
                            .foregroundColor(SuperDesign.Tokens.colors.success)
                        Text("Datos Protegidos")
                            .font(.caption)
                            .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                    }
                    
                    Text("Tus datos están encriptados y protegidos con la máxima seguridad.")
                        .font(.caption2)
                        .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .alert("Error de Autenticación", isPresented: $showingError) {
            Button("Reintentar") {
                authenticate()
            }
            Button("Continuar Sin Autenticación") {
                isAuthenticated = true
                onSuccess()
            }
        } message: {
            Text(authenticationError ?? "Error desconocido")
        }
        .onAppear {
            // Auto-trigger authentication if available
            if securityService.isBiometricAuthenticationAvailable() {
                authenticate()
            }
        }
    }
    
    // MARK: - Computed Properties
    private var biometricIcon: String {
        switch securityService.getBiometricType() {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        default:
            return "person.badge.key"
        }
    }
    
    private var biometricTitle: String {
        switch securityService.getBiometricType() {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        default:
            return "Autenticación Biométrica"
        }
    }
    
    private var biometricDescription: String {
        switch securityService.getBiometricType() {
        case .faceID:
            return "Mira la pantalla para desbloquear JustDad"
        case .touchID:
            return "Coloca tu dedo en el botón de inicio para desbloquear JustDad"
        default:
            return "Usa tu autenticación biométrica para acceder a JustDad"
        }
    }
    
    // MARK: - Actions
    private func authenticate() {
        guard !isAuthenticating else { return }
        
        isAuthenticating = true
        authenticationError = nil
        
        Task {
            let success = await securityService.authenticateWithBiometrics()
            
            await MainActor.run {
                isAuthenticating = false
                
                if success {
                    isAuthenticated = true
                    onSuccess()
                } else {
                    authenticationError = "La autenticación falló. Por favor, intenta nuevamente."
                    showingError = true
                }
            }
        }
    }
}

#Preview {
    BiometricAuthView(
        isAuthenticated: .constant(false),
        onSuccess: {}
    )
}
