
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/neumorphic.dart';
import '../core/constants.dart';
import '../services/level_service.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  final LevelService _levelService = LevelService();
  String _selectedDifficulty = 'easy';
  Map<String, int> _solvedCounts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _levelService.init();
    await _levelService.ensurePuzzlesGenerated();
    final counts = await _levelService.getSolvedCounts();
    if (mounted) {
      setState(() {
        _solvedCounts = counts;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.go('/');
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
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      NeumoIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => context.go('/'),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Levels',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),

                // Difficulty tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: AppConstants.difficulties.map((diff) {
                      final isSelected = _selectedDifficulty == diff;
                      final color = _difficultyColor(diff);
                      final count = _solvedCounts[diff] ?? 0;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedDifficulty = diff),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: isSelected
                                  ? Neumo.boxConcave(radius: BorderRadius.circular(16))
                                  : Neumo.boxConvex(radius: BorderRadius.circular(16)),
                              child: Column(
                                children: [
                                  Text(
                                    AppConstants.difficultyLabels[diff]!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? color : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$count/100',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? color : AppColors.textHint,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Level grid
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1,
                          ),
                          itemCount: AppConstants.levelsPerDifficulty,
                          itemBuilder: (context, index) {
                            final baseId = AppConstants.difficulties.indexOf(_selectedDifficulty) *
                                AppConstants.levelsPerDifficulty;
                            final levelId = baseId + index + 1;
                            return _buildLevelTile(levelId);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelTile(int levelId) {
    return FutureBuilder<LevelData>(
      future: _levelService.getLevel(levelId),
      builder: (context, snapshot) {
        final data = snapshot.data;
        final isUnlocked = data?.isUnlocked ?? false;
        final isSolved = data?.isSolved ?? false;
        final stars = data?.stars ?? 0;
        final isNext = !isSolved && isUnlocked;

        return GestureDetector(
          onTap: () {
            if (isUnlocked) {
              context.go('/game/$levelId');
            }
          },
          child: Container(
            decoration: isSolved
                ? Neumo.boxConvex(
                    radius: BorderRadius.circular(14),
                    color: _difficultyColor(_selectedDifficulty).withAlpha(25),
                  )
                : isUnlocked
                    ? Neumo.boxConvex(radius: BorderRadius.circular(14))
                    : Neumo.boxFlat(radius: BorderRadius.circular(14)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSolved)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      return Icon(
                        i < stars ? Icons.star_rounded : Icons.star_border_rounded,
                        size: 14,
                        color: i < stars
                            ? const Color(0xFFFFD700)
                            : AppColors.textHint,
                      );
                    }),
                  )
                else if (isNext)
                  const Icon(Icons.lock_open_rounded, size: 20, color: AppColors.primary)
                else if (!isUnlocked)
                  const Icon(Icons.lock_rounded, size: 20, color: AppColors.textHint)
                else
                  Text(
                    '$levelId',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                if (isSolved) const SizedBox(height: 2),
                if (isSolved && (data?.bestTime ?? 0) > 0)
                  Text(
                    _formatTime(data!.bestTime),
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy': return AppColors.easyColor;
      case 'medium': return AppColors.mediumColor;
      case 'hard': return AppColors.hardColor;
      default: return AppColors.primary;
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
