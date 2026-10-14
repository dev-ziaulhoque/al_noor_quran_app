/// Duas with their source. Wording follows the cited collection; meanings
/// are plain translations, not new rulings.
class Dua {
  final String id;
  final String category;
  final String titleEn;
  final String titleBn;
  final String arabic;
  final String meaningEn;
  final String meaningBn;
  final String source;
  final String? noteEn;
  final String? noteBn;

  const Dua({
    required this.id,
    required this.category,
    required this.titleEn,
    required this.titleBn,
    required this.arabic,
    required this.meaningEn,
    required this.meaningBn,
    required this.source,
    this.noteEn,
    this.noteBn,
  });

  String title(bool bangla) => bangla ? titleBn : titleEn;
  String meaning(bool bangla) => bangla ? meaningBn : meaningEn;
  String? note(bool bangla) => bangla ? noteBn : noteEn;
}

class DuaCategory {
  final String id;
  final String nameEn;
  final String nameBn;
  final String emoji;

  const DuaCategory(this.id, this.nameEn, this.nameBn, this.emoji);

  String name(bool bangla) => bangla ? nameBn : nameEn;
}

class Duas {
  static const categories = [
    DuaCategory('morning', 'Morning & evening', 'সকাল-সন্ধ্যা', '🌅'),
    DuaCategory('sleep', 'Sleep & waking', 'ঘুম ও জাগরণ', '🌙'),
    DuaCategory('daily', 'Daily life', 'দৈনন্দিন', '🏠'),
    DuaCategory('prayer', 'Mosque & prayer', 'মসজিদ ও নামাজ', '🕌'),
    DuaCategory('travel', 'Travel', 'সফর', '🚗'),
    DuaCategory('forgiveness', 'Forgiveness', 'ক্ষমা প্রার্থনা', '🤲'),
    DuaCategory('hardship', 'Hardship & protection', 'বিপদ ও সুরক্ষা', '🛡️'),
    DuaCategory('quran', 'From the Quran', 'কুরআনের দোয়া', '📖'),
    DuaCategory('ramadan', 'Ramadan', 'রমজান', '🌙'),
  ];

