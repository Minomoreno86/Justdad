//
//  KarmicContentPack.swift
//  JustDad - Karmic Bonds Liberation Content Pack
//
//  Paquete de contenidos para el módulo de Vínculos Pesados
//

import Foundation
import SwiftUI

// MARK: - Karmic Content Script
public struct KarmicScript: Identifiable, Codable {
    public let id = UUID()
    public let title: String
    public let intro: String
    public let evocation: String
    public let recognitionBlock: KarmicReadingBlockContent
    public let liberationBlock: KarmicReadingBlockContent
    public let returningBlock: KarmicReadingBlockContent
    public let sealing: String
    public let suggestedVows: [KarmicBehavioralVow]
    
    public init(
        title: String,
        intro: String,
        evocation: String,
        recognitionBlock: KarmicReadingBlockContent,
        liberationBlock: KarmicReadingBlockContent,
        returningBlock: KarmicReadingBlockContent,
        sealing: String,
        suggestedVows: [KarmicBehavioralVow]
    ) {
        self.title = title
        self.intro = intro
        self.evocation = evocation
        self.recognitionBlock = recognitionBlock
        self.liberationBlock = liberationBlock
        self.returningBlock = returningBlock
        self.sealing = sealing
        self.suggestedVows = suggestedVows
    }
}

// MARK: - Karmic Reading Block Content
public struct KarmicReadingBlockContent: Identifiable, Codable {
    public let id = UUID()
    public let blockType: KarmicReadingBlock
    public let text: String
    public let voiceAnchors: [String]
    
    public init(blockType: KarmicReadingBlock, text: String, voiceAnchors: [String]) {
        self.blockType = blockType
        self.text = text
        self.voiceAnchors = voiceAnchors
    }
}

// MARK: - Karmic Content Pack
public class KarmicContentPack: ObservableObject {
    public static let shared = KarmicContentPack()
    
    @Published public var secularScripts: [KarmicScript] = []
    @Published public var spiritualScripts: [KarmicScript] = []
    
    private init() {
        loadContent()
    }
    
    // MARK: - Public Methods
    
    /// Obtiene un script específico por tipo de vínculo y enfoque
    public func getScript(for bondType: KarmicBondType, approach: KarmicApproach) -> KarmicScript? {
        let scripts = approach == .secular ? secularScripts : spiritualScripts
        
        switch bondType {
        case .exPartner:
            return scripts.first { $0.title.contains("expareja") }
        case .ancestralLoyalty:
            return scripts.first { $0.title.contains("ancestral") }
        case .emotionalDebt:
            return scripts.first { $0.title.contains("deuda") }
        case .soulBond:
            return scripts.first { $0.title.contains("alma") }
        case .betrayalRumination:
            return scripts.first { $0.title.contains("traición") }
        case .brokenPromises:
            return scripts.first { $0.title.contains("promesas") }
        case .emotionalDependency:
            return scripts.first { $0.title.contains("dependencia") }
        case .projectionBurden:
            return scripts.first { $0.title.contains("proyecciones") }
        case .controlStruggle:
            return scripts.first { $0.title.contains("control") }
        case .unrequitedSoul:
            return scripts.first { $0.title.contains("correspondido") }
        case .descendantsPast:
            return scripts.first { $0.title.contains("descendientes") && $0.title.contains("pasado") }
        case .descendantsFuture:
            return scripts.first { $0.title.contains("descendientes") && $0.title.contains("futuro") }
        case .karmicLineage:
            return scripts.first { $0.title.contains("kármica") }
        }
    }
    
    /// Obtiene un script por índice
    public func getScript(at index: Int, approach: KarmicApproach) -> KarmicScript? {
        let scripts = approach == .secular ? secularScripts : spiritualScripts
        guard index >= 0 && index < scripts.count else { return nil }
        return scripts[index]
    }
    
    /// Obtiene todos los scripts para un enfoque
    public func getScripts(for approach: KarmicApproach) -> [KarmicScript] {
        return approach == .secular ? secularScripts : spiritualScripts
    }
    
    // MARK: - Private Methods
    
    private func loadContent() {
        secularScripts = createSecularScripts()
        spiritualScripts = createSpiritualScripts()
    }
    
