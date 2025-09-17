//
//  PrimaryButton_Simplified.swift
//  JustDad - Primary button component
//
//  Simplified primary button using SuperDesign tokens
//

import SwiftUI

struct PrimaryButton_Simplified: View {
    let title: String
    let action: () -> Void
    let isEnabled: Bool
    let isLoading: Bool
    let fullWidth: Bool
    let icon: String?
    
    init(
        _ title: String,
        icon: String? = nil,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        fullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.fullWidth = fullWidth
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if isEnabled && !isLoading {
                performAction()
            }
        }) {
            HStack(spacing: .superXS) {
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
                    .font(.superLabelLarge)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, .superLG)
            .padding(.vertical, .superMD)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
            )
            .scaleEffect(scale)
            .shadow(
                color: .superPrimary.opacity(0.3),
                radius: 8,
                x: 0,
                y: 4
            )
            .opacity(isEnabled ? 1.0 : 0.6)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled || isLoading)
        .accessibilityLabel(title)
        .accessibilityHint(isEnabled ? "Tap to \(title.lowercased())" : "Button is disabled")
    }
    
    @State private var scale: CGFloat = 1.0
    
    private var backgroundColor: Color {
        if !isEnabled {
            return .superSecondary
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
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        action()
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton_Simplified("Continue") {
            print("Primary button tapped")
        }
        
        PrimaryButton_Simplified("Loading", isLoading: true) {
            print("Loading button tapped")
        }
        
        PrimaryButton_Simplified("Disabled", isEnabled: false) {
            print("Disabled button tapped")
        }
        
        PrimaryButton_Simplified("With Icon", icon: "plus") {
            print("Icon button tapped")
        }
        
        PrimaryButton_Simplified("Compact", fullWidth: false) {
            print("Compact button tapped")
        }
    }
    .padding()
}
