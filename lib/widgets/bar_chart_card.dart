import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class ChartPoint {
  final String label;
  final double value;

  const ChartPoint({required this.label, required this.value});
}

class BarChartCard extends StatelessWidget {
  final List<ChartPoint> points;
  final int? highlightIndex;
  final bool showYAxis;
  final String Function(double value)? axisFormatter;
  final double height;

  const BarChartCard({
    super.key,
    required this.points,
    this.highlightIndex,
    this.showYAxis = false,
    this.axisFormatter,
    this.height = 132,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;
    if (points.isEmpty) return const SizedBox.shrink();

    final maxValue = points
        .map((p) => p.value)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;
    final step = showYAxis ? _niceStep(safeMax / 3) : 0.0;
    final axisMax = showYAxis ? step * 3 : safeMax;
    final axisValues = showYAxis
        ? [for (var i = 3; i >= 0; i--) step * i]
        : const <double>[];
    final tickFormatter =
        axisFormatter ?? (double value) => value.toStringAsFixed(0);

    return Column(
      children: [
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showYAxis)
                SizedBox(
                  width: 46,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (var i = 0; i < axisValues.length; i++)
                        Positioned(
                          right: 0,
                          top:
                              34 +
                              (height - 34) * i / (axisValues.length - 1) -
                              6,
                          child: Text(
                            tickFormatter(axisValues[i]),
                            style: type.caption.copyWith(
                              color: palette.textMuted,
                              fontSize: 10,
                              height: 1,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: Stack(
                  children: [
                    if (showYAxis)
                      Positioned(
                        top: 34,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (var i = 0; i < axisValues.length; i++)
                              Container(
                                height: 1,
                                color: palette.border.withValues(alpha: 0.5),
                              ),
                          ],
                        ),
                      ),
                    Positioned.fill(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(points.length, (index) {
                          final point = points[index];
                          final isHighlight = highlightIndex == index;
                          final factor = (point.value / axisMax).clamp(
                            0.06,
                            1.0,
                          );
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: index == 0 ? 0 : 4,
                                right: index == points.length - 1 ? 0 : 4,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    point.value.toStringAsFixed(0),
                                    style: type.caption.copyWith(
                                      color: isHighlight
                                          ? palette.brandStrong
                                          : palette.textMuted,
                                      fontWeight: isHighlight
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeOutCubic,
                                    height: (height - 34) * factor,
                                    decoration: BoxDecoration(
                                      color: isHighlight
                                          ? palette.brand
                                          : palette.chartBarMuted,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (showYAxis) const SizedBox(width: 46),
            for (var index = 0; index < points.length; index++)
              Expanded(
                child: Text(
                  points[index].label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: type.caption.copyWith(
                    color: highlightIndex == index
                        ? palette.brandStrong
                        : palette.textMuted,
                    fontWeight: highlightIndex == index
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  double _niceStep(double raw) {
    if (raw <= 0) return 1;
    final exponent = (math.log(raw) / math.ln10).floor();
    final magnitude = math.pow(10, exponent).toDouble();
    final residual = raw / magnitude;
    final nice = residual <= 1
        ? 1.0
        : residual <= 2
        ? 2.0
        : residual <= 5
        ? 5.0
        : 10.0;
    return nice * magnitude;
  }
}

class ChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;

  const ChartCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.padCard),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: type.cardTitle),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: type.caption),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
