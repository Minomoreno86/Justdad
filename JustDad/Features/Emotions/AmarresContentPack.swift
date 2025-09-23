//
//  AmarresContentPack.swift
//  JustDad - Paquete de Contenido para Corte de Amarres o Brujería
//
//  Contiene todos los scripts, textos y contenido específico para el ritual
//

import Foundation
import SwiftUI

// MARK: - Script de Amarres
public struct AmarresScript: Identifiable, Codable {
    public let id = UUID()
    public let title: String
    public let description: String
    public let duration: String
    public let blocks: [AmarresReadingBlock]
    public let approach: AmarresApproach
    
    public init(
        title: String,
        description: String,
        duration: String,
        blocks: [AmarresReadingBlock],
        approach: AmarresApproach
    ) {
        self.title = title
        self.description = description
        self.duration = duration
        self.blocks = blocks
        self.approach = approach
    }
}

// MARK: - Bloques de Lectura
public enum AmarresReadingBlock: String, CaseIterable, Codable {
    case diagnosis = "diagnosis"
    case breathing = "breathing"
    case identification = "identification"
    case cleansing = "cleansing"
    case cutting = "cutting"
    case protection = "protection"
    case sealing = "sealing"
    
    public var displayName: String {
        switch self {
        case .diagnosis: return "Diagnóstico"
        case .breathing: return "Respiración"
        case .identification: return "Identificación"
        case .cleansing: return "Limpieza"
        case .cutting: return "Corte"
        case .protection: return "Protección"
        case .sealing: return "Sellado"
        }
    }
    
    public var icon: String {
        switch self {
        case .diagnosis: return "stethoscope"
        case .breathing: return "lungs.fill"
        case .identification: return "magnifyingglass"
        case .cleansing: return "drop.fill"
        case .cutting: return "scissors"
        case .protection: return "shield.fill"
        case .sealing: return "lock.fill"
        }
    }
    
    public var color: Color {
        switch self {
        case .diagnosis: return .blue
        case .breathing: return .green
        case .identification: return .orange
        case .cleansing: return .cyan
        case .cutting: return .red
        case .protection: return .purple
        case .sealing: return .yellow
        }
    }
}

// MARK: - Contenido de Bloque
public struct AmarresReadingBlockContent: Codable {
    public let title: String
    public let description: String
    public let instructions: [String]
    public let anchors: [String]
    public let affirmations: [String]
    public let meditationText: String
    public let duration: String
    
    public init(
        title: String,
        description: String,
        instructions: [String],
        anchors: [String],
        affirmations: [String],
        meditationText: String,
        duration: String
    ) {
        self.title = title
        self.description = description
        self.instructions = instructions
        self.anchors = anchors
        self.affirmations = affirmations
        self.meditationText = meditationText
        self.duration = duration
    }
}

// MARK: - Paquete de Contenido Principal
public class AmarresContentPack: ObservableObject {
    public static let shared = AmarresContentPack()
    
    @Published public var secularScripts: [AmarresScript] = []
    @Published public var spiritualScripts: [AmarresScript] = []
    @Published public var traditionalScripts: [AmarresScript] = []
    
    private init() {
        setupScripts()
    }
    
    // MARK: - Scripts Seculares
    
    private func setupScripts() {
        secularScripts = createSecularScripts()
        spiritualScripts = createSpiritualScripts()
        traditionalScripts = createTraditionalScripts()
    }
    
