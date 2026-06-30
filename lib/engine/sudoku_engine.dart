
import 'dart:math';

class SudokuEngine {
  static final Random _random = Random();

  /// Generate a complete, valid Sudoku solution
  static List<List<int>> generateSolution() {
    final grid = List.generate(9, (_) => List.filled(9, 0));
    _fillGrid(grid);
    return grid;
  }

  /// Backtracking solver — fills the grid
  static bool _fillGrid(List<List<int>> grid) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col] == 0) {
          final numbers = List.generate(9, (i) => i + 1)..shuffle(_random);
          for (final num in numbers) {
            if (_isSafe(grid, row, col, num)) {
              grid[row][col] = num;
              if (_fillGrid(grid)) return true;
              grid[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  /// Check if placing num at (row, col) is valid
  static bool _isSafe(List<List<int>> grid, int row, int col, int num) {
    for (int x = 0; x < 9; x++) {
      if (grid[row][x] == num) return false;
      if (grid[x][col] == num) return false;
    }
    final boxRow = row - row % 3;
    final boxCol = col - col % 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (grid[r][c] == num) return false;
      }
    }
    return true;
  }

  /// Count solutions for a puzzle (stops at 2 for uniqueness check)
  static int _countSolutions(List<List<int>> grid, int limit) {
    int count = 0;
    void solve(List<List<int>> g) {
      if (count >= limit) return;
      for (int row = 0; row < 9; row++) {
        for (int col = 0; col < 9; col++) {
          if (g[row][col] == 0) {
            for (int num = 1; num <= 9; num++) {
              if (_isSafe(g, row, col, num)) {
                g[row][col] = num;
                solve(g);
                g[row][col] = 0;
                if (count >= limit) return;
              }
            }
            return;
          }
        }
      }
      count++;
    }
    final copy = grid.map((r) => List<int>.from(r)).toList();
    solve(copy);
    return count;
  }

  /// Remove cells from a filled grid to create a puzzle.
  /// [cellsToRemove] controls difficulty.
  /// Returns (puzzle, solution).
  static (List<List<int>>, List<List<int>>) createPuzzle(int cellsToRemove) {
    final solution = generateSolution();
    final puzzle = solution.map((r) => List<int>.from(r)).toList();
    final positions = List.generate(81, (i) => i)..shuffle(_random);

    int removed = 0;
    for (final pos in positions) {
      if (removed >= cellsToRemove) break;
      final row = pos ~/ 9;
      final col = pos % 9;
      final backup = puzzle[row][col];
      puzzle[row][col] = 0;
      if (_countSolutions(puzzle, 2) == 1) {
        removed++;
      } else {
        puzzle[row][col] = backup;
      }
    }
    return (puzzle, solution);
  }

  /// Generate a puzzle by difficulty
  static (List<List<int>>, List<List<int>>) generateByDifficulty(String difficulty) {
    int cellsToRemove;
    switch (difficulty) {
      case 'easy':
        cellsToRemove = 36 + _random.nextInt(5);   // 36-40 removed, 45-41 given
        break;
      case 'medium':
        cellsToRemove = 42 + _random.nextInt(7);   // 42-48 removed, 39-33 given
        break;
      case 'hard':
        cellsToRemove = 49 + _random.nextInt(6);   // 49-54 removed, 32-27 given
        break;
      default:
        cellsToRemove = 40;
    }
    return createPuzzle(cellsToRemove);
  }

  /// Validate solution
  static bool isValid(List<List<int>> grid) {
    for (int i = 0; i < 9; i++) {
      final rowSet = <int>{};
      final colSet = <int>{};
      final boxSet = <int>{};
      for (int j = 0; j < 9; j++) {
        if (grid[i][j] != 0 && !rowSet.add(grid[i][j])) return false;
        if (grid[j][i] != 0 && !colSet.add(grid[j][i])) return false;
        final r = 3 * (i ~/ 3) + j ~/ 3;
        final c = 3 * (i % 3) + j % 3;
        if (grid[r][c] != 0 && !boxSet.add(grid[r][c])) return false;
      }
    }
    return true;
  }

  /// Check if puzzle is complete and correct
  static bool isComplete(List<List<int>> grid) {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (grid[i][j] == 0) return false;
      }
    }
    return isValid(grid);
  }

  /// Serialize grid to string (0 = empty)
  static String serialize(List<List<int>> grid) {
    return grid.expand((r) => r).join('');
  }

  /// Deserialize string to grid
  static List<List<int>> deserialize(String s) {
    final result = <List<int>>[];
    for (int i = 0; i < 9; i++) {
      result.add(s.substring(i * 9, i * 9 + 9).split('').map(int.parse).toList());
    }
    return result;
  }

  /// Get hints (positions where user's board differs from solution)
  static List<(int, int, int)> getHints(
    List<List<int>> current,
    List<List<int>> solution,
  ) {
    final hints = <(int, int, int)>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (current[r][c] == 0) {
          hints.add((r, c, solution[r][c]));
        }
      }
    }
    return hints;
  }
}
