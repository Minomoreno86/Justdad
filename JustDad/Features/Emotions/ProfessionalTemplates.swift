//
//  ProfessionalTemplatesUpdated.swift
//  JustDad - Professional Therapeutic Templates (Updated)
//
//  Plantillas terapéuticas profesionales para técnicas de liberación con escritura opcional
//

import Foundation
import SwiftUI

// MARK: - Professional Template System
struct ProfessionalTemplate {
    let technique: HybridLiberationService.HybridTechnique
    let steps: [TemplateStep]
    let therapeuticApproach: HybridLiberationService.TherapeuticApproach
    let spiritualElement: HybridLiberationService.SpiritualElement
    
    struct TemplateStep: Identifiable {
        let id = UUID()
        let number: Int
        let title: String
        let description: String
        let duration: String
        let therapeuticPrompt: String
        let spiritualGuidance: String
        let requiresHandwriting: Bool
        let handwritingOptional: Bool
        let requiresRitualElements: Bool
        let emotionalCheckpoint: Bool
        let meditationText: String?
        let instructions: [String]
    }
}

// MARK: - Template Factory
class ProfessionalTemplateFactory {
    static func createTemplate(for technique: HybridLiberationService.HybridTechnique) -> ProfessionalTemplate {
        switch technique {
        case .forgivenessTherapy:
            return createForgivenessTherapyTemplate()
        case .liberationLetter:
            return createLiberationLetterTemplate()
        case .psychogenealogy:
            return createPsychogenealogyTemplate()
        case .liberationRitual:
            return createLiberationRitualTemplate()
        case .energeticCords:
            return createEnergeticCordsTemplate()
        case .pastLifeBonds:
            return createPastLifeBondsTemplate()
        }
    }
    
