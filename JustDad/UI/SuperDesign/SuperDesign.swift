//
//  SuperDesign.swift
//  JustDad - Super Professional Design System
//
//  Incredible Design System Architecture
//  Created by Jorge Vasquez rodriguez on 15/9/25.
//

import SwiftUI

// MARK: - 🎨 SUPER DESIGN SYSTEM
struct SuperDesign {
    static let shared = SuperDesign()
    private init() {}
    
    // MARK: - 🎯 Design Tokens
    struct Tokens {
        // Spacing (8pt grid system)
        static let space = SpacingTokens()
        
        // Colors (Professional palette)
        static let colors = ColorTokens()
        
        // Typography (Perfect scale)
        static let typography = TypographyTokens()
        
        // Effects (Shadows & elevations)
        static let effects = EffectTokens()
        
        // Animation (Smooth transitions)
        static let animation = AnimationTokens()
    }
    
    // MARK: - 🧩 Components
    struct Components {
        // Buttons with amazing styles
        static func primaryButton(
            title: String,
            icon: String? = nil,
            isLoading: Bool = false,
            isEnabled: Bool = true,
            fullWidth: Bool = true,
            action: @escaping () -> Void
        ) -> some View {
            SuperPrimaryButton(
                title: title, 
                icon: icon, 
                isLoading: isLoading,
                isEnabled: isEnabled,
                fullWidth: fullWidth,
                action: action
            )
        }
        
        static func secondaryButton(
            title: String,
            icon: String? = nil,
            isEnabled: Bool = true,
            fullWidth: Bool = true,
            action: @escaping () -> Void
        ) -> some View {
            SuperSecondaryButton(
                title: title, 
                icon: icon, 
                isEnabled: isEnabled,
                fullWidth: fullWidth,
                action: action
            )
        }
        
        static func fab(
            icon: String,
            action: @escaping () -> Void
        ) -> some View {
            SuperFloatingButton(icon: icon, action: action)
        }
        
        // Cards with perfect elevation
        static func card<Content: View>(
            elevation: SuperElevation = .medium,
            padding: CGFloat? = nil,
            @ViewBuilder content: () -> Content
        ) -> some View {
            SuperCard(elevation: elevation, padding: padding, content: content)
        }
        
        static func featuredCard<Content: View>(
            @ViewBuilder content: () -> Content
        ) -> some View {
            SuperFeaturedCard(content: content)
        }
        
        // Text Components
        static func heading(
            _ text: String,
            size: HeadingSize = .large
        ) -> some View {
            SuperHeading(text: text, size: size)
        }
        
        static func body(
            _ text: String,
            size: BodySize = .medium,
            color: Color? = nil
        ) -> some View {
            SuperBody(text: text, size: size, color: color)
        }
        
        // Input Components
        static func textField(
            _ placeholder: String,
            text: Binding<String>,
            isSecure: Bool = false
        ) -> some View {
            SuperTextField(placeholder: placeholder, text: text, isSecure: isSecure)
        }
        
        // Layout Components
        static func section<Content: View>(
            title: String? = nil,
            @ViewBuilder content: () -> Content
        ) -> some View {
            VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.md) {
                if let title = title {
                    SuperHeading(text: title, size: .medium)
                        .padding(.horizontal, SuperDesign.Tokens.space.lg)
                }
                
                content()
            }
        }
    }
}

// MARK: - 📏 Spacing Tokens
struct SpacingTokens {
    let xxxs: CGFloat = 2
    let xxs: CGFloat = 4
    let xs: CGFloat = 8
    let sm: CGFloat = 12
    let md: CGFloat = 16
    let lg: CGFloat = 24
    let xl: CGFloat = 32
    let xxl: CGFloat = 48
    let xxxl: CGFloat = 64
    
    // Semantic spacing
    let container: CGFloat = 20
    let section: CGFloat = 32
    let component: CGFloat = 16
    let element: CGFloat = 8
}

// MARK: - 🎨 Color Tokens (Professional Palette with Dark Mode Support)
struct ColorTokens {
    // Primary Colors - More vibrant and professional
    let primary = Color(red: 0.06, green: 0.47, blue: 0.84) // Vibrant professional blue
    let primaryLight = Color(red: 0.55, green: 0.75, blue: 0.95)
    let primaryDark = Color(red: 0.03, green: 0.35, blue: 0.65)
    
