import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../localization/lang.dart';
import '../../localization/lang_controller.dart';

class LanguageToggleButton extends ConsumerWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLang current = ref.watch(langControllerProvider);

    return PopupMenuButton<AppLang>(
      tooltip: 'Language',
      initialValue: current,
      onSelected: (AppLang selected) {
        ref.read(langControllerProvider.notifier).setLang(selected);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<AppLang>>[
        const PopupMenuItem<AppLang>(value: AppLang.en, child: Text('English')),
        const PopupMenuItem<AppLang>(value: AppLang.hi, child: Text('हिंदी')),
      ],
      child: Chip(
        label: Text(current == AppLang.en ? 'English' : 'हिंदी'),
        avatar: const Icon(Icons.language, size: 16),
      ),
    );
  }
}
