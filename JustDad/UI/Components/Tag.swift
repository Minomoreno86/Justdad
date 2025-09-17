//
//  Tag.swift
//  JustDad - Tag component for categories and labels
//
//  Small tag component using SuperDesign System
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
            case .small: return SuperDesign.Tokens.typography.labelSmall
            case .medium: return SuperDesign.Tokens.typography.labelMedium
            case .large: return SuperDesign.Tokens.typography.labelLarge
            }
        }
        
        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(
                top: SuperDesign.Tokens.space.xxs,
                leading: SuperDesign.Tokens.space.xs,
                bottom: SuperDesign.Tokens.space.xxs,
                trailing: SuperDesign.Tokens.space.xs
            )
            case .medium: return EdgeInsets(
                top: SuperDesign.Tokens.space.xs,
                leading: SuperDesign.Tokens.space.sm,
                bottom: SuperDesign.Tokens.space.xs,
                trailing: SuperDesign.Tokens.space.sm
            )
            case .large: return EdgeInsets(
                top: SuperDesign.Tokens.space.sm,
                leading: SuperDesign.Tokens.space.md,
                bottom: SuperDesign.Tokens.space.sm,
                trailing: SuperDesign.Tokens.space.md
            )
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .small: return SuperDesign.Tokens.effects.cornerRadiusSmall
            case .medium: return SuperDesign.Tokens.effects.cornerRadius
            case .large: return SuperDesign.Tokens.effects.cornerRadius
            }
        }
    }
    
    init(
        _ text: String,
        color: Color = SuperDesign.Tokens.colors.primary,
        backgroundColor: Color? = nil,
        size: TagSize = .medium
    ) {
        self.text = text
        self.color = color
        self.backgroundColor = backgroundColor ?? color.opacity(SuperDesign.Tokens.effects.opacitySubtle)
        self.size = size
    }
    
    var body: some View {
        SuperDesign.Components.body(text, size: .small)
            .font(size.font)
            .fontWeight(.medium)
            .foregroundColor(color)
            .padding(size.padding)
            .background(backgroundColor)
            .cornerRadius(size.cornerRadius)
    }
}

// MARK: - Category Tags
struct CategoryTag: View {
    let category: String
    
    var color: Color {
        switch category.lowercased() {
        case "education", "educación": return SuperDesign.Tokens.colors.info
        case "health", "salud": return SuperDesign.Tokens.colors.error
        case "food", "alimentación": return SuperDesign.Tokens.colors.success
        case "transport", "transporte": return SuperDesign.Tokens.colors.primary
        case "entertainment", "entretenimiento": return SuperDesign.Tokens.colors.warning
        default: return SuperDesign.Tokens.colors.textSecondary
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
        HStack(spacing: SuperDesign.Tokens.space.xxs) {
            Text(emoji)
                .font(SuperDesign.Tokens.typography.labelSmall)
            
            SuperDesign.Components.body(mood, size: .small)
                .fontWeight(.medium)
        }
        .padding(.horizontal, SuperDesign.Tokens.space.sm)
        .padding(.vertical, SuperDesign.Tokens.space.xs)
        .background(SuperDesign.Tokens.colors.surfaceSecondary)
        .cornerRadius(SuperDesign.Tokens.effects.cornerRadiusSmall)
    }
}

// MARK: - Status Tags
struct StatusTag: View {
    let status: String
    let isActive: Bool
    
    var color: Color {
        isActive ? SuperDesign.Tokens.colors.success : SuperDesign.Tokens.colors.textSecondary
    }
    
    var body: some View {
        HStack(spacing: SuperDesign.Tokens.space.xxs) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            
            SuperDesign.Components.body(status, size: .small)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
        .padding(.horizontal, SuperDesign.Tokens.space.sm)
        .padding(.vertical, SuperDesign.Tokens.space.xs)
        .background(color.opacity(SuperDesign.Tokens.effects.opacitySubtle))
        .cornerRadius(SuperDesign.Tokens.effects.cornerRadiusSmall)
    }
}

#Preview {
    VStack(spacing: SuperDesign.Tokens.space.lg) {
        // Basic tags
        HStack {
            Tag("Pequeño", size: .small)
            Tag("Mediano")
            Tag("Grande", size: .large)
        }
        
        // Category tags
        HStack {
            CategoryTag(category: "Educación")
            CategoryTag(category: "Salud")
            CategoryTag(category: "Alimentación")
        }
        
        // Mood tags
        HStack {
            MoodTag(mood: "Feliz", emoji: "😊")
            MoodTag(mood: "Triste", emoji: "😔")
            MoodTag(mood: "Neutral", emoji: "😐")
        }
        
        // Status tags
        HStack {
            StatusTag(status: "Activo", isActive: true)
            StatusTag(status: "Inactivo", isActive: false)
        }
    }
    .padding()
}