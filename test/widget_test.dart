import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pictotranslate/app.dart';
import 'package:pictotranslate/presentation/providers/app_providers.dart';
import 'package:pictotranslate/presentation/providers/keywords_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Home muestra título PictoTranslate', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          keywordsProvider.overrideWith((ref, language) async => <String>[]),
        ],
        child: const PictoTranslateApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PictoTranslate'), findsWidgets);
    expect(find.text('Buscar'), findsOneWidget);
  });
}
