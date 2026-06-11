import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flexpro_coaching/l10n/app_localizations.dart';

import 'core/constants/app_colors.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class FlexProApp extends ConsumerWidget {
  const FlexProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router    = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale    = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'FlexPro Coaching',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
      builder: (context, child) {
        final isDesktop = MediaQuery.of(context).size.width > 600;
        if (!isDesktop || child == null) return child ?? const SizedBox();
        return Container(
          color: AppColors.bgDeep,
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
