//
//  ThemeManager.swift
//  SoloPapá - Advanced Theme Management System
//
//  Handles dynamic light/dark mode switching with premium design
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = .system
    @Published var isDarkMode: Bool = false
    @AppStorage("selectedTheme") private var storedTheme: String = AppTheme.system.rawValue
    
    init() {
        loadTheme()
        updateDarkMode()
    }
    
    enum AppTheme: String, CaseIterable {
        case light = "light"
        case dark = "dark"
        case system = "system"
        
        var displayName: String {
            switch self {
            case .light: return "Claro"
            case .dark: return "Oscuro"
            case .system: return "Sistema"
            }
        }
        
        var icon: String {
            switch self {
            case .light: return "sun.max.fill"
            case .dark: return "moon.fill"
            case .system: return "circle.lefthalf.filled"
            }
        }
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        storedTheme = theme.rawValue
        updateDarkMode()
    }
    
    private func loadTheme() {
        if let theme = AppTheme(rawValue: storedTheme) {
            currentTheme = theme
        }
    }
    
    private func updateDarkMode() {
        switch currentTheme {
        case .light:
            isDarkMode = false
        case .dark:
            isDarkMode = true
        case .system:
            // Default to light mode for system, will be handled by environment
            isDarkMode = false
        }
    }
    
    // MARK: - Dynamic Color System
    func color(for colorType: DynamicColorType) -> Color {
        return isDarkMode ? colorType.darkValue : colorType.lightValue
    }
}

// MARK: - Dynamic Color Types
enum DynamicColorType {
    case primary
    case secondary
    case accent
    case background
    case backgroundSecondary
    case backgroundCard
    case textPrimary
    case textSecondary
    case textTertiary
    case border
    case shadow
    case success
    case warning
    case error
    case info
    
    var lightValue: Color {
        switch self {
        case .primary:
            return Color(red: 0.0, green: 0.48, blue: 0.8)
        case .secondary:
            return Color(red: 0.0, green: 0.66, blue: 0.42)
        case .accent:
            return Color(red: 1.0, green: 0.6, blue: 0.0)
        case .background:
            return Color(red: 0.98, green: 0.98, blue: 0.98)
        case .backgroundSecondary:
            return Color(red: 0.95, green: 0.95, blue: 0.95)
        case .backgroundCard:
            return Color.white
        case .textPrimary:
            return Color(red: 0.1, green: 0.1, blue: 0.1)
        case .textSecondary:
            return Color(red: 0.4, green: 0.4, blue: 0.4)
        case .textTertiary:
            return Color(red: 0.6, green: 0.6, blue: 0.6)
        case .border:
            return Color(red: 0.9, green: 0.9, blue: 0.9)
        case .shadow:
            return Color.black.opacity(0.1)
        case .success:
            return Color(red: 0.0, green: 0.7, blue: 0.0)
        case .warning:
            return Color(red: 1.0, green: 0.8, blue: 0.0)
        case .error:
            return Color(red: 0.9, green: 0.0, blue: 0.0)
        case .info:
            return Color(red: 0.0, green: 0.48, blue: 0.8)
        }
    }
    
    var darkValue: Color {
        switch self {
        case .primary:
            return Color(red: 0.2, green: 0.6, blue: 1.0)
        case .secondary:
            return Color(red: 0.0, green: 0.8, blue: 0.5)
        case .accent:
            return Color(red: 1.0, green: 0.7, blue: 0.2)
        case .background:
            return Color(red: 0.05, green: 0.05, blue: 0.05)
        case .backgroundSecondary:
            return Color(red: 0.1, green: 0.1, blue: 0.1)
        case .backgroundCard:
            return Color(red: 0.15, green: 0.15, blue: 0.15)
        case .textPrimary:
            return Color(red: 0.95, green: 0.95, blue: 0.95)
        case .textSecondary:
            return Color(red: 0.7, green: 0.7, blue: 0.7)
        case .textTertiary:
            return Color(red: 0.5, green: 0.5, blue: 0.5)
        case .border:
            return Color(red: 0.3, green: 0.3, blue: 0.3)
        case .shadow:
            return Color.black.opacity(0.3)
        case .success:
            return Color(red: 0.2, green: 0.8, blue: 0.2)
        case .warning:
            return Color(red: 1.0, green: 0.9, blue: 0.3)
        case .error:
            return Color(red: 1.0, green: 0.3, blue: 0.3)
        case .info:
            return Color(red: 0.2, green: 0.6, blue: 1.0)
        }
    }
}
