//
//  ErrorStateView.swift
//  JustDad - Error State Component
//
//  Professional error state component with SuperDesign integration
//  Provides consistent error handling and retry functionality
//

import SwiftUI

struct ErrorStateView: View {
    // MARK: - Properties
    let error: Error
    let retryAction: (() -> Void)?
    let customMessage: String?
    let showRetryButton: Bool
    
    // MARK: - Initialization
    init(
        error: Error,
        retryAction: (() -> Void)? = nil,
        customMessage: String? = nil,
        showRetryButton: Bool = true
    ) {
        self.error = error
        self.retryAction = retryAction
        self.customMessage = customMessage
        self.showRetryButton = showRetryButton
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: SuperDesign.Tokens.space.lg) {
            // Error icon
            errorIcon
            
            // Error title
            Text(errorTitle)
                .font(SuperDesign.Tokens.typography.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                .multilineTextAlignment(.center)
            
            // Error message
            Text(errorMessage)
                .font(SuperDesign.Tokens.typography.bodyMedium)
                .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, SuperDesign.Tokens.space.lg)
            
            // Retry button
            if showRetryButton && retryAction != nil {
                retryButton
            }
            
            // Error details (for debugging)
            #if DEBUG
            errorDetails
            #endif
        }
        .padding(SuperDesign.Tokens.space.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SuperDesign.Tokens.colors.surface)
    }
    
    // MARK: - Error Icon
    private var errorIcon: some View {
        ZStack {
            Circle()
                .fill(SuperDesign.Tokens.colors.error.opacity(0.1))
                .frame(width: 80, height: 80)
            
            Image(systemName: errorIconName)
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(SuperDesign.Tokens.colors.error)
        }
    }
    
    // MARK: - Retry Button
    private var retryButton: some View {
        SuperDesign.Components.primaryButton(
            title: "Reintentar",
            action: {
                retryAction?()
            }
        )
        .frame(maxWidth: 200)
    }
    
    // MARK: - Error Details (Debug)
    private var errorDetails: some View {
        VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.xs) {
            Text("Detalles del Error:")
                .font(SuperDesign.Tokens.typography.labelSmall)
                .fontWeight(.medium)
                .foregroundColor(SuperDesign.Tokens.colors.textTertiary)
            
            Text(error.localizedDescription)
                .font(SuperDesign.Tokens.typography.labelSmall)
                .foregroundColor(SuperDesign.Tokens.colors.textTertiary)
                .padding(SuperDesign.Tokens.space.sm)
                .background(SuperDesign.Tokens.colors.surfaceSecondary)
                .cornerRadius(SuperDesign.Tokens.effects.cornerRadiusSmall)
        }
        .padding(.horizontal, SuperDesign.Tokens.space.lg)
    }
    
    // MARK: - Computed Properties
    private var errorTitle: String {
        if let customMessage = customMessage {
            return customMessage
        }
        
        return "Error Inesperado"
    }
    
    private var errorMessage: String {
        return error.localizedDescription.isEmpty ? 
            "Ha ocurrido un error inesperado. Por favor, intenta nuevamente." : 
            error.localizedDescription
    }
    
    private var errorIconName: String {
        return "exclamationmark.circle"
    }
    
    // MARK: - Error Message Helpers (simplified for compatibility)
    // These methods are kept for future expansion but simplified for now
}

// MARK: - Error Types (using existing types from the project)
// These types are already defined in other files, so we'll use them directly

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        ErrorStateView(
            error: URLError(.notConnectedToInternet),
            retryAction: { print("Retry tapped") }
        )
        
        ErrorStateView(
            error: NSError(domain: "CalendarError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error del calendario"]),
            retryAction: { print("Retry tapped") }
        )
        
        ErrorStateView(
            error: NSError(domain: "ValidationError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Campo requerido"]),
            retryAction: { print("Retry tapped") }
        )
    }
}
