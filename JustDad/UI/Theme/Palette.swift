//
//  Palette.swift
//  JustDad - App color palette and theme
//
//  Centralized color definitions for consistent theming
//

import SwiftUI

struct Palette {
    // MARK: - Primary Colors
    static let primary = Color.blue
    static let secondary = Color.green
    static let accent = Color.orange
    
    // MARK: - Background Colors
    static let background = Color.white
    static let surface = Color.gray.opacity(0.05)
    static let surfaceContainer = Color.gray.opacity(0.1)
    static let surfaceVariant = Color.gray.opacity(0.08)
    
    // MARK: - Text Colors
    static let textPrimary = Color.black
    static let textSecondary = Color.gray
    static let textTertiary = Color.gray.opacity(0.6)
    static let tertiary = Color.gray.opacity(0.6)
    
    // MARK: - Brand Colors
    static let blue = Color.blue
    static let green = Color.green
    static let orange = Color.orange
    static let red = Color.red
    static let yellow = Color.yellow
    static let gray = Color.gray
    static let purple = Color.purple
    
    // MARK: - Semantic Colors
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = Color.blue
    
    // MARK: - UI Elements
    static let divider = Color.gray.opacity(0.3)
    
    // MARK: - Legacy Support (for existing code)
    static let secondaryBackground = Color.gray.opacity(0.1)
    static let cardBackground = Color.gray.opacity(0.05)
    static let tertiaryText = Color.gray.opacity(0.7)
    static let separator = Color.gray.opacity(0.3)
    
    // MARK: - Professional Emotions Colors
    static let emotionVerySad = Color(red: 0.8, green: 0.2, blue: 0.2)    // Rojo profundo
    static let emotionSad = Color(red: 0.9, green: 0.5, blue: 0.2)        // Naranja cálido
    static let emotionNeutral = Color(red: 0.6, green: 0.6, blue: 0.6)    // Gris elegante
    static let emotionHappy = Color(red: 0.2, green: 0.6, blue: 0.9)      // Azul confianza
    static let emotionVeryHappy = Color(red: 0.2, green: 0.8, blue: 0.4)  // Verde vitalidad
    
    // MARK: - Legacy Emotions Colors (for backward compatibility)
    static let emotion1 = emotionVerySad
    static let emotion2 = emotionSad
    static let emotion3 = emotionNeutral
    static let emotion4 = emotionHappy
    static let emotion5 = emotionVeryHappy
    
    // MARK: - Category Colors
    static let categoryEducation = Color.blue
    static let categoryHealth = Color.red
    static let categoryFood = Color.green
    // MARK: - Additional Colors (for existing references)
    static let gray400 = Color.gray.opacity(0.6)
    
    // MARK: - Layout Constants
    static let cornerRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 4
    static let shadowOffset = CGSize(width: 0, height: 2)
    
    // MARK: - Accessibility Support
    static func contrastingTextColor(for backgroundColor: Color) -> Color {
        // In a real implementation, this would calculate luminance
        // For now, return appropriate contrast colors
        return Color.black
    }
}