    private func createSecularScripts() -> [AmarresScript] {
        return [
            // 1. Diagnóstico Energético
            AmarresScript(
                title: "Diagnóstico Energético",
                description: "Identifica síntomas y patrones de dependencia energética",
                duration: "5-10 min",
                blocks: [
                    AmarresReadingBlock.diagnosis
                ],
                approach: .secular
            ),
            
            // 2. Preparación Respiratoria
            AmarresScript(
                title: "Preparación Respiratoria",
                description: "Centra tu energía y prepara tu campo energético",
                duration: "3-5 min",
                blocks: [
                    AmarresReadingBlock.breathing
                ],
                approach: .secular
            ),
            
            // 3. Identificación de Amarres
            AmarresScript(
                title: "Identificación de Amarres",
                description: "Reconoce y nombra los vínculos energéticos tóxicos",
                duration: "5-7 min",
                blocks: [
                    AmarresReadingBlock.identification
                ],
                approach: .secular
            ),
            
            // 4. Limpieza Energética
            AmarresScript(
                title: "Limpieza Energética",
                description: "Purifica tu campo energético de influencias negativas",
                duration: "5-10 min",
                blocks: [
                    AmarresReadingBlock.cleansing
                ],
                approach: .secular
            ),
            
            // 5. Corte Consciente
            AmarresScript(
                title: "Corte Consciente",
                description: "Libera conscientemente los vínculos tóxicos identificados",
                duration: "5-7 min",
                blocks: [
                    AmarresReadingBlock.cutting
                ],
                approach: .secular
            ),
            
            // 6. Protección Energética
            AmarresScript(
                title: "Protección Energética",
                description: "Establece barreras protectoras contra futuras influencias",
                duration: "5-7 min",
                blocks: [
                    AmarresReadingBlock.protection
                ],
                approach: .secular
            ),
            
            // 7. Sellado de Liberación
            AmarresScript(
                title: "Sellado de Liberación",
                description: "Sella el proceso y establece compromisos de autocuidado",
                duration: "3-5 min",
                blocks: [
                    AmarresReadingBlock.sealing
                ],
                approach: .secular
            )
        ]
    }
    
    private func createSpiritualScripts() -> [AmarresScript] {
        return [
            // 1. Diagnóstico Espiritual
            AmarresScript(
                title: "Diagnóstico Espiritual",
                description: "Conecta con tu ser superior para identificar influencias espirituales",
                duration: "5-10 min",
                blocks: [
                    AmarresReadingBlock.diagnosis
                ],
                approach: .spiritual
            ),
            
            // 2. Respiración Sagrada
            AmarresScript(
                title: "Respiración Sagrada",
                description: "Invoca la luz divina a través de la respiración consciente",
                duration: "3-5 min",
                blocks: [
                    AmarresReadingBlock.breathing
                ],
                approach: .spiritual
            ),
            
            // 3. Reconocimiento Espiritual
            AmarresScript(
                title: "Reconocimiento Espiritual",
                description: "Reconoce los vínculos kármicos y espirituales que te atan",
                duration: "5-7 min",
                blocks: [
                    AmarresReadingBlock.identification
                ],
                approach: .spiritual
            ),
            
            // 4. Purificación Divina
            AmarresScript(
                title: "Purificación Divina",
                description: "Invoca la luz divina para purificar tu campo energético",
                duration: "5-10 min",
                blocks: [
                    AmarresReadingBlock.cleansing
                ],
                approach: .spiritual
            ),
            
            // 5. Liberación Divina
            AmarresScript(
                title: "Liberación Divina",
                description: "Con el poder divino, corta todos los vínculos tóxicos",
                duration: "5-7 min",
                blocks: [
                    AmarresReadingBlock.cutting
                ],
                approach: .spiritual
            ),
            
            // 6. Protección Divina
            AmarresScript(
                title: "Protección Divina",
                description: "Establece protección divina contra futuras influencias",
                duration: "5-7 min",
                blocks: [
                    AmarresReadingBlock.protection
                ],
                approach: .spiritual
            ),
            
            // 7. Sellado Sagrado
            AmarresScript(
                title: "Sellado Sagrado",
                description: "Sella el proceso con la bendición divina",
                duration: "3-5 min",
                blocks: [
                    AmarresReadingBlock.sealing
                ],
                approach: .spiritual
            )
        ]
    }
    
