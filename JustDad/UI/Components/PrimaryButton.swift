//
//  PrimaryButton.swift
//  JustDad - Primary button component
//
//  Consistent primary button styling across the app
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    let isEnabled: Bool
    let isLoading: Bool
    let fullWidth: Bool
    
    init(
        _ title: String,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        fullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.fullWidth = fullWidth
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(height: 50)
            .background(
                isEnabled ? Color.blue : Color.gray
            )
            .cornerRadius(12)
        }
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1.0 : 0.6)
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
        
        PrimaryButton("Compact", fullWidth: false) {
            print("Compact button tapped")
        }
    }
    .padding()
}
