// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get discover => 'Discover';

  @override
  String get library => 'Library';

  @override
  String get time => 'Time';

  @override
  String get profile => 'Profile';

  @override
  String get noBooksYet => 'No books yet';

  @override
  String get epubOnDevice => 'An EPUB from this device';

  @override
  String get import => 'Import';

  @override
  String get importing => 'Importing';

  @override
  String get importEpub => 'Import EPUB';

  @override
  String get read => 'Read';

  @override
  String get notStarted => 'Not started';

  @override
  String get delete => 'Delete';

  @override
  String get deleteBook => 'Delete book';

  @override
  String removeBook(String title) {
    return 'Remove “$title” from the library?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get alreadyInLibrary => 'This book is already in the library.';

  @override
  String get importFailed => 'The EPUB could not be imported.';

  @override
  String get deleteFailed => 'The book could not be deleted.';

  @override
  String get addFailed => 'The book could not be added to the library.';

  @override
  String get untitled => 'Untitled';

  @override
  String get notAnEpub => 'The file is not a valid EPUB.';

  @override
  String get epubMissingRoot => 'The EPUB does not name its content file.';

  @override
  String get epubMissingContent => 'The EPUB content was not found.';

  @override
  String get toAdd => 'To add';

  @override
  String get inYourLibrary => 'In your library';

  @override
  String get add => 'Add';

  @override
  String get allLanguages => 'All';

  @override
  String get spanish => 'Spanish';

  @override
  String get english => 'English';

  @override
  String get catalogEmpty => 'The catalog is empty';

  @override
  String get catalogEmptyBody =>
      'Books will show up here when some are available.';

  @override
  String get retry => 'Retry';

  @override
  String get catalogLoadFailed => 'The catalog could not be loaded.';

  @override
  String catalogLoadFailedStatus(int status) {
    return 'The catalog could not be loaded ($status).';
  }

  @override
  String get catalogInvalid => 'The catalog is not in the expected format.';

  @override
  String get missingDownload => 'This book has no download link.';

  @override
  String downloadFailed(int status) {
    return 'The book could not be downloaded ($status).';
  }

  @override
  String get missingApiKey => 'X_EPUB_KEY is missing from .env.';

  @override
  String get contents => 'Contents';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get noContents => 'This book has no table of contents.';

  @override
  String get copy => 'Copy';

  @override
  String get share => 'Share';

  @override
  String get bookGone => 'This book is no longer in the library.';

  @override
  String get chapterFailed => 'This chapter could not be opened.';

  @override
  String get preferencesFailed => 'The reading settings could not be applied.';

  @override
  String get preferencesSaveFailed =>
      'The reading settings could not be saved.';

  @override
  String get fixedColor => 'Text color does not change in a fixed-layout book.';

  @override
  String get fixedPages => 'This book is read page by page.';

  @override
  String get fixedSize => 'Text size does not change in a fixed-layout book.';

  @override
  String get fixedColorShort => 'Text color does not change in this book';

  @override
  String get fixedPagesShort => 'This book is read page by page';

  @override
  String get fixedSizeShort => 'Text size does not change in this book';

  @override
  String get pageMode => 'Page reading';

  @override
  String get scrollMode => 'Scroll reading';

  @override
  String get lightMode => 'Light mode';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get smallerText => 'Smaller text';

  @override
  String get originalSize => 'Original size';

  @override
  String get largerText => 'Larger text';

  @override
  String get readerDesktopOnly =>
      'The reader works on iOS and Android. On the macOS desktop, Readium does not open the EPUB.';

  @override
  String get openFailed => 'The book could not be opened.';

  @override
  String get invalidBook => 'Invalid book.';

  @override
  String get welcomeTitle => 'Build a reading habit';

  @override
  String get welcomeBody =>
      'A place to read a little every day and keep that habit going.';

  @override
  String get welcomeAccount =>
      'No account. Your books and progress stay on this device.';

  @override
  String stepOf(int step, int total) {
    return '$step of $total';
  }

  @override
  String get start => 'Start';

  @override
  String get startReading => 'I want to start reading';

  @override
  String get next => 'Next';

  @override
  String get answersSaveFailed => 'Your answers could not be saved.';

  @override
  String profileLoadFailed(String error) {
    return 'The profile could not be loaded.\n$error';
  }

  @override
  String get motivationQuestion => 'What do you want from reading?';

  @override
  String get goalQuestion => 'How much do you want to read?';

  @override
  String get whenQuestion => 'When would you like to read?';

  @override
  String get whichDays => 'Which days?';

  @override
  String get whatTime => 'What time?';

  @override
  String minutes(int count) {
    return '$count minutes';
  }

  @override
  String get motivationReadMore => 'Read more';

  @override
  String get motivationHabit => 'Build a habit';

  @override
  String get motivationFinishBooks => 'Finish more books';

  @override
  String get motivationLearn => 'Learn new things';

  @override
  String get motivationTimeForMe => 'Have a moment for myself';

  @override
  String get routineMorning => 'Morning';

  @override
  String get routineAfternoon => 'Afternoon';

  @override
  String get routineNight => 'Night';

  @override
  String get mondayLetter => 'M';

  @override
  String get tuesdayLetter => 'T';

  @override
  String get wednesdayLetter => 'W';

  @override
  String get thursdayLetter => 'T';

  @override
  String get fridayLetter => 'F';

  @override
  String get saturdayLetter => 'S';

  @override
  String get sundayLetter => 'S';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get notSet => 'Not set';

  @override
  String get readingHabit => 'Reading habit';

  @override
  String get sampleReadings => 'Generate sample readings';

  @override
  String get sampleReadingsSubtitle =>
      'From today, a month and a half back, 0 to 15 minutes.';

  @override
  String get sampleReadingsBody =>
      'A random reading will be added for each day, from today back a month and a half. Each one lasts between 0 and 15 minutes.';

  @override
  String get generate => 'Generate';

  @override
  String sampleReadingsAdded(int count) {
    return '$count sample readings were added.';
  }

  @override
  String get sampleReadingsFailed => 'The readings could not be generated.';

  @override
  String get thisWeek => 'This week';

  @override
  String goalLine(String duration) {
    return 'Goal · $duration';
  }

  @override
  String get noRecords => 'No records yet';

  @override
  String get noRecordsBody =>
      'Time is saved once a reading lasts more than 30 seconds.';

  @override
  String booksLoadFailed(String error) {
    return 'The books could not be loaded.\n$error';
  }

  @override
  String readingTimeLoadFailed(String error) {
    return 'Reading time could not be loaded.\n$error';
  }

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get today => 'Today';

  @override
  String get goalLabel => 'Goal';

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String minutesOfGoal(int done, int goal) {
    return '$done / $goal min';
  }

  @override
  String get yesterday => 'Yesterday';

  @override
  String get goalMet => 'goal met';

  @override
  String get partialReading => 'read, goal not met';

  @override
  String get noReading => 'no reading';

  @override
  String calendarDay(int day, String month, String state) {
    return '$month $day, $state';
  }

  @override
  String libraryLoadFailed(String error) {
    return 'The library could not be loaded.\n$error';
  }

  @override
  String get sampleBookTitle => 'Sample reading';

  @override
  String get notificationChannelName => 'Notices';

  @override
  String get notificationChannelDescription => 'Notices from Liora';
}
