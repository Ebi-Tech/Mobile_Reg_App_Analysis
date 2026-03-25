import 'package:flutter/material.dart';

class SliderField extends StatelessWidget {
  final String label;
  final IconData icon;
  final int value;
  final int min;
  final int max;
  final String? unit;
  final ValueChanged<int> onChanged;

  const SliderField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F3460),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  unit != null ? '$value $unit' : '$value',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF0F3460),
              inactiveTrackColor: const Color(0xFFDDE4F5),
              thumbColor: const Color(0xFF0F3460),
              overlayColor: const Color(0xFF0F3460).withAlpha(30),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: max - min,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$min', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                Text('$max', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
