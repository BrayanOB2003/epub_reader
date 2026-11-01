import 'package:epub_reader/features/library/data/book_repository.dart';

class QuoteBookGroup {
  QuoteBookGroup({
    required this.bookId,
    required this.bookTitle,
    required this.author,
    required this.quotes,
  });

  final int bookId;
  final String bookTitle;
  final String? author;
  final List<ReadingQuote> quotes;
}

/// Groups by book. The book with the newest quote comes first, and each
/// group's quotes run newest first. Every quote stays on the same row.
List<QuoteBookGroup> arrangeQuotes(List<ReadingQuote> quotes) {
  if (quotes.isEmpty) return const [];
  final ordered = [...quotes]
    ..sort((a, b) {
      final byTime = b.savedAt.compareTo(a.savedAt);
      if (byTime != 0) return byTime;
      return b.id.compareTo(a.id);
    });
  final groups = <int, QuoteBookGroup>{};
  final order = <int>[];
  for (final quote in ordered) {
    final group = groups[quote.bookId];
    if (group == null) {
      order.add(quote.bookId);
      groups[quote.bookId] = QuoteBookGroup(
        bookId: quote.bookId,
        bookTitle: quote.bookTitle,
        author: quote.author,
        quotes: [quote],
      );
    } else {
      group.quotes.add(quote);
    }
  }
  return [for (final id in order) groups[id]!];
}

/// Passage, then the book and the author, ready for the system share sheet.
String quoteShareBody(ReadingQuote quote) {
  final title = quote.bookTitle.trim();
  final author = quote.author?.trim() ?? '';
  final credit = [if (title.isNotEmpty) title, if (author.isNotEmpty) author];
  final passage = quote.text.trim();
  if (credit.isEmpty) return passage;
  return '$passage\n\n${credit.join('\n')}';
}
