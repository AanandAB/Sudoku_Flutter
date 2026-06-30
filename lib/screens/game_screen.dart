
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/neumorphic.dart';
import '../core/constants.dart';
import '../engine/sudoku_engine.dart';
import '../services/level_service.dart';
import '../widgets/sudoku_board.dart';
import '../widgets/number_pad.dart';
import '../widgets/game_controls.dart';
import '../widgets/confetti_overlay.dart';
import '../services/settings_service.dart';

enum HapticFeedbackType { light, medium, heavy, click }

class GameScreen extends StatefulWidget {
  final int levelId;
  const GameScreen({super.key, required this.levelId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final LevelService _levelService = LevelService();
  LevelData? _levelData;
  bool _loading = true;

  // Game state
  List<List<int>> _puzzle = [];
  List<List<int>> _solution = [];
  List<List<int>> _board = [];
  List<List<Set<int>>> _notes = [];
  int _selectedRow = -1;
  int _selectedCol = -1;
  bool _notesMode = false;
  int _hintsUsed = 0;
  int _mistakes = 0;
  bool _isComplete = false;
  bool _isPaused = false;
  bool _showConfetti = false;

  // Timer
  int _elapsedSeconds = 0;
  Timer? _timer;

  // Undo
  final List<_Move> _undoStack = [];

  final SettingsService _settings = SettingsService();

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _haptic(HapticFeedbackType type) {
    if (!_settings.hapticEnabled) return;
    switch (type) {
      case HapticFeedbackType.light:
        _haptic(HapticFeedbackType.light);
        break;
      case HapticFeedbackType.medium:
        _haptic(HapticFeedbackType.medium);
        break;
      case HapticFeedbackType.heavy:
        _haptic(HapticFeedbackType.heavy);
        break;
      case HapticFeedbackType.click:
        _haptic(HapticFeedbackType.click);
        break;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initGame() async {
    await _levelService.init();
    _levelData = await _levelService.getLevel(widget.levelId);

    _puzzle = SudokuEngine.deserialize(_levelData!.puzzleString);
    _solution = SudokuEngine.deserialize(_levelData!.solutionString);
    _board = _puzzle.map((r) => List<int>.from(r)).toList();
    _notes = List.generate(9, (_) => List.generate(9, (_) => <int>{}));

    if (mounted) {
      setState(() => _loading = false);
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused && !_isComplete) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  bool _isGiven(int row, int col) => _puzzle[row][col] != 0;

  void _onCellTap(int row, int col) {
    if (_isComplete || _isPaused) return;
    _haptic(HapticFeedbackType.light);
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
    });
  }

  void _onNumberInput(int number) {
    if (_selectedRow == -1 || _selectedCol == -1) return;
    if (_isComplete || _isPaused) return;
    if (_isGiven(_selectedRow, _selectedCol)) return;

    if (_notesMode) {
      _haptic(HapticFeedbackType.light);
      setState(() {
        if (_notes[_selectedRow][_selectedCol].contains(number)) {
          _notes[_selectedRow][_selectedCol].remove(number);
        } else {
          _notes[_selectedRow][_selectedCol].add(number);
        }
      });
      return;
    }

    _undoStack.add(_Move(
      row: _selectedRow,
      col: _selectedCol,
      prevValue: _board[_selectedRow][_selectedCol],
      prevNotes: Set<int>.from(_notes[_selectedRow][_selectedCol]),
    ));

    setState(() {
      _board[_selectedRow][_selectedCol] = number;
      _notes[_selectedRow][_selectedCol].clear();

      if (number != _solution[_selectedRow][_selectedCol]) {
        _mistakes++;
      }

      if (SudokuEngine.isComplete(_board)) {
        _isComplete = true;
        _timer?.cancel();
        _onPuzzleComplete();
      }
    });
  }

  void _onErase() {
    if (_selectedRow == -1 || _selectedCol == -1) return;
    if (_isComplete || _isPaused) return;
    if (_isGiven(_selectedRow, _selectedCol)) return;

    _haptic(HapticFeedbackType.light);
    _undoStack.add(_Move(
      row: _selectedRow,
      col: _selectedCol,
      prevValue: _board[_selectedRow][_selectedCol],
      prevNotes: Set<int>.from(_notes[_selectedRow][_selectedCol]),
    ));

    setState(() {
      _board[_selectedRow][_selectedCol] = 0;
      _notes[_selectedRow][_selectedCol].clear();
    });
  }

  void _onUndo() {
    if (_undoStack.isEmpty) return;
    _haptic(HapticFeedbackType.light);
    final move = _undoStack.removeLast();
    setState(() {
      _board[move.row][move.col] = move.prevValue;
      _notes[move.row][move.col] = move.prevNotes;
    });
  }

  void _onHint() {
    if (_isComplete || _isPaused) return;

    _haptic(HapticFeedbackType.medium);
    final hints = SudokuEngine.getHints(_board, _solution);
    if (hints.isEmpty) return;

    (int, int, int) hint;
    if (_selectedRow != -1 && _selectedCol != -1 && _board[_selectedRow][_selectedCol] == 0) {
      hint = (_selectedRow, _selectedCol, _solution[_selectedRow][_selectedCol]);
    } else {
      hint = hints.first;
    }

    _undoStack.add(_Move(
      row: hint.$1,
      col: hint.$2,
      prevValue: _board[hint.$1][hint.$2],
      prevNotes: Set<int>.from(_notes[hint.$1][hint.$2]),
    ));

    setState(() {
      _board[hint.$1][hint.$2] = hint.$3;
      _notes[hint.$1][hint.$2].clear();
      _hintsUsed++;
      _selectedRow = hint.$1;
      _selectedCol = hint.$2;

      if (SudokuEngine.isComplete(_board)) {
        _isComplete = true;
        _timer?.cancel();
        _onPuzzleComplete();
      }
    });
  }

  Future<void> _onPuzzleComplete() async {
    final stars = LevelService.calculateStars(_elapsedSeconds, _levelData!.difficulty);
    await _levelService.saveProgress(
      widget.levelId,
      isSolved: true,
      bestTime: _elapsedSeconds,
      stars: stars,
    );
    await _levelService.incrementSolvedCount(_levelData!.difficulty);

    // Check if all 300 levels solved
    final counts = await _levelService.getSolvedCounts();
    final totalSolved = counts.values.fold(0, (a, b) => a + b);
    final allComplete = totalSolved >= AppConstants.totalLevels;

    if (allComplete) {
      _haptic(HapticFeedbackType.heavy);
      setState(() {
        _showConfetti = true;
      });
    } else {
      _haptic(HapticFeedbackType.heavy);
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            if (allComplete) ...[
              const Icon(Icons.celebration_rounded, size: 48, color: AppColors.success),
              const SizedBox(height: 8),
              const Text('ALL LEVELS\nCOMPLETE!', textAlign: TextAlign.center),
            ] else
              const Text('Puzzle Complete!', textAlign: TextAlign.center),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Icon(
                  i < stars ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 40,
                  color: i < stars ? const Color(0xFFFFD700) : AppColors.textHint,
                );
              }),
            ),
            const SizedBox(height: 16),
            if (allComplete)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: const Text(
   'You solved all 300 puzzles!\nYou\'re a Sudoku Master!',
   textAlign: TextAlign.center,
   style: TextStyle(
                    fontSize: 14,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            _statRow('Time', _formatTime(_elapsedSeconds)),
            _statRow('Hints', '$_hintsUsed'),
            _statRow('Mistakes', '$_mistakes'),
            if (allComplete)
              _statRow('Total Solved', '$totalSolved / ${AppConstants.totalLevels}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/');
            },
            child: const Text('HOME'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/levels');
            },
            child: const Text('LEVELS'),
          ),
          if (widget.levelId < AppConstants.totalLevels)
            NeumoButton(
              height: 48,
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(ctx);
                context.go('/game/${widget.levelId + 1}');
              },
              child: const Text('NEXT', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Set<int> _conflictCells() {
    final conflicts = <int>{};
    if (_selectedRow == -1 || _selectedCol == -1) return conflicts;
    final selectedNum = _board[_selectedRow][_selectedCol];
    if (selectedNum == 0) return conflicts;

    for (int i = 0; i < 9; i++) {
      if (i != _selectedCol && _board[_selectedRow][i] == selectedNum) {
        conflicts.add(_selectedRow * 9 + i);
      }
      if (i != _selectedRow && _board[i][_selectedCol] == selectedNum) {
        conflicts.add(i * 9 + _selectedCol);
      }
    }
    final br = _selectedRow - _selectedRow % 3;
    final bc = _selectedCol - _selectedCol % 3;
    for (int r = br; r < br + 3; r++) {
      for (int c = bc; c < bc + 3; c++) {
        if (r == _selectedRow && c == _selectedCol) continue;
        if (_board[r][c] == selectedNum) {
          conflicts.add(r * 9 + c);
        }
      }
    }
    return conflicts;
  }

  Set<int> _sameNumberCells() {
    final cells = <int>{};
    if (_selectedRow == -1 || _selectedCol == -1) return cells;
    final selectedNum = _board[_selectedRow][_selectedCol];
    if (selectedNum == 0) return cells;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (r == _selectedRow && c == _selectedCol) continue;
        if (_board[r][c] == selectedNum) cells.add(r * 9 + c);
      }
    }
    return cells;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final cellColors = <int, Color>{};
    final sc = _selectedRow * 9 + _selectedCol;
    if (_selectedRow != -1) cellColors[sc] = AppColors.cellSelected;
    for (final c in _sameNumberCells()) {
      cellColors[c] = AppColors.cellSameNumber;
    }
    for (final c in _conflictCells()) {
      cellColors[c] = AppColors.cellError;
    }

    if (_selectedRow != -1) {
      final br = _selectedRow - _selectedRow % 3;
      final bc = _selectedCol - _selectedCol % 3;
      for (int r = br; r < br + 3; r++) {
        for (int c = bc; c < bc + 3; c++) {
          final idx = r * 9 + c;
          if (!cellColors.containsKey(idx)) {
            cellColors[idx] = AppColors.cellSameBox;
          }
        }
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.go('/levels');
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
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
                    // Top bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                      child: Row(
                        children: [
                          NeumoIconButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => context.go('/levels'),
                            size: 42,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Level ${widget.levelId}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  AppConstants.difficultyLabels[_levelData!.difficulty]!.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _difficultyColor(),
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: Neumo.boxConvex(radius: BorderRadius.circular(12)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timer_rounded, size: 18, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  _formatTime(_elapsedSeconds),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFeatures: [FontFeature.tabularFigures()],
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          NeumoIconButton(
                            icon: Icons.pause_rounded,
                            onTap: () { _haptic(HapticFeedbackType.click); setState(() => _isPaused = !_isPaused); },
                            size: 42,
                          ),
                        ],
                      ),
                    ),

                    // Board
                    Expanded(
                      child: Center(
                        child: SudokuBoard(
                          board: _board,
                          puzzle: _puzzle,
                          notes: _notes,
                          selectedRow: _selectedRow,
                          selectedCol: _selectedCol,
                          cellColors: cellColors,
                          onCellTap: _onCellTap,
                        ),
                      ),
                    ),

                    // Game controls
                    GameControls(
                      hintsUsed: _hintsUsed,
                      mistakes: _mistakes,
                      notesMode: _notesMode,
                      canUndo: _undoStack.isNotEmpty,
                      onHint: _onHint,
                      onUndo: _onUndo,
                      onErase: _onErase,
                      onNotesToggle: () { _haptic(HapticFeedbackType.click); setState(() => _notesMode = !_notesMode); },
                    ),

                    // Number pad
                    NumberPad(onNumber: _onNumberInput),
                  ],
                ),
              ),
            ),

            // Confetti overlay
            ConfettiOverlay(show: _showConfetti),

            // Pause overlay
            if (_isPaused)
              Container(
                color: AppColors.textPrimary.withAlpha(100),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: Neumo.boxConvex(radius: BorderRadius.circular(24)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.pause_circle_rounded, size: 64, color: AppColors.primary),
                        const SizedBox(height: 16),
                        const Text('Paused', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 24),
                        NeumoButton(
                          color: AppColors.primary,
                          onTap: () => setState(() => _isPaused = false),
                          child: const Text('RESUME', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 12),
                        NeumoButton(
                          onTap: () => context.go('/levels'),
                          child: const Text('QUIT', style: TextStyle(color: AppColors.accent)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _difficultyColor() {
    switch (_levelData!.difficulty) {
      case 'easy': return AppColors.easyColor;
      case 'medium': return AppColors.mediumColor;
      case 'hard': return AppColors.hardColor;
      default: return AppColors.primary;
    }
  }
}

class _Move {
  final int row;
  final int col;
  final int prevValue;
  final Set<int> prevNotes;
  _Move({required this.row, required this.col, required this.prevValue, required this.prevNotes});
}
