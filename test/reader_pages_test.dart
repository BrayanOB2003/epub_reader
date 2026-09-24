import 'package:epub_reader/features/reader/reader_pages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('estimates the book length from a saved reading position', () {
    expect(estimatedTotalPages(position: 11, totalProgression: 0.04791666666666666), 209);
    expect(estimatedTotalPages(position: 9, totalProgression: 0.038551401869158876), 208);
    expect(estimatedTotalPages(position: 1, totalProgression: 0), isNull);
  });

  test('maps a page onto a chapter and a position inside it', () {
    final start = spineTarget(page: 1, total: 209, chapterCount: 10);
    expect(start.index, 0);
    expect(start.progression, 0);

    final end = spineTarget(page: 209, total: 209, chapterCount: 10);
    expect(end.index, 9);
    expect(end.progression, 1);
  });
}
