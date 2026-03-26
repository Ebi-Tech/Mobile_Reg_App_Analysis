import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumericCard extends StatefulWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final int min;
  final int max;
  final String? unit;

  const NumericCard({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    required this.min,
    required this.max,
    this.unit,
  });

  @override
  State<NumericCard> createState() => _NumericCardState();
}

class _NumericCardState extends State<NumericCard> {
  bool _focused = false;

  static const _kNavy = Color(0xFF0F3460);

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _focused ? _kNavy : const Color(0xFFE8EDF8),
            width: _focused ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _focused
                  ? _kNavy.withAlpha(35)
                  : Colors.black.withAlpha(10),
              blurRadius: _focused ? 14 : 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon badge — flips colour on focus
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: _focused ? _kNavy : const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.icon,
                size: 17,
                color: _focused ? Colors.white : _kNavy,
              ),
            ),
            const SizedBox(height: 10),

            // Field label
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),

            // Bare input — large bold number, no visible border
            TextFormField(
              controller: widget.controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
                height: 1.2,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                hintText: '—',
                hintStyle: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCDD5F0),
                  height: 1.2,
                ),
                errorStyle: const TextStyle(fontSize: 10, height: 1.2),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                final n = int.tryParse(v);
                if (n == null) return 'Enter a number';
                if (n < widget.min || n > widget.max) {
                  return '${widget.min} – ${widget.max}';
                }
                return null;
              },
            ),
            const SizedBox(height: 4),

            // Range hint
            Text(
              'Range: ${widget.min} – ${widget.max}'
              '${widget.unit != null ? ' ${widget.unit}' : ''}',
              style: const TextStyle(fontSize: 11, color: Color(0xFFB0B8D0)),
            ),
          ],
        ),
      ),
    );
  }
}
