# FuelWise project notes

- Flutter/Dart app using Material 3.
- The app has a single dark theme matching the Figma design: canvas `#241C44`,
  surface `#2E2554`, brand `#D0F282`, strong accent `#CEFF5E`, and `onAccent`
  `#241C44` for text/icons on lime. Montserrat is used for headings and metrics,
  Poppins for body text. There is no light theme or theme toggle.
- Never hardcode colors or text styles in screens. Use `context.palette`
  (`lib/theme/app_palette.dart`) and `context.type`
  (`lib/theme/app_typography.dart`).
- State is in-memory through `AppState` (`ChangeNotifier`) and `AppScope`
  (`InheritedNotifier`). Keep local demo mode so the app runs before Firebase
  configuration.
- Persistence goes behind `FuelRepository`/`AuthRepository`
  (`lib/repositories/`); keep the demo implementations as the fallback and do
  not call Firebase APIs from screens or state directly.
- Firebase startup lives in `lib/bootstrap.dart` (`initializeAppDependencies`);
  it must keep the demo-mode fallback when Firebase is unconfigured or
  unsupported on the current platform.
- Firebase integration must use generated FlutterFire configuration and must
  not commit credentials.
- Keep analytics and forecasting simple. Fix existing calculations and labels
  instead of adding new models, metrics, or chart types.
- The oldest refuel has no known distance (`kmDriven = 0`). Efficiency is total
  valid kilometers divided by total valid liters, and average price is
  weighted by liters.
- Forecasts target the next calendar week or month and use real logged buckets.
  Do not insert zero-spend weeks into charts.
- Backdated refuels are validated against the chronological neighbor logs.
- Refuel deletion requires a confirmation dialog and must recalculate mileage
  through `AppState`.
- Alerts are simple in-app banners/sheets controlled by the three existing
  preferences. Do not add push notifications.
- Run `dart format lib test`, `flutter analyze`, and `flutter test` after Dart
  changes.
