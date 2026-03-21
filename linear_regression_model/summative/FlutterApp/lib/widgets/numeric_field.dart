import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumericField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int min;
  final int max;

  const NumericField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.min,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixIcon: const Icon(Icons.edit_outlined, size: 18),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Required';
          final n = int.tryParse(value);
          if (n == null) return 'Enter a whole number';
          if (n < min || n > max) return 'Must be between $min and $max';
          return null;
        },
      ),
    );
  }
}
