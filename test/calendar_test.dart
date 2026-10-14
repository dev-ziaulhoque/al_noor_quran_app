import 'package:al_noor_app/core/calendar/bangla_date.dart';
import 'package:al_noor_app/core/calendar/islamic_events.dart';
import 'package:al_noor_app/core/utils/hijri_date.dart';
import 'package:al_noor_app/core/zakat/zakat_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bangla calendar (revised 2019)', () {
    void expectDate(DateTime d, int year, int month, int day) {
      final b = BanglaDate.fromGregorian(d);
      expect((b.year, b.month, b.day), (year, month, day), reason: d.toIso8601String());
    }

    test('Pohela Boishakh is 14 April', () => expectDate(DateTime(2026, 4, 14), 1433, 1, 1));
    test('Victory Day is 1 Poush', () => expectDate(DateTime(2025, 12, 16), 1432, 9, 1));
    test('Language Day is 8 Falgun', () => expectDate(DateTime(2026, 2, 21), 1432, 11, 8));
    test('Independence Day is 12 Choitro', () => expectDate(DateTime(2026, 3, 26), 1432, 12, 12));
    test('13 April is the last day of Choitro', () => expectDate(DateTime(2026, 4, 13), 1432, 12, 30));
  });

  group('fasting rules', () {
    setUp(() => HijriDate.adjustmentDays = 0);

    test('Eid al-Fitr is forbidden', () {
      final eid = HijriDate(1447, 10, 1).toGregorian();
      expect(IslamicEvents.fastingOn(eid).status, FastStatus.forbidden);
    });

    test('days of Tashreeq are forbidden', () {
      final d = HijriDate(1447, 12, 12).toGregorian();
      expect(IslamicEvents.fastingOn(d).status, FastStatus.forbidden);
    });

    test('Ramadan is obligatory', () {
      final d = HijriDate(1447, 9, 5).toGregorian();
      expect(IslamicEvents.fastingOn(d).status, FastStatus.obligatory);
    });

    test('Arafah is sunnah', () {
      final d = HijriDate(1447, 12, 9).toGregorian();
      expect(IslamicEvents.fastingOn(d).status, FastStatus.sunnah);
    });
  });

  test('Hijri adjustment shifts both directions consistently', () {
    HijriDate.adjustmentDays = -1;
    final g = DateTime(2026, 3, 1);
    final h = HijriDate.fromGregorian(g);
    expect(h.toGregorian(), g);
    HijriDate.adjustmentDays = 0;
  });

  test('gold priced per vori by karat drives the zakat amount', () {
    const voriPrice = 150000.0;
    final result = ZakatCalculator.calculate(const ZakatInput(
      goldValue: 10 * voriPrice,
      goldPricePerGram: voriPrice / ZakatCalculator.gramsPerVori,
      silverNisab: false,
    ));
    expect(result.nisab, closeTo(7.5 * voriPrice, 1));
    expect(result.zakatDue, isTrue);
    expect(result.amount, closeTo(10 * voriPrice * 0.025, 0.01));
  });
}
