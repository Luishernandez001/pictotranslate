import 'package:flutter/material.dart';

import '../../data/settings_store.dart';

/// Transición nula: evita animaciones de página (modo reducir estímulos).
class NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

/// Temas suaves (TEA) y variante alto contraste.
ThemeData buildTeaTheme({
  required AppSettings settings,
  required Brightness brightness,
}) {
  final baseSize = settings.effectiveBodySize;
  final textTheme = TextTheme(
    bodyLarge: TextStyle(fontSize: baseSize, height: 1.35),
    bodyMedium: TextStyle(fontSize: baseSize - 2, height: 1.35),
    titleLarge: TextStyle(fontSize: baseSize + 6, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: baseSize + 2, fontWeight: FontWeight.w600),
    labelLarge: TextStyle(fontSize: baseSize, fontWeight: FontWeight.w500),
  );

  if (settings.highContrast) {
    final scheme = brightness == Brightness.dark
        ? const ColorScheme.dark(
            primary: Color(0xFFFFEB3B),
            onPrimary: Color(0xFF000000),
            surface: Color(0xFF000000),
            onSurface: Color(0xFFFFFFFF),
            secondary: Color(0xFF00E5FF),
            onSecondary: Color(0xFF000000),
          )
        : const ColorScheme.light(
            primary: Color(0xFF000000),
            onPrimary: Color(0xFFFFFFFF),
            surface: Color(0xFFFFFFFF),
            onSurface: Color(0xFF000000),
            secondary: Color(0xFF0D47A1),
            onSecondary: Color(0xFFFFFFFF),
          );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      splashFactory: settings.reduceStimuli ? NoSplash.splashFactory : null,
      pageTransitionsTheme: settings.reduceStimuli
          ? const PageTransitionsTheme(builders: {
              TargetPlatform.android: NoAnimationPageTransitionsBuilder(),
              TargetPlatform.iOS: NoAnimationPageTransitionsBuilder(),
              TargetPlatform.macOS: NoAnimationPageTransitionsBuilder(),
              TargetPlatform.windows: NoAnimationPageTransitionsBuilder(),
              TargetPlatform.linux: NoAnimationPageTransitionsBuilder(),
            })
          : null,
    );
  }

  // Colores suaves, legibles, sin contraste extremo innecesario.
  const seed = Color(0xFF5C8A8B);
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: brightness,
    surface: brightness == Brightness.light
        ? const Color(0xFFF4F7F7)
        : const Color(0xFF1E2526),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    textTheme: textTheme,
    splashFactory: settings.reduceStimuli ? NoSplash.splashFactory : null,
    pageTransitionsTheme: settings.reduceStimuli
        ? const PageTransitionsTheme(builders: {
            TargetPlatform.android: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.iOS: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.macOS: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.windows: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.linux: NoAnimationPageTransitionsBuilder(),
          })
        : null,
  );
}
