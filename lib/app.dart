
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_themes.dart';
import 'services/settings_service.dart';
import 'screens/home_screen.dart';
import 'screens/level_select_screen.dart';
import 'screens/game_screen.dart';
import 'screens/settings_screen.dart';
import 'services/level_service.dart';

ThemePreset _currentTheme = ThemePreset.presets.first;
final settingsService = SettingsService();

void refreshAppTheme() {
  _onSettingsChanged?.call();
}

void Function()? _onSettingsChanged;

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/levels',
      builder: (context, state) => const LevelSelectScreen(),
    ),
    GoRoute(
      path: '/game/:levelId',
      builder: (context, state) {
        final levelId = int.parse(state.pathParameters['levelId']!);
        return GameScreen(levelId: levelId);
      },
    ),
    GoRoute(
      path: '/continue',
      builder: (context, state) {
        final levelService = LevelService();
        final nextLevel = levelService.getNextUnlockedLevel();
        return GameScreen(levelId: nextLevel);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) {
        return SettingsScreen(
          currentTheme: _currentTheme,
          onThemeChanged: () {
            _currentTheme = ThemePreset.byName(settingsService.themeName);
            refreshAppTheme();
          },
        );
      },
    ),
  ],
);

class SudokuApp extends StatefulWidget {
  const SudokuApp({super.key});

  @override
  State<SudokuApp> createState() => _SudokuAppState();
}

class _SudokuAppState extends State<SudokuApp> {
  @override
  void initState() {
    super.initState();
    _currentTheme = ThemePreset.byName(settingsService.themeName);
    _onSettingsChanged = () {
      if (mounted) {
        setState(() {
          _currentTheme = ThemePreset.byName(settingsService.themeName);
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sudoku',
      debugShowCheckedModeBanner: false,
      theme: _currentTheme.toThemeData(),
      routerConfig: _router,
    );
  }
}

ThemePreset get currentTheme => _currentTheme;
