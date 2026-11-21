import 'package:flutter/material.dart';

import '../services/alert_service.dart';
import '../state/app_scope.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'alert_banner.dart';

class AlertCenterSheet extends StatelessWidget {
  const AlertCenterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AlertCenterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;
    final state = AppScope.of(context);
    final alerts = AlertService.active(
      logs: state.logs,
      monthlyBudget: state.profile.monthlyBudget,
      budgetAlerts: state.budgetAlerts,
      priceAlerts: state.priceAlerts,
    );
    final allOff = !state.budgetAlerts && !state.priceAlerts;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.padSide,
          12,
          AppSpacing.padSide,
          24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.borderStrong,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Alerts', style: type.section),
            const SizedBox(height: 4),
            Text(
              'Warnings based on your refuels and monthly budget.',
              style: type.caption,
            ),
            const SizedBox(height: 16),
            if (alerts.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: palette.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 22,
                      color: palette.brandStrong,
                    ),
                    const SizedBox(height: 8),
                    Text('No active alerts', style: type.cardTitle),
                    const SizedBox(height: 2),
                    Text(
                      allOff
                          ? 'Budget and price alerts are off. Turn them on in Account.'
                          : 'You are all caught up for now.',
                      style: type.caption,
                    ),
                  ],
                ),
              )
            else
              ...alerts.map(
                (alert) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AlertBanner(alert: alert),
                ),
              ),
            const SizedBox(height: 8),
            Text('Preferences', style: type.label),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusChip(
                  label: 'Budget alerts',
                  enabled: state.budgetAlerts,
                ),
                _StatusChip(label: 'Price alerts', enabled: state.priceAlerts),
                _StatusChip(
                  label: 'Weekly summary',
                  enabled: state.weeklySummary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool enabled;

  const _StatusChip({required this.label, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: enabled ? palette.accentSoft : palette.surfaceMuted,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        '$label: ${enabled ? 'On' : 'Off'}',
        style: type.caption.copyWith(
          color: enabled ? palette.onAccent : palette.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
