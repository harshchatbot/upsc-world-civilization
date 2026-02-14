import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/era_node.dart';
import '../../../data/models/user_progress.dart';
import '../../home/providers/home_providers.dart';
import '../providers/map_providers.dart';
import '../widgets/realistic_world_map.dart';

class CivilizationMapScreen extends ConsumerStatefulWidget {
  const CivilizationMapScreen({super.key, this.focusNodeId});

  final String? focusNodeId;

  @override
  ConsumerState<CivilizationMapScreen> createState() =>
      _CivilizationMapScreenState();
}

class _CivilizationMapScreenState extends ConsumerState<CivilizationMapScreen> {
  final RealisticWorldMapController _mapController =
      RealisticWorldMapController();
  bool _didAnimateRequestedFocus = false;

  @override
  Widget build(BuildContext context) {
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
              final List<RealisticMapNode> mapNodes = nodes
                  .map((EraNode node) {
                    final bool unlocked = node.order <= progress.unlockedOrder;
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
                  .toList(growable: false);

              if (!_didAnimateRequestedFocus && widget.focusNodeId != null) {
                _didAnimateRequestedFocus = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _mapController.focusOnNode(
                    widget.focusNodeId!,
                    duration: const Duration(milliseconds: 850),
                  );
                });
              }

              return RealisticWorldMap(
                controller: _mapController,
                backgroundAssetPath: 'assets/maps/world_ancient_parchment.png',
                initialScale: 1.4,
                nodes: mapNodes,
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
