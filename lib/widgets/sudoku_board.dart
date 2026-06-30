
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
    final boardSize = size.width - 32;
    final cellSize = boardSize / 9;

    return Container(
      width: boardSize,
      height: boardSize,
      decoration: Neumo.boxConvex(radius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
          ),
          itemCount: 81,
          itemBuilder: (context, index) {
            final row = index ~/ 9;
            final col = index % 9;
            final idx = row * 9 + col;
            final isSelected = row == selectedRow && col == selectedCol;
            final value = board[row][col];
            final isGivenCell = puzzle[row][col] != 0;

            // ── Border logic: thick for 3x3 box edges, thin for cell dividers ──
            final isTopEdge = row % 3 == 0;
            final isLeftEdge = col % 3 == 0;
            final isBottomEdge = row == 8 || row % 3 == 2;
            final isRightEdge = col == 8 || col % 3 == 2;
            final isOuterTop = row == 0;
            final isOuterLeft = col == 0;
            final isOuterBottom = row == 8;
            final isOuterRight = col == 8;

            const boxBorderColor = Color(0xFF5B6ABF);    // primary indigo - thick
            const cellBorderColor = Color(0xFFC5CBE8);    // lighter - thin

            return GestureDetector(
              onTap: () => onCellTap(row, col),
              child: Container(
                decoration: BoxDecoration(
                  color: cellColors[idx] ?? Colors.transparent,
                  borderRadius: isSelected ? BorderRadius.circular(6) : null,
                  border: Border(
                    top: BorderSide(
                      color: isOuterTop || isTopEdge ? boxBorderColor : cellBorderColor,
                      width: isOuterTop ? 2.5 : (isTopEdge ? 2.0 : 0.6),
                    ),
                    left: BorderSide(
                      color: isOuterLeft || isLeftEdge ? boxBorderColor : cellBorderColor,
                      width: isOuterLeft ? 2.5 : (isLeftEdge ? 2.0 : 0.6),
                    ),
                    bottom: BorderSide(
                      color: isOuterBottom || isBottomEdge ? boxBorderColor : cellBorderColor,
                      width: isOuterBottom ? 2.5 : (isBottomEdge ? 2.0 : 0.6),
                    ),
                    right: BorderSide(
                      color: isOuterRight || isRightEdge ? boxBorderColor : cellBorderColor,
                      width: isOuterRight ? 2.5 : (isRightEdge ? 2.0 : 0.6),
                    ),
                  ),
                ),
                child: Center(
                  child: value != 0
                      ? Text(
                          '$value',
                          style: TextStyle(
                            fontSize: cellSize * 0.38,
                            fontWeight: isGivenCell
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isGivenCell
                                ? AppColors.cellGiven
                                : AppColors.cellUser,
                          ),
                        )
                      : _buildNotes(row, col, cellSize),
                ),
              ),
            );
          },
        ),
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
