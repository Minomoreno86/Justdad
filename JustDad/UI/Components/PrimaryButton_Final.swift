//
//  PrimaryButton_Final.swift
//  JustDad - Primary button component
//
//  Final primary button using direct SuperDesign tokens
//

import SwiftUI

struct PrimaryButton_Final: View {
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
            HStack(spacing: 8) {
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
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
            )
            .scaleEffect(scale)
            .shadow(
                color: Color(red: 0.06, green: 0.47, blue: 0.84).opacity(0.3),
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
            return Color(red: 0.35, green: 0.38, blue: 0.45) // textSecondary
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
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        #endif
        
        action()
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton_Final("Continue") {
            print("Primary button tapped")
        }
        
        PrimaryButton_Final("Loading", isLoading: true) {
            print("Loading button tapped")
        }
        
        PrimaryButton_Final("Disabled", isEnabled: false) {
            print("Disabled button tapped")
        }
        
        PrimaryButton_Final("With Icon", icon: "plus") {
            print("Icon button tapped")
        }
        
        PrimaryButton_Final("Compact", fullWidth: false) {
            print("Compact button tapped")
        }
    }
    .padding()
}
