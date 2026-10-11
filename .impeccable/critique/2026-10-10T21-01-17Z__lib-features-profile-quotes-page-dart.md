---
target: lib/features/profile/quotes_page.dart
total_score: 21
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 3
target_identity: "file:/Users/brayanortiz/Code/Flutter/epub_reader/lib/features/profile/quotes_page.dart"
target_fingerprint: "sha256:b08a2d881af4dfb4a9eac975b7ddc12328873250931f1a9d41d1cb8f91c68dd1"
target_path: /Users/brayanortiz/Code/Flutter/epub_reader/lib/features/profile/quotes_page.dart
timestamp: 2026-10-10T21-01-17Z
slug: lib-features-profile-quotes-page-dart
---
Method: dual-agent (A: 3d06c3ce-42cf-47ac-a4e7-9e7196cd817d · B: a61da9d4-d564-4e0e-a7a6-5930568681fe)

## Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 2 | La carga no muestra «Citas». El error imprime la excepción. Abrir una cita mueve el lugar del libro sin decirlo. |
| 2 | Match System / Real World | 3 | El español es claro. Faltan el día, el autor y el verbo de la fila. |
| 3 | User Control and Freedom | 2 | Atrás funciona. Una cita no se puede quitar, y el lugar anterior del libro no se recupera. |
| 4 | Consistency and Standards | 2 | Cabecera y filete coinciden con el programa. La fila no usa el listado del log, y Perfil usa `ListTile` y `Divider`. |
| 5 | Error Prevention | 2 | El mismo pasaje se puede guardar dos veces. El icono de imagen comparte la zona de toque del texto. |
| 6 | Recognition Rather Than Recall | 2 | Se ven el pasaje (hasta 4 líneas) y el título. Día, autor y acción hay que recordarlos. |
| 7 | Flexibility and Efficiency | 1 | Un solo camino: lista de más reciente a más antigua, sin grupos ni salto. |
| 8 | Aesthetic and Minimalist Design | 3 | Papel plano y un filete por fila. Tras el título, todas las líneas pesan igual. |
| 9 | Error Recovery | 2 | El fallo de carga nombra el problema y añade `$error`, sin reintentar. |
| 10 | Help and Documentation | 2 | El vacío explica el gesto. En cuanto hay una cita, esa ayuda desaparece y la fila no dice que el texto abre el libro. |
| **Total** | | **21/40** | **Acceptable** |

## Design Specificity Verdict

**LLM assessment.** La pantalla está escrita en los bordes y es intercambiable en la lista. «Citas», el filete, el vacío en Barlow Condensed a 36 y el papel del programa son de Liora. La fila no lo es: pasaje en cuerpo, cortado a cuatro líneas, título del libro en muted y `Icons.image_outlined`. `ReadingQuote` ya trae `savedAt`, `author` y `highlightColor`. Ninguno se muestra. No hay columna de hora, título Barlow, banda en antena ni azul de estación en una lista con citas. Una app de notas vecina podría usar esa fila tal cual.

El trabajo del producto sí está en el cable. El toque del pasaje abre `/read/{bookId}?origen=quote&cita={id}` y el icono abre la imagen. Ninguna de las dos acciones tiene nombre en la fila. «Crear imagen» vive en un tooltip, que en el teléfono es una pulsación larga.

**Deterministic scan.** `impeccable detect` sobre `lib/features/profile/quotes_page.dart` salió con código 0 y `[]`. Cero hallazgos por regla. El detector y la revisión coinciden en que la página no rompe las prohibiciones visuales del log (sin tarjetas, sin sombras, esquinas rectas, un solo azul). El detector no vio ninguno de los problemas de interacción: lugar del libro, borrado, agrupación, icono sin etiqueta, error con excepción. Un array vacío aquí no es un visto bueno de UX. No hay falsos positivos que descartar.

**Visual overlays.** No hay overlay visible. La superficie es un widget Flutter, sin documento HTML donde inyectar `detect.js`. No se abrió pestaña ni servidor.

## Overall Impression

La lista está en calma y el vacío está bien escrito. El problema de fondo es que la pantalla trata una cita como un apunte, y para esta lectora es un lugar al que quiere volver sin perder la lectura de hoy. Con tres citas se reconoce la frase. Con cuarenta es un pliego sin fechas. La carga cognitiva de la lista es alta en estructura y memoria (4 fallos del checklist: sin grupos, sin jerarquía una vez que el título se va, día y lugar del libro fuera de la página, pasaje cortado sin expansión), aunque las acciones visibles de esta pantalla son solo tres.

## What's Working

- El vacío usa el título de programa: Barlow Condensed 36, tinta, luego el cuerpo en muted, bajo la cabecera y el filete. «Selecciona un pasaje en la lectura y guárdalo» es una instrucción real en los dos idiomas.
- El toque del pasaje abre el libro en esa cita y deja el resaltado activo. El orden es de más reciente a más antigua, que coincide con «la línea que acabo de guardar».
- La página sigue en el papel. Está fuera de la barra de pestañas, `SafeArea` cierra bien, Atrás es la salida, y el botón semántico lee el pasaje completo y el título aunque la elipsis los corte. Los resaltados ámbar, verde, rosa y violeta del lector se quedan fuera de este papel.

## Priority Issues

### [P1] Releer y mover el lugar del libro son el mismo toque

**Why it matters:** `_locatorForOpening` abre el lector en el localizador de la cita. `_onLocator` persiste ese localizador unos 400 ms después, en `saveProgress`. Una frase guardada al principio, abierta cuando ya se ha leído más, pasa a ser el lugar de la biblioteca. El lugar de hoy es el hábito.

