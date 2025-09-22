//
//  ForgivenessLetters.swift
//  JustDad - 21 Days of Forgiveness Letters
//
//  Cartas del perdón pránico para la terapia de 21 días
//

import Foundation

struct ForgivenessLetters {
    
    // MARK: - FASE 1: Sanar conmigo mismo (Días 1-7)
    
    static let day1 = ForgivenessLetter(
        day: 1,
        phase: .selfForgiveness,
        title: "Carta al Yo del Pasado",
        content: """
        Hoy me dirijo a mi propio pasado. A ese hombre que tomó decisiones, algunas sabias y otras equivocadas. Reconozco que actué con lo que sabía y con lo que tenía en ese momento. Me equivoqué, sí, pero también aprendí. Ya no castigo a ese hombre que fui, porque fue él quien me trajo hasta aquí, más consciente y más fuerte. Hoy decido mirarme con compasión. Perdono mis errores y me abrazo como un hermano que entiende. Ya no vivo en la condena del ayer, elijo abrirme a la libertad del presente. Yo soy digno de paz, de amor y de un futuro mejor. Me libero y me perdono.
        """,
        affirmation: "Soy digno de paz, amor y un futuro mejor",
        visualizationText: "Visualiza a tu yo del pasado recibiendo un abrazo de compasión y liberación"
    )
    
    static let day2 = ForgivenessLetter(
        day: 2,
        phase: .selfForgiveness,
        title: "Carta a mis decisiones equivocadas",
        content: """
        Hoy hablo con mis decisiones pasadas, aquellas que cargué como piedras en mi espalda. Decisiones que creí firmes y que luego se derrumbaron, decisiones que lastimaron y que también me hirieron. Las miro de frente sin miedo, y les digo: gracias por enseñarme. Ya no me definen, ya no me aprisionan. Hoy las transformo en lecciones y las suelto. Me perdono por haber elegido desde la ignorancia o el dolor. Y me doy permiso para decidir distinto de ahora en adelante. Hoy reclamo mi poder de elección con sabiduría, claridad y amor propio.
        """,
        affirmation: "Transformo mis errores en lecciones de sabiduría",
        visualizationText: "Ve tus decisiones pasadas transformándose en luz dorada que te fortalece"
    )
    
    static let day3 = ForgivenessLetter(
        day: 3,
        phase: .selfForgiveness,
        title: "Carta al hombre que falló como pareja",
        content: """
        Hoy hablo con la parte de mí que siente que falló como compañero de vida. Reconozco que no siempre supe amar bien, que mis palabras, mis silencios o mis actos no siempre fueron los mejores. Hoy dejo de culparme eternamente. No fui perfecto, pero fui humano. Reconozco que di lo que pude, con mis límites y heridas. Hoy me perdono, porque no merezco vivir en la cárcel de la culpa. Aprendí, crecí y hoy soy más consciente. Le digo a mi yo de aquella relación: te perdono, te libero y te abrazo con compasión.
        """,
        affirmation: "Fui humano en mis errores, ahora soy consciente en mi amor",
        visualizationText: "Imagina liberando la culpa de pareja y abriendo tu corazón al amor consciente"
    )
    
    static let day4 = ForgivenessLetter(
        day: 4,
        phase: .selfForgiveness,
        title: "Carta al padre que cree que no dio suficiente",
        content: """
        Hoy me hablo como padre. Sé que muchas veces he sentido que no di lo suficiente a mis hijos, que la separación me robó tiempo y presencia. Hoy me libero de esa culpa. Reconozco que hice lo mejor que pude y que sigo haciéndolo. Mis hijos no necesitan perfección, necesitan amor verdadero y eso siempre lo tuvieron de mí. Me perdono por mis ausencias y me comprometo a estar más presente ahora, con más calidad, con más consciencia. Hoy suelto el peso de la culpa paterna y abrazo el poder de un amor que no se rompe con el divorcio. Soy un buen padre y seguiré siéndolo.
        """,
        affirmation: "Soy un buen padre, mi amor por mis hijos es infinito e inquebrantable",
        visualizationText: "Ve tu amor paternal expandiéndose y envolviendo a tus hijos con luz protectora"
    )
    
