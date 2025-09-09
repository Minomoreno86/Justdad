//
//  Typography.swift
//  JustDad - Typography system
//
//  Centralized typography definitions for consistent text styling
//

import SwiftUI

struct Typography {
    // MARK: - Base Typography Tokens
    static let display = Font.system(size: 32, weight: .bold, design: .default)
    static let displayLarge = Font.system(size: 36, weight: .bold, design: .default)
    static let displayMedium = Font.system(size: 32, weight: .bold, design: .default)
    static let displaySmall = Font.system(size: 28, weight: .bold, design: .default)
    static let title = Font.title
    static let titleLarge = Font.title
    static let titleMedium = Font.title2
    static let titleSmall = Font.title3
    static let subtitle = Font.title2
    static let headline = Font.headline
    static let body = Font.body
    static let bodyMedium = Font.body
    static let bodySmall = Font.callout
    static let callout = Font.callout
    static let caption = Font.caption
    static let captionMedium = Font.caption
    static let footnote = Font.footnote
    static let button = Font.body.weight(.medium)
    
    // MARK: - Legacy Support (existing tokens)
    static let largeTitle = Font.largeTitle
    static let title1 = Font.title
    static let title2 = Font.title2
    static let title3 = Font.title3
    static let subheadline = Font.subheadline
    static let caption1 = Font.caption
    static let caption2 = Font.caption2
    
    // MARK: - Custom Styles
    static let cardTitle = Font.headline.weight(.semibold)
    static let buttonText = Font.body.weight(.medium)
    static let navigationTitle = Font.title2.weight(.bold)
    
    // MARK: - Emotion Text
    static let moodEmoji = Font.system(size: 32)
    static let moodLabel = Font.caption.weight(.medium)
    
    // MARK: - Financial Text
    static let currencyLarge = Font.title2.weight(.bold).monospacedDigit()
    static let currencySmall = Font.body.weight(.medium).monospacedDigit()
    
    // MARK: - Accessibility
    static func scaledFont(_ style: Font.TextStyle, size: CGFloat) -> Font {
        return Font.system(size: size, design: .default)
    }
}
