/// Bangla calendar (Bangabda) as revised by Bangladesh in 2019:
/// 1 Boishakh is 14 April, the first six months have 31 days, Falgun has
/// 29 days (30 in a Gregorian leap year) and the rest have 30.
class BanglaDate {
  final int year;
  final int month;
  final int day;

  const BanglaDate(this.year, this.month, this.day);

  static const monthsBn = [
    'বৈশাখ', 'জ্যৈষ্ঠ', 'আষাঢ়', 'শ্রাবণ', 'ভাদ্র', 'আশ্বিন',
    'কার্তিক', 'অগ্রহায়ণ', 'পৌষ', 'মাঘ', 'ফাল্গুন', 'চৈত্র',
  ];
  static const monthsEn = [
    'Boishakh', 'Joishtho', 'Asharh', 'Shrabon', 'Bhadro', 'Ashwin',
    'Kartik', 'Ogrohayon', 'Poush', 'Magh', 'Falgun', 'Choitro',
  ];
  static const seasonsBn = ['গ্রীষ্ম', 'বর্ষা', 'শরৎ', 'হেমন্ত', 'শীত', 'বসন্ত'];
  static const seasonsEn = ['Summer', 'Monsoon', 'Autumn', 'Late autumn', 'Winter', 'Spring'];

  static bool _isLeap(int y) => (y % 4 == 0 && y % 100 != 0) || y % 400 == 0;

  static BanglaDate fromGregorian(DateTime date) {
    final d = DateTime.utc(date.year, date.month, date.day);
    final startYear = d.isBefore(DateTime.utc(date.year, 4, 14)) ? date.year - 1 : date.year;
    var offset = d.difference(DateTime.utc(startYear, 4, 14)).inDays;
    final lengths = [31, 31, 31, 31, 31, 31, 30, 30, 30, 30, _isLeap(startYear + 1) ? 30 : 29, 30];
    var month = 0;
    while (month < 11 && offset >= lengths[month]) {
      offset -= lengths[month];
      month++;
    }
    return BanglaDate(startYear - 593, month + 1, offset + 1);
  }

  String monthName(bool bangla) => (bangla ? monthsBn : monthsEn)[month - 1];
  String season(bool bangla) => (bangla ? seasonsBn : seasonsEn)[(month - 1) ~/ 2];
}
