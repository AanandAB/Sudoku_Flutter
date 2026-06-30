
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/level_select_screen.dart';
import 'screens/game_screen.dart';
import 'services/level_service.dart';

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sudoku',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}

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
  ],
);