    // MARK: - Forgiveness Therapy Template
    private static func createForgivenessTherapyTemplate() -> ProfessionalTemplate {
        return ProfessionalTemplate(
            technique: .forgivenessTherapy,
            steps: [
                ProfessionalTemplate.TemplateStep(
                    number: 1,
                    title: "Preparación y Centrado",
                    description: "Prepara tu espacio y centra tu mente para el trabajo de perdón",
                    duration: "3-5 min",
                    therapeuticPrompt: "¿Qué persona o situación necesitas perdonar? Identifica específicamente lo que te duele.",
                    spiritualGuidance: "Conecta con tu corazón y abre tu mente a la compasión",
                    requiresHandwriting: false,
                    handwritingOptional: true,
                    requiresRitualElements: true,
                    emotionalCheckpoint: true,
                    meditationText: "Inhala paz, exhala tensión. Permítete estar presente en este momento de sanación.",
                    instructions: [
                        "Enciende una vela blanca",
                        "Coloca un cristal de cuarzo rosa cerca",
                        "Siéntate cómodamente con la espalda recta",
                        "Cierra los ojos y respira profundamente"
                    ]
                ),
                ProfessionalTemplate.TemplateStep(
                    number: 2,
                    title: "Identificación del Dolor",
                    description: "Identifica específicamente qué te duele y por qué",
                    duration: "5-7 min",
                    therapeuticPrompt: "Escribe específicamente qué te duele de esta situación. ¿Qué emociones sientes? ¿Qué pensamientos tienes?",
                    spiritualGuidance: "Observa sin juzgar. Las emociones son mensajeras, no enemigas",
                    requiresHandwriting: true,
                    handwritingOptional: true,
                    requiresRitualElements: false,
                    emotionalCheckpoint: true,
                    meditationText: "Observa sin juzgar. Permite que las emociones surjan naturalmente.",
                    instructions: [
                        "Toma papel y lápiz (opcional)",
                        "Escribe libremente sobre lo que te duele",
                        "No te preocupes por la gramática o coherencia",
                        "Permite que las emociones fluyan"
                    ]
                ),
                ProfessionalTemplate.TemplateStep(
                    number: 3,
                    title: "Comprensión y Empatía",
                    description: "Intenta entender las circunstancias que llevaron a esa situación",
                    duration: "5-7 min",
                    therapeuticPrompt: "¿Qué circunstancias pudo haber vivido la otra persona? ¿Qué dolor pudo haberla llevado a actuar así?",
                    spiritualGuidance: "Todos somos humanos, todos cometemos errores. La compasión es la clave del perdón",
                    requiresHandwriting: true,
                    handwritingOptional: true,
                    requiresRitualElements: false,
                    emotionalCheckpoint: true,
                    meditationText: "Todos somos humanos, todos cometemos errores. La compasión es la clave del perdón.",
                    instructions: [
                        "Reflexiona sobre la humanidad de la otra persona",
                        "Considera qué dolor pudo haberla llevado a actuar así",
                        "Escribe sobre tu comprensión (opcional)",
                        "Practica la empatía"
                    ]
                ),
                ProfessionalTemplate.TemplateStep(
                    number: 4,
                    title: "Perdón Consciente",
                    description: "Practica el perdón consciente hacia la otra persona y hacia ti mismo",
                    duration: "5-7 min",
                    therapeuticPrompt: "Repite mentalmente: 'Te perdono por tu dolor. Me perdono por mi dolor. Libero esta carga con amor.'",
                    spiritualGuidance: "El perdón es un regalo que te das a ti mismo. Te libera del pasado",
                    requiresHandwriting: true,
                    handwritingOptional: true,
                    requiresRitualElements: false,
                    emotionalCheckpoint: true,
                    meditationText: "Te perdono por tu dolor. Me perdono por mi dolor. Libero esta carga con amor.",
                    instructions: [
                        "Escribe una carta de perdón (opcional)",
                        "Incluye perdón hacia la otra persona",
                        "Incluye perdón hacia ti mismo",
                        "Usa palabras de amor y compasión"
                    ]
                ),
                ProfessionalTemplate.TemplateStep(
                    number: 5,
                    title: "Liberación y Renovación",
                    description: "Visualiza la liberación de la carga y la renovación de tu corazón",
                    duration: "5-7 min",
                    therapeuticPrompt: "Visualiza la situación siendo liberada como una nube que se disipa en el cielo. ¿Cómo te sientes ahora?",
                    spiritualGuidance: "Visualiza la situación elevándose como una nube blanca, llevándose todo el dolor",
                    requiresHandwriting: true,
                    handwritingOptional: true,
                    requiresRitualElements: true,
                    emotionalCheckpoint: true,
                    meditationText: "Visualiza la situación elevándose como una nube blanca, llevándose todo el dolor.",
                    instructions: [
                        "Visualiza la situación siendo liberada",
                        "Imagina una luz dorada llenando tu corazón",
                        "Escribe sobre tu nueva perspectiva (opcional)",
                        "Realiza un ritual de liberación simbólico"
                    ]
                )
            ],
            therapeuticApproach: .cognitiveBehavioral,
            spiritualElement: .meditation
        )
    }
    