    // Accent Colors
    let accent = Color(red: 0.95, green: 0.38, blue: 0.21) // Professional orange
    let accentLight = Color(red: 1.0, green: 0.65, blue: 0.45)
    
    // Background Colors - Adaptive to dark mode
    let background = Color(.systemBackground)
    let surface = Color(.secondarySystemBackground)
    let surfaceSecondary = Color(.tertiarySystemBackground)
    let surfaceElevated = Color(.systemBackground)
    
    // Text Colors - Adaptive to dark mode
    let textPrimary = Color(.label)
    let textSecondary = Color(.secondaryLabel)
    let textTertiary = Color(.tertiaryLabel)
    
    // Semantic Colors - Adaptive
    let success = Color(.systemGreen)
    let warning = Color(.systemOrange)
    let error = Color(.systemRed)
    let info = Color(.systemBlue)
    
    // Border Colors - Adaptive
    let border = Color(.separator)
    let borderLight = Color(.separator).opacity(0.5)
    let borderDark = Color(.separator)
    
    // Professional Gradients - Adaptive
    let primaryGradient = LinearGradient(
        colors: [Color(red: 0.06, green: 0.47, blue: 0.84), Color(red: 0.03, green: 0.35, blue: 0.65)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    let surfaceGradient = LinearGradient(
        colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Component-specific colors - Adaptive
    let card = Color(.secondarySystemBackground)
    let cardSecondary = Color(.tertiarySystemBackground)
}

// MARK: - ✍️ Typography Tokens
struct TypographyTokens {
    // Display styles
    let displayLarge = Font.system(size: 57, weight: .bold, design: .default)
    let displayMedium = Font.system(size: 45, weight: .bold, design: .default)
    let displaySmall = Font.system(size: 36, weight: .bold, design: .default)
    
    // Headline styles
    let headlineLarge = Font.system(size: 32, weight: .semibold, design: .default)
    let headlineMedium = Font.system(size: 28, weight: .semibold, design: .default)
    let headlineSmall = Font.system(size: 24, weight: .semibold, design: .default)
    
    // Title styles
    let titleLarge = Font.system(size: 22, weight: .medium, design: .default)
    let titleMedium = Font.system(size: 16, weight: .medium, design: .default)
    let titleSmall = Font.system(size: 14, weight: .medium, design: .default)
    
    // Body styles
    let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)
    let bodyMedium = Font.system(size: 14, weight: .regular, design: .default)
    let bodySmall = Font.system(size: 12, weight: .regular, design: .default)
    
    // Label styles
    let labelLarge = Font.system(size: 14, weight: .medium, design: .default)
    let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
    let labelSmall = Font.system(size: 11, weight: .medium, design: .default)
}

// MARK: - ✨ Effect Tokens
struct EffectTokens {
    // Corner Radius System
    let cornerRadius: CGFloat = 12
    let cornerRadiusSmall: CGFloat = 8
    let cornerRadiusMedium: CGFloat = 12
    let cornerRadiusLarge: CGFloat = 16
    let cornerRadiusXLarge: CGFloat = 24
    
    // Border System
    let borderWidth: CGFloat = 1
    let borderWidthThick: CGFloat = 2
    
    // Shadows
    func shadow(for elevation: SuperElevation) -> (Color, CGFloat, CGFloat, CGFloat) {
        switch elevation {
        case .none:
            return (Color.clear, 0, 0, 0)
        case .low:
            return (Color.black.opacity(0.05), 2, 0, 1)
        case .medium:
            return (Color.black.opacity(0.1), 4, 0, 2)
        case .high:
            return (Color.black.opacity(0.15), 8, 0, 4)
        case .highest:
            return (Color.black.opacity(0.2), 16, 0, 8)
        }
    }
    
    // Opacity System
    let opacityDisabled: Double = 0.6
    let opacityOverlay: Double = 0.8
    let opacitySubtle: Double = 0.1
    let opacityMedium: Double = 0.3
    let opacityStrong: Double = 0.6
}

// MARK: - 🎬 Animation Tokens
struct AnimationTokens {
    let instant: Double = 0.1
    let fast: Double = 0.2
    let normal: Double = 0.3
    let slow: Double = 0.5
    
    // Easing curves
    let easeOut = Animation.easeOut(duration: 0.3)
    let easeIn = Animation.easeIn(duration: 0.3)
    let easeInOut = Animation.easeInOut(duration: 0.3)
    let spring = Animation.spring(response: 0.5, dampingFraction: 0.8)
    let springBouncy = Animation.spring(response: 0.4, dampingFraction: 0.6)
}

// MARK: - 📐 Elevation System
enum SuperElevation: CaseIterable {
    case none
    case low
    case medium
    case high
    case highest
}

// MARK: - 🔲 Super Primary Button
struct SuperPrimaryButton: View {
    let title: String
    let icon: String?
    let isLoading: Bool
    let isEnabled: Bool
    let fullWidth: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var scale: CGFloat = 1.0
    
    init(
        title: String,
        icon: String? = nil,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        fullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.fullWidth = fullWidth
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if isEnabled && !isLoading {
                performAction()
            }
        }) {
            HStack(spacing: SuperDesign.Tokens.space.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .font(SuperDesign.Tokens.typography.labelLarge)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, SuperDesign.Tokens.space.lg)
            .padding(.vertical, SuperDesign.Tokens.space.md)
            .background(
                RoundedRectangle(cornerRadius: SuperDesign.Tokens.effects.cornerRadius)
                    .fill(backgroundColor)
            )
            .scaleEffect(scale)
            .shadow(
                color: SuperDesign.Tokens.colors.primary.opacity(0.3),
                radius: 8,
                x: 0,
                y: 4
            )
            .opacity(isEnabled ? 1.0 : SuperDesign.Tokens.effects.opacityDisabled)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled || isLoading)
    }
    
