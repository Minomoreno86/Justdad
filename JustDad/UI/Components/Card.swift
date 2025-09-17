//
//  Card.swift
//  JustDad - Card component
//
//  Reusable card container using SuperDesign System
//

import SwiftUI

struct Card<Content: View>: View {
    let content: Content
    let elevation: SuperElevation
    let padding: CGFloat?
    
    init(
        elevation: SuperElevation = .medium,
        padding: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.elevation = elevation
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        SuperDesign.Components.card(
            elevation: elevation,
            padding: padding
        ) {
            content
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        Card {
            VStack {
                SuperDesign.Components.heading("Card Title", size: .medium)
                SuperDesign.Components.body("This is a card with SuperDesign System styling", size: .medium)
            }
        }
        
        Card(elevation: .high, padding: 20) {
            VStack {
                SuperDesign.Components.heading("Elevated Card", size: .medium)
                SuperDesign.Components.body("This card has high elevation and custom padding", size: .medium)
            }
        }
    }
    .padding()
}