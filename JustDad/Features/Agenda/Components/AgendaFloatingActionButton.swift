//
//  AgendaFloatingActionButton.swift
//  JustDad - Agenda Floating Action Button Component
//
//  Professional floating action button with enhanced animations and styling
//

import SwiftUI

struct AgendaFloatingActionButton: View {
    // MARK: - Properties
    let onTap: () -> Void
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Enhanced shadow ring
            Circle()
                .fill(SuperDesign.Tokens.colors.primary.opacity(0.2))
                .frame(width: 64, height: 64)
                .scaleEffect(1.2)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: UUID())
            
            // Main FAB with SuperDesign
            SuperFAB(icon: "plus", size: .large) {
                withAnimation(SuperDesign.Tokens.animation.spring) {
                    onTap()
                }
            }
            .shadow(color: SuperDesign.Tokens.colors.primary.opacity(0.3), radius: 12, x: 0, y: 6)
        }
    }
}
