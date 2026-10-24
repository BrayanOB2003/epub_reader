import 'package:epub_reader/app/app_logo.dart';
import 'package:epub_reader/app/schedule_theme.dart';
import 'package:epub_reader/app/schedule_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the mark field takes the station color of the appearance', () async {
    final data = await rootBundle.load('assets/logo/mark.png');
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    const station = (r: 0x8C, g: 0x3D, b: 0x2F);
    const mark = (r: 0xF6, g: 0xF1, b: 0xE8);
    const accent = (r: 0xC4, g: 0x8A, b: 0x7A);

    final png = recolorLogoPng(
      bytes,
      station: station,
      mark: mark,
      accent: accent,
    );
    final image = img.decodePng(png)!;

    final field = image.getPixel(0, 0);
    expect(field.r.toInt(), station.r);
    expect(field.g.toInt(), station.g);
    expect(field.b.toInt(), station.b);

    final paper = image.getPixel(90, 87);
    expect(paper.r.toInt(), mark.r);
    expect(paper.g.toInt(), mark.g);
    expect(paper.b.toInt(), mark.b);

    final window = image.getPixel(249, 338);
    expect(window.r.toInt(), accent.r);
    expect(window.g.toInt(), accent.g);
    expect(window.b.toInt(), accent.b);
  });

  test('two appearances paint different fields', () async {
    final data = await rootBundle.load('assets/logo/mark.png');
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final book = recolorLogoPng(
      bytes,
      station: logoRgb(const Color(0xFF8C3D2F)),
      mark: logoRgb(const Color(0xFFF6F1E8)),
      accent: logoRgb(
        logoFieldAccent(const Color(0xFF8C3D2F), const Color(0xFFF6F1E8)),
      ),
    );
    final news = recolorLogoPng(
      bytes,
      station: logoRgb(const Color(0xFF8F1D2C)),
      mark: logoRgb(const Color(0xFFF7F4EC)),
      accent: logoRgb(
        logoFieldAccent(const Color(0xFF8F1D2C), const Color(0xFFF7F4EC)),
      ),
    );
    expect(
      img.decodePng(book)!.getPixel(0, 0).r,
      isNot(img.decodePng(news)!.getPixel(0, 0).r),
    );
  });

  testWidgets('the library home shows the mark in the current station color', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: scheduleTheme(Brightness.light, AppThemeId.libro),
        home: const Scaffold(
          body: ScheduleHeader(
            title: 'Biblioteca',
            leading: AppLogo(size: 36, semanticLabel: 'Liora'),
          ),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    await tester.runAsync(
      () => precacheImage(image.image, tester.element(find.byType(AppLogo))),
    );
    await tester.pump();

    expect(find.bySemanticsLabel('Liora'), findsOneWidget);
    expect(
      tester.widget<ClipRRect>(find.byType(ClipRRect)).borderRadius,
      BorderRadius.circular(30),
    );
    expect(find.text('Biblioteca'), findsOneWidget);
    final provider = image.image as ThemedLogoImage;
    expect(provider.station, const Color(0xFF8C3D2F));
    expect(provider.mark, const Color(0xFFF6F1E8));
  });
}
