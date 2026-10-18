---
target: la screen de profile
total_score: 23
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 3
target_identity: "file:/Users/brayanortiz/Code/Flutter/epub_reader/lib/features/profile/profile_page.dart"
target_fingerprint: "sha256:05036be589624da2a2134910e57b8b1595fac27893edc2a25b4e514199c4a6da"
target_path: /Users/brayanortiz/Code/Flutter/epub_reader/lib/features/profile/profile_page.dart
timestamp: 2026-10-18T19-09-38Z
slug: lib-features-profile-profile-page-dart
---
Method: dual-agent (A: 7f578329-9749-41a5-9127-382f3f8cb692 · B: 3dc81e96-816e-4306-b01e-575616805c91)

## Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 3 | El tema y la fuente se marcan al instante, y PQRS pasa de «Enviando» a «Enviada». Guardar el hábito no confirma nada, y el botón final sigue diciendo «Quiero empezar a leer». |
| 2 | Match System / Real World | 3 | Las instrucciones en español son concretas. En el hub, «PQRS» no se explica, y editar el hábito habla con las preguntas del primer día. |
| 3 | User Control and Freedom | 2 | Hay atrás y «Cancelar». Borrar una cita, generar lecturas de ejemplo y guardar el hábito no se pueden deshacer. El asistente cierra con `context.go`, así que no se vuelve con un pop. |
| 4 | Consistency and Standards | 2 | El hub es `ListTile`; Apariencia usa `ScheduleListing`; el asistente usa tarjetas con borde; PQRS usa una grilla reglada. Citas quita la barra de pestañas; las demás pantallas la dejan. |
| 5 | Error Prevention | 3 | Minutos, tipo, correo y longitud están acotados. Borrar y generar piden confirmación. El límite de 2000 caracteres aparece solo después de enviar, y «Eliminar» se ve igual que «Cancelar». |
| 6 | Recognition Rather Than Recall | 2 | Minutos, nombre del tema y número de citas están en la fila. El horario y el nombre del color de las citas no. Hay que abrir PQRS para entender qué es. |
| 7 | Flexibility and Efficiency | 1 | Cambiar la hora exige tres pasos del asistente. No hay edición directa ni un resumen que se pueda corregir. Apariencia y el color de las citas sí se cambian en un paso. |
| 8 | Aesthetic and Minimalist Design | 2 | El papel y las líneas finas son quietos. El hub gasta una fila en un generador de datos, y PQRS ocupa la primera pantalla en siete preguntas antes del formulario. |
| 9 | Error Recovery | 2 | PQRS nombra el fallo y conserva el borrador. `profileLoadFailed` y `quotesLoadFailed` anexan la excepción cruda. Los errores de campo son leyendas en azul de estación. |
| 10 | Help and Documentation | 3 | Las preguntas frecuentes responden tareas reales (cuenta, importar, sin conexión, hábito, tiempo, tamaño de tipo, borrar). La puerta de esa ayuda es la etiqueta «PQRS». |
| **Total** | | **23/40** | **Aceptable** |

## Design Specificity Verdict

**Evaluación de diseño.** El hub de Perfil es una lista de ajustes intercambiable. `ProfilePage` son ocho `ListTile` del mismo peso — «Hábito de lectura», el resumen del mes, «Citas», «Apariencia», «Color de las citas», «Modo concentración», «PQRS», «Generar lecturas de ejemplo» — separados por `Divider` y un `ScheduleRule` que es la misma línea de 1 px. No hay banda de estación, no hay Barlow Condensed, no hay marca de que la fila abre otra pantalla. Cambiar los sustantivos y esta es la pantalla de ajustes de cualquier teléfono.

El cuaderno impreso sí aparece en las hojas, y de forma desigual. Apariencia está escrita para Liora: la banda `ScheduleListing` está al aire, y cada tema se pone en su propia cara (`Programa` en Barlow Condensed, `Libro` en serifa, `Ficha` en slab). Citas vacías también: «Todavía no hay citas» es un título de programa, con una instrucción y una sola acción. PQRS está a medias: la grilla de cuatro tipos es un bloque reglado, y la nota «Enviada» es una banda de estación de verdad; las siete preguntas de arriba son un centro de ayuda. El editor del hábito es el asistente del primer día (`OnboardingPage`, `editing: true`). Tarjetas con borde, «1 de 3», y un cierre que dice «Quiero empezar a leer». No se lee como un programa que se está revisando.

El hub también se salta el producto. Quien abre Perfil viene a ver y cambiar un hábito diario. La fila que debería ser el programa solo arrastra los minutos (`10 minutos`, o «Sin definir»). El periodo, la hora y los días de `ReadingRoutine` no están en la fila.

**Escaneo determinista.** `impeccable detect --json lib/features/profile` salió con código 0 y un arreglo vacío. Cero hallazgos en los 10 archivos Dart de la carpeta, incluido `profile_page.dart`. El detector no vio jerarquía, arquitectura ni texto: busca patrones de marcado web, y una pantalla Flutter puede salir limpia y seguir siendo una lista genérica. No hay falsos positivos, porque no hubo hallazgos. Lo que el detector no alcanzó a marcar es todo el problema de esta pantalla.

