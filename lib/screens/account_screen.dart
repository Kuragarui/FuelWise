import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../services/analysis_service.dart';
import '../state/app_scope.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_switch_row.dart';
import '../widgets/app_text_field.dart';
import '../widgets/choice_chips.dart';
import '../widgets/page_header.dart';
import '../widgets/section_header.dart';
import 'fuel_budget_screen.dart';
import 'welcome_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;
    final state = AppScope.of(context);
    final profile = state.profile;
    final summary = AnalysisService.summarize(state.logs);

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
              title: 'Account',
              subtitle: 'Your profile and preferences',
            ),
            const SizedBox(height: AppSpacing.gapSection),
            AppCard(
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: palette.brand,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      profile.initials,
                      style: type.section.copyWith(color: palette.textOnBrand),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.fullName, style: type.cardTitle),
                        const SizedBox(height: 2),
                        Text(profile.email, style: type.caption),
                        const SizedBox(height: 4),
                        Text(
                          '${profile.location} · ${summary.logCount} refuels',
                          style: type.caption.copyWith(
                            color: palette.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _editProfile(context),
                    child: Text(
                      'Edit',
                      style: type.label.copyWith(color: palette.brandStrong),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.gapSection),
            const SectionHeader(title: 'Vehicle'),
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.directions_car_rounded,
                    label: 'Vehicle',
                    value: '${profile.vehicleName} · ${profile.vehicleType}',
                  ),
                  const SizedBox(height: 14),
                  _InfoRow(
                    icon: Icons.local_gas_station_rounded,
                    label: 'Fuel type',
                    value: profile.fuelType,
                  ),
                  const SizedBox(height: 14),
                  _InfoRow(
                    icon: Icons.tune_rounded,
                    label: 'Driving style',
                    value: profile.drivingStyle,
                  ),
                  const SizedBox(height: 14),
                  _InfoRow(
                    icon: Icons.speed_rounded,
                    label: 'Efficiency',
                    value: summary.avgKmPerL > 0
                        ? '${summary.avgKmPerL.toStringAsFixed(1)} km/L'
                        : 'Not enough data',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.gapSection),
            const SectionHeader(title: 'Fuel budget'),
            const SizedBox(height: 8),
            AppCard(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const FuelBudgetScreen(),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 20,
                    color: palette.brandStrong,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Monthly budget', style: type.cardTitle),
                        const SizedBox(height: 2),
                        Text(
                          Fmt.money(profile.monthlyBudget, decimals: 0),
                          style: type.caption,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: palette.textMuted),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.gapSection),
            const SectionHeader(title: 'Preferences'),
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                children: [
                  AppSwitchRow(
                    title: 'Price alerts',
                    subtitle: 'Tell me when fuel prices drop',
                    icon: Icons.local_offer_outlined,
                    value: state.priceAlerts,
                    onChanged: state.setPriceAlerts,
                  ),
                  const SizedBox(height: 16),
                  AppSwitchRow(
                    title: 'Budget alerts',
                    subtitle: 'Warn me near my monthly limit',
                    icon: Icons.notifications_active_outlined,
                    value: state.budgetAlerts,
                    onChanged: state.setBudgetAlerts,
                  ),
                  const SizedBox(height: 16),
                  AppSwitchRow(
                    title: 'Weekly summary',
                    subtitle: 'A recap of spend and efficiency',
                    icon: Icons.mark_email_read_outlined,
                    value: state.weeklySummary,
                    onChanged: state.setWeeklySummary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.gapSection),
            const SectionHeader(title: 'More'),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _LinkRow(
                    icon: Icons.replay_rounded,
                    label: 'Reset demo data',
                    onTap: () => _resetData(context),
                  ),
                  _LinkRow(
                    icon: Icons.logout_rounded,
                    label: 'View welcome screen',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const WelcomeScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.gapSection),
            AppButton(
              label: 'Log a refuel',
              icon: Icons.add_rounded,
              onTap: () => Navigator.of(context).pushNamed('/log-refuel'),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                state.firebaseEnabled
                    ? 'FuelWise v1.0.0 · Firebase connected'
                    : 'FuelWise demo · v1.0.0',
                style: type.caption.copyWith(color: palette.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetData(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset demo data?'),
        content: const Text(
          'This restores the sample refuels and profile. Any refuels you added '
          'in this session will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              AppScope.read(context).resetDemoData();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _editProfile(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _EditProfileSheet(),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet();

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _firstController;
  late final TextEditingController _lastController;
  late final TextEditingController _emailController;
  late final TextEditingController _vehicleController;
  late String _vehicleType;
  late String _fuelType;
  late String _drivingStyle;

  @override
  void initState() {
    super.initState();
    final profile = AppScope.read(context).profile;
    _firstController = TextEditingController(text: profile.firstName);
    _lastController = TextEditingController(text: profile.lastName);
    _emailController = TextEditingController(text: profile.email);
    _vehicleController = TextEditingController(text: profile.vehicleName);
    _vehicleType = profile.vehicleType;
    _fuelType = profile.fuelType;
    _drivingStyle = profile.drivingStyle;
  }

  @override
  void dispose() {
    _firstController.dispose();
    _lastController.dispose();
    _emailController.dispose();
    _vehicleController.dispose();
    super.dispose();
  }

  void _save() {
    AppScope.read(context).updateProfile(
      firstName: _firstController.text.trim(),
      lastName: _lastController.text.trim(),
      email: _emailController.text.trim(),
      vehicleName: _vehicleController.text.trim(),
      vehicleType: _vehicleType,
      fuelType: _fuelType,
      drivingStyle: _drivingStyle,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.padSide,
        20,
        AppSpacing.padSide,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Edit profile', style: type.title),
            const SizedBox(height: 4),
            Text(
              'Update your details and vehicle preferences.',
              style: type.caption,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'First name',
                    controller: _firstController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Last name',
                    controller: _lastController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            AppTextField(label: 'Vehicle name', controller: _vehicleController),
            const SizedBox(height: 14),
            Text('Vehicle type', style: type.label),
            const SizedBox(height: 8),
            ChoiceChips<String>(
              options: DemoData.vehicleTypes
                  .map((v) => ChoiceOption(v, v))
                  .toList(),
              value: _vehicleType,
              onChanged: (value) => setState(() => _vehicleType = value),
            ),
            const SizedBox(height: 14),
            Text('Fuel type', style: type.label),
            const SizedBox(height: 8),
            ChoiceChips<String>(
              options: DemoData.fuelTypes
                  .map((v) => ChoiceOption(v, v))
                  .toList(),
              value: _fuelType,
              onChanged: (value) => setState(() => _fuelType = value),
            ),
            const SizedBox(height: 14),
            Text('Driving style', style: type.label),
            const SizedBox(height: 8),
            ChoiceChips<String>(
              options: DemoData.drivingStyles
                  .map((v) => ChoiceOption(v, v))
                  .toList(),
              value: _drivingStyle,
              onChanged: (value) => setState(() => _drivingStyle = value),
            ),
            const SizedBox(height: 20),
            AppButton(label: 'Save changes', onTap: _save),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Changes stay in this session.',
                style: type.caption.copyWith(color: palette.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;

    return Row(
      children: [
        Icon(icon, size: 18, color: palette.brandStrong),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: type.caption)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: type.label.copyWith(color: palette.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: palette.textSecondary),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: type.cardTitle)),
            Icon(Icons.chevron_right_rounded, color: palette.textMuted),
          ],
        ),
      ),
    );
  }
}