    static let day5 = ForgivenessLetter(
        day: 5,
        phase: .selfForgiveness,
        title: "Carta a mi vergüenza",
        content: """
        Hoy escribo a mi vergüenza, a esa voz que me dice que soy un fracaso porque mi matrimonio terminó. Hoy le digo: ya no tienes poder sobre mí. El divorcio no me define, me transforma. Soy más que un estado civil, soy un hombre que elige levantarse. Perdonarme es liberarme de la mirada ajena y de mis propios juicios. Hoy camino erguido, sin vergüenza, sin etiquetas. Soy un hombre digno, completo y en evolución. Hoy suelto la vergüenza y abrazo mi nueva vida con fuerza y orgullo.
        """,
        affirmation: "Soy un hombre digno, completo y en evolución constante",
        visualizationText: "Visualiza tu vergüenza disolviéndose y siendo reemplazada por orgullo y dignidad"
    )
    
    static let day6 = ForgivenessLetter(
        day: 6,
        phase: .selfForgiveness,
        title: "Carta a mi cuerpo y energía",
        content: """
        Hoy me hablo a mí mismo, a mi cuerpo y a mi energía. Sé que en medio del dolor me descuidé: no dormí bien, no me alimenté bien, no cuidé mi mente ni mi salud. Hoy pido perdón a mi cuerpo por el abandono, por el cansancio acumulado, por haberlo cargado con tanto dolor. Hoy me reconcilio con él y le prometo atención, cuidado y fuerza. Mi cuerpo es mi templo y mi energía mi motor. A partir de ahora me trato con respeto, con cariño y con disciplina. Me perdono por haberme descuidado y me comprometo a honrarme cada día.
        """,
        affirmation: "Mi cuerpo es mi templo, lo honro y cuido con amor y respeto",
        visualizationText: "Imagina tu cuerpo llenándose de energía dorada y vitalidad renovada"
    )
    
    static let day7 = ForgivenessLetter(
        day: 7,
        phase: .selfForgiveness,
        title: "Carta de reconciliación conmigo mismo",
        content: """
        Hoy cierro la primera etapa de este camino perdonándome por completo. Reconozco mis sombras y mis luces, mis errores y mis aciertos. No necesito seguir peleando conmigo, porque la batalla interna me roba vida. Hoy me uno conmigo mismo y me abrazo como el hombre que soy: imperfecto, pero valioso; herido, pero resiliente; caído, pero de pie. Me perdono en totalidad y me libero del peso que me mantenía atado al dolor. A partir de hoy, camino conmigo como aliado y no como enemigo. Soy mi propia paz.
        """,
        affirmation: "Soy mi propia paz, camino conmigo como aliado",
        visualizationText: "Ve tu yo interior abrazándose y fusionándose en una luz de paz total"
    )
    
    // MARK: - FASE 2: Sanar la relación con la ex-pareja (Días 8-14)
    
    static let day8 = ForgivenessLetter(
        day: 8,
        phase: .partnerForgiveness,
        title: "Carta a mis expectativas rotas",
        content: """
        Hoy escribo a las expectativas que tuve sobre mi matrimonio. Creí que sería eterno, que nada podría quebrarlo, que el amor bastaría para todo. Esas ilusiones se rompieron y me dejaron con dolor y frustración. Hoy miro esas expectativas y las suelto. Comprendo que no eran la realidad, sino un sueño que se desvaneció. Ya no vivo aferrado a lo que creí que debía ser, elijo aceptar lo que fue. Agradezco lo vivido, lo aprendido y lo que hoy me permite crecer. Suelto la rigidez del ideal y abrazo la flexibilidad de la vida. Perdono mis expectativas rotas y me libero de ellas.
        """,
        affirmation: "Acepto la realidad con flexibilidad y gratitud",
        visualizationText: "Ve tus expectativas rotas transformándose en semillas de sabiduría"
    )
    
    static let day9 = ForgivenessLetter(
        day: 9,
        phase: .partnerForgiveness,
        title: "Carta al dolor de la separación",
        content: """
        Hoy hablo con el dolor profundo de la separación. Dolor que quemó mi pecho, que me hizo sentir vacío, que me arrancó noches de paz. Hoy no lo niego, lo reconozco, lo abrazo y lo transformo. Me digo: la separación no me destruyó, me transformó. El fin de la relación no es el fin de mi vida, es el inicio de un nuevo ciclo. Acepto que la ruptura fue necesaria para que ambos crezcamos. Hoy perdono al dolor por haberme consumido y le agradezco porque también me despertó. Ya no temo a la soledad, ahora camino con libertad.
        """,
        affirmation: "La separación me transformó, no me destruyó",
        visualizationText: "Imagina el dolor transformándose en alas que te elevan hacia la libertad"
    )
    
