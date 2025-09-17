//
//  EmptyStateView.swift
//  JustDad - Empty state component
//
//  Enhanced empty state view using SuperDesign System
//  Provides multiple styles and interactive elements
//

import SwiftUI

struct EmptyStateView: View {
    // MARK: - Properties
    let title: String
    let message: String
    let icon: String
    let actionTitle: String?
    let action: (() -> Void)?
    let style: EmptyStateStyle
    let showAnimation: Bool
    let secondaryActionTitle: String?
    let secondaryAction: (() -> Void)?
    
    // MARK: - Initialization
    init(
        title: String,
        message: String,
        icon: String = "text.book.closed",
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        style: EmptyStateStyle = .default,
        showAnimation: Bool = true,
        secondaryActionTitle: String? = nil,
        secondaryAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.actionTitle = actionTitle
        self.action = action
        self.style = style
        self.showAnimation = showAnimation
        self.secondaryActionTitle = secondaryActionTitle
        self.secondaryAction = secondaryAction
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: SuperDesign.Tokens.space.lg) {
            // Icon with animation
            iconView
            
            // Title
            SuperDesign.Components.heading(title, size: .medium)
                .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                .multilineTextAlignment(.center)
            
            // Message
            SuperDesign.Components.body(message, size: .medium)
                .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, SuperDesign.Tokens.space.lg)
            
            // Actions
            actionsView
        }
        .padding(SuperDesign.Tokens.space.xl)
        .background(backgroundView)
        .cornerRadius(SuperDesign.Tokens.effects.cornerRadius)
        .shadow(
            color: SuperDesign.Tokens.effects.shadow(for: .low).0,
            radius: SuperDesign.Tokens.effects.shadow(for: .low).1,
            x: SuperDesign.Tokens.effects.shadow(for: .low).2,
            y: SuperDesign.Tokens.effects.shadow(for: .low).3
        )
    }
    
    // MARK: - Icon View
    private var iconView: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(iconBackgroundColor)
                .frame(width: 100, height: 100)
                .scaleEffect(showAnimation ? iconScale : 1.0)
                .opacity(showAnimation ? iconOpacity : 1.0)
                .animation(
                    Animation.easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true),
                    value: iconScale
                )
            
            // Icon
            Image(systemName: icon)
                .font(.system(size: 40, weight: .medium))
                .foregroundColor(iconColor)
                .scaleEffect(showAnimation ? iconBounceScale : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: iconBounceScale
                )
        }
    }
    
    // MARK: - Actions View
    private var actionsView: some View {
        VStack(spacing: SuperDesign.Tokens.space.sm) {
            // Primary action
            if let actionTitle, let action {
                SuperDesign.Components.primaryButton(
                    title: actionTitle,
                    icon: "plus"
                ) {
                    action()
                }
                .frame(maxWidth: 200)
            }
            
            // Secondary action
            if let secondaryActionTitle, let secondaryAction {
                SuperDesign.Components.secondaryButton(
                    title: secondaryActionTitle
                ) {
                    secondaryAction()
                }
                .frame(maxWidth: 200)
            }
        }
        .padding(.top, SuperDesign.Tokens.space.sm)
    }
    
    // MARK: - Background View
    private var backgroundView: some View {
        Group {
            switch style {
            case .default:
                SuperDesign.Tokens.colors.card
            case .gradient:
                SuperDesign.Tokens.colors.surfaceGradient
            case .transparent:
                Color.clear
            case .accent:
                SuperDesign.Tokens.colors.primary.opacity(0.05)
            }
        }
    }
    
    // MARK: - Computed Properties
    private var iconColor: Color {
        switch style {
        case .default:
            return SuperDesign.Tokens.colors.textSecondary
        case .gradient:
            return SuperDesign.Tokens.colors.primary
        case .transparent:
            return SuperDesign.Tokens.colors.textTertiary
        case .accent:
            return SuperDesign.Tokens.colors.primary
        }
    }
    
    private var iconBackgroundColor: Color {
        switch style {
        case .default:
            return SuperDesign.Tokens.colors.surfaceSecondary
        case .gradient:
            return SuperDesign.Tokens.colors.primary.opacity(0.1)
        case .transparent:
            return Color.clear
        case .accent:
            return SuperDesign.Tokens.colors.primary.opacity(0.15)
        }
    }
    
    // MARK: - Animation States
    @State private var iconScale: CGFloat = 0.9
    @State private var iconOpacity: Double = 0.7
    @State private var iconBounceScale: CGFloat = 1.0
}

// MARK: - Empty State Style Enum
enum EmptyStateStyle {
    case `default`
    case gradient
    case transparent
    case accent
}

#Preview {
    VStack(spacing: 20) {
        EmptyStateView(
            title: "No hay entradas aún",
            message: "Comienza a capturar tus momentos especiales",
            icon: "heart.circle",
            actionTitle: "Agregar entrada",
            action: {}
        )
        
        EmptyStateView(
            title: "Lista vacía",
            message: "No hay elementos para mostrar en este momento"
        )
    }
    .padding()
}