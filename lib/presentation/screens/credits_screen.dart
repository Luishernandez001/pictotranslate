import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_notifier.dart';

/// Atribución obligatoria ARASAAC (CC BY-NC-SA).
class CreditsScreen extends ConsumerWidget {
  const CreditsScreen({super.key});

  static const String attributionBody = '''
PictoTranslate utiliza pictogramas y datos de ARASAAC (Aragonese Open Resource Augmentative and Alternative Communication).

Autor / origen: ARASAAC — https://arasaac.org/

Licencia: Creative Commons BY-NC-SA (Reconocimiento – No comercial – Compartir igual). Debes citar la autoría y el origen, no usar los recursos con fines comerciales, y mantener la misma licencia en obras derivadas.

Esta aplicación es un ejemplo educativo de accesibilidad; revisa siempre los términos actualizados en el sitio oficial de ARASAAC antes de un uso amplio o público.
''';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Créditos',
          style: TextStyle(fontSize: settings.effectiveBodySize),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: SelectableText(
            attributionBody.trim(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