    static let day10 = ForgivenessLetter(
        day: 10,
        phase: .partnerForgiveness,
        title: "Carta a las discusiones",
        content: """
        Hoy escribo a todas las discusiones que viví en esa relación. A los gritos, a las palabras que hirieron, al silencio que también lastimó. Reviví esas peleas demasiadas veces en mi mente, como si necesitara volver a sufrirlas. Hoy decido detener ese ciclo. Ya no peleo con fantasmas del pasado. Reconozco que esas discusiones nacieron del dolor, del miedo y de la falta de comprensión. Perdono esas escenas, las suelto y corto la energía que me mantenía atrapado en ellas. Hoy elijo la paz sobre la repetición. Hoy dejo de discutir dentro de mí.
        """,
        affirmation: "Elijo la paz sobre la repetición del conflicto",
        visualizationText: "Ve las discusiones disolviéndose en el aire como humo que se lleva el viento"
    )
    
    static let day11 = ForgivenessLetter(
        day: 11,
        phase: .partnerForgiveness,
        title: "Carta a la traición (real o sentida)",
        content: """
        Hoy hablo con la herida más profunda: la traición, real o percibida. Sentí engaño, abandono, deslealtad. Sentí que me arrancaron confianza. Hoy miro ese dolor de frente y le digo: ya no eres mi dueño. No voy a vivir cargando odio ni venganza. Elijo cortar la cadena que me une a la traición. No significa que lo apruebo ni lo olvido, significa que me libero de su control. Te perdono, no porque lo merezcas, sino porque yo merezco paz. Hoy cierro esa herida con luz y no permito que sangre más en mi vida.
        """,
        affirmation: "Me libero de la traición para encontrar mi propia paz",
        visualizationText: "Visualiza cerrando la herida de la traición con luz dorada sanadora"
    )
    
    static let day12 = ForgivenessLetter(
        day: 12,
        phase: .partnerForgiveness,
        title: "Carta a la madre de mis hijos",
        content: """
        Hoy me dirijo a ti, madre de mis hijos. Como pareja ya no estamos, y aunque hubo dolor, reconozco tu lugar sagrado: eres la madre de quienes más amo. Por ellos, elijo respetarte. Por mí, elijo liberarte. No te culpo más, no me culpo más. Te veo no como mi expareja, sino como la madre de nuestros hijos, y desde ese lugar te agradezco. Te libero de mis resentimientos y te deseo paz. El vínculo de pareja terminó, pero el de padres permanece. Hoy perdono y transformo nuestra relación en respeto.
        """,
        affirmation: "Transformo nuestro vínculo de pareja en respeto como padres",
        visualizationText: "Ve el vínculo de pareja transformándose en un puente de respeto hacia los hijos"
    )
    
    static let day13 = ForgivenessLetter(
        day: 13,
        phase: .partnerForgiveness,
        title: "Carta a mis promesas rotas",
        content: """
        Hoy escribo a las promesas que hice y no pude cumplir. Promesas de amor eterno, de familia unida, de futuro compartido. Cada vez que recuerdo esas palabras me pesa la culpa. Hoy decido soltar ese peso. Entiendo que no todo lo prometido podía sostenerse. La vida cambió, los caminos se bifurcaron. No por eso dejo de ser valioso ni digno de amor. Me perdono por mis promesas rotas y agradezco la sinceridad de lo que sí di. Hoy elijo prometerme algo nuevo: ser honesto, presente y consciente en mi nueva vida.
        """,
        affirmation: "Me prometo honestidad, presencia y consciencia en mi nueva vida",
        visualizationText: "Ve tus promesas rotas transformándose en nuevas intenciones de amor consciente"
    )
    
