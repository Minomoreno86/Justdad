//
//  SuperButton.swift
//  JustDad - SuperDesign Modern Button
//
//  Professional Button Implementation
//  Created by Jorge Vasquez rodriguez on 15/9/25.
//

import SwiftUI

// MARK: - Super Button Modern Implementation
struct SuperButton: View {
    let title: String
    let icon: String?
    let style: SuperButtonStyle
    let size: SuperButtonSize
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var scale: CGFloat = 1.0
    
    init(
        title: String,
        icon: String? = nil,
        style: SuperButtonStyle = .primary,
        size: SuperButtonSize = .medium,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            performAction()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: size.iconSize, weight: .medium))
                        .foregroundColor(style.textColor)
                }
                
                if !title.isEmpty {
                    Text(title)
                        .font(size.font)
                        .fontWeight(.medium)
                        .foregroundColor(style.textColor)
                }
            }
            .padding(size.padding)
            .frame(minHeight: size.height)
            .background(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .fill(style.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: style.cornerRadius)
                            .stroke(style.borderColor, lineWidth: style.borderWidth)
                    )
            )
            .scaleEffect(scale)
            .shadow(
                color: style.shadowColor,
                radius: style.shadowRadius,
                x: style.shadowX,
                y: style.shadowY
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onTapGesture {
            performAction()
        }
    }
    
    private func performAction() {
        // Animation feedback
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            scale = 0.95
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                scale = 1.0
            }
            action()
        }
    }
}

// MARK: - Super Button Styles
enum SuperButtonStyle {
    case primary
    case secondary
    case ghost
    case destructive
    case success
    case warning
    
    var backgroundColor: Color {
        switch self {
        case .primary:
            return Color.blue
        case .secondary:
            return Color.blue.opacity(0.1)
        case .ghost:
            return Color.clear
        case .destructive:
            return Color.red
        case .success:
            return Color.green
        case .warning:
            return Color.orange
        }
    }
    
    var textColor: Color {
        switch self {
        case .primary, .destructive, .success, .warning:
            return Color.white
        case .secondary, .ghost:
            return Color.blue
        }
    }
    
    var borderColor: Color {
        switch self {
        case .ghost:
            return Color.gray.opacity(0.3)
        default:
            return Color.clear
        }
    }
    
    var borderWidth: CGFloat {
        switch self {
        case .ghost:
            return 1
        default:
            return 0
        }
    }
    
    var cornerRadius: CGFloat {
        return 8
    }
    
    var shadowColor: Color {
        switch self {
        case .primary, .destructive, .success, .warning:
            return backgroundColor.opacity(0.25)
        default:
            return Color.clear
        }
    }
    
    var shadowRadius: CGFloat {
        switch self {
        case .primary, .destructive, .success, .warning:
            return 4
        default:
            return 0
        }
    }
    
    var shadowX: CGFloat { return 0 }
    var shadowY: CGFloat { return 2 }
}

// MARK: - Super Button Sizes
enum SuperButtonSize {
    case small
    case medium
    case large
    case extraLarge
    
    var height: CGFloat {
        switch self {
        case .small: return 32
        case .medium: return 40
        case .large: return 48
        case .extraLarge: return 56
        }
    }
    
    var padding: EdgeInsets {
        switch self {
        case .small:
            return EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        case .medium:
            return EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        case .large:
            return EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
        case .extraLarge:
            return EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
        }
    }
    
    var font: Font {
        switch self {
        case .small:
            return .system(size: 12, weight: .medium)
        case .medium:
            return .system(size: 14, weight: .medium)
        case .large:
            return .system(size: 16, weight: .medium)
        case .extraLarge:
            return .system(size: 18, weight: .medium)
        }
    }
    
    var iconSize: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 16
        case .large: return 18
        case .extraLarge: return 20
        }
    }
}

// MARK: - Super FAB (Floating Action Button)
struct SuperFAB: View {
    let icon: String
    let size: SuperFABSize
    let action: () -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    
    var body: some View {
        Button(action: {
            performAction()
        }) {
            Image(systemName: icon)
                .font(.system(size: size.iconSize, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: size.diameter, height: size.diameter)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(
                            color: Color.blue.opacity(0.3),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                )
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func performAction() {
        // Rotation and scale animation
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            rotation += 180
            scale = 0.9
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                scale = 1.0
            }
            action()
        }
    }
}

// MARK: - Super FAB Sizes
enum SuperFABSize {
    case mini
    case regular
    case large
    
    var diameter: CGFloat {
        switch self {
        case .mini: return 40
        case .regular: return 56
        case .large: return 64
        }
    }
    
    var iconSize: CGFloat {
        switch self {
        case .mini: return 16
        case .regular: return 24
        case .large: return 28
        }
    }
}

// MARK: - Super Design Extensions
extension View {
    func superButtonStyle(
        _ style: SuperButtonStyle = .primary,
        size: SuperButtonSize = .medium
    ) -> some View {
        modifier(SuperButtonModifier(style: style, size: size))
    }
}

// MARK: - View Modifiers
struct SuperButtonModifier: ViewModifier {
    let style: SuperButtonStyle
    let size: SuperButtonSize
    
    func body(content: Content) -> some View {
        content
            .padding(size.padding)
            .background(style.backgroundColor)
            .foregroundColor(style.textColor)
            .cornerRadius(style.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .stroke(style.borderColor, lineWidth: style.borderWidth)
            )
            .shadow(
                color: style.shadowColor,
                radius: style.shadowRadius,
                x: style.shadowX,
                y: style.shadowY
            )
    }
}
