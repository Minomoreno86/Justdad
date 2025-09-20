//
//  EmotionModels.swift
//  JustDad - Emotion Models
//
//  Models for emotional state tracking and entries
//

import Foundation
import SwiftUI

// MARK: - Professional Emotional States
public enum EmotionalState: Int, CaseIterable, Identifiable, Codable {
    case verySad = 1
    case sad = 2
    case neutral = 3
    case happy = 4
    case veryHappy = 5
    
    public var id: Int { rawValue }
    
    public var displayName: String {
        switch self {
        case .verySad: return "Muy Triste"
        case .sad: return "Triste"
        case .neutral: return "Neutral"
        case .happy: return "Feliz"
        case .veryHappy: return "Muy Feliz"
        }
    }
    
    public var icon: String {
        switch self {
        case .verySad: return "face.dashed.fill"
        case .sad: return "face.dashed"
        case .neutral: return "face.smiling"
        case .happy: return "face.smiling.fill"
        case .veryHappy: return "face.smiling.inverse"
        }
    }
    
    public var color: Color {
        switch self {
        case .verySad: return Color.red
        case .sad: return Color.orange
        case .neutral: return Color.yellow
        case .happy: return Color.green
        case .veryHappy: return Color.blue
        }
    }
}

// MARK: - Emotion Entry Model
public struct EmotionEntry: Identifiable, Codable {
    public let id: UUID
    public let emotion: EmotionalState
    public let timestamp: Date
    public let notes: String?
    
    public init(emotion: EmotionalState, notes: String? = nil) {
        self.id = UUID()
        self.emotion = emotion
        self.timestamp = Date()
        self.notes = notes
    }
}