    // MARK: - Liberation Letter Template
    private static func createLiberationLetterTemplate() -> ProfessionalTemplate {
        return ProfessionalTemplate(
            technique: .liberationLetter,
            steps: [
                ProfessionalTemplate.TemplateStep(
                    number: 1,
                    title: "Preparación del Espacio",
                    description: "Prepara un espacio sagrado para la escritura terapéutica",
                    duration: "2-3 min",
                    therapeuticPrompt: "¿A quién o qué necesitas escribirle? ¿Qué necesitas liberar?",
                    spiritualGuidance: "Este espacio es sagrado. Aquí me conecto con mi esencia divina",
                    requiresHandwriting: false,
                    handwritingOptional: true,
                    requiresRitualElements: true,
                    emotionalCheckpoint: false,
                    meditationText: "Este espacio es sagrado. Aquí me conecto con mi esencia divina.",
                    instructions: [
                        "Consigue papel blanco de calidad",
                        "Prepara una pluma o lápiz cómodo",
                        "Enciende una vela blanca",
                        "Crea un ambiente tranquilo y privado"
                    ]
                ),
                ProfessionalTemplate.TemplateStep(
                    number: 2,
                    title: "Escritura Libre",
                    description: "Escribe todo lo que sientes sin filtros ni censura",
                    duration: "10-15 min",
                    therapeuticPrompt: "Escribe todo lo que sientes sobre esta situación. No te preocupes por la gramática, solo deja fluir las emociones.",
                    spiritualGuidance: "Deja que tu corazón escriba. No hay reglas, solo honestidad",
                    requiresHandwriting: true,
                    handwritingOptional: true,
                    requiresRitualElements: false,
                    emotionalCheckpoint: true,
                    meditationText: "Deja que tu corazón escriba. No hay reglas, solo honestidad.",
                    instructions: [
                        "Escribe sin parar durante 10-15 minutos",
                        "No te preocupes por la gramática o coherencia",
                        "Permite que las emociones fluyan libremente",
                        "Escribe todo lo que necesites decir"
                    ]
                ),
                ProfessionalTemplate.TemplateStep(
                    number: 3,
                    title: "Expresión de Emociones",
                    description: "Expresa específicamente tus emociones: rabia, tristeza, miedo, etc.",
                    duration: "5-10 min",
                    therapeuticPrompt: "¿Qué emociones específicas sientes? Escribe sobre cada una: rabia, tristeza, miedo, decepción, etc.",
                    spiritualGuidance: "Es seguro sentir. Las emociones son mensajeras, no enemigas",
                    requiresHandwriting: true,
                    handwritingOptional: true,
                    requiresRitualElements: false,
                    emotionalCheckpoint: true,
                    meditationText: "Es seguro sentir. Las emociones son mensajeras, no enemigas.",
                    instructions: [
                        "Identifica cada emoción específica",
                        "Escribe sobre cada una por separado",
                        "Permítete sentir completamente",
                        "No juzgues tus emociones"
                    ]
                ),
                ProfessionalTemplate.TemplateStep(
                    number: 4,
                    title: "Carta de Perdón",
                    description: "Escribe una carta de perdón hacia la otra persona y hacia ti mismo",
                    duration: "10-15 min",
                    therapeuticPrompt: "Escribe una carta de perdón. Incluye perdón hacia la otra persona y hacia ti mismo. Usa palabras de amor y compasión.",
                    spiritualGuidance: "El perdón es un regalo que te das a ti mismo. Te libera del pasado",
                    requiresHandwriting: true,
                    handwritingOptional: true,
                    requiresRitualElements: false,
                    emotionalCheckpoint: true,
                    meditationText: "El perdón es un regalo que te das a ti mismo. Te libera del pasado.",
                    instructions: [
                        "Escribe una carta formal de perdón",
                        "Incluye perdón hacia la otra persona",
                        "Incluye perdón hacia ti mismo",
                        "Usa palabras de amor y compasión"
                    ]
                ),
                ProfessionalTemplate.TemplateStep(
                    number: 5,
                    title: "Ritual de Liberación",
                    description: "Realiza un ritual simbólico para liberar la carta y las emociones",
                    duration: "5-10 min",
                    therapeuticPrompt: "¿Cómo quieres liberar esta carta? ¿Quemarla, enterrarla, o guardarla? ¿Qué simboliza para ti?",
                    spiritualGuidance: "Con este acto simbólico, libero estas emociones al universo",
                    requiresHandwriting: false,
                    handwritingOptional: true,
                    requiresRitualElements: true,
                    emotionalCheckpoint: true,
                    meditationText: "Con este acto simbólico, libero estas emociones al universo.",
                    instructions: [
                        "Decide cómo quieres liberar la carta",
                        "Realiza el ritual simbólico",
                        "Visualiza las emociones siendo liberadas",
                        "Agradece por la liberación"
                    ]
                )
            ],
            therapeuticApproach: .expressiveTherapy,
            spiritualElement: .ritual
        )
    }
    
