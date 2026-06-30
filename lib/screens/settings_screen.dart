
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_themes.dart';
import '../core/theme/neumorphic.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  final ThemePreset currentTheme;
  final VoidCallback onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settings = SettingsService();
  late bool _hapticEnabled;
  late String _themeName;

  @override
  void initState() {
    super.initState();
    _hapticEnabled = _settings.hapticEnabled;
    _themeName = _settings.themeName;
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.currentTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/');
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [t.background, t.backgroundEnd],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      NeumoIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () { HapticFeedback.selectionClick(); context.go('/'); },
                      ),
                      const SizedBox(width: 16),
                      Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── SECTION: Gameplay ──
                  _sectionHeader('Gameplay', t),
                  const SizedBox(height: 12),

                  // Haptic toggle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: Neumo.boxConvex(radius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        Icon(Icons.vibration_rounded, color: t.primary, size: 24),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Haptic Feedback', style: Theme.of(context).textTheme.titleMedium),
                              Text('Vibrate on taps and interactions',
                                style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        Switch(
                          value: _hapticEnabled,
                          activeColor: t.primary,
                          onChanged: (v) {
                            setState(() => _hapticEnabled = v);
                            _settings.setHapticEnabled(v);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── SECTION: Color Theme ──
                  _sectionHeader('Color Theme', t),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: Neumo.boxConvex(radius: BorderRadius.circular(16)),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: ThemePreset.presets.map((preset) {
                        final isActive = _themeName == preset.name;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _themeName = preset.name);
                            _settings.setThemeName(preset.name);
                            widget.onThemeChanged();
                          },
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [preset.primary, preset.primaryDark],
                              ),
                              border: isActive
                                  ? Border.all(color: preset.accent, width: 3)
                                  : null,
                              boxShadow: isActive ? Neumo.convex : Neumo.flat,
                            ),
                            child: isActive
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 28)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String text, ThemePreset t) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: t.primary,
          letterSpacing: 2,
        ),
      ),
    );
  }

}
