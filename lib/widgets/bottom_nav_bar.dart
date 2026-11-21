import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class BottomNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final List<NavItem> items;

  const BottomNavBar({
    super.key,
    required this.index,
    required this.onChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;

    return Container(
      decoration: BoxDecoration(
        color: palette.navBackground,
        border: Border(top: BorderSide(color: palette.border)),
        boxShadow: AppSpacing.navShadow,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSpacing.navH,
          child: Row(
            children: List.generate(items.length, (i) {
              final active = i == index;
              final item = items[i];
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: EdgeInsets.symmetric(
                          horizontal: active ? 16 : 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? palette.navActive
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusPill,
                          ),
                        ),
                        child: Icon(
                          active ? item.activeIcon : item.icon,
                          size: 21,
                          color: active
                              ? palette.textOnBrand
                              : palette.navInactive,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: type.navLabel.copyWith(
                          color: active ? palette.brand : palette.navInactive,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
