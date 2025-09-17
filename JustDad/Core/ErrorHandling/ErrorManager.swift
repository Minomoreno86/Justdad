//
//  ErrorManager.swift
//  JustDad - Global error handling
//
//  Centralized error management and user-friendly error messages
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ErrorManager: ObservableObject {
    static let shared = ErrorManager()
    
    @Published var currentError: AppError?
    @Published var isShowingError = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Error Handling
    func handle(_ error: Error) {
        let appError = AppError.from(error)
        currentError = appError
        isShowingError = true
        
        // Log error for debugging
        print("Error occurred: \(appError.localizedDescription)")
        print("Debug info: \(appError.debugDescription)")
    }
    
    func handle(_ appError: AppError) {
        currentError = appError
        isShowingError = true
        
        // Log error for debugging
        print("App error occurred: \(appError.localizedDescription)")
        print("Debug info: \(appError.debugDescription)")
    }
    
    func dismissError() {
        currentError = nil
        isShowingError = false
    }
    
    // MARK: - Specific Error Handlers
    func handleNetworkError(_ error: Error) {
        let appError = AppError.networkError(underlying: error)
        handle(appError)
    }
    
    func handleValidationError(_ error: Any) {
        let appError = AppError.unknownError("Validation error")
        handle(appError)
    }
    
    func handlePersistenceError(_ error: Error) {
        let appError = AppError.persistenceError(underlying: error)
        handle(appError)
    }
    
    func handleSecurityError(_ error: Error) {
        let appError = AppError.securityError(underlying: error)
        handle(appError)
    }
}

// MARK: - App Error Types
enum AppError: LocalizedError, Identifiable {
    case networkError(underlying: Error)
    case validationError(Any)
    case persistenceError(underlying: Error)
    case securityError(underlying: Error)
    case unknownError(String)
    case userCancelled
    case permissionDenied
    case dataCorrupted
    case fileNotFound
    case insufficientStorage
    case rateLimited
    
    var id: String {
        switch self {
        case .networkError: return "network"
        case .validationError: return "validation"
        case .persistenceError: return "persistence"
        case .securityError: return "security"
        case .unknownError: return "unknown"
        case .userCancelled: return "cancelled"
        case .permissionDenied: return "permission"
        case .dataCorrupted: return "corrupted"
        case .fileNotFound: return "not_found"
        case .insufficientStorage: return "storage"
        case .rateLimited: return "rate_limited"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Error de conexión: \(error.localizedDescription)"
        case .validationError:
            return "Error de validación"
        case .persistenceError(let error):
            return "Error de datos: \(error.localizedDescription)"
        case .securityError(let error):
            return "Error de seguridad: \(error.localizedDescription)"
        case .unknownError(let message):
            return "Error desconocido: \(message)"
        case .userCancelled:
            return "Operación cancelada"
        case .permissionDenied:
            return "Permisos insuficientes"
        case .dataCorrupted:
            return "Los datos están corruptos"
        case .fileNotFound:
            return "Archivo no encontrado"
        case .insufficientStorage:
            return "Espacio de almacenamiento insuficiente"
        case .rateLimited:
            return "Demasiadas solicitudes. Intenta más tarde"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Verifica tu conexión a internet e intenta nuevamente"
        case .validationError:
            return "Revisa los datos ingresados y corrige los errores"
        case .persistenceError:
            return "Reinicia la aplicación o contacta al soporte"
        case .securityError:
            return "Verifica tu autenticación o contacta al soporte"
        case .unknownError:
            return "Reinicia la aplicación o contacta al soporte"
        case .userCancelled:
            return nil
        case .permissionDenied:
            return "Ve a Configuración y otorga los permisos necesarios"
        case .dataCorrupted:
            return "Los datos pueden necesitar ser restaurados desde un respaldo"
        case .fileNotFound:
            return "El archivo puede haber sido eliminado o movido"
        case .insufficientStorage:
            return "Libera espacio en tu dispositivo"
        case .rateLimited:
            return "Espera unos minutos antes de intentar nuevamente"
        }
    }
    
    var debugDescription: String {
        switch self {
        case .networkError(let error):
            return "Network error: \(error)"
        case .validationError:
            return "Validation error"
        case .persistenceError(let error):
            return "Persistence error: \(error)"
        case .securityError(let error):
            return "Security error: \(error)"
        case .unknownError(let message):
            return "Unknown error: \(message)"
        case .userCancelled:
            return "User cancelled operation"
        case .permissionDenied:
            return "Permission denied"
        case .dataCorrupted:
            return "Data corruption detected"
        case .fileNotFound:
            return "File not found"
        case .insufficientStorage:
            return "Insufficient storage space"
        case .rateLimited:
            return "Rate limit exceeded"
        }
    }
    
    var severity: ErrorSeverity {
        switch self {
        case .networkError, .rateLimited:
            return .warning
        case .validationError, .userCancelled:
            return .info
        case .persistenceError, .securityError, .dataCorrupted:
            return .error
        case .unknownError, .permissionDenied, .fileNotFound, .insufficientStorage:
            return .error
        }
    }
    
    var shouldRetry: Bool {
        switch self {
        case .networkError, .rateLimited:
            return true
        case .validationError, .userCancelled, .permissionDenied:
            return false
        case .persistenceError, .securityError, .dataCorrupted, .fileNotFound, .insufficientStorage, .unknownError:
            return false
        }
    }
    
    static func from(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        
        // Map common system errors
        if let nsError = error as NSError? {
            switch nsError.domain {
            case NSURLErrorDomain:
                return .networkError(underlying: error)
            case NSCocoaErrorDomain:
                switch nsError.code {
                case NSFileReadNoSuchFileError:
                    return .fileNotFound
                case NSFileWriteOutOfSpaceError:
                    return .insufficientStorage
                case 134030:
                    return .dataCorrupted
                default:
                    return .persistenceError(underlying: error)
                }
            case "com.apple.security":
                return .securityError(underlying: error)
            default:
                return .unknownError(error.localizedDescription)
            }
        }
        
        return .unknownError(error.localizedDescription)
    }
}

// MARK: - Error Severity
enum ErrorSeverity {
    case info
    case warning
    case error
    
    var color: Color {
        switch self {
        case .info: return .blue
        case .warning: return .orange
        case .error: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.circle.fill"
        }
    }
}

// MARK: - Error Alert View
struct ErrorAlertView: View {
    let error: AppError
    let onDismiss: () -> Void
    let onRetry: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: error.severity.icon)
                .font(.system(size: 40))
                .foregroundColor(error.severity.color)
            
            Text(error.errorDescription ?? "Error desconocido")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            if let suggestion = error.recoverySuggestion {
                Text(suggestion)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            HStack(spacing: 12) {
                Button("Cerrar") {
                    onDismiss()
                }
                .buttonStyle(.bordered)
                
                if error.shouldRetry, let onRetry = onRetry {
                    Button("Reintentar") {
                        onRetry()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}

// MARK: - Error Handling View Modifier
struct ErrorHandlingModifier: ViewModifier {
    @StateObject private var errorManager = ErrorManager.shared
    
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: $errorManager.isShowingError) {
                Button("Cerrar") {
                    errorManager.dismissError()
                }
            } message: {
                if let error = errorManager.currentError {
                    Text(error.errorDescription ?? "Error desconocido")
                }
            }
    }
}

extension View {
    func withErrorHandling() -> some View {
        self.modifier(ErrorHandlingModifier())
    }
}
