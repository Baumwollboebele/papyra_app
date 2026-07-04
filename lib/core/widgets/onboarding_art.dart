import 'package:flutter/material.dart';

/// Clean, license-free illustration for onboarding and empty states: a gradient
/// "medallion" (concentric soft rings + a filled circle with a subtle gradient)
/// holding a single centered icon. Adapts to the theme and reads as calm,
/// professional and trustworthy — and looks right with any icon.
class OnboardingArt extends StatelessWidget {
  const OnboardingArt({
    required this.icon,
    required this.color,
    this.size = 200,
    super.key,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer soft rings.
          _ring(size, color.withValues(alpha: isDark ? 0.10 : 0.07)),
          _ring(size * 0.78, color.withValues(alpha: isDark ? 0.16 : 0.11)),
          // Gradient medallion.
          Container(
            width: size * 0.52,
            height: size * 0.52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(color, Colors.white, 0.12)!,
                  Color.lerp(color, Colors.black, 0.14)!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: size * 0.22),
          ),
        ],
      ),
    );
  }

  Widget _ring(double diameter, Color color) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