    private var backgroundColor: Color {
        if !isEnabled {
            return SuperDesign.Tokens.colors.textSecondary
        }
        return SuperDesign.Tokens.colors.primary
    }
    
    private func performAction() {
        withAnimation(SuperDesign.Tokens.animation.springBouncy) {
            scale = 0.95
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(SuperDesign.Tokens.animation.spring) {
                scale = 1.0
            }
            action()
        }
    }
}

// MARK: - 🔳 Super Secondary Button
struct SuperSecondaryButton: View {
    let title: String
    let icon: String?
    let isEnabled: Bool
    let fullWidth: Bool
    let action: () -> Void
    
    @State private var scale: CGFloat = 1.0
    
    init(
        title: String,
        icon: String? = nil,
        isEnabled: Bool = true,
        fullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isEnabled = isEnabled
        self.fullWidth = fullWidth
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if isEnabled {
                performAction()
            }
        }) {
            HStack(spacing: SuperDesign.Tokens.space.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(textColor)
                }
                
                Text(title)
                    .font(SuperDesign.Tokens.typography.labelLarge)
                    .fontWeight(.medium)
                    .foregroundColor(textColor)
            }
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, SuperDesign.Tokens.space.lg)
            .padding(.vertical, SuperDesign.Tokens.space.md)
            .background(
                RoundedRectangle(cornerRadius: SuperDesign.Tokens.effects.cornerRadius)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: SuperDesign.Tokens.effects.cornerRadius)
                    .stroke(borderColor, lineWidth: SuperDesign.Tokens.effects.borderWidth)
            )
            .scaleEffect(scale)
            .opacity(isEnabled ? 1.0 : SuperDesign.Tokens.effects.opacityDisabled)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
    }
    
    private var textColor: Color {
        if !isEnabled {
            return SuperDesign.Tokens.colors.textSecondary
        }
        return SuperDesign.Tokens.colors.primary
    }
    
    private var backgroundColor: Color {
        if !isEnabled {
            return SuperDesign.Tokens.colors.surface
        }
        return SuperDesign.Tokens.colors.primaryLight
    }
    
    private var borderColor: Color {
        if !isEnabled {
            return SuperDesign.Tokens.colors.border
        }
        return SuperDesign.Tokens.colors.primary
    }
    
    private func performAction() {
        withAnimation(SuperDesign.Tokens.animation.springBouncy) {
            scale = 0.95
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(SuperDesign.Tokens.animation.spring) {
                scale = 1.0
            }
            action()
        }
    }
}

