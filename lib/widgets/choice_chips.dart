import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class ChoiceChips<T> extends StatelessWidget {
  final List<ChoiceOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;

  const ChoiceChips({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final selected = option.value == value;
        return GestureDetector(
          onTap: () => onChanged(option.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? palette.brand : palette.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              border: Border.all(
                color: selected ? palette.brand : palette.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (option.icon != null) ...[
                  Icon(
                    option.icon,
                    size: 15,
                    color: selected
                        ? palette.textOnBrand
                        : palette.textSecondary,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  option.label,
                  style: type.label.copyWith(
                    color: selected
                        ? palette.textOnBrand
                        : palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ChoiceOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const ChoiceOption(this.value, this.label, {this.icon});
}
