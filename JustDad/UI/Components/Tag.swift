//
//  Tag.swift
//  JustDad - Tag component for categories and labels
//
//  Small tag component for categorization
//

import SwiftUI

struct Tag: View {
    let text: String
    let color: Color
    let backgroundColor: Color?
    let size: TagSize
    
    enum TagSize {
        case small, medium, large
        
        var font: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .footnote
            }
        }
        
        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6)
            case .medium: return EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
            case .large: return EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
            }
        }
    }
    
    init(
        _ text: String,
        color: Color = .blue,
        backgroundColor: Color? = nil,
        size: TagSize = .medium
    ) {
        self.text = text
        self.color = color
        self.backgroundColor = backgroundColor ?? color.opacity(0.1)
        self.size = size
    }
    
    var body: some View {
        Text(text)
            .font(size.font)
            .fontWeight(.medium)
            .foregroundColor(color)
            .padding(size.padding)
            .background(backgroundColor)
            .cornerRadius(size == .small ? 4 : 6)
    }
}

// MARK: - Category Tags
struct CategoryTag: View {
    let category: String
    
    var color: Color {
        switch category.lowercased() {
        case "education", "educación": return .blue
        case "health", "salud": return .red
        case "food", "alimentación": return .green
        case "transport", "transporte": return .purple
        case "entertainment", "entretenimiento": return .orange
        default: return .gray
        }
    }
    
    var body: some View {
        Tag(category, color: color)
    }
}

// MARK: - Mood Tags
struct MoodTag: View {
    let mood: String
    let emoji: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text(emoji)
                .font(.caption)
            
            Text(mood)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 16) {
        HStack {
            Tag("Small", size: .small)
            Tag("Medium")
            Tag("Large", size: .large)
        }
        
        HStack {
            CategoryTag(category: "Education")
            CategoryTag(category: "Health")
            CategoryTag(category: "Food")
        }
        
        HStack {
            MoodTag(mood: "Happy", emoji: "😊")
            MoodTag(mood: "Sad", emoji: "😔")
            MoodTag(mood: "Neutral", emoji: "😐")
        }
    }
    .padding()
}
