//
//  OnboardingContainerView.swift
//  JustDad - Onboarding container with step management
//
//  Main onboarding flow controller
//

import SwiftUI

struct OnboardingContainerView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentStep = 0
    
    private let totalSteps = 3
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress indicator
                    HStack {
                        ForEach(0..<totalSteps, id: \.self) { step in
                            Capsule()
                                .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                                .frame(height: 4)
                                .animation(.easeInOut, value: currentStep)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    
                    // Step content
                    TabView(selection: $currentStep) {
                        OnboardingStepWelcomeView()
                            .tag(0)
                        
                        OnboardingStepPrivacyView()
                            .tag(1)
                        
                        OnboardingStepGoalsView()
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentStep)
                    
                    // Navigation buttons
                    VStack(spacing: 16) {
                        HStack {
                            if currentStep > 0 {
                                Button("Previous") {
                                    withAnimation {
                                        currentStep -= 1
                                    }
                                }
                                .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(currentStep == totalSteps - 1 ? "Get Started" : "Continue") {
                                if currentStep == totalSteps - 1 {
                                    completeOnboarding()
                                } else {
                                    withAnimation {
                                        currentStep += 1
                                    }
                                }
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(8)
                        }
                        
                        if currentStep < totalSteps - 1 {
                            Button("Skip for now") {
                                completeOnboarding()
                            }
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func completeOnboarding() {
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

#Preview {
    OnboardingContainerView()
}