    private func createSecularScripts() -> [KarmicScript] {
        return [
            // 1. Liberación de vínculo con expareja (Secular)
            KarmicScript(
                title: "Liberación de vínculo con expareja",
                intro: "Este ritual es simbólico y terapéutico. No justifica el pasado: te libera para elegir mejor hoy.",
                evocation: "Trae a tu mente a esta persona. Observa cómo su recuerdo impacta tu cuerpo y tu ánimo.",
                recognitionBlock: KarmicReadingBlockContent(
                    blockType: .recognition,
                    text: "Reconozco lo que vivimos y cómo me afectó. Reconozco que puse energía y tiempo que hoy necesito recuperar. Reconozco que la relación terminó y no necesito seguir atado a su eco.",
                    voiceAnchors: ["reconozco lo que vivimos", "me afectó", "no necesito seguir atado"]
                ),
                liberationBlock: KarmicReadingBlockContent(
                    blockType: .liberation,
                    text: "Hoy elijo soltar esta conexión que me pesa. Corto este lazo y dejo de alimentarlo. Mi atención vuelve a mí, a mi presente y a lo que sí puedo construir.",
                    voiceAnchors: ["elijo soltar", "corto este lazo", "mi atención vuelve a mí"]
                ),
                returningBlock: KarmicReadingBlockContent(
                    blockType: .returning,
                    text: "Te devuelvo lo que es tuyo y recupero lo que es mío: mi calma, mi tiempo, mi libertad. Sigo mi camino con dignidad y respeto.",
                    voiceAnchors: ["te devuelvo lo que es tuyo", "recupero lo que es mío", "mi libertad"]
                ),
                sealing: "Estoy protegido, en paz y con límites claros. El pasado ya no gobierna mi presente.",
                suggestedVows: [
                    KarmicBehavioralVow(title: "No revisar chats antiguos por 72h", duration: .seventyTwoHours, category: .digitalHygiene, isCustom: false, reminderDate: nil),
                    KarmicBehavioralVow(title: "Respirar 5-5 durante 3 minutos antes de dormir", duration: .twentyFourHours, category: .mindfulness, isCustom: false, reminderDate: nil),
                    KarmicBehavioralVow(title: "Hablar 15 minutos con mis hijos hoy", duration: .twentyFourHours, category: .coparenting, isCustom: false, reminderDate: nil)
                ]
            ),
            
            // 2. Liberar vínculo con promesas rotas (Secular)
            KarmicScript(
                title: "Liberar vínculo con promesas rotas",
                intro: "Este proceso te ayuda a soltar expectativas que aún te atan.",
                evocation: "Trae la escena de la promesa rota y nómbrala en voz alta.",
                recognitionBlock: KarmicReadingBlockContent(
                    blockType: .recognition,
                    text: "Reconozco que esta promesa no pudo sostenerse y que me aferré a su idea por miedo.",
                    voiceAnchors: ["no pudo sostenerse", "me aferré por miedo", "promesa"]
                ),
                liberationBlock: KarmicReadingBlockContent(
                    blockType: .liberation,
                    text: "Hoy dejo ir la expectativa que me aprisiona. Corto el lazo con esa imagen idealizada.",
                    voiceAnchors: ["dejo ir la expectativa", "corto el lazo", "imagen idealizada"]
                ),
                returningBlock: KarmicReadingBlockContent(
                    blockType: .returning,
                    text: "Recupero mi poder de decidir distinto ahora. Reubico mi energía en lo que sí es posible.",
                    voiceAnchors: ["recupero mi poder", "decidir distinto", "lo posible"]
                ),
                sealing: "Estoy en calma y con foco en el presente.",
                suggestedVows: [
                    KarmicBehavioralVow(title: "Responder a mi ex solo por temas de hijos", duration: .seventyTwoHours, category: .noContact, isCustom: false, reminderDate: nil),
                    KarmicBehavioralVow(title: "Evitar relecturas de chats por 72h", duration: .seventyTwoHours, category: .digitalHygiene, isCustom: false, reminderDate: nil),
                    KarmicBehavioralVow(title: "Dormir antes de las 23:00", duration: .twentyFourHours, category: .selfCare, isCustom: false, reminderDate: nil)
                ]
            ),
            
            // 3. Corte de dependencia emocional (Secular)
            KarmicScript(
                title: "Corte de dependencia emocional",
                intro: "Regresa tu atención a ti, con límites y autocuidado.",
                evocation: "Nombra el hábito que te mantiene pendiente.",
                recognitionBlock: KarmicReadingBlockContent(
                    blockType: .recognition,
                    text: "Reconozco que mi atención se fue detrás de lo que no puedo controlar.",
                    voiceAnchors: ["mi atención se fue", "no puedo controlar", "reconozco"]
                ),
                liberationBlock: KarmicReadingBlockContent(
                    blockType: .liberation,
                    text: "Hoy corto esta dependencia. Recupero mi tiempo y mi calma.",
                    voiceAnchors: ["corto esta dependencia", "recupero mi tiempo", "mi calma"]
                ),
                returningBlock: KarmicReadingBlockContent(
                    blockType: .returning,
                    text: "Me trato con respeto y cuido mi energía. Dirijo mi atención a lo valioso de mi día.",
                    voiceAnchors: ["me trato con respeto", "cuido mi energía", "mi atención"]
                ),
                sealing: "Estoy en paz, con límites claros.",
                suggestedVows: [
                    KarmicBehavioralVow(title: "Bloquear notificaciones 24h", duration: .twentyFourHours, category: .digitalHygiene, isCustom: false, reminderDate: nil),
                    KarmicBehavioralVow(title: "Paseo de 20 min sin móvil", duration: .twentyFourHours, category: .physicalActivity, isCustom: false, reminderDate: nil),
                    KarmicBehavioralVow(title: "Llamar 10 min a un amigo", duration: .twentyFourHours, category: .selfCare, isCustom: false, reminderDate: nil)
                ]
            ),
            
            // 4. Devolver proyecciones (Secular)
            KarmicScript(
                title: "Devolver proyecciones",
                intro: "Devuelve lo que no es tuyo; toma lo que sí te corresponde.",
                evocation: "Nombra la situación donde cargaste de más.",
                recognitionBlock: KarmicReadingBlockContent(
                    blockType: .recognition,
                    text: "Reconozco que asumí culpas y roles que no me correspondían.",
                    voiceAnchors: ["asumí culpas", "no me correspondían"]
                ),
                liberationBlock: KarmicReadingBlockContent(
                    blockType: .liberation,
                    text: "Hoy suelto esas proyecciones y dejo de sostenerlas.",
                    voiceAnchors: ["suelto proyecciones", "dejo de sostenerlas"]
                ),
                returningBlock: KarmicReadingBlockContent(
                    blockType: .returning,
                    text: "Tomo lo que es mío: mis decisiones, mi atención y mi cuidado.",
                    voiceAnchors: ["tomo lo que es mío", "mis decisiones", "mi cuidado"]
                ),
                sealing: "Estoy claro y liviano.",
                suggestedVows: [
                    KarmicBehavioralVow(title: "Plan de no-contact 48h", duration: .fortyEightHours, category: .noContact, isCustom: false, reminderDate: nil),
                    KarmicBehavioralVow(title: "Actividad con hijos", duration: .twentyFourHours, category: .coparenting, isCustom: false, reminderDate: nil),
                    KarmicBehavioralVow(title: "Dormir temprano", duration: .twentyFourHours, category: .selfCare, isCustom: false, reminderDate: nil)
                ]
            ),
            
            // 5. Soltar control y aceptar realidad (Secular)
            KarmicScript(
                title: "Soltar control y aceptar realidad",
                intro: "Cede lo que no controlas; actúa donde sí puedes.",
                evocation: "Nombra lo que intentas controlar sin resultado.",
                recognitionBlock: KarmicReadingBlockContent(
                    blockType: .recognition,
                    text: "Reconozco mi lucha con lo que no puedo controlar.",
                    voiceAnchors: ["lucha con lo que no puedo controlar"]
                ),
                liberationBlock: KarmicReadingBlockContent(
                    blockType: .liberation,
                    text: "Suelto la necesidad de control. Dejo de pelear con la realidad.",
                    voiceAnchors: ["suelto la necesidad de control", "dejo de pelear con la realidad"]
                ),
                returningBlock: KarmicReadingBlockContent(
                    blockType: .returning,
                    text: "Dirijo mi energía a acciones concretas aquí y ahora.",
                    voiceAnchors: ["dirijo mi energía", "acciones concretas", "aquí y ahora"]
                ),
                sealing: "Estoy sereno y eficaz.",
                suggestedVows: [
                    KarmicBehavioralVow(title: "Lista de 3 acciones realistas", duration: .twentyFourHours, category: .mindfulness, isCustom: false, reminderDate: nil),
                    KarmicBehavioralVow(title: "Salir a caminar 15 min", duration: .twentyFourHours, category: .physicalActivity, isCustom: false, reminderDate: nil),
                    KarmicBehavioralVow(title: "Bloquear redes 2h", duration: .twentyFourHours, category: .digitalHygiene, isCustom: false, reminderDate: nil)
                ]
            ),
            
            // 6. Cortar rumiación y anclar presente (Secular)
            KarmicScript(
                title: "Cortar rumiación y anclar presente",
                intro: "Poner fin a la rumiación y abrir espacio al presente.",
                evocation: "Nombra el pensamiento recurrente.",
                recognitionBlock: KarmicReadingBlockContent(
                    blockType: .recognition,
                    text: "Reconozco que esta rumiación agota mi energía.",
                    voiceAnchors: ["rumiación agota mi energía"]
                ),
                liberationBlock: KarmicReadingBlockContent(
                    blockType: .liberation,
                    text: "Corto el ciclo repetitivo ahora. Dejo de alimentar el bucle.",
                    voiceAnchors: ["corto el ciclo repetitivo", "dejo de alimentar el bucle"]
                ),
                returningBlock: KarmicReadingBlockContent(
                    blockType: .returning,
                    text: "Anclo mi atención en este momento y en lo que sí depende de mí.",
                    voiceAnchors: ["anclo mi atención", "este momento"]
                ),
                sealing: "Estoy presente y en calma.",
                suggestedVows: [
                    KarmicBehavioralVow(title: "Respirar 5-5 3 min", duration: .twentyFourHours, category: .mindfulness, isCustom: false, reminderDate: nil),
                    KarmicBehavioralVow(title: "Ejercicio breve 10 min", duration: .twentyFourHours, category: .physicalActivity, isCustom: false, reminderDate: nil),
                    KarmicBehavioralVow(title: "Escribir 3 prioridades de hoy", duration: .twentyFourHours, category: .mindfulness, isCustom: false, reminderDate: nil)
                ]
            )
        ]
    }
    
