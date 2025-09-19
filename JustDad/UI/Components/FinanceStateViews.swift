//
//  FinanceStateViews.swift
//  JustDad - Professional Financial Management
//
//  Professional state views for Finance feature
//

import SwiftUI

// MARK: - Professional Loading State
struct ProfessionalLoadingState: View {
    let message: String
    let showProgress: Bool
    
    init(message: String = "Cargando datos financieros...", showProgress: Bool = true) {
        self.message = message
        self.showProgress = showProgress
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if showProgress {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.2)
            }
            
            VStack(spacing: 8) {
                Text(message)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.adaptiveLabel)
                
                Text("Por favor espera un momento")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.adaptiveSecondarySystemBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Professional Error State
struct ProfessionalErrorState: View {
    let title: String
    let message: String
    let retryAction: (() -> Void)?
    
    init(title: String = "Error", message: String, retryAction: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.retryAction = retryAction
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.adaptiveLabel)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let retryAction = retryAction {
                Button(action: retryAction) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Reintentar")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.adaptiveSecondarySystemBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Professional Empty State
struct ProfessionalEmptyState: View {
    let title: String
    let message: String
    let actionTitle: String?
    let actionIcon: String?
    let action: (() -> Void)?
    
    init(
        title: String = "No hay datos",
        message: String,
        actionTitle: String? = nil,
        actionIcon: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.actionIcon = actionIcon
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "creditcard.trianglebadge.exclamationmark")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.adaptiveLabel)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let actionIcon = actionIcon, let action = action {
                Button(action: action) {
                    HStack {
                        Image(systemName: actionIcon)
                        Text(actionTitle)
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.adaptiveSecondarySystemBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Professional Skeleton Loading
struct ProfessionalSkeletonLoading: View {
    let itemCount: Int
    
    init(itemCount: Int = 3) {
        self.itemCount = itemCount
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<itemCount, id: \.self) { _ in
                HStack(spacing: 12) {
                    // Icon skeleton
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        // Title skeleton
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Subtitle skeleton
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Spacer()
                    
                    // Amount skeleton
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 20)
                }
                .padding(16)
                .background(Color.adaptiveSecondarySystemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .shimmer()
    }
}

// MARK: - Professional Success State
struct ProfessionalSuccessState: View {
    let title: String
    let message: String
    let icon: String
    let color: Color
    
    init(
        title: String = "¡Éxito!",
        message: String,
        icon: String = "checkmark.circle.fill",
        color: Color = .green
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(color)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.adaptiveLabel)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.adaptiveSecondarySystemBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Shimmer Effect Extension
// Note: shimmer() function is already defined in LoadingStateView.swift

// MARK: - Professional State Container
struct ProfessionalStateContainer<Content: View>: View {
    let loadingState: LoadingState
    let errorMessage: String?
    let isEmpty: Bool
    let content: () -> Content
    let retryAction: (() -> Void)?
    let emptyStateAction: (() -> Void)?
    
    init(
        loadingState: LoadingState,
        errorMessage: String? = nil,
        isEmpty: Bool = false,
        retryAction: (() -> Void)? = nil,
        emptyStateAction: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.loadingState = loadingState
        self.errorMessage = errorMessage
        self.isEmpty = isEmpty
        self.retryAction = retryAction
        self.emptyStateAction = emptyStateAction
        self.content = content
    }
    
    var body: some View {
        Group {
            switch loadingState {
            case .idle, .success:
                if isEmpty {
                    ProfessionalEmptyState(
                        title: "No hay transacciones",
                        message: "Agrega tu primer gasto para comenzar a gestionar tus finanzas",
                        actionTitle: "Agregar Gasto",
                        actionIcon: "plus.circle.fill",
                        action: emptyStateAction
                    )
                } else {
                    content()
                }
                
            case .loading:
                ProfessionalLoadingState()
                
            case .error:
                ProfessionalErrorState(
                    title: "Error al cargar datos",
                    message: errorMessage ?? "Ocurrió un error inesperado",
                    retryAction: retryAction
                )
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ProfessionalLoadingState()
        ProfessionalErrorState(message: "Error de conexión") { }
        ProfessionalEmptyState(
            message: "No hay transacciones",
            actionTitle: "Agregar Gasto",
            actionIcon: "plus.circle.fill"
        ) { }
        ProfessionalSuccessState(message: "Gasto guardado exitosamente")
    }
    .padding()
}
