//
//  OnboardingStepWelcomeView.swift
//  JustDad - Welcome step in onboarding
//
//  First step introducing the app
//

import SwiftUI

struct OnboardingStepWelcomeView: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // App Icon or Illustration
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 20) {
                Text("Welcome to JustDad")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Your personal companion for modern fatherhood. Track emotions, manage finances, plan activities, and connect with other dads.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            VStack(spacing: 16) {
                FeatureHighlight(
                    icon: "shield.fill",
                    title: "Private & Secure",
                    description: "Your data stays on your device"
                )
                
                FeatureHighlight(
                    icon: "clock.fill",
                    title: "Always Available",
                    description: "Works offline, syncs when connected"
                )
                
                FeatureHighlight(
                    icon: "heart.fill",
                    title: "Built for Dads",
                    description: "Designed with fathers in mind"
                )
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

struct FeatureHighlight: View {
    let icon: String
    let title: String
    let description: String
    
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
        }
    }
}

#Preview {
    OnboardingStepWelcomeView()
}
