//
//  SecondaryButton_Final.swift
//  JustDad - Secondary button component
//
//  Final secondary button using direct SuperDesign tokens
//

import SwiftUI

struct SecondaryButton_Final: View {
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
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(textColor)
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textColor)
            }
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
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
            return Color(red: 0.35, green: 0.38, blue: 0.45) // textSecondary
        }
        return Color(red: 0.06, green: 0.47, blue: 0.84) // primary
    }
    
    private var backgroundColor: Color {
        if !isEnabled {
            return Color.white // surface
        }
        return Color(red: 0.55, green: 0.75, blue: 0.95).opacity(0.1) // primaryLight
    }
    
    private var borderColor: Color {
        if !isEnabled {
            return Color(red: 0.35, green: 0.38, blue: 0.45).opacity(0.3) // textSecondary
        }
        return Color(red: 0.06, green: 0.47, blue: 0.84) // primary
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
        #if canImport(UIKit)
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        #endif
        
        action()
    }
}

#Preview {
    VStack(spacing: 16) {
        SecondaryButton_Final("Secondary Action") {
            print("Secondary button tapped")
        }
        
        SecondaryButton_Final("With Icon", icon: "arrow.right") {
            print("Icon secondary button tapped")
        }
        
        SecondaryButton_Final("Disabled", isEnabled: false) {
            print("Disabled secondary button tapped")
        }
        
        SecondaryButton_Final("Compact", fullWidth: false) {
            print("Compact secondary button tapped")
        }
    }
    .padding()
}
