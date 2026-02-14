import 'package:flutter/material.dart';

class NextButton extends StatelessWidget {
  const NextButton({
    super.key,
    required this.enabled,
    required this.onPressed,
    this.label = 'Next',
  });

  final bool enabled;
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        child: Text(label),
      ),
    );
  }
}
