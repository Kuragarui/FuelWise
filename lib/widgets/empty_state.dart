import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_typography.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: palette.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: palette.brandStrong, size: 26),
          ),
          const SizedBox(height: 16),
          Text(title, style: type.cardTitle, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center, style: type.bodySmall),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}
