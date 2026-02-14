import 'package:flutter/material.dart';

class InteractionOverlay extends StatefulWidget {
  const InteractionOverlay({
    super.key,
    required this.prompt,
    required this.onSuccess,
  });

  final String prompt;
  final VoidCallback onSuccess;

  @override
  State<InteractionOverlay> createState() => _InteractionOverlayState();
}

class _InteractionOverlayState extends State<InteractionOverlay> {
  Offset _emberPosition = const Offset(40, 110);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: const Color(0x99000000),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Rect target = Rect.fromCenter(
              center: Offset(
                constraints.maxWidth - 70,
                constraints.maxHeight - 90,
              ),
              width: 80,
              height: 80,
            );

            return Stack(
              children: <Widget>[
                Positioned(
                  left: 16,
                  right: 16,
                  top: 16,
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      widget.prompt,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Positioned.fromRect(
                  rect: target,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFFFD080),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.local_fire_department,
                        color: Color(0xFFFFD080),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: _emberPosition.dx,
                  top: _emberPosition.dy,
                  child: Draggable<String>(
                    data: 'ember',
                    feedback: const _EmberToken(opacity: 1),
                    childWhenDragging: const _EmberToken(opacity: 0.25),
                    onDragEnd: (DraggableDetails details) {
                      final Offset p = details.offset;
                      final bool hit = target.contains(
                        Offset(p.dx + 20, p.dy + 20),
                      );
                      if (hit) {
                        widget.onSuccess();
                        return;
                      }
                      setState(() {
                        _emberPosition = const Offset(40, 110);
                      });
                    },
                    child: const _EmberToken(opacity: 1),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmberToken extends StatelessWidget {
  const _EmberToken({required this.opacity});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFFFA340),
        ),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(Icons.blur_circular, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
