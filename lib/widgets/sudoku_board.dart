
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/neumorphic.dart';

class SudokuBoard extends StatelessWidget {
  final List<List<int>> board;
  final List<List<int>> puzzle;
  final List<List<Set<int>>> notes;
  final int selectedRow;
  final int selectedCol;
  final Map<int, Color> cellColors;
  final void Function(int row, int col) onCellTap;

  const SudokuBoard({
    super.key,
    required this.board,
    required this.puzzle,
    required this.notes,
    required this.selectedRow,
    required this.selectedCol,
    required this.cellColors,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final boardSize = size.width - 32; // 16px padding each side
    final cellSize = boardSize / 9;

    return Container(
      width: boardSize,
      height: boardSize,
      decoration: Neumo.boxConvex(radius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(4),
      child: Column(
        children: List.generate(3, (br) {
          return Expanded(
            child: Row(
              children: List.generate(3, (bc) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      top: br > 0 ? 1.5 : 0,
                      bottom: br < 2 ? 1.5 : 0,
                      left: bc > 0 ? 1.5 : 0,
                      right: bc < 2 ? 1.5 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark.withAlpha(76),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, innerIdx) {
                        final r = br * 3 + innerIdx ~/ 3;
                        final c = bc * 3 + innerIdx % 3;
                        final idx = r * 9 + c;
                        final isSelected = r == selectedRow && c == selectedCol;
                        final value = board[r][c];
                        final isGivenCell = puzzle[r][c] != 0;

                        return GestureDetector(
                          onTap: () => onCellTap(r, c),
                          child: Container(
                            decoration: BoxDecoration(
                              color: cellColors[idx] ?? Colors.transparent,
                              borderRadius: isSelected
                                  ? BorderRadius.circular(8)
                                  : null,
                              border: isSelected
                                  ? Border.all(color: AppColors.primary, width: 2)
                                  : Border.all(
                                      color: AppColors.textHint.withAlpha(38),
                                      width: 0.5,
                                    ),
                            ),
                            child: Center(
                              child: value != 0
                                  ? Text(
                                      '$value',
                                      style: TextStyle(
                                        fontSize: cellSize * 0.35,
                                        fontWeight: isGivenCell
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isGivenCell
                                            ? AppColors.cellGiven
                                            : AppColors.cellUser,
                                      ),
                                    )
                                  : _buildNotes(r, c, cellSize),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNotes(int row, int col, double cellSize) {
    final noteSet = notes[row][col];
    if (noteSet.isEmpty) return const SizedBox.shrink();

    final noteSize = cellSize * 0.12;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        final num = index + 1;
        return Center(
          child: Text(
            noteSet.contains(num) ? '$num' : '',
            style: TextStyle(
              fontSize: noteSize,
              fontWeight: FontWeight.w500,
              color: AppColors.cellNote,
            ),
          ),
        );
      },
    );
  }
}
