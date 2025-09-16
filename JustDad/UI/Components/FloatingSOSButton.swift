//
//  FloatingSOSButton.swift
//  JustDad - SuperDesign SOS Button
//
//  Enhanced SOS Button with SuperDesign
//  Created by Jorge Vasquez rodriguez on 15/9/25.
//

import SwiftUI

struct FloatingSOSButton: View {
    let action: () -> Void
    
    @State private var isPulsing = false
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                Button(action: {
                    performSOSAction()
                }) {
                    ZStack {
                        // Pulsing background effect
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.red.opacity(0.3),
                                        Color.red.opacity(0.1)
                                    ],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 40
                                )
                            )
                            .frame(width: 80, height: 80)
                            .scaleEffect(isPulsing ? 1.2 : 1.0)
                            .opacity(isPulsing ? 0.6 : 0.8)
                            .animation(
                                Animation
                                    .easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true),
                                value: isPulsing
                            )
                        
                        // Main button
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.red,
                                        Color.red.opacity(0.8)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                            .shadow(
                                color: Color.red.opacity(0.4),
                                radius: 12,
                                x: 0,
                                y: 6
                            )
                            .scaleEffect(scale)
                            .rotationEffect(.degrees(rotation))
                        
                        VStack(spacing: 2) {
                            Text("SOS")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 0, y: 1)
                            
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 0, y: 1)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .onAppear {
                    isPulsing = true
                }
                .padding(.trailing, 20)
                .padding(.bottom, 100) // Space for tab bar
            }
        }
        .allowsHitTesting(true)
        .accessibilityLabel("Emergency SOS")
        .accessibilityHint("Double tap for emergency assistance")
    }
    
    private func performSOSAction() {
        // Stop pulsing temporarily
        isPulsing = false
        
        // Urgent animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            scale = 0.8
            rotation += 360
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                scale = 1.0
            }
            
            // Resume pulsing after action
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isPulsing = true
            }
            
            action()
        }
    }
}
