import 'package:flutter_test/flutter_test.dart';
import 'package:al_noor_app/core/utils/hijri_date.dart';

void main() {
  test('gregorian and hijri round-trip across a year', () {
    var day = DateTime(2024, 1, 1);
    final end = DateTime(2026, 12, 31);
    while (!day.isAfter(end)) {
      final hijri = HijriDate.fromGregorian(day);
      final back = hijri.toGregorian();
      expect(DateTime(back.year, back.month, back.day), DateTime(day.year, day.month, day.day),
          reason: '${day.toIso8601String()} -> $hijri');
      expect(hijri.month, inInclusiveRange(1, 12));
      expect(hijri.day, inInclusiveRange(1, HijriDate.monthLength(hijri.year, hijri.month)));
      day = day.add(const Duration(days: 17));
    }
  });

  test('11 March 2024 falls in Ramadan 1445', () {
    final hijri = HijriDate.fromGregorian(DateTime(2024, 3, 11));
    expect(hijri.year, 1445);
    expect(hijri.month, 9);
  });
}
