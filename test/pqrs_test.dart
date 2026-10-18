import 'package:epub_reader/features/profile/pqrs.dart';
import 'package:epub_reader/features/profile/pqrs_page.dart';
import 'package:epub_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'a draft needs a kind and a message, and a real email if one is given',
    () {
      expect(checkPqrs(kind: null, message: '  ', email: '').issues, {
        PqrsIssue.kind,
        PqrsIssue.messageEmpty,
      });
      expect(
        checkPqrs(
          kind: PqrsKind.complaint,
          message: 'x' * (pqrsMessageLimit + 1),
          email: 'no',
        ).issues,
        {PqrsIssue.messageTooLong, PqrsIssue.email},
      );

      final draft = draftFrom(
        kind: PqrsKind.suggestion,
        message: '  Más tiempo en la noche  ',
        email: '  ',
      );
      expect(draft?.kind, PqrsKind.suggestion);
      expect(draft?.message, 'Más tiempo en la noche');
      expect(draft?.email, isNull);
    },
  );

  test('a saved PQRS keeps the kind, the message, and the email', () {
    expect(
      pqrsFields(
        const PqrsDraft(
          kind: PqrsKind.claim,
          message: 'No abre el EPUB',
          email: 'ada@liora.app',
        ),
        platform: 'ios',
        locale: 'es',
      ),
      {
        'kind': 'claim',
        'message': 'No abre el EPUB',
        'platform': 'ios',
        'locale': 'es',
        'email': 'ada@liora.app',
      },
    );
    expect(
      pqrsFields(
        const PqrsDraft(kind: PqrsKind.petition, message: 'Sin correo'),
        platform: 'android',
        locale: 'en',
      ).containsKey('email'),
      isFalse,
    );
  });

  testWidgets('a question opens, and a written note stays on the phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final channel = _RecordingChannel();
    await tester.pumpWidget(_PqrsApp(channel: channel));
    await tester.pumpAndSettle();

    expect(find.text('¿Necesito una cuenta?'), findsNothing);
    await tester.tap(find.text('Preguntas frecuentes'));
    await tester.pumpAndSettle();
    expect(find.text('¿Necesito una cuenta?'), findsOneWidget);
    expect(
      find.text('No. Tus libros y tu progreso se guardan en este dispositivo.'),
      findsNothing,
    );

    await tester.tap(find.text('¿Necesito una cuenta?'));
    await tester.pumpAndSettle();
    expect(
      find.text('No. Tus libros y tu progreso se guardan en este dispositivo.'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Enviar', skipOffstage: false));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();
    expect(find.text('Escribe el mensaje.'), findsOneWidget);
    expect(
      find.text('Elige petición, queja, reclamo o sugerencia.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Queja'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'El EPUB no abre.');
    await tester.pumpAndSettle();
    expect(find.text('El EPUB no abre.'), findsOneWidget);
    await tester.ensureVisible(find.text('Enviar', skipOffstage: false));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();

    expect(find.text('Enviada'), findsOneWidget);
    expect(find.text('Recibimos tu queja.'), findsOneWidget);
    expect(find.text('El EPUB no abre.'), findsOneWidget);
    expect(channel.draft?.kind, PqrsKind.complaint);
    expect(channel.draft?.message, 'El EPUB no abre.');
    expect(channel.locale, 'es');
    expect(find.text('Enviar'), findsNothing);

    await tester.tap(find.text('Escribir otra'));
    await tester.pumpAndSettle();
    expect(find.text('Enviar'), findsOneWidget);
    expect(find.text('Enviada'), findsNothing);
  });

  testWidgets('a failed send keeps the message on the form', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_PqrsApp(channel: _RecordingChannel(fail: true)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sugerencia'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Más minutos.');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Enviar', skipOffstage: false));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();

    expect(find.text('No se pudo enviar. Inténtalo de nuevo.'), findsOneWidget);
    expect(find.text('Más minutos.'), findsOneWidget);
    expect(find.text('Enviada'), findsNothing);
  });
}

class _RecordingChannel extends PqrsChannel {
  _RecordingChannel({this.fail = false});

  final bool fail;
  PqrsDraft? draft;
  String? locale;

  @override
  Future<void> submit(PqrsDraft draft, {required String locale}) async {
    if (fail) throw StateError('offline');
    this.draft = draft;
    this.locale = locale;
  }
}

class _PqrsApp extends StatelessWidget {
  const _PqrsApp({required this.channel});

  final PqrsChannel channel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: PqrsPage(channel: channel),
    );
  }
}