    // MARK: - Psychogenealogy Template
    private static func createPsychogenealogyTemplate() -> ProfessionalTemplate {
        return ProfessionalTemplate(
            technique: .psychogenealogy,
            steps: [
                ProfessionalTemplate.TemplateStep(
                    number: 1,
                    title: "Construcción del Árbol Genealógico",
                    description: "Crea tu árbol genealógico con información relevante",
                    duration: "10-15 min",
                    therapeuticPrompt: "¿Qué información tienes sobre tu familia? Nombres, fechas, profesiones, causas de muerte, etc.",
                    spiritualGuidance: "Observa los patrones que se repiten. No juzgues, solo observa",
                    requiresHandwriting: true,
                    handwritingOptional: true,
                    requiresRitualElements: true,
                    emotionalCheckpoint: false,
                    meditationText: "Observa los patrones que se repiten. No juzgues, solo observa.",
                    instructions: [
                        "Dibuja tu árbol genealógico",
                        "Incluye 3-4 generaciones hacia atrás",
                        "Anota nombres, fechas, profesiones",
                        "Incluye causas de muerte y eventos importantes"
                    ]
                ),
                ProfessionalTemplate.TemplateStep(
                    number: 2,
                    title: "Identificación de Patrones",
                    description: "Identifica patrones repetitivos en tu familia",
                    duration: "10-15 min",
                    therapeuticPrompt: "¿Qué patrones observas en tu familia? Divorcios, adicciones, enfermedades, accidentes, profesiones, etc.",
                    spiritualGuidance: "Los patrones familiares son oportunidades de sanación, no condenas",
                    requiresHandwriting: true,
                    handwritingOptional: true,
                    requiresRitualElements: false,
                    emotionalCheckpoint: true,
                    meditationText: "Los patrones familiares son oportunidades de sanación, no condenas.",
                    instructions: [
                        "Identifica patrones repetitivos",
                        "Anota cada patrón que observes",
                        "No juzgues, solo observa",
                        "Considera cómo estos patrones te afectan"
                    ]
                ),
                ProfessionalTemplate.TemplateStep(
                    number: 3,
                    title: "Reconocimiento de Influencias",
                    description: "Reconoce cómo estos patrones te afectan actualmente",
                    duration: "5-10 min",
                    therapeuticPrompt: "¿Cómo estos patrones familiares afectan tu vida actual? ¿Qué comportamientos, creencias o emociones heredaste?",
                    spiritualGuidance: "Al reconocer el patrón, ya has comenzado a liberarte de él",
                    requiresHandwriting: true,
                    handwritingOptional: true,
                    requiresRitualElements: false,
                    emotionalCheckpoint: true,
                    meditationText: "Al reconocer el patrón, ya has comenzado a liberarte de él.",
                    instructions: [
                        "Reflexiona sobre tu vida actual",
                        "Identifica influencias familiares",
                        "Escribe sobre cómo te afectan",
                        "Practica la autoobservación"
                    ]
                ),
                ProfessionalTemplate.TemplateStep(
                    number: 4,
                    title: "Liberación Ancestral",
                    description: "Visualiza sanando a tus ancestros y liberando los patrones",
                    duration: "10-15 min",
                    therapeuticPrompt: "Escribe una carta a tus ancestros. Agradéceles por las lecciones y libéralos de su dolor.",
                    spiritualGuidance: "Con amor, libero a mis ancestros de su dolor y me libero del mío",
                    requiresHandwriting: true,
                    handwritingOptional: true,
                    requiresRitualElements: true,
                    emotionalCheckpoint: true,
                    meditationText: "Con amor, libero a mis ancestros de su dolor y me libero del mío.",
                    instructions: [
                        "Escribe cartas a tus ancestros",
                        "Agradéceles por las lecciones",
                        "Libéralos de su dolor",
                        "Visualiza la sanación generacional"
                    ]
                ),
                ProfessionalTemplate.TemplateStep(
                    number: 5,
                    title: "Nuevo Patrón",
                    description: "Crea un nuevo patrón positivo para ti y tus descendientes",
                    duration: "5-10 min",
                    therapeuticPrompt: "¿Qué nuevo patrón quieres crear para ti y tus descendientes? Escribe sobre el legado de amor que quieres dejar.",
                    spiritualGuidance: "Elijo crear un nuevo legado de amor, paz y sanación",
                    requiresHandwriting: true,
                    handwritingOptional: true,
                    requiresRitualElements: true,
                    emotionalCheckpoint: true,
                    meditationText: "Elijo crear un nuevo legado de amor, paz y sanación.",
                    instructions: [
                        "Define tu nuevo patrón familiar",
                        "Escribe sobre el legado que quieres dejar",
                        "Visualiza a tus descendientes sanos y felices",
                        "Realiza un ritual de renovación familiar"
                    ]
                )
            ],
            therapeuticApproach: .systemicTherapy,
            spiritualElement: .ancestralHealing
        )
    }
    
