---
target: división de secciones y cambios de Tiempo
total_score: 24
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 2
p2_count: 1
target_identity: "file:/Users/brayanortiz/Code/Flutter/epub_reader/lib/features/habits/reading_time_page.dart"
target_fingerprint: "sha256:ea912e17c8f3d250fe11f50dcdb5744693c19a6eccc799f287d054c23dee085b"
target_path: /Users/brayanortiz/Code/Flutter/epub_reader/lib/features/habits/reading_time_page.dart
timestamp: 2026-10-16T21-28-48Z
slug: lib-features-habits-reading-time-page-dart
---
Method: dual-agent (A: c146f86c-64d4-4078-8f9d-6ffe438ba367 · B: bad145a7-7f68-47b8-9640-0ad5730a9c8d)

## Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of system status | 2 | Un día de hoy por debajo de la meta usa el mismo azul sólido que un día cumplido. |
| 2 | Match between system and real world | 3 | Los nombres son los del log. El relleno de hoy usa el color de “meta cumplida” para un día en curso. |
| 3 | User control and freedom | 3 | Se puede volver a meses anteriores. No hay vuelta a Hoy, y la semana no se puede deseleccionar. |
| 4 | Consistency and standards | 2 | Semana y mes no comparten la regla, ni el lenguaje de selección, ni el lugar de la lectura del día. |
| 5 | Error prevention | 3 | El mes siguiente se desactiva en el mes actual. Un hoy vacío se ve igual que un día futuro. |
| 6 | Recognition rather than recall | 2 | Sólido, 28 % y papel se distinguen en la celda. En la barra de hoy, el sólido deja de significar meta. |
| 7 | Flexibility and efficiency | 2 | Tocar un día de la semana no mueve el calendario. Volver a hoy exige recorrer los meses. |
| 8 | Aesthetic and minimalist design | 3 | Papel, un azul y la regla se sostienen. La página gasta dos respuestas para la misma pregunta. |
| 9 | Error recovery | 2 | El fallo de carga muestra la excepción y no ofrece reintento. |
| 10 | Help and documentation | 2 | “Todavía no hay registros” no aparece cuando la semana está en cero. |
| **Total** | | **24/40** | **Aceptable** |

## Design specificity

Las marcas son de este log: columnas cuadradas, meta en línea discontinua de tinta, estación al 28 % para el día corto, minutos en Barlow y el libro como listado bajo una regla de 1 px. La estructura de la página es la parte intercambiable. Semana, mes y libro se apilan como un gráfico, una grilla y un ítem, y el corte entre los dos primeros es espacio sobrante.

El detector automático, sobre los cuatro archivos de la pantalla, devolvió 0 hallazgos (salida 0, `[]`). No contradice el juicio: no mira la relación entre bloques. No hay overlay en el navegador: Tiempo es una pantalla Flutter, sin página HTML donde inyectar.

## Overall impression

La división entre semana y mes sí se puede mejorar, y es el hueco más claro de lo que ya está en pantalla. El libro anuncia su sección con una regla. La semana y el mes, que son dos instrumentos distintos, se encuentran en 32 px de papel.

## What's working

- “Esta semana” a la izquierda y “Meta · …” a la derecha, con la meta dibujada en tinta. La cantidad es la columna. El umbral es la línea. El día vacío sigue en papel.
- La marca del día de hoy en el calendario está bien separada del significado de la celda: el relleno sigue diciendo cumplido, parcial o vacío, y la rayita de 10×2 solo dice “aquí”.
- El libro de esta pantalla es una fila: portada, título, autor y una duración. “Todos los libros” sigue siendo el control de texto, y solo aparece cuando hay más de uno.

## Priority issues

### [P1] Semana y mes no forman dos secciones

**Why it matters.** Entre la lectura de la semana y el nombre del mes hay 32 px de papel y ninguna regla: 12 px del gráfico, 12 px del hueco y 8 px del calendario. Encima de “Tiempo”, encima del libro y encima de “Todos los libros” el corte es una regla de 1 px. El mes, además, tiene título propio y sus propios controles. Sin la regla, semana y mes se leen como un solo bloque, y el libro como el único registro aparte. Si no hay libros, el mes ni siquiera recibe un cierre.

