//
//  LiberationLetterData.swift
//  JustDad - Liberation Letter Data
//
//  Datos de las 21 cartas de liberación organizadas por fases
//

import Foundation

// MARK: - Liberation Letter Data Provider
class LiberationLetterDataProvider {
    static let shared = LiberationLetterDataProvider()
    
    private init() {}
    
    // MARK: - All Liberation Letters
    var allLetters: [LiberationLetter] {
        return phase1Letters + phase2Letters + phase3Letters + phase4Letters
    }
    
    // MARK: - Phase 1: Sanar conmigo mismo (Días 1-7)
    var phase1Letters: [LiberationLetter] {
        [
            LiberationLetter(
                day: 1,
                phase: .selfHealing,
                title: "Carta al Yo del Pasado",
                content: "Hoy me dirijo a mi propio pasado. A ese hombre que tomó decisiones, algunas sabias y otras equivocadas. Reconozco que actué con lo que sabía y con lo que tenía en ese momento. Me equivoqué, sí, pero también aprendí. Ya no castigo a ese hombre que fui, porque fue él quien me trajo hasta aquí, más consciente y más fuerte. Hoy decido mirarme con compasión. Perdono mis errores y me abrazo como un hermano que entiende. Ya no vivo en la condena del ayer; elijo abrirme a la libertad del presente. Yo soy digno de paz, de amor y de un futuro mejor. Me libero y me perdono.",
                duration: "6 min",
                voiceAnchors: ["hice lo que pude", "me perdono", "elijo la paz"],
                affirmations: ["Yo me perdono", "Camino en paz"]
            ),
            
            LiberationLetter(
                day: 2,
                phase: .selfHealing,
                title: "Carta a mis decisiones equivocadas",
                content: "Hoy hablo con mis decisiones pasadas, aquellas que cargué como piedras en mi espalda. Decisiones que creí firmes y que luego se derrumbaron, decisiones que lastimaron y que también me hirieron. Las miro de frente sin miedo y les digo: gracias por enseñarme. Ya no me definen, ya no me aprisionan. Hoy las transformo en lecciones y las suelto. Me perdono por haber elegido desde la ignorancia o el dolor. Y me doy permiso para decidir distinto de ahora en adelante. Hoy reclamo mi poder de elección con sabiduría, claridad y amor propio.",
                duration: "6 min",
                voiceAnchors: ["mis errores no me definen", "aprendo y suelto", "decido distinto"],
                affirmations: ["Aprendo y avanzo", "Actúo con sabiduría"]
            ),
            
            LiberationLetter(
                day: 3,
                phase: .selfHealing,
                title: "Carta al hombre que falló como pareja",
                content: "Hoy hablo con la parte de mí que siente que falló como compañero de vida. Reconozco que no siempre supe amar bien, que mis palabras, mis silencios o mis actos no siempre fueron los mejores. Hoy dejo de culparme eternamente. No fui perfecto, pero fui humano. Reconozco que di lo que pude, con mis límites y heridas. Hoy me perdono, porque no merezco vivir en la cárcel de la culpa. Aprendí, crecí y hoy soy más consciente. Le digo a mi yo de aquella relación: te perdono, te libero y te abrazo con compasión.",
                duration: "6 min",
                voiceAnchors: ["no fui perfecto, fui humano", "me perdono", "me libero de la culpa"],
                affirmations: ["Me abrazo con compasión", "Sigo creciendo"]
            ),
            
            LiberationLetter(
                day: 4,
                phase: .selfHealing,
                title: "Carta al padre que cree que no dio suficiente",
                content: "Hoy me hablo como padre. Sé que muchas veces he sentido que no di lo suficiente a mis hijos, que la separación me robó tiempo y presencia. Hoy me libero de esa culpa. Reconozco que hice lo mejor que pude y que sigo haciéndolo. Mis hijos no necesitan perfección; necesitan amor verdadero y eso siempre lo tuvieron de mí. Me perdono por mis ausencias y me comprometo a estar más presente ahora, con más calidad y más consciencia. Hoy suelto el peso de la culpa paterna y abrazo el poder de un amor que no se rompe con el divorcio. Soy un buen padre y seguiré siéndolo.",
                duration: "6 min",
                voiceAnchors: ["hice lo mejor que pude", "mis hijos necesitan presencia", "me comprometo a estar"],
                affirmations: ["Soy un buen padre", "Estoy presente"]
            ),
            
            LiberationLetter(
                day: 5,
                phase: .selfHealing,
                title: "Carta a mi vergüenza",
                content: "Hoy escribo a mi vergüenza, a esa voz que me dice que soy un fracaso porque mi matrimonio terminó. Hoy le digo: ya no tienes poder sobre mí. El divorcio no me define; me transforma. Soy más que un estado civil, soy un hombre que elige levantarse. Perdonarme es liberarme de la mirada ajena y de mis propios juicios. Hoy camino erguido, sin vergüenza, sin etiquetas. Soy un hombre digno, completo y en evolución. Hoy suelto la vergüenza y abrazo mi nueva vida con fuerza y orgullo.",
                duration: "5 min",
                voiceAnchors: ["el divorcio no me define", "me levanto", "soy digno"],
                affirmations: ["Camino con dignidad", "Me reinvento"]
            ),
            
            LiberationLetter(
                day: 6,
                phase: .selfHealing,
                title: "Carta a mi cuerpo y energía",
                content: "Hoy me hablo a mí mismo, a mi cuerpo y a mi energía. Sé que en medio del dolor me descuidé: no dormí bien, no me alimenté bien, no cuidé mi mente ni mi salud. Hoy pido perdón a mi cuerpo por el abandono, por el cansancio acumulado, por haberlo cargado con tanto dolor. Hoy me reconcilio con él y le prometo atención, cuidado y fuerza. Mi cuerpo es mi templo y mi energía, mi motor. A partir de ahora me trato con respeto, cariño y disciplina. Me perdono por haberme descuidado y me comprometo a honrarme cada día.",
                duration: "5 min",
                voiceAnchors: ["perdón por descuidarte", "mi cuerpo es mi templo", "me comprometo a cuidarme"],
                affirmations: ["Honro mi cuerpo", "Protejo mi energía"]
            ),
            
            LiberationLetter(
                day: 7,
                phase: .selfHealing,
                title: "Carta de reconciliación conmigo mismo",
                content: "Hoy cierro la primera etapa de este camino perdonándome por completo. Reconozco mis sombras y mis luces, mis errores y mis aciertos. No necesito seguir peleando conmigo, porque la batalla interna me roba vida. Hoy me uno conmigo mismo y me abrazo como el hombre que soy: imperfecto, pero valioso; herido, pero resiliente; caído, pero de pie. Me perdono en totalidad y me libero del peso que me mantenía atado al dolor. A partir de hoy, camino conmigo como aliado y no como enemigo. Soy mi propia paz.",
                duration: "6 min",
                voiceAnchors: ["me acepto completo", "me perdono en totalidad", "soy mi propia paz"],
                affirmations: ["Estoy en paz conmigo", "Soy mi aliado"]
            )
        ]
    }
    
