import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_typography.dart';

class LogoMark extends StatelessWidget {
  final double size;
  final bool showName;
  final Color? color;

  const LogoMark({super.key, this.size = 34, this.showName = true, this.color});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;
    final markColor = color ?? palette.brand;

    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: markColor, shape: BoxShape.circle),
      child: Icon(
        Icons.local_gas_station_rounded,
        size: size * 0.55,
        color: palette.textOnBrand,
      ),
    );

    if (!showName) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 10),
        Text(
          'FuelWise',
          style: type.cardTitle.copyWith(
            color: palette.textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
