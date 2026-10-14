/// Civil (tabular) Hijri dates. Arithmetic only, so it works offline.
///
/// Moon-sighting announcements, including those from the Islamic Foundation
/// Bangladesh, can place Eid and the start of Ramadan a day earlier or later.
class HijriDate {
  final int year;
  final int month;
  final int day;

  const HijriDate(this.year, this.month, this.day);

  /// Days added to the civil calendar to match the local moon sighting
  /// (Bangladesh is often one day behind). Set from settings.
  static int adjustmentDays = 0;

  static const List<String> monthNamesAr = [
    'مُحَرَّم',
    'صَفَر',
    'رَبِيع الأَوَّل',
    'رَبِيع الآخِر',
    'جُمَادَى الأُولَى',
    'جُمَادَى الآخِرَة',
    'رَجَب',
    'شَعْبَان',
    'رَمَضَان',
    'شَوَّال',
    'ذُو القَعْدَة',
    'ذُو الحِجَّة',
  ];

  String get monthNameAr => monthNamesAr[month - 1];

  static const List<String> monthNames = [
    'Muharram',
    'Safar',
    "Rabi' al-Awwal",
    "Rabi' al-Thani",
    'Jumada al-Awwal',
    'Jumada al-Thani',
    'Rajab',
    "Sha'ban",
    'Ramadan',
    'Shawwal',
    "Dhul Qa'dah",
    'Dhul Hijjah',
  ];

  String get monthName => monthNames[month - 1];

  String get formatted => '$day $monthName $year AH';

  bool get isRamadan => month == 9;

  static HijriDate fromGregorian(DateTime date) {
    return _fromJd(_gregorianToJd(date.year, date.month, date.day) + adjustmentDays);
  }

  DateTime toGregorian() => _jdToGregorian(_toJd() - adjustmentDays);

  @override
  bool operator ==(Object other) =>
      other is HijriDate && other.year == year && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  /// 30-year tabular cycle. Year 30 of a cycle (remainder 0) is not a leap year.
  static bool isLeapYear(int year) {
    const leaps = {2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29};
    return leaps.contains(year % 30);
  }

  static int monthLength(int year, int month) {
    if (month.isOdd) return 30;
    if (month == 12 && isLeapYear(year)) return 30;
    return 29;
  }

  static int _gregorianToJd(int year, int month, int day) {
    var y = year;
    var m = month;
    if (m < 3) {
      y -= 1;
      m += 12;
    }
    final a = y ~/ 100;
    final b = 2 - a + (a ~/ 4);
    return (365.25 * (y + 4716)).floor() + (30.6001 * (m + 1)).floor() + day + b - 1524;
  }

  static HijriDate _fromJd(int jd) {
    var l = jd - 1948440 + 10632;
    final n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;
    final j = ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) + (l ~/ 5670) * ((43 * l) ~/ 15238);
    l = l - ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) - (j ~/ 16) * ((15238 * j) ~/ 43) + 29;
    final hMonth = (24 * l) ~/ 709;
    final hDay = l - (709 * hMonth) ~/ 24;
    final hYear = 30 * n + j - 30;
    return HijriDate(hYear, hMonth, hDay);
  }

  int _toJd() {
    return ((11 * year + 3) ~/ 30) + 354 * year + 30 * month - ((month - 1) ~/ 2) + day + 1948440 - 385;
  }

  static DateTime _jdToGregorian(int jd) {
    final a = jd + 32044;
    final b = (4 * a + 3) ~/ 146097;
    final c = a - (146097 * b) ~/ 4;
    final d = (4 * c + 3) ~/ 1461;
    final e = c - (1461 * d) ~/ 4;
    final m = (5 * e + 2) ~/ 153;
    final day = e - (153 * m + 2) ~/ 5 + 1;
    final month = m + 3 - 12 * (m ~/ 10);
    final year = 100 * b + d - 4800 + (m ~/ 10);
    return DateTime(year, month, day);
  }
}
