//
//  RitualContentPack.swift
//  JustDad - Ritual de Liberación y Renovación Content Pack
//
//  Paquete de contenido con textos, afirmaciones, votos y prompts para el ritual
//

import Foundation
import SwiftUI

// MARK: - Ritual Content Pack
struct RitualContentPack {
    
    // MARK: - Welcome Messages
    static let welcomeMessages = [
        "El perdón no cambia el pasado; abre tu futuro",
        "Este ritual no justifica el pasado; te libera para elegir mejor hoy",
        "La liberación es un acto de amor hacia ti mismo",
        "Cada ritual es un paso hacia tu sanación y renovación"
    ]
    
    // MARK: - Daily Affirmations (Rotating)
    static let dailyAffirmations = [
        "Yo me perdono",
        "Elijo la paz",
        "Mi presencia es amor",
        "Avanzo con coraje",
        "Hablo con respeto",
        "Dejo el pasado en el pasado",
        "Soy un padre confiable",
        "Merezco amor",
        "Mi paz es prioridad",
        "Soy un padre presente",
        "Elijo el amor sobre el miedo",
        "Me libero de la culpa"
    ]
    
    // MARK: - Verbalization Scripts
    static let verbalizationScripts = VerbalizationScripts()
    
    // MARK: - Behavioral Vows
    static let behavioralVows = BehavioralVows()
    
    // MARK: - Renewal Vows
    static let renewalVows: [BehavioralVow] = [
        BehavioralVow(title: "Llamar a mis hijos", description: "Llamar 15 minutos a mis hijos hoy", category: .children),
        BehavioralVow(title: "Caminar y meditar", description: "Caminar 20 minutos al aire libre y meditar 5 minutos", category: .selfCare),
        BehavioralVow(title: "Responder con respeto", description: "Responder a mi ex solo sobre temas de hijos, sin discutir", category: .exPartner),
        BehavioralVow(title: "Tiempo de calidad", description: "Pasar 30 minutos de tiempo de calidad con mis hijos", category: .children),
        BehavioralVow(title: "Autocuidado", description: "Hacer algo que me guste durante 20 minutos", category: .selfCare),
        BehavioralVow(title: "Comunicación respetuosa", description: "Comunicarme con respeto en todas mis interacciones", category: .emotional),
        BehavioralVow(title: "Ejercicio", description: "Hacer 30 minutos de ejercicio físico", category: .physical),
        BehavioralVow(title: "Reflexión", description: "Reflexionar sobre mis logros del día", category: .spiritual),
        BehavioralVow(title: "Gratitud", description: "Escribir 3 cosas por las que estoy agradecido", category: .spiritual),
        BehavioralVow(title: "Límites saludables", description: "Mantener límites saludables en mis relaciones", category: .emotional)
    ]
    
    // MARK: - Evocation Prompts
    static let evocationPrompts = EvocationPrompts()
    
    // MARK: - Sealing Phrases
    static let sealingPhrases = [
        "Estoy libre. Estoy en paz. El pasado no me gobierna",
        "Me libero con amor y gratitud",
        "Soy libre de elegir mi presente",
        "El pasado queda atrás, el futuro me pertenece",
        "Estoy en paz conmigo mismo",
        "Me abrazo con compasión y amor"
    ]
    
    // MARK: - Integration Messages
    static let integrationMessages = [
        "Has completado un acto de amor hacia ti mismo",
        "La liberación es un proceso, y has dado un paso importante",
        "Tu coraje al enfrentar el pasado es admirable",
        "Cada ritual te acerca más a la paz interior",
        "Eres digno de amor, paz y felicidad",
        "Tu sanación es un regalo para ti y tus seres queridos"
    ]
}

// MARK: - Verbalization Scripts
struct VerbalizationScripts {
    
    let standard = StandardVerbalization()
    let selfForgiveness = SelfForgivenessVerbalization()
    let coparental = CoparentalVerbalization()
    
    struct StandardVerbalization {
        let recognition = "Reconozco lo que pasó y cómo me afectó"
        let forgiveness = "Elijo perdonar y perdonarme"
        let liberation = "Libero el lazo que me une a esta historia y recupero mi energía"
        
        let recognitionAnchors = ["reconozco lo que pasó", "me afectó", "hoy decido mirarlo de frente"]
        let forgivenessAnchors = ["te perdono y me perdono", "elijo comprensión", "me suelto de la culpa"]
        let liberationAnchors = ["libero este lazo", "corto el cordón", "recupero mi paz"]
    }
    
    struct SelfForgivenessVerbalization {
        let recognition = "Reconozco mis errores y cómo me afectaron a mí y a otros"
        let forgiveness = "Me perdono por no haber sabido hacerlo mejor en ese momento"
        let liberation = "Me libero de la culpa y elijo aprender de esta experiencia"
        
