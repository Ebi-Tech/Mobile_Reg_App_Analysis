import 'package:flutter/material.dart';

class ChipSelector extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const ChipSelector({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: options.map((opt) {
              final selected = opt == value;
              return ChoiceChip(
                label: Text(
                  opt,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF0F3460),
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                selected: selected,
                selectedColor: const Color(0xFF0F3460),
                backgroundColor: const Color(0xFFF0F4FF),
                side: BorderSide(
                  color: selected
                      ? const Color(0xFF0F3460)
                      : const Color(0xFFCDD5F0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                onSelected: (_) => onChanged(opt),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
