import 'package:get/get.dart';

import '../utils/hijri_date.dart';

/// Helpers for text that mixes numbers and names, so Bangla screens show
/// Bangla digits and month names.
class LocaleText {
  static bool get isBangla => Get.locale?.languageCode == 'bn';

  static const _bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

  static String digits(Object value) {
    final s = value.toString();
    if (!isBangla) return s;
    final out = StringBuffer();
    for (final ch in s.split('')) {
      final d = int.tryParse(ch);
      out.write(d == null || ch.trim().isEmpty ? ch : _bnDigits[d]);
    }
    return out.toString();
  }

  static String hijri(HijriDate h) {
    if (isBangla) return '${digits(h.day)} ${h.monthName.tr} ${digits(h.year)} হিজরি';
    return h.formatted;
  }

  static String hijriMonth(HijriDate h) => '${h.monthName.tr} ${digits(h.year)}';

  static const List<String> weekdaysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const List<String> weekdaysBn = ['সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি', 'রবি'];
  static const List<String> weekdaysFullEn = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  static const List<String> weekdaysFullBn = ['সোমবার', 'মঙ্গলবার', 'বুধবার', 'বৃহস্পতিবার', 'শুক্রবার', 'শনিবার', 'রবিবার'];

  static String weekdayShort(int weekday) => (isBangla ? weekdaysBn : weekdaysEn)[weekday - 1];
  static String weekday(int weekday) => (isBangla ? weekdaysFullBn : weekdaysFullEn)[weekday - 1];

  static const List<String> monthsEn = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const List<String> monthsBn = [
    'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
    'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর',
  ];

  static String gregorian(DateTime d, {bool withYear = true, bool withWeekday = false}) {
    final month = (isBangla ? monthsBn : monthsEn)[d.month - 1];
    final head = withWeekday ? '${weekday(d.weekday)}, ' : '';
    final year = withYear ? ' ${digits(d.year)}' : '';
    return '$head${digits(d.day)} $month$year';
  }

  static String gregorianShort(DateTime d) {
    final month = (isBangla ? monthsBn : monthsEn)[d.month - 1];
    return '${digits(d.day)} ${isBangla ? month : month.substring(0, 3)}';
  }

  /// `h:mm AM` with Bangla digits when needed.
  static String time(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final suffix = t.hour < 12 ? 'AM' : 'PM';
    return digits('$h:$m ${suffix.tr}');
  }

  static String duration(Duration d) {
    if (d.isNegative) d = Duration.zero;
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (isBangla) {
      if (h > 0) return '${digits(h)} ঘণ্টা ${digits(m)} মিনিট';
      return '${digits(m)} মিনিট';
    }
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  static String clock(Duration d) {
    if (d.isNegative) d = Duration.zero;
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return digits('$h:$m:$s');
  }
}