    private func createTraditionalScripts() -> [AmarresScript] {
        return [
            // 1. Diagnóstico Tradicional
            AmarresScript(
                title: "Diagnóstico Tradicional",
                description: "Usa métodos tradicionales para identificar influencias",
                duration: "5-10 min",
                blocks: [
                    AmarresReadingBlock.diagnosis
                ],
                approach: .traditional
            ),
            
            // 2. Respiración Ancestral
            AmarresScript(
                title: "Respiración Ancestral",
                description: "Conecta con la sabiduría ancestral a través de la respiración",
                duration: "3-5 min",
                blocks: [
                    AmarresReadingBlock.breathing
                ],
                approach: .traditional
            ),
            
            // 3. Reconocimiento Ancestral
            AmarresScript(
                title: "Reconocimiento Ancestral",
                description: "Reconoce las influencias ancestrales y familiares",
                duration: "5-7 min",
                blocks: [
                    AmarresReadingBlock.identification
                ],
                approach: .traditional
            ),
            
            // 4. Limpieza Ancestral
            AmarresScript(
                title: "Limpieza Ancestral",
                description: "Usa métodos tradicionales de limpieza energética",
                duration: "5-10 min",
                blocks: [
                    AmarresReadingBlock.cleansing
                ],
                approach: .traditional
            ),
            
            // 5. Corte Ancestral
            AmarresScript(
                title: "Corte Ancestral",
                description: "Corta vínculos usando la sabiduría de los ancestros",
                duration: "5-7 min",
                blocks: [
                    AmarresReadingBlock.cutting
                ],
                approach: .traditional
            ),
            
            // 6. Protección Ancestral
            AmarresScript(
                title: "Protección Ancestral",
                description: "Establece protección usando métodos tradicionales",
                duration: "5-7 min",
                blocks: [
                    AmarresReadingBlock.protection
                ],
                approach: .traditional
            ),
            
            // 7. Sellado Ancestral
            AmarresScript(
                title: "Sellado Ancestral",
                description: "Sella el proceso con la bendición ancestral",
                duration: "3-5 min",
                blocks: [
                    AmarresReadingBlock.sealing
                ],
                approach: .traditional
            )
        ]
    }
    
    // MARK: - Métodos de Acceso
    
    public func getScript(at index: Int, approach: AmarresApproach) -> AmarresScript? {
        let scripts = getScripts(for: approach)
        guard index >= 0 && index < scripts.count else { return nil }
        return scripts[index]
    }
    
    public func getScript(for block: AmarresReadingBlock, approach: AmarresApproach) -> AmarresScript? {
        let scripts = getScripts(for: approach)
        return scripts.first { script in
            script.blocks.contains(block)
        }
    }
    
    public func getScripts(for approach: AmarresApproach) -> [AmarresScript] {
        switch approach {
        case .secular:
            return secularScripts
        case .spiritual:
            return spiritualScripts
        case .traditional:
            return traditionalScripts
        }
    }
    
    public func getContent(for block: AmarresReadingBlock, approach: AmarresApproach) -> AmarresReadingBlockContent? {
        switch block {
        case .diagnosis:
            return getDiagnosisContent(for: approach)
        case .breathing:
            return getBreathingContent(for: approach)
        case .identification:
            return getIdentificationContent(for: approach)
        case .cleansing:
            return getCleansingContent(for: approach)
        case .cutting:
            return getCuttingContent(for: approach)
        case .protection:
            return getProtectionContent(for: approach)
        case .sealing:
            return getSealingContent(for: approach)
        }
    }
    
    // MARK: - Contenido Específico por Enfoque
    
    private func getDiagnosisContent(for approach: AmarresApproach) -> AmarresReadingBlockContent {
        switch approach {
        case .secular:
            return AmarresReadingBlockContent(
                title: "Diagnóstico Energético",
                description: "Identifica síntomas físicos y emocionales de dependencia energética",
                instructions: [
                    "Observa tu cuerpo y detecta tensiones",
                    "Identifica emociones recurrentes negativas",
                    "Reconoce patrones de pensamiento obsesivo",
                    "Evalúa tu nivel de energía vital"
                ],
                anchors: [
                    "Me observo con amor",
                    "Identifico mis síntomas",
                    "Reconozco mi realidad"
                ],
                affirmations: [
                    "Soy consciente de mi estado energético",
                    "Identifico con claridad mis síntomas",
                    "Tengo el poder de sanar mi energía"
                ],
                meditationText: "Observo mi campo energético con amor y claridad. Identifico los síntomas que indican influencias negativas.",
                duration: "5-10 min"
            )
            
        case .spiritual:
            return AmarresReadingBlockContent(
                title: "Diagnóstico Espiritual",
                description: "Conecta con tu ser superior para identificar influencias espirituales",
                instructions: [
                    "Invoca la luz divina",
                    "Pide guía espiritual",
                    "Observa con los ojos del alma",
                    "Reconoce las influencias externas"
                ],
                anchors: [
                    "Invoco la luz divina",
                    "Pido guía espiritual",
                    "Reconozco las influencias"
                ],
                affirmations: [
                    "La luz divina me guía",
                    "Mi ser superior me protege",
                    "Reconozco las influencias con claridad"
                ],
                meditationText: "Invoco la luz divina para que me guíe. Pido a mi ser superior que me muestre las influencias que me afectan.",
                duration: "5-10 min"
            )
            
        case .traditional:
            return AmarresReadingBlockContent(
                title: "Diagnóstico Tradicional",
                description: "Usa métodos tradicionales para identificar influencias ancestrales",
                instructions: [
                    "Conecta con tus ancestros",
                    "Usa la sabiduría tradicional",
                    "Observa con los ojos del alma",
                    "Reconoce patrones familiares"
                ],
                anchors: [
                    "Conecto con mis ancestros",
                    "Uso la sabiduría tradicional",
                    "Reconozco los patrones"
                ],
                affirmations: [
                    "Mis ancestros me guían",
                    "La sabiduría tradicional me protege",
                    "Reconozco los patrones familiares"
                ],
                meditationText: "Conecto con la sabiduría de mis ancestros. Pido que me guíen para identificar las influencias que me afectan.",
                duration: "5-10 min"
            )
        }
    }
    
