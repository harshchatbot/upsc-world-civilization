import 'package:flutter/material.dart';

class DialogueBox extends StatelessWidget {
  const DialogueBox({super.key, required this.speaker, required this.text});

  final String speaker;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF5A3E2B), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (speaker.trim().isNotEmpty)
            Text(speaker, style: const TextStyle(fontWeight: FontWeight.w700)),
          if (speaker.trim().isNotEmpty) const SizedBox(height: 6),
          Text(text),
        ],
      ),
    );
  }
}
