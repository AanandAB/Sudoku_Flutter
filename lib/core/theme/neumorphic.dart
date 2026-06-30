
import 'package:flutter/material.dart';
import 'app_colors.dart';

class Neumo {
  Neumo._();

  /// Outer convex shadow (raised button, card)
  static List<BoxShadow> get convex => const [
    BoxShadow(
      color: AppColors.shadowDark,
      offset: Offset(6, 6),
      blurRadius: 12,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(-6, -6),
      blurRadius: 12,
      spreadRadius: 1,
    ),
  ];

  /// Inner concave shadow (pressed, inset)
  static List<BoxShadow> get concave => const [
    BoxShadow(
      color: AppColors.shadowDark,
      offset: Offset(-4, -4),
      blurRadius: 6,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(4, 4),
      blurRadius: 6,
      spreadRadius: 1,
    ),
  ];

  /// Subtle convex for small elements
  static List<BoxShadow> get convexSmall => const [
    BoxShadow(
      color: AppColors.shadowDark,
      offset: Offset(3, 3),
      blurRadius: 6,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(-3, -3),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  /// Flat surface
  static List<BoxShadow> get flat => const [
    BoxShadow(
      color: AppColors.shadowDark,
      offset: Offset(1, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  /// Convex with color tint
  static List<BoxShadow> convexTinted(Color color) => [
    BoxShadow(
      color: color.withAlpha(89),
      offset: const Offset(6, 6),
      blurRadius: 12,
      spreadRadius: 1,
    ),
    const BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(-6, -6),
      blurRadius: 12,
      spreadRadius: 1,
    ),
  ];

  /// Decorated container (convex)
  static BoxDecoration boxConvex({Color? color, BorderRadius? radius}) {
    return BoxDecoration(
      color: color ?? AppColors.background,
      borderRadius: radius ?? BorderRadius.circular(16),
      boxShadow: convex,
    );
  }

  /// Decorated container (concave — inset look)
  static BoxDecoration boxConcave({Color? color, BorderRadius? radius}) {
    return BoxDecoration(
      color: color ?? AppColors.surfaceDark,
      borderRadius: radius ?? BorderRadius.circular(16),
      boxShadow: concave,
    );
  }

  /// Decorated container (flat)
  static BoxDecoration boxFlat({Color? color, BorderRadius? radius}) {
    return BoxDecoration(
      color: color ?? AppColors.background,
      borderRadius: radius ?? BorderRadius.circular(16),
      boxShadow: flat,
    );
  }
}

/// Neumorphic button widget
class NeumoButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final BorderRadius radius;
  final Color? color;
  final Color? pressedColor;

  const NeumoButton({
    super.key,
    required this.child,
    this.onTap,
    this.width,
    this.height = 56,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.radius = const BorderRadius.all(Radius.circular(16)),
    this.color,
    this.pressedColor,
  });

  @override
  State<NeumoButton> createState() => _NeumoButtonState();
}

class _NeumoButtonState extends State<NeumoButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.onTap != null ? (_) { setState(() => _pressed = false); widget.onTap?.call(); } : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: _pressed
              ? (widget.pressedColor ?? AppColors.surfaceDark)
              : (widget.color ?? AppColors.background),
          borderRadius: widget.radius,
          boxShadow: _pressed ? Neumo.concave : Neumo.convex,
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}

/// Neumorphic icon button (circular)
class NeumoIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color? color;
  final Color? iconColor;

  const NeumoIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 48,
    this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: Neumo.boxConvex(
          color: color,
          radius: BorderRadius.circular(size / 2),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: size * 0.5),
      ),
    );
  }
}
