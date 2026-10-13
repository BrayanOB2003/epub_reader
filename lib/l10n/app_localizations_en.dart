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
  String get contentsKeepReading => 'You can keep turning pages.';

  @override
  String get contentsSearch => 'Search the contents';

  @override
  String get contentsNoMatches => 'No chapter matches.';

  @override
  String chapterLabel(int position) {
    return 'Chapter $position';
  }

  @override
  String chapterOpenFailed(String title) {
    return '“$title” could not be opened.';
  }

  @override
  String get showChapters => 'Show chapters';

  @override
  String get hideChapters => 'Hide chapters';

  @override
  String get copy => 'Copy';

  @override
  String get share => 'Share';

  @override
  String get copied => 'Copied';

  @override
  String get saveQuote => 'Save quote';

  @override
  String get quoteSaved => 'Quote saved';

  @override
  String get quoteSaveFailed => 'The quote could not be saved.';

  @override
  String get savedQuotes => 'Quotes';

  @override
  String get noQuotes => 'No quotes yet';

  @override
  String get noQuotesBody => 'Select a passage and tap Save quote.';

  @override
  String get quoteAlreadySaved => 'That quote is already saved.';

  @override
  String get shareQuoteText => 'Share text';

  @override
  String get quoteShareFailed => 'The quote could not be shared.';

  @override
  String quotesLoadFailed(String error) {
    return 'Quotes could not be loaded.\n$error';
  }

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
  String get notificationPermissionTitle => 'A reminder at your time';

  @override
  String get notificationPermissionBody =>
      'When the time you chose arrives, Liora can remind you to read.';

  @override
  String get notificationPermissionAllow => 'Turn on reminders';

  @override
  String get notificationPermissionSkip => 'Not now';

  @override
  String get notificationPermissionFailed =>
      'The permission request could not be shown.';

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
  String calendarDate(int day, String month) {
    return '$month $day';
  }

  @override
  String dayReading(String day, String duration) {
    return '$day · $duration';
  }

  @override
  String calendarDay(int day, String month, String duration, String state) {
    return '$month $day, $duration, $state';
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

  @override
  String get notificationRoutineTitle => 'Time to read';

  @override
  String notificationRoutineBody(String hour, int minutes) {
    return 'It\'s $hour. Today\'s goal is $minutes min.';
  }

  @override
  String get notificationGoalTitle => 'Today\'s goal';

  @override
  String notificationGoalRemainingBody(int minutes) {
    return '$minutes min left to close the day.';
  }

  @override
  String get notificationGoalMetTitle => 'Goal met';

  @override
  String notificationGoalMetBody(int minutes) {
    return 'You closed the day. $minutes min.';
  }

  @override
  String notificationResumeChapterBody(int chapter, String title) {
    return 'You\'re still on chapter $chapter of $title.';
  }

  @override
  String notificationResumeSectionBody(String section, String title) {
    return 'You\'re still in $section of $title.';
  }

  @override
  String notificationResumeBookBody(String title) {
    return 'You\'re still with $title.';
  }

  @override
  String get notificationStreakTitle => 'Your streak';

  @override
  String notificationStreakBody(int days) {
    return '$days days in a row. Today counts too.';
  }

  @override
  String get notificationNudgeTitle => 'There\'s still time';

  @override
  String get notificationNudgeBody1 =>
      'Two minutes are enough to keep the day.';

  @override
  String get notificationNudgeBody2 =>
      'If the day filled up, stay for a couple of pages.';

  @override
  String get notificationNudgeBody3 =>
      'You don\'t have to hit the goal. Opening the book counts.';

  @override
  String get notificationNudgeBody4 => 'A short moment still holds the habit.';

  @override
  String get notificationNudgeBody5 =>
      'The day still has room for a few lines.';

  @override
  String get focusMode => 'Focus mode';

  @override
  String get focusModeAndroidBody =>
      'Silences notifications and calls while Liora is open. Alarms still ring.';

  @override
  String get focusModeIosBody =>
      'When you open Liora, your iPhone can turn on Do Not Disturb once you set up Shortcuts.';

  @override
  String get focusModeIosOnBody =>
      'On. To remove it completely, delete the automation in Shortcuts.';

  @override
  String get focusModePermissionNeeded =>
      'To silence the phone, allow Liora access to Do Not Disturb.';

  @override
  String get focusModeChangeFailed => 'Do Not Disturb could not be changed.';

  @override
  String get focusModeIosRemains =>
      'The Shortcuts automation stays until you delete it.';

  @override
  String get focusGuideTitle => 'Do Not Disturb while you read';

  @override
  String get focusGuideBody =>
      'iOS does not let an app turn on Do Not Disturb. Shortcuts can, once you set it up.';

  @override
  String get focusGuideOpenHeading => 'When Liora opens';

  @override
  String get focusGuideOpenSteps =>
      '1. In Shortcuts, open Automation and tap +.\n2. Choose App, then Liora, and leave Is Opened selected.\n3. Add Set Focus, choose Do Not Disturb, and turn it On.\n4. Turn off Ask Before Running.';

  @override
  String get focusGuideCloseHeading => 'When Liora closes';

  @override
  String get focusGuideCloseSteps =>
      'Repeat the steps with Is Closed, and turn Do Not Disturb Off.';

  @override
  String get focusGuideOpenShortcuts => 'Open Shortcuts';

  @override
  String get focusGuideDone => 'Done';

  @override
  String get focusGuideNotNow => 'Not now';

  @override
  String get focusGuideOpenFailed => 'Shortcuts could not be opened.';

  @override
  String get createQuoteImage => 'Create image';

  @override
  String get quoteImageTitle => 'Image';

  @override
  String get saveToPhotos => 'Save to photos';

  @override
  String get quoteImageSaved => 'Image saved to photos';

  @override
  String get quoteImageSaveFailed => 'The image could not be saved.';

  @override
  String get quoteImageShareFailed => 'The image could not be shared.';

  @override
  String get quoteImageTooLong => 'This passage is too long for this format.';

  @override
  String get quoteImageImportFailed => 'That image could not be used.';

  @override
  String get quoteImageTooLarge => 'That image is too large.';

  @override
  String get quoteBackgroundFailed => 'The background could not be opened.';

  @override
  String get quoteImageMissing => 'This quote is no longer here.';

  @override
  String get removeQuoteBackground => 'Remove this background?';

  @override
  String get removeQuoteBackgroundBody =>
      'The copy stored on this device is deleted.';

  @override
  String get importQuoteBackground => 'Import background';

  @override
  String get removeImportedBackground => 'Remove background';

  @override
  String get quoteFormatStory => 'Story';

  @override
  String get quoteFormatPost => 'Post';

  @override
  String get quoteFormatSquare => 'Square';

  @override
  String get quoteFormatScreen => 'Screen';

  @override
  String get quoteFontSerif => 'Serif';

  @override
  String get quoteFontCondensed => 'Condensed';

  @override
  String get quoteFontPlain => 'Text';

  @override
  String get quoteTextSize => 'Size';

  @override
  String get quoteVeil => 'Veil';

  @override
  String get quoteInkPaper => 'Paper';

  @override
  String get quoteInkWhite => 'White';

  @override
  String get quoteInkCream => 'Cream';

  @override
  String get quoteInkInk => 'Ink';

  @override
  String get quoteInkBlack => 'Black';

  @override
  String get quoteInkStation => 'Blue';

  @override
  String get quoteHighlightColor => 'Highlight color';

  @override
  String get quoteHighlightAmber => 'Amber';

  @override
  String get quoteHighlightGreen => 'Green';

  @override
  String get quoteHighlightBlue => 'Blue';

  @override
  String get quoteHighlightRose => 'Rose';

  @override
  String get quoteHighlightViolet => 'Violet';

  @override
  String get quoteHighlightFailed => 'The color could not be changed.';

  @override
  String get quoteHighlightDefault => 'Quote color';

  @override
  String get quoteHighlightDefaultSubtitle =>
      'For the quotes you save from now on.';

  @override
  String get deleteQuote => 'Delete quote';

  @override
  String get deleteQuoteTitle => 'Delete this quote?';

  @override
  String get deleteQuoteBody =>
      'It leaves your quotes and is no longer highlighted in the book.';

  @override
  String get quoteDeleted => 'Quote deleted.';

  @override
  String get quoteDeleteFailed => 'The quote could not be deleted.';

  @override
  String get chapterMinuteLeft => 'A minute left in the chapter';

  @override
  String chapterMinutesLeft(int minutes) {
    return 'About $minutes min left in the chapter';
  }

  @override
  String get chapterFinishTitle => 'Keep going a little longer?';

  @override
  String get chapterMinuteAlmostDone => 'A minute left to finish the chapter.';

  @override
  String chapterMinutesAlmostDone(int minutes) {
    return 'About $minutes min left to finish the chapter.';
  }

  @override
  String chapterMinuteAlmostDoneNamed(String title) {
    return 'A minute left to finish “$title”.';
  }

  @override
  String chapterMinutesAlmostDoneNamed(int minutes, String title) {
    return 'About $minutes min left to finish “$title”.';
  }

  @override
  String get keepReading => 'Keep reading';

  @override
  String get leaveReader => 'Leave';

  @override
  String get tableView => 'Table';

  @override
  String bookTimeLeft(String duration) {
    return 'About $duration left';
  }

  @override
  String bookPacePerTen(String duration) {
    return '~$duration per 10%';
  }

  @override
  String get bookUnderAWeek => 'At this pace, less than a week';

  @override
  String get bookWeekLeft => 'At this pace, a week';

  @override
  String bookWeeksLeft(int count) {
    return 'At this pace, about $count weeks';
  }

  @override
  String get bookSittingLeft => 'One session like the recent ones';

  @override
  String get readingByBook => 'By book';

  @override
  String get allReadingBooks => 'All books';

  @override
  String get readingByBookEmpty => 'No book has reading time yet.';

  @override
  String bookSittingsLeft(int count) {
    return 'About $count sessions like the recent ones';
  }

  @override
  String get monthReading => 'Month in review';

  @override
  String monthReadingOf(String month) {
    return '$month in review';
  }

  @override
  String get monthReadingEmpty =>
      'The review appears when a month with reading comes to a close.';

  @override
  String get monthInProgress => 'In progress';

  @override
  String monthPlanDays(String month, int met, int planned) {
    return 'In $month you kept $met of $planned days in your plan.';
  }

  @override
  String monthReadTime(String month, String duration) {
    return 'In $month you read $duration.';
  }

  @override
  String monthMinutesMore(String duration, String month) {
    return '$duration more than in $month';
  }

  @override
  String monthMinutesLess(String duration, String month) {
    return '$duration less than in $month';
  }

  @override
  String get monthBookFinished => 'You finished this book.';

  @override
  String get monthShareFailed => 'The review could not be shared.';

  @override
  String get monthMethodical => 'Methodical reader';

  @override
  String get monthMethodicalPhrase => 'Steadiness is already part of you.';

  @override
  String monthMethodicalEvidence(int onTime, int sessions, String hour) {
    return '$onTime of $sessions readings started near $hour.';
  }

  @override
  String get monthAnt => 'Ant reader';

  @override
  String get monthAntPhrase =>
      'You use every moment. Step by step you build a long read.';

  @override
  String monthAntEvidence(int met, int planned) {
    return 'You kept $met of $planned days, in readings of 15 min or less.';
  }

  @override
  String get monthMarathoner => 'The marathoner';

  @override
  String get monthMarathonerPhrase =>
      'When you sink into a story, time loses its shape.';

  @override
  String monthMarathonerEvidence(String duration) {
    return 'On the days you read, you averaged $duration.';
  }

  @override
  String get monthHunter => 'Idea hunter';

  @override
  String get monthHunterPhrase =>
      'You don\'t only read: you collect thoughts and make them yours.';

  @override
  String monthHunterEvidence(int withQuotes, int sessions) {
    return 'You saved quotes in $withQuotes of $sessions readings.';
  }

  @override
  String get monthEarly => 'The early riser';

  @override
  String get monthEarlyPhrase =>
      'You start the day feeding your mind before the routine begins.';

  @override
  String get monthAfternoon => 'Afternoon reader';

  @override
  String get monthAfternoonPhrase =>
      'You pause in the middle of the day and fill it with pages.';

  @override
  String get monthNight => 'The night owl';

  @override
  String get monthNightPhrase =>
      'You find calm and focus when the world goes quiet.';

  @override
  String monthBandEvidence(int percent) {
    return '$percent% of your reading was in that part of the day.';
  }

  @override
  String get monthNomad => 'Nomad reader';

  @override
  String get monthNomadPhrase => 'Any moment is a good moment to open a book.';

  @override
  String get monthNomadEvidence => 'No part of the day reaches 60%.';

  @override
  String get appearance => 'Appearance';

  @override
  String get themePrograma => 'Program';

  @override
  String get themeLibro => 'Book';

  @override
  String get themeCuaderno => 'Notebook';

  @override
  String get themePeriodico => 'Newspaper';

  @override
  String get themeFicha => 'Card';

  @override
  String get themeChangeFailed => 'The appearance could not be changed.';
}
