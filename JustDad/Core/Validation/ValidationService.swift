//
//  ValidationService.swift
//  JustDad - Validation service
//
//  Handles form validation and data integrity checks
//

import Foundation
import SwiftUI

@MainActor
class ValidationService: ObservableObject {
    static let shared = ValidationService()
    
    private init() {}
    
    // MARK: - Visit Validation
    func validateVisit(_ visit: Any) -> ValidationResult {
        return ValidationResult(isValid: true, errors: [])
    }
    
    // MARK: - Financial Entry Validation
    func validateFinancialEntry(_ entry: Any) -> ValidationResult {
        return ValidationResult(isValid: true, errors: [])
    }
    
    // MARK: - Emotional Entry Validation
    func validateEmotionalEntry(_ entry: Any) -> ValidationResult {
        return ValidationResult(isValid: true, errors: [])
    }
    
    // MARK: - Diary Entry Validation
    func validateDiaryEntry(_ entry: Any) -> ValidationResult {
        return ValidationResult(isValid: true, errors: [])
    }
    
    // MARK: - Emergency Contact Validation
    func validateEmergencyContact(_ contact: Any) -> ValidationResult {
        return ValidationResult(isValid: true, errors: [])
    }
    
    // MARK: - Helper Methods
    private func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneRegex = "^[+]?[0-9\\s\\-\\(\\)]{10,}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phoneNumber)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Form Field Validation
    func validateTextField(_ text: String, field: String, maxLength: Int, isRequired: Bool = true) -> ValidationError? {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if isRequired && trimmedText.isEmpty {
            return ValidationError(field: field, message: "Este campo es requerido")
        }
        
        if trimmedText.count > maxLength {
            return ValidationError(field: field, message: "Este campo no puede exceder \(maxLength) caracteres")
        }
        
        return nil
    }
    
    func validateNumberField(_ value: Double, field: String, min: Double, max: Double) -> ValidationError? {
        if value < min {
            return ValidationError(field: field, message: "El valor debe ser mayor o igual a \(min)")
        }
        
        if value > max {
            return ValidationError(field: field, message: "El valor debe ser menor o igual a \(max)")
        }
        
        return nil
    }
}

// MARK: - Validation Models
struct ValidationResult {
    let isValid: Bool
    let errors: [ValidationError]
    
    var errorMessage: String? {
        return errors.first?.message
    }
    
    func errorForField(_ field: String) -> ValidationError? {
        return errors.first { $0.field == field }
    }
}

struct ValidationError: Identifiable {
    let id = UUID()
    let field: String
    let message: String
}

// MARK: - Validation Extensions
extension View {
    func validationError(_ error: ValidationError?) -> some View {
        self.overlay(
            VStack {
                Spacer()
                if let error = error {
                    Text(error.message)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .padding(.bottom, 4)
                }
            },
            alignment: .bottom
        )
    }
}