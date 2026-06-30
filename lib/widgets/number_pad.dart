
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/neumorphic.dart';

class NumberPad extends StatelessWidget {
  final void Function(int number) onNumber;

  const NumberPad({super.key, required this.onNumber});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final btnSize = (size.width - 56) / 9; // 9 buttons with spacing

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(9, (i) {
          final number = i + 1;
          return GestureDetector(
            onTap: () => onNumber(number),
            child: Container(
              width: btnSize.clamp(32, 48),
              height: btnSize.clamp(40, 56),
              decoration: Neumo.boxConvex(radius: BorderRadius.circular(12)),
              child: Center(
                child: Text(
                  '$number',
                  style: TextStyle(
                    fontSize: btnSize.clamp(32, 48) * 0.48,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