    // MARK: - Phase 2: Sanar la relación con la ex-pareja (Días 8-14)
    var phase2Letters: [LiberationLetter] {
        [
            LiberationLetter(
                day: 8,
                phase: .exPartnerHealing,
                title: "Carta a mis expectativas rotas",
                content: "Hoy escribo a las expectativas que tuve sobre mi matrimonio. Creí que sería eterno, que nada podría quebrarlo, que el amor bastaría para todo. Esas ilusiones se rompieron y me dejaron con dolor y frustración. Hoy miro esas expectativas y las suelto. Comprendo que no eran la realidad, sino un sueño que se desvaneció. Ya no vivo aferrado a lo que creí que debía ser; elijo aceptar lo que fue. Agradezco lo vivido, lo aprendido y lo que hoy me permite crecer. Suelto la rigidez del ideal y abrazo la flexibilidad de la vida. Perdono mis expectativas rotas y me libero de ellas.",
                duration: "6 min",
                voiceAnchors: ["suelto la ilusión", "acepto lo que fue", "agradezco lo aprendido"],
                affirmations: ["Flexibilidad y calma", "Acepto y avanzo"]
            ),
            
            LiberationLetter(
                day: 9,
                phase: .exPartnerHealing,
                title: "Carta al dolor de la separación",
                content: "Hoy hablo con el dolor profundo de la separación. Dolor que quemó mi pecho, que me hizo sentir vacío, que me arrancó noches de paz. Hoy no lo niego; lo reconozco, lo abrazo y lo transformo. Me digo: la separación no me destruyó, me transformó. El fin de la relación no es el fin de mi vida; es el inicio de un nuevo ciclo. Acepto que la ruptura fue necesaria para que ambos crezcamos. Hoy perdono al dolor por haberme consumido y le agradezco porque también me despertó. Ya no temo a la soledad; ahora camino con libertad.",
                duration: "6 min",
                voiceAnchors: ["la separación me transformó", "acepto la ruptura", "elijo libertad"],
                affirmations: ["Acepto el cambio", "Camino con libertad"]
            ),
            
            LiberationLetter(
                day: 10,
                phase: .exPartnerHealing,
                title: "Carta a las discusiones",
                content: "Hoy escribo a todas las discusiones que viví en esa relación. A los gritos, a las palabras que hirieron, al silencio que también lastimó. Reviví esas peleas demasiadas veces en mi mente, como si necesitara volver a sufrirlas. Hoy decido detener ese ciclo. Ya no peleo con fantasmas del pasado. Reconozco que esas discusiones nacieron del dolor, del miedo y de la falta de comprensión. Perdono esas escenas, las suelto y corto la energía que me mantenía atrapado en ellas. Hoy elijo la paz sobre la repetición. Hoy dejo de discutir dentro de mí.",
                duration: "5 min",
                voiceAnchors: ["detengo el ciclo", "elijo la paz", "dejo de discutir por dentro"],
                affirmations: ["Silencio interior", "Paz sostenida"]
            ),
            
            LiberationLetter(
                day: 11,
                phase: .exPartnerHealing,
                title: "Carta a la traición (real o sentida)",
                content: "Hoy hablo con la herida más profunda: la traición, real o percibida. Sentí engaño, abandono, deslealtad. Sentí que me arrancaron confianza. Hoy miro ese dolor de frente y le digo: ya no eres mi dueño. No voy a vivir cargando odio ni venganza. Elijo cortar la cadena que me une a la traición. No significa que lo apruebo ni lo olvido; significa que me libero de su control. Te perdono, no porque lo merezcas, sino porque yo merezco paz. Hoy cierro esa herida con luz y no permito que sangre más en mi vida.",
                duration: "6 min",
                voiceAnchors: ["ya no eres mi dueño", "corto la cadena", "elijo mi paz"],
                affirmations: ["Me libero del rencor", "Protejo mi paz"]
            ),
            
            LiberationLetter(
                day: 12,
                phase: .exPartnerHealing,
                title: "Carta a la madre de mis hijos",
                content: "Hoy me dirijo a ti, madre de mis hijos. Como pareja ya no estamos y, aunque hubo dolor, reconozco tu lugar sagrado: eres la madre de quienes más amo. Por ellos, elijo respetarte. Por mí, elijo liberarte. No te culpo más; no me culpo más. Te veo no como mi expareja, sino como la madre de nuestros hijos, y desde ese lugar te agradezco. Te libero de mis resentimientos y te deseo paz. El vínculo de pareja terminó, pero el de padres permanece. Hoy perdono y transformo nuestra relación en respeto.",
                duration: "7 min",
                voiceAnchors: ["te honro como madre", "te libero como pareja", "transformo en respeto"],
                affirmations: ["Respeto y cooperación", "Paz por nuestros hijos"]
            ),
            
            LiberationLetter(
                day: 13,
                phase: .exPartnerHealing,
                title: "Carta a mis promesas rotas",
                content: "Hoy escribo a las promesas que hice y no pude cumplir. Promesas de amor eterno, de familia unida, de futuro compartido. Cada vez que recuerdo esas palabras me pesa la culpa. Hoy decido soltar ese peso. Entiendo que no todo lo prometido podía sostenerse. La vida cambió, los caminos se bifurcaron. No por eso dejo de ser valioso ni digno de amor. Me perdono por mis promesas rotas y agradezco la sinceridad de lo que sí di. Hoy elijo prometerme algo nuevo: ser honesto, presente y consciente en mi nueva vida.",
                duration: "6 min",
                voiceAnchors: ["suelto la culpa", "la vida cambió", "me prometo honestidad"],
                affirmations: ["Honestidad conmigo", "Avanzo con verdad"]
            ),
            
            LiberationLetter(
                day: 14,
                phase: .exPartnerHealing,
                title: "Carta al silencio y la distancia",
                content: "Hoy escribo al silencio que quedó entre nosotros. Un silencio que muchas veces me dolió más que las discusiones. La distancia me parecía rechazo, abandono, frialdad. Hoy dejo de temer al silencio. Comprendo que a veces es necesario para sanar, para no herir más, para seguir adelante. Hoy le digo al silencio: ya no eres enemigo; eres espacio para crecer. Acepto que la distancia es parte del cierre. No necesito buscar palabras que ya no existen. Hoy me reconcilio con el silencio y lo transformo en paz. Te perdono y me libero de la necesidad de respuestas.",
                duration: "5 min",
                voiceAnchors: ["el silencio es espacio", "acepto la distancia", "transformo en paz"],
                affirmations: ["Elijo serenidad", "Dejo ir con respeto"]
            )
        ]
    }
    
