/// Study calculator. Nisab weights follow the common Hanafi figures
/// (7.5 vori gold, 52.5 vori silver). Prices change daily, so the user enters
/// them. This is not a fatwa.
class ZakatInput {
  final double cashAndSavings;
  final double goldGrams;
  final double silverGrams;
  final double goldPricePerGram;
  final double silverPricePerGram;

  /// Market value of all gold when it is priced per karat. Overrides
  /// [goldGrams] × [goldPricePerGram].
  final double? goldValue;
  final double tradeGoods;
  final double moneyOwedToYou;
  final double debtsYouOwe;
  final bool silverNisab;

  const ZakatInput({
    this.cashAndSavings = 0,
    this.goldGrams = 0,
    this.silverGrams = 0,
    this.goldPricePerGram = 0,
    this.silverPricePerGram = 0,
    this.goldValue,
    this.tradeGoods = 0,
    this.moneyOwedToYou = 0,
    this.debtsYouOwe = 0,
    this.silverNisab = true,
  });
}

class ZakatResult {
  final double goldValue;
  final double silverValue;
  final double grossWealth;
  final double netWealth;
  final double nisab;
  final bool zakatDue;
  final double amount;

  const ZakatResult({
    required this.goldValue,
    required this.silverValue,
    required this.grossWealth,
    required this.netWealth,
    required this.nisab,
    required this.zakatDue,
    required this.amount,
  });
}

class ZakatCalculator {
  static const double gramsPerVori = 11.664;
  static const double goldNisabGrams = 87.48;
  static const double silverNisabGrams = 612.36;
  static const double goldNisabVori = 7.5;
  static const double silverNisabVori = 52.5;
  static const double rate = 0.025;

  static ZakatResult calculate(ZakatInput input) {
    final goldValue = input.goldValue != null
        ? _nonNegative(input.goldValue!)
        : _nonNegative(input.goldGrams) * _nonNegative(input.goldPricePerGram);
    final silverValue = _nonNegative(input.silverGrams) * _nonNegative(input.silverPricePerGram);
    final gross = _nonNegative(input.cashAndSavings) +
        goldValue +
        silverValue +
        _nonNegative(input.tradeGoods) +
        _nonNegative(input.moneyOwedToYou);
    final net = gross - _nonNegative(input.debtsYouOwe);
    final wealth = net < 0 ? 0.0 : net;

    final nisab = input.silverNisab
        ? silverNisabGrams * _nonNegative(input.silverPricePerGram)
        : goldNisabGrams * _nonNegative(input.goldPricePerGram);

    final due = nisab > 0 && wealth >= nisab;
    return ZakatResult(
      goldValue: goldValue,
      silverValue: silverValue,
      grossWealth: gross,
      netWealth: wealth,
      nisab: nisab,
      zakatDue: due,
      amount: due ? wealth * rate : 0,
    );
  }

  static double voriToGrams(double vori) => vori * gramsPerVori;

  static double fitra({required int people, required double ratePerPerson}) {
    if (people <= 0) return 0;
    return people * _nonNegative(ratePerPerson);
  }

  static double _nonNegative(double value) => value.isNaN || value < 0 ? 0 : value;
}
