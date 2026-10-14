import '../utils/hijri_date.dart';

enum EventKind { major, night, fast, info }

class IslamicEvent {
  final String name;
  final String nameBn;
  final String note;
  final String noteBn;
  final int month;
  final int day;
  final EventKind kind;

  const IslamicEvent({
    required this.name,
    required this.nameBn,
    required this.note,
    required this.noteBn,
    required this.month,
    required this.day,
    this.kind = EventKind.info,
  });

  String title(bool bangla) => bangla ? nameBn : name;
  String detail(bool bangla) => bangla ? noteBn : note;
}

class UpcomingIslamicDate {
  final IslamicEvent event;
  final DateTime gregorian;
  final HijriDate hijri;

  const UpcomingIslamicDate({
    required this.event,
    required this.gregorian,
    required this.hijri,
  });

  int daysFrom(DateTime today) {
    final start = DateTime(today.year, today.month, today.day);
    return gregorian.difference(start).inDays;
  }
}

enum FastStatus { none, obligatory, sunnah, forbidden }

class FastInfo {
  final FastStatus status;
  final String reason;
  final String reasonBn;
  const FastInfo(this.status, this.reason, this.reasonBn);

  String label(bool bangla) => bangla ? reasonBn : reason;
}

/// Night events sit on the Hijri day whose evening starts that night, because
/// an Islamic night begins at the Maghrib before its day.
class IslamicEvents {
  static const List<IslamicEvent> all = [
    IslamicEvent(
      name: 'Islamic New Year',
      nameBn: 'হিজরি নববর্ষ',
      note: '1 Muharram. A day for reflection, not a celebration copied from other new-year customs.',
      noteBn: '১ মুহাররম। আত্মসমালোচনার দিন; অন্য নববর্ষের প্রথা অনুকরণের নয়।',
      month: 1,
      day: 1,
      kind: EventKind.major,
    ),
    IslamicEvent(
      name: 'Tasu\'a fast',
      nameBn: 'তাসুআর রোজা',
      note: '9 Muharram. The Prophet ﷺ intended to fast the 9th together with Ashura (Muslim 1134).',
      noteBn: '৯ মুহাররম। নবী ﷺ আশুরার সাথে ৯ তারিখেও রোজা রাখার ইচ্ছা করেছিলেন (মুসলিম ১১৩৪)।',
      month: 1,
      day: 9,
      kind: EventKind.fast,
    ),
    IslamicEvent(
      name: 'Ashura',
      nameBn: 'আশুরা',
      note: '10 Muharram. Fasting it expiates the sins of the previous year (Muslim 1162). Fast the 9th or the 11th with it.',
      noteBn: '১০ মুহাররম। এ দিনের রোজা পূর্ববর্তী এক বছরের গুনাহের কাফফারা (মুসলিম ১১৬২)। সাথে ৯ বা ১১ তারিখও রাখুন।',
      month: 1,
      day: 10,
      kind: EventKind.fast,
    ),
    IslamicEvent(
      name: '12 Rabi\' al-Awwal',
      nameBn: '১২ রবিউল আউয়াল',
      note: 'Widely observed as the Prophet\'s ﷺ birthday (Eid-e-Miladunnabi, a public holiday in Bangladesh). Historians differ on the exact date; it is also reported as the day of his passing.',
      noteBn: 'অনেকে নবী ﷺ-এর জন্মদিন হিসেবে পালন করেন (ঈদে মিলাদুন্নবী, বাংলাদেশে সরকারি ছুটি)। সঠিক তারিখ নিয়ে ঐতিহাসিকদের মতভেদ আছে; এ দিন তাঁর ওফাতের দিন হিসেবেও বর্ণিত।',
      month: 3,
      day: 12,
    ),
    IslamicEvent(
      name: 'Isra and Mi\'raj (27 Rajab)',
      nameBn: 'শবে মিরাজ (২৭ রজব)',
      note: 'The date many communities observe for the Night Journey. Its exact date is not established in authentic reports, and no special prayer is prescribed for it.',
      noteBn: 'অনেকে এই রাতকে মিরাজের রাত হিসেবে পালন করেন। সঠিক তারিখ সহিহ বর্ণনায় প্রমাণিত নয় এবং এ রাতের জন্য বিশেষ কোনো নামাজ নির্ধারিত নেই।',
      month: 7,
      day: 26,
      kind: EventKind.night,
    ),
    IslamicEvent(
      name: 'Mid-Sha\'ban night (Shab-e-Barat)',
      nameBn: 'শবে বরাত (মধ্য শাবানের রাত)',
      note: 'Begins at Maghrib. Some hadith mention Allah\'s forgiveness on this night; scholars differ on their strength. No specific prayer is prescribed.',
      noteBn: 'মাগরিব থেকে শুরু। কিছু হাদিসে এ রাতে আল্লাহর ক্ষমার কথা এসেছে; সেগুলোর মান নিয়ে আলেমদের মতভেদ আছে। নির্দিষ্ট কোনো নামাজ নির্ধারিত নেই।',
      month: 8,
      day: 14,
      kind: EventKind.night,
    ),
    IslamicEvent(
      name: 'Ramadan begins',
      nameBn: 'রমজান শুরু',
      note: 'Expected first fast. Taraweeh starts the night before. Confirm the moon sighting with your local mosque.',
      noteBn: 'সম্ভাব্য প্রথম রোজা। আগের রাত থেকে তারাবিহ শুরু। স্থানীয় চাঁদ দেখার ঘোষণা নিশ্চিত করুন।',
      month: 9,
      day: 1,
      kind: EventKind.major,
    ),
    IslamicEvent(
      name: 'Last ten nights begin',
      nameBn: 'শেষ দশকের রাত শুরু',
      note: 'The 21st night begins at Maghrib. Seek Laylat al-Qadr in the odd nights (Bukhari 2017). I\'tikaf usually starts now.',
      noteBn: 'মাগরিব থেকে ২১তম রাত। বেজোড় রাতগুলোতে লাইলাতুল কদর তালাশ করুন (বুখারি ২০১৭)। ইতিকাফ সাধারণত এখন শুরু হয়।',
      month: 9,
      day: 20,
      kind: EventKind.night,
    ),
    IslamicEvent(
      name: '23rd night',
      nameBn: '২৩তম রাত',
      note: 'An odd night of the last ten. Laylat al-Qadr is better than a thousand months (Al-Qadr 97:3).',
      noteBn: 'শেষ দশকের বেজোড় রাত। লাইলাতুল কদর হাজার মাসের চেয়ে উত্তম (সূরা কদর ৯৭:৩)।',
      month: 9,
      day: 22,
      kind: EventKind.night,
    ),
    IslamicEvent(
      name: '25th night',
      nameBn: '২৫তম রাত',
      note: 'An odd night of the last ten. Keep the night in prayer if you can.',
      noteBn: 'শেষ দশকের বেজোড় রাত। সম্ভব হলে রাত ইবাদতে কাটান।',
      month: 9,
      day: 24,
      kind: EventKind.night,
    ),
    IslamicEvent(
      name: '27th night (Shab-e-Qadr)',
      nameBn: '২৭তম রাত (শবে কদর)',
      note: 'The night many communities observe. It is not certain; the other odd nights matter too.',
      noteBn: 'অনেকে এই রাতকে শবে কদর হিসেবে পালন করেন। এটি নিশ্চিত নয়; অন্য বেজোড় রাতগুলোও গুরুত্বপূর্ণ।',
      month: 9,
      day: 26,
      kind: EventKind.night,
    ),
    IslamicEvent(
      name: '29th night',
      nameBn: '২৯তম রাত',
      note: 'The last odd night of Ramadan. Do not leave the search until only the 27th.',
      noteBn: 'রমজানের শেষ বেজোড় রাত। শুধু ২৭তম রাতের অপেক্ষায় থাকবেন না।',
      month: 9,
      day: 28,
      kind: EventKind.night,
    ),
    IslamicEvent(
      name: 'Eid al-Fitr',
      nameBn: 'ঈদুল ফিতর',
      note: '1 Shawwal. Pay Zakat al-Fitr before the Eid prayer. Fasting today is not allowed. Confirm the day locally.',
      noteBn: '১ শাওয়াল। ঈদের নামাজের আগে সদকাতুল ফিতর আদায় করুন। আজ রোজা রাখা নিষেধ। স্থানীয় ঘোষণা নিশ্চিত করুন।',
      month: 10,
      day: 1,
      kind: EventKind.major,
    ),
    IslamicEvent(
      name: 'Six fasts of Shawwal',
      nameBn: 'শাওয়ালের ছয় রোজা',
      note: 'From 2 Shawwal. Ramadan followed by six days of Shawwal is like fasting the whole year (Muslim 1164).',
      noteBn: '২ শাওয়াল থেকে। রমজানের পর শাওয়ালের ছয় রোজা সারা বছর রোজার সমান (মুসলিম ১১৬৪)।',
      month: 10,
      day: 2,
      kind: EventKind.fast,
    ),
    IslamicEvent(
      name: 'First ten days of Dhul Hijjah',
      nameBn: 'জিলহজের প্রথম দশক',
      note: 'No days are better for good deeds than these (Bukhari 969). Those sacrificing should not cut hair or nails (Muslim 1977).',
      noteBn: 'নেক আমলের জন্য এর চেয়ে উত্তম দিন নেই (বুখারি ৯৬৯)। কুরবানিদাতা চুল-নখ কাটবেন না (মুসলিম ১৯৭৭)।',
      month: 12,
      day: 1,
      kind: EventKind.major,
    ),
    IslamicEvent(
      name: 'Hajj begins (Day of Tarwiyah)',
      nameBn: 'হজ শুরু (তারবিয়ার দিন)',
      note: '8 Dhul Hijjah. Pilgrims go to Mina.',
      noteBn: '৮ জিলহজ। হাজিরা মিনায় যান।',
      month: 12,
      day: 8,
    ),
    IslamicEvent(
      name: 'Day of Arafah',
      nameBn: 'আরাফার দিন',
      note: '9 Dhul Hijjah. Fasting it expiates the sins of the previous and the coming year (Muslim 1162). Takbir of Tashreeq starts after Fajr.',
      noteBn: '৯ জিলহজ। এ দিনের রোজা আগের ও পরের এক বছরের গুনাহের কাফফারা (মুসলিম ১১৬২)। ফজর থেকে তাকবিরে তাশরিক শুরু।',
      month: 12,
      day: 9,
      kind: EventKind.fast,
    ),
    IslamicEvent(
      name: 'Eid al-Adha',
      nameBn: 'ঈদুল আজহা',
      note: '10 Dhul Hijjah. Qurbani can be offered after the Eid prayer until sunset of 12 Dhul Hijjah (13 in some schools). Confirm the day locally.',
      noteBn: '১০ জিলহজ। ঈদের নামাজের পর থেকে ১২ জিলহজ সূর্যাস্ত পর্যন্ত কুরবানি করা যায় (কিছু মাযহাবে ১৩ পর্যন্ত)। স্থানীয় ঘোষণা নিশ্চিত করুন।',
      month: 12,
      day: 10,
      kind: EventKind.major,
    ),
    IslamicEvent(
      name: 'Days of Tashreeq',
      nameBn: 'আইয়ামে তাশরিক',
      note: '11–13 Dhul Hijjah. Days of eating, drinking and remembering Allah (Muslim 1141). Fasting is not allowed.',
      noteBn: '১১–১৩ জিলহজ। খাওয়া, পান করা ও আল্লাহর জিকিরের দিন (মুসলিম ১১৪১)। রোজা রাখা নিষেধ।',
      month: 12,
      day: 11,
    ),
  ];

