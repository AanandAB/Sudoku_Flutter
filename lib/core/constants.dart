
class AppConstants {
  AppConstants._();

  static const String appName = 'Sudoku';
  static const int gridSize = 9;
  static const int boxSize = 3;
  static const int totalLevels = 300;
  static const int levelsPerDifficulty = 100;

  static const List<String> difficulties = ['easy', 'medium', 'hard'];
  static const Map<String, String> difficultyLabels = {
    'easy': 'Easy',
    'medium': 'Medium',
    'hard': 'Hard',
  };
}
