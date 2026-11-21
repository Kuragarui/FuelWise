import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/fuel_log.dart';
import '../state/app_scope.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_text_field.dart';
import '../widgets/choice_chips.dart';
import '../widgets/glow_background.dart';
import '../widgets/page_header.dart';

class LogRefuelScreen extends StatefulWidget {
  static const String routeName = '/log-refuel';

  const LogRefuelScreen({super.key});

  @override
  State<LogRefuelScreen> createState() => _LogRefuelScreenState();
}

class _LogRefuelScreenState extends State<LogRefuelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _litersController = TextEditingController();
  final _priceController = TextEditingController();
  final _odometerController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _date = DateTime.now();
  String? _station;

  @override
  void initState() {
    super.initState();
    final state = AppScope.read(context);
    if (state.averagePrice > 0) {
      _priceController.text = state.averagePrice.toStringAsFixed(2);
    }
    final latest = state.latestLog;
    if (latest != null) {
      _odometerController.text = (latest.odometer + 250).toString();
    }
  }

  @override
  void dispose() {
    _litersController.dispose();
    _priceController.dispose();
    _odometerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _liters => double.tryParse(_litersController.text.trim()) ?? 0;

  double get _price => double.tryParse(_priceController.text.trim()) ?? 0;

  double get _total => _liters * _price;

  FuelLog? _previousLog(List<FuelLog> logs) {
    final selectedDay = DateTime(_date.year, _date.month, _date.day);
    FuelLog? previous;
    for (final log in logs) {
      final logDay = DateTime(log.date.year, log.date.month, log.date.day);
      if (logDay.isAfter(selectedDay)) continue;
      if (previous == null || log.date.isAfter(previous.date)) previous = log;
    }
    return previous;
  }

  FuelLog? _nextLog(List<FuelLog> logs) {
    final selectedDay = DateTime(_date.year, _date.month, _date.day);
    FuelLog? next;
    for (final log in logs) {
      final logDay = DateTime(log.date.year, log.date.month, log.date.day);
      if (!logDay.isAfter(selectedDay)) continue;
      if (next == null || log.date.isBefore(next.date)) next = log;
    }
    return next;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final state = AppScope.read(context);
    final odometer = int.tryParse(_odometerController.text.trim()) ?? 0;
    final previous = _previousLog(state.logs);
    final kmDriven = previous != null && odometer > previous.odometer
        ? (odometer - previous.odometer).toDouble()
        : 0.0;

    final log = FuelLog(
      date: _date,
      liters: _liters,
      pricePerLiter: _price,
      odometer: odometer,
      station: _station,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      kmDriven: kmDriven,
    );

    state.addLog(log);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Refuel saved: ${Fmt.liters(log.liters)} for ${Fmt.money(log.cost)}.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;
    final state = AppScope.of(context);
    final previous = _previousLog(state.logs);
    final next = _nextLog(state.logs);

    return Scaffold(
      backgroundColor: palette.canvas,
      body: GlowBackground(
        variant: GlowVariant.pageTop,
        child: SafeArea(
          child: Form(
            key: _formKey,
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
                    title: 'Log a refuel',
                    subtitle: 'Keep your records accurate',
                    showBack: true,
                  ),
                  const SizedBox(height: AppSpacing.gapSection),
                  AppCard(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusField,
                          ),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Date',
                              suffixIcon: Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: palette.textMuted,
                              ),
                            ),
                            child: Text(
                              Fmt.dateTime(_date),
                              style: type.body.copyWith(
                                color: palette.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'Liters',
                          hint: '0.00',
                          controller: _litersController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]'),
                            ),
                          ],
                          suffixText: 'L',
                          onChanged: (_) => setState(() {}),
                          validator: (value) {
                            final parsed = double.tryParse(value?.trim() ?? '');
                            if (parsed == null || parsed <= 0) {
                              return 'Enter the liters filled';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'Price per liter',
                          hint: '0.00',
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]'),
                            ),
                          ],
                          prefixText: state.profile.currencySymbol,
                          onChanged: (_) => setState(() {}),
                          validator: (value) {
                            final parsed = double.tryParse(value?.trim() ?? '');
                            if (parsed == null || parsed <= 0) {
                              return 'Enter the price per liter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'Odometer (km)',
                          hint: previous != null
                              ? 'Last was ${previous.odometer}'
                              : '0',
                          controller: _odometerController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          suffixText: 'km',
                          onChanged: (_) => setState(() {}),
                          validator: (value) {
                            final parsed = int.tryParse(value?.trim() ?? '');
                            if (parsed == null || parsed <= 0) {
                              return 'Enter your odometer reading';
                            }
                            if (previous != null &&
                                parsed <= previous.odometer) {
                              return 'Must be more than ${previous.odometer} km';
                            }
                            if (next != null && parsed >= next.odometer) {
                              return 'Must be less than ${next.odometer} km';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.gapBlock),
                  Text('Station', style: type.label),
                  const SizedBox(height: 8),
                  ChoiceChips<String>(
                    options: [
                      ChoiceOption<String>('', 'Skip'),
                      ...const [
                        'Shell',
                        'Petron',
                        'Caltex',
                        'Phoenix',
                        'SeaOil',
                        'Other',
                      ].map((station) => ChoiceOption(station, station)),
                    ],
                    value: _station ?? '',
                    onChanged: (value) =>
                        setState(() => _station = value.isEmpty ? null : value),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Notes (optional)',
                    hint: 'Traffic, route, or anything worth remembering',
                    controller: _notesController,
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: AppSpacing.gapSection),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: palette.surfaceMuted,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      border: Border.all(color: palette.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Receipt total',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: type.cardTitle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                Fmt.money(_total),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: type.metricSmall.copyWith(
                                  color: palette.brandStrong,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${Fmt.liters(_liters)} × ${Fmt.price(_price)}',
                                style: type.caption,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (previous != null &&
                                _odometerController.text.isNotEmpty &&
                                int.tryParse(_odometerController.text.trim()) !=
                                    null)
                              Flexible(
                                child: Text(
                                  '${(int.parse(_odometerController.text.trim()) - previous.odometer).clamp(0, 99999)} km since last',
                                  textAlign: TextAlign.end,
                                  style: type.caption.copyWith(
                                    color: palette.textMuted,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.gapSection),
                  AppButton(
                    label: 'Save refuel',
                    icon: Icons.check_rounded,
                    onTap: _save,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Saved refuels update your dashboard, history, and forecast.',
                      style: type.caption.copyWith(color: palette.textMuted),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
