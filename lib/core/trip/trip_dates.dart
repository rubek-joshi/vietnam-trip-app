/// Trip dates from Vietnam Final Package: 22–28 Sep 2026 (7 days).
class TripDates {
  TripDates._();

  static final DateTime start = DateTime(2026, 9, 22);
  static final DateTime end = DateTime(2026, 9, 28);
  static const int totalDays = 7;

  static final List<DateTime> dayDates = List.generate(
    totalDays,
    (i) => DateTime(2026, 9, 22 + i),
  );

  /// Day index 1–7 for [date], clamped to the trip window.
  static int activeDay([DateTime? date]) {
    final d = _dateOnly(date ?? DateTime.now());
    if (d.isBefore(start)) return 1;
    if (d.isAfter(end)) return totalDays;
    return d.difference(start).inDays + 1;
  }

  /// Remaining calendar days in the trip including today (min 1 during trip).
  /// Returns 0 after the trip ends.
  static int remainingDays([DateTime? date]) {
    final d = _dateOnly(date ?? DateTime.now());
    if (d.isBefore(start)) return totalDays;
    if (d.isAfter(end)) return 0;
    return end.difference(d).inDays + 1;
  }

  static DateTime dateForDay(int day) {
    assert(day >= 1 && day <= totalDays);
    return dayDates[day - 1];
  }

  static String labelForDay(int day) {
    final d = dateForDay(day);
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return 'Day $day · ${d.day} ${months[d.month]}';
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