    private func getBreathingContent(for approach: AmarresApproach) -> AmarresReadingBlockContent {
        switch approach {
        case .secular:
            return AmarresReadingBlockContent(
                title: "Preparación Respiratoria",
                description: "Centra tu energía y prepara tu campo energético",
                instructions: [
                    "Siéntate cómodamente",
                    "Respira profundamente",
                    "Centra tu atención",
                    "Relaja tu cuerpo"
                ],
                anchors: [
                    "Respiro profundamente",
                    "Me centro en mi respiración",
                    "Relajo mi cuerpo"
                ],
                affirmations: [
                    "Mi respiración me centra",
                    "Estoy en paz y tranquilo",
                    "Mi energía se equilibra"
                ],
                meditationText: "Con cada respiración, me centro más en mi ser. Mi energía se equilibra y me preparo para la liberación.",
                duration: "3-5 min"
            )
            
        case .spiritual:
            return AmarresReadingBlockContent(
                title: "Respiración Sagrada",
                description: "Invoca la luz divina a través de la respiración consciente",
                instructions: [
                    "Invoca la luz divina",
                    "Respira la luz sagrada",
                    "Siente la presencia divina",
                    "Permite que la luz te llene"
                ],
                anchors: [
                    "Invoco la luz divina",
                    "Respiro la luz sagrada",
                    "Siento la presencia divina"
                ],
                affirmations: [
                    "La luz divina me llena",
                    "Soy uno con la luz",
                    "La presencia divina me protege"
                ],
                meditationText: "Con cada respiración, invoco la luz divina. Siento cómo la luz sagrada llena mi ser y me prepara para la liberación.",
                duration: "3-5 min"
            )
            
        case .traditional:
            return AmarresReadingBlockContent(
                title: "Respiración Ancestral",
                description: "Conecta con la sabiduría ancestral a través de la respiración",
                instructions: [
                    "Conecta con tus ancestros",
                    "Respira la sabiduría ancestral",
                    "Siente la conexión ancestral",
                    "Permite que la sabiduría te llene"
                ],
                anchors: [
                    "Conecto con mis ancestros",
                    "Respiro la sabiduría ancestral",
                    "Siento la conexión ancestral"
                ],
                affirmations: [
                    "La sabiduría ancestral me llena",
                    "Soy uno con mis ancestros",
                    "La conexión ancestral me protege"
                ],
                meditationText: "Con cada respiración, conecto con la sabiduría de mis ancestros. Siento cómo su sabiduría llena mi ser y me prepara para la liberación.",
                duration: "3-5 min"
            )
        }
    }
    
