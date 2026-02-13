import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'app_router.dart';

class UpscWorldApp extends StatelessWidget {
  const UpscWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'UPSC World: Civilization',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      routerConfig: appRouter,
    );
  }
}
