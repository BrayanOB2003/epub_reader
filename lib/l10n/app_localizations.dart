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

  /// No description provided for @welcomeAccount.
  ///
  /// In es, this message translates to:
  /// **'Sin cuenta. Tus libros y tu progreso se guardan en este dispositivo.'**
  String get welcomeAccount;

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
  /// **'No se pudo cargar el perfil.\n{error}'**
  String profileLoadFailed(String error);

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

  /// No description provided for @sampleReadings.
  ///
  /// In es, this message translates to:
  /// **'Generar lecturas de ejemplo'**
  String get sampleReadings;

  /// No description provided for @sampleReadingsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Desde hoy, un mes y medio atrás, de 0 a 15 minutos.'**
  String get sampleReadingsSubtitle;

  /// No description provided for @sampleReadingsBody.
  ///
  /// In es, this message translates to:
  /// **'Se agregará una lectura al azar por cada día, desde hoy hasta un mes y medio atrás. Cada una dura entre 0 y 15 minutos.'**
  String get sampleReadingsBody;

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

  /// No description provided for @calendarDay.
  ///
  /// In es, this message translates to:
  /// **'{day} de {month}, {state}'**
  String calendarDay(int day, String month, String state);

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
