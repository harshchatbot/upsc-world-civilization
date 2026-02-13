import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Node model for [RealisticWorldMap].
///
/// [x] and [y] are normalized values in the `0..1` range, so node placement
/// stays proportional across different device sizes.
class RealisticMapNode {
  const RealisticMapNode({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
    required this.icon,
    required this.unlocked,
    this.completed = false,
    this.iconColor = const Color(0xFF5A3E2B),
  });

  final String id;
  final String label;
  final double x;
  final double y;
  final IconData icon;
  final bool unlocked;
  final bool completed;
  final Color iconColor;
}

/// A high-performance, zoomable and pannable civilization map.
///
/// Replace [backgroundAssetPath] with any high-resolution historical map image.
/// If you switch to OpenHistoricalMap-style art later, only this single asset
/// path needs to change.
class RealisticWorldMap extends StatefulWidget {
  const RealisticWorldMap({
    super.key,
    required this.nodes,
    required this.onNodeTap,
    required this.backgroundAssetPath,
    this.onLockedNodeTap,
    this.baseMapSize = const Size(2400, 1500),
    this.minScale = 0.55,
    this.maxScale = 2.8,
  });

  final List<RealisticMapNode> nodes;
  final ValueChanged<RealisticMapNode> onNodeTap;
  final ValueChanged<RealisticMapNode>? onLockedNodeTap;
  final String backgroundAssetPath;

  /// Virtual canvas size used for normalized coordinate placement.
  final Size baseMapSize;
  final double minScale;
  final double maxScale;

  @override
  State<RealisticWorldMap> createState() => _RealisticWorldMapState();
}

