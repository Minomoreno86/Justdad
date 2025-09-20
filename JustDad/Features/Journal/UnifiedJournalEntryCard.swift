//
//  UnifiedJournalEntryCard.swift
//  JustDad - Unified Journal Entry Card Component
//
//  Reusable card component for displaying journal entries in the unified system.
//

import SwiftUI

struct UnifiedJournalEntryCard: View {
    let entry: UnifiedJournalEntry
    let onTap: () -> Void
    
    @StateObject private var journalingService = UnifiedJournalingService()
    
    private var entryIcon: String {
        switch entry.type {
        case .intelligent(let emotion, _):
            return emotion.icon
        case .traditional(_):
            return "book.closed.fill"
        }
    }
    
    private var entryColor: Color {
        switch entry.type {
        case .intelligent(let emotion, _):
            return emotion.color
        case .traditional(_):
            return .blue
        }
    }
    
    private var entryTitle: String {
        switch entry.type {
        case .intelligent(let emotion, let prompt):
            return prompt.text
        case .traditional(let title):
            return title ?? "Entrada tradicional"
        }
    }
    
    private var entrySubtitle: String {
        switch entry.type {
        case .intelligent(let emotion, _):
            return "Journaling Inteligente • \(emotion.displayName)"
        case .traditional(_):
            return "Journaling Tradicional"
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: entry.date)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: entryIcon)
                        .font(.title2)
                        .foregroundColor(entryColor)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entryTitle)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Text(entrySubtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(formattedDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // Media indicators
                        HStack(spacing: 4) {
                            if entry.audioURLString != nil {
                                Image(systemName: "waveform")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                            
                            if !entry.photoURLStrings.isEmpty {
                                Image(systemName: "photo")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                            }
                            
                            if entry.isEncrypted {
                                Image(systemName: "lock.fill")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
                
                // Content Preview
                if !entry.content.isEmpty {
                    Text(entry.content)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                
                // Tags
                if !entry.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(entry.tags.prefix(5), id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption2)
                                    .foregroundColor(entryColor)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(entryColor.opacity(0.1))
                                    )
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
                
                // Action Buttons (for audio playback)
                if entry.audioURLString != nil {
                    HStack {
                        Button(action: {
                            if journalingService.isPlaying && journalingService.currentPlayingEntry?.id == entry.id {
                                journalingService.stopAudio()
                            } else {
                                journalingService.playAudio(for: entry)
                            }
                        }) {
                            let isCurrentlyPlaying = journalingService.isPlaying && journalingService.currentPlayingEntry?.id == entry.id
                            
                            HStack(spacing: 6) {
                                Image(systemName: isCurrentlyPlaying ? "stop.fill" : "play.fill")
                                    .font(.caption)
                                
                                Text(isCurrentlyPlaying ? "Detener" : "Reproducir audio")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.1))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(entryColor.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Compact Card Variant
struct UnifiedJournalEntryCompactCard: View {
    let entry: UnifiedJournalEntry
    let onTap: () -> Void
    
    private var entryIcon: String {
        switch entry.type {
        case .intelligent(let emotion, _):
            return emotion.icon
        case .traditional(_):
            return "book.closed.fill"
        }
    }
    
    private var entryColor: Color {
        switch entry.type {
        case .intelligent(let emotion, _):
            return emotion.color
        case .traditional(_):
            return .blue
        }
    }
    
    private var entryTitle: String {
        switch entry.type {
        case .intelligent(_, let prompt):
            return prompt.text
        case .traditional(let title):
            return title ?? "Entrada tradicional"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: entryIcon)
                    .font(.title3)
                    .foregroundColor(entryColor)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(entryTitle)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(entry.content)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            if entry.audioURLString != nil {
                                Image(systemName: "waveform")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                            
                            if !entry.photoURLStrings.isEmpty {
                                Image(systemName: "photo")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(entryColor.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 16) {
        UnifiedJournalEntryCard(
            entry: UnifiedJournalEntry(
                emotion: .happy,
                prompt: JournalPrompt(text: "¿Qué te hizo sonreír hoy?", category: .gratitude, estimatedTime: "5 min"),
                content: "Hoy fue un día increíble. Fuimos al parque con los niños y jugamos fútbol. Ver sus sonrisas me llenó el corazón de alegría.",
                tags: ["familia", "parque", "diversión"]
            )
        ) {
            print("Tapped")
        }
        
        UnifiedJournalEntryCompactCard(
            entry: UnifiedJournalEntry(
                title: "Reflexiones nocturnas",
                content: "A veces siento que no soy suficiente, pero luego recuerdo todos los pequeños momentos que comparto con mis hijos.",
                mood: "reflexivo",
                tags: ["reflexión", "paternidad"]
            )
        ) {
            print("Tapped compact")
        }
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
