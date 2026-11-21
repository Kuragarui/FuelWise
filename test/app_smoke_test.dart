import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/data/demo_data.dart';
import 'package:fuelwise/main.dart';
import 'package:fuelwise/models/fuel_log.dart';
import 'package:fuelwise/models/user_profile.dart';
import 'package:fuelwise/widgets/refuel_tile.dart';

Future<void> pumpApp(
  WidgetTester tester, {
  List<FuelLog>? logs,
  UserProfile? profile,
}) async {
  tester.view.physicalSize = const Size(430, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    FuelWiseApp(initialLogs: logs, initialProfile: profile),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('welcome flows into the dashboard and tabs', (tester) async {
    await pumpApp(tester);

    expect(find.text('Welcome,'), findsOneWidget);
    expect(find.text('Paolo'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Paolo'), findsWidgets);
    expect(find.text('MONTHLY FUEL BUDGET'), findsOneWidget);

    await tester.tap(find.text('Calculator'));
    await tester.pumpAndSettle();
    expect(find.text('Fuel Calculator'), findsOneWidget);
    expect(find.text('Use this estimate'), findsNothing);

    await tester.tap(find.text('Analytics'));
    await tester.pumpAndSettle();
    expect(find.text('Understand your fuel habits'), findsOneWidget);

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    expect(find.text('Your profile and preferences'), findsOneWidget);
    expect(find.text('FuelWise demo · v1.0.0'), findsOneWidget);
  });

  testWidgets('welcome lets you update the car name', (tester) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextFormField).first, 'Honda City');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Honda City'), findsWidgets);
  });

  testWidgets('notification bell opens the alerts sheet', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();

    expect(find.text('Alerts'), findsOneWidget);
    expect(find.text('Budget alerts: On'), findsOneWidget);
    expect(find.text('Weekly summary: Off'), findsOneWidget);
  });

  testWidgets('app is dark only and has no theme toggle', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.text('MONTHLY FUEL BUDGET'))).brightness,
      Brightness.dark,
    );

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    expect(find.text('Dark mode'), findsNothing);
  });

  testWidgets('dashboard places the forecast below the log action', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Budget left'), findsNothing);

    final logButton = find.text('Log a refuel');
    final forecast = find.text('Next week forecast');
    expect(forecast, findsOneWidget);
    expect(
      tester.getTopLeft(forecast).dy,
      greaterThan(tester.getTopLeft(logButton).dy),
    );
  });

  testWidgets('forecast tile opens the plan page', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    final forecast = find.text('Next week forecast');
    await tester.ensureVisible(forecast);
    await tester.pumpAndSettle();
    await tester.tap(forecast);
    await tester.pumpAndSettle();

    expect(find.text('Plan for next week'), findsOneWidget);
    expect(find.text('Recent weeks'), findsOneWidget);
  });

  testWidgets('refuel details sheet opens from the dashboard', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    final tile = find.byType(RefuelTile).first;
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();

    expect(find.text('TOTAL COST'), findsOneWidget);
    expect(find.text('Price per liter'), findsOneWidget);
    expect(find.text('Odometer'), findsOneWidget);
  });

  testWidgets('budget alert banner respects its preference', (tester) async {
    final now = DateTime.now();
    final logs = List.generate(
      3,
      (index) => FuelLog(
        id: 'alert-$index',
        date: now.subtract(Duration(minutes: index)),
        liters: 10,
        pricePerLiter: 100,
        odometer: 3000 - (index * 100),
      ),
    );
    await pumpApp(
      tester,
      logs: logs,
      profile: DemoData.profile.copyWith(monthlyBudget: 500),
    );

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Over your fuel budget'), findsOneWidget);

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    final budgetSwitch = find.byType(Switch).at(1);
    await tester.ensureVisible(budgetSwitch);
    await tester.pumpAndSettle();
    await tester.tap(budgetSwitch);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Over your fuel budget'), findsNothing);
  });

  testWidgets('weekly summary toggle shows the current-week card', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    final weeklySummary = find.text('Weekly summary');
    await tester.ensureVisible(weeklySummary);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).at(2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('This week'), findsOneWidget);
  });

  testWidgets('history deletes a refuel after confirmation', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();
    expect(find.text('12 refuels recorded'), findsOneWidget);

    final deleteButton = find.byIcon(Icons.delete_outline_rounded).first;
    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(find.text('Delete this refuel?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('11 refuels recorded'), findsOneWidget);
    expect(find.text('Refuel deleted.'), findsOneWidget);
  });

  testWidgets('log refuel adds a new entry to history', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log a refuel'));
    await tester.pumpAndSettle();

    expect(find.text('Keep your records accurate'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '12.5');
    await tester.enterText(fields.at(1), '64.00');
    await tester.enterText(fields.at(2), '60050');
    await tester.pump();

    expect(find.textContaining('\u20b1 800.00'), findsOneWidget);

    await tester.tap(find.text('Save refuel'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Paolo'), findsWidgets);
  });
}