    private func getIdentificationContent(for approach: AmarresApproach) -> AmarresReadingBlockContent {
        switch approach {
        case .secular:
            return AmarresReadingBlockContent(
                title: "Identificación de Amarres",
                description: "Reconoce y nombra los vínculos energéticos tóxicos",
                instructions: [
                    "Identifica las personas o situaciones",
                    "Reconoce los patrones de dependencia",
                    "Nombra los vínculos específicos",
                    "Evalúa la intensidad de cada vínculo"
                ],
                anchors: [
                    "Identifico mis amarres",
                    "Reconozco los vínculos tóxicos",
                    "Nombro lo que me ata"
                ],
                affirmations: [
                    "Identifico claramente mis amarres",
                    "Reconozco los vínculos que me limitan",
                    "Tengo el poder de liberarme"
                ],
                meditationText: "Con claridad y amor, identifico los vínculos que me atan. Reconozco cada amarre y lo nombro con valentía.",
                duration: "5-7 min"
            )
            
        case .spiritual:
            return AmarresReadingBlockContent(
                title: "Reconocimiento Espiritual",
                description: "Reconoce los vínculos kármicos y espirituales que te atan",
                instructions: [
                    "Pide guía divina",
                    "Reconoce los vínculos kármicos",
                    "Identifica las lecciones pendientes",
                    "Nombra las conexiones espirituales"
                ],
                anchors: [
                    "Pido guía divina",
                    "Reconozco los vínculos kármicos",
                    "Identifico las lecciones"
                ],
                affirmations: [
                    "La luz divina me guía",
                    "Reconozco mis vínculos kármicos",
                    "Estoy listo para las lecciones"
                ],
                meditationText: "Con la guía divina, reconozco los vínculos kármicos que me atan. Identifico las lecciones que debo aprender.",
                duration: "5-7 min"
            )
            
        case .traditional:
            return AmarresReadingBlockContent(
                title: "Reconocimiento Ancestral",
                description: "Reconoce las influencias ancestrales y familiares",
                instructions: [
                    "Conecta con tus ancestros",
                    "Reconoce los patrones familiares",
                    "Identifica las lealtades invisibles",
                    "Nombra las influencias ancestrales"
                ],
                anchors: [
                    "Conecto con mis ancestros",
                    "Reconozco los patrones familiares",
                    "Identifico las lealtades"
                ],
                affirmations: [
                    "Mis ancestros me guían",
                    "Reconozco los patrones familiares",
                    "Estoy listo para liberarme"
                ],
                meditationText: "Conectando con mis ancestros, reconozco los patrones familiares que me atan. Identifico las lealtades invisibles.",
                duration: "5-7 min"
            )
        }
    }
    
    private func getCleansingContent(for approach: AmarresApproach) -> AmarresReadingBlockContent {
        switch approach {
        case .secular:
            return AmarresReadingBlockContent(
                title: "Limpieza Energética",
                description: "Purifica tu campo energético de influencias negativas",
                instructions: [
                    "Visualiza luz blanca",
                    "Limpia cada chakra",
                    "Purifica tu aura",
                    "Elimina energías densas"
                ],
                anchors: [
                    "Visualizo luz blanca",
                    "Limpio mi campo energético",
                    "Purifico mi aura"
                ],
                affirmations: [
                    "Mi campo energético se purifica",
                    "La luz blanca me limpia",
                    "Estoy libre de influencias negativas"
                ],
                meditationText: "Visualizo luz blanca que purifica mi campo energético. Siento cómo se eliminan todas las energías densas y negativas.",
                duration: "5-10 min"
            )
            
        case .spiritual:
            return AmarresReadingBlockContent(
                title: "Purificación Divina",
                description: "Invoca la luz divina para purificar tu campo energético",
                instructions: [
                    "Invoca la luz divina",
                    "Pide purificación espiritual",
                    "Siente la limpieza divina",
                    "Permite que la luz te purifique"
                ],
                anchors: [
                    "Invoco la luz divina",
                    "Pido purificación espiritual",
                    "Siento la limpieza divina"
                ],
                affirmations: [
                    "La luz divina me purifica",
                    "Soy limpiado espiritualmente",
                    "Estoy libre de influencias negativas"
                ],
                meditationText: "Invoco la luz divina para que me purifique. Siento cómo la luz sagrada elimina todas las influencias negativas.",
                duration: "5-10 min"
            )
            
        case .traditional:
            return AmarresReadingBlockContent(
                title: "Limpieza Ancestral",
                description: "Usa métodos tradicionales de limpieza energética",
                instructions: [
                    "Conecta con tus ancestros",
                    "Usa métodos tradicionales",
                    "Visualiza la limpieza ancestral",
                    "Permite que la sabiduría te limpie"
                ],
                anchors: [
                    "Conecto con mis ancestros",
                    "Uso métodos tradicionales",
                    "Visualizo la limpieza ancestral"
                ],
                affirmations: [
                    "La sabiduría ancestral me limpia",
                    "Soy purificado por mis ancestros",
                    "Estoy libre de influencias negativas"
                ],
                meditationText: "Conectando con mis ancestros, uso sus métodos tradicionales de limpieza. Siento cómo la sabiduría ancestral me purifica.",
                duration: "5-10 min"
            )
        }
    }
    
