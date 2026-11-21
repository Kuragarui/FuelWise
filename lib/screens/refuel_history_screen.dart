import 'package:flutter/material.dart';

import '../models/fuel_log.dart';
import '../services/analysis_service.dart';
import '../state/app_scope.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/glow_background.dart';
import '../widgets/page_header.dart';
import '../widgets/refuel_details_sheet.dart';
import '../widgets/refuel_tile.dart';
import '../widgets/segmented_control.dart';
import 'log_refuel_screen.dart';

enum HistoryRange { all, thisMonth, lastThreeMonths }

class RefuelHistoryScreen extends StatefulWidget {
  static const String routeName = '/history';

  const RefuelHistoryScreen({super.key});

  @override
  State<RefuelHistoryScreen> createState() => _RefuelHistoryScreenState();
}

class _RefuelHistoryScreenState extends State<RefuelHistoryScreen> {
  HistoryRange _range = HistoryRange.all;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;
    final state = AppScope.of(context);
    final filtered = _filter(state.logs);
    final summary = AnalysisService.summarize(filtered);
    final grouped = AnalysisService.groupByMonth(filtered);

    return Scaffold(
      backgroundColor: palette.canvas,
      body: GlowBackground(
        variant: GlowVariant.pageTop,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.padSide,
              12,
              AppSpacing.padSide,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Refuel history',
                  subtitle: '${state.logs.length} refuels recorded',
                  showBack: true,
                  actions: [
                    IconButton(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const LogRefuelScreen(),
                          ),
                        );
                        if (mounted) setState(() {});
                      },
                      icon: Icon(Icons.add_rounded, color: palette.textPrimary),
                      tooltip: 'Add refuel',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.gapBlock),
                SegmentedControl<HistoryRange>(
                  options: const [
                    SegmentOption(HistoryRange.all, 'All time'),
                    SegmentOption(HistoryRange.thisMonth, 'This month'),
                    SegmentOption(
                      HistoryRange.lastThreeMonths,
                      'Last 3 months',
                    ),
                  ],
                  value: _range,
                  onChanged: (value) => setState(() => _range = value),
                ),
                const SizedBox(height: AppSpacing.gapBlock),
                AppCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryCell(
                          label: 'Total spend',
                          value: Fmt.money(summary.totalSpend, decimals: 0),
                        ),
                      ),
                      Container(width: 1, height: 36, color: palette.border),
                      Expanded(
                        child: _SummaryCell(
                          label: 'Liters',
                          value: Fmt.liters(summary.totalLiters),
                        ),
                      ),
                      Container(width: 1, height: 36, color: palette.border),
                      Expanded(
                        child: _SummaryCell(
                          label: 'Refuels',
                          value: '${summary.logCount}',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.gapSection),
                if (filtered.isEmpty)
                  EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No refuels in this range',
                    message: 'Try another filter or add a new refuel to start building your history.',
                    action: AppButton(
                      label: 'Log a refuel',
                      icon: Icons.add_rounded,
                      expand: false,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const LogRefuelScreen(),
                          ),
                        );
                        if (mounted) setState(() {});
                      },
                    ),
                  )
                else
                  ...grouped.entries.toList().reversed.map((entry) {
                    final month = entry.key;
                    final monthLogs = entry.value;
                    final monthTotal = monthLogs.fold<double>(
                      0,
                      (sum, log) => sum + log.cost,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.gapBlock,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(Fmt.monthYear(month), style: type.cardTitle),
                              const Spacer(),
                              Text(
                                Fmt.money(monthTotal, decimals: 0),
                                style: type.caption.copyWith(
                                  color: palette.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: palette.surface,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusCard,
                              ),
                              border: Border.all(color: palette.border),
                            ),
                            child: Column(
                              children: [
                                for (var i = 0; i < monthLogs.length; i++)
                                  RefuelTile(
                                    log: monthLogs[i],
                                    showDivider: i != monthLogs.length - 1,
                                    onTap: () => RefuelDetailsSheet.show(
                                      context,
                                      monthLogs[i],
                                    ),
                                    onDelete: () =>
                                        _confirmDelete(monthLogs[i]),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 8),
                Text(
                  'Tap a refuel to review the full details. '
                  'All entries stay in local demo storage for this session.',
                  style: type.caption.copyWith(color: palette.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(FuelLog log) async {
    final palette = context.palette;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this refuel?'),
        content: Text(
          '${log.station ?? 'Fuel stop'} · ${Fmt.dateShort(log.date)} · '
          '${Fmt.money(log.cost)}. This will update your analytics and forecast.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: palette.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    AppScope.read(context).deleteLog(log.id);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Refuel deleted.')));
  }

  List<FuelLog> _filter(List<FuelLog> logs) {
    final now = DateTime.now();
    switch (_range) {
      case HistoryRange.all:
        return logs;
      case HistoryRange.thisMonth:
        return logs
            .where(
              (log) => log.date.year == now.year && log.date.month == now.month,
            )
            .toList();
      case HistoryRange.lastThreeMonths:
        final cutoff = DateTime(now.year, now.month - 2, 1);
        return logs.where((log) => !log.date.isBefore(cutoff)).toList();
    }
  }
}

class _SummaryCell extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;
    return Column(
      children: [
        Text(
          value,
          style: type.metricSmall.copyWith(color: palette.brandStrong),
        ),
        const SizedBox(height: 2),
        Text(label, style: type.caption, textAlign: TextAlign.center),
      ],
    );
  }
}