  static const all = [
    Dua(
      id: 'morning',
      category: 'morning',
      titleEn: 'Morning remembrance',
      titleBn: 'সকালের জিকির',
      arabic: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      meaningEn: 'We have reached the morning and all dominion belongs to Allah. Praise is for Allah. None has the right to be worshipped but Allah alone, with no partner. His is the dominion and His is the praise, and He is able to do all things.',
      meaningBn: 'আমরা সকালে উপনীত হয়েছি এবং সকল রাজত্ব আল্লাহর। সকল প্রশংসা আল্লাহর। আল্লাহ ছাড়া কোনো সত্য ইলাহ নেই, তিনি এক, তাঁর কোনো শরিক নেই। রাজত্ব তাঁরই, প্রশংসা তাঁরই, এবং তিনি সব কিছুর উপর ক্ষমতাবান।',
      source: 'Sahih Muslim 2723',
    ),
    Dua(
      id: 'evening',
      category: 'morning',
      titleEn: 'Evening remembrance',
      titleBn: 'সন্ধ্যার জিকির',
      arabic: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      meaningEn: 'We have reached the evening and all dominion belongs to Allah. Praise is for Allah. None has the right to be worshipped but Allah alone, with no partner. His is the dominion and His is the praise, and He is able to do all things.',
      meaningBn: 'আমরা সন্ধ্যায় উপনীত হয়েছি এবং সকল রাজত্ব আল্লাহর। সকল প্রশংসা আল্লাহর। আল্লাহ ছাড়া কোনো সত্য ইলাহ নেই, তিনি এক, তাঁর কোনো শরিক নেই। রাজত্ব তাঁরই, প্রশংসা তাঁরই, এবং তিনি সব কিছুর উপর ক্ষমতাবান।',
      source: 'Sahih Muslim 2723',
    ),
    Dua(
      id: 'sayyid_istighfar',
      category: 'forgiveness',
      titleEn: 'Sayyid al-Istighfar',
      titleBn: 'সাইয়েদুল ইস্তিগফার',
      arabic: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي، فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
      meaningEn: 'O Allah, You are my Lord. None has the right to be worshipped but You. You created me and I am Your servant, and I keep Your covenant and promise as much as I can. I seek refuge in You from the evil I have done. I acknowledge Your favour upon me and I acknowledge my sin, so forgive me, for none forgives sins but You.',
      meaningBn: 'হে আল্লাহ, তুমি আমার রব। তুমি ছাড়া কোনো সত্য ইলাহ নেই। তুমি আমাকে সৃষ্টি করেছ এবং আমি তোমার বান্দা। আমি সাধ্যমতো তোমার অঙ্গীকার ও প্রতিশ্রুতির উপর আছি। আমার কৃতকর্মের অনিষ্ট থেকে তোমার আশ্রয় চাই। আমার উপর তোমার অনুগ্রহ স্বীকার করছি এবং আমার গুনাহ স্বীকার করছি। অতএব আমাকে ক্ষমা করো, কারণ তুমি ছাড়া কেউ গুনাহ ক্ষমা করতে পারে না।',
      source: 'Sahih al-Bukhari 6306',
      noteEn: 'The Prophet ﷺ called it the best way to ask forgiveness, in the morning and the evening.',
      noteBn: 'নবী ﷺ এটিকে ক্ষমা প্রার্থনার শ্রেষ্ঠ দোয়া বলেছেন; সকাল ও সন্ধ্যায় পড়া হয়।',
    ),
    Dua(
      id: 'bismillah_protection',
      category: 'morning',
      titleEn: 'Protection, three times',
      titleBn: 'সুরক্ষার দোয়া (তিনবার)',
      arabic: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
      meaningEn: 'In the name of Allah, with whose name nothing on earth or in heaven can cause harm, and He is the All-Hearing, the All-Knowing.',
      meaningBn: 'আল্লাহর নামে, যাঁর নামের সাথে আসমান ও জমিনের কোনো কিছুই ক্ষতি করতে পারে না, আর তিনি সর্বশ্রোতা, সর্বজ্ঞ।',
      source: 'Sunan Abi Dawud 5088 · Jami‘ at-Tirmidhi 3388',
      noteEn: 'Say it three times in the morning and three times in the evening.',
      noteBn: 'সকালে তিনবার ও সন্ধ্যায় তিনবার পড়ুন।',
    ),
    Dua(
      id: 'waking',
      category: 'sleep',
      titleEn: 'On waking up',
      titleBn: 'ঘুম থেকে জেগে',
      arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      meaningEn: 'Praise is for Allah who gave us life after He caused us to die, and to Him is the return.',
      meaningBn: 'সকল প্রশংসা আল্লাহর, যিনি আমাদের মৃত্যুর (ঘুমের) পর জীবিত করেছেন, আর তাঁরই দিকে পুনরুত্থান।',
      source: 'Sahih al-Bukhari 6312',
    ),
    Dua(
      id: 'sleeping',
      category: 'sleep',
      titleEn: 'Before sleeping',
      titleBn: 'ঘুমানোর আগে',
      arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      meaningEn: 'In Your name, O Allah, I die and I live.',
      meaningBn: 'হে আল্লাহ, তোমার নামেই আমি মরি (ঘুমাই) ও জীবিত হই (জাগি)।',
      source: 'Sahih al-Bukhari 6324',
    ),
    Dua(
      id: 'ayat_kursi',
      category: 'sleep',
      titleEn: 'Ayat al-Kursi at bedtime',
      titleBn: 'ঘুমের আগে আয়াতুল কুরসি',
      arabic: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
      meaningEn: 'Allah – there is no deity except Him, the Ever-Living, the Sustainer of existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is before them and what will be after them, and they encompass nothing of His knowledge except what He wills. His Kursi extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great.',
      meaningBn: 'আল্লাহ, তিনি ছাড়া কোনো উপাস্য নেই, তিনি চিরঞ্জীব, সবকিছুর ধারক। তাঁকে তন্দ্রা ও নিদ্রা স্পর্শ করে না। আসমান ও জমিনে যা কিছু আছে সবই তাঁর। কে আছে যে তাঁর অনুমতি ছাড়া তাঁর কাছে সুপারিশ করবে? তাদের সামনে ও পেছনে যা আছে তিনি জানেন। তিনি যা চান তা ছাড়া তাঁর জ্ঞানের কিছুই তারা আয়ত্ত করতে পারে না। তাঁর কুরসি আসমান ও জমিন পরিব্যাপ্ত, এবং এগুলোর রক্ষণাবেক্ষণ তাঁকে ক্লান্ত করে না। তিনি সর্বোচ্চ, মহামহিম।',
      source: 'Quran 2:255 · Sahih al-Bukhari 2311',
    ),
    Dua(
      id: 'before_eating',
      category: 'daily',
      titleEn: 'Before eating',
      titleBn: 'খাওয়ার আগে',
      arabic: 'بِسْمِ اللَّهِ',
      meaningEn: 'In the name of Allah.',
      meaningBn: 'আল্লাহর নামে।',
      source: 'Sahih al-Bukhari 5376 · Sahih Muslim 2022',
      noteEn: 'Eat with the right hand and from what is nearest to you.',
      noteBn: 'ডান হাতে এবং নিজের সামনে থেকে খাবেন।',
    ),
    Dua(
      id: 'forgot_bismillah',
      category: 'daily',
      titleEn: 'If you forgot Bismillah',
      titleBn: 'বিসমিল্লাহ ভুলে গেলে',
      arabic: 'بِسْمِ اللَّهِ أَوَّلَهُ وَآخِرَهُ',
      meaningEn: 'In the name of Allah, at its beginning and at its end.',
      meaningBn: 'আল্লাহর নামে, এর শুরুতে ও শেষে।',
      source: 'Sunan Abi Dawud 3767 · Jami‘ at-Tirmidhi 1858',
    ),
    Dua(
      id: 'after_eating',
      category: 'daily',
      titleEn: 'After eating',
      titleBn: 'খাওয়ার পরে',
      arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا، وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ',
      meaningEn: 'Praise is for Allah who fed me this and provided it for me without any might or power from myself.',
      meaningBn: 'সকল প্রশংসা আল্লাহর, যিনি আমাকে এটি খাওয়ালেন এবং আমার কোনো শক্তি ও সামর্থ্য ছাড়াই আমাকে এ রিজিক দিলেন।',
      source: 'Sunan Abi Dawud 4023 · Jami‘ at-Tirmidhi 3458',
    ),
    Dua(
      id: 'leaving_home',
      category: 'daily',
      titleEn: 'Leaving home',
      titleBn: 'ঘর থেকে বের হওয়ার সময়',
      arabic: 'بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      meaningEn: 'In the name of Allah, I place my trust in Allah, and there is no might nor power except with Allah.',
      meaningBn: 'আল্লাহর নামে, আমি আল্লাহর উপর ভরসা করলাম, আল্লাহর সাহায্য ছাড়া কোনো শক্তি ও সামর্থ্য নেই।',
      source: 'Sunan Abi Dawud 5095 · Jami‘ at-Tirmidhi 3426',
    ),
    Dua(
      id: 'toilet_enter',
      category: 'daily',
      titleEn: 'Entering the toilet',
      titleBn: 'শৌচাগারে প্রবেশের সময়',
      arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ',
      meaningEn: 'O Allah, I seek refuge in You from the male and female devils.',
      meaningBn: 'হে আল্লাহ, আমি তোমার কাছে পুরুষ ও নারী শয়তান থেকে আশ্রয় চাই।',
      source: 'Sahih al-Bukhari 142 · Sahih Muslim 375',
    ),
    Dua(
      id: 'toilet_leave',
      category: 'daily',
      titleEn: 'Leaving the toilet',
      titleBn: 'শৌচাগার থেকে বের হয়ে',
      arabic: 'غُفْرَانَكَ',
      meaningEn: 'I ask Your forgiveness.',
      meaningBn: '(হে আল্লাহ) তোমার ক্ষমা চাই।',
      source: 'Sunan Abi Dawud 30 · Jami‘ at-Tirmidhi 7',
    ),
    Dua(
      id: 'sick_visit',
      category: 'daily',
      titleEn: 'Visiting someone who is ill',
      titleBn: 'অসুস্থকে দেখতে গিয়ে',
      arabic: 'لَا بَأْسَ، طَهُورٌ إِنْ شَاءَ اللَّهُ',
      meaningEn: 'No harm. It is a purification, if Allah wills.',
      meaningBn: 'কোনো সমস্যা নেই, আল্লাহ চাইলে এটি (গুনাহ থেকে) পবিত্রতা।',
      source: 'Sahih al-Bukhari 3616',
    ),
    Dua(
      id: 'rain',
      category: 'daily',
      titleEn: 'When it rains',
      titleBn: 'বৃষ্টির সময়',
      arabic: 'اللَّهُمَّ صَيِّبًا نَافِعًا',
      meaningEn: 'O Allah, let it be a beneficial rain.',
      meaningBn: 'হে আল্লাহ, উপকারী বৃষ্টি দাও।',
      source: 'Sahih al-Bukhari 1032',
    ),
    Dua(
      id: 'mosque_enter',
      category: 'prayer',
      titleEn: 'Entering the mosque',
      titleBn: 'মসজিদে প্রবেশের সময়',
      arabic: 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
      meaningEn: 'O Allah, open for me the doors of Your mercy.',
      meaningBn: 'হে আল্লাহ, আমার জন্য তোমার রহমতের দরজাগুলো খুলে দাও।',
      source: 'Sahih Muslim 713',
    ),
    Dua(
      id: 'mosque_leave',
      category: 'prayer',
      titleEn: 'Leaving the mosque',
      titleBn: 'মসজিদ থেকে বের হওয়ার সময়',
      arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
      meaningEn: 'O Allah, I ask You of Your bounty.',
      meaningBn: 'হে আল্লাহ, আমি তোমার অনুগ্রহ প্রার্থনা করছি।',
      source: 'Sahih Muslim 713',
    ),
    Dua(
      id: 'after_salah',
      category: 'prayer',
      titleEn: 'After the obligatory prayer',
      titleBn: 'ফরজ নামাজের পর',
      arabic: 'أَسْتَغْفِرُ اللَّهَ، أَسْتَغْفِرُ اللَّهَ، أَسْتَغْفِرُ اللَّهَ، اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
      meaningEn: 'I seek Allah\'s forgiveness (three times). O Allah, You are Peace and from You is peace. Blessed are You, O Owner of majesty and honour.',
      meaningBn: 'আমি আল্লাহর কাছে ক্ষমা চাই (তিনবার)। হে আল্লাহ, তুমিই শান্তি, তোমার কাছ থেকেই শান্তি। তুমি বরকতময়, হে মহিমা ও সম্মানের অধিকারী।',
      source: 'Sahih Muslim 591',
    ),
    Dua(
      id: 'travel',
      category: 'travel',
      titleEn: 'Riding a vehicle',
      titleBn: 'যানবাহনে উঠে',
      arabic: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَىٰ رَبِّنَا لَمُنقَلِبُونَ',
      meaningEn: 'Glory be to Him who has subjected this to us, and we could never have done it ourselves. And to our Lord we will surely return.',
      meaningBn: 'পবিত্র তিনি, যিনি এটিকে আমাদের বশীভূত করে দিয়েছেন, অথচ আমরা একে বশ করতে সক্ষম ছিলাম না। আর নিশ্চয়ই আমরা আমাদের রবের দিকে প্রত্যাবর্তনকারী।',
      source: 'Quran 43:13–14 · Sahih Muslim 1342',
    ),
    Dua(
      id: 'stopping_place',
      category: 'travel',
      titleEn: 'Stopping at a place',
      titleBn: 'কোথাও অবস্থান করলে',
      arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      meaningEn: 'I seek refuge in the perfect words of Allah from the evil of what He has created.',
      meaningBn: 'আমি আল্লাহর পরিপূর্ণ বাণীসমূহের মাধ্যমে তাঁর সৃষ্টির অনিষ্ট থেকে আশ্রয় চাই।',
      source: 'Sahih Muslim 2708',
    ),
    Dua(
      id: 'yunus',
      category: 'hardship',
      titleEn: 'In distress (dua of Yunus)',
      titleBn: 'বিপদে (ইউনুস আ.-এর দোয়া)',
      arabic: 'لَا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
      meaningEn: 'There is no deity except You; glory be to You. Indeed, I have been of the wrongdoers.',
      meaningBn: 'তুমি ছাড়া কোনো ইলাহ নেই, তুমি পবিত্র; নিশ্চয়ই আমি জালিমদের অন্তর্ভুক্ত ছিলাম।',
      source: 'Quran 21:87 · Jami‘ at-Tirmidhi 3505',
    ),
    Dua(
      id: 'anxiety',
      category: 'hardship',
      titleEn: 'Worry, grief and debt',
      titleBn: 'দুশ্চিন্তা, দুঃখ ও ঋণ',
      arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْبُخْلِ وَالْجُبْنِ، وَضَلَعِ الدَّيْنِ وَغَلَبَةِ الرِّجَالِ',
      meaningEn: 'O Allah, I seek refuge in You from worry and grief, from helplessness and laziness, from miserliness and cowardice, and from the burden of debt and from being overpowered by people.',
      meaningBn: 'হে আল্লাহ, আমি তোমার কাছে আশ্রয় চাই দুশ্চিন্তা ও দুঃখ থেকে, অক্ষমতা ও অলসতা থেকে, কৃপণতা ও কাপুরুষতা থেকে, ঋণের বোঝা ও মানুষের প্রাধান্য থেকে।',
      source: 'Sahih al-Bukhari 6369',
    ),
    Dua(
      id: 'adam',
      category: 'forgiveness',
      titleEn: 'Dua of Adam and Hawwa',
      titleBn: 'আদম ও হাওয়া (আ.)-এর দোয়া',
      arabic: 'رَبَّنَا ظَلَمْنَا أَنفُسَنَا وَإِن لَّمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ',
      meaningEn: 'Our Lord, we have wronged ourselves, and if You do not forgive us and have mercy on us, we will surely be among the losers.',
      meaningBn: 'হে আমাদের রব, আমরা নিজেদের উপর জুলুম করেছি। তুমি যদি আমাদের ক্ষমা না করো এবং দয়া না করো, তবে আমরা অবশ্যই ক্ষতিগ্রস্তদের অন্তর্ভুক্ত হব।',
      source: 'Quran 7:23',
    ),
    Dua(
      id: 'dunya_akhirah',
      category: 'quran',
      titleEn: 'Good in this world and the next',
      titleBn: 'দুনিয়া ও আখিরাতের কল্যাণ',
      arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      meaningEn: 'Our Lord, give us good in this world and good in the Hereafter, and protect us from the punishment of the Fire.',
      meaningBn: 'হে আমাদের রব, আমাদের দুনিয়াতে কল্যাণ দাও, আখিরাতেও কল্যাণ দাও এবং আমাদের জাহান্নামের আজাব থেকে রক্ষা করো।',
      source: 'Quran 2:201 · Sahih al-Bukhari 6389',
      noteEn: 'Anas said this was the dua the Prophet ﷺ made most often.',
      noteBn: 'আনাস (রা.) বলেন, নবী ﷺ এই দোয়াটি সবচেয়ে বেশি করতেন।',
    ),
    Dua(
      id: 'parents',
      category: 'quran',
      titleEn: 'For parents',
      titleBn: 'মা-বাবার জন্য',
      arabic: 'رَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
      meaningEn: 'My Lord, have mercy on them both as they brought me up when I was small.',
      meaningBn: 'হে আমার রব, তাঁদের প্রতি দয়া করো, যেমন তাঁরা শৈশবে আমাকে লালনপালন করেছেন।',
      source: 'Quran 17:24',
    ),
    Dua(
      id: 'family',
      category: 'quran',
      titleEn: 'For spouse and children',
      titleBn: 'স্ত্রী ও সন্তানের জন্য',
      arabic: 'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا',
      meaningEn: 'Our Lord, grant us from our spouses and children comfort to our eyes, and make us leaders of the righteous.',
      meaningBn: 'হে আমাদের রব, আমাদের স্ত্রী ও সন্তানদের মাধ্যমে আমাদের চোখের শীতলতা দান করো এবং আমাদের মুত্তাকিদের ইমাম বানাও।',
      source: 'Quran 25:74',
    ),
    Dua(
      id: 'knowledge',
      category: 'quran',
      titleEn: 'For knowledge',
      titleBn: 'জ্ঞান বৃদ্ধির জন্য',
      arabic: 'رَّبِّ زِدْنِي عِلْمًا',
      meaningEn: 'My Lord, increase me in knowledge.',
      meaningBn: 'হে আমার রব, আমার জ্ঞান বৃদ্ধি করে দাও।',
      source: 'Quran 20:114',
    ),
    Dua(
      id: 'ease',
      category: 'quran',
      titleEn: 'For ease in a task',
      titleBn: 'কাজ সহজ হওয়ার জন্য',
      arabic: 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
      meaningEn: 'My Lord, expand for me my chest and make my task easy for me.',
      meaningBn: 'হে আমার রব, আমার বক্ষ প্রশস্ত করে দাও এবং আমার কাজ সহজ করে দাও।',
      source: 'Quran 20:25–26',
    ),
    Dua(
      id: 'guidance',
      category: 'quran',
      titleEn: 'For guidance',
      titleBn: 'হিদায়াতের জন্য',
      arabic: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
      meaningEn: 'Guide us to the straight path.',
      meaningBn: 'আমাদের সরল পথ দেখাও।',
      source: 'Quran 1:6',
    ),
    Dua(
      id: 'iftar',
      category: 'ramadan',
      titleEn: 'At iftar',
      titleBn: 'ইফতারের সময়',
      arabic: 'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ وَثَبَتَ الْأَجْرُ إِنْ شَاءَ اللَّهُ',
      meaningEn: 'The thirst has gone, the veins are moist, and the reward is confirmed, if Allah wills.',
      meaningBn: 'পিপাসা দূর হয়েছে, শিরাগুলো সিক্ত হয়েছে এবং আল্লাহ চাইলে প্রতিদান নিশ্চিত হয়েছে।',
      source: 'Sunan Abi Dawud 2357',
      noteEn: 'Graded hasan by al-Albani; some scholars consider the chain weak. Breaking the fast does not depend on it.',
      noteBn: 'আলবানী (রহ.) হাসান বলেছেন; কেউ কেউ সনদকে দুর্বল বলেছেন। ইফতার এই দোয়ার উপর নির্ভরশীল নয়।',
    ),
    Dua(
      id: 'qadr',
      category: 'ramadan',
      titleEn: 'Laylat al-Qadr',
      titleBn: 'লাইলাতুল কদরের দোয়া',
      arabic: 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
      meaningEn: 'O Allah, You are Most Forgiving and You love to forgive, so forgive me.',
      meaningBn: 'হে আল্লাহ, তুমি ক্ষমাশীল, ক্ষমা করতে ভালোবাসো, অতএব আমাকে ক্ষমা করো।',
      source: 'Jami‘ at-Tirmidhi 3513',
      noteEn: 'Taught by the Prophet ﷺ to Aishah for the night of Qadr.',
      noteBn: 'নবী ﷺ আয়েশা (রা.)-কে কদরের রাতের জন্য এই দোয়া শিখিয়েছেন।',
    ),
  ];

  static List<Dua> inCategory(String id) => all.where((d) => d.category == id).toList();

  static Dua? byId(String id) {
    for (final d in all) {
      if (d.id == id) return d;
    }
    return null;
  }
}