    // MARK: - Phase 3: Sanar la relación con los hijos (Días 15-18)
    var phase3Letters: [LiberationLetter] {
        [
            LiberationLetter(
                day: 15,
                phase: .childrenHealing,
                title: "Carta a mis hijos",
                content: "Hoy me dirijo a ustedes, mis hijos. Quiero que mis palabras lleguen a su corazón como un abrazo. Ustedes no tienen culpa de lo que pasó entre su madre y yo. Las decisiones adultas no son cargas para los niños. Los amo sin condiciones, más allá del tiempo, la distancia o las circunstancias. Si alguna vez sintieron vacío o tristeza por nuestra separación, hoy les digo: no fue su responsabilidad. Ustedes merecen amor, alegría y confianza. Yo estaré aquí, siempre, aunque no vivamos bajo el mismo techo. Hoy suelto la culpa y abrazo la certeza de que mi amor por ustedes es infinito.",
                duration: "6 min",
                voiceAnchors: ["no tienen culpa", "los amo sin condiciones", "siempre estaré"],
                affirmations: ["Amor presente", "Cuidado incondicional"]
            ),
            
            LiberationLetter(
                day: 16,
                phase: .childrenHealing,
                title: "Carta al padre ausente",
                content: "Hoy me hablo a mí mismo como padre, a esa parte que siente haber estado ausente. Hubo momentos en los que no estuve presente como hubiera querido: trabajo, discusiones, separación… y eso me pesa. Hoy me perdono por esas ausencias. Comprendo que no puedo cambiar el pasado, pero sí elegir el presente. A partir de ahora, estaré de forma plena, consciente y con calidad de amor. No necesito compensar con regalos ni culpas, sino con presencia real. Hoy corto la energía de la ausencia y me comprometo a vivir el ahora con mis hijos con todo mi corazón.",
                duration: "6 min",
                voiceAnchors: ["me perdono por ausencias", "elijo presencia real", "vivo el ahora"],
                affirmations: ["Estoy aquí y ahora", "Presencia con calidad"]
            ),
            
            LiberationLetter(
                day: 17,
                phase: .childrenHealing,
                title: "Carta a la culpa heredada",
                content: "Hoy hablo con la culpa que siento que mis hijos pudieran heredar de nuestra separación. Muchas veces temí que cargaran con nuestro dolor, que pensaran que algo de esto era por ellos. Hoy declaro con fuerza: ¡mis hijos son inocentes! No llevan mis culpas; no cargan mis heridas. Yo soy el adulto, yo asumo mis responsabilidades. A ustedes, hijos, les devuelvo su libertad. Pueden crecer ligeros, sin pesos que no les corresponden. Hoy corto ese lazo de transmisión del dolor. Hoy les digo: ustedes son libres, merecen alegría y un camino propio lleno de luz.",
                duration: "5 min",
                voiceAnchors: ["mis hijos son inocentes", "no llevan mis culpas", "son libres"],
                affirmations: ["Les devuelvo su libertad", "Su camino es ligero"]
            ),
            
            LiberationLetter(
                day: 18,
                phase: .childrenHealing,
                title: "Carta al futuro con mis hijos",
                content: "Hoy escribo al futuro que tendré con mis hijos. Lo imagino lleno de nuevos recuerdos: risas, viajes, aprendizajes, conversaciones profundas. El divorcio no rompe nuestro vínculo; lo transforma. A partir de ahora, mi papel como padre se vuelve aún más consciente. Quiero enseñarles con el ejemplo que las crisis no destruyen, sino que pueden fortalecernos. Hoy proyecto un futuro donde nuestro amor se hace más grande y más resiliente. Les digo: confíen, porque siempre estaré, porque nuestro lazo es indestructible. Hoy perdono el pasado y abrazo el futuro luminoso con ustedes.",
                duration: "5 min",
                voiceAnchors: ["nuestro vínculo es indestructible", "confíen", "construiremos nuevos recuerdos"],
                affirmations: ["Futuro luminoso", "Amor resiliente"]
            )
        ]
    }
    
