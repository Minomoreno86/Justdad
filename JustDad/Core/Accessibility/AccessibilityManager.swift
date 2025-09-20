//
//  AccessibilityManager.swift
//  JustDad - Accessibility Manager
//
//  Professional accessibility management for inclusive user experience.
//

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@MainActor
class AccessibilityManager: ObservableObject {
    static let shared = AccessibilityManager()
    
    @Published var isVoiceOverEnabled: Bool = false
    @Published var isReduceMotionEnabled: Bool = false
    @Published var isReduceTransparencyEnabled: Bool = false
    @Published var isIncreaseContrastEnabled: Bool = false
    @Published var preferredContentSizeCategory: ContentSizeCategory = .medium
    
    private init() {
        setupAccessibilityObservers()
        updateAccessibilitySettings()
    }
    
    // MARK: - Setup
    private func setupAccessibilityObservers() {
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.voiceOverStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAccessibilitySettings()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.reduceMotionStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAccessibilitySettings()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.reduceTransparencyStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAccessibilitySettings()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.darkerSystemColorsStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAccessibilitySettings()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIContentSizeCategory.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAccessibilitySettings()
        }
    }
    
    private func updateAccessibilitySettings() {
        isVoiceOverEnabled = UIAccessibility.isVoiceOverRunning
        isReduceMotionEnabled = UIAccessibility.isReduceMotionEnabled
        isReduceTransparencyEnabled = UIAccessibility.isReduceTransparencyEnabled
        isIncreaseContrastEnabled = UIAccessibility.isDarkerSystemColorsEnabled
        preferredContentSizeCategory = ContentSizeCategory(UIApplication.shared.preferredContentSizeCategory)
    }
    
    // MARK: - Accessibility Helpers
    func announce(_ message: String, priority: UIAccessibility.Notification = .announcement) {
        UIAccessibility.post(notification: priority, argument: message)
    }
    
    func announceScreenChange(_ screenName: String) {
        announce("Pantalla cambiada a \(screenName)", priority: .screenChanged)
    }
    
    func announceElementFocused(_ elementName: String) {
        announce("Enfocado en \(elementName)", priority: .layoutChanged)
    }
    
    func announceValueChanged(_ value: String, for element: String) {
        announce("\(element) cambiado a \(value)")
    }
    
    // MARK: - Dynamic Type Support
    func scaledFont(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        return Font.system(style, design: .default).weight(weight)
    }
    
    func scaledSize(_ baseSize: CGFloat) -> CGFloat {
        let scaleFactor = preferredContentSizeCategory.scaleFactor
        return baseSize * scaleFactor
    }
    
    // MARK: - Color Accessibility
    func accessibleColor(_ lightColor: Color, darkColor: Color? = nil) -> Color {
        if isIncreaseContrastEnabled {
            return highContrastColor(lightColor, darkColor: darkColor)
        }
        return darkColor ?? lightColor
    }
    
    private func highContrastColor(_ lightColor: Color, darkColor: Color?) -> Color {
        // Implement high contrast color logic
        return lightColor
    }
    
    // MARK: - Animation Accessibility
    func accessibleAnimation<T>(_ animation: Animation, value: T) -> Animation {
        if isReduceMotionEnabled {
            return .linear(duration: 0)
        }
        return animation
    }
    
    func accessibleTransition(_ transition: AnyTransition) -> AnyTransition {
        if isReduceMotionEnabled {
            return .identity
        }
        return transition
    }
}

// MARK: - Content Size Category Extension
extension ContentSizeCategory {
    init(_ category: UIContentSizeCategory) {
        switch category {
        case .extraSmall: self = .extraSmall
        case .small: self = .small
        case .medium: self = .medium
        case .large: self = .large
        case .extraLarge: self = .extraLarge
        case .extraExtraLarge: self = .extraExtraLarge
        case .extraExtraExtraLarge: self = .extraExtraExtraLarge
        case .accessibilityMedium: self = .accessibilityMedium
        case .accessibilityLarge: self = .accessibilityLarge
        case .accessibilityExtraLarge: self = .accessibilityExtraLarge
        case .accessibilityExtraExtraLarge: self = .accessibilityExtraExtraLarge
        case .accessibilityExtraExtraExtraLarge: self = .accessibilityExtraExtraExtraLarge
        default: self = .medium
        }
    }
    
