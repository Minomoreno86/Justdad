import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Bienvenido a SoloPapá")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("La app diseñada para padres divorciados que quieren mantenerse organizados y conectados con sus hijos.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button("Comenzar") {
                onComplete()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
        }
        .padding()
    }
}

#Preview {
    OnboardingView {
        print("Onboarding completed")
    }
}