    // MARK: - Phase 4: Sanar el futuro (Días 19-21)
    var phase4Letters: [LiberationLetter] {
        [
            LiberationLetter(
                day: 19,
                phase: .futureHealing,
                title: "Carta al miedo al futuro",
                content: "Hoy me dirijo a ti, miedo. Has estado rondando mi mente desde que todo cambió. Me susurras que no podré reconstruirme, que no seré suficiente, que el futuro será vacío. Hoy te miro de frente y te digo: ya no gobiernas mi vida. El futuro no está escrito y no depende de tu voz; depende de mis acciones y decisiones. Me perdono por haberte escuchado tanto tiempo y por haberme paralizado en tu sombra. Hoy elijo la confianza sobre el miedo. Confío en que tengo la fuerza, la sabiduría y el amor para crear una vida nueva. Hoy corto tu poder y camino hacia adelante con valentía.",
                duration: "5 min",
                voiceAnchors: ["ya no gobiernas mi vida", "elijo la confianza", "camino con valentía"],
                affirmations: ["Confío en mí", "Avanzo con coraje"]
            ),
            
            LiberationLetter(
                day: 20,
                phase: .futureHealing,
                title: "Carta al amor que vendrá",
                content: "Hoy escribo al amor que aún no conozco, pero que sé que merece entrar en mi vida. Durante mucho tiempo pensé que no volvería a amar, que no era digno de una nueva oportunidad. Hoy me perdono por haberme cerrado, por haber creído que mi corazón no podía sanar. Hoy declaro: merezco amar y ser amado. El divorcio no me hizo menos; me hizo más consciente. No buscaré reemplazar, sino construir distinto. Al amor que vendrá le digo: llegarás cuando deba ser y te recibiré con un corazón libre, no con cadenas del pasado. Me abro a lo nuevo con esperanza y gratitud.",
                duration: "5 min",
                voiceAnchors: ["merezco amar y ser amado", "no reemplazo, construyo distinto", "me abro a lo nuevo"],
                affirmations: ["Merezco amor", "Recibo lo nuevo"]
            ),
            
            LiberationLetter(
                day: 21,
                phase: .futureHealing,
                title: "Carta de cierre y liberación total",
                content: "Hoy cierro este camino de 21 días de perdón. Miro atrás y reconozco mi dolor, mis culpas, mis resentimientos… y también reconozco cómo los he ido soltando uno a uno. Hoy escribo la palabra final: LIBERACIÓN. Perdono todo, me perdono todo, libero todo. Hoy no soy prisionero de lo que pasó; soy creador de lo que viene. Mi pasado no me define; me enseña. Mi presente es paz y mi futuro es esperanza. Agradezco a la vida por la oportunidad de sanar y renacer. Hoy declaro: soy un hombre nuevo, libre, digno y en paz.",
                duration: "6 min",
                voiceAnchors: ["perdono todo", "me perdono todo", "soy un hombre nuevo y en paz"],
                affirmations: ["Libertad total", "Renazco hoy"]
            )
        ]
    }
    
    // MARK: - Helper Methods
    func getLetter(for day: Int) -> LiberationLetter? {
        return allLetters.first { $0.day == day }
    }
    
    func getLetters(for phase: LiberationLetterPhase) -> [LiberationLetter] {
        return allLetters.filter { $0.phase == phase }
    }
    
    func getPhase(for day: Int) -> LiberationLetterPhase? {
        return getLetter(for: day)?.phase
    }
}
