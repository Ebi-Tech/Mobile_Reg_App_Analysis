import 'dart:math' as math;
import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final double score;
  const ResultCard({super.key, required this.score});

  Color _color(double s) {
    if (s >= 85) return const Color(0xFF2E7D32);
    if (s >= 70) return const Color(0xFF0F3460);
    if (s >= 60) return const Color(0xFFF57F17);
    return const Color(0xFFC62828);
  }

  String _label(double s) {
    if (s >= 85) return 'High Performer';
    if (s >= 70) return 'On Track';
    if (s >= 60) return 'Needs Support';
    return 'At Risk';
  }

  String _advice(double s) {
    if (s >= 85) return 'Excellent! Keep up the momentum.';
    if (s >= 70) return 'Doing well — consistent effort will push further.';
    if (s >= 60) return 'Consider tutoring and increased parental support.';
    return 'Immediate academic intervention recommended.';
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(score);
    // Normalize score from [55, 101] to [0.0, 1.0]
    final targetProgress = ((score - 55) / 46).clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: targetProgress),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOutCubic,
      builder: (context, animProgress, _) {
        final displayScore = 55 + animProgress * 46;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(40),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: color.withAlpha(60), width: 1.5),
          ),
          child: Column(
            children: [
              Text(
                'Predicted Exam Score',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 20),

              // Arc gauge
              SizedBox(
                width: 190,
                height: 190,
                child: CustomPaint(
                  painter: _ArcPainter(progress: animProgress, color: color),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayScore.toStringAsFixed(1),
                          style: TextStyle(
                            color: color,
                            fontSize: 46,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                        Text(
                          'pts',
                          style: TextStyle(
                            color: color.withAlpha(180),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Band pill
              AnimatedOpacity(
                opacity: animProgress > 0.5 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    _label(score),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              AnimatedOpacity(
                opacity: animProgress > 0.7 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: Text(
                  _advice(score),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ),

              const SizedBox(height: 8),
              Text(
                'Valid range: 55 – 101 pts',
                style: TextStyle(color: Colors.grey[400], fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.43;
    // Start at 135° (bottom-left), sweep 270° clockwise
    const startAngle = math.pi * 0.75;
    const totalSweep = math.pi * 1.5;

    final trackPaint = Paint()
      ..color = const Color(0xFFEEF1FA)
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background track
    canvas.drawArc(rect, startAngle, totalSweep, false, trackPaint);

    // Filled progress
    if (progress > 0) {
      canvas.drawArc(rect, startAngle, totalSweep * progress, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.color != color;
}
