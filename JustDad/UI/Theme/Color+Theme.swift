//
//  Color+Theme.swift
//  JustDad - Color theme extensions
//
//  SwiftUI Color extensions for app theming
//

import SwiftUI

extension Color {
    static var primaryColor: Color {
        return .blue
    }
    
    static var secondaryColor: Color {
        return .green
    }
    
    static var accentColor: Color {
        return .orange
    }
    
    static var backgroundPrimary: Color {
        return .white
    }
    
    static var backgroundSecondary: Color {
        return .gray.opacity(0.1)
    }
    
    static var backgroundCard: Color {
        return .gray.opacity(0.05)
    }
    
    static var textPrimary: Color {
        return .black
    }
    
    static var textSecondary: Color {
        return .gray
    }
    
    static var textTertiary: Color {
        return .gray.opacity(0.7)
    }
    
    static var border: Color {
        return .gray.opacity(0.3)
    }
    
    static var shadow: Color {
        return .gray.opacity(0.3)
    }
    
    // MARK: - Dynamic Theme Methods (for legacy support)
    static func themePrimary(_ isDark: Bool) -> Color {
        return isDark ? .blue.opacity(0.8) : .blue
    }
    
    static func themeBackground(_ isDark: Bool) -> Color {
        return isDark ? .black : .white
    }
    
    static func themeBackgroundSecondary(_ isDark: Bool) -> Color {
        return isDark ? .gray.opacity(0.2) : .gray.opacity(0.1)
    }
    
    static func themeBackgroundCard(_ isDark: Bool) -> Color {
        return isDark ? .gray.opacity(0.15) : .gray.opacity(0.05)
    }
    
    static func themeTextPrimary(_ isDark: Bool) -> Color {
        return isDark ? .white : .black
    }
    
    static func themeBorder(_ isDark: Bool) -> Color {
        return isDark ? .gray.opacity(0.4) : .gray.opacity(0.3)
    }
    
    static func themeShadow(_ isDark: Bool) -> Color {
        return isDark ? .black.opacity(0.5) : .gray.opacity(0.3)
    }
}

extension Color {
    // Emotion colors for mood tracking
    static var emotion1: Color { .red }     // Very sad
    static var emotion2: Color { .orange }  // Sad
    static var emotion3: Color { .gray }    // Neutral
    static var emotion4: Color { .blue }    // Happy
    static var emotion5: Color { .green }   // Very happy
    
    // Category colors for finance tracking
    static var categoryEducation: Color { .blue }
    static var categoryHealth: Color { .red }
    static var categoryFood: Color { .green }
    static var categoryTransport: Color { .purple }
    static var categoryEntertainment: Color { .orange }
    static var categoryOther: Color { .gray }
}
