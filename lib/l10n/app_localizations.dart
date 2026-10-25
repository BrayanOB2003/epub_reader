import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @discover.
  ///
  /// In es, this message translates to:
  /// **'Descubrimiento'**
  String get discover;

  /// No description provided for @library.
  ///
  /// In es, this message translates to:
  /// **'Biblioteca'**
  String get library;

  /// No description provided for @time.
  ///
  /// In es, this message translates to:
  /// **'Tiempo'**
  String get time;

  /// No description provided for @profile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// No description provided for @noBooksYet.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay libros'**
  String get noBooksYet;

  /// No description provided for @epubOnDevice.
  ///
  /// In es, this message translates to:
  /// **'Un EPUB de este dispositivo'**
  String get epubOnDevice;

  /// No description provided for @import.
  ///
  /// In es, this message translates to:
  /// **'Importar'**
  String get import;

  /// No description provided for @importing.
  ///
  /// In es, this message translates to:
  /// **'Importando'**
  String get importing;

  /// No description provided for @importEpub.
  ///
  /// In es, this message translates to:
  /// **'Importar EPUB'**
  String get importEpub;

  /// No description provided for @read.
  ///
  /// In es, this message translates to:
  /// **'Leer'**
  String get read;

  /// No description provided for @notStarted.
  ///
  /// In es, this message translates to:
  /// **'Sin empezar'**
  String get notStarted;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @deleteBook.
  ///
  /// In es, this message translates to:
  /// **'Eliminar libro'**
  String get deleteBook;

  /// No description provided for @removeBook.
  ///
  /// In es, this message translates to:
  /// **'¿Quitar «{title}» de la biblioteca?'**
  String removeBook(String title);

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @alreadyInLibrary.
  ///
  /// In es, this message translates to:
  /// **'Este libro ya está en la biblioteca.'**
  String get alreadyInLibrary;

  /// No description provided for @importFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo importar el EPUB.'**
  String get importFailed;

  /// No description provided for @deleteFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar el libro.'**
  String get deleteFailed;

  /// No description provided for @addFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo añadir el libro a la biblioteca.'**
  String get addFailed;

  /// No description provided for @untitled.
  ///
  /// In es, this message translates to:
  /// **'Sin título'**
  String get untitled;

  /// No description provided for @notAnEpub.
  ///
  /// In es, this message translates to:
  /// **'El archivo no es un EPUB válido.'**
  String get notAnEpub;

  /// No description provided for @epubMissingRoot.
  ///
  /// In es, this message translates to:
  /// **'El EPUB no indica su archivo de contenido.'**
  String get epubMissingRoot;

  /// No description provided for @epubMissingContent.
  ///
  /// In es, this message translates to:
  /// **'No se encontró el contenido del EPUB.'**
  String get epubMissingContent;

  /// No description provided for @toAdd.
  ///
  /// In es, this message translates to:
  /// **'Por añadir'**
  String get toAdd;

  /// No description provided for @inYourLibrary.
  ///
  /// In es, this message translates to:
  /// **'En tu biblioteca'**
  String get inYourLibrary;

  /// No description provided for @add.
  ///
  /// In es, this message translates to:
  /// **'Añadir'**
  String get add;

  /// No description provided for @allLanguages.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get allLanguages;

  /// No description provided for @spanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get english;

  /// No description provided for @catalogEmpty.
  ///
  /// In es, this message translates to:
  /// **'El catálogo está vacío'**
  String get catalogEmpty;

  /// No description provided for @catalogEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Cuando haya libros disponibles, aparecerán aquí.'**
  String get catalogEmptyBody;

  /// No description provided for @catalogLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando el catálogo'**
  String get catalogLoading;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @catalogLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el catálogo.'**
  String get catalogLoadFailed;

  /// No description provided for @catalogLoadFailedStatus.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el catálogo ({status}).'**
  String catalogLoadFailedStatus(int status);

  /// No description provided for @catalogInvalid.
  ///
  /// In es, this message translates to:
  /// **'El catálogo no tiene el formato esperado.'**
  String get catalogInvalid;

  /// No description provided for @missingDownload.
  ///
  /// In es, this message translates to:
  /// **'Este libro no tiene enlace de descarga.'**
  String get missingDownload;

  /// No description provided for @downloadFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo descargar el libro ({status}).'**
  String downloadFailed(int status);

  /// No description provided for @missingApiKey.
  ///
  /// In es, this message translates to:
  /// **'Falta X_EPUB_KEY en .env.'**
  String get missingApiKey;

  /// No description provided for @contents.
  ///
  /// In es, this message translates to:
  /// **'Índice'**
  String get contents;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get back;

  /// No description provided for @noContents.
  ///
  /// In es, this message translates to:
  /// **'Este libro no tiene índice.'**
  String get noContents;

  /// No description provided for @contentsKeepReading.
  ///
  /// In es, this message translates to:
  /// **'Puedes seguir pasando páginas.'**
  String get contentsKeepReading;

  /// No description provided for @contentsSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar en el índice'**
  String get contentsSearch;

  /// No description provided for @contentsNoMatches.
  ///
  /// In es, this message translates to:
  /// **'Ningún capítulo coincide.'**
  String get contentsNoMatches;

  /// No description provided for @chapterLabel.
  ///
  /// In es, this message translates to:
  /// **'Capítulo {position}'**
  String chapterLabel(int position);

  /// No description provided for @chapterOpenFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir «{title}».'**
  String chapterOpenFailed(String title);

  /// No description provided for @showChapters.
  ///
  /// In es, this message translates to:
  /// **'Mostrar capítulos'**
  String get showChapters;

  /// No description provided for @hideChapters.
  ///
  /// In es, this message translates to:
  /// **'Ocultar capítulos'**
  String get hideChapters;

  /// No description provided for @copy.
  ///
  /// In es, this message translates to:
  /// **'Copiar'**
  String get copy;

  /// No description provided for @share.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get share;

  /// No description provided for @copied.
  ///
  /// In es, this message translates to:
  /// **'Copiado'**
  String get copied;

  /// No description provided for @saveQuote.
  ///
  /// In es, this message translates to:
  /// **'Guardar cita'**
  String get saveQuote;

  /// No description provided for @quoteSaved.
  ///
  /// In es, this message translates to:
  /// **'Cita guardada'**
  String get quoteSaved;

  /// No description provided for @quoteSaveFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar la cita.'**
  String get quoteSaveFailed;

  /// No description provided for @savedQuotes.
  ///
  /// In es, this message translates to:
  /// **'Citas'**
  String get savedQuotes;

  /// No description provided for @noQuotes.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay citas'**
  String get noQuotes;

  /// No description provided for @noQuotesBody.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un pasaje y pulsa Guardar cita.'**
  String get noQuotesBody;

  /// No description provided for @quoteAlreadySaved.
  ///
  /// In es, this message translates to:
  /// **'Esa cita ya está guardada.'**
  String get quoteAlreadySaved;

  /// No description provided for @shareQuoteText.
  ///
  /// In es, this message translates to:
  /// **'Compartir texto'**
  String get shareQuoteText;

  /// No description provided for @quoteShareFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo compartir la cita.'**
  String get quoteShareFailed;

  /// No description provided for @quotesLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar las citas. Inténtalo de nuevo.'**
  String get quotesLoadFailed;

  /// No description provided for @bookGone.
  ///
  /// In es, this message translates to:
  /// **'Este libro ya no está en la biblioteca.'**
  String get bookGone;

  /// No description provided for @chapterFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir este capítulo.'**
  String get chapterFailed;

  /// No description provided for @preferencesFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron aplicar los ajustes de lectura.'**
  String get preferencesFailed;

  /// No description provided for @preferencesSaveFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron guardar los ajustes de lectura.'**
  String get preferencesSaveFailed;

  /// No description provided for @fixedColor.
  ///
  /// In es, this message translates to:
  /// **'En un libro de maquetación fija el color del texto no cambia.'**
  String get fixedColor;

  /// No description provided for @fixedPages.
  ///
  /// In es, this message translates to:
  /// **'Este libro se lee por páginas.'**
  String get fixedPages;

  /// No description provided for @fixedSize.
  ///
  /// In es, this message translates to:
  /// **'En un libro de maquetación fija el tamaño del texto no cambia.'**
  String get fixedSize;

  /// No description provided for @fixedColorShort.
  ///
  /// In es, this message translates to:
  /// **'En este libro el color del texto no cambia'**
  String get fixedColorShort;

  /// No description provided for @fixedPagesShort.
  ///
  /// In es, this message translates to:
  /// **'Este libro se lee por páginas'**
  String get fixedPagesShort;

  /// No description provided for @fixedSizeShort.
  ///
  /// In es, this message translates to:
  /// **'En este libro el tamaño del texto no cambia'**
  String get fixedSizeShort;

  /// No description provided for @pageMode.
  ///
  /// In es, this message translates to:
  /// **'Lectura por páginas'**
  String get pageMode;

  /// No description provided for @scrollMode.
  ///
  /// In es, this message translates to:
  /// **'Lectura con scroll'**
  String get scrollMode;

  /// No description provided for @lightMode.
  ///
  /// In es, this message translates to:
  /// **'Modo claro'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In es, this message translates to:
  /// **'Modo oscuro'**
  String get darkMode;

  /// No description provided for @smallerText.
  ///
  /// In es, this message translates to:
  /// **'Reducir texto'**
  String get smallerText;

  /// No description provided for @originalSize.
  ///
  /// In es, this message translates to:
  /// **'Tamaño original'**
  String get originalSize;

  /// No description provided for @largerText.
  ///
  /// In es, this message translates to:
  /// **'Aumentar texto'**
  String get largerText;

  /// No description provided for @readerDesktopOnly.
  ///
  /// In es, this message translates to:
  /// **'El lector funciona en iOS y Android. En el escritorio de macOS Readium no abre el EPUB.'**
  String get readerDesktopOnly;

  /// No description provided for @openFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir el libro.'**
  String get openFailed;

  /// No description provided for @invalidBook.
  ///
  /// In es, this message translates to:
  /// **'Libro no válido.'**
  String get invalidBook;

  /// No description provided for @welcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'Crea el hábito de leer'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In es, this message translates to:
  /// **'Un lugar para leer un poco cada día y sostener ese hábito.'**
  String get welcomeBody;

  /// No description provided for @welcomeNext.
  ///
  /// In es, this message translates to:
  /// **'Unos minutos, a la hora que elijas.'**
  String get welcomeNext;

  /// No description provided for @notificationPermissionTitle.
  ///
  /// In es, this message translates to:
  /// **'Te aviso a tu hora'**
  String get notificationPermissionTitle;

  /// No description provided for @notificationPermissionBody.
  ///
  /// In es, this message translates to:
  /// **'Cuando llega el momento que elegiste, Liora puede recordarte que leas.'**
  String get notificationPermissionBody;

  /// No description provided for @notificationPermissionAllow.
  ///
  /// In es, this message translates to:
  /// **'Activar avisos'**
  String get notificationPermissionAllow;

  /// No description provided for @notificationPermissionSkip.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get notificationPermissionSkip;

  /// No description provided for @notificationPermissionFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo pedir el permiso.'**
  String get notificationPermissionFailed;

  /// No description provided for @stepOf.
  ///
  /// In es, this message translates to:
  /// **'{step} de {total}'**
  String stepOf(int step, int total);

  /// No description provided for @start.
  ///
  /// In es, this message translates to:
  /// **'Empezar'**
  String get start;

  /// No description provided for @startReading.
  ///
  /// In es, this message translates to:
  /// **'Quiero empezar a leer'**
  String get startReading;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @habitSaved.
  ///
  /// In es, this message translates to:
  /// **'Hábito guardado.'**
  String get habitSaved;

  /// No description provided for @next.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get next;

  /// No description provided for @answersSaveFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron guardar tus respuestas.'**
  String get answersSaveFailed;

  /// No description provided for @profileLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el perfil. Inténtalo de nuevo.'**
  String get profileLoadFailed;

  /// No description provided for @motivationQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Qué quieres conseguir con la lectura?'**
  String get motivationQuestion;

  /// No description provided for @goalQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Cuánto quieres leer?'**
  String get goalQuestion;

  /// No description provided for @whenQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Cuándo te gustaría leer?'**
  String get whenQuestion;

  /// No description provided for @whichDays.
  ///
  /// In es, this message translates to:
  /// **'¿Qué días?'**
  String get whichDays;

  /// No description provided for @whatTime.
  ///
  /// In es, this message translates to:
  /// **'¿A qué hora?'**
  String get whatTime;

  /// No description provided for @minutes.
  ///
  /// In es, this message translates to:
  /// **'{count} minutos'**
  String minutes(int count);

  /// No description provided for @motivationReadMore.
  ///
  /// In es, this message translates to:
  /// **'Leer más'**
  String get motivationReadMore;

  /// No description provided for @motivationHabit.
  ///
  /// In es, this message translates to:
  /// **'Crear un hábito'**
  String get motivationHabit;

  /// No description provided for @motivationFinishBooks.
  ///
  /// In es, this message translates to:
  /// **'Terminar más libros'**
  String get motivationFinishBooks;

  /// No description provided for @motivationLearn.
  ///
  /// In es, this message translates to:
  /// **'Aprender cosas nuevas'**
  String get motivationLearn;

  /// No description provided for @motivationTimeForMe.
  ///
  /// In es, this message translates to:
  /// **'Tener un momento para mí'**
  String get motivationTimeForMe;

  /// No description provided for @routineMorning.
  ///
  /// In es, this message translates to:
  /// **'Mañana'**
  String get routineMorning;

  /// No description provided for @routineAfternoon.
  ///
  /// In es, this message translates to:
  /// **'Tarde'**
  String get routineAfternoon;

  /// No description provided for @routineNight.
  ///
  /// In es, this message translates to:
  /// **'Noche'**
  String get routineNight;

  /// No description provided for @mondayLetter.
  ///
  /// In es, this message translates to:
  /// **'L'**
  String get mondayLetter;

  /// No description provided for @tuesdayLetter.
  ///
  /// In es, this message translates to:
  /// **'M'**
  String get tuesdayLetter;

  /// No description provided for @wednesdayLetter.
  ///
  /// In es, this message translates to:
  /// **'X'**
  String get wednesdayLetter;

  /// No description provided for @thursdayLetter.
  ///
  /// In es, this message translates to:
  /// **'J'**
  String get thursdayLetter;

  /// No description provided for @fridayLetter.
  ///
  /// In es, this message translates to:
  /// **'V'**
  String get fridayLetter;

  /// No description provided for @saturdayLetter.
  ///
  /// In es, this message translates to:
  /// **'S'**
  String get saturdayLetter;

  /// No description provided for @sundayLetter.
  ///
  /// In es, this message translates to:
  /// **'D'**
  String get sundayLetter;

  /// No description provided for @everyDay.
  ///
  /// In es, this message translates to:
  /// **'Todos los días'**
  String get everyDay;

  /// No description provided for @monday.
  ///
  /// In es, this message translates to:
  /// **'Lunes'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In es, this message translates to:
  /// **'Martes'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In es, this message translates to:
  /// **'Miércoles'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In es, this message translates to:
  /// **'Jueves'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In es, this message translates to:
  /// **'Viernes'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In es, this message translates to:
  /// **'Sábado'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In es, this message translates to:
  /// **'Domingo'**
  String get sunday;

  /// No description provided for @notSet.
  ///
  /// In es, this message translates to:
  /// **'Sin definir'**
  String get notSet;

  /// No description provided for @readingHabit.
  ///
  /// In es, this message translates to:
  /// **'Hábito de lectura'**
  String get readingHabit;

  /// No description provided for @profileRecords.
  ///
  /// In es, this message translates to:
  /// **'Registros'**
  String get profileRecords;

  /// No description provided for @profileDevice.
  ///
  /// In es, this message translates to:
  /// **'Dispositivo'**
  String get profileDevice;

  /// No description provided for @profileSampleData.
  ///
  /// In es, this message translates to:
  /// **'Datos de muestra'**
  String get profileSampleData;

  /// No description provided for @sampleReadings.
  ///
  /// In es, this message translates to:
  /// **'Lecturas de ejemplo'**
  String get sampleReadings;

  /// No description provided for @sampleReadingsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Se agregan al registro de lectura de este dispositivo.'**
  String get sampleReadingsSubtitle;

  /// No description provided for @sampleReadingsBody.
  ///
  /// In es, this message translates to:
  /// **'Se agrega una lectura al azar por cada día, desde hoy hasta un mes y medio atrás. Cada una dura entre 0 y 15 minutos.'**
  String get sampleReadingsBody;

  /// No description provided for @sampleReadingsContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get sampleReadingsContinue;

  /// No description provided for @sampleReadingsConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Escribir en el registro'**
  String get sampleReadingsConfirmTitle;

  /// No description provided for @sampleReadingsConfirmBody.
  ///
  /// In es, this message translates to:
  /// **'Estas lecturas se agregan a tu historial en este dispositivo. Puedes quitarlas después desde Perfil.'**
  String get sampleReadingsConfirmBody;

  /// No description provided for @sampleReadingsWrite.
  ///
  /// In es, this message translates to:
  /// **'Escribirlas'**
  String get sampleReadingsWrite;

  /// No description provided for @sampleReadingsPresent.
  ///
  /// In es, this message translates to:
  /// **'{count} en el registro de este dispositivo.'**
  String sampleReadingsPresent(int count);

  /// No description provided for @removeSampleReadings.
  ///
  /// In es, this message translates to:
  /// **'Quitar lecturas de ejemplo'**
  String get removeSampleReadings;

  /// No description provided for @removeSampleReadingsBody.
  ///
  /// In es, this message translates to:
  /// **'Se quitan del registro las lecturas de ejemplo. Las que leíste tú se quedan.'**
  String get removeSampleReadingsBody;

  /// No description provided for @removeSampleReadingsAction.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get removeSampleReadingsAction;

  /// No description provided for @sampleReadingsRemoved.
  ///
  /// In es, this message translates to:
  /// **'Se quitaron las lecturas de ejemplo.'**
  String get sampleReadingsRemoved;

  /// No description provided for @sampleReadingsRemoveFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron quitar las lecturas de ejemplo.'**
  String get sampleReadingsRemoveFailed;

  /// No description provided for @generate.
  ///
  /// In es, this message translates to:
  /// **'Generar'**
  String get generate;

  /// No description provided for @sampleReadingsAdded.
  ///
  /// In es, this message translates to:
  /// **'Se agregaron {count} lecturas de ejemplo.'**
  String sampleReadingsAdded(int count);

  /// No description provided for @sampleReadingsFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron generar las lecturas.'**
  String get sampleReadingsFailed;

  /// No description provided for @thisWeek.
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get thisWeek;

  /// No description provided for @goalLine.
  ///
  /// In es, this message translates to:
  /// **'Meta · {duration}'**
  String goalLine(String duration);

  /// No description provided for @noRecords.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay registros'**
  String get noRecords;

  /// No description provided for @noRecordsBody.
  ///
  /// In es, this message translates to:
  /// **'El tiempo se guarda cuando una lectura pasa de 30 segundos.'**
  String get noRecordsBody;

  /// No description provided for @booksLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los libros.\n{error}'**
  String booksLoadFailed(String error);

  /// No description provided for @readingTimeLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el tiempo de lectura.\n{error}'**
  String readingTimeLoadFailed(String error);

  /// No description provided for @previousMonth.
  ///
  /// In es, this message translates to:
  /// **'Mes anterior'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In es, this message translates to:
  /// **'Mes siguiente'**
  String get nextMonth;

  /// No description provided for @today.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get today;

  /// No description provided for @goalLabel.
  ///
  /// In es, this message translates to:
  /// **'Meta'**
  String get goalLabel;

  /// No description provided for @minutesShort.
  ///
  /// In es, this message translates to:
  /// **'{count} min'**
  String minutesShort(int count);

  /// No description provided for @minutesOfGoal.
  ///
  /// In es, this message translates to:
  /// **'{done} / {goal} min'**
  String minutesOfGoal(int done, int goal);

  /// No description provided for @yesterday.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get yesterday;

  /// No description provided for @goalMet.
  ///
  /// In es, this message translates to:
  /// **'meta cumplida'**
  String get goalMet;

  /// No description provided for @partialReading.
  ///
  /// In es, this message translates to:
  /// **'leído sin cumplir la meta'**
  String get partialReading;

  /// No description provided for @noReading.
  ///
  /// In es, this message translates to:
  /// **'sin lectura'**
  String get noReading;

  /// No description provided for @calendarDate.
  ///
  /// In es, this message translates to:
  /// **'{day} de {month}'**
  String calendarDate(int day, String month);

  /// No description provided for @dayReading.
  ///
  /// In es, this message translates to:
  /// **'{day} · {duration}'**
  String dayReading(String day, String duration);

  /// No description provided for @calendarDay.
  ///
  /// In es, this message translates to:
  /// **'{day} de {month}, {duration}, {state}'**
  String calendarDay(int day, String month, String duration, String state);

  /// No description provided for @libraryLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar la biblioteca.\n{error}'**
  String libraryLoadFailed(String error);

  /// No description provided for @sampleBookTitle.
  ///
  /// In es, this message translates to:
  /// **'Lectura de ejemplo'**
  String get sampleBookTitle;

  /// No description provided for @notificationChannelName.
  ///
  /// In es, this message translates to:
  /// **'Avisos'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In es, this message translates to:
  /// **'Avisos de Liora'**
  String get notificationChannelDescription;

  /// No description provided for @notificationRoutineTitle.
  ///
  /// In es, this message translates to:
  /// **'Hora de leer'**
  String get notificationRoutineTitle;

  /// No description provided for @notificationRoutineBody.
  ///
  /// In es, this message translates to:
  /// **'Son las {hour}. Hoy tu meta es {minutes} min.'**
  String notificationRoutineBody(String hour, int minutes);

  /// No description provided for @notificationGoalTitle.
  ///
  /// In es, this message translates to:
  /// **'La meta de hoy'**
  String get notificationGoalTitle;

  /// No description provided for @notificationGoalRemainingBody.
  ///
  /// In es, this message translates to:
  /// **'Te faltan {minutes} min para cerrar el día.'**
  String notificationGoalRemainingBody(int minutes);

  /// No description provided for @notificationGoalMetTitle.
  ///
  /// In es, this message translates to:
  /// **'Meta cumplida'**
  String get notificationGoalMetTitle;

  /// No description provided for @notificationGoalMetBody.
  ///
  /// In es, this message translates to:
  /// **'Cerraste el día. {minutes} min.'**
  String notificationGoalMetBody(int minutes);

  /// No description provided for @notificationResumeChapterBody.
  ///
  /// In es, this message translates to:
  /// **'Sigues en el capítulo {chapter} de {title}.'**
  String notificationResumeChapterBody(int chapter, String title);

  /// No description provided for @notificationResumeSectionBody.
  ///
  /// In es, this message translates to:
  /// **'Sigues en {section} de {title}.'**
  String notificationResumeSectionBody(String section, String title);

  /// No description provided for @notificationResumeBookBody.
  ///
  /// In es, this message translates to:
  /// **'Sigues con {title}.'**
  String notificationResumeBookBody(String title);

  /// No description provided for @notificationStreakTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu racha'**
  String get notificationStreakTitle;

  /// No description provided for @notificationStreakBody.
  ///
  /// In es, this message translates to:
  /// **'Llevas {days} días. Hoy también cuenta.'**
  String notificationStreakBody(int days);

  /// No description provided for @notificationNudgeTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía hay tiempo'**
  String get notificationNudgeTitle;

  /// No description provided for @notificationNudgeBody1.
  ///
  /// In es, this message translates to:
  /// **'Dos minutos alcanzan para no soltar el día.'**
  String get notificationNudgeBody1;

  /// No description provided for @notificationNudgeBody2.
  ///
  /// In es, this message translates to:
  /// **'Si hoy se llenó, quédate con un par de páginas.'**
  String get notificationNudgeBody2;

  /// No description provided for @notificationNudgeBody3.
  ///
  /// In es, this message translates to:
  /// **'No hace falta cumplir la meta. Abrir el libro ya cuenta.'**
  String get notificationNudgeBody3;

  /// No description provided for @notificationNudgeBody4.
  ///
  /// In es, this message translates to:
  /// **'Un momento corto también sostiene el hábito.'**
  String get notificationNudgeBody4;

  /// No description provided for @notificationNudgeBody5.
  ///
  /// In es, this message translates to:
  /// **'El día todavía tiene sitio para unas líneas.'**
  String get notificationNudgeBody5;

  /// No description provided for @focusMode.
  ///
  /// In es, this message translates to:
  /// **'Modo concentración'**
  String get focusMode;

  /// No description provided for @focusModeAndroidBody.
  ///
  /// In es, this message translates to:
  /// **'Silencia notificaciones y llamadas mientras Liora está abierta. Las alarmas siguen sonando.'**
  String get focusModeAndroidBody;

  /// No description provided for @focusModeIosBody.
  ///
  /// In es, this message translates to:
  /// **'Al abrir Liora, el iPhone entra en No molestar si preparas Atajos una vez.'**
  String get focusModeIosBody;

  /// No description provided for @focusModeIosOnBody.
  ///
  /// In es, this message translates to:
  /// **'Activo. Para quitarlo del todo, borra la automatización en Atajos.'**
  String get focusModeIosOnBody;

  /// No description provided for @focusModePermissionNeeded.
  ///
  /// In es, this message translates to:
  /// **'Para silenciar el teléfono, permite a Liora el acceso a No molestar.'**
  String get focusModePermissionNeeded;

  /// No description provided for @focusModeChangeFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cambiar No molestar.'**
  String get focusModeChangeFailed;

  /// No description provided for @focusModeIosRemains.
  ///
  /// In es, this message translates to:
  /// **'La automatización de Atajos sigue hasta que la borres.'**
  String get focusModeIosRemains;

  /// No description provided for @focusGuideTitle.
  ///
  /// In es, this message translates to:
  /// **'No molestar al leer'**
  String get focusGuideTitle;

  /// No description provided for @focusGuideBody.
  ///
  /// In es, this message translates to:
  /// **'iOS no deja que una app encienda No molestar. Atajos sí, si lo dejas preparado una vez.'**
  String get focusGuideBody;

  /// No description provided for @focusGuideOpenHeading.
  ///
  /// In es, this message translates to:
  /// **'Al abrir Liora'**
  String get focusGuideOpenHeading;

  /// No description provided for @focusGuideOpenSteps.
  ///
  /// In es, this message translates to:
  /// **'1. En Atajos, entra en Automatización y pulsa +.\n2. Elige App, luego Liora, y deja marcada la opción de al abrirla.\n3. Añade Definir concentración, elige No molestar y ponlo en Activado.\n4. Desactiva Preguntar antes de ejecutar.'**
  String get focusGuideOpenSteps;

  /// No description provided for @focusGuideCloseHeading.
  ///
  /// In es, this message translates to:
  /// **'Al cerrar Liora'**
  String get focusGuideCloseHeading;

  /// No description provided for @focusGuideCloseSteps.
  ///
  /// In es, this message translates to:
  /// **'Repite los pasos con la opción de al cerrarla y No molestar en Desactivado.'**
  String get focusGuideCloseSteps;

  /// No description provided for @focusGuideOpenShortcuts.
  ///
  /// In es, this message translates to:
  /// **'Abrir Atajos'**
  String get focusGuideOpenShortcuts;

  /// No description provided for @focusGuideDone.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get focusGuideDone;

  /// No description provided for @focusGuideNotNow.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get focusGuideNotNow;

  /// No description provided for @focusGuideOpenFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir Atajos.'**
  String get focusGuideOpenFailed;

  /// No description provided for @createQuoteImage.
  ///
  /// In es, this message translates to:
  /// **'Crear imagen'**
  String get createQuoteImage;

  /// No description provided for @quoteImageTitle.
  ///
  /// In es, this message translates to:
  /// **'Imagen'**
  String get quoteImageTitle;

  /// No description provided for @saveToPhotos.
  ///
  /// In es, this message translates to:
  /// **'Guardar en fotos'**
  String get saveToPhotos;

  /// No description provided for @quoteImageSaved.
  ///
  /// In es, this message translates to:
  /// **'Imagen guardada en fotos'**
  String get quoteImageSaved;

  /// No description provided for @quoteImageSaveFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar la imagen.'**
  String get quoteImageSaveFailed;

  /// No description provided for @quoteImageShareFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo compartir la imagen.'**
  String get quoteImageShareFailed;

  /// No description provided for @quoteImageTooLong.
  ///
  /// In es, this message translates to:
  /// **'Este pasaje es demasiado largo para este formato.'**
  String get quoteImageTooLong;

  /// No description provided for @quoteImageImportFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo usar esa imagen.'**
  String get quoteImageImportFailed;

  /// No description provided for @quoteImageTooLarge.
  ///
  /// In es, this message translates to:
  /// **'Esa imagen pesa demasiado.'**
  String get quoteImageTooLarge;

  /// No description provided for @quoteBackgroundFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir el fondo.'**
  String get quoteBackgroundFailed;

  /// No description provided for @quoteImageMissing.
  ///
  /// In es, this message translates to:
  /// **'Esta cita ya no está.'**
  String get quoteImageMissing;

  /// No description provided for @removeQuoteBackground.
  ///
  /// In es, this message translates to:
  /// **'¿Quitar este fondo?'**
  String get removeQuoteBackground;

  /// No description provided for @removeQuoteBackgroundBody.
  ///
  /// In es, this message translates to:
  /// **'Se borra la copia guardada en este dispositivo.'**
  String get removeQuoteBackgroundBody;

  /// No description provided for @importQuoteBackground.
  ///
  /// In es, this message translates to:
  /// **'Importar fondo'**
  String get importQuoteBackground;

  /// No description provided for @removeImportedBackground.
  ///
  /// In es, this message translates to:
  /// **'Quitar fondo'**
  String get removeImportedBackground;

  /// No description provided for @quoteFormatStory.
  ///
  /// In es, this message translates to:
  /// **'Historia'**
  String get quoteFormatStory;

  /// No description provided for @quoteFormatPost.
  ///
  /// In es, this message translates to:
  /// **'Publicación'**
  String get quoteFormatPost;

  /// No description provided for @quoteFormatSquare.
  ///
  /// In es, this message translates to:
  /// **'Cuadrada'**
  String get quoteFormatSquare;

  /// No description provided for @quoteFormatScreen.
  ///
  /// In es, this message translates to:
  /// **'Pantalla'**
  String get quoteFormatScreen;

  /// No description provided for @quoteFontSerif.
  ///
  /// In es, this message translates to:
  /// **'Serif'**
  String get quoteFontSerif;

  /// No description provided for @quoteFontCondensed.
  ///
  /// In es, this message translates to:
  /// **'Condensada'**
  String get quoteFontCondensed;

  /// No description provided for @quoteFontPlain.
  ///
  /// In es, this message translates to:
  /// **'Texto'**
  String get quoteFontPlain;

  /// No description provided for @quoteTextSize.
  ///
  /// In es, this message translates to:
  /// **'Tamaño'**
  String get quoteTextSize;

  /// No description provided for @quoteVeil.
  ///
  /// In es, this message translates to:
  /// **'Velo'**
  String get quoteVeil;

  /// No description provided for @quoteInkPaper.
  ///
  /// In es, this message translates to:
  /// **'Papel'**
  String get quoteInkPaper;

  /// No description provided for @quoteInkWhite.
  ///
  /// In es, this message translates to:
  /// **'Blanco'**
  String get quoteInkWhite;

  /// No description provided for @quoteInkCream.
  ///
  /// In es, this message translates to:
  /// **'Crema'**
  String get quoteInkCream;

  /// No description provided for @quoteInkInk.
  ///
  /// In es, this message translates to:
  /// **'Tinta'**
  String get quoteInkInk;

  /// No description provided for @quoteInkBlack.
  ///
  /// In es, this message translates to:
  /// **'Negro'**
  String get quoteInkBlack;

  /// No description provided for @quoteInkStation.
  ///
  /// In es, this message translates to:
  /// **'Azul'**
  String get quoteInkStation;

  /// No description provided for @quoteHighlightColor.
  ///
  /// In es, this message translates to:
  /// **'Color del resaltado'**
  String get quoteHighlightColor;

  /// No description provided for @quoteHighlightAmber.
  ///
  /// In es, this message translates to:
  /// **'Ámbar'**
  String get quoteHighlightAmber;

  /// No description provided for @quoteHighlightGreen.
  ///
  /// In es, this message translates to:
  /// **'Verde'**
  String get quoteHighlightGreen;

  /// No description provided for @quoteHighlightBlue.
  ///
  /// In es, this message translates to:
  /// **'Azul'**
  String get quoteHighlightBlue;

  /// No description provided for @quoteHighlightRose.
  ///
  /// In es, this message translates to:
  /// **'Rosa'**
  String get quoteHighlightRose;

  /// No description provided for @quoteHighlightViolet.
  ///
  /// In es, this message translates to:
  /// **'Violeta'**
  String get quoteHighlightViolet;

  /// No description provided for @quoteHighlightFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cambiar el color.'**
  String get quoteHighlightFailed;

  /// No description provided for @quoteHighlightDefault.
  ///
  /// In es, this message translates to:
  /// **'Color de las citas'**
  String get quoteHighlightDefault;

  /// No description provided for @quoteHighlightDefaultSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Para las citas que guardes desde ahora.'**
  String get quoteHighlightDefaultSubtitle;

  /// No description provided for @deleteQuote.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cita'**
  String get deleteQuote;

  /// No description provided for @deleteQuoteTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar esta cita?'**
  String get deleteQuoteTitle;

  /// No description provided for @deleteQuoteBody.
  ///
  /// In es, this message translates to:
  /// **'Sale de tus citas y deja de estar resaltada en el libro.'**
  String get deleteQuoteBody;

  /// No description provided for @quoteDeleted.
  ///
  /// In es, this message translates to:
  /// **'Cita eliminada.'**
  String get quoteDeleted;

  /// No description provided for @quoteDeleteFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar la cita.'**
  String get quoteDeleteFailed;

  /// No description provided for @chapterMinuteLeft.
  ///
  /// In es, this message translates to:
  /// **'Un minuto de capítulo'**
  String get chapterMinuteLeft;

  /// No description provided for @chapterMinutesLeft.
  ///
  /// In es, this message translates to:
  /// **'Unos {minutes} min de capítulo'**
  String chapterMinutesLeft(int minutes);

  /// No description provided for @chapterFinishTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Sigues un poco más?'**
  String get chapterFinishTitle;

  /// No description provided for @chapterMinuteAlmostDone.
  ///
  /// In es, this message translates to:
  /// **'Te falta un minuto para acabar el capítulo.'**
  String get chapterMinuteAlmostDone;

  /// No description provided for @chapterMinutesAlmostDone.
  ///
  /// In es, this message translates to:
  /// **'Te faltan unos {minutes} min para acabar el capítulo.'**
  String chapterMinutesAlmostDone(int minutes);

  /// No description provided for @chapterMinuteAlmostDoneNamed.
  ///
  /// In es, this message translates to:
  /// **'Te falta un minuto para acabar «{title}».'**
  String chapterMinuteAlmostDoneNamed(String title);

  /// No description provided for @chapterMinutesAlmostDoneNamed.
  ///
  /// In es, this message translates to:
  /// **'Te faltan unos {minutes} min para acabar «{title}».'**
  String chapterMinutesAlmostDoneNamed(int minutes, String title);

  /// No description provided for @keepReading.
  ///
  /// In es, this message translates to:
  /// **'Seguir leyendo'**
  String get keepReading;

  /// No description provided for @leaveReader.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get leaveReader;

  /// No description provided for @tableView.
  ///
  /// In es, this message translates to:
  /// **'Tabla'**
  String get tableView;

  /// No description provided for @bookTimeLeft.
  ///
  /// In es, this message translates to:
  /// **'Faltan ~{duration}'**
  String bookTimeLeft(String duration);

  /// No description provided for @bookPacePerTen.
  ///
  /// In es, this message translates to:
  /// **'~{duration} por cada 10 %'**
  String bookPacePerTen(String duration);

  /// No description provided for @bookUnderAWeek.
  ///
  /// In es, this message translates to:
  /// **'A este ritmo, menos de una semana'**
  String get bookUnderAWeek;

  /// No description provided for @bookWeekLeft.
  ///
  /// In es, this message translates to:
  /// **'A este ritmo, una semana'**
  String get bookWeekLeft;

  /// No description provided for @bookWeeksLeft.
  ///
  /// In es, this message translates to:
  /// **'A este ritmo, unas {count} semanas'**
  String bookWeeksLeft(int count);

  /// No description provided for @bookSittingLeft.
  ///
  /// In es, this message translates to:
  /// **'Una lectura como las últimas'**
  String get bookSittingLeft;

  /// No description provided for @readingByBook.
  ///
  /// In es, this message translates to:
  /// **'Por libro'**
  String get readingByBook;

  /// No description provided for @allReadingBooks.
  ///
  /// In es, this message translates to:
  /// **'Todos los libros'**
  String get allReadingBooks;

  /// No description provided for @readingByBookEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay un libro con tiempo de lectura.'**
  String get readingByBookEmpty;

  /// No description provided for @bookSittingsLeft.
  ///
  /// In es, this message translates to:
  /// **'Unas {count} lecturas como las últimas'**
  String bookSittingsLeft(int count);

  /// No description provided for @bookSession.
  ///
  /// In es, this message translates to:
  /// **'1 sesión'**
  String get bookSession;

  /// No description provided for @bookSessions.
  ///
  /// In es, this message translates to:
  /// **'{count} sesiones'**
  String bookSessions(int count);

  /// No description provided for @bookQuote.
  ///
  /// In es, this message translates to:
  /// **'1 cita'**
  String get bookQuote;

  /// No description provided for @bookQuotes.
  ///
  /// In es, this message translates to:
  /// **'{count} citas'**
  String bookQuotes(int count);

  /// No description provided for @monthReading.
  ///
  /// In es, this message translates to:
  /// **'Resumen del mes'**
  String get monthReading;

  /// No description provided for @monthReadingOf.
  ///
  /// In es, this message translates to:
  /// **'Resumen de {month}'**
  String monthReadingOf(String month);

  /// No description provided for @monthReadingEmpty.
  ///
  /// In es, this message translates to:
  /// **'El resumen aparece al cerrar un mes con lectura.'**
  String get monthReadingEmpty;

  /// No description provided for @monthInProgress.
  ///
  /// In es, this message translates to:
  /// **'En curso'**
  String get monthInProgress;

  /// No description provided for @monthPlanDays.
  ///
  /// In es, this message translates to:
  /// **'En {month} cumpliste {met} de {planned} días de tu plan.'**
  String monthPlanDays(String month, int met, int planned);

  /// No description provided for @monthReadTime.
  ///
  /// In es, this message translates to:
  /// **'En {month} leíste {duration}.'**
  String monthReadTime(String month, String duration);

  /// No description provided for @monthMinutesMore.
  ///
  /// In es, this message translates to:
  /// **'{duration} más que en {month}'**
  String monthMinutesMore(String duration, String month);

  /// No description provided for @monthMinutesLess.
  ///
  /// In es, this message translates to:
  /// **'{duration} menos que en {month}'**
  String monthMinutesLess(String duration, String month);

  /// No description provided for @monthBookFinished.
  ///
  /// In es, this message translates to:
  /// **'Terminaste este libro.'**
  String get monthBookFinished;

  /// No description provided for @monthShareFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo compartir el resumen.'**
  String get monthShareFailed;

  /// No description provided for @monthMethodical.
  ///
  /// In es, this message translates to:
  /// **'Lector metódico'**
  String get monthMethodical;

  /// No description provided for @monthMethodicalPhrase.
  ///
  /// In es, this message translates to:
  /// **'La constancia ya forma parte de ti.'**
  String get monthMethodicalPhrase;

  /// No description provided for @monthMethodicalEvidence.
  ///
  /// In es, this message translates to:
  /// **'{onTime} de {sessions} lecturas empezaron cerca de las {hour}.'**
  String monthMethodicalEvidence(int onTime, int sessions, String hour);

  /// No description provided for @monthAnt.
  ///
  /// In es, this message translates to:
  /// **'Lector hormiga'**
  String get monthAnt;

  /// No description provided for @monthAntPhrase.
  ///
  /// In es, this message translates to:
  /// **'Aprovechas cada momento. Paso a paso construyes grandes lecturas.'**
  String get monthAntPhrase;

  /// No description provided for @monthAntEvidence.
  ///
  /// In es, this message translates to:
  /// **'Cumpliste {met} de {planned} días, en lecturas de 15 min o menos.'**
  String monthAntEvidence(int met, int planned);

  /// No description provided for @monthMarathoner.
  ///
  /// In es, this message translates to:
  /// **'El maratonista'**
  String get monthMarathoner;

  /// No description provided for @monthMarathonerPhrase.
  ///
  /// In es, this message translates to:
  /// **'Cuando te sumerges en una historia, el tiempo pierde su forma.'**
  String get monthMarathonerPhrase;

  /// No description provided for @monthMarathonerEvidence.
  ///
  /// In es, this message translates to:
  /// **'Los días que leíste, promedias {duration}.'**
  String monthMarathonerEvidence(String duration);

  /// No description provided for @monthHunter.
  ///
  /// In es, this message translates to:
  /// **'Cazador de ideas'**
  String get monthHunter;

  /// No description provided for @monthHunterPhrase.
  ///
  /// In es, this message translates to:
  /// **'No solo lees: coleccionas pensamientos y los haces tuyos.'**
  String get monthHunterPhrase;

  /// No description provided for @monthHunterEvidence.
  ///
  /// In es, this message translates to:
  /// **'Guardaste citas en {withQuotes} de {sessions} lecturas.'**
  String monthHunterEvidence(int withQuotes, int sessions);

  /// No description provided for @monthEarly.
  ///
  /// In es, this message translates to:
  /// **'El madrugador'**
  String get monthEarly;

  /// No description provided for @monthEarlyPhrase.
  ///
  /// In es, this message translates to:
  /// **'Inicias el día alimentando tu mente antes de que empiece la rutina.'**
  String get monthEarlyPhrase;

  /// No description provided for @monthAfternoon.
  ///
  /// In es, this message translates to:
  /// **'Lector de sobremesa'**
  String get monthAfternoon;

  /// No description provided for @monthAfternoonPhrase.
  ///
  /// In es, this message translates to:
  /// **'Haces una pausa en mitad del día y la llenas de páginas.'**
  String get monthAfternoonPhrase;

  /// No description provided for @monthNight.
  ///
  /// In es, this message translates to:
  /// **'El búho nocturno'**
  String get monthNight;

  /// No description provided for @monthNightPhrase.
  ///
  /// In es, this message translates to:
  /// **'Encuentras la calma y la concentración cuando el mundo se apaga.'**
  String get monthNightPhrase;

  /// No description provided for @monthBandEvidence.
  ///
  /// In es, this message translates to:
  /// **'El {percent} % de tu lectura fue en esa franja.'**
  String monthBandEvidence(int percent);

  /// No description provided for @monthNomad.
  ///
  /// In es, this message translates to:
  /// **'Lector nómada'**
  String get monthNomad;

  /// No description provided for @monthNomadPhrase.
  ///
  /// In es, this message translates to:
  /// **'Cualquier momento es bueno para abrir un libro.'**
  String get monthNomadPhrase;

  /// No description provided for @monthNomadEvidence.
  ///
  /// In es, this message translates to:
  /// **'Ninguna franja llega al 60 %.'**
  String get monthNomadEvidence;

  /// No description provided for @appearance.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get appearance;

  /// No description provided for @themePrograma.
  ///
  /// In es, this message translates to:
  /// **'Programa'**
  String get themePrograma;

  /// No description provided for @themeLibro.
  ///
  /// In es, this message translates to:
  /// **'Libro'**
  String get themeLibro;

  /// No description provided for @themeCuaderno.
  ///
  /// In es, this message translates to:
  /// **'Cuaderno'**
  String get themeCuaderno;

  /// No description provided for @themePeriodico.
  ///
  /// In es, this message translates to:
  /// **'Periódico'**
  String get themePeriodico;

  /// No description provided for @themeFicha.
  ///
  /// In es, this message translates to:
  /// **'Ficha'**
  String get themeFicha;

  /// No description provided for @themeChangeFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cambiar la apariencia.'**
  String get themeChangeFailed;

  /// No description provided for @appFont.
  ///
  /// In es, this message translates to:
  /// **'Fuente'**
  String get appFont;

  /// No description provided for @fontSystem.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get fontSystem;

  /// No description provided for @fontSourceSans.
  ///
  /// In es, this message translates to:
  /// **'Source Sans'**
  String get fontSourceSans;

  /// No description provided for @fontLibreFranklin.
  ///
  /// In es, this message translates to:
  /// **'Libre Franklin'**
  String get fontLibreFranklin;

  /// No description provided for @fontSourceSerif.
  ///
  /// In es, this message translates to:
  /// **'Source Serif'**
  String get fontSourceSerif;

  /// No description provided for @fontNewsreader.
  ///
  /// In es, this message translates to:
  /// **'Newsreader'**
  String get fontNewsreader;

  /// No description provided for @fontChangeFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cambiar la fuente.'**
  String get fontChangeFailed;

  /// No description provided for @appearanceRestore.
  ///
  /// In es, this message translates to:
  /// **'Restaurar'**
  String get appearanceRestore;

  /// No description provided for @appearanceRestoreFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo restaurar la apariencia.'**
  String get appearanceRestoreFailed;

  /// No description provided for @pqrs.
  ///
  /// In es, this message translates to:
  /// **'Ayuda'**
  String get pqrs;

  /// No description provided for @pqrsMessageCount.
  ///
  /// In es, this message translates to:
  /// **'{count} / {limit}'**
  String pqrsMessageCount(int count, int limit);

  /// No description provided for @pqrsIntro.
  ///
  /// In es, this message translates to:
  /// **'Peticiones, quejas, reclamos y sugerencias sobre Liora.'**
  String get pqrsIntro;

  /// No description provided for @pqrsQuestions.
  ///
  /// In es, this message translates to:
  /// **'Preguntas frecuentes'**
  String get pqrsQuestions;

  /// No description provided for @pqrsWrite.
  ///
  /// In es, this message translates to:
  /// **'Escribir'**
  String get pqrsWrite;

  /// No description provided for @pqrsKindPetition.
  ///
  /// In es, this message translates to:
  /// **'Petición'**
  String get pqrsKindPetition;

  /// No description provided for @pqrsKindComplaint.
  ///
  /// In es, this message translates to:
  /// **'Queja'**
  String get pqrsKindComplaint;

  /// No description provided for @pqrsKindClaim.
  ///
  /// In es, this message translates to:
  /// **'Reclamo'**
  String get pqrsKindClaim;

  /// No description provided for @pqrsKindSuggestion.
  ///
  /// In es, this message translates to:
  /// **'Sugerencia'**
  String get pqrsKindSuggestion;

  /// No description provided for @pqrsKindRequired.
  ///
  /// In es, this message translates to:
  /// **'Elige petición, queja, reclamo o sugerencia.'**
  String get pqrsKindRequired;

  /// No description provided for @pqrsMessage.
  ///
  /// In es, this message translates to:
  /// **'Mensaje'**
  String get pqrsMessage;

  /// No description provided for @pqrsMessageHint.
  ///
  /// In es, this message translates to:
  /// **'Qué pasó, o qué te gustaría.'**
  String get pqrsMessageHint;

  /// No description provided for @pqrsMessageRequired.
  ///
  /// In es, this message translates to:
  /// **'Escribe el mensaje.'**
  String get pqrsMessageRequired;

  /// No description provided for @pqrsMessageTooLong.
  ///
  /// In es, this message translates to:
  /// **'El mensaje es demasiado largo.'**
  String get pqrsMessageTooLong;

  /// No description provided for @pqrsEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get pqrsEmail;

  /// No description provided for @pqrsEmailHint.
  ///
  /// In es, this message translates to:
  /// **'Opcional, si quieres una respuesta'**
  String get pqrsEmailHint;

  /// No description provided for @pqrsEmailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ese correo no es válido.'**
  String get pqrsEmailInvalid;

  /// No description provided for @pqrsSend.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get pqrsSend;

  /// No description provided for @pqrsSending.
  ///
  /// In es, this message translates to:
  /// **'Enviando'**
  String get pqrsSending;

  /// No description provided for @pqrsSendFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar. Inténtalo de nuevo.'**
  String get pqrsSendFailed;

  /// No description provided for @pqrsHeldTitle.
  ///
  /// In es, this message translates to:
  /// **'Enviada'**
  String get pqrsHeldTitle;

  /// No description provided for @pqrsHeldBody.
  ///
  /// In es, this message translates to:
  /// **'Recibimos tu {kind}.'**
  String pqrsHeldBody(String kind);

  /// No description provided for @pqrsAnother.
  ///
  /// In es, this message translates to:
  /// **'Escribir otra'**
  String get pqrsAnother;

  /// No description provided for @pqrsFaqAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Necesito una cuenta?'**
  String get pqrsFaqAccount;

  /// No description provided for @pqrsFaqAccountAnswer.
  ///
  /// In es, this message translates to:
  /// **'No. Tus libros y tu progreso se guardan en este dispositivo.'**
  String get pqrsFaqAccountAnswer;

  /// No description provided for @pqrsFaqAdd.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo añado un libro?'**
  String get pqrsFaqAdd;

  /// No description provided for @pqrsFaqAddAnswer.
  ///
  /// In es, this message translates to:
  /// **'En Biblioteca, Importar abre un EPUB de este dispositivo. En Descubrimiento puedes bajar uno del catálogo.'**
  String get pqrsFaqAddAnswer;

  /// No description provided for @pqrsFaqOffline.
  ///
  /// In es, this message translates to:
  /// **'¿Puedo leer sin internet?'**
  String get pqrsFaqOffline;

  /// No description provided for @pqrsFaqOfflineAnswer.
  ///
  /// In es, this message translates to:
  /// **'Un libro que ya está en la biblioteca se abre sin conexión. El catálogo necesita red para cargar y para descargar.'**
  String get pqrsFaqOfflineAnswer;

  /// No description provided for @pqrsFaqHabit.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo cambio la meta o la hora?'**
  String get pqrsFaqHabit;

  /// No description provided for @pqrsFaqHabitAnswer.
  ///
  /// In es, this message translates to:
  /// **'En Perfil, Hábito de lectura.'**
  String get pqrsFaqHabitAnswer;

  /// No description provided for @pqrsFaqTime.
  ///
  /// In es, this message translates to:
  /// **'¿Dónde veo cuánto he leído?'**
  String get pqrsFaqTime;

  /// No description provided for @pqrsFaqTimeAnswer.
  ///
  /// In es, this message translates to:
  /// **'En Tiempo están la semana y el calendario.'**
  String get pqrsFaqTimeAnswer;

  /// No description provided for @pqrsFaqReader.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo cambio el tamaño o el modo?'**
  String get pqrsFaqReader;

  /// No description provided for @pqrsFaqReaderAnswer.
  ///
  /// In es, this message translates to:
  /// **'Dentro del libro: texto más grande o más pequeño, modo claro u oscuro, y páginas o scroll.'**
  String get pqrsFaqReaderAnswer;

  /// No description provided for @pqrsFaqDelete.
  ///
  /// In es, this message translates to:
  /// **'¿Qué pasa si elimino un libro?'**
  String get pqrsFaqDelete;

  /// No description provided for @pqrsFaqDeleteAnswer.
  ///
  /// In es, this message translates to:
  /// **'Sale de la biblioteca de este dispositivo, con su progreso y sus citas.'**
  String get pqrsFaqDeleteAnswer;

  /// No description provided for @privacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Privacidad'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In es, this message translates to:
  /// **'Términos'**
  String get termsOfUse;

  /// No description provided for @legalPageFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir la página.'**
  String get legalPageFailed;

  /// No description provided for @premiumTitle.
  ///
  /// In es, this message translates to:
  /// **'Premium'**
  String get premiumTitle;

  /// No description provided for @premiumLead.
  ///
  /// In es, this message translates to:
  /// **'Un pago abre las tres.'**
  String get premiumLead;

  /// No description provided for @premiumPrice.
  ///
  /// In es, this message translates to:
  /// **'7 USD'**
  String get premiumPrice;

  /// No description provided for @premiumMonthBody.
  ///
  /// In es, this message translates to:
  /// **'El mes que cerraste: los días del plan, el tiempo y los libros.'**
  String get premiumMonthBody;

  /// No description provided for @premiumBooksBody.
  ///
  /// In es, this message translates to:
  /// **'El tiempo de cada libro, aparte de la semana y el calendario.'**
  String get premiumBooksBody;

  /// No description provided for @premiumAppearanceBody.
  ///
  /// In es, this message translates to:
  /// **'El papel, la tinta y la letra con la que se lee Liora.'**
  String get premiumAppearanceBody;

  /// No description provided for @premiumUnlock.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear · 7 USD'**
  String get premiumUnlock;

  /// No description provided for @premiumPurchaseUnavailable.
  ///
  /// In es, this message translates to:
  /// **'La compra no está disponible todavía.'**
  String get premiumPurchaseUnavailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
