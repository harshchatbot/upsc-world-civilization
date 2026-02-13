import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/era_node.dart';
import '../../../data/repositories/content_repository.dart';

final FutureProvider<List<EraNode>> eraNodesProvider =
    FutureProvider<List<EraNode>>((Ref ref) async {
      return ref.read(contentRepositoryProvider).fetchNodes();
    });
