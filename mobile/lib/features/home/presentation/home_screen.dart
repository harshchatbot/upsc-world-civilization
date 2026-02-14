import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/language_toggle_button.dart';
import '../../../core/utils/level_utils.dart';
import '../../../data/models/user_progress.dart';
import '../providers/home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<UserProgress> progressAsync = ref.watch(
      progressControllerProvider,
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: progressAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace stackTrace) =>
                const Center(child: Text('Failed to load progress.')),
            data: (UserProgress progress) {
              final int level = levelFromXp(progress.xp);
              final int remaining = xpToNextLevel(progress.xp);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Align(
                    alignment: Alignment.topRight,
                    child: LanguageToggleButton(),
                  ),
                  const Spacer(),
                  Text(
                    'UPSC World: Civilization',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Build your command over ancient Indian history through era-by-era strategic learning.',
                  ),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'XP: ${progress.xp}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text('Level $level • $remaining XP to next'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => context.go('/map'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Enter Civilization'),
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