    private func createSpiritualScripts() -> [KarmicScript] {
        return [
            // 1. Corte de lazo kármico con expareja (Espiritual)
            KarmicScript(
                title: "Corte de lazo kármico con expareja",
                intro: "Este ritual es simbólico; entrega el vínculo a la luz y recupera tu energía.",
                evocation: "Trae a la mente su presencia y respira. Permite que emerja lo necesario para ser liberado.",
                recognitionBlock: KarmicReadingBlockContent(
                    blockType: .recognition,
                    text: "Reconozco nuestro lazo de alma y su propósito cumplido. Reconozco lo aprendido y también el peso que quedó.",
                    voiceAnchors: ["lazo de alma", "propósito cumplido", "lo aprendido"]
                ),
                liberationBlock: KarmicReadingBlockContent(
                    blockType: .liberation,
                    text: "Corto todo lazo kármico que ya cumplió su función. Lo entrego a la luz y dejo de sostenerlo con mi energía.",
                    voiceAnchors: ["corto lazo kármico", "lo entrego a la luz", "dejo de sostenerlo"]
                ),
                returningBlock: KarmicReadingBlockContent(
                    blockType: .returning,
                    text: "Te devuelvo lo que pertenece a tu camino y recupero lo que es mío. Que cada alma siga su viaje en paz.",
                    voiceAnchors: ["devuelvo lo que pertenece a tu camino", "recupero lo que es mío", "en paz"]
                ),
                sealing: "Estoy protegido en la luz. Camino en paz, con límites y libertad.",
                suggestedVows: [
                    KarmicBehavioralVow(title: "Repetir mentalmente: 'Camino en paz' antes de dormir", duration: .twentyFourHours, category: .mindfulness, isCustom: false, reminderDate: nil),
                    KarmicBehavioralVow(title: "Caminar 20 minutos al aire libre hoy", duration: .twentyFourHours, category: .physicalActivity, isCustom: false, reminderDate: nil),
                    KarmicBehavioralVow(title: "Escribir una gratitud del día", duration: .twentyFourHours, category: .mindfulness, isCustom: false, reminderDate: nil)
                ]
            ),
            
            // 2. Liberación de lealtad ancestral (Espiritual)
            KarmicScript(
                title: "Liberación de lealtad ancestral",
                intro: "Honra a tus ancestros y corta la repetición que ya no te corresponde.",
                evocation: "Evoca a tu linaje masculino. Agradece la vida recibida.",
                recognitionBlock: KarmicReadingBlockContent(
                    blockType: .recognition,
                    text: "Reconozco a los hombres de mi linaje y su historia de presencias y ausencias.",
                    voiceAnchors: ["hombres de mi linaje", "ausencias", "presencias"]
                ),
                liberationBlock: KarmicReadingBlockContent(
                    blockType: .liberation,
                    text: "Corto la lealtad invisible a la ausencia. Elijo presencia y amor consciente.",
                    voiceAnchors: ["corto la lealtad", "ausencia", "elijo presencia"]
                ),
                returningBlock: KarmicReadingBlockContent(
                    blockType: .returning,
                    text: "Devuelvo a mis ancestros sus cargas y tomo solo la vida. Camino liviano y presente.",
                    voiceAnchors: ["devuelvo sus cargas", "tomo la vida", "camino liviano"]
                ),
                sealing: "Estoy protegido en la luz de mi linaje sano.",
                suggestedVows: [
                    KarmicBehavioralVow(title: "Actividad de 30 min con mis hijos hoy", duration: .twentyFourHours, category: .coparenting, isCustom: false, reminderDate: nil),
                    KarmicBehavioralVow(title: "Decir 'estoy aquí' al mirarlos", duration: .twentyFourHours, category: .coparenting, isCustom: false, reminderDate: nil),
                    KarmicBehavioralVow(title: "Respirar 5-5 al despertar", duration: .twentyFourHours, category: .mindfulness, isCustom: false, reminderDate: nil)
                ]
            ),
            
            // 3. Cierre de lazo con traición (Espiritual)
            KarmicScript(
                title: "Cierre de lazo con traición",
                intro: "Suelta el rencor y entrega el dolor a la luz.",
                evocation: "Evoca la herida y respira.",
                recognitionBlock: KarmicReadingBlockContent(
                    blockType: .recognition,
                    text: "Reconozco la herida de la traición y el dolor que dejó.",
                    voiceAnchors: ["herida de la traición", "dolor que dejó"]
                ),
                liberationBlock: KarmicReadingBlockContent(
                    blockType: .liberation,
                    text: "Corto la cadena del rencor y la entrego a la luz. Me libero de sostenerla.",
                    voiceAnchors: ["corto la cadena", "entrego a la luz", "me libero"]
                ),
                returningBlock: KarmicReadingBlockContent(
                    blockType: .returning,
                    text: "Recupero mi paz y mi dignidad. Camino como un hombre libre.",
                    voiceAnchors: ["recupero mi paz", "mi dignidad", "hombre libre"]
                ),
                sealing: "Estoy protegido y mi corazón se fortalece en la luz.",
                suggestedVows: [
                    KarmicBehavioralVow(title: "Escribir 3 líneas de gratitud", duration: .twentyFourHours, category: .mindfulness, isCustom: false, reminderDate: nil),
                    KarmicBehavioralVow(title: "Caminar 15 min", duration: .twentyFourHours, category: .physicalActivity, isCustom: false, reminderDate: nil),
                    KarmicBehavioralVow(title: "Borrar un chat detonante", duration: .twentyFourHours, category: .digitalHygiene, isCustom: false, reminderDate: nil)
                ]
            ),
            
            // 4. Liberación de deuda emocional (Espiritual)
            KarmicScript(
                title: "Liberación de deuda emocional",
                intro: "Corta pactos de deuda afectiva para caminar en libertad.",
                evocation: "Evoca el pacto no dicho que te pesa.",
                recognitionBlock: KarmicReadingBlockContent(
                    blockType: .recognition,
                    text: "Reconozco el pacto de deuda emocional que hemos sostenido.",
                    voiceAnchors: ["pacto de deuda", "hemos sostenido"]
                ),
                liberationBlock: KarmicReadingBlockContent(
                    blockType: .liberation,
                    text: "Corto este pacto y lo entrego a la luz.",
                    voiceAnchors: ["corto este pacto", "lo entrego a la luz"]
                ),
                returningBlock: KarmicReadingBlockContent(
                    blockType: .returning,
                    text: "Recupero mi libertad y te devuelvo lo que te pertenece.",
                    voiceAnchors: ["recupero mi libertad", "te devuelvo lo que te pertenece"]
                ),
                sealing: "Estoy protegido y libre.",
                suggestedVows: [
                    KarmicBehavioralVow(title: "Repetir 'soy libre' 10 veces", duration: .twentyFourHours, category: .mindfulness, isCustom: false, reminderDate: nil),
                    KarmicBehavioralVow(title: "Respirar 5-5 3 min", duration: .twentyFourHours, category: .mindfulness, isCustom: false, reminderDate: nil),
                    KarmicBehavioralVow(title: "Cuidar mi alimentación hoy", duration: .twentyFourHours, category: .selfCare, isCustom: false, reminderDate: nil)
                ]
            ),
            
            // 5. Cierre con vínculo de alma no correspondido (Espiritual)
            KarmicScript(
                title: "Cierre con vínculo de alma no correspondido",
                intro: "Honra el amor y déjalo ir si no camina contigo.",
                evocation: "Evoca con gratitud lo que sí hubo.",
                recognitionBlock: KarmicReadingBlockContent(
                    blockType: .recognition,
                    text: "Reconozco el amor y su aprendizaje en mi camino.",
                    voiceAnchors: ["reconozco el amor", "aprendizaje en mi camino"]
                ),
                liberationBlock: KarmicReadingBlockContent(
                    blockType: .liberation,
                    text: "Entrego este lazo a la luz si ya no nos corresponde seguir.",
                    voiceAnchors: ["entrego este lazo a la luz", "ya no corresponde"]
                ),
                returningBlock: KarmicReadingBlockContent(
                    blockType: .returning,
                    text: "Recupero mi libertad para amar de nuevo cuando sea tiempo.",
                    voiceAnchors: ["recupero mi libertad", "amar de nuevo"]
                ),
                sealing: "Estoy en paz y abierto al bien.",
                suggestedVows: [
                    KarmicBehavioralVow(title: "Afirmación 'merezco amar y ser amado'", duration: .twentyFourHours, category: .mindfulness, isCustom: false, reminderDate: nil),
                    KarmicBehavioralVow(title: "Higiene de sueño", duration: .twentyFourHours, category: .selfCare, isCustom: false, reminderDate: nil),
                    KarmicBehavioralVow(title: "Acto de autocuidado", duration: .twentyFourHours, category: .selfCare, isCustom: false, reminderDate: nil)
                ]
            ),
            
            // 6. Integración de alma: camino propio (Espiritual)
            KarmicScript(
                title: "Integración de alma: camino propio",
                intro: "Agradece, libera y camina con tu propia luz.",
                evocation: "Evoca tu camino futuro con paz.",
                recognitionBlock: KarmicReadingBlockContent(
                    blockType: .recognition,
                    text: "Reconozco lo vivido y lo honro.",
                    voiceAnchors: ["reconozco lo vivido", "lo honro"]
                ),
                liberationBlock: KarmicReadingBlockContent(
                    blockType: .liberation,
                    text: "Libero lo que ya no pertenece a mi camino.",
                    voiceAnchors: ["libero lo que ya no pertenece a mi camino"]
                ),
                returningBlock: KarmicReadingBlockContent(
                    blockType: .returning,
                    text: "Tomo mi destino con amor y confianza.",
                    voiceAnchors: ["tomo mi destino", "amor y confianza"]
                ),
                sealing: "Estoy protegido en la luz y avanzo con calma.",
                suggestedVows: [
                    KarmicBehavioralVow(title: "Gratitud escrita 1 minuto", duration: .twentyFourHours, category: .mindfulness, isCustom: false, reminderDate: nil),
                    KarmicBehavioralVow(title: "Silencio 3 minutos", duration: .twentyFourHours, category: .mindfulness, isCustom: false, reminderDate: nil),
                    KarmicBehavioralVow(title: "Acto de autocuidado", duration: .twentyFourHours, category: .selfCare, isCustom: false, reminderDate: nil)
                ]
            )
        ]
    }
}