    static let day14 = ForgivenessLetter(
        day: 14,
        phase: .partnerForgiveness,
        title: "Carta al silencio y distancia",
        content: """
        Hoy escribo al silencio que quedó entre nosotros. Un silencio que muchas veces me dolió más que las discusiones. La distancia me parecía rechazo, abandono, frialdad. Hoy dejo de temer al silencio. Comprendo que a veces es necesario para sanar, para no herir más, para seguir adelante. Hoy le digo al silencio: ya no eres enemigo, eres espacio para crecer. Acepto que la distancia es parte del cierre. No necesito buscar palabras que ya no existen. Hoy me reconcilio con el silencio y lo transformo en paz. Te perdono y me libero de la necesidad de respuestas.
        """,
        affirmation: "El silencio es espacio para crecer, no para sufrir",
        visualizationText: "Imagina el silencio como un jardín de paz donde creces y floreces"
    )
    
    // MARK: - FASE 3: Sanar la relación con los hijos (Días 15-18)
    
    static let day15 = ForgivenessLetter(
        day: 15,
        phase: .childrenForgiveness,
        title: "Carta a mis hijos",
        content: """
        Hoy me dirijo a ustedes, mis hijos. Quiero que mis palabras lleguen a su corazón como un abrazo. Ustedes no tienen culpa de lo que pasó entre su madre y yo. Las decisiones adultas no son cargas para los niños. Los amo sin condiciones, más allá del tiempo, la distancia o las circunstancias. Si alguna vez sintieron vacío o tristeza por nuestra separación, hoy les digo: no fue su responsabilidad. Ustedes merecen amor, alegría y confianza. Yo estaré aquí, siempre, aunque no vivamos bajo el mismo techo. Hoy suelto la culpa y abrazo la certeza de que mi amor por ustedes es infinito.
        """,
        affirmation: "Mi amor por mis hijos es infinito e incondicional",
        visualizationText: "Ve tu amor paternal expandiéndose como un campo de luz que protege a tus hijos"
    )
    
    static let day16 = ForgivenessLetter(
        day: 16,
        phase: .childrenForgiveness,
        title: "Carta al padre ausente",
        content: """
        Hoy me hablo a mí mismo como padre, a esa parte que siente haber estado ausente. Hubo momentos en los que no estuve presente como hubiera querido: trabajo, discusiones, separación… y eso me pesa. Hoy me perdono por esas ausencias. Comprendo que no puedo cambiar el pasado, pero sí elegir el presente. A partir de ahora, estaré de forma plena, consciente y con calidad de amor. No necesito compensar con regalos ni culpas, sino con presencia real. Hoy corto la energía de la ausencia y me comprometo a vivir el ahora con mis hijos con todo mi corazón.
        """,
        affirmation: "Estoy presente con mis hijos de forma plena y consciente",
        visualizationText: "Imagina tu presencia paternal como una luz cálida que envuelve a tus hijos"
    )
    
    static let day17 = ForgivenessLetter(
        day: 17,
        phase: .childrenForgiveness,
        title: "Carta a la culpa heredada",
        content: """
        Hoy hablo con la culpa que siento que mis hijos pudieran heredar de nuestra separación. Muchas veces temí que cargaran con nuestro dolor, que pensaran que algo de esto era por ellos. Hoy declaro con fuerza: ¡mis hijos son inocentes! No llevan mis culpas, no cargan mis heridas. Yo soy el adulto, yo asumo mis responsabilidades. A ustedes, hijos, les devuelvo su libertad. Pueden crecer ligeros, sin pesos que no les corresponden. Hoy corto ese lazo de transmisión del dolor. Hoy les digo: ustedes son libres, merecen alegría y un camino propio lleno de luz.
        """,
        affirmation: "Mis hijos son libres e inocentes, merecen crecer en luz",
        visualizationText: "Ve cortando los hilos invisibles de culpa que pudieran unirte a tus hijos"
    )
    
