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

// MARK: - Specialized Cards
struct StatsCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    let color: Color
    let action: (() -> Void)?
    
    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String,
        color: Color = .blue,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action ?? {}) {
            Card {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(color)
                        
                        Spacer()
                        
                        if action != nil {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Text(value)
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)
                    
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
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
        
        HStack(spacing: 16) {
            StatsCard(
                title: "Next Visit",
                value: "3 days",
                subtitle: "Weekend with kids",
                icon: "calendar",
                color: .blue
            ) {
                print("Stats card tapped")
            }
            
            StatsCard(
                title: "This Month",
                value: "$1,250",
                subtitle: "+12% vs last month",
                icon: "creditcard.fill",
                color: .green
            )
        }
    }
    .padding()
}
