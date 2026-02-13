import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/era_node.dart';
import '../../../data/models/user_progress.dart';
import '../../home/providers/home_providers.dart';
import '../providers/map_providers.dart';
import '../widgets/era_node_widget.dart';

class CivilizationMapScreen extends ConsumerWidget {
  const CivilizationMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<EraNode>> nodesAsync = ref.watch(eraNodesProvider);
    final AsyncValue<UserProgress> progressAsync = ref.watch(
      progressControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Civilization Map')),
      body: nodesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) =>
            const Center(child: Text('Failed to load map nodes.')),
        data: (List<EraNode> nodes) {
          return progressAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace stackTrace) =>
                const Center(child: Text('Failed to load progress.')),
            data: (UserProgress progress) {
              return InteractiveViewer(
                minScale: 0.7,
                maxScale: 2.0,
                constrained: false,
                child: Container(
                  width: 1400,
                  height: 900,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[Color(0xFFE5D7C0), Color(0xFFCFBB99)],
                    ),
                  ),
                  child: Stack(
                    children: <Widget>[
                      CustomPaint(
                        size: const Size(1400, 900),
                        painter: _PathPainter(),
                      ),
                      ...nodes.map((EraNode node) {
                        final bool unlocked =
                            node.order <= progress.unlockedOrder;
                        final bool completed = progress.completedNodeIds
                            .contains(node.id);
                        return EraNodeWidget(
                          node: node,
                          unlocked: unlocked,
                          completed: completed,
                          onTap: () => context.push('/scene/${node.id}'),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0x995A3E2B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final Path path = Path()
      ..moveTo(220, 570)
      ..quadraticBezierTo(380, 460, 450, 440)
      ..quadraticBezierTo(630, 370, 720, 350)
      ..quadraticBezierTo(920, 300, 980, 300)
      ..quadraticBezierTo(1160, 240, 1240, 230);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
