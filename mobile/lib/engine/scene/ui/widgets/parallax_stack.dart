import 'package:flutter/material.dart';

import '../../models/scene_layer.dart';

class ParallaxStack extends StatefulWidget {
  const ParallaxStack({super.key, required this.layers});

  final List<SceneLayer> layers;

  @override
  State<ParallaxStack> createState() => _ParallaxStackState();
}

class _ParallaxStackState extends State<ParallaxStack> {
  double _dragX = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (DragUpdateDetails details) {
        setState(() {
          _dragX = (_dragX + details.delta.dx).clamp(-80, 80);
        });
      },
      onPanEnd: (_) {
        setState(() {
          _dragX = 0;
        });
      },
      child: Stack(
        fit: StackFit.expand,
        children: widget.layers
            .map((SceneLayer layer) {
              final double shift = _dragX * layer.parallax;
              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: shift),
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                builder: (BuildContext context, double value, Widget? child) {
                  return Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(value, 0),
                      child: child,
                    ),
                  );
                },
                child: Image.asset(
                  layer.asset,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.low,
                  errorBuilder:
                      (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                      ) {
                        return const SizedBox.shrink();
                      },
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}
