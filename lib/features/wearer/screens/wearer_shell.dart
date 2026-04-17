import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class WearerShell extends StatelessWidget {
  final Widget child;
  const WearerShell({super.key, required this.child});

  static const _tabs = ['/wearer', '/wearer/health', '/wearer/qrcode', '/wearer/settings'];

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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _NavItem(icon: Icons.home_outlined, filledIcon: Icons.home, label: 'Home',
                    selected: idx == 0, onTap: () => context.go('/wearer')),
                _NavItem(icon: Icons.favorite_outline, filledIcon: Icons.favorite,
                    label: 'Health', selected: idx == 1,
                    onTap: () => context.go('/wearer/health')),
                _NavItem(icon: Icons.qr_code_2_outlined, filledIcon: Icons.qr_code_2,
                    label: 'QR Code', selected: idx == 2,
                    onTap: () => context.go('/wearer/qrcode')),
                _NavItem(icon: Icons.settings_outlined, filledIcon: Icons.settings,
                    label: 'Settings', selected: idx == 3,
                    onTap: () => context.go('/wearer/settings')),
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
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500)),
            if (selected)
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: 20, height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