        let recognitionAnchors = ["reconozco mis errores", "me afectaron", "hoy acepto mi humanidad"]
        let forgivenessAnchors = ["me perdono", "no sabía hacerlo mejor", "acepto mi imperfección"]
        let liberationAnchors = ["me libero de la culpa", "elijo aprender", "me permito crecer"]
    }
    
    struct CoparentalVerbalization {
        let recognition = "Reconozco la complejidad de nuestra relación coparental"
        let forgiveness = "Elijo perdonar por el bien de nuestros hijos y mi propia paz"
        let liberation = "Me libero de la necesidad de controlar y elijo la armonía"
        
        let recognitionAnchors = ["reconozco la complejidad", "relación coparental", "por el bien de nuestros hijos"]
        let forgivenessAnchors = ["elijo perdonar", "por nuestros hijos", "mi propia paz"]
        let liberationAnchors = ["me libero de controlar", "elijo la armonía", "priorizo el bienestar"]
    }
}

// MARK: - Behavioral Vows
struct BehavioralVows {
    
    let predefinedVows = [
        // Children Category
        BehavioralVow(text: "Hablaré 15 minutos con mis hijos hoy", category: .children),
        BehavioralVow(text: "Haré una actividad lúdica con mis hijos", category: .children),
        BehavioralVow(text: "Les diré a mis hijos que los amo", category: .children),
        
        // Ex-Partner Category
        BehavioralVow(text: "Responderé a mi ex solo por tema de hijos, sin discutir", category: .exPartner),
        BehavioralVow(text: "Mantendré la comunicación respetuosa con mi ex", category: .exPartner),
        BehavioralVow(text: "No revisaré conversaciones pasadas con mi ex", category: .exPartner),
        
        // Self-Care Category
        BehavioralVow(text: "Caminaré 20 minutos y respiraré consciente 5 minutos", category: .selfCare),
        BehavioralVow(text: "Dormiré antes de las 23:00 y evitaré pantallas 1 h antes", category: .selfCare),
        BehavioralVow(text: "Me tomaré 10 minutos de silencio para meditar", category: .selfCare),
        
        // Emotional Category
        BehavioralVow(text: "Escribiré una carta breve de gratitud por algo de hoy", category: .emotional),
        BehavioralVow(text: "Pediré disculpas si hoy reacciono desde el enojo", category: .emotional),
        BehavioralVow(text: "Practicaré la respiración profunda cuando sienta estrés", category: .emotional),
        
        // Physical Category
        BehavioralVow(text: "Haré 20 minutos de ejercicio suave", category: .physical),
        BehavioralVow(text: "Beberé 8 vasos de agua durante el día", category: .physical),
        BehavioralVow(text: "Comeré al menos una comida saludable y balanceada", category: .physical),
        
        // Spiritual Category
        BehavioralVow(text: "Practicaré 10 minutos de meditación o contemplación", category: .spiritual),
        BehavioralVow(text: "Agradeceré por 3 cosas buenas de mi día", category: .spiritual),
        BehavioralVow(text: "Haré un acto de bondad hacia alguien", category: .spiritual)
    ]
    
    func getVowsByCategory(_ category: VowCategory) -> [BehavioralVow] {
        return predefinedVows.filter { $0.category == category }
    }
    
    func getRandomVows(count: Int = 3) -> [BehavioralVow] {
        return Array(predefinedVows.shuffled().prefix(count))
    }
}

// MARK: - Evocation Prompts
struct EvocationPrompts {
    