**Fix:** El pasaje completo se lee en el papel: quitar el tope de cuatro líneas, o expandir la fila en el mismo cuerpo entre los mismos filetes. El toque que solo relee deja el localizador del libro quieto. «Leer» va en palabras, en la columna final del listado, o como control de estación a ancho completo en la cita más reciente. Ese control es el que empuja `quoteReadingRoute`.

**Suggested command:** /impeccable shape

### [P1] Con muchas citas no hay forma de encontrar una

**Why it matters:** `savedAt` y `author` están en el modelo y no en la fila. El orden es reciente primero y no hay una fecha que lo demuestre. El mismo libro queda repartido. Un campo de búsqueda inventaría un control que el log no tiene.

**Fix:** Agrupar bajo el libro. El título del libro es un título de listado en Barlow a 22, dos líneas, y el autor en cuerpo muted. Debajo, cada pasaje en cuerpo, con el día guardado en la columna tabular de 64 px que los listados ya usan. El grupo más reciente puede ser la banda en antena: campo de estación, libro en tipo de programa, pasaje en `onStation`, «Leer» invertido. Los grupos anteriores se quedan en el papel.

**Suggested command:** /impeccable layout

### [P1] Una cita guardada no se puede quitar

**Why it matters:** Las filas de la biblioteca dicen Eliminar. Esta fila no. La única salida es borrar el libro, que arrastra las citas. «Cita guardada» no se puede deshacer. `saveQuote` siempre inserta, así que el mismo pasaje puede salir dos veces.

**Fix:** «Eliminar» al final, en muted, el mismo botón de texto que un listado de libro, confirmado con el diálogo de la plataforma. No insertar de nuevo si ese libro y ese pasaje ya están, y mostrar la fila que ya existe.

**Suggested command:** /impeccable harden

### [P2] Crear imagen es un icono sin nombre

**Why it matters:** `Icons.image_outlined` es el único verbo de la fila y su nombre es un tooltip. En el teléfono queda junto al texto, arriba de la fila, y el pulgar lo confunde con abrir la cita.

**Fix:** Las palabras «Crear imagen», en la cara de la plataforma, muted, en la columna final, el mismo patrón que Eliminar.

**Suggested command:** /impeccable clarify

### [P2] El vacío y la fila de Perfil no devuelven a un libro

**Why it matters:** El vacío explica un gesto que ocurre en otra pantalla y no nombra «Guardar cita». No hay un control. En Perfil, «Citas» va sola: sin recuento, sin la última línea, con un `Divider` donde el resto del log usa un filete.

**Fix:** Bajo la frase vacía, un botón de estación a ancho completo hacia Biblioteca, y una frase que nombre el control: «Selecciona un pasaje y pulsa Guardar cita.» En Perfil, el recuento en muted, como los minutos del hábito, y un filete en lugar del divisor.

**Suggested command:** /impeccable onboard

## Persona Red Flags

**Alex (muchas citas, quiere una ya).** Cuarenta extractos iguales, cuatro líneas, sin día, sin autor, sin encabezado de libro. El icono de imagen rompe el barrido en cada fila. No hay salto, ni forma de quitar duplicados o citas que ya no quiere.

**Jordan (nada guardado, o la primera cita).** Perfil no dice si Citas está vacío. La página vacía no nombra «Guardar cita». Tras guardar, el lector solo dice «Cita guardada», sin camino hasta aquí. La línea nueva no dice «ahora». Si la lista falla, aparece el texto de la excepción.

**Casey (una mano, interrumpida).** Atrás es una flecha de 48 px arriba. El botón de imagen se alinea al tope de la fila, junto a la primera línea. La lista sobrevive a una interrupción porque es un stream. El lugar del libro puede no sobrevivir: si abrió una cita y el teléfono la sacó, ese localizador ya se escribió.

**Elena (lee en español y guarda una línea para volver al libro).** Perfil muestra la meta en minutos y «Citas» como una fila en blanco, así que la línea no se ve junto al hábito. La página habla claro y aun así no tiene día ni «Leer». Al tocar la frase llega al resaltado, y ese toque es también el nuevo lugar del libro. Si solo quería oír la línea y seguir con las páginas de esta noche, el lugar de esta noche ya no está. Biblioteca muestra la fecha de hoy bajo su cabecera. Citas no.

## Minor Observations

- Carga y error se saltan `ScheduleHeader`. Solo queda la flecha.
- La flecha y el título no comparten el margen de 20 px.
- La cabecera es el primer ítem de la lista, así que un scroll largo deja la pantalla sin título.
- Las filas no tienen `ValueKey` con el id de la cita.
- Un título vacío pasa a «Sin título», que es el respaldo correcto.
- La cita usa 16 px de padding vertical. El listado usa 8 px y 20 px a los dos lados.
- El estado «Esta cita ya no está» de la imagen dice las palabras justas y no tiene cabecera.
- La copia en inglés ya está en `app_en.arb` y sigue el idioma del dispositivo.

## Questions to Consider

- Si la cita más reciente fuera la banda en antena, con la hora, el libro en Barlow y Leer como control invertido, ¿el resto de las líneas se leería como el programa del día?
- ¿Una línea que solo se quiere volver a oír puede ser una visita que deje el lugar de hoy donde está?
- La foto es lo que se comparte. ¿Qué cambia si la frase completa tiene que leerse en el papel antes de abrir ese estudio?
