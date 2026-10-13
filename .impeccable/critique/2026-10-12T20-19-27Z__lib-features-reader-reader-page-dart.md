---
target: indice del lector
total_score: 20
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 3
target_identity: "file:/Users/brayanortiz/Code/Flutter/epub_reader/lib/features/reader/reader_page.dart"
target_fingerprint: "sha256:ec48d84ede2de5f047933a5f914dbf2c2d396aa85b1af88832b2c4da686d707a"
target_path: /Users/brayanortiz/Code/Flutter/epub_reader/lib/features/reader/reader_page.dart
timestamp: 2026-10-12T20-19-27Z
slug: lib-features-reader-reader-page-dart
---
Method: dual-agent (A: f4d893e6-c5df-4a10-ac10-05e0006bbb1d · B: feb0e046-fcbf-482a-ade1-999a49c69978)

# Índice del lector

Superficie: diálogo de índice en `lib/features/reader/reader_page.dart` (`_ContentsDialog`, líneas 852–891), abierto desde la barra del lector.

## Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 2 | La lista no marca el capítulo actual y el salto no tiene estado de espera. |
| 2 | Match System / Real World | 3 | «Índice» y el orden del libro son correctos; el contenedor es una alerta centrada. |
| 3 | User Control and Freedom | 3 | Se puede salir tocando fuera, con «Cerrar» o con el gesto de volver. El salto no se deshace. |
| 4 | Consistency and Standards | 2 | Usa el mismo `AlertDialog` que un aviso de borrar, y se aparta del listado del programa y de una hoja de teléfono. |
| 5 | Error Prevention | 2 | Filas «Sin título» y enlaces muertos siguen siendo tocables. |
| 6 | Recognition Rather Than Recall | 1 | No hay fila actual, ni búsqueda, y la entrada es un icono con tooltip. |
| 7 | Flexibility and Efficiency | 1 | Un solo camino: abrir, recorrer desde el principio, tocar. |
| 8 | Aesthetic and Minimalist Design | 2 | Está vacío de ruido y todas las filas pesan igual. El papel, el filete y el azul estación no llegan. |
| 9 | Error Recovery | 2 | «No se pudo abrir este capítulo.» es claro y no dice cuál ni qué hacer después. |
| 10 | Help and Documentation | 2 | El tooltip dice Índice. Una lista larga o sin títulos no tiene otra ayuda. |
| **Total** | | **20/40** | **Acceptable** |

Carga cognitiva: 6 de 8 comprobaciones fallan (alta). Pasan el foco único y el hacer una cosa a la vez. Fallan el troceo, la agrupación, la jerarquía visual, el límite de opciones, la memoria de trabajo y la revelación progresiva. El índice aplana el árbol (`_contentsOf`, líneas 836–849) y muestra cada capítulo como una fila igual. La decisión visible es el libro entero.

## Design Specificity Verdict

**LLM assessment.** El índice es intercambiable. `_ContentsDialog` es un `AlertDialog` de Material con título, `ListTile` por defecto y un `TextButton`. Cualquier lector EPUB podría publicarlo igual. El carácter de Liora se queda en la barra que abre el índice: papel al 95% (`#F2F4F7FB`), pista de 3 px en azul estación. El diálogo no usa el listado del programa (Barlow Condensed, filete de 1 px, relleno de estación cuando la fila está en antena). El azul estación aparece solo en el botón «Cerrar», porque el tema pinta así todos los botones de texto. La misma forma de diálogo sirve para confirmar un borrado (línea 423). El índice es el mapa del libro, y el sistema ya tiene una fila para «esta es la que está en antena». Esa fila no se usa.

**Deterministic scan.** `impeccable detect --json lib/features/reader/reader_page.dart` salió con código 0 y `[]`. Cero hallazgos en el archivo, incluido el diálogo y el botón de índice. El detector no vio lo que la revisión sí ve: ausencia de capítulo actual, contenedor de alerta, jerarquía plana. No hay falsos positivos que descartar. El acuerdo es este: no hay anti-patrones mecánicos de marcado; el problema es de estructura y de tarea.

**Visual overlays.** No hay overlay en el navegador. El índice es un `AlertDialog` nativo de Flutter, sin URL. No se inyectó `detect.js`. El simulador iPhone 17 estaba encendido en la pantalla de inicio; la app no estaba delante y el índice no se veía. El juicio visual sale del widget, no de una captura del diálogo.

