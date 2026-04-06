import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'presentation/providers/settings_notifier.dart';
import 'presentation/screens/home_screen.dart';

class PictoTranslateApp extends ConsumerWidget {
  const PictoTranslateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp(
      title: 'PictoTranslate',
      debugShowCheckedModeBanner: false,
      theme: buildTeaTheme(settings: settings, brightness: Brightness.light),
      darkTheme: buildTeaTheme(settings: settings, brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      themeAnimationDuration:
          settings.reduceStimuli ? Duration.zero : const Duration(milliseconds: 200),
      home: const HomeScreen(),
    );
  }
}