**Capas visuales.** No hay una capa visible para la persona. Es una superficie Flutter nativa; no había una página en localhost sirviendo Perfil, y no se inyectó el script del detector. La evidencia visual es el emulador Android que ya estaba corriendo (`emulator-5554`): Perfil en claro y en oscuro, y en claro Apariencia, Citas vacías, PQRS y los tres pasos del editor del hábito. iOS no estaba encendido; esa plataforma se revisó solo en el código.

## Overall Impression

Perfil funciona como un índice plano. Lo que Liora es — un rato de lectura a una hora elegida — no aparece en la única pantalla que guarda ese rato. La oportunidad grande es poner el programa arriba, con la hora, el periodo y los minutos, y dejar que el resto de la lista quede debajo, en grupos con nombre.

Carga cognitiva: fallan las 8 comprobaciones. El hub ofrece 8 filas del mismo peso. También superan las cuatro opciones visibles el paso de motivaciones (5), los temas (5), las fuentes (5), los colores de cita (5), las preguntas frecuentes (7), los días (7) y las horas de la tarde (7).

## What's Working

- **Apariencia es una página de programa.** La banda al aire, la cara propia de `Programa`, `Libro`, `Cuaderno`, `Periódico` y `Ficha`, y un «Restaurar» que se apaga en el valor por defecto.
- **Citas vacías enseña el gesto.** «Todavía no hay citas», «Selecciona un pasaje y pulsa Guardar cita.», y una acción: «Biblioteca».
- **El cierre de PQRS y el modo concentración.** Cuatro tipos en un bloque reglado, y después una banda que repite lo enviado. En el hub, «Modo concentración» es el texto más claro: avisa que las notificaciones y las llamadas se callan y que las alarmas siguen sonando.

## Priority Issues

### [P1] Editar el hábito repite el primer día

`ProfilePage` abre `/onboarding?editar=1`. `OnboardingPage` arranca en el paso 1 cuando `editing` es verdadero, y el botón del paso 3 sigue siendo `startReading` («Quiero empezar a leer»). Guardar llama a `context.go` hacia Perfil, sin una línea de éxito.

**Por qué importa.** Esta es la tarea de la pantalla. Quien quiere mover las 14:00 responde otra vez para qué lee, y sale como si todavía no hubiera empezado.

**Arreglo.** Una superficie de edición que muestre los minutos actuales, Mañana / Tarde / Noche, los días y la hora, con «Guardar». Volver con pop y actualizar la fila «Hábito de lectura». El asistente de tres pasos se queda para la primera vez.

**Comando sugerido:** /impeccable distill

### [P1] El hub no muestra el programa

«Hábito de lectura» es un `ListTile` cuyo texto de cola es solo los minutos, o «Sin definir». No hay banda, ni hora, ni días. La mitad de abajo del teléfono es papel vacío: la fila importante queda arriba, lejos del pulgar, y «Generar lecturas de ejemplo» queda más cerca de la mano.

**Por qué importa.** El producto es un hábito a una hora elegida. La pantalla que lo guarda lo muestra como un valor de ajustes.

**Arreglo.** Una banda de estación primero: la hora guardada como hora de entrada, el periodo y los minutos como la línea. El resto, bajo líneas con nombre (registros, luego el dispositivo). Una marca de disclosure en las filas que abren otra pantalla.

**Comando sugerido:** /impeccable layout

### [P1] «PQRS» esconde la tarea

La etiqueta del hub es el acrónimo. En la página, siete preguntas preceden al formulario. En el teléfono que se revisó, «Enviar» empieza debajo de la barra de pestañas. La frase «Peticiones, quejas, reclamos y sugerencias sobre Liora.» existe, y solo se lee después del toque.

**Por qué importa.** La ayuda y el escrito son reales, y la primera pantalla no resuelve ninguno con claridad. Quien llega por primera vez no sabe qué abre la fila. Quien vino a escribir tiene que pasar el manual.

**Arreglo.** Nombrar la fila con esa descripción, o con «Ayuda». Poner «Escribir» primero. Dejar las preguntas frecuentes como un solo grupo cerrado.

**Comando sugerido:** /impeccable clarify

### [P2] Las señales de riesgo usan el mismo azul de la banda

«Eliminar» y «Cancelar» son dos `TextButton` iguales. Los errores de PQRS usan `colors.station`, el mismo azul del tipo elegido y del botón «Enviar». El azul de noche `#2F6FE0` sobre el papel de noche `#0E1A2B` queda en 3.72:1, por debajo de 4.5:1 para texto. El tipo claro `#F4F7FB` sobre ese azul queda en 4.37:1.