## Overall Impression

El índice cumple el mínimo: abre, lista, salta y vuelve al libro. El salto que funciona termina bien, con la barra plegada y la lectura al frente. El hueco grande es de orientación. Abres el mapa de un libro que ya estás leyendo y el mapa no sabe en qué página estás.

La propuesta es una sola pieza, no un rediseño del lector:

El índice pasa a ser una hoja del programa, desde abajo. El párrafo que dejas sigue visible arriba. La fila del capítulo en curso va en azul estación y la hoja abre ya colocada en esa fila. Las partes son rótulos; los capítulos, listados con filete; los hijos permanecen plegados hasta abrir la parte. Si el libro es largo, un buscador aparece arriba del listado. Si el salto falla, la hoja sigue abierta y el mensaje nombra el capítulo. «Atrás» cierra el índice. «Cerrar» sigue siendo salir del libro.

## What's Working

- El español es el de quien lee. «Índice», «Sin título», «Este libro no tiene índice.», «No se pudo abrir este capítulo.» (`lib/l10n/app_es.arb`). No hay jerga del motor.
- Un salto correcto devuelve al libro y esconde la barra (línea 201). Eso coincide con el hábito: leer un poco y seguir.
- Si el libro no trae índice de navegación, se usa el orden de lectura (líneas 837–839). Se puede salir sin elegir: tocar fuera, «Cerrar», o el gesto del sistema.

## Priority Issues

### [P1] El índice no sabe dónde estás

`_latestLocator` se actualiza en cada página (líneas 157–163) y no entra al diálogo. `_ContentsDialog` solo recibe `entries` (líneas 186, 853–855). La lista abre en la primera fila. No hay fila seleccionada, ni relleno de estación, ni desplazamiento hasta el capítulo actual.

**Why it matters.** La tarea es encontrar el capítulo actual o el que buscas y saltar. En un libro largo, el capítulo actual es la referencia. Sin ella, cada visita empieza en la portada.

**Fix.** La fila cuyo `href` coincide con el locator va en antena: relleno de estación y título en `onStation`. Al abrir, esa fila queda bajo el título. El locator viaja con el diálogo.

**Suggested command.** `/impeccable shape`

### [P1] Una alerta centrada es el contenedor equivocado

La lista mide el 60% de la altura (línea 860) y encima van el título y «Cerrar». `AlertDialog` es el patrón de confirmar un borrado. En teléfono, ir a un lugar del libro es una hoja o una lista a altura completa. El botón de índice está arriba a la izquierda (`Icons.format_list_bulleted`, líneas 748–751), lejos del pulgar. La caja fija al 60% no crece con el tamaño de texto.

**Why it matters.** Quien lee va a mitad de capítulo, a menudo con una mano. La lista es toda la tarea, y el contenedor la deja flotando en el centro.

**Fix.** Hoja desde abajo, a la altura que queda bajo una franja del libro. Papel, filetes, esquinas rectas, área segura abajo. Arrastrar o «Atrás» para cerrar (`back` ya existe en el arb, línea 58). La lista ocupa el alto restante. El botón de índice pasa a la zona del pulgar, o muestra la palabra «Índice».

**Suggested command.** `/impeccable adapt`

### [P1] La jerarquía es una sangría, y no hay forma de acotarla

El mismo `ListTile` en cada profundidad. El único mapa es `16 + depth * 16` (líneas 873–876). Sin `maxLines`, sin elipsis, sin rótulo de parte, sin búsqueda, sin progreso por capítulo. Un título largo envuelve sin límite. Una sangría profunda se come el ancho de la línea.

**Why it matters.** Una novela se vuelve un muro de opciones iguales. La sangría deja de leerse en cuanto el título parte en dos líneas.

**Fix.** Las partes son un rótulo en tinta apagada. Los capítulos son listados bajo un filete. Los hijos siguen plegados hasta abrir esa parte. Si la lista es larga, un solo campo de búsqueda arriba filtra por título. Progreso, búsqueda y árbol completo no van juntos en la primera vista.

**Suggested command.** `/impeccable distill`

### [P2] El fallo y el lomo sin títulos abandonan la tarea

