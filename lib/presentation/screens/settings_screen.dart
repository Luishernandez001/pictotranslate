import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/tea_routes.dart';
import '../providers/app_providers.dart';
import '../providers/settings_notifier.dart';
import 'credits_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  List<Map<String, String>> _voices = [];
  bool _voicesLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    final tts = ref.read(ttsServiceProvider);
    try {
      final v = await tts.getEnglishVoices();
      if (mounted) {
        setState(() {
          _voices = v;
          _voicesLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _voicesLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ajustes',
          style: TextStyle(fontSize: settings.effectiveBodySize),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          children: [
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              title: Text(
                'Reducir estímulos',
                style: TextStyle(fontSize: settings.effectiveBodySize),
              ),
              subtitle: Text(
                'Menos animaciones y sin efecto de splash en botones.',
                style: TextStyle(fontSize: settings.effectiveBodySize - 2),
              ),
              value: settings.reduceStimuli,
              onChanged: notifier.setReduceStimuli,
            ),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              title: Text(
                'Modo alto contraste',
                style: TextStyle(fontSize: settings.effectiveBodySize),
              ),
              value: settings.highContrast,
              onChanged: notifier.setHighContrast,
            ),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              title: Text(
                'Modo letra extra grande',
                style: TextStyle(fontSize: settings.effectiveBodySize),
              ),
              subtitle: Text(
                'Aumenta el tamaño respecto al valor del control inferior.',
                style: TextStyle(fontSize: settings.effectiveBodySize - 2),
              ),
              value: settings.extraLargeText,
              onChanged: notifier.setExtraLargeText,
            ),
            const SizedBox(height: 8),
            Text(
              'Tamaño de letra',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              min: 18,
              max: 26,
              divisions: 8,
              label: '${settings.fontSize.round()} pt',
              value: settings.fontSize.clamp(18, 26),
              onChanged: (v) => notifier.setFontSize(v),
            ),
            const Divider(height: 32),
            Text(
              'Lectura en voz alta (inglés)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              title: Text(
                'Velocidad lenta',
                style: TextStyle(fontSize: settings.effectiveBodySize),
              ),
              subtitle: Text(
                'Desactivado = velocidad normal.',
                style: TextStyle(fontSize: settings.effectiveBodySize - 2),
              ),
              value: settings.ttsSlow,
              onChanged: notifier.setTtsSlow,
            ),
            const SizedBox(height: 8),
            Text(
              'Voz (inglés)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_voicesLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Voz del sistema',
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    isExpanded: true,
                    value: _validVoiceValue(settings.ttsVoiceId, _voices),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Predeterminada (en-US)'),
                      ),
                      ..._voices.map(
                        (v) => DropdownMenuItem<String?>(
                          value: v['name'],
                          child: Text(
                            '${v['name']} (${v['locale']})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (v) => notifier.setTtsVoice(v),
                  ),
                ),
              ),
            const Divider(height: 32),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              title: Text(
                'Créditos y licencia ARASAAC',
                style: TextStyle(fontSize: settings.effectiveBodySize),
              ),
              subtitle: Text(
                'Creative Commons BY-NC-SA — obligatorio citar el origen.',
                style: TextStyle(fontSize: settings.effectiveBodySize - 2),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push<void>(
                  teaAwareRoute<void>(
                    child: const CreditsScreen(),
                    reduceStimuli: settings.reduceStimuli,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

String? _validVoiceValue(String? saved, List<Map<String, String>> voices) {
  if (saved == null || saved.isEmpty) return null;
  final ok = voices.any((v) => v['name'] == saved);
  return ok ? saved : null;
}
