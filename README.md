# FuelWise

FuelWise is a Flutter fuel tracker for logging fill-ups, planning trip costs,
reviewing trends, and forecasting next week's spend. The UI follows the
approved Figma dark theme: deep violet/indigo canvas with lime accents, and
Montserrat headings/metrics with Poppins body text. There is a single theme -
no light/dark toggle.

## Run locally

1. Ensure Flutter is installed and available on `PATH`.
2. Run `flutter pub get`.
3. Run `flutter run` with an Android, iOS, Windows, or Chrome target.
4. Run `flutter analyze` and `flutter test` to verify changes.

The app starts on the Welcome setup screen with the Paolo Reyes demo persona.
The demo repository keeps data in memory for the session; when Firebase is
configured, refuels and the profile are stored in Firestore instead.

## Screens

- **Welcome** - persona, editable car name, vehicle, fuel type, driving style,
  and budget overview.
- **Home** - monthly budget hero, active alert banner, efficiency stats, recent
  refuels, log action, next-week forecast, weekly spend chart, optional current
  week summary, and price trend.
- **Calculator** - trip distance/round-trip input with liters, cost, and budget
  comparison.
- **Analytics** - spend and efficiency insights, weekly chart, and
  recommendations.
- **Account** - profile editing, vehicle details, budget shortcut, alert
  preferences, and demo reset.
- **Log a refuel** - date, liters, price, odometer, station, and notes with a
  live receipt total. Backdated entries are validated against the refuels
  before and after the chosen date.
- **Refuel history** - all refuels grouped by month with range filters. Each
  entry can be deleted after a confirmation dialog.
- **Plan for next week** - linear-regression forecast, trend insight, and
  projected budget use.
- **Fuel budget** - monthly limit, progress, projection, and alert switches.

## Architecture

- `lib/theme/` - `AppPalette` and `AppTypography` theme extensions with a single
  dark token set, plus shared spacing and `ThemeData`.
- `lib/state/` - `AppState` (`ChangeNotifier`) and `AppScope`
  (`InheritedNotifier`) for in-memory logs, profile, and preferences.
- `lib/repositories/` - `FuelRepository` and `AuthRepository` interfaces with
  demo and Firebase implementations. `AppState` reads and writes through these
  repositories, so screens do not depend on Firebase directly.
- `lib/services/` - pure calculation helpers for analysis, prediction, trip
  estimates, budget status, and active alerts.
- `lib/data/demo_data.dart` - demo persona, vehicles, and seed refuels.
- `lib/widgets/` - shared cards, buttons, fields, charts, alerts, navigation,
  and layout primitives.
- `test/` - service, state, repository, and widget smoke tests.

## Analytics and forecasting

The calculations stay intentionally simple and understandable:

- The oldest refuel has no known distance and is stored with `kmDriven = 0`.
- Efficiency is total valid kilometers divided by total valid liters; L/100 km
  is derived from that value.
- The average fuel price is weighted by liters, and price comparisons use the
  most recent refuel by date.
- Weekly recommendations compare the last two completed calendar weeks.
- Forecasts use a linear regression over real weekly or monthly buckets and
  target the next calendar week or month. Month-end projection applies the
  next-week forecast to the remaining days of the current month.

Charts intentionally show logged weeks rather than inserting zero-spend weeks.
Labels use "Recent weeks" instead of implying a fixed consecutive window.

## Firebase

The integration is wired behind a fallback: `initializeAppDependencies()`
(`lib/bootstrap.dart`) initializes Firebase, signs the user in anonymously, and
loads logs/profile from Firestore. If Firebase is not configured - or the
platform is unsupported, such as Windows desktop - the app falls back to
in-memory demo mode automatically.

To connect your own project:

1. `firebase login`
2. `flutterfire configure` in the project root and select the Android, iOS, and
   Web platforms. This replaces the placeholder `lib/firebase_options.dart`
   and generates the platform config files.
3. In the Firebase console, enable Authentication > Sign-in method > Anonymous,
   and create a Firestore database.
4. Publish Firestore rules that scope reads and writes to the signed-in user:
   `users/{uid}` and its `logs/{logId}` subcollection, allowed when
   `request.auth.uid == uid`.
5. Run the app on Chrome or an Android device/emulator (desktop is not
   supported by Firebase Auth/Firestore). The first launch signs in
   anonymously and seeds the demo refuels under `users/{uid}/logs`.

Firestore layout: `users/{uid}` holds the profile document and
`users/{uid}/logs/{logId}` holds refuels. No credentials are stored in this
repository.
