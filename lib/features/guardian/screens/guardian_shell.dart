import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class GuardianShell extends StatelessWidget {
  final Widget child;
  const GuardianShell({super.key, required this.child});

  static const _tabs = [
    '/guardian',
    '/guardian/map',
    '/guardian/vault',
    '/guardian/settings',
  ];

  int _currentIndex(String location) {
    for (int i = _tabs.length - 1; i >= 0; i--) {
      if (location.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _currentIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.borderColor)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  filledIcon: Icons.home,
                  label: 'Home',
                  selected: idx == 0,
                  onTap: () => context.go('/guardian'),
                ),
                _NavItem(
                  icon: Icons.map_outlined,
                  filledIcon: Icons.map,
                  label: 'Map',
                  selected: idx == 1,
                  onTap: () => context.go('/guardian/map'),
                ),
                // FAB center
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/guardian/add-profile'),
                    child: Center(
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          gradient: AppGradients.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x441758E7),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                ),
                _NavItem(
                  icon: Icons.lock_outline,
                  filledIcon: Icons.lock,
                  label: 'Vault',
                  selected: idx == 2,
                  onTap: () => context.go('/guardian/vault'),
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  filledIcon: Icons.settings,
                  label: 'Settings',
                  selected: idx == 3,
                  onTap: () => context.go('/guardian/settings'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData filledIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.filledIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryBlue : AppColors.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? filledIcon : icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
