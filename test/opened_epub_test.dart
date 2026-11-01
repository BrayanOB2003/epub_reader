import 'package:epub_reader/features/library/opened_epub.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads the opened epub path and name', () {
    final file = openedEpubFromEvent({
      'path': '/tmp/a.epub',
      'name': 'Don Quijote.epub',
    });
    expect(file?.path, '/tmp/a.epub');
    expect(file?.name, 'Don Quijote.epub');
    expect(openedEpubFromEvent({'path': ''}), isNull);
    expect(openedEpubFromEvent('nope'), isNull);
    expect(openedEpubFromEvent({'path': '/tmp/a.epub'})?.name, 'a.epub');
  });

  test('opens the book after onboarding is finished', () {
    expect(
      canOpenBookFromDevice(
        onboardingComplete: true,
        location: '/library',
        notificationPromptDue: false,
      ),
      isTrue,
    );
    expect(
      canOpenBookFromDevice(
        onboardingComplete: false,
        location: '/library',
        notificationPromptDue: false,
      ),
      isFalse,
    );
    expect(
      canOpenBookFromDevice(
        onboardingComplete: null,
        location: '/boot',
        notificationPromptDue: false,
      ),
      isFalse,
    );
    expect(
      canOpenBookFromDevice(
        onboardingComplete: true,
        location: '/notifications',
        notificationPromptDue: false,
      ),
      isFalse,
    );
    expect(
      canOpenBookFromDevice(
        onboardingComplete: true,
        location: '/library',
        notificationPromptDue: true,
      ),
      isFalse,
    );
    expect(
      canOpenBookFromDevice(
        onboardingComplete: true,
        location: '/library',
        notificationPromptDue: false,
        permissionKnown: false,
      ),
      isFalse,
    );
  });
}