El diálogo se cierra antes de saber si el salto funcionó (líneas 188–199). El snackbar no nombra el capítulo y no ofrece acción. «Sin título» es el único recurso (líneas 829–832), así que un lomo sin títulos es muchos botones con el mismo nombre. La frase vacía casi no aparece: solo corre si el índice y el orden de lectura están vacíos.

**Why it matters.** Para reintentar hay que recordar qué fila falló y volver a abrir el índice desde arriba.

**Fix.** La hoja permanece hasta que el salto funciona. Si falla, la fila sigue ahí y el mensaje nombra el título, con «Reintentar». Si un enlace no tiene título, se muestra su puesto («Capítulo 4»). «Sin título» queda para cuando tampoco hay puesto. Si las dos fuentes están vacías, la frase dice que se puede seguir pasando páginas, en una hoja corta.

**Suggested command.** `/impeccable harden`

### [P2] La entrada, la salida y el modo oscuro no coinciden

La entrada es un icono con tooltip «Índice», en una fila de siete iconos iguales (líneas 747–797). «Cerrar» en el diálogo cierra el índice (líneas 884–886). «Cerrar» en la barra sale del libro (líneas 790–794). La misma palabra, dos alcances. La barra está fija en papel claro. En oscuro del sistema, el color del icono sigue el tema y puede quedar claro sobre ese papel. El contraste no se midió en dispositivo.

**Why it matters.** Hay que aprender un icono sin palabra. «Cerrar» puede sentirse como salir del libro. En oscuro, el icono de la barra puede perder contraste.

**Fix.** Iconos de la barra en tinta `#0E1A2B` sobre ese papel claro. «Atrás» cierra el índice. «Cerrar» se reserva para salir del libro.

**Suggested command.** `/impeccable audit`

## Persona Red Flags

Acción principal: encontrar el capítulo actual o el deseado y saltar.

**Alex (lector de libros largos).** Abre el índice a mitad del libro y aterriza en la primera entrada. No hay búsqueda, ni recientes, ni «estás aquí», ni partes plegadas. La barra de progreso no es un deslizador (líneas 728–733), así que esta lista es el único salto. Recorre una sangría plana desde el principio. El rato de lectura se va en el índice.

**Jordan (primera vez).** El icono de lista no tiene palabra hasta que el título de la alerta dice «Índice», y solo después del toque. Un lomo de «Sin título» no enseña nada. «Cerrar» es la misma palabra que la X que sale del libro. La frase vacía no dice que se puede seguir pasando páginas.

**Casey (una mano, con interrupciones).** Mostrar la barra pide un toque al centro. El índice está arriba a la izquierda. Las primeras filas quedan altas y «Cerrar» es el pie del diálogo, no el borde inferior del teléfono. Una interrupción devuelve una lista que sigue en el tope, sin fila actual. El modal tapa la lectura hasta cerrarlo.

**Sam (VoiceOver y texto grande).** El tooltip «Índice» nombra el botón, y cada `ListTile` se anuncia por su título. La profundidad es solo padding, así que parte y capítulo no se distinguen al oírlos. No hay estado seleccionado que anunciar. «Sin título» repetido son varios botones con la misma etiqueta. El texto grande envuelve dentro de un alto fijo del 60%, y la sangría estrecha más la línea.

## Minor Observations

- En inglés el mismo flujo dice «Contents», «Close», «Untitled», «This book has no table of contents.», «This chapter could not be opened.» El español es el idioma de la interfaz que el producto declara.
- `ListView.builder` construye filas bajo demanda. La estructura de lista es la correcta. El muro de opciones sigue ahí.
- El ritmo del `ListTile` por defecto no es el del listado del programa (alto mínimo 48, padding 8×20).
- «Cerrar» repite lo que ya hace tocar fuera. El problema es la palabra, que choca con salir del libro.
- `goToLocator` (línea 195) no muestra espera. Un salto lento parece un toque que no hizo nada, hasta que la página se mueve o llega el snackbar.
- No hubo captura del diálogo abierto, ni un EPUB real, ni VoiceOver, ni una medida de contraste en el simulador.

## Questions to Consider

- Si el índice es un listado del programa, ¿por qué el capítulo que se está leyendo es la única fila que no está en antena?
- ¿Qué pasa con «leer un poco» si la hoja abre ya en el capítulo actual y la frase que dejas sigue visible arriba?
- Cuando el lomo no trae títulos, ¿una columna de «Sin título» dice la verdad, o la dice una frase corta que invita a seguir pasando páginas?
