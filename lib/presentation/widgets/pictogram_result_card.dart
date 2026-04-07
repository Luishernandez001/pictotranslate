import 'package:flutter/material.dart';

import '../../data/settings_store.dart';
import '../../domain/models/pictogram_result.dart';
import 'pictogram_image.dart';

class PictogramResultCard extends StatelessWidget {
  const PictogramResultCard({
    super.key,
    required this.result,
    required this.displayWord,
    required this.settings,
    required this.onListen,
    required this.speaking,
    required this.reduceMotion,
  });

  final PictogramResult result;
  final String displayWord;
  final AppSettings settings;
  final VoidCallback onListen;
  final bool speaking;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleSize = settings.effectiveBodySize + 8;

    return Semantics(
      container: true,
      label: 'Pictograma para la palabra $displayWord',
      child: Card(
        elevation: reduceMotion ? 0 : 1,
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: PictogramImage(
                  key: ValueKey<int>(result.id),
                  pictogramId: result.id,
                  width: 280,
                  height: 280,
                  reduceMotion: reduceMotion,
                  theme: theme,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                displayWord,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(fontSize: titleSize),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: onListen,
                  icon: Icon(
                    speaking ? Icons.volume_up : Icons.hearing,
                    size: 28,
                  ),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      speaking ? 'Reproduciendo…' : '🔊 Escuchar',
                      style: TextStyle(fontSize: settings.effectiveBodySize),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
