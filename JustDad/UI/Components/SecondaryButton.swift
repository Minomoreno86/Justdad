//
//  SecondaryButton.swift
//  JustDad - Secondary button component
//
//  Secondary button with outline styling using SuperDesign System
//

import SwiftUI

struct SecondaryButton: View {
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
        SuperDesign.Components.secondaryButton(
            title: title,
            icon: icon,
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
        SecondaryButton("Secondary Action") {
            print("Secondary button tapped")
        }
        
        SecondaryButton("With Icon", icon: "arrow.right") {
            print("Icon secondary button tapped")
        }
        
        SecondaryButton("Disabled", isEnabled: false) {
            print("Disabled secondary button tapped")
        }
        
        SecondaryButton("Compact", fullWidth: false) {
            print("Compact secondary button tapped")
        }
    }
    .padding()
}