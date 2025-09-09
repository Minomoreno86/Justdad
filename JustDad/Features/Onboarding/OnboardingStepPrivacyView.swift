//
//  OnboardingStepPrivacyView.swift
//  JustDad - Privacy step in onboarding
//
//  Privacy and security explanation
//

import SwiftUI

struct OnboardingStepPrivacyView: View {
    @State private var enableBiometrics = true
    @State private var enableLocalStorage = true
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Privacy Icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
            }
            
            VStack(spacing: 20) {
                Text("Your Privacy Matters")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("JustDad is designed to keep your personal information private and secure. All data is encrypted and stored locally on your device.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            VStack(spacing: 20) {
                PrivacyToggle(
                    icon: "faceid",
                    title: "Biometric Authentication",
                    description: "Use Face ID or Touch ID to secure your data",
                    isEnabled: $enableBiometrics
                )
                
                PrivacyToggle(
                    icon: "internaldrive.fill",
                    title: "Local Storage Only",
                    description: "Data never leaves your device without your permission",
                    isEnabled: $enableLocalStorage
                )
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("No tracking or analytics")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("No data sharing with third parties")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Full control over your information")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

struct PrivacyToggle: View {
    let icon: String
    let title: String
    let description: String
    @Binding var isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    OnboardingStepPrivacyView()
}
