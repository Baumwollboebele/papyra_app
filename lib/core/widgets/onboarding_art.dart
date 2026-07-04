import 'package:flutter/material.dart';

/// Lightweight, license-free custom-painted illustration for onboarding and
/// empty states: a soft halo behind a stylized stack of document cards with an
/// icon badge. Colors derive from the theme so it adapts to light/dark.
class OnboardingArt extends StatelessWidget {
  const OnboardingArt({
    required this.icon,
    required this.color,
    this.size = 220,
    super.key,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ArtPainter(
          color: color,
          surface: Theme.of(context).colorScheme.surface,
        ),
        child: Center(
          child: Container(
            width: size * 0.32,
            height: size * 0.32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: size * 0.16),
          ),
        ),
      ),
    );
  }
}

class _ArtPainter extends CustomPainter {
  _ArtPainter({required this.color, required this.surface});

  final Color color;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    // Soft halo.
    canvas.drawCircle(
      center,
      size.width * 0.46,
      Paint()..color = color.withValues(alpha: 0.10),
    );
    canvas.drawCircle(
      center,
      size.width * 0.36,
      Paint()..color = color.withValues(alpha: 0.14),
    );

    // A little stack of tilted "document" cards.
    final cardPaint = Paint()..color = surface;
    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    void card(double dx, double dy, double angle) {
      canvas.save();
      canvas.translate(center.dx + dx, center.dy + dy);
      canvas.rotate(angle);
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: size.width * 0.5,
          height: size.width * 0.62,
        ),
        const Radius.circular(14),
      );
      canvas.drawRRect(rect, cardPaint);
      canvas.drawRRect(rect, borderPaint);
      canvas.restore();
    }

    card(-size.width * 0.10, size.height * 0.02, -0.18);
    card(size.width * 0.10, -size.height * 0.02, 0.12);
  }

  @override
  bool shouldRepaint(covariant _ArtPainter old) =>
      old.color != color || old.surface != surface;
}