La proximidad agrupa lo que está cerca y separa lo que tiene aire. Aquí el aire es mayor entre semana y mes (32 px) que entre mes y libro (unos 16 px más una regla). El espacio dice una cosa y la regla dice otra.

**Fix.** Sustituir el hueco de 12 px por la misma `ScheduleRule` del resto del log. Dejar 12 px de papel a cada lado de esa regla.

**Suggested command.** /impeccable layout

### [P1] Hoy y un día cumplido son la misma barra

**Why it matters.** En la semana, hoy se pinta sólido en cuanto hay lectura, aunque no haya llegado a la meta. El 28 % queda reservado a los otros días. Quien abre Tiempo para ver si hoy ya pasó la línea ve una columna igual a la de un día cumplido. La línea discontinua sigue siendo el umbral, pero el color, que se lee antes que la altura, dice que ya está hecho. En el calendario ese conflicto no existe: hoy es la rayita, y el relleno guarda el estado.

Además, el rótulo de hoy y el del día tocado usan el mismo azul y el mismo peso 700. Tras tocar otro día hay dos rótulos iguales, y la barra no cambia.

**Fix.** Sólido significa meta cumplida, también hoy. Hoy por debajo de la meta se queda al 28 %. Hoy vacío se queda en papel. Hoy se marca como en el calendario: peso 700 y una rayita de 10×2 bajo la etiqueta del día. El día seleccionado conserva el rótulo en estación.

**Suggested command.** /impeccable layout

### [P2] La misma pregunta tiene dos respuestas

**Why it matters.** La semana responde debajo de las barras, en Barlow: el día en tinta y los minutos en estación. El mes responde entre el título y la grilla, en una sola frase del sistema, y la celda tocada crece un borde de 2 px. Las dos respuestas pueden estar visibles a la vez, cada una con un día distinto. El borde de 2 px además aprieta la rayita de hoy, que vive a 3 px del borde inferior de una celda de 32 px.

**Fix.** La lectura del día, en las dos partes, va debajo del instrumento y con la misma línea: nombre en tinta, minutos en estación. El borde de selección del calendario baja a 1 px, que es el trazo del log. Una sola selección manda: tocar un día de la semana que cae en el mes visible actualiza también el calendario.

**Suggested command.** /impeccable typeset

## Persona red flags

**Quien abre el teléfono para ver si hoy ya leyó.** El lugar es el correcto, arriba. El color no lo es: 4 minutos hoy se ven como un día cumplido hasta que se mide la columna contra una línea de 1,5 px. Si hoy aún no hay lectura, la columna es papel, igual que el sábado que no ha llegado, y solo el rótulo en negrita lo distingue. Para seguir con el libro hay que pasar el mes entero.

**Quien entra por primera vez.** Una semana en cero es un plot vacío y un mes de cuadrados, sin la frase que ya existe: “El tiempo se guarda cuando una lectura pasa de 30 segundos.” Tocar una barra cambia la cifra y no la barra, así que el toque parece no haber caído. El calendario enseña otra regla: un borde de 2 px y una frase distinta.

## Minor observations

- La rayita de hoy mide 10×2 px. En un día cumplido, clara sobre azul, se confunde con el borde. El peso 700 sigue haciendo casi todo el trabajo de ubicar el día.
- “Viernes” está en Barlow. En este log las fechas viven en la fuente del sistema. La cifra de minutos es la pieza de programa.
- La duración del libro está en tinta, y así debe seguir: en un listado el texto de cierre es tinta. El azul de los minutos de la semana es la lectura en vivo, no el total del libro.
- El fallo de carga enseña la excepción cruda. La semana vacía no usa “Todavía no hay registros”.
- La línea de la meta usa extremos redondos. El log es de cortes rectos.

## Questions to consider

- Si el sólido significa solo “meta cumplida”, ¿qué le queda a hoy además de la rayita que el calendario ya usa?
- Si semana y mes son dos registros del mismo hábito, ¿la próxima regla de la página es la del libro?