    // MARK: - Liberation Ritual Template
    private static func createLiberationRitualTemplate() -> ProfessionalTemplate {
        return ProfessionalTemplate(
            technique: .liberationRitual,
            steps: [
                ProfessionalTemplate.TemplateStep(
                    number: 1,
                    title: "Preparación del Espacio Sagrado",
                    description: "Prepara un espacio sagrado con elementos rituales",
                    duration: "5-10 min",
                    therapeuticPrompt: "¿Qué necesitas liberar? ¿Qué intención tienes para este ritual?",
                    spiritualGuidance: "Este espacio es sagrado. Aquí me conecto con mi esencia divina",
                    requiresHandwriting: false,
                    handwritingOptional: true,
                    requiresRitualElements: true,
                    emotionalCheckpoint: false,
                    meditationText: "Este espacio es sagrado. Aquí me conecto con mi esencia divina.",
                    instructions: [
                        "Limpia y ordena el espacio",
                        "Enciende velas e incienso",
                        "Coloca cristales y elementos naturales",
                        "Establece tu intención clara"
                    ]
                ),
                ProfessionalTemplate.TemplateStep(
                    number: 2,
                    title: "Purificación y Centrado",
                    description: "Purifica tu cuerpo y mente para el ritual",
                    duration: "5-10 min",
                    therapeuticPrompt: "¿Qué necesitas purificar de ti mismo? ¿Qué cargas emocionales quieres liberar?",
                    spiritualGuidance: "Con esta agua, me purifico de todo lo que ya no me sirve",
                    requiresHandwriting: true,
                    handwritingOptional: true,
                    requiresRitualElements: true,
                    emotionalCheckpoint: true,
                    meditationText: "Con esta agua, me purifico de todo lo que ya no me sirve.",
                    instructions: [
                        "Lávate las manos con agua y sal",
                        "Enciende incienso para purificar",
                        "Visualiza la luz limpiando tu aura",
                        "Escribe sobre lo que quieres purificar"
                    ]
                ),
                ProfessionalTemplate.TemplateStep(
                    number: 3,
                    title: "Ceremonia de Liberación",
                    description: "Realiza el ritual específico de liberación",
                    duration: "10-15 min",
                    therapeuticPrompt: "¿Qué acto simbólico quieres realizar? ¿Quemar papel, enterrar objetos, etc.?",
                    spiritualGuidance: "Con este acto sagrado, libero al universo todo lo que necesito soltar",
                    requiresHandwriting: true,
                    handwritingOptional: true,
                    requiresRitualElements: true,
                    emotionalCheckpoint: true,
                    meditationText: "Con este acto sagrado, libero al universo todo lo que necesito soltar.",
                    instructions: [
                        "Realiza el acto simbólico elegido",
                        "Visualiza la liberación de cargas",
                        "Usa afirmaciones de liberación",
                        "Escribe sobre la experiencia"
                    ]
                ),
                ProfessionalTemplate.TemplateStep(
                    number: 4,
                    title: "Gratitud y Renovación",
                    description: "Agradece por la liberación y visualiza tu nueva realidad",
                    duration: "5-10 min",
                    therapeuticPrompt: "¿Por qué estás agradecido? ¿Cómo se ve tu nueva realidad?",
                    spiritualGuidance: "Agradezco por esta liberación. Recibo con amor mi nueva realidad",
                    requiresHandwriting: true,
                    handwritingOptional: true,
                    requiresRitualElements: false,
                    emotionalCheckpoint: true,
                    meditationText: "Agradezco por esta liberación. Recibo con amor mi nueva realidad.",
                    instructions: [
                        "Expresa gratitud por la liberación",
                        "Visualiza tu nueva realidad",
                        "Escribe sobre tus agradecimientos",
                        "Acepta la renovación"
                    ]
                ),
                ProfessionalTemplate.TemplateStep(
                    number: 5,
                    title: "Cierre y Protección",
                    description: "Cierra el ritual y protege tu nueva energía",
                    duration: "3-5 min",
                    therapeuticPrompt: "¿Cómo te sientes después del ritual? ¿Qué protección necesitas?",
                    spiritualGuidance: "Me envuelvo en luz dorada. Estoy protegido y en paz",
                    requiresHandwriting: true,
                    handwritingOptional: true,
                    requiresRitualElements: true,
                    emotionalCheckpoint: true,
                    meditationText: "Me envuelvo en luz dorada. Estoy protegido y en paz.",
                    instructions: [
                        "Visualiza una burbuja de protección",
                        "Agradece a los elementos utilizados",
                        "Escribe sobre tu experiencia",
                        "Cierra el espacio sagrado"
                    ]
                )
            ],
            therapeuticApproach: .transpersonalTherapy,
            spiritualElement: .ceremony
        )
    }
    
