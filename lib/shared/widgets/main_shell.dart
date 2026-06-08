import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flexpro_coaching/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  int _activeIndex(String location) {
    if (location.startsWith(AppRoutes.programs)) return 1;
    if (location.startsWith(AppRoutes.workout))  return 2;
    if (location.startsWith(AppRoutes.progress)) return 3;
    if (location.startsWith(AppRoutes.profile))  return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final tabs = [
      _NavTab(label: l.navHome,     icon: Icons.home_rounded,               route: AppRoutes.home),
      _NavTab(label: l.navPrograms, icon: Icons.format_list_bulleted_rounded, route: AppRoutes.programs),
      _NavTab(label: l.navWorkout,  icon: Icons.play_circle_fill_rounded,   route: AppRoutes.workout),
      _NavTab(label: l.navProgress, icon: Icons.show_chart_rounded,         route: AppRoutes.progress),
      _NavTab(label: l.navProfile,  icon: Icons.person_rounded,             route: AppRoutes.profile),
    ];

    final location = GoRouterState.of(context).uri.path;
    final activeIdx = _activeIndex(location);

    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        border: Border(top: BorderSide(color: context.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(tabs.length, (i) {
              final isActive = i == activeIdx;
              return Expanded(
                child: _NavItem(
                  tab: tabs[i],
                  isActive: isActive,
                  onTap: () {
                    if (!isActive) {
                      HapticFeedback.selectionClick();
                      context.go(tabs[i].route);
                    }
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.tab, required this.isActive, required this.onTap});

  final _NavTab tab;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: isActive
                  ? BoxDecoration(
                      color: AppColors.accentDim,
                      borderRadius: BorderRadius.circular(10),
                    )
                  : null,
              child: Icon(tab.icon, size: 22,
                  color: isActive ? AppColors.accent : context.tertiaryText),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: isActive ? AppColors.accent : context.tertiaryText,
              ),
              child: Text(tab.label),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTab {
  const _NavTab({required this.label, required this.icon, required this.route});
  final String label;
  final IconData icon;
  final String route;
}
