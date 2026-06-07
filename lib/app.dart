import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class FlexProApp extends ConsumerWidget {
  const FlexProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router    = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'FlexPro Coaching',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        // On desktop: centre-constrain to phone width for dev preview
        final isDesktop = MediaQuery.of(context).size.width > 600;
        if (!isDesktop || child == null) return child ?? const SizedBox();
        return Container(
          color: const Color(0xFF070707),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(44),
              child: SizedBox(
                width: 390,
                height: 844,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