    private func getCuttingContent(for approach: AmarresApproach) -> AmarresReadingBlockContent {
        switch approach {
        case .secular:
            return AmarresReadingBlockContent(
                title: "Corte Consciente",
                description: "Libera conscientemente los vínculos tóxicos identificados",
                instructions: [
                    "Visualiza tijeras de luz",
                    "Corta cada vínculo con amor",
                    "Siente la liberación",
                    "Permite que se vaya"
                ],
                anchors: [
                    "Visualizo tijeras de luz",
                    "Corto los vínculos con amor",
                    "Siento la liberación"
                ],
                affirmations: [
                    "Corto los vínculos con amor",
                    "Me libero de las ataduras",
                    "Soy libre y autónomo"
                ],
                meditationText: "Visualizo tijeras de luz que cortan cada vínculo tóxico con amor. Siento cómo me libero de todas las ataduras.",
                duration: "5-7 min"
            )
            
        case .spiritual:
            return AmarresReadingBlockContent(
                title: "Liberación Divina",
                description: "Con el poder divino, corta todos los vínculos tóxicos",
                instructions: [
                    "Invoca el poder divino",
                    "Pide liberación espiritual",
                    "Visualiza la luz cortando",
                    "Siente la liberación divina"
                ],
                anchors: [
                    "Invoco el poder divino",
                    "Pido liberación espiritual",
                    "Siento la liberación divina"
                ],
                affirmations: [
                    "El poder divino me libera",
                    "Soy liberado espiritualmente",
                    "Estoy libre en la luz divina"
                ],
                meditationText: "Invoco el poder divino para que me libere. Siento cómo la luz divina corta todos los vínculos tóxicos.",
                duration: "5-7 min"
            )
            
        case .traditional:
            return AmarresReadingBlockContent(
                title: "Corte Ancestral",
                description: "Corta vínculos usando la sabiduría de los ancestros",
                instructions: [
                    "Conecta con tus ancestros",
                    "Pide ayuda ancestral",
                    "Visualiza el corte ancestral",
                    "Siente la liberación ancestral"
                ],
                anchors: [
                    "Conecto con mis ancestros",
                    "Pido ayuda ancestral",
                    "Siento la liberación ancestral"
                ],
                affirmations: [
                    "Mis ancestros me liberan",
                    "Soy liberado por la sabiduría ancestral",
                    "Estoy libre en la tradición"
                ],
                meditationText: "Conectando con mis ancestros, pido que me ayuden a cortar los vínculos. Siento cómo su sabiduría me libera.",
                duration: "5-7 min"
            )
        }
    }
    
