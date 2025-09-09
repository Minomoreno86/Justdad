//
//  FloatingSOSButton.swift
//  JustDad - Floating SOS emergency button
//
//  Emergency help button that floats over content
//

import SwiftUI

struct FloatingSOSButton: View {
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                Button(action: action) {
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 60, height: 60)
                            .scaleEffect(isPressed ? 0.95 : 1.0)
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        VStack(spacing: 2) {
                            Text("SOS")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.white)
                            
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = pressing
                    }
                }, perform: {})
                .padding(.trailing, 20)
                .padding(.bottom, 100) // Above tab bar
            }
        }
        .accessibilityLabel("Emergency SOS")
        .accessibilityHint("Tap for emergency help and resources")
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1)
            .ignoresSafeArea()
        
        FloatingSOSButton {
            print("SOS button tapped")
        }
    }
}