    // MARK: - Energetic Cords Template
    private static func createEnergeticCordsTemplate() -> ProfessionalTemplate {
        return ProfessionalTemplate(
            technique: .energeticCords,
            steps: [
                ProfessionalTemplate.TemplateStep(
                    number: 1,
                    title: "Meditación de Conexión",
                    description: "Conecta con tu campo energético y visualiza los cordones",
                    duration: "5-7 min",
                    therapeuticPrompt: "¿Con qué personas sientes conexiones energéticas? ¿Cuáles son saludables y cuáles tóxicas?",
                    spiritualGuidance: "Observo los cordones de luz que me conectan con el mundo",
                    requiresHandwriting: false,
                    handwritingOptional: true,
                    requiresRitualElements: true,
                    emotionalCheckpoint: false,
                    meditationText: "Observo los cordones de luz que me conectan con el mundo.",
                    instructions: [
                        "Enciende una vela púrpura",
                        "Siéntate cómodamente",
                        "Cierra los ojos y respira profundamente",
                        "Visualiza tu campo energético"
                    ]
                ),
                ProfessionalTemplate.TemplateStep(
                    number: 2,
                    title: "Identificación de Cordones",
                    description: "Identifica qué cordones son saludables y cuáles son tóxicos",
                    duration: "5-10 min",
                    therapeuticPrompt: "Escribe sobre cada conexión energética. ¿Qué color tiene? ¿Cómo se siente? ¿Es saludable o tóxico?",
                    spiritualGuidance: "Con amor, distingo entre conexiones sanas y dependencias tóxicas",
                    requiresHandwriting: true,
                    handwritingOptional: true,
                    requiresRitualElements: false,
                    emotionalCheckpoint: true,
                    meditationText: "Con amor, distingo entre conexiones sanas y dependencias tóxicas.",
                    instructions: [
                        "Visualiza cada cordón energético",
                        "Identifica el color y la sensación",
                        "Escribe sobre cada conexión",
                        "Clasifica como sana o tóxica"
                    ]
                ),
                ProfessionalTemplate.TemplateStep(
                    number: 3,
                    title: "Corte Consciente",
                    description: "Visualiza cortando los cordones tóxicos con amor",
                    duration: "5-10 min",
                    therapeuticPrompt: "¿Qué cordones necesitas cortar? Escribe sobre el proceso de liberación.",
                    spiritualGuidance: "Con amor, corto estos cordones. Te libero y me libero con gratitud",
                    requiresHandwriting: true,
                    handwritingOptional: true,
                    requiresRitualElements: false,
                    emotionalCheckpoint: true,
                    meditationText: "Con amor, corto estos cordones. Te libero y me libero con gratitud.",
                    instructions: [
                        "Visualiza tijeras de luz dorada",
                        "Corta cada cordón tóxico con amor",
                        "Escribe sobre la liberación",
                        "Practica la gratitud"
                    ]
                ),
                ProfessionalTemplate.TemplateStep(
                    number: 4,
                    title: "Sanación Energética",
                    description: "Visualiza sanando las heridas donde estaban los cordones",
                    duration: "5-10 min",
                    therapeuticPrompt: "¿Cómo te sientes después del corte? ¿Qué heridas necesitas sanar?",
                    spiritualGuidance: "Con luz dorada, sanó estas heridas. Me lleno de amor propio",
                    requiresHandwriting: true,
                    handwritingOptional: true,
                    requiresRitualElements: false,
                    emotionalCheckpoint: true,
                    meditationText: "Con luz dorada, sanó estas heridas. Me lleno de amor propio.",
                    instructions: [
                        "Visualiza luz dorada curando las heridas",
                        "Llena los espacios vacíos con amor propio",
                        "Escribe sobre la sanación",
                        "Practica la autocompasión"
                    ]
                ),
                ProfessionalTemplate.TemplateStep(
                    number: 5,
                    title: "Protección Permanente",
                    description: "Visualiza una burbuja de protección alrededor de tu campo energético",
                    duration: "3-5 min",
                    therapeuticPrompt: "¿Cómo te sientes ahora? ¿Qué protección necesitas para el futuro?",
                    spiritualGuidance: "Me envuelvo en una burbuja de luz dorada. Estoy protegido y en paz",
                    requiresHandwriting: true,
                    handwritingOptional: true,
                    requiresRitualElements: true,
                    emotionalCheckpoint: true,
                    meditationText: "Me envuelvo en una burbuja de luz dorada. Estoy protegido y en paz.",
                    instructions: [
                        "Visualiza una burbuja de protección",
                        "Coloca cristales de protección",
                        "Escribe sobre tu nueva protección",
                        "Agradece por la liberación"
                    ]
                )
            ],
            therapeuticApproach: .energyPsychology,
            spiritualElement: .energyWork
        )
    }
    
