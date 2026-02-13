import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/era_node.dart';
import '../../../data/models/user_progress.dart';
import '../../home/providers/home_providers.dart';
import '../providers/map_providers.dart';
import '../widgets/realistic_world_map.dart';

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
              const double oldMapWidth = 1400;
              const double oldMapHeight = 900;

              return RealisticWorldMap(
                backgroundAssetPath:
                    'assets/maps/world_ancient_parchment_hd.webp',
                nodes: nodes
                    .map((EraNode node) {
                      final bool unlocked =
                          node.order <= progress.unlockedOrder;
                      final bool completed = progress.completedNodeIds.contains(
                        node.id,
                      );
                      return RealisticMapNode(
                        id: node.id,
                        label: node.title,
                        x: node.dx / oldMapWidth,
                        y: node.dy / oldMapHeight,
                        icon: _iconForOrder(node.order),
                        unlocked: unlocked,
                        completed: completed,
                      );
                    })
                    .toList(growable: false),
                onNodeTap: (RealisticMapNode tappedNode) {
                  context.push('/scene/${tappedNode.id}');
                },
                onLockedNodeTap: (RealisticMapNode lockedNode) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${lockedNode.label} is locked. Complete earlier eras first.',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

IconData _iconForOrder(int order) {
  switch (order) {
    case 0:
      return Icons.forest;
    case 1:
      return Icons.account_balance;
    case 2:
      return Icons.menu_book;
    case 3:
      return Icons.temple_hindu;
    case 4:
      return Icons.auto_awesome;
    default:
      return Icons.place;
  }
}
