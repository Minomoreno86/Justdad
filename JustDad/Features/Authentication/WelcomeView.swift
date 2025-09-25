//
//  WelcomeView.swift
//  JustDad - Welcome Screen with Multiple Authentication Options
//
//  Professional welcome screen with biometric, passkey, and manual authentication
//

import SwiftUI
import LocalAuthentication

struct WelcomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var securityService: SecurityService
    @State private var isAuthenticating = false
    @State private var authenticationError: String?
    @State private var showingError = false
    @State private var selectedAuthMethod: AuthMethod = .biometric
    @State private var availableAuthMethods: [AuthMethod] = []
    @State private var showingSettings = false
    @State private var showingUserManagement = false
    @State private var shouldDismissWelcome = false
    
    enum AuthMethod: String, CaseIterable {
        case biometric = "biometric"
        case passkey = "passkey"
        case manual = "manual"
        
        var displayName: String {
            switch self {
            case .biometric: return "Autenticación Biométrica"
            case .passkey: return "Passkey"
            case .manual: return "Contraseña"
            }
        }
        
        func icon(securityService: SecurityService) -> String {
            switch self {
            case .biometric: return securityService.getBiometricType() == .faceID ? "faceid" : "touchid"
            case .passkey: return "key.fill"
            case .manual: return "lock.fill"
            }
        }
        
        func description(securityService: SecurityService) -> String {
            switch self {
            case .biometric: 
                return securityService.getBiometricType() == .faceID ? "Usar Face ID" : "Usar Touch ID"
            case .passkey: return "Usar Passkey (iOS 16+)"
            case .manual: return "Ingresar contraseña"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    SuperDesign.Tokens.colors.primary.opacity(0.1),
                    SuperDesign.Tokens.colors.surface,
                    SuperDesign.Tokens.colors.primary.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header Section
                    headerSection
                    
                    // User Profile Section
                    userProfileSection
                    
                    // Authentication Options
                    authenticationSection
                    
                    // Settings Section
                    settingsSection
                    
                    // Help Section
                    helpSection
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
        }
        .navigationBarHidden(true)
        .overlay(
            // Skip button in top-right corner
            VStack {
                HStack {
                    Spacer()
                    Button("Saltar") {
                        shouldDismissWelcome = true
                    }
                    .foregroundColor(SuperDesign.Tokens.colors.primary)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(SuperDesign.Tokens.colors.primary.opacity(0.1))
                    )
                    .padding(.top, 8)
                    .padding(.trailing, 16)
                }
                Spacer()
            }
        )
        .alert("Error de Autenticación", isPresented: $showingError) {
            Button("Intentar de nuevo") {
                authenticationError = nil
            }
            Button("Cancelar", role: .cancel) {
                authenticationError = nil
            }
        } message: {
            if let error = authenticationError {
                Text(error)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SecuritySettingsView()
        }
        .sheet(isPresented: $showingUserManagement) {
            UserManagementView()
        }
        .onChange(of: shouldDismissWelcome) { _, newValue in
            if newValue {
                // Close welcome screen and proceed to main app
                // This will be handled by the parent view
                print("WelcomeView: shouldDismissWelcome = \(newValue)")
                NotificationCenter.default.post(name: .init("WelcomeViewDismissed"), object: nil)
            }
        }
        .onAppear {
            checkAvailableAuthMethods()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // App Logo/Icon
            Image(systemName: "house.fill")
                .font(.system(size: 60))
                .foregroundColor(SuperDesign.Tokens.colors.primary)
                .padding(.top, 20)
            
            // App Name
            Text("JustDad")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(SuperDesign.Tokens.colors.primary)
            
            // Welcome Message
            Text("Bienvenido de vuelta")
                .font(.title2)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - User Profile Section
    private var userProfileSection: some View {
        VStack(spacing: 16) {
            // User Avatar
            if let imageData = appState.userProfileImageData,
               let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(SuperDesign.Tokens.colors.primary, lineWidth: 3)
                    )
            } else {
                Circle()
                    .fill(SuperDesign.Tokens.colors.primary.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text("P")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(SuperDesign.Tokens.colors.primary)
                    )
                    .overlay(
                        Circle()
                            .stroke(SuperDesign.Tokens.colors.primary, lineWidth: 3)
                    )
            }
            
            // User Name
            Text(appState.userName.isEmpty ? "Papá Usuario" : appState.userName)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // User Age (if available)
            if !appState.userAge.isEmpty {
                Text("\(appState.userAge) años")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(SuperDesign.Tokens.colors.surface)
                .shadow(color: SuperDesign.Tokens.colors.primary.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Authentication Section
    private var authenticationSection: some View {
        VStack(spacing: 16) {
            Text("Iniciar Sesión")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // Primary Authentication Method
            Button(action: {
                authenticateWithMethod(selectedAuthMethod)
            }) {
                HStack {
                    Image(systemName: selectedAuthMethod.icon(securityService: securityService))
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedAuthMethod.displayName)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(selectedAuthMethod.description(securityService: securityService))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    if isAuthenticating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.right")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(SuperDesign.Tokens.colors.primary)
                        .shadow(color: SuperDesign.Tokens.colors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                )
            }
            .disabled(isAuthenticating)
            
            // Alternative Authentication Methods
            VStack(spacing: 12) {
                ForEach(availableAuthMethods.filter { $0 != selectedAuthMethod }, id: \.self) { method in
                    Button(action: {
                        selectedAuthMethod = method
                    }) {
                        HStack {
                            Image(systemName: method.icon(securityService: securityService))
                                .font(.title3)
                                .foregroundColor(SuperDesign.Tokens.colors.primary)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(method.displayName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                Text(method.description(securityService: securityService))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedAuthMethod == method {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(SuperDesign.Tokens.colors.primary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedAuthMethod == method ? 
                                      SuperDesign.Tokens.colors.primary.opacity(0.1) : 
                                      SuperDesign.Tokens.colors.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedAuthMethod == method ? 
                                               SuperDesign.Tokens.colors.primary : 
                                               SuperDesign.Tokens.colors.border, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(SuperDesign.Tokens.colors.surface)
                .shadow(color: SuperDesign.Tokens.colors.primary.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(spacing: 16) {
            Text("Configuración")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                // Security Settings
                Button(action: {
                    showingSettings = true
                }) {
                    HStack {
                        Image(systemName: "shield.fill")
                            .font(.title3)
                            .foregroundColor(SuperDesign.Tokens.colors.primary)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Configuración de Seguridad")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("Face ID, Touch ID, Passkeys")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(SuperDesign.Tokens.colors.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(SuperDesign.Tokens.colors.border, lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // User Management
                Button(action: {
                    showingUserManagement = true
                }) {
                    HStack {
                        Image(systemName: "person.fill")
                            .font(.title3)
                            .foregroundColor(SuperDesign.Tokens.colors.primary)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Gestión de Usuario")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("Cambiar usuario, perfil")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(SuperDesign.Tokens.colors.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(SuperDesign.Tokens.colors.border, lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(SuperDesign.Tokens.colors.surface)
                .shadow(color: SuperDesign.Tokens.colors.primary.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Help Section
    private var helpSection: some View {
        VStack(spacing: 16) {
            Text("Ayuda")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                // Continue Button - More prominent
                Button(action: {
                    shouldDismissWelcome = true
                }) {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 28)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Continuar")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("Ir a la aplicación")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(SuperDesign.Tokens.colors.primary)
                            .shadow(color: SuperDesign.Tokens.colors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Support
                Button(action: {
                    // TODO: Implement support
                }) {
                    HStack {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(SuperDesign.Tokens.colors.primary)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Soporte")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("Ayuda y contacto")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(SuperDesign.Tokens.colors.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(SuperDesign.Tokens.colors.border, lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(SuperDesign.Tokens.colors.surface)
                .shadow(color: SuperDesign.Tokens.colors.primary.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Authentication Methods
    private func authenticateWithMethod(_ method: AuthMethod) {
        isAuthenticating = true
        authenticationError = nil
        
        Task {
            let success: Bool
            
            do {
                switch method {
                case .biometric:
                    success = await securityService.authenticateWithBiometrics()
                case .passkey:
                    success = await authenticateWithPasskey()
                case .manual:
                    success = await authenticateManually()
                }
                
                await MainActor.run {
                    isAuthenticating = false
                    
                if success {
                    // Authentication successful - navigate to main app
                    shouldDismissWelcome = true
                } else {
                    // Provide specific error message based on authentication method
                    switch method {
                    case .biometric:
                        authenticationError = "Fallo la autenticación biométrica. Verifica que Face ID/Touch ID esté configurado y funcionando."
                    case .passkey:
                        authenticationError = "Fallo la autenticación con Passkey. Intenta de nuevo."
                    case .manual:
                        authenticationError = "Fallo la autenticación manual. Intenta de nuevo."
                    }
                    showingError = true
                }
                }
            } catch {
                await MainActor.run {
                    isAuthenticating = false
                    authenticationError = "Error inesperado: \(error.localizedDescription)"
                    showingError = true
                }
            }
        }
    }
    
    private func authenticateWithPasskey() async -> Bool {
        // TODO: Implement Passkey authentication
        // For now, return false as placeholder
        return false
    }
    
    private func authenticateManually() async -> Bool {
        // TODO: Implement manual authentication
        // For now, return false as placeholder
        return false
    }
    
    // MARK: - Helper Methods
    private func checkAvailableAuthMethods() {
        var methods: [AuthMethod] = []
        
        // Check biometric availability with detailed logging
        print("Checking biometric authentication availability...")
        let isBiometricAvailable = securityService.isBiometricAuthenticationAvailable()
        print("Biometric available: \(isBiometricAvailable)")
        
        if isBiometricAvailable {
            methods.append(.biometric)
            print("Added biometric authentication method")
        } else {
            print("Biometric authentication not available - user may need to set up Face ID/Touch ID")
        }
        
        // Always include manual as fallback
        methods.append(.manual)
        print("Added manual authentication method")
        
        // TODO: Check Passkey availability for iOS 16+
        // methods.append(.passkey)
        
        availableAuthMethods = methods
        print("Available authentication methods: \(availableAuthMethods.map { $0.rawValue })")
        
        // Set default method
        if !methods.isEmpty {
            selectedAuthMethod = methods.first ?? .manual
            print("Selected authentication method: \(selectedAuthMethod.rawValue)")
        }
    }
}

// MARK: - Supporting Views
struct SecuritySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Text("Configuración de Seguridad")
                .navigationTitle("Seguridad")
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
}

struct UserManagementView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Text("Gestión de Usuario")
                .navigationTitle("Usuario")
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
}

#Preview {
    WelcomeView()
        .environmentObject(AppState())
        .environmentObject(SecurityService.shared)
}
