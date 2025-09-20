//
//  EmotionArchiveEntryCard.swift
//  JustDad - Emotion Archive Entry Card
//
//  Tarjeta individual para mostrar entradas del archivo de emociones con acciones de editar y borrar.
//

import SwiftUI

#if os(iOS)
import UIKit
#endif

struct EmotionArchiveEntryCard: View {
    let entry: JournalEntry
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showingActions = false
    @StateObject private var journalingService = IntelligentJournalingService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with emotion and date
            HStack {
                // Emotion indicator
                HStack(spacing: 8) {
                    emotionIcon
                    Text(emotionText)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(emotionColor.opacity(0.2))
                .cornerRadius(8)
                
                Spacer()
                
                // Date
                Text(entry.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Actions menu
                Menu {
                    Button("Editar", action: onEdit)
                    Button("Eliminar", role: .destructive, action: onDelete)
                    Button("Compartir", action: shareEntry)
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                }
            }
            
            // Prompt
            if !entry.prompt.text.isEmpty {
                Text(entry.prompt.text)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(6)
            }
            
            // Content
            Text(entry.content)
                .font(.body)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
            
            // Footer with metadata
            HStack {
                // Tags
                if !entry.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(entry.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Audio playback button
                if entry.hasAudio {
                    Button(action: {
                        if journalingService.isPlaying && journalingService.currentPlayingEntry?.id == entry.id {
                            journalingService.pauseAudio()
                        } else {
                            journalingService.playAudio(for: entry)
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: (journalingService.isPlaying && journalingService.currentPlayingEntry?.id == entry.id) ? "pause.circle.fill" : "play.circle.fill")
                                .font(.caption)
                            Text((journalingService.isPlaying && journalingService.currentPlayingEntry?.id == entry.id) ? "Reproduciendo" : "Reproducir")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Word count
                Text("\(entry.content.split(separator: " ").count) palabras")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Computed Properties
    
    private var emotionIcon: some View {
        Group {
            switch entry.emotion {
            case .verySad:
                Image(systemName: "face.dashed.fill")
                    .foregroundColor(.purple)
            case .sad:
                Image(systemName: "face.dashed")
                    .foregroundColor(.blue)
            case .neutral:
                Image(systemName: "face.smiling")
                    .foregroundColor(.gray)
            case .happy:
                Image(systemName: "face.smiling.fill")
                    .foregroundColor(.green)
            case .veryHappy:
                Image(systemName: "face.smiling.inverse")
                    .foregroundColor(.yellow)
            }
        }
        .font(.caption)
    }
    
    private var emotionText: String {
        switch entry.emotion {
        case .verySad: return "Muy Triste"
        case .sad: return "Triste"
        case .neutral: return "Neutral"
        case .happy: return "Feliz"
        case .veryHappy: return "Muy Feliz"
        }
    }
    
    private var emotionColor: Color {
        switch entry.emotion {
        case .verySad: return .purple
        case .sad: return .blue
        case .neutral: return .gray
        case .happy: return .green
        case .veryHappy: return .yellow
        }
    }
    
    // MARK: - Actions
    
    private func shareEntry() {
        let text = """
        \(emotionText) - \(entry.date.formatted(date: .abbreviated, time: .omitted))
        
        Prompt: \(entry.prompt.text)
        
        \(entry.content)
        
        Tags: \(entry.tags.joined(separator: ", "))
        """
        
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        EmotionArchiveEntryCard(
            entry: JournalEntry(
                emotion: .happy,
                prompt: JournalPrompt(
                    text: "¿Qué te hizo sonreír hoy? Describe el momento en detalle.",
                    category: .gratitude,
                    estimatedTime: "5 min"
                ),
                content: "Hoy fue un día increíble. Fuimos al parque con los niños y jugamos fútbol. Ver sus sonrisas me llenó el corazón de alegría. Esos momentos simples son los que más valoro como padre.",
                tags: ["familia", "parque", "diversión", "paternidad"]
            ),
            onEdit: { print("Edit tapped") },
            onDelete: { print("Delete tapped") }
        )
        
        EmotionArchiveEntryCard(
            entry: JournalEntry(
                emotion: .sad,
                prompt: JournalPrompt(
                    text: "¿Qué desafíos enfrentaste hoy como padre?",
                    category: .reflection,
                    estimatedTime: "7 min"
                ),
                content: "A veces me siento abrumado por todas las responsabilidades. Ser padre soltero no es fácil, pero cada día aprendo algo nuevo.",
                tags: ["reflexión", "desafíos"]
            ),
            onEdit: { print("Edit tapped") },
            onDelete: { print("Delete tapped") }
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
