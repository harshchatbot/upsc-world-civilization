import 'package:flutter/material.dart';
import '../../../data/models/era_node.dart';

class EraNodeWidget extends StatelessWidget {
  const EraNodeWidget({
    super.key,
    required this.node,
    required this.unlocked,
    required this.completed,
    required this.onTap,
  });

  final EraNode node;
  final bool unlocked;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double opacity = unlocked ? 1 : 0.35;
    final Color border = completed
        ? Colors.green.shade700
        : (unlocked ? const Color(0xFF5A3E2B) : Colors.grey.shade600);

    return Positioned(
      left: node.dx,
      top: node.dy,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 350),
        opacity: opacity,
        child: GestureDetector(
          onTap: unlocked ? onTap : null,
          child: AnimatedScale(
            scale: completed ? 1.06 : 1,
            duration: const Duration(milliseconds: 350),
            child: Container(
              width: 170,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border, width: 2),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    blurRadius: 8,
                    offset: Offset(0, 4),
                    color: Color(0x1A000000),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      node.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: unlocked ? Colors.black : Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (completed)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    )
                  else if (!unlocked)
                    const Icon(Icons.lock, color: Colors.grey, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