    static let day18 = ForgivenessLetter(
        day: 18,
        phase: .childrenForgiveness,
        title: "Carta al futuro con mis hijos",
        content: """
        Hoy escribo al futuro que tendré con mis hijos. Lo imagino lleno de nuevos recuerdos: risas, viajes, aprendizajes, conversaciones profundas. El divorcio no rompe nuestro vínculo, lo transforma. A partir de ahora, mi papel como padre se vuelve aún más consciente. Quiero enseñarles con el ejemplo que las crisis no destruyen, sino que pueden fortalecernos. Hoy proyecto un futuro donde nuestro amor se hace más grande y más resiliente. Les digo: confíen, porque siempre estaré, porque nuestro lazo es indestructible. Hoy perdono el pasado y abrazo el futuro luminoso con ustedes.
        """,
        affirmation: "Nuestro vínculo padre-hijos es indestructible y se fortalece con el tiempo",
        visualizationText: "Ve el futuro con tus hijos lleno de luz, amor y nuevos recuerdos hermosos"
    )
    
    // MARK: - FASE 4: Sanar el futuro (Días 19-21)
    
    static let day19 = ForgivenessLetter(
        day: 19,
        phase: .futureForgiveness,
        title: "Carta al miedo al futuro",
        content: """
        Hoy me dirijo a ti, miedo. Has estado rondando mi mente desde que todo cambió. Me susurras que no podré reconstruirme, que no seré suficiente, que el futuro será vacío. Hoy te miro de frente y te digo: ya no gobiernas mi vida. El futuro no está escrito y no depende de tu voz, depende de mis acciones y decisiones. Me perdono por haberte escuchado tanto tiempo y por haberme paralizado en tu sombra. Hoy elijo la confianza sobre el miedo. Confío en que tengo la fuerza, la sabiduría y el amor para crear una vida nueva. Hoy corto tu poder y camino hacia adelante con valentía.
        """,
        affirmation: "Elijo la confianza sobre el miedo, tengo fuerza para crear una vida nueva",
        visualizationText: "Ve tu miedo disolviéndose y siendo reemplazado por confianza y determinación"
    )
    
    static let day20 = ForgivenessLetter(
        day: 20,
        phase: .futureForgiveness,
        title: "Carta al amor que vendrá",
        content: """
        Hoy escribo al amor que aún no conozco, pero que sé que merece entrar en mi vida. Durante mucho tiempo pensé que no volvería a amar, que no era digno de una nueva oportunidad. Hoy me perdono por haberme cerrado, por haber creído que mi corazón no podía sanar. Hoy declaro: merezco amar y ser amado. El divorcio no me hizo menos, me hizo más consciente. No buscaré reemplazar, sino construir distinto. Al amor que vendrá le digo: llegarás cuando deba ser, y te recibiré con un corazón libre, no con cadenas del pasado. Me abro a lo nuevo con esperanza y gratitud.
        """,
        affirmation: "Merezco amar y ser amado con un corazón libre y consciente",
        visualizationText: "Ve tu corazón abriéndose como una flor para recibir el amor que viene"
    )
    
    static let day21 = ForgivenessLetter(
        day: 21,
        phase: .futureForgiveness,
        title: "Carta de cierre y liberación total",
        content: """
        Hoy cierro este camino de 21 días de perdón. Miro atrás y reconozco mi dolor, mis culpas, mis resentimientos… y también reconozco cómo los he ido soltando uno a uno. Hoy escribo la palabra final: LIBERACIÓN. Perdono todo, me perdono todo, libero todo. Hoy no soy prisionero de lo que pasó, soy creador de lo que viene. Mi pasado no me define, me enseña. Mi presente es paz y mi futuro es esperanza. Agradezco a la vida por la oportunidad de sanar y renacer. Hoy declaro: soy un hombre nuevo, libre, digno y en paz.
        """,
        affirmation: "Soy un hombre nuevo, libre, digno y en paz total",
        visualizationText: "Ve toda tu energía liberándose en una explosión de luz dorada que te envuelve completamente"
    )
    
    // MARK: - All Letters Array
    
    static let allLetters: [ForgivenessLetter] = [
        day1, day2, day3, day4, day5, day6, day7,
        day8, day9, day10, day11, day12, day13, day14,
        day15, day16, day17, day18,
        day19, day20, day21
    ]
    
    static let defaultLetter = ForgivenessLetter(
        day: 1,
        phase: .selfForgiveness,
        title: "Carta de Liberación",
        content: "Hoy me libero de todo lo que me ata al pasado. Perdono, me perdono y abrazo la paz.",
        affirmation: "Soy libre y estoy en paz",
        visualizationText: "Visualiza tu liberación y paz interior"
    )
}
