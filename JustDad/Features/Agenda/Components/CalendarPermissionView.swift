//
//  CalendarPermissionView.swift
//  JustDad - Calendar Permission Request
//
//  Professional permission request interface for calendar access
//

import SwiftUI
import EventKit

struct CalendarPermissionView: View {
    @StateObject private var permissionService = EventKitPermissionService()
    @State private var isRequestingPermission = false
    @State private var showingSettings = false
    
    let onPermissionGranted: () -> Void
    let onPermissionDenied: () -> Void
    
    var body: some View {
        VStack(spacing: SuperDesign.Tokens.space.xl) {
            // Header
            VStack(spacing: SuperDesign.Tokens.space.md) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(SuperDesign.Tokens.colors.primary)
                
                Text("Acceso al Calendario")
                    .font(SuperDesign.Tokens.typography.headlineLarge)
                    .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                
                Text("JustDad necesita acceso a tu calendario para sincronizar tus visitas con el sistema de calendarios de iOS.")
                    .font(SuperDesign.Tokens.typography.bodyMedium)
                    .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, SuperDesign.Tokens.space.lg)
            }
            
            // Benefits
            VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.sm) {
                BenefitRow(
                    icon: "calendar.badge.checkmark",
                    title: "Sincronización Automática",
                    description: "Tus visitas se sincronizan automáticamente con tu calendario"
                )
                
                BenefitRow(
                    icon: "bell.badge",
                    title: "Recordatorios Inteligentes",
                    description: "Recibe notificaciones antes de tus visitas programadas"
                )
                
                BenefitRow(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Sincronización Bidireccional",
                    description: "Los cambios se reflejan tanto en la app como en el calendario"
                )
            }
            .padding(.horizontal, SuperDesign.Tokens.space.lg)
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: SuperDesign.Tokens.space.md) {
                if permissionService.calendarPermissionStatus == .denied {
                    // Permission denied state
                    VStack(spacing: SuperDesign.Tokens.space.sm) {
                        Text("Acceso Denegado")
                            .font(SuperDesign.Tokens.typography.titleMedium)
                            .foregroundColor(SuperDesign.Tokens.colors.error)
                        
                        Text("Puedes habilitar el acceso en Configuración > Privacidad y Seguridad > Calendarios")
                            .font(SuperDesign.Tokens.typography.bodySmall)
                            .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, SuperDesign.Tokens.space.lg)
                    
                    Button("Abrir Configuración") {
                        openSettings()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                } else {
                    // Request permission button
                    Button(action: requestPermission) {
                        HStack {
                            if isRequestingPermission {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "calendar.badge.plus")
                            }
                            Text(isRequestingPermission ? "Solicitando..." : "Permitir Acceso al Calendario")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(isRequestingPermission)
                }
                
                Button("Continuar Sin Sincronización") {
                    onPermissionDenied()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .padding(.horizontal, SuperDesign.Tokens.space.lg)
            .padding(.bottom, SuperDesign.Tokens.space.xl)
        }
        .background(
            SuperDesign.Tokens.colors.surfaceGradient
                .ignoresSafeArea()
        )
        .onChange(of: permissionService.calendarPermissionStatus) { status in
            handlePermissionStatusChange(status)
        }
    }
    
    // MARK: - Actions
    
    private func requestPermission() {
        isRequestingPermission = true
        
        Task {
            let granted = await permissionService.requestCalendarPermission()
            
            await MainActor.run {
                isRequestingPermission = false
                if granted {
                    onPermissionGranted()
                }
            }
        }
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    private func handlePermissionStatusChange(_ status: EKAuthorizationStatus) {
        switch status {
        case .authorized, .fullAccess, .writeOnly:
            onPermissionGranted()
        case .denied, .restricted:
            // Keep showing the permission view
            break
        case .notDetermined:
            // Keep showing the permission view
            break
        @unknown default:
            break
        }
    }
}

// MARK: - Benefit Row Component

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: SuperDesign.Tokens.space.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(SuperDesign.Tokens.colors.primary)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(SuperDesign.Tokens.typography.titleMedium)
                    .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                
                Text(description)
                    .font(SuperDesign.Tokens.typography.bodySmall)
                    .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
            }
            
            Spacer()
        }
        .padding(.vertical, SuperDesign.Tokens.space.xs)
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(SuperDesign.Tokens.typography.titleMedium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(SuperDesign.Tokens.colors.primary)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(SuperDesign.Tokens.typography.titleMedium)
            .foregroundColor(SuperDesign.Tokens.colors.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(SuperDesign.Tokens.colors.primary, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    CalendarPermissionView(
        onPermissionGranted: { print("Permission granted") },
        onPermissionDenied: { print("Permission denied") }
    )
}
