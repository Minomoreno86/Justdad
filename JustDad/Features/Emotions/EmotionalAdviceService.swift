//
//  EmotionalAdviceService.swift
//  JustDad - Professional Emotional Advice System
//
//  Contextual advice and recommendations based on emotional state
//

import Foundation
import SwiftUI

// MARK: - Emotional Advice Service
class EmotionalAdviceService: ObservableObject {
    static let shared = EmotionalAdviceService()
    
    @Published var emotionEntries: [EmotionEntry] = []
    
    private let userDefaults = UserDefaults.standard
    private let emotionEntriesKey = "emotion_entries"
    
    private init() {
        loadEmotionEntries()
    }
    
    // MARK: - Emotion Entry Management
    func addEmotionEntry(_ emotion: EmotionalState, notes: String? = nil) {
        let entry = EmotionEntry(emotion: emotion, notes: notes)
        emotionEntries.append(entry)
        saveEmotionEntries()
    }
    
    func loadEmotionEntries() {
        if let data = userDefaults.data(forKey: emotionEntriesKey),
           let entries = try? JSONDecoder().decode([EmotionEntry].self, from: data) {
            emotionEntries = entries.sorted { $0.timestamp > $1.timestamp }
        }
    }
    
    private func saveEmotionEntries() {
        if let data = try? JSONEncoder().encode(emotionEntries) {
            userDefaults.set(data, forKey: emotionEntriesKey)
        }
    }
    
    func getRecentEmotionEntries(limit: Int = 5) -> [EmotionEntry] {
        return Array(emotionEntries.prefix(limit))
    }
    
    // MARK: - Contextual Advice by Emotional State
    func getAdvice(for emotion: EmotionalState) -> [EmotionalAdvice] {
        switch emotion {
        case .verySad:
            return [
                EmotionalAdvice(
                    title: "Es normal sentirse así",
                    content: "Recuerda: tus hijos te necesitan fuerte. Es válido sentir dolor, pero también es importante cuidarte.",
                    type: .support,
                    priority: .high
                ),
                EmotionalAdvice(
                    title: "Ejercicio de gratitud",
                    content: "Escribe 3 cosas por las que estás agradecido hoy, por pequeñas que sean.",
                    type: .exercise,
                    priority: .medium
                ),
                EmotionalAdvice(
                    title: "Respiración profunda",
                    content: "Inhala por 4 segundos, mantén por 4, exhala por 6. Repite 5 veces.",
                    type: .breathing,
                    priority: .high
                ),
                EmotionalAdvice(
                    title: "Conecta con alguien",
                    content: "Llama a un amigo o familiar de confianza. No tienes que pasar esto solo.",
                    type: .social,
                    priority: .medium
                )
            ]
            
        case .sad:
            return [
                EmotionalAdvice(
                    title: "Un día difícil, pero manejable",
                    content: "Reconoce tu fortaleza. Has superado días difíciles antes y puedes hacerlo de nuevo.",
                    type: .support,
                    priority: .medium
                ),
                EmotionalAdvice(
                    title: "Caminata suave",
                    content: "Sal a caminar 15-20 minutos. El movimiento ayuda a procesar las emociones.",
                    type: .exercise,
                    priority: .medium
                ),
                EmotionalAdvice(
                    title: "Planifica algo especial",
                    content: "Organiza una actividad simple pero especial con tus hijos para esta semana.",
                    type: .planning,
                    priority: .low
                )
            ]
            
        case .neutral:
            return [
                EmotionalAdvice(
                    title: "Momento perfecto para planificar",
                    content: "Aprovecha este equilibrio para organizar actividades con tus hijos o reflexionar sobre tus metas.",
                    type: .planning,
                    priority: .medium
                ),
                EmotionalAdvice(
                    title: "Mantén el equilibrio",
                    content: "Continúa con tus rutinas saludables. La consistencia es clave para el bienestar.",
                    type: .support,
                    priority: .low
                ),
                EmotionalAdvice(
                    title: "Ejercicio moderado",
                    content: "Haz 30 minutos de ejercicio que disfrutes: caminar, correr, o ir al gimnasio.",
                    type: .exercise,
                    priority: .low
                )
            ]
            
        case .happy:
            return [
                EmotionalAdvice(
                    title: "¡Aprovecha esta energía!",
                    content: "Planifica algo especial con tus hijos. Los momentos felices crean recuerdos duraderos.",
                    type: .planning,
                    priority: .high
                ),
                EmotionalAdvice(
                    title: "Comparte tu alegría",
                    content: "Comunica tu estado positivo con alguien importante. La felicidad se multiplica al compartirla.",
                    type: .social,
                    priority: .medium
                ),
                EmotionalAdvice(
                    title: "Documenta el momento",
                    content: "Escribe qué te hizo sentir así. Esto te ayudará a recrear estos momentos en el futuro.",
                    type: .journaling,
                    priority: .low
                )
            ]
            
        case .veryHappy:
            return [
                EmotionalAdvice(
                    title: "¡Un día increíble!",
                    content: "Celebra este momento. Has trabajado duro para llegar aquí y mereces disfrutarlo.",
                    type: .support,
                    priority: .high
                ),
                EmotionalAdvice(
                    title: "Crea recuerdos especiales",
                    content: "Aprovecha esta energía para hacer algo memorable con tus hijos.",
                    type: .planning,
                    priority: .high
                ),
                EmotionalAdvice(
                    title: "Reflexiona sobre el éxito",
                    content: "Analiza qué te llevó a sentirte tan bien para poder replicarlo en el futuro.",
                    type: .journaling,
                    priority: .medium
                )
            ]
        }
    }
    
