class Fmt {
  Fmt._();

  static const List<String> _monthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sept',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> _monthsLong = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _weekdaysShort = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static String monthShort(DateTime date) => _monthsShort[date.month - 1];

  static String monthLong(DateTime date) => _monthsLong[date.month - 1];

  static String monthYear(DateTime date) =>
      '${_monthsLong[date.month - 1]} ${date.year}';

  static String weekdayShort(DateTime date) => _weekdaysShort[date.weekday - 1];

  static String weekRange(DateTime start, {String separator = ' - '}) {
    final end = start.add(const Duration(days: 6));
    return '${monthShort(start)} ${start.day}$separator'
        '${monthShort(end)} ${end.day}';
  }

  static String dateShort(DateTime date) =>
      '${_monthsShort[date.month - 1]} ${date.day}, ${date.year}';

  static String dateTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '${dateShort(date)} · $hour:$minute $period';
  }

  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return dateShort(date);
  }

  static String money(double value, {String symbol = '₱', int decimals = 2}) {
    final fixed = value.abs().toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final whole = _withThousands(parts.first);
    final sign = value < 0 ? '-' : '';
    return decimals > 0
        ? '$sign$symbol $whole.${parts[1]}'
        : '$sign$symbol $whole';
  }

  static String moneyCompact(double value, {String symbol = '₱'}) {
    if (value >= 1000000) {
      return '$symbol ${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 10000) {
      return '$symbol ${(value / 1000).toStringAsFixed(1)}k';
    }
    return money(value, symbol: symbol, decimals: 0);
  }

  static String axisMoney(double value) {
    if (value >= 1000000) {
      return '₱${_compact(value / 1000000)}M';
    }
    if (value >= 1000) {
      return '₱${_compact(value / 1000)}k';
    }
    return '₱${value.toStringAsFixed(0)}';
  }

  static String _compact(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }

  static String liters(double value) => '${value.toStringAsFixed(1)} L';

  static String price(double value, {String symbol = '₱'}) =>
      '$symbol${value.toStringAsFixed(2)}/L';

  static String number(double value, {int decimals = 0}) =>
      value.toStringAsFixed(decimals);

  static String percent(double value, {int decimals = 0}) =>
      '${value.toStringAsFixed(decimals)}%';

  static String _withThousands(String value) {
    final buffer = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      if (i > 0 && (value.length - i) % 3 == 0) buffer.write(',');
      buffer.write(value[i]);
    }
    return buffer.toString();
  }
}
