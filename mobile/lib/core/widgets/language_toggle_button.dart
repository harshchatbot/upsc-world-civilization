import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/providers/language_provider.dart';
import '../localization/app_language.dart';

class LanguageToggleButton extends ConsumerWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLanguage current =
        ref.watch(appLanguageProvider).value ?? AppLanguage.en;

    return PopupMenuButton<AppLanguage>(
      tooltip: 'Language',
      initialValue: current,
      onSelected: (AppLanguage selected) {
        ref.read(appLanguageProvider.notifier).setLanguage(selected);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<AppLanguage>>[
        const PopupMenuItem<AppLanguage>(
          value: AppLanguage.en,
          child: Text('English'),
        ),
        const PopupMenuItem<AppLanguage>(
          value: AppLanguage.hi,
          child: Text('हिंदी'),
        ),
      ],
      child: Chip(
        label: Text(current.label),
        avatar: const Icon(Icons.language, size: 16),
      ),
    );
  }
}