    // MARK: - Past Life Bonds Template
    private static func createPastLifeBondsTemplate() -> ProfessionalTemplate {
        return ProfessionalTemplate(
            technique: .pastLifeBonds,
            steps: [
                ProfessionalTemplate.TemplateStep(
                    number: 1,
                    title: "Meditación Profunda",
                    description: "Entra en un estado de meditación profunda para conectar con vidas pasadas",
                    duration: "5-10 min",
                    therapeuticPrompt: "¿Qué patrones se repiten en tu vida? ¿Qué lecciones kármicas necesitas aprender?",
                    spiritualGuidance: "Me conecto con mi alma eterna. Observo las vidas que he vivido",
                    requiresHandwriting: false,
                    handwritingOptional: true,
                    requiresRitualElements: true,
                    emotionalCheckpoint: false,
                    meditationText: "Me conecto con mi alma eterna. Observo las vidas que he vivido.",
                    instructions: [
                        "Enciende una vela índigo",
                        "Usa incienso de copal",
                        "Coloca lapislázuli en tu tercer ojo",
                        "Entra en meditación profunda"
                    ]
                ),
                ProfessionalTemplate.TemplateStep(
                    number: 2,
                    title: "Exploración Kármica",
                    description: "Explora las conexiones kármicas y vínculos del alma",
                    duration: "10-15 min",
                    therapeuticPrompt: "¿Qué vidas pasadas sientes que te afectan? Escribe sobre las conexiones kármicas que percibes.",
                    spiritualGuidance: "Con amor, observo las lecciones que mi alma ha venido a aprender",
                    requiresHandwriting: true,
                    handwritingOptional: true,
                    requiresRitualElements: false,
                    emotionalCheckpoint: true,
                    meditationText: "Con amor, observo las lecciones que mi alma ha venido a aprender.",
                    instructions: [
                        "Visualiza vidas pasadas",
                        "Identifica patrones kármicos",
                        "Escribe sobre las conexiones",
                        "Practica la observación sin juicio"
                    ]
                ),
                ProfessionalTemplate.TemplateStep(
                    number: 3,
                    title: "Reconocimiento de Patrones",
                    description: "Reconoce los patrones kármicos que se repiten en esta vida",
                    duration: "5-10 min",
                    therapeuticPrompt: "¿Qué patrones de vidas pasadas se repiten en esta vida? ¿Qué lecciones necesitas aprender?",
                    spiritualGuidance: "Reconozco estos patrones como oportunidades de crecimiento",
                    requiresHandwriting: true,
                    handwritingOptional: true,
                    requiresRitualElements: false,
                    emotionalCheckpoint: true,
                    meditationText: "Reconozco estos patrones como oportunidades de crecimiento.",
                    instructions: [
                        "Identifica patrones repetitivos",
                        "Escribe sobre las lecciones",
                        "Practica la aceptación",
                        "Considera el propósito kármico"
                    ]
                ),
                ProfessionalTemplate.TemplateStep(
                    number: 4,
                    title: "Liberación Kármica",
                    description: "Visualiza liberando los vínculos kármicos con amor",
                    duration: "10-15 min",
                    therapeuticPrompt: "¿Qué vínculos kármicos necesitas liberar? Escribe sobre la liberación de estas conexiones.",
                    spiritualGuidance: "Con amor, libero estos vínculos kármicos. Acepto las lecciones aprendidas",
                    requiresHandwriting: true,
                    handwritingOptional: true,
                    requiresRitualElements: true,
                    emotionalCheckpoint: true,
                    meditationText: "Con amor, libero estos vínculos kármicos. Acepto las lecciones aprendidas.",
                    instructions: [
                        "Visualiza la liberación de vínculos",
                        "Usa afirmaciones de liberación",
                        "Escribe sobre la liberación",
                        "Practica la gratitud por las lecciones"
                    ]
                ),
                ProfessionalTemplate.TemplateStep(
                    number: 5,
                    title: "Renovación del Alma",
                    description: "Visualiza tu alma renovada, libre de cargas del pasado",
                    duration: "5-10 min",
                    therapeuticPrompt: "¿Cómo se siente tu alma renovada? ¿Qué nueva realidad quieres crear?",
                    spiritualGuidance: "Mi alma se renueva. Soy libre de crear mi realidad presente con amor",
                    requiresHandwriting: true,
                    handwritingOptional: true,
                    requiresRitualElements: true,
                    emotionalCheckpoint: true,
                    meditationText: "Mi alma se renueva. Soy libre de crear mi realidad presente con amor.",
                    instructions: [
                        "Visualiza tu alma renovada",
                        "Escribe sobre tu nueva realidad",
                        "Practica la gratitud",
                        "Acepta la renovación"
                    ]
                )
            ],
            therapeuticApproach: .transpersonalTherapy,
            spiritualElement: .soulWork
        )
    }
}