    // MARK: - Exercise Recommendations by Emotional State
    func getExercises(for emotion: EmotionalState) -> [ExerciseRecommendation] {
        switch emotion {
        case .verySad:
            return [
                ExerciseRecommendation(
                    name: "Yoga Restaurativo",
                    duration: "20-30 min",
                    description: "Posturas suaves que ayudan a procesar emociones",
                    icon: "figure.yoga"
                ),
                ExerciseRecommendation(
                    name: "Caminata en la Naturaleza",
                    duration: "15-20 min",
                    description: "Caminar al aire libre para conectar con el entorno",
                    icon: "figure.walk"
                )
            ]
            
        case .sad:
            return [
                ExerciseRecommendation(
                    name: "Caminata Moderada",
                    duration: "20-30 min",
                    description: "Ritmo constante que ayuda a procesar emociones",
                    icon: "figure.walk"
                ),
                ExerciseRecommendation(
                    name: "Estiramientos Suaves",
                    duration: "10-15 min",
                    description: "Movimientos que liberan tensión emocional",
                    icon: "figure.flexibility"
                )
            ]
            
        case .neutral:
            return [
                ExerciseRecommendation(
                    name: "Ejercicio Regular",
                    duration: "30-45 min",
                    description: "Mantén tu rutina de ejercicio habitual",
                    icon: "figure.strengthtraining.traditional"
                ),
                ExerciseRecommendation(
                    name: "Natación",
                    duration: "30 min",
                    description: "Ejercicio completo y relajante",
                    icon: "figure.pool.swim"
                )
            ]
            
        case .happy:
            return [
                ExerciseRecommendation(
                    name: "Deportes en Equipo",
                    duration: "45-60 min",
                    description: "Aprovecha la energía para actividades sociales",
                    icon: "figure.soccer"
                ),
                ExerciseRecommendation(
                    name: "Baile",
                    duration: "20-30 min",
                    description: "Libera la alegría a través del movimiento",
                    icon: "figure.dance"
                )
            ]
            
        case .veryHappy:
            return [
                ExerciseRecommendation(
                    name: "Cardio Intenso",
                    duration: "30-45 min",
                    description: "Aprovecha la energía para un entrenamiento vigoroso",
                    icon: "figure.run"
                ),
                ExerciseRecommendation(
                    name: "Actividades Aventureras",
                    duration: "60+ min",
                    description: "Haz algo que siempre has querido probar",
                    icon: "figure.climbing"
                )
            ]
        }
    }
}

// MARK: - Emotional Advice Model
struct EmotionalAdvice: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let type: AdviceType
    let priority: Priority
}

enum AdviceType {
    case support
    case exercise
    case breathing
    case social
    case planning
    case journaling
    
    var icon: String {
        switch self {
        case .support: return "heart.fill"
        case .exercise: return "figure.walk"
        case .breathing: return "lungs.fill"
        case .social: return "person.2.fill"
        case .planning: return "calendar"
        case .journaling: return "book.pages"
        }
    }
    
    var color: Color {
        switch self {
        case .support: return .red
        case .exercise: return .green
        case .breathing: return .blue
        case .social: return .orange
        case .planning: return .purple
        case .journaling: return .brown
        }
    }
}

enum Priority {
    case high, medium, low
}

// MARK: - Exercise Recommendation Model
struct ExerciseRecommendation: Identifiable {
    let id = UUID()
    let name: String
    let duration: String
    let description: String
    let icon: String
}
