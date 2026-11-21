import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/budget_service.dart';
import '../state/app_scope.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_switch_row.dart';
import '../widgets/app_text_field.dart';
import '../widgets/budget_progress.dart';
import '../widgets/glow_background.dart';
import '../widgets/page_header.dart';

class FuelBudgetScreen extends StatefulWidget {
  static const String routeName = '/budget';

  const FuelBudgetScreen({super.key});

  @override
  State<FuelBudgetScreen> createState() => _FuelBudgetScreenState();
}

class _FuelBudgetScreenState extends State<FuelBudgetScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final profile = AppScope.read(context).profile;
    _controller = TextEditingController(
      text: profile.monthlyBudget.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _budget => double.tryParse(_controller.text.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;
    final state = AppScope.of(context);
    final budget = BudgetService.status(
      logs: state.logs,
      budget: state.profile.monthlyBudget,
      projectedSpend: 0,
    );
    final average = BudgetService.averageMonthlySpend(state.logs);
    final suggested = average > 0 ? (average * 1.1).ceilToDouble() : 5000.0;

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
                const PageHeader(
                  title: 'Fuel budget',
                  subtitle: 'Set a monthly limit and alerts',
                  showBack: true,
                ),
                const SizedBox(height: AppSpacing.gapSection),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('This month', style: type.cardTitle),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: budget.isOverspent
                                  ? palette.danger.withValues(alpha: 0.12)
                                  : palette.accentSoft,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusPill,
                              ),
                            ),
                            child: Text(
                              budget.isOverspent
                                  ? 'Over budget'
                                  : '${(budget.progress * 100).toStringAsFixed(0)}% used',
                              style: type.caption.copyWith(
                                color: budget.isOverspent
                                    ? palette.danger
                                    : palette.onAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        Fmt.money(budget.spent, decimals: 0),
                        style: type.metric,
                      ),
                      const SizedBox(height: 12),
                      BudgetProgress(
                        progress: budget.progress,
                        spent: budget.spent,
                        budget: budget.budget,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        budget.isOverspent
                            ? 'You are ${Fmt.money(budget.remaining.abs(), decimals: 0)} over your limit.'
                            : '${Fmt.money(budget.remaining, decimals: 0)} still available this month.',
                        style: type.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.gapBlock),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: 'Monthly fuel budget',
                        hint: '0',
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        prefixText: state.profile.currencySymbol,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Based on your recent refuels, we suggest '
                        '${Fmt.money(suggested, decimals: 0)} per month.',
                        style: type.caption,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [3000, 5000, 8000].map((preset) {
                          return ActionChip(
                            label: Text(
                              Fmt.money(preset.toDouble(), decimals: 0),
                            ),
                            onPressed: () {
                              setState(() {
                                _controller.text = preset.toString();
                              });
                            },
                            backgroundColor: palette.surfaceMuted,
                            side: BorderSide(color: palette.border),
                            labelStyle: type.caption.copyWith(
                              color: palette.textPrimary,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.gapBlock),
                AppCard(
                  child: Column(
                    children: [
                      AppSwitchRow(
                        title: 'Budget alerts',
                        subtitle: 'Notify me at 90% of the limit',
                        icon: Icons.notifications_active_outlined,
                        value: state.budgetAlerts,
                        onChanged: state.setBudgetAlerts,
                      ),
                      const SizedBox(height: 16),
                      AppSwitchRow(
                        title: 'Price alerts',
                        subtitle: 'Notify me when prices drop',
                        icon: Icons.local_offer_outlined,
                        value: state.priceAlerts,
                        onChanged: state.setPriceAlerts,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.gapBlock),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: palette.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: palette.brandStrong,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your budget is stored for this session only. '
                          'Connect Firebase later to sync it across devices.',
                          style: type.caption,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.gapSection),
                AppButton(
                  label: 'Save budget',
                  icon: Icons.check_rounded,
                  onTap: _budget <= 0
                      ? null
                      : () {
                          AppScope.read(context).updateBudget(_budget);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Monthly budget set to ${Fmt.money(_budget, decimals: 0)}.',
                              ),
                            ),
                          );
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
