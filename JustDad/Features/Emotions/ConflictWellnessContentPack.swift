//
//  ConflictWellnessContentPack.swift
//  JustDad - Conflict Wellness Content Pack
//
//  Static content for conflict wellness module
//

import Foundation

struct ConflictWellnessContentPack {
    
    // MARK: - Communication Examples
    static let communicationExamples: [CommunicationExample] = [
        // Acusaciones de mal padre
        CommunicationExample(
            category: "Acusaciones de mal padre",
            trigger: "¡Nunca te importa nuestro hijo, eres un irresponsable!",
            responseSerena: "Estaré el sábado a las 10 a.m. en el lugar acordado con nuestro hijo.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        CommunicationExample(
            category: "Acusaciones de mal padre",
            trigger: "Tus hijos no significan nada para ti.",
            responseSerena: "Ayer asistí a la reunión escolar a las 4 p.m. como estaba planificado.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        CommunicationExample(
            category: "Acusaciones de mal padre",
            trigger: "Siempre fallas como padre.",
            responseSerena: "El domingo a las 5 p.m. haré la entrega en el punto acordado.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        CommunicationExample(
            category: "Acusaciones de mal padre",
            trigger: "Nunca apareces cuando te toca.",
            responseSerena: "Confirmo que llegaré hoy a las 6 p.m. al lugar habitual.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        CommunicationExample(
            category: "Acusaciones de mal padre",
            trigger: "Eres un estorbo en la vida de los niños.",
            responseSerena: "Mañana a las 7:30 a.m. los llevaré al colegio como cada lunes.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        
        // Ataques económicos
        CommunicationExample(
            category: "Ataques económicos",
            trigger: "Nunca pagas lo que debes.",
            responseSerena: "El apoyo mensual se transfirió el día 5; puedes revisarlo en tu cuenta.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        CommunicationExample(
            category: "Ataques económicos",
            trigger: "Siempre me dejas sola con los gastos.",
            responseSerena: "Estoy cumpliendo el acuerdo de apoyo mensual establecido.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        CommunicationExample(
            category: "Ataques económicos",
            trigger: "Eres irresponsable con el dinero.",
            responseSerena: "Enviaré hoy el comprobante del pago correspondiente.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        CommunicationExample(
            category: "Ataques económicos",
            trigger: "Me debes más de lo que dice ese papel.",
            responseSerena: "Si necesitas revisar montos, podemos ver el acuerdo escrito.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        
        // Ataques personales
        CommunicationExample(
            category: "Ataques personales",
            trigger: "Eres un inútil, nadie te quiere.",
            responseSerena: "Mañana a las 9 a.m. pasaré a recoger a los niños.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        CommunicationExample(
            category: "Ataques personales",
            trigger: "Eres basura, no sirves para nada.",
            responseSerena: "Hoy a las 6 p.m. haré la entrega en tu domicilio.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        CommunicationExample(
            category: "Ataques personales",
            trigger: "Das pena, siempre fuiste un perdedor.",
            responseSerena: "Estaré a las 7 p.m. en el lugar acordado.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        CommunicationExample(
            category: "Ataques personales",
            trigger: "No cambias nunca.",
            responseSerena: "Confirmo la actividad del niño el jueves a las 4 p.m.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        
        // Manipulación con los hijos
        CommunicationExample(
            category: "Manipulación con los hijos",
            trigger: "Los niños no quieren verte.",
            responseSerena: "Estaré este sábado a las 10 a.m. en el punto de encuentro.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        CommunicationExample(
            category: "Manipulación con los hijos",
            trigger: "Te tienen miedo.",
            responseSerena: "Cumpliré con el horario de crianza compartida de esta semana.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        CommunicationExample(
            category: "Manipulación con los hijos",
            trigger: "Lloran cuando saben que irán contigo.",
            responseSerena: "Estaré a la hora acordada y llevaré su juguete favorito para la transición.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        CommunicationExample(
            category: "Manipulación con los hijos",
            trigger: "No te extrañan en absoluto.",
            responseSerena: "Hoy pasaré a saludar a la salida del colegio según lo hablado.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        
        // Provocaciones emocionales
        CommunicationExample(
            category: "Provocaciones emocionales",
            trigger: "Eres igual que tu padre, un desastre.",
            responseSerena: "El domingo a las 5 p.m. entregaré a los niños en la dirección acordada.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        CommunicationExample(
            category: "Provocaciones emocionales",
            trigger: "Siempre arruinas todo.",
            responseSerena: "Confirmo mi llegada mañana a las 7 p.m.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        CommunicationExample(
            category: "Provocaciones emocionales",
            trigger: "Jamás cambiarás.",
            responseSerena: "El jueves asistiré a la reunión a las 10 a.m.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        
        // Reproches del pasado
        CommunicationExample(
            category: "Reproches del pasado",
            trigger: "Siempre fuiste un fracasado.",
            responseSerena: "Mañana estaré en la escuela a las 10 a.m. para la reunión.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        CommunicationExample(
            category: "Reproches del pasado",
            trigger: "Todo es tu culpa desde el principio.",
            responseSerena: "Haré la recogida hoy a las 6 p.m. como está en el plan.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        CommunicationExample(
            category: "Reproches del pasado",
            trigger: "Nunca diste nada por esta familia.",
            responseSerena: "Enviaré el resumen de actividades de nuestro hijo.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        
        // Críticas sobre nueva pareja
        CommunicationExample(
            category: "Críticas sobre nueva pareja",
            trigger: "Tu nueva pareja no sirve y no la quiero cerca.",
            responseSerena: "La coordinación de entregas se mantiene igual; llegaré a la hora acordada.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        CommunicationExample(
            category: "Críticas sobre nueva pareja",
            trigger: "No quiero que esa persona toque a mis hijos.",
            responseSerena: "Seguiré el plan ya establecido para las visitas.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        CommunicationExample(
            category: "Críticas sobre nueva pareja",
            trigger: "Esa relación afecta a los niños.",
            responseSerena: "Cumpliré los horarios y actividades programadas para nuestro hijo.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        
        // Cambios de última hora
        CommunicationExample(
            category: "Cambios de última hora",
            trigger: "Cambiaremos la hora ahora mismo.",
            responseSerena: "Mantengo la hora acordada. Si necesitas proponer un cambio, indícalo por escrito.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        CommunicationExample(
            category: "Cambios de última hora",
            trigger: "No estaré en el punto de entrega, muévete tú.",
            responseSerena: "Estaré en el punto acordado a la hora habitual.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        CommunicationExample(
            category: "Cambios de última hora",
            trigger: "Recógelos más tarde sin avisar.",
            responseSerena: "Mantengo la hora establecida. Avisaré si hay imprevistos.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        ),
        CommunicationExample(
            category: "Cambios de última hora",
            trigger: "No los llevaré hoy, arregla tú.",
            responseSerena: "Seguiré el plan de hoy y estaré en el lugar acordado.",
            checks: ["Breve", "Clara", "Amable", "Firme"],
            points: 5
        )
    ]
    
    // MARK: - Communication Rules
    static let communicationRules: [CommunicationRule] = [
        CommunicationRule(
            title: "Responde solo lo necesario (breve)",
            description: "Mantén tus respuestas cortas y al punto. No agregues información innecesaria.",
            example: "❌ \"No, no es cierto, siempre he estado ahí...\" ✅ \"Estaré el sábado a las 10 a.m.\""
        ),
        CommunicationRule(
            title: "Quédate en hechos y acuerdos (clara)",
            description: "Enfócate en información específica: fechas, horas, lugares, acuerdos establecidos.",
            example: "❌ \"Tú sabes que siempre cumplo\" ✅ \"El pago se hizo el día 5 como acordamos\""
        ),
        CommunicationRule(
            title: "Usa un tono neutro y respetuoso (amable)",
            description: "Mantén un lenguaje civil y profesional, sin sarcasmo ni ataques.",
            example: "❌ \"Claro, como siempre...\" ✅ \"Confirmo que estaré a las 7 p.m.\""
        ),
        CommunicationRule(
            title: "Cierra el tema sin abrir discusión (firme)",
            description: "Termina la conversación sin dar pie a más debate o argumentación.",
            example: "❌ \"Si quieres podemos hablar de esto más tarde\" ✅ \"El plan se mantiene como está\""
        ),
        CommunicationRule(
            title: "Evita etiquetas, sarcasmo y ataques personales",
            description: "No uses adjetivos negativos, ironía o comentarios sobre la persona.",
            example: "❌ \"Eres imposible\" ✅ \"Mantengo la hora acordada\""
        ),
        CommunicationRule(
            title: "Si dudas, espera 2 minutos y respira 5-5",
            description: "Tómate tiempo para pensar antes de responder. Respira 5 segundos inhalando, 5 exhalando.",
            example: "Pausa antes de enviar cualquier mensaje que pueda escalar el conflicto."
        ),
        CommunicationRule(
            title: "Escribe en afirmativo: indica qué harás y cuándo",
            description: "Usa declaraciones positivas sobre tus acciones futuras.",
            example: "❌ \"No voy a llegar tarde\" ✅ \"Estaré a las 6 p.m. puntual\""
        ),
        CommunicationRule(
            title: "Mantén foco en los hijos y la logística, no en el pasado",
            description: "Centra la comunicación en el presente y futuro, especialmente en el bienestar de los niños.",
            example: "❌ \"Antes también hacías esto\" ✅ \"Hoy llevaré a los niños a su actividad\""
        )
    ]
    
    // MARK: - Children Support Scripts
    static let childrenSupportScripts: [ChildrenSupportScript] = [
        ChildrenSupportScript(
            situation: "El niño pregunta por qué mamá dice cosas malas de papá",
            dontSay: "Tu mamá miente y te manipula",
            doSay: "Entiendo que esto es confuso. No es tu culpa. Yo siempre estaré aquí.",
            explanation: "Validamos sus sentimientos sin atacar al otro progenitor, protegiendo su salud emocional."
        ),
        ChildrenSupportScript(
            situation: "El niño se siente culpable por los conflictos",
            dontSay: "Tu mamá nos hace la vida imposible",
            doSay: "A veces los adultos discuten; tú no tienes la culpa. Te quiero mucho.",
            explanation: "Liberamos al niño de la responsabilidad del conflicto adulto y reforzamos el amor."
        ),
        ChildrenSupportScript(
            situation: "El niño no quiere ir con el otro progenitor",
            dontSay: "No le hagas caso a tu mamá",
            doSay: "Vamos a enfocarnos en que tengas un día tranquilo y seguro.",
            explanation: "No ponemos al niño en medio del conflicto, priorizamos su bienestar emocional."
        ),
        ChildrenSupportScript(
            situation: "El niño está triste después de una entrega",
            dontSay: "Tu mamá te hace daño",
            doSay: "Lo que sientes es válido. Aquí conmigo estás seguro. Podemos hablar cuando quieras.",
            explanation: "Ofrecemos un espacio seguro para que exprese sus emociones sin juicio."
        ),
        ChildrenSupportScript(
            situation: "El niño pregunta por qué no vivimos juntos",
            dontSay: "Tu mamá nos separó",
            doSay: "A veces las familias cambian, pero yo siempre seré tu papá y te querré siempre.",
            explanation: "Explicamos la situación de manera apropiada para su edad sin culpar."
        )
    ]
    
    // MARK: - Self Care Practices
    static let selfCarePractices: [SelfCarePractice] = [
        SelfCarePractice(
            title: "Respiración 5-5",
            description: "Inhala durante 5 segundos, exhala durante 5 segundos. Repite durante 2-3 minutos.",
            duration: "2-3 minutos",
            frequency: "Antes de responder mensajes difíciles",
            icon: "lungs.fill",
            color: "teal"
        ),
        SelfCarePractice(
            title: "Pausa Consciente",
            description: "Espera 2 minutos completos antes de enviar cualquier mensaje que pueda escalar el conflicto.",
            duration: "2 minutos",
            frequency: "Antes de enviar mensajes",
            icon: "timer",
            color: "blue"
        ),
        SelfCarePractice(
            title: "Registro de Gratitud",
            description: "Escribe 3 cosas por las que estés agradecido al final del día.",
            duration: "5 minutos",
            frequency: "Diario",
            icon: "heart.fill",
            color: "pink"
        ),
        SelfCarePractice(
            title: "Actividad Física",
            description: "Realiza 10-20 minutos de ejercicio: caminar, correr, yoga o cualquier actividad que disfrutes.",
            duration: "10-20 minutos",
            frequency: "Diario",
            icon: "figure.walk",
            color: "green"
        ),
        SelfCarePractice(
            title: "Conexión Social",
            description: "Contacta a un amigo, familiar o terapeuta al menos una vez por semana.",
            duration: "30 minutos",
            frequency: "Semanal",
            icon: "person.2.fill",
            color: "purple"
        ),
        SelfCarePractice(
            title: "Afirmación Diaria",
            description: "Repite una afirmación positiva sobre tu rol como padre y tu capacidad de manejar situaciones difíciles.",
            duration: "2 minutos",
            frequency: "Diario",
            icon: "star.fill",
            color: "yellow"
        )
    ]
}