    private func getProtectionContent(for approach: AmarresApproach) -> AmarresReadingBlockContent {
        switch approach {
        case .secular:
            return AmarresReadingBlockContent(
                title: "Protección Energética",
                description: "Establece barreras protectoras contra futuras influencias",
                instructions: [
                    "Visualiza un escudo de luz",
                    "Envuelve tu campo energético",
                    "Establece límites claros",
                    "Mantén la protección activa"
                ],
                anchors: [
                    "Visualizo un escudo de luz",
                    "Envuelvo mi campo energético",
                    "Establezco límites claros"
                ],
                affirmations: [
                    "Estoy protegido por la luz",
                    "Mi campo energético está seguro",
                    "Mantengo límites saludables"
                ],
                meditationText: "Visualizo un escudo de luz que envuelve mi campo energético. Establezco límites claros y mantengo la protección activa.",
                duration: "5-7 min"
            )
            
        case .spiritual:
            return AmarresReadingBlockContent(
                title: "Protección Divina",
                description: "Establece protección divina contra futuras influencias",
                instructions: [
                    "Invoca la protección divina",
                    "Pide un escudo espiritual",
                    "Visualiza la luz protectora",
                    "Siente la protección divina"
                ],
                anchors: [
                    "Invoco la protección divina",
                    "Pido un escudo espiritual",
                    "Siento la protección divina"
                ],
                affirmations: [
                    "La protección divina me envuelve",
                    "Estoy protegido espiritualmente",
                    "La luz divina me cuida"
                ],
                meditationText: "Invoco la protección divina para que me envuelva. Siento cómo la luz divina me protege de futuras influencias.",
                duration: "5-7 min"
            )
            
        case .traditional:
            return AmarresReadingBlockContent(
                title: "Protección Ancestral",
                description: "Establece protección usando métodos tradicionales",
                instructions: [
                    "Conecta con tus ancestros",
                    "Pide protección ancestral",
                    "Visualiza el escudo ancestral",
                    "Siente la protección tradicional"
                ],
                anchors: [
                    "Conecto con mis ancestros",
                    "Pido protección ancestral",
                    "Siento la protección tradicional"
                ],
                affirmations: [
                    "La protección ancestral me envuelve",
                    "Estoy protegido por mis ancestros",
                    "La sabiduría tradicional me cuida"
                ],
                meditationText: "Conectando con mis ancestros, pido que me protejan. Siento cómo su sabiduría tradicional me envuelve en protección.",
                duration: "5-7 min"
            )
        }
    }
    
    private func getSealingContent(for approach: AmarresApproach) -> AmarresReadingBlockContent {
        switch approach {
        case .secular:
            return AmarresReadingBlockContent(
                title: "Sellado de Liberación",
                description: "Sella el proceso y establece compromisos de autocuidado",
                instructions: [
                    "Sella el proceso con gratitud",
                    "Establece compromisos de autocuidado",
                    "Visualiza el futuro libre",
                    "Mantén la liberación activa"
                ],
                anchors: [
                    "Sello el proceso con gratitud",
                    "Establezco compromisos de autocuidado",
                    "Visualizo el futuro libre"
                ],
                affirmations: [
                    "Sello mi liberación con gratitud",
                    "Me comprometo con mi autocuidado",
                    "Mi futuro es libre y autónomo"
                ],
                meditationText: "Sello este proceso de liberación con gratitud. Establezco compromisos de autocuidado y visualizo un futuro libre.",
                duration: "3-5 min"
            )
            
        case .spiritual:
            return AmarresReadingBlockContent(
                title: "Sellado Sagrado",
                description: "Sella el proceso con la bendición divina",
                instructions: [
                    "Pide la bendición divina",
                    "Sella con gratitud espiritual",
                    "Establece compromisos divinos",
                    "Visualiza el futuro en la luz"
                ],
                anchors: [
                    "Pido la bendición divina",
                    "Sello con gratitud espiritual",
                    "Establezco compromisos divinos"
                ],
                affirmations: [
                    "Recibo la bendición divina",
                    "Sello mi liberación espiritualmente",
                    "Mi futuro está en la luz divina"
                ],
                meditationText: "Pido la bendición divina para sellar mi liberación. Establezco compromisos espirituales y visualizo un futuro en la luz.",
                duration: "3-5 min"
            )
            
        case .traditional:
            return AmarresReadingBlockContent(
                title: "Sellado Ancestral",
                description: "Sella el proceso con la bendición ancestral",
                instructions: [
                    "Pide la bendición ancestral",
                    "Sella con gratitud tradicional",
                    "Establece compromisos ancestrales",
                    "Visualiza el futuro en la tradición"
                ],
                anchors: [
                    "Pido la bendición ancestral",
                    "Sello con gratitud tradicional",
                    "Establezco compromisos ancestrales"
                ],
                affirmations: [
                    "Recibo la bendición ancestral",
                    "Sello mi liberación tradicionalmente",
                    "Mi futuro está en la tradición"
                ],
                meditationText: "Pido la bendición ancestral para sellar mi liberación. Establezco compromisos tradicionales y visualizo un futuro en la tradición.",
                duration: "3-5 min"
            )
        }
    }
}
