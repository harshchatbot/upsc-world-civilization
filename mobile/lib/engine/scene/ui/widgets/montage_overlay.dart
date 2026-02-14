import 'package:flutter/material.dart';

class MontageOverlay extends StatelessWidget {
  const MontageOverlay({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xAA000000),
        child: Center(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items
                .map(
                  (String item) => Chip(
                    backgroundColor: const Color(0xFFEAD9BC),
                    label: Text(item),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ),
    );
  }
}