  static List<IslamicEvent> on(HijriDate h) =>
      all.where((e) => e.month == h.month && e.day == h.day).toList();

  static FastInfo fastingOn(DateTime date) {
    final h = HijriDate.fromGregorian(date);
    if (h.month == 10 && h.day == 1) return const FastInfo(FastStatus.forbidden, 'Eid day: fasting is not allowed', 'ঈদের দিন: রোজা রাখা নিষেধ');
    if (h.month == 12 && h.day == 10) return const FastInfo(FastStatus.forbidden, 'Eid day: fasting is not allowed', 'ঈদের দিন: রোজা রাখা নিষেধ');
    if (h.month == 12 && h.day >= 11 && h.day <= 13) {
      return const FastInfo(FastStatus.forbidden, 'Days of Tashreeq: fasting is not allowed', 'আইয়ামে তাশরিক: রোজা রাখা নিষেধ');
    }
    if (h.month == 9) return const FastInfo(FastStatus.obligatory, 'Ramadan: obligatory fast', 'রমজান: ফরজ রোজা');
    if (h.month == 12 && h.day == 9) return const FastInfo(FastStatus.sunnah, 'Day of Arafah', 'আরাফার দিন');
    if (h.month == 1 && (h.day == 9 || h.day == 10 || h.day == 11)) return const FastInfo(FastStatus.sunnah, 'Ashura fast', 'আশুরার রোজা');
    if (h.day >= 13 && h.day <= 15) return const FastInfo(FastStatus.sunnah, 'White days (13, 14, 15)', 'আইয়ামে বীজ (১৩, ১৪, ১৫)');
    if (h.month == 10 && h.day >= 2) return const FastInfo(FastStatus.sunnah, 'Six fasts of Shawwal', 'শাওয়ালের ছয় রোজা');
    if (h.month == 12 && h.day <= 8) return const FastInfo(FastStatus.sunnah, 'First days of Dhul Hijjah', 'জিলহজের প্রথম দিনগুলো');
    if (date.weekday == DateTime.monday) return const FastInfo(FastStatus.sunnah, 'Monday fast', 'সোমবারের রোজা');
    if (date.weekday == DateTime.thursday) return const FastInfo(FastStatus.sunnah, 'Thursday fast', 'বৃহস্পতিবারের রোজা');
    if (date.weekday == DateTime.friday) {
      return const FastInfo(FastStatus.none, 'Do not single out Friday for fasting (Bukhari 1985)', 'শুধু শুক্রবারকে রোজার জন্য নির্দিষ্ট করবেন না (বুখারি ১৯৮৫)');
    }
    return const FastInfo(FastStatus.none, 'Voluntary fasting is allowed', 'নফল রোজা রাখা যায়');
  }

  static List<UpcomingIslamicDate> upcoming(DateTime from, {int withinDays = 400}) {
    final today = DateTime(from.year, from.month, from.day);
    final hijriToday = HijriDate.fromGregorian(today);
    final results = <UpcomingIslamicDate>[];

    for (final event in all) {
      for (var year = hijriToday.year; year <= hijriToday.year + 1; year++) {
        final hijri = HijriDate(year, event.month, event.day);
        final gregorian = hijri.toGregorian();
        final day = DateTime(gregorian.year, gregorian.month, gregorian.day);
        final diff = day.difference(today).inDays;
        if (diff >= 0 && diff <= withinDays) {
          results.add(UpcomingIslamicDate(event: event, gregorian: day, hijri: hijri));
          break;
        }
      }
    }

    results.sort((a, b) => a.gregorian.compareTo(b.gregorian));
    return results;
  }
}
