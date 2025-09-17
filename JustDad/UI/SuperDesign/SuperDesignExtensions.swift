//
//  SuperDesignExtensions.swift
//  JustDad - SuperDesign Extensions
//
//  Extensions to make SuperDesign more accessible throughout the app
//

import SwiftUI

// MARK: - View Extensions for Easy Access
// Note: These extensions are already defined in SuperDesign.swift
// This file provides additional convenience methods

// MARK: - Quick Typography Access
extension Text {
    func superHeading(size: HeadingSize = .large) -> some View {
        self
            .font(size.font)
            .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
    }
    
    func superBody(size: BodySize = .medium, color: Color? = nil) -> some View {
        self
            .font(size.font)
            .foregroundColor(color ?? SuperDesign.Tokens.colors.textSecondary)
    }
}

// MARK: - Quick Color Access
extension Color {
    static let superPrimary = SuperDesign.Tokens.colors.primary
    static let superSecondary = SuperDesign.Tokens.colors.textSecondary
    static let superSuccess = SuperDesign.Tokens.colors.success
    static let superWarning = SuperDesign.Tokens.colors.warning
    static let superError = SuperDesign.Tokens.colors.error
    static let superInfo = SuperDesign.Tokens.colors.info
    static let superCard = SuperDesign.Tokens.colors.card
    static let superSurface = SuperDesign.Tokens.colors.surface
    static let superBackground = SuperDesign.Tokens.colors.background
}

// MARK: - Quick Spacing Access
extension CGFloat {
    static let superXS = SuperDesign.Tokens.space.xs
    static let superSM = SuperDesign.Tokens.space.sm
    static let superMD = SuperDesign.Tokens.space.md
    static let superLG = SuperDesign.Tokens.space.lg
    static let superXL = SuperDesign.Tokens.space.xl
}

// MARK: - Quick Font Access
extension Font {
    static let superHeadingLarge = SuperDesign.Tokens.typography.headlineLarge
    static let superHeadingMedium = SuperDesign.Tokens.typography.headlineMedium
    static let superHeadingSmall = SuperDesign.Tokens.typography.headlineSmall
    static let superTitleLarge = SuperDesign.Tokens.typography.titleLarge
    static let superTitleMedium = SuperDesign.Tokens.typography.titleMedium
    static let superTitleSmall = SuperDesign.Tokens.typography.titleSmall
    static let superBodyLarge = SuperDesign.Tokens.typography.bodyLarge
    static let superBodyMedium = SuperDesign.Tokens.typography.bodyMedium
    static let superBodySmall = SuperDesign.Tokens.typography.bodySmall
    static let superLabelLarge = SuperDesign.Tokens.typography.labelLarge
    static let superLabelMedium = SuperDesign.Tokens.typography.labelMedium
    static let superLabelSmall = SuperDesign.Tokens.typography.labelSmall
}
