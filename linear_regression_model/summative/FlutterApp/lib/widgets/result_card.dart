import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final double score;

  const ResultCard({super.key, required this.score});

  // Colour-code by score bracket
  Color _bandColor(double s) {
    if (s >= 85) return const Color(0xFF2E7D32); // green  — high performer
    if (s >= 70) return const Color(0xFF1565C0); // blue   — on track
    if (s >= 60) return const Color(0xFFF57F17); // amber  — needs support
    return const Color(0xFFC62828);               // red    — at risk
  }

  String _bandLabel(double s) {
    if (s >= 85) return 'High Performer';
    if (s >= 70) return 'On Track';
    if (s >= 60) return 'Needs Support';
    return 'At Risk';
  }

  IconData _bandIcon(double s) {
    if (s >= 85) return Icons.emoji_events_rounded;
    if (s >= 70) return Icons.thumb_up_rounded;
    if (s >= 60) return Icons.warning_amber_rounded;
    return Icons.report_problem_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final color = _bandColor(score);
    final label = _bandLabel(score);
    final icon  = _bandIcon(score);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 48),
          const SizedBox(height: 8),
          Text(
            'Predicted Exam Score',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '${score.toStringAsFixed(1)} pts',
            style: Theme.of(context).textTheme.displaySmall!.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Chip(
            label: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          const SizedBox(height: 6),
          Text(
            'Valid range: 55 – 101 points',
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
