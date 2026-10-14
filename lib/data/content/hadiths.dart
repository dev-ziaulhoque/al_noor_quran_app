/// Short, well-known hadith with collection and number. Grades are the
/// collection's (Bukhari, Muslim) or at-Tirmidhi's own wording.
class Hadith {
  final String category;
  final String arabic;
  final String meaningEn;
  final String meaningBn;
  final String source;
  final String grade;

  const Hadith({
    required this.category,
    required this.arabic,
    required this.meaningEn,
    required this.meaningBn,
    required this.source,
    required this.grade,
  });

  String meaning(bool bangla) => bangla ? meaningBn : meaningEn;
}

class Hadiths {
  static const categories = ['Faith', 'Manners', 'Worship', 'Quran', 'Knowledge', 'Patience', 'Charity', 'Ramadan'];

  static const all = [
    Hadith(
      category: 'Faith',
      arabic: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
      meaningEn: 'Actions are only by intentions.',
      meaningBn: 'নিশ্চয়ই সকল কাজ নিয়তের উপর নির্ভরশীল।',
      source: 'Sahih al-Bukhari 1',
      grade: 'Sahih',
    ),
    Hadith(
      category: 'Manners',
      arabic: 'الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ',
      meaningEn: 'A Muslim is one from whose tongue and hand other Muslims are safe.',
      meaningBn: 'প্রকৃত মুসলিম সে, যার জিহ্বা ও হাত থেকে অন্য মুসলিমরা নিরাপদ থাকে।',
      source: 'Sahih al-Bukhari 10',
      grade: 'Sahih',
    ),
    Hadith(
      category: 'Quran',
      arabic: 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
      meaningEn: 'The best of you are those who learn the Quran and teach it.',
      meaningBn: 'তোমাদের মধ্যে সর্বোত্তম সে, যে কুরআন শেখে এবং শেখায়।',
      source: 'Sahih al-Bukhari 5027',
      grade: 'Sahih',
    ),
    Hadith(
      category: 'Faith',
      arabic: 'اتَّقِ اللَّهَ حَيْثُمَا كُنْتَ، وَأَتْبِعِ السَّيِّئَةَ الْحَسَنَةَ تَمْحُهَا، وَخَالِقِ النَّاسَ بِخُلُقٍ حَسَنٍ',
      meaningEn: 'Fear Allah wherever you are. Follow a bad deed with a good one and it will wipe it out. And treat people with good character.',
      meaningBn: 'যেখানেই থাকো আল্লাহকে ভয় করো, মন্দ কাজের পর ভালো কাজ করো, তা মন্দকে মুছে দেবে, আর মানুষের সাথে উত্তম আচরণ করো।',
      source: 'Jami‘ at-Tirmidhi 1987',
      grade: 'Hasan Sahih (at-Tirmidhi)',
    ),
    Hadith(
      category: 'Knowledge',
      arabic: 'مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا سَهَّلَ اللَّهُ لَهُ بِهِ طَرِيقًا إِلَى الْجَنَّةِ',
      meaningEn: 'Whoever travels a path seeking knowledge, Allah makes easy for him a path to Paradise.',
      meaningBn: 'যে ব্যক্তি জ্ঞান অর্জনের জন্য কোনো পথে চলে, আল্লাহ তার জন্য জান্নাতের পথ সহজ করে দেন।',
      source: 'Sahih Muslim 2699',
      grade: 'Sahih',
    ),
    Hadith(
      category: 'Charity',
      arabic: 'تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ لَكَ صَدَقَةٌ',
      meaningEn: 'Your smile in the face of your brother is charity for you.',
      meaningBn: 'তোমার ভাইয়ের সামনে তোমার হাসিমুখ তোমার জন্য সদকা।',
      source: 'Jami‘ at-Tirmidhi 1956',
      grade: 'Hasan Gharib (at-Tirmidhi)',
    ),
    Hadith(
      category: 'Faith',
      arabic: 'الدِّينُ النَّصِيحَةُ',
      meaningEn: 'The religion is sincere goodwill.',
      meaningBn: 'দ্বীন হলো কল্যাণকামিতা।',
      source: 'Sahih Muslim 55',
      grade: 'Sahih',
    ),
    Hadith(
      category: 'Faith',
      arabic: 'لَا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لِأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
      meaningEn: 'None of you truly believes until he loves for his brother what he loves for himself.',
      meaningBn: 'তোমাদের কেউ প্রকৃত মুমিন হবে না, যতক্ষণ না সে নিজের জন্য যা পছন্দ করে, তার ভাইয়ের জন্যও তা পছন্দ করে।',
      source: 'Sahih al-Bukhari 13',
      grade: 'Sahih',
    ),
    Hadith(
      category: 'Manners',
      arabic: 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
      meaningEn: 'Whoever believes in Allah and the Last Day, let him speak good or stay silent.',
      meaningBn: 'যে আল্লাহ ও শেষ দিবসে বিশ্বাস রাখে, সে যেন ভালো কথা বলে অথবা চুপ থাকে।',
      source: 'Sahih al-Bukhari 6018',
      grade: 'Sahih',
    ),
    Hadith(
      category: 'Worship',
      arabic: 'الطُّهُورُ شَطْرُ الْإِيمَانِ',
      meaningEn: 'Purity is half of faith.',
      meaningBn: 'পবিত্রতা ঈমানের অর্ধেক।',
      source: 'Sahih Muslim 223',
      grade: 'Sahih',
    ),
    Hadith(
      category: 'Patience',
      arabic: 'لَيْسَ الشَّدِيدُ بِالصُّرَعَةِ، إِنَّمَا الشَّدِيدُ الَّذِي يَمْلِكُ نَفْسَهُ عِنْدَ الْغَضَبِ',
      meaningEn: 'The strong one is not the one who throws others down. The strong one is the one who controls himself when angry.',
      meaningBn: 'কুস্তিতে হারিয়ে দেওয়া ব্যক্তি শক্তিশালী নয়; প্রকৃত শক্তিশালী সে, যে রাগের সময় নিজেকে নিয়ন্ত্রণ করে।',
      source: 'Sahih al-Bukhari 6114',
      grade: 'Sahih',
    ),
    Hadith(
      category: 'Charity',
      arabic: 'الْكَلِمَةُ الطَّيِّبَةُ صَدَقَةٌ',
      meaningEn: 'A good word is charity.',
      meaningBn: 'উত্তম কথাও সদকা।',
      source: 'Sahih al-Bukhari 2989',
      grade: 'Sahih',
    ),
    Hadith(
      category: 'Ramadan',
      arabic: 'مَنْ صَامَ رَمَضَانَ إِيمَانًا وَاحْتِسَابًا غُفِرَ لَهُ مَا تَقَدَّمَ مِنْ ذَنْبِهِ',
      meaningEn: 'Whoever fasts Ramadan with faith and hoping for reward, his past sins are forgiven.',
      meaningBn: 'যে ব্যক্তি ঈমানের সাথে ও সওয়াবের আশায় রমজানের রোজা রাখে, তার পূর্বের গুনাহ ক্ষমা করে দেওয়া হয়।',
      source: 'Sahih al-Bukhari 38',
      grade: 'Sahih',
    ),
    Hadith(
      category: 'Ramadan',
      arabic: 'مَنْ لَمْ يَدَعْ قَوْلَ الزُّورِ وَالْعَمَلَ بِهِ فَلَيْسَ لِلَّهِ حَاجَةٌ فِي أَنْ يَدَعَ طَعَامَهُ وَشَرَابَهُ',
      meaningEn: 'Whoever does not give up false speech and acting on it, Allah has no need of him giving up his food and drink.',
      meaningBn: 'যে ব্যক্তি মিথ্যা কথা ও সে অনুযায়ী কাজ ত্যাগ করে না, তার পানাহার ত্যাগ করায় আল্লাহর কোনো প্রয়োজন নেই।',
      source: 'Sahih al-Bukhari 1903',
      grade: 'Sahih',
    ),
    Hadith(
      category: 'Quran',
      arabic: 'اقْرَءُوا الْقُرْآنَ فَإِنَّهُ يَأْتِي يَوْمَ الْقِيَامَةِ شَفِيعًا لِأَصْحَابِهِ',
      meaningEn: 'Read the Quran, for it will come on the Day of Resurrection as an intercessor for its companions.',
      meaningBn: 'তোমরা কুরআন পড়ো, কেননা কিয়ামতের দিন তা তার পাঠকারীদের জন্য সুপারিশকারী হয়ে আসবে।',
      source: 'Sahih Muslim 804',
      grade: 'Sahih',
    ),
    Hadith(
      category: 'Worship',
      arabic: 'أَحَبُّ الْأَعْمَالِ إِلَى اللَّهِ أَدْوَمُهَا وَإِنْ قَلَّ',
      meaningEn: 'The deeds most beloved to Allah are those done consistently, even if they are small.',
      meaningBn: 'আল্লাহর কাছে সবচেয়ে প্রিয় আমল সেটি, যা নিয়মিত করা হয়, যদিও তা অল্প হয়।',
      source: 'Sahih al-Bukhari 6464',
      grade: 'Sahih',
    ),
    Hadith(
      category: 'Patience',
      arabic: 'عَجَبًا لِأَمْرِ الْمُؤْمِنِ، إِنَّ أَمْرَهُ كُلَّهُ خَيْرٌ',
      meaningEn: 'How wonderful is the affair of the believer: all of it is good for him.',
      meaningBn: 'মুমিনের বিষয়টি কতই না চমৎকার! তার সব কিছুই কল্যাণকর।',
      source: 'Sahih Muslim 2999',
      grade: 'Sahih',
    ),
    Hadith(
      category: 'Manners',
      arabic: 'مَنْ لَا يَرْحَمُ لَا يُرْحَمُ',
      meaningEn: 'Whoever does not show mercy will not be shown mercy.',
      meaningBn: 'যে দয়া করে না, তাকে দয়া করা হয় না।',
      source: 'Sahih al-Bukhari 5997',
      grade: 'Sahih',
    ),
    Hadith(
      category: 'Charity',
      arabic: 'مَا نَقَصَتْ صَدَقَةٌ مِنْ مَالٍ',
      meaningEn: 'Charity does not decrease wealth.',
      meaningBn: 'সদকা সম্পদ কমায় না।',
      source: 'Sahih Muslim 2588',
      grade: 'Sahih',
    ),
    Hadith(
      category: 'Manners',
      arabic: 'الْمُؤْمِنُ لِلْمُؤْمِنِ كَالْبُنْيَانِ يَشُدُّ بَعْضُهُ بَعْضًا',
      meaningEn: 'A believer to another believer is like a building whose parts support one another.',
      meaningBn: 'এক মুমিন অন্য মুমিনের জন্য একটি ভবনের মতো, যার এক অংশ অন্য অংশকে শক্তিশালী করে।',
      source: 'Sahih al-Bukhari 481',
      grade: 'Sahih',
    ),
    Hadith(
      category: 'Knowledge',
      arabic: 'يَسِّرُوا وَلَا تُعَسِّرُوا، وَبَشِّرُوا وَلَا تُنَفِّرُوا',
      meaningEn: 'Make things easy and do not make them hard. Give good news and do not drive people away.',
      meaningBn: 'সহজ করো, কঠিন করো না; সুসংবাদ দাও, বিতৃষ্ণা সৃষ্টি করো না।',
      source: 'Sahih al-Bukhari 69',
      grade: 'Sahih',
    ),
    Hadith(
      category: 'Worship',
      arabic: 'الدُّعَاءُ هُوَ الْعِبَادَةُ',
      meaningEn: 'Supplication is worship.',
      meaningBn: 'দোয়াই ইবাদত।',
      source: 'Jami‘ at-Tirmidhi 2969',
      grade: 'Hasan Sahih (at-Tirmidhi)',
    ),
  ];

  static Hadith forDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day).difference(DateTime(date.year)).inDays;
    return all[day % all.length];
  }
}
