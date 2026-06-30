
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/neumorphic.dart';
import '../core/constants.dart';
import '../services/level_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final LevelService _levelService = LevelService();
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;
  int _totalSolved = 0;
  bool _allComplete = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
    _loadStats();
  }

  Future<void> _loadStats() async {
    await _levelService.init();
    final counts = await _levelService.getSolvedCounts();
    if (mounted) {
      setState(() {
        _totalSolved = counts.values.fold(0, (a, b) => a + b);
        _allComplete = _totalSolved >= AppConstants.totalLevels;
      });
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          // Do nothing — stay on home screen
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.background, Color(0xFFDCE3F0)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // ── Settings gear ──
                  Align(
                    alignment: Alignment.topRight,
                    child: NeumoIconButton(
                      icon: Icons.settings_rounded,
                      size: 40,
                      onTap: () { HapticFeedback.selectionClick(); context.go('/settings'); },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Logo ──
                  AnimatedBuilder(
                    animation: _scaleAnim,
                    builder: (_, child) => Transform.scale(
                      scale: _scaleAnim.value,
                      child: child,
                    ),
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: Neumo.boxConvex(
                        radius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.grid_on_rounded,
                            size: 60,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Title ──
                  Text(
                    'SUDOKU',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Challenge Your Mind',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Stats Cards ──
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.emoji_events_rounded,
                          label: 'Solved',
                          value: '$_totalSolved',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.grid_view_rounded,
                          label: 'Levels',
                          value: '${AppConstants.totalLevels}',
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Progress Bar ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: Neumo.boxConvex(radius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Overall Progress',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            Text(
                              '${(_totalSolved / AppConstants.totalLevels * 100).toStringAsFixed(1)}%',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _totalSolved / AppConstants.totalLevels,
                            minHeight: 10,
                            backgroundColor: AppColors.surfaceDark,
                            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Difficulty Stats ──
                  _buildDifficultyRow(),

                  const SizedBox(height: 32),

                  // ── All Complete Badge ──
                  if (_allComplete)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: Neumo.boxConvex(
                        radius: BorderRadius.circular(20),
                        color: AppColors.success.withAlpha(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.celebration_rounded, color: AppColors.success, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            'ALL 300 LEVELS COMPLETE!',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.success,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ── Play Button ──
                  NeumoButton(
                    width: double.infinity,
                    height: 64,
                    radius: BorderRadius.circular(20),
                    color: AppColors.primary,
                    pressedColor: AppColors.primaryDark,
                    onTap: () { HapticFeedback.selectionClick(); context.go('/levels'); },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          'PLAY',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Continue Button ──
                  if (_totalSolved > 0 && !_allComplete)
                    NeumoButton(
                      width: double.infinity,
                      height: 56,
                      onTap: () { HapticFeedback.selectionClick(); context.go('/continue'); },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.skip_next_rounded, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Continue Level ${_levelService.getNextUnlockedLevel()}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
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

  Widget _buildDifficultyRow() {
    return FutureBuilder<Map<String, int>>(
      future: _levelService.getSolvedCounts(),
      builder: (context, snapshot) {
        final counts = snapshot.data ?? {};
        return Row(
          children: AppConstants.difficulties.map((diff) {
            final count = counts[diff] ?? 0;
            final color = _difficultyColor(diff);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: Neumo.boxConvex(radius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Icon(_diffIcon(diff), color: color, size: 24),
                      const SizedBox(height: 6),
                      Text(
                        AppConstants.difficultyLabels[diff]!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count/100',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  IconData _diffIcon(String diff) {
    switch (diff) {
      case 'easy': return Icons.sentiment_satisfied_rounded;
      case 'medium': return Icons.sentiment_neutral_rounded;
      case 'hard': return Icons.sentiment_very_dissatisfied_rounded;
      default: return Icons.grid_view_rounded;
    }
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy': return AppColors.easyColor;
      case 'medium': return AppColors.mediumColor;
      case 'hard': return AppColors.hardColor;
      default: return AppColors.primary;
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: Neumo.boxConvex(radius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
