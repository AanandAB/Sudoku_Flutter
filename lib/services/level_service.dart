
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../engine/sudoku_engine.dart';
import '../core/constants.dart';

class LevelData {
  final int id;
  final String difficulty;
  final String puzzleString;
  final String solutionString;
  final bool isUnlocked;
  final bool isSolved;
  final int bestTime; // seconds, 0 = not solved
  final int stars; // 0-3

  LevelData({
    required this.id,
    required this.difficulty,
    required this.puzzleString,
    required this.solutionString,
    this.isUnlocked = false,
    this.isSolved = false,
    this.bestTime = 0,
    this.stars = 0,
  });

  Map<String, dynamic> toJson() => {
    'puzzleString': puzzleString,
    'solutionString': solutionString,
    'isSolved': isSolved,
    'bestTime': bestTime,
    'stars': stars,
  };

  factory LevelData.fromJson(int id, String difficulty, Map<String, dynamic> json) {
    return LevelData(
      id: id,
      difficulty: difficulty,
      puzzleString: json['puzzleString'] ?? '',
      solutionString: json['solutionString'] ?? '',
      isSolved: json['isSolved'] ?? false,
      bestTime: json['bestTime'] ?? 0,
      stars: json['stars'] ?? 0,
    );
  }
}

class LevelService {
  static final LevelService _instance = LevelService._();
  factory LevelService() => _instance;
  LevelService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Generate 300 puzzles if not already stored
  Future<void> ensurePuzzlesGenerated() async {
    for (final diff in AppConstants.difficulties) {
      final stored = _prefs!.getString('puzzles_$diff');
      if (stored == null) {
        final puzzles = <Map<String, String>>[];
        for (int i = 0; i < AppConstants.levelsPerDifficulty; i++) {
          final (puzzle, solution) = SudokuEngine.generateByDifficulty(diff);
          puzzles.add({
            'puzzle': SudokuEngine.serialize(puzzle),
            'solution': SudokuEngine.serialize(solution),
          });
        }
        await _prefs!.setString('puzzles_$diff', jsonEncode(puzzles));
      }
    }
  }

  /// Get puzzle data for a specific level
  Future<LevelData> getLevel(int levelId) async {
    final diffIndex = (levelId - 1) ~/ AppConstants.levelsPerDifficulty;
    final diff = AppConstants.difficulties[diffIndex.clamp(0, 2)];
    final puzzleIndex = (levelId - 1) % AppConstants.levelsPerDifficulty;

    final stored = _prefs!.getString('puzzles_$diff') ?? '[]';
    final puzzles = (jsonDecode(stored) as List).cast<Map<String, dynamic>>();
    final puzzleData = puzzles[puzzleIndex];

    // Load progress
    final progressJson = _prefs!.getString('progress_$levelId');
    final progress = progressJson != null
        ? jsonDecode(progressJson) as Map<String, dynamic>
        : <String, dynamic>{};

    return LevelData(
      id: levelId,
      difficulty: diff,
      puzzleString: puzzleData['puzzle'] ?? '',
      solutionString: puzzleData['solution'] ?? '',
      isSolved: progress['isSolved'] ?? false,
      bestTime: progress['bestTime'] ?? 0,
      stars: progress['stars'] ?? 0,
      isUnlocked: levelId == 1 || _isLevelUnlocked(levelId),
    );
  }

  /// Save level progress
  Future<void> saveProgress(int levelId, {bool? isSolved, int? bestTime, int? stars}) async {
    final existing = _prefs!.getString('progress_$levelId');
    final data = existing != null
        ? jsonDecode(existing) as Map<String, dynamic>
        : <String, dynamic>{};

    if (isSolved != null) data['isSolved'] = isSolved;
    if (bestTime != null) {
      data['bestTime'] = data['bestTime'] == 0
          ? bestTime
          : (bestTime < (data['bestTime'] ?? 999999) ? bestTime : data['bestTime']);
    }
    if (stars != null) {
      data['stars'] = stars > (data['stars'] ?? 0) ? stars : data['stars'];
    }

    await _prefs!.setString('progress_$levelId', jsonEncode(data));
  }

  /// Get count of solved levels per difficulty
  Future<Map<String, int>> getSolvedCounts() async {
    final counts = <String, int>{};
    for (final diff in AppConstants.difficulties) {
      counts[diff] = _prefs!.getInt('solved_$diff') ?? 0;
    }
    return counts;
  }

  /// Increment solved count for difficulty
  Future<void> incrementSolvedCount(String difficulty) async {
    final key = 'solved_$difficulty';
    final current = _prefs!.getInt(key) ?? 0;
    await _prefs!.setInt(key, current + 1);
  }

  /// Stars based on time
  static int calculateStars(int timeSeconds, String difficulty) {
    switch (difficulty) {
      case 'easy':
        if (timeSeconds <= 180) return 3;
        if (timeSeconds <= 360) return 2;
        return 1;
      case 'medium':
        if (timeSeconds <= 300) return 3;
        if (timeSeconds <= 600) return 2;
        return 1;
      case 'hard':
        if (timeSeconds <= 480) return 3;
        if (timeSeconds <= 900) return 2;
        return 1;
      default:
        return 1;
    }
  }

  bool _isLevelUnlocked(int levelId) {
    if (levelId == 1) return true;
    final prevProgress = _prefs!.getString('progress_${levelId - 1}');
    if (prevProgress != null) {
      final data = jsonDecode(prevProgress) as Map<String, dynamic>;
      return data['isSolved'] == true;
    }
    return false;
  }

  /// Get next unlocked level
  int getNextUnlockedLevel() {
    for (int i = 1; i <= AppConstants.totalLevels; i++) {
      if (i == 1) continue;
      final prevProgress = _prefs!.getString('progress_${i - 1}');
      if (prevProgress != null) {
        final data = jsonDecode(prevProgress) as Map<String, dynamic>;
        if (data['isSolved'] == true) continue;
      }
      final currentProgress = _prefs!.getString('progress_$i');
      if (currentProgress == null) return i;
    }
    return 1;
  }
}