    var scaleFactor: CGFloat {
        switch self {
        case .extraSmall: return 0.8
        case .small: return 0.9
        case .medium: return 1.0
        case .large: return 1.1
        case .extraLarge: return 1.2
        case .extraExtraLarge: return 1.3
        case .extraExtraExtraLarge: return 1.4
        case .accessibilityMedium: return 1.5
        case .accessibilityLarge: return 1.6
        case .accessibilityExtraLarge: return 1.7
        case .accessibilityExtraExtraLarge: return 1.8
        case .accessibilityExtraExtraExtraLarge: return 1.9
        @unknown default: return 1.0
        }
    }
}

// MARK: - Accessibility Modifiers
struct AccessibilityModifiers {
    static func button(label: String, hint: String? = nil, action: String? = nil) -> some ViewModifier {
        ButtonAccessibilityModifier(label: label, hint: hint, action: action)
    }
    
    static func card(title: String, content: String, value: String? = nil) -> some ViewModifier {
        CardAccessibilityModifier(title: title, content: content, value: value)
    }
    
    static func chart(title: String, data: String, value: String) -> some ViewModifier {
        ChartAccessibilityModifier(title: title, data: data, value: value)
    }
    
    static func navigation(title: String, subtitle: String? = nil) -> some ViewModifier {
        NavigationAccessibilityModifier(title: title, subtitle: subtitle)
    }
}

// MARK: - Button Accessibility Modifier
struct ButtonAccessibilityModifier: ViewModifier {
    let label: String
    let hint: String?
    let action: String?
    
    func body(content: Content) -> some View {
        content
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction(named: action ?? "Activar") {
                // Action will be handled by the button itself
            }
    }
}

// MARK: - Card Accessibility Modifier
struct CardAccessibilityModifier: ViewModifier {
    let title: String
    let content: String
    let value: String?
    
    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(title). \(content)")
            .accessibilityValue(value ?? "")
            .accessibilityAddTraits(.isStaticText)
    }
}

// MARK: - Chart Accessibility Modifier
struct ChartAccessibilityModifier: ViewModifier {
    let title: String
    let data: String
    let value: String
    
    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(title). \(data)")
            .accessibilityValue(value)
            .accessibilityAddTraits(.isImage)
    }
}

// MARK: - Navigation Accessibility Modifier
struct NavigationAccessibilityModifier: ViewModifier {
    let title: String
    let subtitle: String?
    
    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(title)\(subtitle != nil ? ". \(subtitle!)" : "")")
            .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Accessibility Extensions
extension View {
    func accessibleButton(label: String, hint: String? = nil, action: String? = nil) -> some View {
        self.modifier(AccessibilityModifiers.button(label: label, hint: hint, action: action))
    }
    
    func accessibleCard(title: String, content: String, value: String? = nil) -> some View {
        self.modifier(AccessibilityModifiers.card(title: title, content: content, value: value))
    }
    
    func accessibleChart(title: String, data: String, value: String) -> some View {
        self.modifier(AccessibilityModifiers.chart(title: title, data: data, value: value))
    }
    
    func accessibleNavigation(title: String, subtitle: String? = nil) -> some View {
        self.modifier(AccessibilityModifiers.navigation(title: title, subtitle: subtitle))
    }
    
    func accessibleHeading(_ level: Int) -> some View {
        self.accessibilityAddTraits(.isHeader)
            .accessibilityHeading(.init(rawValue: UInt(level)) ?? .h1)
    }
    
    func accessibleAnnouncement(_ message: String) -> some View {
        self.onAppear {
            AccessibilityManager.shared.announce(message)
        }
    }
}
