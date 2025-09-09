//
//  SecondaryButton.swift
//  JustDad - Secondary button component
//
//  Secondary button with outline styling
//

import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    let isEnabled: Bool
    let fullWidth: Bool
    
    init(
        _ title: String,
        isEnabled: Bool = true,
        fullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.fullWidth = fullWidth
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body.weight(.medium))
                .foregroundColor(isEnabled ? .blue : .gray)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .frame(height: 50)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isEnabled ? Color.blue : Color.gray, lineWidth: 2)
                )
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
        .accessibilityLabel(title)
    }
}

#Preview {
    VStack(spacing: 16) {
        SecondaryButton("Secondary Action") {
            print("Secondary button tapped")
        }
        
        SecondaryButton("Disabled", isEnabled: false) {
            print("Disabled secondary button tapped")
        }
    }
    .padding()
}
