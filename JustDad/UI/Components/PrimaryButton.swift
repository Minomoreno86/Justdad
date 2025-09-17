//
//  PrimaryButton.swift
//  JustDad - Primary button component
//
//  Consistent primary button styling using SuperDesign System
//

import SwiftUI

struct PrimaryButton: View {
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
        SuperDesign.Components.primaryButton(
            title: title,
            icon: icon,
            isLoading: isLoading,
            isEnabled: isEnabled,
            fullWidth: fullWidth,
            action: action
        )
        .accessibilityLabel(title)
        .accessibilityHint(isEnabled ? "Tap to \(title.lowercased())" : "Button is disabled")
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton("Continue") {
            print("Primary button tapped")
        }
        
        PrimaryButton("Loading", isLoading: true) {
            print("Loading button tapped")
        }
        
        PrimaryButton("Disabled", isEnabled: false) {
            print("Disabled button tapped")
        }
        
        PrimaryButton("With Icon", icon: "plus") {
            print("Icon button tapped")
        }
        
        PrimaryButton("Compact", fullWidth: false) {
            print("Compact button tapped")
        }
    }
    .padding()
}