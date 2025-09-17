//
//  Card_Final.swift
//  JustDad - Card component
//
//  Final card container using direct SuperDesign tokens
//

import SwiftUI

struct Card_Final<Content: View>: View {
    let content: Content
    let elevation: CardElevation
    let padding: CGFloat?
    
    enum CardElevation {
        case none, low, medium, high, highest
        
        var shadow: (Color, CGFloat, CGFloat, CGFloat) {
            switch self {
            case .none:
                return (Color.clear, 0, 0, 0)
            case .low:
                return (Color.black.opacity(0.05), 2, 0, 1)
            case .medium:
                return (Color.black.opacity(0.1), 4, 0, 2)
            case .high:
                return (Color.black.opacity(0.15), 8, 0, 4)
            case .highest:
                return (Color.black.opacity(0.2), 16, 0, 8)
            }
        }
    }
    
    init(
        elevation: CardElevation = .medium,
        padding: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.elevation = elevation
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding ?? 24)
            .background(Color.white) // card background
            .cornerRadius(12)
            .shadow(
                color: shadowInfo.0,
                radius: shadowInfo.1,
                x: shadowInfo.2,
                y: shadowInfo.3
            )
    }
    
    private var shadowInfo: (Color, CGFloat, CGFloat, CGFloat) {
        elevation.shadow
    }
}

#Preview {
    VStack(spacing: 16) {
        Card_Final {
            VStack {
                Text("Card Title")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(Color(red: 0.08, green: 0.09, blue: 0.15))
                Text("This is a card with SuperDesign System styling")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 0.35, green: 0.38, blue: 0.45))
            }
        }
        
        Card_Final(elevation: .high, padding: 20) {
            VStack {
                Text("Elevated Card")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(Color(red: 0.08, green: 0.09, blue: 0.15))
                Text("This card has high elevation and custom padding")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 0.35, green: 0.38, blue: 0.45))
            }
        }
    }
    .padding()
}
