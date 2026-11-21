import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/utils/formatters.dart';

void main() {
  group('Fmt.weekRange', () {
    test('formats a monday to sunday range', () {
      expect(Fmt.weekRange(DateTime(2026, 9, 1)), 'Sept 1 - Sept 7');
    });

    test('supports a custom separator', () {
      expect(
        Fmt.weekRange(DateTime(2026, 9, 1), separator: ' to '),
        'Sept 1 to Sept 7',
      );
    });

    test('spans month boundaries', () {
      expect(Fmt.weekRange(DateTime(2026, 8, 30)), 'Aug 30 - Sept 5');
    });
  });

  group('Fmt.axisMoney', () {
    test('formats small values', () {
      expect(Fmt.axisMoney(0), '₱0');
      expect(Fmt.axisMoney(750), '₱750');
    });

    test('formats thousands', () {
      expect(Fmt.axisMoney(1500), '₱1.5k');
      expect(Fmt.axisMoney(3000), '₱3k');
    });

    test('formats millions', () {
      expect(Fmt.axisMoney(2000000), '₱2M');
    });
  });
}
