import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../state/app_scope.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/choice_chips.dart';
import '../widgets/glow_background.dart';
import '../widgets/logo_mark.dart';
import 'main_shell.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _vehicleController;
  late String _vehicleType;
  late String _fuelType;
  late String _drivingStyle;

  @override
  void initState() {
    super.initState();
    final profile = AppScope.read(context).profile;
    _vehicleController = TextEditingController(text: profile.vehicleName);
    _vehicleType = profile.vehicleType;
    _fuelType = profile.fuelType;
    _drivingStyle = profile.drivingStyle;
  }

  @override
  void dispose() {
    _vehicleController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    AppScope.read(context).updateProfile(
      vehicleName: _vehicleController.text.trim(),
      vehicleType: _vehicleType,
      fuelType: _fuelType,
      drivingStyle: _drivingStyle,
    );
    _close();
  }

  void _close() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed(MainShell.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;
    final state = AppScope.of(context);
    final profile = state.profile;

    return Scaffold(
      backgroundColor: palette.canvas,
      body: GlowBackground(
        variant: GlowVariant.pageBottom,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.padSide,
              20,
              AppSpacing.padSide,
              32,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LogoMark(),
                  const SizedBox(height: 40),
                  Text('Welcome,', style: type.caption.copyWith(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(profile.firstName, style: type.hero),
                  const SizedBox(height: 10),
                  Text(
                    'Let\'s set up your fuel tracking so every refuel counts.',
                    style: type.body,
                  ),
                  const SizedBox(height: 28),
                  _SetupCard(
                    label: 'Your vehicle',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          label: 'Car name',
                          controller: _vehicleController,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter your car name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        ChoiceChips<String>(
                          options: DemoData.vehicleTypes
                              .map((v) => ChoiceOption(v, v))
                              .toList(),
                          value: _vehicleType,
                          onChanged: (value) =>
                              setState(() => _vehicleType = value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SetupCard(
                    label: 'Fuel type',
                    child: ChoiceChips<String>(
                      options: DemoData.fuelTypes
                          .map((v) => ChoiceOption(v, v))
                          .toList(),
                      value: _fuelType,
                      onChanged: (value) => setState(() => _fuelType = value),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SetupCard(
                    label: 'Driving style',
                    child: ChoiceChips<String>(
                      options: DemoData.drivingStyles
                          .map(
                            (v) => ChoiceOption(
                              v,
                              v,
                              icon: switch (v) {
                                'Eco' => Icons.eco_rounded,
                                'Performance' => Icons.bolt_rounded,
                                _ => Icons.tune_rounded,
                              },
                            ),
                          )
                          .toList(),
                      value: _drivingStyle,
                      onChanged: (value) =>
                          setState(() => _drivingStyle = value),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SetupCard(
                    label: 'Monthly fuel budget',
                    child: Row(
                      children: [
                        Text(
                          profile.currencySymbol,
                          style: type.metricSmall.copyWith(
                            color: palette.textMuted,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          profile.monthlyBudget.toStringAsFixed(0),
                          style: type.metricSmall,
                        ),
                        const Spacer(),
                        Text(
                          'Set in Account',
                          style: type.caption.copyWith(
                            color: palette.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  AppButton(label: 'Continue', onTap: _continue),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: _close,
                      child: Text(
                        'Skip for now',
                        style: type.label.copyWith(color: palette.textMuted),
                      ),
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

class _SetupCard extends StatelessWidget {
  final String label;
  final Widget child;

  const _SetupCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.padCard),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: type.overline),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
