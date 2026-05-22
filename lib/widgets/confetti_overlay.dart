import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ConfettiOverlay extends StatefulWidget {
  final int particleCount;
  final double durationSeconds;

  const ConfettiOverlay({
    super.key,
    this.particleCount = 30,
    this.durationSeconds = 2.0,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: (widget.durationSeconds * 1000).round()),
      vsync: this,
    );
    _particles = List.generate(widget.particleCount, (i) => _ConfettiParticle());
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          children: _particles.map((p) {
            final progress = _controller.value;
            final x = p.startX + (p.endX - p.startX) * progress;
            final y = p.startY + (p.endY - p.startY) * progress * progress;
            final opacity = (1 - progress) * (1 - progress);
            final rotation = p.rotation * progress * 10;
            final scale = progress < 0.5
                ? 1.0
                : 1.0 - ((progress - 0.5) * 2 * 0.5);
            final color = p.color;

            return Positioned(
              left: x * MediaQuery.of(context).size.width,
              top: y * MediaQuery.of(context).size.height,
              child: Opacity(
                opacity: opacity,
                child: Transform.rotate(
                  angle: rotation,
                  child: Transform.scale(
                    scale: scale.clamp(0.0, 1.0),
                    child: Container(
                      width: p.size,
                      height: p.size * (p.isSquare ? 1.0 : 0.6),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: p.isSquare
                            ? BorderRadius.circular(2)
                            : BorderRadius.circular(p.size / 2),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ConfettiParticle {
  final double startX = 0.3 + (0.4 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000).clamp(0, 1).toDouble();
  final double startY = -0.05;
  final double endX;
  final double endY = 0.95 + (0.05 * (DateTime.now().microsecondsSinceEpoch % 100) / 100);
  final double size;
  final double rotation;
  final Color color;
  final bool isSquare;

  _ConfettiParticle()
      : endX = (DateTime.now().microsecondsSinceEpoch % 1000) / 1000,
        size = 6 + (DateTime.now().microsecondsSinceEpoch % 8).toDouble(),
        rotation = 3.14 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000,
        color = [
          AppTheme.accentPrimary,
          AppTheme.accentAmber,
          AppTheme.accentGreen,
          AppTheme.accentBlue,
          AppTheme.accentRed,
          AppTheme.priorityCritical,
          AppTheme.priorityMedium,
        ][DateTime.now().microsecondsSinceEpoch % 7],
        isSquare = DateTime.now().microsecondsSinceEpoch % 2 == 0;
}

// Show confetti as an overlay
void showConfetti(BuildContext context, {int count = 30, double duration = 2.0}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    builder: (_) => ConfettiOverlay(
      particleCount: count,
      durationSeconds: duration,
    ),
  );
}

// Confetti levels
void showMinorConfetti(BuildContext context) {
  showConfetti(context, count: 10, duration: 1.5);
}

void showMediumConfetti(BuildContext context) {
  showConfetti(context, count: 30, duration: 2.0);
}

void showMajorConfetti(BuildContext context) {
  showConfetti(context, count: 80, duration: 3.0);
}

void showEpicConfetti(BuildContext context) {
  showConfetti(context, count: 200, duration: 4.0);
}
