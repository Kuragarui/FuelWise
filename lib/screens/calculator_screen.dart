import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/analysis_service.dart';
import '../services/budget_service.dart';
import '../services/trip_service.dart';
import '../state/app_scope.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/app_text_field.dart';
import '../widgets/page_header.dart';
import '../widgets/section_header.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _fromController = TextEditingController(text: 'Home');
  final _toController = TextEditingController();
  final _distanceController = TextEditingController(text: '12');
  final _priceController = TextEditingController();
  bool _roundTrip = true;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _distanceController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;
    final state = AppScope.of(context);
    final summary = AnalysisService.summarize(state.logs);
    final budget = BudgetService.status(
      logs: state.logs,
      budget: state.profile.monthlyBudget,
      projectedSpend: 0,
    );

    final distance = double.tryParse(_distanceController.text.trim()) ?? 0;
    final price =
        double.tryParse(_priceController.text.trim()) ??
        (state.averagePrice > 0 ? state.averagePrice : 60);
    final estimate = TripService.estimate(
      oneWayKm: distance,
      roundTrip: _roundTrip,
      kmPerLiter: summary.avgKmPerL > 0 ? summary.avgKmPerL : 12,
      pricePerLiter: price,
    );

    return SafeArea(
      bottom: false,
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
              title: 'Fuel Calculator',
              subtitle: 'Estimate the cost before you drive',
            ),
            const SizedBox(height: AppSpacing.gapSection),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'From',
                    hint: 'Starting point',
                    controller: _fromController,
                    prefixIcon: Icon(
                      Icons.trip_origin_rounded,
                      size: 18,
                      color: palette.textMuted,
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'To',
                    hint: 'Destination',
                    controller: _toController,
                    prefixIcon: Icon(
                      Icons.place_outlined,
                      size: 18,
                      color: palette.textMuted,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Distance (km)',
                          hint: '0',
                          controller: _distanceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]'),
                            ),
                          ],
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'Fuel price / L',
                          hint: price.toStringAsFixed(2),
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          prefixText: state.profile.currencySymbol,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]'),
                            ),
                          ],
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _RoundTripToggle(
                    value: _roundTrip,
                    onChanged: (value) => setState(() => _roundTrip = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.gapBlock),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: palette.brand,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ESTIMATED TRIP COST',
                    style: type.overline.copyWith(
                      color: palette.textOnBrand.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Fmt.money(estimate.cost, decimals: 2),
                    style: type.metric.copyWith(color: palette.textOnBrand),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _TripStat(
                          label: 'Distance',
                          value: '${estimate.distanceKm.toStringAsFixed(0)} km',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TripStat(
                          label: 'Fuel needed',
                          value: Fmt.liters(estimate.liters),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TripStat(
                          label: 'Budget left',
                          value: Fmt.money(
                            (budget.remaining - estimate.cost).clamp(
                              0,
                              double.infinity,
                            ),
                            decimals: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.gapSection),
            const SectionHeader(title: 'Your driving profile'),
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                children: [
                  _ProfileRow(
                    label: 'Vehicle',
                    value:
                        '${state.profile.vehicleName} · ${state.profile.vehicleType}',
                  ),
                  const SizedBox(height: 12),
                  _ProfileRow(label: 'Fuel', value: state.profile.fuelType),
                  const SizedBox(height: 12),
                  _ProfileRow(
                    label: 'Average efficiency',
                    value: summary.avgKmPerL > 0
                        ? '${summary.avgKmPerL.toStringAsFixed(1)} km/L'
                        : 'Not enough data',
                  ),
                  const SizedBox(height: 12),
                  _ProfileRow(
                    label: 'Average price',
                    value: state.averagePrice > 0
                        ? Fmt.price(state.averagePrice)
                        : 'Not enough data',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Estimates use your logged efficiency and the fuel price you enter. '
              'Actual cost may vary with traffic, load, and driving style.',
              style: type.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundTripToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _RoundTripToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final type = context.type;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Round trip', style: type.cardTitle),
              const SizedBox(height: 2),
              Text(
                'Double the distance for a return journey',
                style: type.caption,
              ),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _TripStat extends StatelessWidget {
  final String label;
  final String value;

  const _TripStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: type.caption.copyWith(
            color: palette.textOnBrand.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: type.label.copyWith(color: palette.textOnBrand)),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;

    return Row(
      children: [
        Text(label, style: type.caption),
        const Spacer(),
        Text(value, style: type.label.copyWith(color: palette.textPrimary)),
      ],
    );
  }
}
