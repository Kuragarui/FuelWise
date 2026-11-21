import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

enum GlowVariant { pageTop, pageBottom }

class GlowBackground extends StatelessWidget {
  final GlowVariant variant;
  final Widget child;

  const GlowBackground({super.key, required this.variant, required this.child});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final isTop = variant == GlowVariant.pageTop;

    return Stack(
      children: [
        Positioned.fill(child: Container(color: palette.canvas)),
        Positioned(
          left: isTop ? -40 : null,
          right: isTop ? null : -40,
          top: isTop ? -60 : null,
          bottom: isTop ? null : -60,
          child: IgnorePointer(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  color: isTop ? palette.glowTop : palette.glowBottom,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: isTop ? -70 : null,
          left: isTop ? null : -70,
          top: isTop ? 20 : null,
          bottom: isTop ? null : 20,
          child: IgnorePointer(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  color: isTop ? palette.glowBottom : palette.glowTop,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}
