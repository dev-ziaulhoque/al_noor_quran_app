import 'package:flutter_test/flutter_test.dart';
import 'package:al_noor_app/core/zakat/zakat_calculator.dart';

void main() {
  test('silver nisab charges 2.5 percent once wealth reaches it', () {
    const price = 100.0;
    final nisab = ZakatCalculator.silverNisabGrams * price;
    final result = ZakatCalculator.calculate(ZakatInput(
      cashAndSavings: nisab,
      silverPricePerGram: price,
      silverNisab: true,
    ));
    expect(result.zakatDue, isTrue);
    expect(result.amount, closeTo(nisab * 0.025, 0.01));
  });

  test('debts can bring wealth under nisab', () {
    final result = ZakatCalculator.calculate(const ZakatInput(
      cashAndSavings: 100000,
      debtsYouOwe: 100000,
      silverPricePerGram: 100,
      silverNisab: true,
    ));
    expect(result.netWealth, 0);
    expect(result.zakatDue, isFalse);
    expect(result.amount, 0);
  });

  test('fitra is people times the local rate', () {
    expect(ZakatCalculator.fitra(people: 4, ratePerPerson: 120), 480);
    expect(ZakatCalculator.fitra(people: 0, ratePerPerson: 120), 0);
    expect(ZakatCalculator.fitra(people: 2, ratePerPerson: -5), 0);
  });
}
