
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/neumorphic.dart';

class GameControls extends StatelessWidget {
  final int hintsUsed;
  final int mistakes;
  final bool notesMode;
  final bool canUndo;
  final VoidCallback onHint;
  final VoidCallback onUndo;
  final VoidCallback onErase;
  final VoidCallback onNotesToggle;

  const GameControls({
    super.key,
    required this.hintsUsed,
    required this.mistakes,
    required this.notesMode,
    required this.canUndo,
    required this.onHint,
    required this.onUndo,
    required this.onErase,
    required this.onNotesToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlButton(
            icon: Icons.undo_rounded,
            label: 'Undo',
            enabled: canUndo,
            onTap: canUndo ? onUndo : null,
          ),
          _ControlButton(
            icon: Icons.backspace_rounded,
            label: 'Erase',
            enabled: true,
            onTap: onErase,
          ),
          _ControlButton(
            icon: Icons.edit_note_rounded,
            label: 'Notes',
            enabled: true,
            isActive: notesMode,
            onTap: onNotesToggle,
          ),
          _ControlButton(
            icon: Icons.lightbulb_rounded,
            label: 'Hint ($hintsUsed)',
            enabled: true,
            onTap: onHint,
          ),
          _ControlButton(
            icon: Icons.warning_rounded,
            label: '$mistakes',
            enabled: false,
            color: mistakes > 0 ? AppColors.accent : AppColors.textHint,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final bool isActive;
  final VoidCallback? onTap;
  final Color? color;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.enabled,
    this.isActive = false,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ??
        (isActive
            ? AppColors.accent
            : enabled
                ? AppColors.primary
                : AppColors.textHint);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: isActive
            ? Neumo.boxConcave(radius: BorderRadius.circular(12))
            : Neumo.boxConvex(radius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: activeColor),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: activeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
