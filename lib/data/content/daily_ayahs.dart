class DailyAyah {
  final int surah;
  final int ayah;
  final String arabic;
  final String meaningEn;
  final String meaningBn;
  final String reference;
  final String connection;

  const DailyAyah({
    required this.surah,
    required this.ayah,
    required this.arabic,
    required this.meaningEn,
    required this.meaningBn,
    required this.reference,
    required this.connection,
  });
}

/// Complete short ayat only. Meanings are brief paraphrases for the share
/// card, not a published tafsir or a copyrighted translation.
class DailyAyahs {
  static const List<DailyAyah> all = [
    DailyAyah(
      surah: 94,
      ayah: 5,
      arabic: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
      meaningEn: 'With hardship comes ease.',
      meaningBn: 'কষ্টের সাথে স্বস্তি আছে।',
      reference: 'Ash-Sharh 94:5',
      connection: 'The next ayah repeats the same promise: Ash-Sharh 94:6. Read them together.',
    ),
    DailyAyah(
      surah: 94,
      ayah: 6,
      arabic: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      meaningEn: 'Indeed, with hardship comes ease.',
      meaningBn: 'নিশ্চয়ই কষ্টের সাথে স্বস্তি আছে।',
      reference: 'Ash-Sharh 94:6',
      connection: 'This repeats 94:5. The repetition is the point of the pair.',
    ),
    DailyAyah(
      surah: 112,
      ayah: 1,
      arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
      meaningEn: 'Say: He is Allah, the One.',
      meaningBn: 'বল, তিনি আল্লাহ, একক।',
      reference: 'Al-Ikhlas 112:1',
      connection: 'The rest of the surah (112:2–4) completes this statement of tawhid.',
    ),
    DailyAyah(
      surah: 112,
      ayah: 2,
      arabic: 'اللَّهُ الصَّمَدُ',
      meaningEn: 'Allah is the Eternal, the One all creation needs.',
      meaningBn: 'আল্লাহ অমুখাপেক্ষী, সকলে তাঁর মুখাপেক্ষী।',
      reference: 'Al-Ikhlas 112:2',
      connection: 'Read with 112:1. “As-Samad” belongs with Allah’s oneness, not on its own.',
    ),
    DailyAyah(
      surah: 1,
      ayah: 2,
      arabic: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      meaningEn: 'Praise belongs to Allah, Lord of all worlds.',
      meaningBn: 'সমস্ত প্রশংসা আল্লাহর, যিনি সকল সৃষ্টির রব।',
      reference: 'Al-Fatihah 1:2',
      connection: 'Al-Fatihah 1:5 then moves from praise to worship and asking for help.',
    ),
    DailyAyah(
      surah: 1,
      ayah: 5,
      arabic: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
      meaningEn: 'You alone we worship, and You alone we ask for help.',
      meaningBn: 'আমরা শুধু তোমারই ইবাদত করি এবং শুধু তোমারই সাহায্য চাই।',
      reference: 'Al-Fatihah 1:5',
      connection: 'This sits between praise (1:2–4) and the prayer for guidance (1:6–7).',
    ),
    DailyAyah(
      surah: 108,
      ayah: 1,
      arabic: 'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ',
      meaningEn: 'We have given you al-Kawthar.',
      meaningBn: 'আমরা তোমাকে কাউসার দিয়েছি।',
      reference: 'Al-Kawthar 108:1',
      connection: '108:2 answers the gift: pray to your Lord. A related hadith about the Quran is in Sahih al-Bukhari 5027 (Sahih): the best of people learn the Quran and teach it.',
    ),
    DailyAyah(
      surah: 103,
      ayah: 1,
      arabic: 'وَالْعَصْرِ',
      meaningEn: 'By time.',
      meaningBn: 'সময়ের শপথ।',
      reference: 'Al-Asr 103:1',
      connection: 'The oath introduces 103:2–3: loss, then the people who are excepted.',
    ),
    DailyAyah(
      surah: 103,
      ayah: 2,
      arabic: 'إِنَّ الْإِنسَانَ لَفِي خُسْرٍ',
      meaningEn: 'People are in loss.',
      meaningBn: 'মানুষ ক্ষতির মধ্যে আছে।',
      reference: 'Al-Asr 103:2',
      connection: '103:3 gives the exception: faith, good deeds, truth, and patience.',
    ),
    DailyAyah(
      surah: 112,
      ayah: 3,
      arabic: 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
      meaningEn: 'He does not beget, and He was not begotten.',
      meaningBn: 'তিনি কাউকে জন্ম দেননি এবং তাঁকেও জন্ম দেওয়া হয়নি।',
      reference: 'Al-Ikhlas 112:3',
      connection: 'Read the whole of Al-Ikhlas. 112:4 adds that none is comparable to Him.',
    ),
    DailyAyah(
      surah: 112,
      ayah: 4,
      arabic: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
      meaningEn: 'There is none comparable to Him.',
      meaningBn: 'তাঁর সমতুল্য কেউ নেই।',
      reference: 'Al-Ikhlas 112:4',
      connection: 'This closes Al-Ikhlas after 112:1–3.',
    ),
    DailyAyah(
      surah: 108,
      ayah: 2,
      arabic: 'فَصَلِّ لِرَبِّكَ وَانْحَرْ',
      meaningEn: 'So pray to your Lord, and offer sacrifice for Him.',
      meaningBn: 'অতএব তোমার রবের জন্য সালাত পড়ো এবং কোরবানি করো।',
      reference: 'Al-Kawthar 108:2',
      connection: 'This is the response to the gift named in 108:1.',
    ),
  ];

  static DailyAyah forDate(DateTime date) {
    final start = DateTime(date.year, 1, 1);
    final index = date.difference(start).inDays % all.length;
    return all[index];
  }
}
