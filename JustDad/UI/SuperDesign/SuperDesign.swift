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
            action: @escaping () -> Void
        ) -> some View {
            SuperPrimaryButton(title: title, icon: icon, action: action)
        }
        
        static func secondaryButton(
            title: String,
            icon: String? = nil,
            action: @escaping () -> Void
        ) -> some View {
            SuperSecondaryButton(title: title, icon: icon, action: action)
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
            @ViewBuilder content: () -> Content
        ) -> some View {
            SuperCard(elevation: elevation, content: content)
        }
        
        static func featuredCard<Content: View>(
            @ViewBuilder content: () -> Content
        ) -> some View {
            SuperFeaturedCard(content: content)
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

// MARK: - 🎨 Color Tokens
struct ColorTokens {
    // Primary brand colors
    let primary = Color.blue
    let primaryLight = Color.blue.opacity(0.1)
    let primaryDark = Color(red: 0.0, green: 0.3, blue: 0.8)
    
    // Surface colors
    let background = Color(red: 0.98, green: 0.98, blue: 1.0)
    let surface = Color(red: 0.95, green: 0.95, blue: 0.97)
    let card = Color.white
    
    // Text colors
    let textPrimary = Color.primary
    let textSecondary = Color.secondary
    let textTertiary = Color.gray
    
    // Semantic colors
    let success = Color.green
    let warning = Color.orange
    let error = Color.red
    let info = Color.blue
    
    // Border colors
    let border = Color.gray.opacity(0.3)
    let borderLight = Color.gray.opacity(0.1)
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
    let cornerRadius: CGFloat = 12
    let cornerRadiusSmall: CGFloat = 8
    let cornerRadiusLarge: CGFloat = 16
    
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
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            performAction()
        }) {
            HStack(spacing: SuperDesign.Tokens.space.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .font(SuperDesign.Tokens.typography.labelLarge)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, SuperDesign.Tokens.space.lg)
            .padding(.vertical, SuperDesign.Tokens.space.md)
            .background(
                RoundedRectangle(cornerRadius: SuperDesign.Tokens.effects.cornerRadius)
                    .fill(SuperDesign.Tokens.colors.primary)
            )
            .scaleEffect(scale)
            .shadow(
                color: SuperDesign.Tokens.colors.primary.opacity(0.3),
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(PlainButtonStyle())
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
    let action: () -> Void
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            performAction()
        }) {
            HStack(spacing: SuperDesign.Tokens.space.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(SuperDesign.Tokens.colors.primary)
                }
                
                Text(title)
                    .font(SuperDesign.Tokens.typography.labelLarge)
                    .fontWeight(.medium)
                    .foregroundColor(SuperDesign.Tokens.colors.primary)
            }
            .padding(.horizontal, SuperDesign.Tokens.space.lg)
            .padding(.vertical, SuperDesign.Tokens.space.md)
            .background(
                RoundedRectangle(cornerRadius: SuperDesign.Tokens.effects.cornerRadius)
                    .fill(SuperDesign.Tokens.colors.primaryLight)
            )
            .scaleEffect(scale)
        }
        .buttonStyle(PlainButtonStyle())
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
    let content: Content
    
    init(
        elevation: SuperElevation = .medium,
        @ViewBuilder content: () -> Content
    ) {
        self.elevation = elevation
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(SuperDesign.Tokens.space.lg)
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
}
