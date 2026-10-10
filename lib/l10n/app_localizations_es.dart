// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get discover => 'Descubrimiento';

  @override
  String get library => 'Biblioteca';

  @override
  String get time => 'Tiempo';

  @override
  String get profile => 'Perfil';

  @override
  String get noBooksYet => 'Todavía no hay libros';

  @override
  String get epubOnDevice => 'Un EPUB de este dispositivo';

  @override
  String get import => 'Importar';

  @override
  String get importing => 'Importando';

  @override
  String get importEpub => 'Importar EPUB';

  @override
  String get read => 'Leer';

  @override
  String get notStarted => 'Sin empezar';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteBook => 'Eliminar libro';

  @override
  String removeBook(String title) {
    return '¿Quitar «$title» de la biblioteca?';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get alreadyInLibrary => 'Este libro ya está en la biblioteca.';

  @override
  String get importFailed => 'No se pudo importar el EPUB.';

  @override
  String get deleteFailed => 'No se pudo eliminar el libro.';

  @override
  String get addFailed => 'No se pudo añadir el libro a la biblioteca.';

  @override
  String get untitled => 'Sin título';

  @override
  String get notAnEpub => 'El archivo no es un EPUB válido.';

  @override
  String get epubMissingRoot => 'El EPUB no indica su archivo de contenido.';

  @override
  String get epubMissingContent => 'No se encontró el contenido del EPUB.';

  @override
  String get toAdd => 'Por añadir';

  @override
  String get inYourLibrary => 'En tu biblioteca';

  @override
  String get add => 'Añadir';

  @override
  String get allLanguages => 'Todos';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'Inglés';

  @override
  String get catalogEmpty => 'El catálogo está vacío';

  @override
  String get catalogEmptyBody =>
      'Cuando haya libros disponibles, aparecerán aquí.';

  @override
  String get retry => 'Reintentar';

  @override
  String get catalogLoadFailed => 'No se pudo cargar el catálogo.';

  @override
  String catalogLoadFailedStatus(int status) {
    return 'No se pudo cargar el catálogo ($status).';
  }

  @override
  String get catalogInvalid => 'El catálogo no tiene el formato esperado.';

  @override
  String get missingDownload => 'Este libro no tiene enlace de descarga.';

  @override
  String downloadFailed(int status) {
    return 'No se pudo descargar el libro ($status).';
  }

  @override
  String get missingApiKey => 'Falta X_EPUB_KEY en .env.';

  @override
  String get contents => 'Índice';

  @override
  String get close => 'Cerrar';

  @override
  String get back => 'Atrás';

  @override
  String get noContents => 'Este libro no tiene índice.';

  @override
  String get copy => 'Copiar';

  @override
  String get share => 'Compartir';

  @override
  String get copied => 'Copiado';

  @override
  String get saveQuote => 'Guardar cita';

  @override
  String get quoteSaved => 'Cita guardada';

  @override
  String get quoteSaveFailed => 'No se pudo guardar la cita.';

  @override
  String get savedQuotes => 'Citas';

  @override
  String get noQuotes => 'Todavía no hay citas';

  @override
  String get noQuotesBody => 'Selecciona un pasaje en la lectura y guárdalo.';

  @override
  String quotesLoadFailed(String error) {
    return 'No se pudieron cargar las citas.\n$error';
  }

  @override
  String get bookGone => 'Este libro ya no está en la biblioteca.';

  @override
  String get chapterFailed => 'No se pudo abrir este capítulo.';

  @override
  String get preferencesFailed =>
      'No se pudieron aplicar los ajustes de lectura.';

  @override
  String get preferencesSaveFailed =>
      'No se pudieron guardar los ajustes de lectura.';

  @override
  String get fixedColor =>
      'En un libro de maquetación fija el color del texto no cambia.';

  @override
  String get fixedPages => 'Este libro se lee por páginas.';

  @override
  String get fixedSize =>
      'En un libro de maquetación fija el tamaño del texto no cambia.';

  @override
  String get fixedColorShort => 'En este libro el color del texto no cambia';

  @override
  String get fixedPagesShort => 'Este libro se lee por páginas';

  @override
  String get fixedSizeShort => 'En este libro el tamaño del texto no cambia';

  @override
  String get pageMode => 'Lectura por páginas';

  @override
  String get scrollMode => 'Lectura con scroll';

  @override
  String get lightMode => 'Modo claro';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get smallerText => 'Reducir texto';

  @override
  String get originalSize => 'Tamaño original';

  @override
  String get largerText => 'Aumentar texto';

  @override
  String get readerDesktopOnly =>
      'El lector funciona en iOS y Android. En el escritorio de macOS Readium no abre el EPUB.';

  @override
  String get openFailed => 'No se pudo abrir el libro.';

  @override
  String get invalidBook => 'Libro no válido.';

  @override
  String get welcomeTitle => 'Crea el hábito de leer';

  @override
  String get welcomeBody =>
      'Un lugar para leer un poco cada día y sostener ese hábito.';

  @override
  String get welcomeAccount =>
      'Sin cuenta. Tus libros y tu progreso se guardan en este dispositivo.';

  @override
  String get notificationPermissionTitle => 'Te aviso a tu hora';

  @override
  String get notificationPermissionBody =>
      'Cuando llega el momento que elegiste, Liora puede recordarte que leas.';

  @override
  String get notificationPermissionAllow => 'Activar avisos';

  @override
  String get notificationPermissionSkip => 'Ahora no';

  @override
  String get notificationPermissionFailed => 'No se pudo pedir el permiso.';

  @override
  String stepOf(int step, int total) {
    return '$step de $total';
  }

  @override
  String get start => 'Empezar';

  @override
  String get startReading => 'Quiero empezar a leer';

  @override
  String get next => 'Siguiente';

  @override
  String get answersSaveFailed => 'No se pudieron guardar tus respuestas.';

  @override
  String profileLoadFailed(String error) {
    return 'No se pudo cargar el perfil.\n$error';
  }

  @override
  String get motivationQuestion => '¿Qué quieres conseguir con la lectura?';

  @override
  String get goalQuestion => '¿Cuánto quieres leer?';

  @override
  String get whenQuestion => '¿Cuándo te gustaría leer?';

  @override
  String get whichDays => '¿Qué días?';

  @override
  String get whatTime => '¿A qué hora?';

  @override
  String minutes(int count) {
    return '$count minutos';
  }

  @override
  String get motivationReadMore => 'Leer más';

  @override
  String get motivationHabit => 'Crear un hábito';

  @override
  String get motivationFinishBooks => 'Terminar más libros';

  @override
  String get motivationLearn => 'Aprender cosas nuevas';

  @override
  String get motivationTimeForMe => 'Tener un momento para mí';

  @override
  String get routineMorning => 'Mañana';

  @override
  String get routineAfternoon => 'Tarde';

  @override
  String get routineNight => 'Noche';

  @override
  String get mondayLetter => 'L';

  @override
  String get tuesdayLetter => 'M';

  @override
  String get wednesdayLetter => 'X';

  @override
  String get thursdayLetter => 'J';

  @override
  String get fridayLetter => 'V';

  @override
  String get saturdayLetter => 'S';

  @override
  String get sundayLetter => 'D';

  @override
  String get monday => 'Lunes';

  @override
  String get tuesday => 'Martes';

  @override
  String get wednesday => 'Miércoles';

  @override
  String get thursday => 'Jueves';

  @override
  String get friday => 'Viernes';

  @override
  String get saturday => 'Sábado';

  @override
  String get sunday => 'Domingo';

  @override
  String get notSet => 'Sin definir';

  @override
  String get readingHabit => 'Hábito de lectura';

  @override
  String get sampleReadings => 'Generar lecturas de ejemplo';

  @override
  String get sampleReadingsSubtitle =>
      'Desde hoy, un mes y medio atrás, de 0 a 15 minutos.';

  @override
  String get sampleReadingsBody =>
      'Se agregará una lectura al azar por cada día, desde hoy hasta un mes y medio atrás. Cada una dura entre 0 y 15 minutos.';

  @override
  String get generate => 'Generar';

  @override
  String sampleReadingsAdded(int count) {
    return 'Se agregaron $count lecturas de ejemplo.';
  }

  @override
  String get sampleReadingsFailed => 'No se pudieron generar las lecturas.';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String goalLine(String duration) {
    return 'Meta · $duration';
  }

  @override
  String get noRecords => 'Todavía no hay registros';

  @override
  String get noRecordsBody =>
      'El tiempo se guarda cuando una lectura pasa de 30 segundos.';

  @override
  String booksLoadFailed(String error) {
    return 'No se pudieron cargar los libros.\n$error';
  }

  @override
  String readingTimeLoadFailed(String error) {
    return 'No se pudo cargar el tiempo de lectura.\n$error';
  }

  @override
  String get previousMonth => 'Mes anterior';

  @override
  String get nextMonth => 'Mes siguiente';

  @override
  String get today => 'Hoy';

  @override
  String get goalLabel => 'Meta';

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String minutesOfGoal(int done, int goal) {
    return '$done / $goal min';
  }

  @override
  String get yesterday => 'Ayer';

  @override
  String get goalMet => 'meta cumplida';

  @override
  String get partialReading => 'leído sin cumplir la meta';

  @override
  String get noReading => 'sin lectura';

  @override
  String calendarDate(int day, String month) {
    return '$day de $month';
  }

  @override
  String dayReading(String day, String duration) {
    return '$day · $duration';
  }

  @override
  String calendarDay(int day, String month, String duration, String state) {
    return '$day de $month, $duration, $state';
  }

  @override
  String libraryLoadFailed(String error) {
    return 'No se pudo cargar la biblioteca.\n$error';
  }

  @override
  String get sampleBookTitle => 'Lectura de ejemplo';

  @override
  String get notificationChannelName => 'Avisos';

  @override
  String get notificationChannelDescription => 'Avisos de Liora';

  @override
  String get notificationRoutineTitle => 'Hora de leer';

  @override
  String notificationRoutineBody(String hour, int minutes) {
    return 'Son las $hour. Hoy tu meta es $minutes min.';
  }

  @override
  String get notificationGoalTitle => 'La meta de hoy';

  @override
  String notificationGoalRemainingBody(int minutes) {
    return 'Te faltan $minutes min para cerrar el día.';
  }

  @override
  String get notificationGoalMetTitle => 'Meta cumplida';

  @override
  String notificationGoalMetBody(int minutes) {
    return 'Cerraste el día. $minutes min.';
  }

  @override
  String notificationResumeChapterBody(int chapter, String title) {
    return 'Sigues en el capítulo $chapter de $title.';
  }

  @override
  String notificationResumeSectionBody(String section, String title) {
    return 'Sigues en $section de $title.';
  }

  @override
  String notificationResumeBookBody(String title) {
    return 'Sigues con $title.';
  }

  @override
  String get notificationStreakTitle => 'Tu racha';

  @override
  String notificationStreakBody(int days) {
    return 'Llevas $days días. Hoy también cuenta.';
  }

  @override
  String get notificationNudgeTitle => 'Todavía hay tiempo';

  @override
  String get notificationNudgeBody1 =>
      'Dos minutos alcanzan para no soltar el día.';

  @override
  String get notificationNudgeBody2 =>
      'Si hoy se llenó, quédate con un par de páginas.';

  @override
  String get notificationNudgeBody3 =>
      'No hace falta cumplir la meta. Abrir el libro ya cuenta.';

  @override
  String get notificationNudgeBody4 =>
      'Un momento corto también sostiene el hábito.';

  @override
  String get notificationNudgeBody5 =>
      'El día todavía tiene sitio para unas líneas.';

  @override
  String get focusMode => 'Modo concentración';

  @override
  String get focusModeAndroidBody =>
      'Silencia notificaciones y llamadas mientras Liora está abierta. Las alarmas siguen sonando.';

  @override
  String get focusModeIosBody =>
      'Al abrir Liora, el iPhone entra en No molestar si preparas Atajos una vez.';

  @override
  String get focusModeIosOnBody =>
      'Activo. Para quitarlo del todo, borra la automatización en Atajos.';

  @override
  String get focusModePermissionNeeded =>
      'Para silenciar el teléfono, permite a Liora el acceso a No molestar.';

  @override
  String get focusModeChangeFailed => 'No se pudo cambiar No molestar.';

  @override
  String get focusModeIosRemains =>
      'La automatización de Atajos sigue hasta que la borres.';

  @override
  String get focusGuideTitle => 'No molestar al leer';

  @override
  String get focusGuideBody =>
      'iOS no deja que una app encienda No molestar. Atajos sí, si lo dejas preparado una vez.';

  @override
  String get focusGuideOpenHeading => 'Al abrir Liora';

  @override
  String get focusGuideOpenSteps =>
      '1. En Atajos, entra en Automatización y pulsa +.\n2. Elige App, luego Liora, y deja marcada la opción de al abrirla.\n3. Añade Definir concentración, elige No molestar y ponlo en Activado.\n4. Desactiva Preguntar antes de ejecutar.';

  @override
  String get focusGuideCloseHeading => 'Al cerrar Liora';

  @override
  String get focusGuideCloseSteps =>
      'Repite los pasos con la opción de al cerrarla y No molestar en Desactivado.';

  @override
  String get focusGuideOpenShortcuts => 'Abrir Atajos';

  @override
  String get focusGuideDone => 'Listo';

  @override
  String get focusGuideNotNow => 'Ahora no';

  @override
  String get focusGuideOpenFailed => 'No se pudo abrir Atajos.';
}