class _RealisticWorldMapState extends State<RealisticWorldMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  final TransformationController _transformController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<RealisticMapNode> orderedNodes = List<RealisticMapNode>.from(
      widget.nodes,
    )..sort((RealisticMapNode a, RealisticMapNode b) => a.x.compareTo(b.x));

    final List<Offset> orderedOffsets = orderedNodes
        .map((RealisticMapNode n) => _offsetForNode(n, widget.baseMapSize))
        .toList(growable: false);

    final List<Offset> lockedOffsets = orderedNodes
        .where((RealisticMapNode n) => !n.unlocked)
        .map((RealisticMapNode n) => _offsetForNode(n, widget.baseMapSize))
        .toList(growable: false);

    return ClipRect(
      child: InteractiveViewer(
        transformationController: _transformController,
        minScale: widget.minScale,
        maxScale: widget.maxScale,
        boundaryMargin: const EdgeInsets.all(240),
        constrained: false,
        child: RepaintBoundary(
          child: SizedBox(
            width: widget.baseMapSize.width,
            height: widget.baseMapSize.height,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Image.asset(
                    widget.backgroundAssetPath,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.low,
                    errorBuilder:
                        (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          return const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: <Color>[
                                  Color(0xFFDED2BC),
                                  Color(0xFFC8B08E),
                                ],
                              ),
                            ),
                          );
                        },
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _NodePathPainter(
                        nodeOffsets: orderedOffsets,
                        unlockedCount: orderedNodes
                            .where((RealisticMapNode n) => n.unlocked)
                            .length,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _FogPainter(
                        size: widget.baseMapSize,
                        lockedOffsets: lockedOffsets,
                      ),
                    ),
                  ),
                ),
                ...orderedNodes.map(
                  (RealisticMapNode node) => _EraNodeMarker(
                    node: node,
                    pulse: _pulseController,
                    mapSize: widget.baseMapSize,
                    onTap: () {
                      if (node.unlocked) {
                        widget.onNodeTap(node);
                        return;
                      }
                      widget.onLockedNodeTap?.call(node);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Offset _offsetForNode(RealisticMapNode node, Size mapSize) {
    return Offset(node.x * mapSize.width, node.y * mapSize.height);
  }
}

class _EraNodeMarker extends StatelessWidget {
  const _EraNodeMarker({
    required this.node,
    required this.mapSize,
    required this.pulse,
    required this.onTap,
  });

  final RealisticMapNode node;
  final Size mapSize;
  final Animation<double> pulse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double cx = node.x * mapSize.width;
    final double cy = node.y * mapSize.height;
    const double markerSize = 62;

    return Positioned(
      left: cx - markerSize / 2,
      top: cy - markerSize / 2,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedBuilder(
          animation: pulse,
          builder: (BuildContext context, Widget? child) {
            final double t = node.unlocked ? pulse.value : 0.0;
            final double scale = node.unlocked
                ? lerpDouble(1.0, 1.08, t)!
                : 1.0;

            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: node.unlocked ? 1.0 : 0.5,
                child: Container(
                  width: markerSize,
                  height: markerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: node.completed
                          ? <Color>[
                              const Color(0xFFCBEED1),
                              const Color(0xFF2D7A3F),
                            ]
                          : <Color>[
                              const Color(0xFFF4E6CF),
                              const Color(0xFF8C6B49),
                            ],
                    ),
                    border: Border.all(
                      color: node.unlocked
                          ? const Color(0xFFF5E5BA)
                          : const Color(0xFF797979),
                      width: 2,
                    ),
                    boxShadow: node.unlocked
                        ? <BoxShadow>[
                            BoxShadow(
                              color: const Color(0x66F6D98E),
                              blurRadius: lerpDouble(8, 18, t)!,
                              spreadRadius: lerpDouble(1, 4, t)!,
                            ),
                          ]
                        : const <BoxShadow>[],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Icon(node.icon, color: node.iconColor, size: 26),
                      if (node.completed)
                        const Positioned(
                          right: 0,
                          bottom: 0,
                          child: Icon(
                            Icons.check_circle,
                            color: Color(0xFF1F8B3A),
                            size: 18,
                          ),
                        )
                      else if (!node.unlocked)
                        const Positioned(
                          right: 0,
                          bottom: 0,
                          child: Icon(
                            Icons.lock,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FogPainter extends CustomPainter {
  const _FogPainter({required this.size, required this.lockedOffsets});

  final Size size;
  final List<Offset> lockedOffsets;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final Paint baseFog = Paint()..color = const Color(0x4D000000);
    canvas.drawRect(Offset.zero & size, baseFog);

    for (final Offset center in lockedOffsets) {
      final Rect rect = Rect.fromCircle(center: center, radius: 230);
      final Paint patch = Paint()
        ..shader = const RadialGradient(
          colors: <Color>[Color(0x33000000), Color(0x99000000)],
          stops: <double>[0.2, 1],
        ).createShader(rect);
      canvas.drawCircle(center, 230, patch);
    }
  }

  @override
  bool shouldRepaint(covariant _FogPainter oldDelegate) {
    return oldDelegate.lockedOffsets.length != lockedOffsets.length ||
        oldDelegate.size != size;
  }
}

class _NodePathPainter extends CustomPainter {
  const _NodePathPainter({
    required this.nodeOffsets,
    required this.unlockedCount,
  });

  final List<Offset> nodeOffsets;
  final int unlockedCount;

  @override
  void paint(Canvas canvas, Size size) {
    if (nodeOffsets.length < 2) {
      return;
    }

    final Paint lockedPathPaint = Paint()
      ..color = const Color(0x70F2D7AA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final Paint unlockedPathPaint = Paint()
      ..color = const Color(0xFFC39A5E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final Path fullPath = Path()
      ..moveTo(nodeOffsets.first.dx, nodeOffsets.first.dy);
    for (int i = 1; i < nodeOffsets.length; i++) {
      final Offset prev = nodeOffsets[i - 1];
      final Offset curr = nodeOffsets[i];
      final double midX = (prev.dx + curr.dx) / 2;
      fullPath.cubicTo(
        midX,
        prev.dy - 28,
        midX,
        curr.dy + 28,
        curr.dx,
        curr.dy,
      );
    }

    canvas.drawPath(fullPath, lockedPathPaint);

    if (unlockedCount < 2) {
      return;
    }

    final List<Offset> unlocked = nodeOffsets.take(unlockedCount).toList();
    final Path unlockedPath = Path()
      ..moveTo(unlocked.first.dx, unlocked.first.dy);
    for (int i = 1; i < unlocked.length; i++) {
      final Offset prev = unlocked[i - 1];
      final Offset curr = unlocked[i];
      final double midX = (prev.dx + curr.dx) / 2;
      unlockedPath.cubicTo(
        midX,
        prev.dy - 28,
        midX,
        curr.dy + 28,
        curr.dx,
        curr.dy,
      );
    }

    canvas.drawPath(unlockedPath, unlockedPathPaint);
  }

  @override
  bool shouldRepaint(covariant _NodePathPainter oldDelegate) {
    return oldDelegate.nodeOffsets.length != nodeOffsets.length ||
        oldDelegate.unlockedCount != unlockedCount;
  }
}
