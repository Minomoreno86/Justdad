//
//  PsychogenealogyLetterData.swift
//  JustDad - Psicogenealogía Letter Data
//
//  Datos de las cartas de Psicogenealogía
//  Created by Jorge Vasquez Rodriguez
//

import Foundation
import SwiftUI

// MARK: - Psychogenealogy Letter Data Provider
class PsychogenealogyLetterDataProvider {
    static let allLetters: [PsychogenealogyLetter] = [
        // MARK: - Cartas al Linaje Paterno
        PsychogenealogyLetter(
            type: .paternalLineage,
            title: "Carta al Linaje Paterno Ausente",
            content: "Hoy me dirijo al linaje paterno de mi familia. Reconozco a todos los hombres que vinieron antes de mí, aunque hayan estado ausentes, aunque hayan fallado en su presencia. No los juzgo; los reconozco como parte de mi historia. Hoy elijo cortar la repetición de la ausencia. Yo seré un padre presente, yo caminaré distinto. Les devuelvo sus cargas y tomo solo la vida que me dieron. Honro lo que recibí, libero lo que me ata, y camino en mi propio destino con fuerza y libertad.",
            voiceAnchors: ["te reconozco", "te libero", "honro mi camino"],
            affirmations: ["Soy un hombre libre", "Me sostengo en mi fuerza"],
            duration: 6,
            targetPattern: .absence
        ),
        
        PsychogenealogyLetter(
            type: .paternalLineage,
            title: "Carta al Abuelo Paterno",
            content: "Abuelo, te reconozco. Reconozco tu historia, tu dolor, tus luchas. Veo cómo tus decisiones afectaron a mi padre y cómo eso llegó hasta mí. Hoy elijo liberar la cadena. No heredo tu dolor, sino tu fuerza. No heredo tus miedos, sino tu coraje. Te honro desde la distancia, te agradezco la vida que me diste, y elijo caminar mi propio camino con amor y presencia. Que tu alma descanse en paz, y que mi camino sea diferente.",
            voiceAnchors: ["te reconozco", "te libero", "camino diferente"],
            affirmations: ["Heredo tu fuerza", "Camino con amor"],
            duration: 5,
            targetPattern: .absence
        ),
        
        PsychogenealogyLetter(
            type: .paternalLineage,
            title: "Carta al Bisabuelo",
            content: "Bisabuelo, aunque nunca te conocí, siento tu presencia en mi sangre. Veo cómo las decisiones que tomaste hace décadas siguen resonando en mi vida hoy. Reconozco el peso que cargas, reconozco el dolor que heredé. Pero hoy elijo liberar esa herencia. Te devuelvo las cargas que no me pertenecen. Me quedo solo con el amor y la vida que me diste. Que tu espíritu encuentre paz, y que yo encuentre mi propio camino libre de ataduras ancestrales.",
            voiceAnchors: ["te reconozco", "te libero", "libre de ataduras"],
            affirmations: ["Soy libre", "Camino mi destino"],
            duration: 5,
            targetPattern: .absence
        ),
        
        // MARK: - Cartas al Linaje Materno
        PsychogenealogyLetter(
            type: .maternalLineage,
            title: "Carta al Linaje Materno",
            content: "Madre, abuela, bisabuela... A todas las mujeres de mi linaje materno. Reconozco vuestro dolor, vuestras luchas, vuestro amor incondicional. Veo cómo habéis cargado con las emociones de la familia, cómo habéis sido las pilares silenciosos. Hoy os libero de esa carga. Ya no necesito que me sostengáis desde el dolor. Os amo, os honro, pero elijo recibir vuestro amor desde la fuerza, no desde la necesidad. Que vuestro amor me fortalezca, no me ate.",
            voiceAnchors: ["os reconozco", "os libero", "os amo"],
            affirmations: ["Recibo vuestro amor", "Soy fuerte"],
            duration: 6,
            targetPattern: .absence
        ),
        
        PsychogenealogyLetter(
            type: .maternalLineage,
            title: "Carta a la Abuela Materna",
            content: "Abuela, te veo. Te veo en tus silencios, en tu forma de amar, en cómo cargaste con el dolor de la familia. Reconozco que heredé de ti la responsabilidad emocional, la necesidad de cuidar a todos. Hoy elijo liberar esa herencia. No soy responsable del dolor de otros. Puedo amar sin cargar. Puedo cuidar sin sacrificarme. Te honro, te agradezco, pero elijo amarme primero. Que tu alma encuentre paz, y que yo encuentre el equilibrio entre el amor y la libertad.",
            voiceAnchors: ["te veo", "te libero", "me amo primero"],
            affirmations: ["Amo sin cargar", "Me amo primero"],
            duration: 5,
            targetPattern: .absence
        ),
        
        // MARK: - Cartas a los Secretos Familiares
        PsychogenealogyLetter(
            type: .familySecrets,
            title: "Carta a los Secretos Familiares",
            content: "Secretos familiares, os reconozco. Reconozco vuestro peso, vuestro silencio, cómo habéis moldeado nuestras vidas desde las sombras. Ya no os temo. Ya no permito que me controléis. Os doy voz, os doy luz. Lo que se oculta en la familia, se manifiesta en la vida. Hoy elijo la transparencia. Hoy elijo la verdad. Que los secretos salgan a la luz, que la familia se libere del peso del silencio. Ya no heredo vuestros secretos. Ya no repito vuestros patrones.",
            voiceAnchors: ["os reconozco", "os doy luz", "elijo la verdad"],
            affirmations: ["Soy transparente", "Vivo en verdad"],
            duration: 6,
            targetPattern: .secrets
        ),
        
        PsychogenealogyLetter(
            type: .familySecrets,
            title: "Carta al Hijo No Reconocido",
            content: "Hermano o hermana que no conocí, que fuiste ocultado, que fuiste silenciado. Te reconozco. Reconozco tu existencia, tu derecho a ser amado, tu lugar en la familia. Aunque fuiste ocultado, aunque fuiste negado, hoy te doy voz. Eres parte de nosotros. Eres parte de mí. Te honro, te incluyo en mi corazón. Que tu alma encuentre paz. Que tu historia sea reconocida. Ya no permito que los secretos dividan a la familia. Te amo, te reconozco, te honro.",
            voiceAnchors: ["te reconozco", "te doy voz", "te amo"],
            affirmations: ["Reconozco la verdad", "Amo sin condiciones"],
            duration: 5,
            targetPattern: .secrets
        ),
        
        // MARK: - Cartas a los Patrones Repetidos
        PsychogenealogyLetter(
            type: .divorcePattern,
            title: "Carta al Ciclo de Divorcios",
            content: "Ciclo de divorcios, patrón que se repite en mi familia, te reconozco. Veo cómo se ha repetido generación tras generación. Veo cómo cada uno de nosotros ha heredado el miedo al compromiso, la incapacidad de amar completamente. Hoy corto esa cadena. Yo no soy mis ancestros. Yo elijo amar diferente. Yo elijo comprometerme desde el amor, no desde el miedo. Ya no repito el patrón. Ya no heredo el dolor. Elijo crear un nuevo legado de amor duradero y compromiso verdadero.",
            voiceAnchors: ["te reconozco", "corto la cadena", "amo diferente"],
            affirmations: ["Amo completamente", "Creo nuevo legado"],
            duration: 6,
            targetPattern: .divorce
        ),
        
        PsychogenealogyLetter(
            type: .divorcePattern,
            title: "Carta al Patrón de Abandono",
            content: "Patrón de abandono, te reconozco. Veo cómo se repite en mi familia: padres que abandonan, hijos que abandonan, parejas que abandonan. Reconozco el miedo que heredé, la creencia de que no soy suficiente, de que seré abandonado. Hoy libero esa creencia. Hoy elijo creer que soy digno de amor, que soy digno de permanencia. Ya no abandono antes de ser abandonado. Ya no repito el patrón. Elijo amar desde la seguridad, no desde el miedo. Elijo ser presente, no ausente.",
            voiceAnchors: ["te reconozco", "soy digno", "elijo permanecer"],
            affirmations: ["Soy digno de amor", "Permanezco presente"],
            duration: 6,
            targetPattern: .absence
        ),
        
        PsychogenealogyLetter(
            type: .divorcePattern,
            title: "Carta al Patrón de Adicciones",
            content: "Patrón de adicciones, te reconozco. Veo cómo se ha repetido en mi familia: abuelos, padres, hermanos, todos buscando escapar del dolor a través de sustancias o comportamientos. Reconozco la vulnerabilidad que heredé, la tendencia a buscar escape en lugar de enfrentar. Hoy elijo enfrentar. Hoy elijo sentir. Ya no escapo del dolor, lo abrazo. Ya no busco adormecer, busco despertar. Elijo la sobriedad emocional, la presencia plena, la vida consciente. Rompo la cadena de la adicción.",
            voiceAnchors: ["te reconozco", "elijo enfrentar", "rompo la cadena"],
            affirmations: ["Soy consciente", "Vivo presente"],
            duration: 6,
            targetPattern: .addiction
        ),
        
        // MARK: - Cartas de Integración
        PsychogenealogyLetter(
            type: .integration,
            title: "Carta de Integración Familiar",
            content: "Familia, te reconozco completa. Te reconozco con todos tus claroscuros, con todos tus secretos, con todos tus patrones. No te juzgo, te amo. Te amo desde la comprensión, desde la compasión, desde el reconocimiento de que todos hicimos lo mejor que pudimos con lo que teníamos. Hoy me integro a ti desde el amor, no desde el dolor. Hoy tomo mi lugar en la familia desde la fuerza, no desde la necesidad. Soy parte de ti, pero soy también único. Honro mi lugar, honro mi diferencia, honro mi camino.",
            voiceAnchors: ["te reconozco", "te amo", "honro mi camino"],
            affirmations: ["Soy parte de la familia", "Soy único"],
            duration: 6,
            targetPattern: .absence
        ),
        
        PsychogenealogyLetter(
            type: .integration,
            title: "Carta a Mi Lugar en el Sistema",
            content: "Sistema familiar, reconozco mi lugar en ti. Reconozco las dinámicas, los roles, las expectativas. Reconozco cómo me posicioné, cómo me adapté, cómo sobreviví. Hoy elijo no solo sobrevivir, sino vivir. Hoy elijo no solo adaptarme, sino transformar. Tomo mi lugar desde la autenticidad, no desde la adaptación. Soy hijo, soy padre, soy hermano, pero sobre todo, soy yo mismo. Honro mis roles, pero no me pierdo en ellos. Mantengo mi identidad dentro del sistema familiar.",
            voiceAnchors: ["reconozco mi lugar", "soy auténtico", "mantengo mi identidad"],
            affirmations: ["Soy auténtico", "Mantengo mi identidad"],
            duration: 5,
            targetPattern: .absence
        ),
        
        // MARK: - Cartas de Liberación
        PsychogenealogyLetter(
            type: .integration,
            title: "Carta de Liberación Ancestral",
            content: "Ancestros, os libero. Os libero de vuestro dolor, de vuestras cargas, de vuestros patrones. Os libero para que vuestras almas encuentren paz. Ya no cargo con vuestro peso. Ya no repito vuestros errores. Ya no heredo vuestro dolor. Os amo, os honro, pero os libero. Que vuestro amor me fortalezca, pero que vuestro dolor no me limite. Que vuestras virtudes me inspiren, pero que vuestros miedos no me paralicen. Soy libre. Soy yo. Camino mi propio destino con amor y gratitud hacia vosotros.",
            voiceAnchors: ["os libero", "soy libre", "camino mi destino"],
            affirmations: ["Soy libre", "Camino mi destino"],
            duration: 7,
            targetPattern: .absence
        ),
        
        PsychogenealogyLetter(
            type: .integration,
            title: "Carta de Liberación de Lealtades Invisibles",
            content: "Lealtades invisibles, os reconozco. Os reconozco en mi forma de actuar, en mis decisiones, en mis miedos. Veo cómo he sido leal a patrones que no me sirven, a creencias que me limitan, a dinámicas que me dañan. Hoy rompo esas lealtades. Hoy elijo ser leal a mí mismo, a mi verdad, a mi bienestar. Ya no soy leal al dolor familiar. Ya no soy leal a los patrones destructivos. Soy leal al amor, a la sanación, a la evolución. Libero las lealtades que me atan y elijo las que me liberan.",
            voiceAnchors: ["os reconozco", "rompo las lealtades", "soy leal a mí"],
            affirmations: ["Soy leal a mí mismo", "Elijo la sanación"],
            duration: 6,
            targetPattern: .absence
        ),
        
        // MARK: - Cartas de Sanación
        PsychogenealogyLetter(
            type: .integration,
            title: "Carta de Sanación Transgeneracional",
            content: "Sanación transgeneracional, te invoco. Te invoco para curar las heridas que se han transmitido de generación en generación. Te invoco para cerrar los círculos de dolor, para abrir los círculos de amor. Que la sanación fluya desde mí hacia mis ancestros y hacia mis descendientes. Que el amor reemplace al miedo, que la comprensión reemplace al juicio, que la compasión reemplace al resentimiento. Soy el canal de sanación en mi familia. A través de mi sanación, sano a mis ancestros. A través de mi amor, amo a mis descendientes.",
            voiceAnchors: ["te invoco", "soy canal de sanación", "el amor reemplaza al miedo"],
            affirmations: ["Soy canal de sanación", "El amor fluye a través mío"],
            duration: 7,
            targetPattern: .absence
        ),
        
        PsychogenealogyLetter(
            type: .integration,
            title: "Carta de Sanación del Niño Interior",
            content: "Niño interior, te veo. Te veo herido por los patrones familiares, por las expectativas, por los miedos heredados. Te veo buscando amor donde no lo hay, buscando aprobación donde no la encuentras. Hoy te abrazo. Hoy te digo que eres suficiente, que eres amado, que eres valioso. No necesitas ser perfecto para ser amado. No necesitas cumplir expectativas para ser valioso. Eres suficiente tal como eres. Te amo, te acepto, te honro. Juntos sanamos, juntos crecemos, juntos evolucionamos.",
            voiceAnchors: ["te veo", "te abrazo", "eres suficiente"],
            affirmations: ["Soy suficiente", "Me amo tal como soy"],
            duration: 6,
            targetPattern: .absence
        ),
        
        // MARK: - Cartas de Gratitud
        PsychogenealogyLetter(
            type: .integration,
            title: "Carta de Gratitud Ancestral",
            content: "Ancestros, os agradezco. Os agradezco por la vida que me disteis, por las lecciones que me enseñasteis, por el amor que me transmitisteis. Aunque hubo dolor, aunque hubo errores, aunque hubo patrones que no me sirven, os agradezco. Porque a través de vosotros llegué aquí, a través de vosotros soy quien soy. Os agradezco por vuestra fuerza, por vuestra resistencia, por vuestro amor. Os agradezco por haberme dado la oportunidad de evolucionar, de sanar, de crear un nuevo legado. Vuestra vida no fue en vano. A través de mí, vuestro amor se multiplica.",
            voiceAnchors: ["os agradezco", "vuestro amor se multiplica", "creo nuevo legado"],
            affirmations: ["Agradezco mi herencia", "Multiplico el amor"],
            duration: 6,
            targetPattern: .absence
        ),
        
        PsychogenealogyLetter(
            type: .integration,
            title: "Carta de Gratitud por la Oportunidad de Sanar",
            content: "Vida, te agradezco. Te agradezco por darme la oportunidad de sanar, de evolucionar, de romper patrones. Te agradezco por ponerme en el lugar exacto donde puedo hacer la diferencia. Te agradezco por la conciencia, por la compasión, por el amor que me permites sentir. No es casualidad que esté aquí, ahora, con esta capacidad de sanar. Es un regalo, es una oportunidad, es una responsabilidad sagrada. Te agradezco por confiar en mí para sanar mi linaje, para crear un nuevo legado, para multiplicar el amor en el mundo.",
            voiceAnchors: ["te agradezco", "es un regalo", "multiplico el amor"],
            affirmations: ["Agradezco la oportunidad", "Multiplico el amor"],
            duration: 5,
            targetPattern: .absence
        )
    ]
    
    static func getLettersForPattern(_ patternType: PatternType) -> [PsychogenealogyLetter] {
        return allLetters.filter { $0.targetPattern == patternType }
    }
    
    static func getLettersForRelationship(_ relationship: RelationshipType) -> [PsychogenealogyLetter] {
        return allLetters.filter { $0.targetRelationship == relationship }
    }
    
    static func getLettersForType(_ letterType: LetterType) -> [PsychogenealogyLetter] {
        return allLetters.filter { $0.type == letterType }
    }
    
    static func getRandomLetter() -> PsychogenealogyLetter? {
        return allLetters.randomElement()
    }
    
    static func getLetterById(_ id: UUID) -> PsychogenealogyLetter? {
        return allLetters.first { $0.id == id }
    }
}