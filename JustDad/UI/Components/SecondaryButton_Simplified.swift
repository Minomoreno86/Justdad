//
//  SecondaryButton_Simplified.swift
//  JustDad - Secondary button component
//
//  Simplified secondary button using SuperDesign tokens
//

import SwiftUI

struct SecondaryButton_Simplified: View {
    let title: String
    let action: () -> Void
    let isEnabled: Bool
    let fullWidth: Bool
    let icon: String?
    
    init(
        _ title: String,
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
            HStack(spacing: .superXS) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(textColor)
                }
                
                Text(title)
                    .font(.superLabelLarge)
                    .fontWeight(.medium)
                    .foregroundColor(textColor)
            }
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, .superLG)
            .padding(.vertical, .superMD)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1)
            )
            .scaleEffect(scale)
            .opacity(isEnabled ? 1.0 : 0.6)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
        .accessibilityLabel(title)
        .accessibilityHint(isEnabled ? "Tap to \(title.lowercased())" : "Button is disabled")
    }
    
    @State private var scale: CGFloat = 1.0
    
    private var textColor: Color {
        if !isEnabled {
            return .superSecondary
        }
        return .superPrimary
    }
    
    private var backgroundColor: Color {
        if !isEnabled {
            return .superSurface
        }
        return .superPrimary.opacity(0.1)
    }
    
    private var borderColor: Color {
        if !isEnabled {
            return .superSecondary.opacity(0.3)
        }
        return .superPrimary
    }
    
    private func performAction() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            scale = 0.95
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                scale = 1.0
            }
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        action()
    }
}

#Preview {
    VStack(spacing: 16) {
        SecondaryButton_Simplified("Secondary Action") {
            print("Secondary button tapped")
        }
        
        SecondaryButton_Simplified("With Icon", icon: "arrow.right") {
            print("Icon secondary button tapped")
        }
        
        SecondaryButton_Simplified("Disabled", isEnabled: false) {
            print("Disabled secondary button tapped")
        }
        
        SecondaryButton_Simplified("Compact", fullWidth: false) {
            print("Compact secondary button tapped")
        }
    }
    .padding()
}
