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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor      = isDark ? const Color(0xFF94A3B8) : Colors.grey.shade500;
    final labelColor     = isDark ? const Color(0xFFCBD5E1) : Colors.grey.shade700;
    final chipBg         = isDark ? const Color(0xFF2D3748) : const Color(0xFFF0F4FF);
    final chipBorderUnsel = isDark ? const Color(0xFF4A5568) : const Color(0xFFCDD5F0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(fontSize: 13, color: labelColor),
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
                    color: selected
                        ? Colors.white
                        : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF0F3460)),
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                selected: selected,
                selectedColor: const Color(0xFF0F3460),
                backgroundColor: chipBg,
                side: BorderSide(
                  color: selected
                      ? const Color(0xFF0F3460)
                      : chipBorderUnsel,
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