// MARK: - 🔴 Super Floating Button
struct SuperFloatingButton: View {
    let icon: String
    let action: () -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    
    var body: some View {
        Button(action: {
            performAction()
        }) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    SuperDesign.Tokens.colors.primary,
                                    SuperDesign.Tokens.colors.primaryDark
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
                .shadow(
                    color: SuperDesign.Tokens.colors.primary.opacity(0.3),
                    radius: 12,
                    x: 0,
                    y: 6
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func performAction() {
        withAnimation(SuperDesign.Tokens.animation.springBouncy) {
            rotation += 180
            scale = 0.9
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(SuperDesign.Tokens.animation.spring) {
                scale = 1.0
            }
            action()
        }
    }
}

// MARK: - 🃏 Super Card
struct SuperCard<Content: View>: View {
    let elevation: SuperElevation
    let padding: CGFloat?
    let content: Content
    
    init(
        elevation: SuperElevation = .medium,
        padding: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.elevation = elevation
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding ?? SuperDesign.Tokens.space.lg)
            .background(SuperDesign.Tokens.colors.card)
            .cornerRadius(SuperDesign.Tokens.effects.cornerRadius)
            .shadow(
                color: shadowInfo.0,
                radius: shadowInfo.1,
                x: shadowInfo.2,
                y: shadowInfo.3
            )
    }
    
    private var shadowInfo: (Color, CGFloat, CGFloat, CGFloat) {
        SuperDesign.Tokens.effects.shadow(for: elevation)
    }
}

// MARK: - 🌟 Super Featured Card
struct SuperFeaturedCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(SuperDesign.Tokens.space.xl)
            .background(
                RoundedRectangle(cornerRadius: SuperDesign.Tokens.effects.cornerRadiusLarge)
                    .fill(
                        LinearGradient(
                            colors: [
                                SuperDesign.Tokens.colors.card,
                                SuperDesign.Tokens.colors.surface
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: SuperDesign.Tokens.effects.cornerRadiusLarge)
                    .stroke(
                        LinearGradient(
                            colors: [
                                SuperDesign.Tokens.colors.primary.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: SuperDesign.Tokens.colors.primary.opacity(0.1),
                radius: 20,
                x: 0,
                y: 10
            )
    }
}

// MARK: - 📝 Text Component Sizes
enum HeadingSize {
    case small, medium, large, xLarge
    
    var font: Font {
        switch self {
        case .small: return SuperDesign.Tokens.typography.headlineSmall
        case .medium: return SuperDesign.Tokens.typography.headlineMedium
        case .large: return SuperDesign.Tokens.typography.headlineLarge
        case .xLarge: return SuperDesign.Tokens.typography.displaySmall
        }
    }
}

enum BodySize {
    case small, medium, large
    
    var font: Font {
        switch self {
        case .small: return SuperDesign.Tokens.typography.bodySmall
        case .medium: return SuperDesign.Tokens.typography.bodyMedium
        case .large: return SuperDesign.Tokens.typography.bodyLarge
        }
    }
}

// MARK: - 📝 Super Heading
struct SuperHeading: View {
    let text: String
    let size: HeadingSize
    
    var body: some View {
        Text(text)
            .font(size.font)
            .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
            .multilineTextAlignment(.leading)
    }
}

// MARK: - 📝 Super Body
struct SuperBody: View {
    let text: String
    let size: BodySize
    let color: Color?
    
    var body: some View {
        Text(text)
            .font(size.font)
            .foregroundColor(color ?? SuperDesign.Tokens.colors.textSecondary)
            .multilineTextAlignment(.leading)
    }
}

// MARK: - 📝 Super Text Field
struct SuperTextField: View {
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .font(SuperDesign.Tokens.typography.bodyMedium)
        .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
        .padding(SuperDesign.Tokens.space.md)
        .background(SuperDesign.Tokens.colors.surface)
        .cornerRadius(SuperDesign.Tokens.effects.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: SuperDesign.Tokens.effects.cornerRadius)
                .stroke(SuperDesign.Tokens.colors.border, lineWidth: SuperDesign.Tokens.effects.borderWidth)
        )
    }
}

// MARK: - 📝 Super Section
struct SuperSection<Content: View>: View {
    let title: String?
    let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.md) {
            if let title = title {
                SuperHeading(text: title, size: .medium)
                    .padding(.horizontal, SuperDesign.Tokens.space.lg)
            }
            
            content
        }
    }
}

// MARK: - 🎯 View Extensions
extension View {
    func superCard(elevation: SuperElevation = .medium) -> some View {
        SuperDesign.Components.card(elevation: elevation) {
            self
        }
    }
    
    func superFeaturedCard() -> some View {
        SuperDesign.Components.featuredCard {
            self
        }
    }
    
    func superSection(title: String? = nil) -> some View {
        SuperDesign.Components.section(title: title) {
            self
        }
    }
}