**Por qué importa.** Borrar, un correo mal escrito y «esta opción está al aire» se ven con el mismo énfasis. En oscuro, el texto en azul de estación no alcanza el contraste de lectura ordinaria.

**Arreglo.** Usar la acción destructiva de la plataforma para «Eliminar» y para «Generar». Marcar los errores con un icono y tinta, y reservar el azul de estación para el tipo elegido y para «Enviar». Cuando el azul de noche sea texto sobre papel de noche, subirlo de luminosidad, o usarlo solo como relleno con tipo `onStation`.

**Comando sugerido:** /impeccable harden

### [P2] «Generar lecturas de ejemplo» vive en la lista de quien lee

El subtítulo dice «Desde hoy, un mes y medio atrás, de 0 a 15 minutos.» Confirmar escribe ese historial en el registro del dispositivo. PRODUCT.md sigue tratando esto como pregunta abierta: función del producto o ayuda de desarrollo. No hay deshacer.

**Por qué importa.** Pesa lo mismo que el hábito, y puede falsear el registro que la app existe para guardar.

**Arreglo.** Si es ayuda de desarrollo, quitarla de esta pantalla. Si se queda, nombrarla como datos de muestra, pedir una segunda confirmación que diga que se va a escribir encima, y ofrecer una forma de quitar esas sesiones.

**Comando sugerido:** /impeccable harden

## Persona Red Flags

**Jordan (primera vez).** Perfil no dice qué hacer. «PQRS» es opaco. El resumen del mes no tiene valor ni chevron. Tocar «Hábito de lectura» abre «¿Qué quieres conseguir con la lectura?» y «1 de 3», en lugar de los minutos que la fila acaba de mostrar. El final de ese camino dice «Quiero empezar a leer». Citas vacías sí le sirven; el hub y el asistente no.

**Sam (VoiceOver, teclado, baja visión).** La fila del color de las citas no dice «Ámbar» ni los otros cuatro nombres; los círculos del diálogo sí, y no tienen texto visible. El azul de noche a 3.72:1 no alcanza. `ScheduleHeader` no es un encabezado, así que no hay salto entre Perfil, Apariencia, Citas y PQRS. Los errores son texto azul, sin icono. La tira de fuentes es de 12 px en una tarjeta de 80 px, y «Newsreader» se corta. Los días sí exponen «Lunes» a «Domingo», y el interruptor de concentración es un switch de verdad. Los iconos de una cita tienen tooltip («Crear imagen», «Compartir texto», «Eliminar cita»).

**Casey (una mano, a ratos).** Las flechas de atrás están en la esquina de arriba. La fila del hábito está en la banda alta; «Generar lecturas de ejemplo» es la fila más cerca del pulgar. «Enviar» queda a un scroll de siete preguntas, y luego apretado sobre la barra de pestañas. «Siguiente» y «Quiero empezar a leer» sí caen en la zona del pulgar, pero las respuestas viven solo en el estado del widget hasta el último toque. Si la app se cierra a mitad de la edición, el cambio se pierde. Si se cierra a mitad de PQRS, el mensaje se pierde. Apariencia aguanta, porque guarda al tocar.

**Quien lee en español, con un hábito diario y sin cuenta.** Perfil no repite «Sin cuenta. Tus libros y tu progreso se guardan en este dispositivo.» Esa frase está dentro de la respuesta de las preguntas frecuentes. El hábito que ya eligió queda reducido a «10 minutos». La fila de abajo puede fabricar historial de lectura en el único dispositivo que lo guarda. «Quiero empezar a leer» le habla como a alguien que no ha empezado.

## Minor Observations

- Desde Citas vacías, «Biblioteca» hace `context.go('/library')`, así que Atrás desde la biblioteca no vuelve a las citas.
- La banda de vista previa de Apariencia es el lema de bienvenida a una hora fija, `08:00`, y no el horario de esta persona. En español la letra de la banda es «C», mientras `Programa` y `Periódico` muestran ambos una «P».
- Las letras de los días en español (`L M X J V S D`) evitan el duplicado; la build en inglés del emulador mostraba `M T W T F S S`.
- `_DayLetter` mide 44 px de alto dentro de una fila de siete columnas, así que el ancho de toque se aprieta en un teléfono estrecho.
- Las pantallas de detalle usan título grande. En iOS ese tamaño corresponde a la raíz.
- Borrar una cita y generar lecturas usan `AlertDialog` en las dos plataformas.
- «Restaurar» no pide confirmación. El tema anterior está a un toque.
- No hay cuenta de caracteres hacia el límite de 2000 del mensaje.

## Questions to Consider

- Si Perfil es donde se guarda el hábito, qué cambia si lo primero de la página es el programa de hoy — hora, periodo, minutos — y cada otra fila queda debajo.
- Qué se vuelve más claro sobre la confianza si «Generar lecturas de ejemplo» no se puede alcanzar desde esta pantalla.
- El último control de una edición sigue diciendo «Quiero empezar a leer». Qué debería decirle esa línea a alguien que ya lee a las 14:00.