    let prompts: [RitualFocus: EvocationPrompt] = [
        .exPartner: EvocationPrompt(
            title: "Ex-pareja",
            description: "Liberación de vínculos emocionales con tu ex-pareja",
            prompt: "Nombra en voz alta lo que vas a soltar respecto a tu ex-pareja",
            guidance: "Puedes mencionar resentimientos, expectativas no cumplidas, o patrones que quieres romper",
            examples: [
                "El resentimiento por la forma en que terminó nuestra relación",
                "La necesidad de aprobación de mi ex-pareja",
                "Los patrones de comunicación tóxica que mantenemos"
            ]
        ),
        
        .brokenPromises: EvocationPrompt(
            title: "Promesas Rotas",
            description: "Liberación de promesas incumplidas y expectativas fallidas",
            prompt: "Nombra las promesas rotas que necesitas liberar",
            guidance: "Tanto las promesas que te hicieron como las que no pudiste cumplir",
            examples: [
                "La promesa de estar siempre juntos",
                "Mi promesa de ser el padre perfecto",
                "La promesa de que las cosas mejorarían"
            ]
        ),
        
        .parentalGuilt: EvocationPrompt(
            title: "Culpa Paterna",
            description: "Liberación de culpa relacionada con el rol de padre",
            prompt: "Expresa la culpa que sientes como padre",
            guidance: "Reconoce los sentimientos de culpa sin juzgarte",
            examples: [
                "La culpa por no estar presente todo el tiempo",
                "La culpa por el divorcio y cómo afectó a mis hijos",
                "La culpa por no saber cómo ser el padre que ellos necesitan"
            ]
        ),
        
        .absencePattern: EvocationPrompt(
            title: "Patrón de Ausencia",
            description: "Liberación de patrones familiares de ausencia o abandono",
            prompt: "Reconoce el patrón de ausencia que quieres romper",
            guidance: "Identifica cómo este patrón se repite en tu vida",
            examples: [
                "El patrón de ausencia emocional que heredé",
                "Mi tendencia a alejarme cuando las cosas se complican",
                "La repetición del abandono en mis relaciones"
            ]
        ),
        
        .betrayal: EvocationPrompt(
            title: "Traición",
            description: "Liberación de sentimientos de traición y desconfianza",
            prompt: "Nombra la traición que necesitas liberar",
            guidance: "Reconoce cómo la traición ha afectado tu capacidad de confiar",
            examples: [
                "La traición de confianza en mi relación",
                "Mi propia traición a mis valores",
                "La traición de las expectativas que tenía"
            ]
        ),
        
        .futureFear: EvocationPrompt(
            title: "Miedo al Futuro",
            description: "Liberación de miedos y ansiedades sobre el futuro",
            prompt: "Expresa los miedos al futuro que quieres soltar",
            guidance: "Identifica los miedos que te paralizan o limitan",
            examples: [
                "El miedo a no ser un buen padre",
                "El miedo al rechazo de mis hijos",
                "El miedo a estar solo para siempre"
            ]
        ),
        
        .custom: EvocationPrompt(
            title: "Personalizado",
            description: "Liberación personalizada según tu situación específica",
            prompt: "Nombra en voz alta lo que vas a liberar hoy",
            guidance: "Puedes elegir cualquier aspecto de tu vida que necesite liberación",
            examples: [
                "Escribe tu propio foco de liberación",
                "Sé específico sobre lo que quieres soltar",
                "Conecta con tu intuición para identificar el tema"
            ]
        )
    ]
    
    func getPrompt(for focus: RitualFocus) -> EvocationPrompt {
        return prompts[focus] ?? prompts[.custom]!
    }
}

// MARK: - Evocation Prompt Model
struct EvocationPrompt {
    let title: String
    let description: String
    let prompt: String
    let guidance: String
    let examples: [String]
}

// MARK: - Breathing Guidance
struct BreathingGuidance {
    
    struct BreathingPattern {
        let name: String
        let description: String
        let inhaleCount: Int
        let holdCount: Int
        let exhaleCount: Int
        let cycles: Int
        
        var totalDuration: TimeInterval {
            return TimeInterval((inhaleCount + holdCount + exhaleCount) * cycles)
        }
    }
    
    static let patterns = [
        RitualBreathingPattern.fourSevenEight,
        RitualBreathingPattern.fiveFive,
        RitualBreathingPattern.fourFourFour
    ]
    
    static func getPattern(named name: String) -> RitualBreathingPattern? {
        return RitualBreathingPattern.allPatterns.first { $0.name == name }
    }
    
    static func getDefaultPattern() -> RitualBreathingPattern {
        return .fourSevenEight
    }
}

// MARK: - Safety Messages
struct SafetyMessages {
    
    static let safetyCheckMessages = [
        "¿Cómo te sientes en este momento?",
        "¿Necesitas hacer una pausa?",
        "¿El contenido te está causando angustia?",
        "¿Sientes que puedes continuar de manera segura?"
    ]
    
    static let supportMessages = [
        "Recuerda que no estás solo en este proceso",
        "Es normal sentir emociones intensas durante la liberación",
        "Puedes detener el ritual en cualquier momento",
        "Busca apoyo profesional si lo necesitas"
    ]
    
    static let crisisResources = [
        "Línea Nacional de Prevención del Suicidio: 988",
        "Línea de Crisis de Salud Mental: 1-800-273-8255",
        "Emergencias: 911",
        "Terapeuta o consejero de confianza"
    ]
}

// MARK: - Clinical Disclaimer
struct ClinicalDisclaimer {
    static let text = """
    IMPORTANTE: Este ritual de liberación es una herramienta de apoyo emocional y no sustituye la atención psicológica o psiquiátrica profesional. Si experimentas crisis emocionales, pensamientos de autolesión, o síntomas de depresión o ansiedad severa, busca ayuda profesional inmediatamente.
    
    Este módulo está diseñado como complemento a tu proceso de sanación personal y no reemplaza la terapia individual, de pareja o familiar cuando sea necesaria.
    """
}
