//
//  Card.swift
//  JustDad - Card component
//
//  Reusable card container with consistent styling
//

import SwiftUI

struct Card<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let backgroundColor: Color
    let shadowRadius: CGFloat
    
    init(
        padding: CGFloat = 16,
        backgroundColor: Color = Color.white,
        shadowRadius: CGFloat = 2,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.backgroundColor = backgroundColor
        self.shadowRadius = shadowRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: shadowRadius, x: 0, y: 1)
    }
}

#Preview {
    VStack(spacing: 16) {
        Card {
            VStack {
                Text("Custom Card Content")
                    .font(.headline)
                Text("This is a custom card with any content")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
    .padding()
}
