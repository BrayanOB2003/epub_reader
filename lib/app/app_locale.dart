import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// English for any English region, Spanish for Spanish and every other language.
Locale resolveAppLocale(List<Locale> locales) {
  for (final locale in locales) {
    if (locale.languageCode == 'en') return const Locale('en');
    if (locale.languageCode == 'es') return const Locale('es');
  }
  return const Locale('es');
}

/// Value sent as `idioma`. `en` covers every English region; `en-GB` would not.
String catalogLanguageOf(Locale locale) =>
    locale.languageCode == 'en' ? 'en' : 'es';

final appLocaleProvider = NotifierProvider<AppLocaleNotifier, Locale>(
  AppLocaleNotifier.new,
);

final catalogLanguageProvider = Provider<String>((ref) {
  return catalogLanguageOf(ref.watch(appLocaleProvider));
});

class AppLocaleNotifier extends Notifier<Locale> with WidgetsBindingObserver {
  @override
  Locale build() {
    final binding = WidgetsBinding.instance;
    binding.addObserver(this);
    ref.onDispose(() => binding.removeObserver(this));
    return resolveAppLocale(binding.platformDispatcher.locales);
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    state = resolveAppLocale(
      locales ?? WidgetsBinding.instance.platformDispatcher.locales,
    );
  }
}
