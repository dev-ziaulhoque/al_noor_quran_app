import 'package:flutter/material.dart';

/// One ayah or a short run of ayahs. Only the reference is stored; the
/// Arabic and translation come from the Quran service, so nothing is typed
/// by hand.
class ThemeAyah {
  final int surah;
  final int from;
  final int to;

  const ThemeAyah(this.surah, this.from, [int? to]) : to = to ?? from;

  String get ref => to > from ? '$surah:$from-$to' : '$surah:$from';
  String get key => '$surah:$from:$to';

  static ThemeAyah? parse(String key) {
    final p = key.split(':').map(int.tryParse).toList();
    if (p.length < 2 || p.any((e) => e == null)) return null;
    return ThemeAyah(p[0]!, p[1]!, p.length > 2 ? p[2] : null);
  }
}

class ReflectionTheme {
  final String id;
  final String nameEn;
  final String nameBn;
  final String arabic;
  final IconData icon;
  final Color color;
  final String descEn;
  final String descBn;
  final List<ThemeAyah> ayahs;
  final List<String> keywords;
  final List<String> promptsEn;
  final List<String> promptsBn;
  final String? duaCategory;

  const ReflectionTheme({
    required this.id,
    required this.nameEn,
    required this.nameBn,
    required this.arabic,
    required this.icon,
    required this.color,
    required this.descEn,
    required this.descBn,
    required this.ayahs,
    required this.keywords,
    required this.promptsEn,
    required this.promptsBn,
    this.duaCategory,
  });

  String name(bool bangla) => bangla ? nameBn : nameEn;
  String desc(bool bangla) => bangla ? descBn : descEn;
  List<String> prompts(bool bangla) => bangla ? promptsBn : promptsEn;
}

class Mood {
  final String id;
  final String emoji;
  final String labelEn;
  final String labelBn;
  final String themeId;

  const Mood(this.id, this.emoji, this.labelEn, this.labelBn, this.themeId);

  String label(bool bangla) => bangla ? labelBn : labelEn;
}

class ReflectionThemes {
  static const moods = [
    Mood('grateful', '😊', 'Grateful', 'কৃতজ্ঞ', 'gratitude'),
    Mood('calm', '🙂', 'Calm', 'শান্ত', 'purpose'),
    Mood('okay', '😐', 'Okay', 'মোটামুটি', 'tawakkul'),
    Mood('anxious', '😟', 'Anxious', 'দুশ্চিন্তায়', 'anxiety'),
    Mood('sad', '😢', 'Sad', 'মন খারাপ', 'sadness'),
  ];

  static Mood? moodById(String? id) {
    for (final m in moods) {
      if (m.id == id) return m;
    }
    return null;
  }

  static const all = [
    ReflectionTheme(
      id: 'despair',
      nameEn: 'Despair & hope',
      nameBn: 'হতাশা ও আশা',
      arabic: 'لَا تَقْنَطُوا',
      icon: Icons.wb_twilight_rounded,
      color: Color(0xFF3F6FB5),
      descEn: 'When everything feels closed, Allah reminds us that His mercy is wider than any sin or loss.',
      descBn: 'যখন সব দরজা বন্ধ মনে হয়, আল্লাহ মনে করিয়ে দেন তাঁর রহমত যেকোনো গুনাহ বা ক্ষতির চেয়ে বড়।',
      ayahs: [ThemeAyah(39, 53), ThemeAyah(12, 87), ThemeAyah(15, 56), ThemeAyah(94, 5, 6), ThemeAyah(7, 156), ThemeAyah(6, 54), ThemeAyah(2, 286)],
      keywords: ['hopeless', 'despair', 'give up', 'giving up', 'depressed', 'no hope', 'pointless', 'broken', 'হতাশ', 'নিরাশ', 'আশা নেই', 'ভেঙে পড়', 'হাল ছেড়', 'ডিপ্রেশন', 'বিষণ্ণ'],
      promptsEn: ['What exactly feels closed to me right now?', 'When did Allah open a way for me before, when I could not see one?', 'What is one small step I can take today, and leave the rest to Allah?'],
      promptsBn: ['এই মুহূর্তে ঠিক কোন বিষয়টা আমার কাছে বন্ধ মনে হচ্ছে?', 'আগে কখন আল্লাহ এমন পথ খুলে দিয়েছিলেন, যা আমি দেখতে পাইনি?', 'আজ আমি কোন ছোট্ট পদক্ষেপ নিতে পারি, আর বাকিটা আল্লাহর উপর ছেড়ে দিতে পারি?'],
      duaCategory: 'hardship',
    ),
    ReflectionTheme(
      id: 'patience',
      nameEn: 'Patience',
      nameBn: 'ধৈর্য',
      arabic: 'الصَّبْر',
      icon: Icons.hourglass_bottom_rounded,
      color: Color(0xFF1B7A5A),
      descEn: 'Sabr is not silence; it is holding on to Allah while the test lasts.',
      descBn: 'সবর মানে চুপ থাকা নয়; পরীক্ষা চলাকালে আল্লাহকে আঁকড়ে ধরে থাকা।',
      ayahs: [ThemeAyah(2, 153), ThemeAyah(2, 155, 157), ThemeAyah(39, 10), ThemeAyah(3, 200), ThemeAyah(16, 127), ThemeAyah(8, 46), ThemeAyah(103, 1, 3)],
      keywords: ['patience', 'patient', 'wait', 'waiting', 'tired', 'struggle', 'test', 'trial', 'endure', 'ধৈর্য', 'সবর', 'অপেক্ষা', 'ক্লান্ত', 'সহ্য', 'পরীক্ষা', 'কষ্ট'],
      promptsEn: ['What test am I in right now?', 'What does patience look like for me today, in practice?', 'Who has shown me patience that I can learn from?'],
      promptsBn: ['এখন আমি কোন পরীক্ষার মধ্যে আছি?', 'আজ বাস্তবে আমার জন্য ধৈর্য মানে কী?', 'কার ধৈর্য থেকে আমি শিখতে পারি?'],
      duaCategory: 'hardship',
    ),
    ReflectionTheme(
      id: 'rizq',
      nameEn: 'Rizq & provision',
      nameBn: 'রিজিক',
      arabic: 'الرِّزْق',
      icon: Icons.spa_rounded,
      color: Color(0xFF9A6B1F),
      descEn: 'Provision is written by Allah. Our part is effort, honesty, gratitude and trust.',
      descBn: 'রিজিক আল্লাহর লেখা। আমাদের দায়িত্ব চেষ্টা, সততা, কৃতজ্ঞতা ও ভরসা।',
      ayahs: [ThemeAyah(11, 6), ThemeAyah(51, 22), ThemeAyah(51, 58), ThemeAyah(65, 2, 3), ThemeAyah(14, 7), ThemeAyah(71, 10, 12), ThemeAyah(29, 60), ThemeAyah(2, 268)],
      keywords: ['money', 'job', 'income', 'salary', 'debt', 'loan', 'business', 'provision', 'rizq', 'poor', 'career', 'unemployed', 'রিজিক', 'টাকা', 'চাকরি', 'আয়', 'বেতন', 'ঋণ', 'ধার', 'ব্যবসা', 'অভাব', 'বেকার'],
      promptsEn: ['What am I worried about losing or not getting?', 'What blessings of provision do I already have today?', 'Is there anything in my earning I need to make cleaner?'],
      promptsBn: ['আমি কী হারানোর বা না পাওয়ার ভয়ে আছি?', 'আজ আমার কাছে রিজিকের কোন নিয়ামতগুলো আছে?', 'আমার উপার্জনে কি এমন কিছু আছে যা আরও পবিত্র করা দরকার?'],
    ),
    ReflectionTheme(
      id: 'anxiety',
      nameEn: 'Anxiety & worry',
      nameBn: 'দুশ্চিন্তা',
      arabic: 'الطُّمَأْنِينَة',
      icon: Icons.air_rounded,
      color: Color(0xFF4F7C8A),
      descEn: 'Hearts find rest in the remembrance of Allah. Nothing reaches us except what He has written.',
      descBn: 'আল্লাহর স্মরণেই অন্তর প্রশান্তি পায়। তিনি যা লিখেছেন তা ছাড়া কিছুই আমাদের কাছে পৌঁছায় না।',
      ayahs: [ThemeAyah(13, 28), ThemeAyah(9, 51), ThemeAyah(3, 173), ThemeAyah(65, 3), ThemeAyah(20, 46), ThemeAyah(2, 286)],
      keywords: ['anxious', 'anxiety', 'worry', 'worried', 'stress', 'stressed', 'nervous', 'overthinking', 'panic', 'exam', 'চিন্তা', 'দুশ্চিন্তা', 'টেনশন', 'উদ্বেগ', 'অস্থির', 'পরীক্ষা নিয়ে'],
      promptsEn: ['What is the worry, written plainly in one sentence?', 'Which part of it is in my control, and which is with Allah?', 'What remembrance can I keep on my tongue today?'],
      promptsBn: ['দুশ্চিন্তাটা এক বাক্যে স্পষ্ট করে লিখি।', 'এর কোন অংশ আমার হাতে, আর কোনটা আল্লাহর হাতে?', 'আজ মুখে কোন জিকির রাখতে পারি?'],
      duaCategory: 'hardship',
    ),
    ReflectionTheme(
      id: 'sadness',
      nameEn: 'Sadness & grief',
      nameBn: 'দুঃখ ও শোক',
      arabic: 'الحُزْن',
      icon: Icons.water_drop_rounded,
      color: Color(0xFF5B6EA8),
      descEn: 'The prophets wept and complained to Allah alone. Your sorrow is seen.',
      descBn: 'নবীরাও কেঁদেছেন এবং শুধু আল্লাহর কাছেই অভিযোগ করেছেন। আপনার কষ্ট তিনি দেখছেন।',
      ayahs: [ThemeAyah(12, 86), ThemeAyah(9, 40), ThemeAyah(3, 139), ThemeAyah(93, 3, 5), ThemeAyah(94, 1, 8), ThemeAyah(2, 155, 157)],
      keywords: ['sad', 'sadness', 'cry', 'crying', 'grief', 'loss', 'lost someone', 'hurt', 'heartbroken', 'pain', 'দুঃখ', 'কান্না', 'কাঁদ', 'শোক', 'মন খারাপ', 'কষ্ট পাচ্ছি', 'হারিয়ে'],
      promptsEn: ['What am I grieving, and what do I want to say to Allah about it?', 'What would I tell a friend who felt this way?', 'What gentle thing can I do for myself today?'],
      promptsBn: ['আমি কীসের জন্য কষ্ট পাচ্ছি, আর আল্লাহকে কী বলতে চাই?', 'কোনো বন্ধু এমন অনুভব করলে তাকে কী বলতাম?', 'আজ নিজের জন্য কোন সহজ ভালো কাজটি করতে পারি?'],
      duaCategory: 'hardship',
    ),
    ReflectionTheme(
      id: 'gratitude',
      nameEn: 'Gratitude',
      nameBn: 'কৃতজ্ঞতা',
      arabic: 'الشُّكْر',
      icon: Icons.favorite_rounded,
      color: Color(0xFFB0572E),
      descEn: 'If you are grateful, Allah will give you more. Counting blessings is worship.',
      descBn: 'কৃতজ্ঞ হলে আল্লাহ আরও বাড়িয়ে দেন। নিয়ামত গোনাও ইবাদত।',
      ayahs: [ThemeAyah(14, 7), ThemeAyah(2, 152), ThemeAyah(16, 18), ThemeAyah(31, 12), ThemeAyah(27, 19), ThemeAyah(55, 13)],
      keywords: ['grateful', 'thankful', 'thank', 'blessed', 'alhamdulillah', 'gratitude', 'happy', 'শুকরিয়া', 'আলহামদুলিল্লাহ', 'কৃতজ্ঞ', 'ধন্যবাদ', 'খুশি', 'নিয়ামত'],
      promptsEn: ['Three blessings from today I almost overlooked:', 'Who should I thank today, besides Allah?', 'How can I use one blessing in a way that pleases Allah?'],
      promptsBn: ['আজকের তিনটি নিয়ামত, যা প্রায় চোখ এড়িয়ে যাচ্ছিল:', 'আল্লাহর পাশাপাশি আজ কাকে ধন্যবাদ দেওয়া উচিত?', 'একটি নিয়ামত কীভাবে আল্লাহর সন্তুষ্টিতে ব্যবহার করতে পারি?'],
    ),
    ReflectionTheme(
      id: 'repentance',
      nameEn: 'Repentance',
      nameBn: 'তওবা ও ক্ষমা',
      arabic: 'التَّوْبَة',
      icon: Icons.refresh_rounded,
      color: Color(0xFF2E7D6B),
      descEn: 'However far we go, the door of tawbah stays open, and Allah loves those who return.',
      descBn: 'যত দূরেই যাই, তওবার দরজা খোলা; আল্লাহ ফিরে আসা মানুষদের ভালোবাসেন।',
      ayahs: [ThemeAyah(39, 53), ThemeAyah(4, 110), ThemeAyah(3, 135), ThemeAyah(66, 8), ThemeAyah(25, 70), ThemeAyah(2, 222)],
      keywords: ['sin', 'sinned', 'guilty', 'guilt', 'regret', 'forgive me', 'mistake', 'ashamed', 'repent', 'গুনাহ', 'পাপ', 'অনুশোচনা', 'তওবা', 'ক্ষমা', 'ভুল করেছি', 'লজ্জা'],
      promptsEn: ['What do I want to leave behind, honestly?', 'What will I do differently the next time it comes?', 'Is there someone I need to make things right with?'],
      promptsBn: ['সত্যি করে, আমি কী পেছনে ফেলে আসতে চাই?', 'পরের বার একই পরিস্থিতিতে কী ভিন্নভাবে করব?', 'কারও সাথে কি সম্পর্ক ঠিক করে নেওয়া দরকার?'],
      duaCategory: 'forgiveness',
    ),
    ReflectionTheme(
      id: 'tawakkul',
      nameEn: 'Trust in Allah',
      nameBn: 'তাওয়াক্কুল',
      arabic: 'التَّوَكُّل',
      icon: Icons.anchor_rounded,
      color: Color(0xFF3D5A80),
      descEn: 'Tie the camel, then trust. Whoever relies on Allah, He is enough for him.',
      descBn: 'উট বেঁধে নাও, তারপর ভরসা করো। যে আল্লাহর উপর ভরসা করে, তিনিই তার জন্য যথেষ্ট।',
      ayahs: [ThemeAyah(65, 3), ThemeAyah(3, 159), ThemeAyah(9, 51), ThemeAyah(3, 173), ThemeAyah(25, 58)],
      keywords: ['decision', 'decide', 'trust', 'plan', 'future', 'uncertain', 'confused', 'choice', 'ভরসা', 'সিদ্ধান্ত', 'তাওয়াক্কুল', 'ভবিষ্যৎ', 'পরিকল্পনা', 'দ্বিধা'],
      promptsEn: ['What decision am I carrying?', 'Have I done my part: istikharah, advice, effort?', 'What would it feel like to truly hand the outcome to Allah?'],
      promptsBn: ['কোন সিদ্ধান্তের ভার আমি বয়ে বেড়াচ্ছি?', 'আমি কি আমার অংশ করেছি: ইস্তিখারা, পরামর্শ, চেষ্টা?', 'ফলাফল সত্যিই আল্লাহর হাতে ছেড়ে দিলে কেমন লাগবে?'],
    ),
    ReflectionTheme(
      id: 'loneliness',
      nameEn: 'Loneliness',
      nameBn: 'একাকীত্ব',
      arabic: 'القُرْب',
      icon: Icons.person_outline_rounded,
      color: Color(0xFF6A5A9C),
      descEn: 'Allah is near, closer than your jugular vein, and answers the one who calls.',
      descBn: 'আল্লাহ কাছেই, গলার শিরার চেয়েও নিকটে; যে ডাকে তার ডাকে সাড়া দেন।',
      ayahs: [ThemeAyah(2, 186), ThemeAyah(50, 16), ThemeAyah(57, 4), ThemeAyah(93, 3), ThemeAyah(20, 46)],
      keywords: ['alone', 'lonely', 'loneliness', 'nobody', 'no one', 'isolated', 'ignored', 'একা', 'একাকী', 'নিঃসঙ্গ', 'কেউ নেই', 'কেউ বোঝে না'],
      promptsEn: ['When do I feel most alone?', 'What would I say to Allah if I spoke to Him like a close friend?', 'Who is one person I can reach out to this week?'],
      promptsBn: ['কখন আমি সবচেয়ে একা অনুভব করি?', 'আল্লাহকে কাছের বন্ধুর মতো বললে কী বলতাম?', 'এই সপ্তাহে কার সাথে যোগাযোগ করতে পারি?'],
    ),
    ReflectionTheme(
      id: 'anger',
      nameEn: 'Anger',
      nameBn: 'রাগ',
      arabic: 'كَظْمُ الغَيْظ',
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFB23A3A),
      descEn: 'Those who swallow their anger and pardon people are praised by Allah.',
      descBn: 'যারা রাগ সংবরণ করে এবং মানুষকে ক্ষমা করে, আল্লাহ তাদের প্রশংসা করেছেন।',
      ayahs: [ThemeAyah(3, 134), ThemeAyah(42, 37), ThemeAyah(41, 34), ThemeAyah(7, 199, 200)],
      keywords: ['angry', 'anger', 'rage', 'furious', 'annoyed', 'irritated', 'fight', 'argument', 'রাগ', 'ক্ষোভ', 'বিরক্ত', 'ঝগড়া', 'মেজাজ'],
      promptsEn: ['What triggered my anger, and what was underneath it?', 'What would pardoning look like here, even partly?', 'What will I do next time before I speak?'],
      promptsBn: ['কী আমার রাগ জাগিয়েছিল, আর এর পেছনে আসল অনুভূতি কী ছিল?', 'এখানে ক্ষমা করা, অন্তত আংশিক, কেমন হতে পারে?', 'পরের বার কথা বলার আগে কী করব?'],
    ),
    ReflectionTheme(
      id: 'family',
      nameEn: 'Family & parents',
      nameBn: 'পরিবার ও বাবা-মা',
      arabic: 'الأُسْرَة',
      icon: Icons.family_restroom_rounded,
      color: Color(0xFF8A5A44),
      descEn: 'Mercy to parents, tranquility between spouses, and children as the coolness of our eyes.',
      descBn: 'বাবা-মায়ের প্রতি দয়া, দাম্পত্যে প্রশান্তি, আর সন্তান চোখের শীতলতা।',
      ayahs: [ThemeAyah(17, 23, 24), ThemeAyah(31, 14), ThemeAyah(30, 21), ThemeAyah(25, 74), ThemeAyah(46, 15)],
      keywords: ['mother', 'father', 'mom', 'dad', 'parents', 'wife', 'husband', 'spouse', 'marriage', 'children', 'son', 'daughter', 'family', 'মা', 'বাবা', 'আম্মু', 'আব্বু', 'পরিবার', 'স্ত্রী', 'স্বামী', 'বিয়ে', 'সন্তান', 'ছেলে', 'মেয়ে'],
      promptsEn: ['What am I grateful for in my family today?', 'Is there someone at home I need to be gentler with?', 'What dua do I want to make for my family?'],
      promptsBn: ['আজ পরিবারের কোন বিষয়ে আমি কৃতজ্ঞ?', 'ঘরে কারও প্রতি কি আরও কোমল হওয়া দরকার?', 'পরিবারের জন্য কোন দোয়া করতে চাই?'],
    ),
    ReflectionTheme(
      id: 'purpose',
      nameEn: 'Purpose & guidance',
      nameBn: 'জীবনের উদ্দেশ্য',
      arabic: 'الغَايَة',
      icon: Icons.explore_rounded,
      color: Color(0xFF1F7A42),
      descEn: 'We were not created in vain. Life is a test of who is best in deeds.',
      descBn: 'আমাদের অনর্থক সৃষ্টি করা হয়নি। জীবন হলো কে আমলে উত্তম তার পরীক্ষা।',
      ayahs: [ThemeAyah(51, 56), ThemeAyah(67, 2), ThemeAyah(3, 190, 191), ThemeAyah(29, 69), ThemeAyah(1, 6, 7)],
      keywords: ['purpose', 'meaning', 'direction', 'lost', 'why am i', 'goal', 'calm', 'peace', 'উদ্দেশ্য', 'লক্ষ্য', 'দিশা', 'অর্থ', 'শান্তি', 'শান্ত'],
      promptsEn: ['What did I do today that I want to do more of, for Allah?', 'Where am I spending time that does not serve my purpose?', 'What does a good deed this week look like?'],
      promptsBn: ['আজ আল্লাহর জন্য এমন কী করেছি যা আরও বেশি করতে চাই?', 'কোথায় সময় দিচ্ছি যা আমার উদ্দেশ্যের সাথে যায় না?', 'এই সপ্তাহে একটি ভালো কাজ কেমন হতে পারে?'],
    ),
    ReflectionTheme(
      id: 'hereafter',
      nameEn: 'Death & the hereafter',
      nameBn: 'মৃত্যু ও আখিরাত',
      arabic: 'الآخِرَة',
      icon: Icons.nights_stay_rounded,
      color: Color(0xFF37474F),
      descEn: 'Every soul will taste death; the home of the hereafter is the true life.',
      descBn: 'প্রত্যেক প্রাণ মৃত্যুর স্বাদ গ্রহণ করবে; আখিরাতের ঘরই প্রকৃত জীবন।',
      ayahs: [ThemeAyah(3, 185), ThemeAyah(29, 64), ThemeAyah(2, 156), ThemeAyah(89, 27, 30)],
      keywords: ['death', 'died', 'passed away', 'grave', 'funeral', 'akhirah', 'hereafter', 'janazah', 'মৃত্যু', 'মারা', 'ইন্তেকাল', 'কবর', 'জানাজা', 'আখিরাত'],
      promptsEn: ['If today were my last, what would I want to have done?', 'Who do I want to remember in my duas?', 'What am I holding onto in this world too tightly?'],
      promptsBn: ['আজ যদি শেষ দিন হতো, কী করে রাখতে চাইতাম?', 'দোয়ায় কাকে স্মরণ করতে চাই?', 'দুনিয়ার কোন জিনিস আমি খুব শক্ত করে আঁকড়ে আছি?'],
    ),
    ReflectionTheme(
      id: 'illness',
      nameEn: 'Illness & healing',
      nameBn: 'অসুস্থতা ও শিফা',
      arabic: 'الشِّفَاء',
      icon: Icons.healing_rounded,
      color: Color(0xFF26838F),
      descEn: 'When I am ill, it is He who cures me. The Quran is healing for what is in the hearts.',
      descBn: 'আমি অসুস্থ হলে তিনিই আরোগ্য দেন। কুরআন অন্তরের রোগের শিফা।',
      ayahs: [ThemeAyah(26, 80), ThemeAyah(21, 83, 84), ThemeAyah(17, 82), ThemeAyah(10, 57)],
      keywords: ['sick', 'ill', 'illness', 'pain', 'hospital', 'disease', 'doctor', 'surgery', 'fever', 'অসুস্থ', 'অসুখ', 'রোগ', 'হাসপাতাল', 'ব্যথা', 'জ্বর', 'ডাক্তার'],
      promptsEn: ['How is my body, and how is my heart?', 'What has this illness taught me to value?', 'Who can I ask to make dua for me?'],
      promptsBn: ['আমার শরীর কেমন আছে, আর মন কেমন আছে?', 'এই অসুস্থতা আমাকে কী মূল্য দিতে শেখাল?', 'কাকে আমার জন্য দোয়া করতে বলতে পারি?'],
      duaCategory: 'hardship',
    ),
    ReflectionTheme(
      id: 'fear',
      nameEn: 'Fear',
      nameBn: 'ভয়',
      arabic: 'الأَمَان',
      icon: Icons.shield_rounded,
      color: Color(0xFF455A9C),
      descEn: '"Do not fear; I am with you, I hear and I see." No fear for the friends of Allah.',
      descBn: '"ভয় পেয়ো না, আমি তোমাদের সাথে আছি, আমি শুনি ও দেখি।" আল্লাহর বন্ধুদের কোনো ভয় নেই।',
      ayahs: [ThemeAyah(20, 46), ThemeAyah(9, 40), ThemeAyah(3, 173), ThemeAyah(10, 62), ThemeAyah(41, 30), ThemeAyah(2, 38)],
      keywords: ['afraid', 'scared', 'fear', 'terrified', 'unsafe', 'threat', 'ভয়', 'ভীত', 'আতঙ্ক', 'নিরাপত্তা'],
      promptsEn: ['What am I afraid of, exactly?', 'What would I do if I trusted that Allah is with me in this?', 'Which ayah or dua will I hold on to?'],
      promptsBn: ['আমি ঠিক কীসের ভয় পাচ্ছি?', 'আল্লাহ এই বিষয়ে আমার সাথে আছেন, এই বিশ্বাস থাকলে কী করতাম?', 'কোন আয়াত বা দোয়া আঁকড়ে ধরব?'],
      duaCategory: 'hardship',
    ),
  ];

  static ReflectionTheme? byId(String? id) {
    for (final t in all) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Themes whose keywords appear in [text], best match first. Runs on the
  /// phone; nothing is sent anywhere.
  static List<ReflectionTheme> suggest(String text, {int limit = 2}) {
    final lower = text.toLowerCase();
    if (lower.trim().length < 3) return const [];
    final scores = <ReflectionTheme, int>{};
    for (final t in all) {
      var score = 0;
      for (final k in t.keywords) {
        if (_matches(lower, k)) score += k.length > 4 ? 2 : 1;
      }
      if (score > 0) scores[t] = score;
    }
    final sorted = scores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => e.key).toList();
  }

  static final _patterns = <String, RegExp>{};

  /// Keyword must start a word ("ill" must not hit "will"). Short English
  /// words ("sin" vs "since") and tiny Bangla ones ("মা") must be the whole
  /// word; longer Bangla keywords still match inflected forms like "রাগে".
  static bool _matches(String text, String keyword) {
    final re = _patterns.putIfAbsent(keyword, () {
      final ascii = keyword.codeUnits.every((c) => c < 128);
      final whole = keyword.runes.length <= (ascii ? 3 : 2);
      final end = whole ? r'(?![\p{L}\p{M}])' : '';
      return RegExp('(?<![\\p{L}\\p{M}])${RegExp.escape(keyword)}$end', unicode: true);
    });
    return re.hasMatch(text);
  }

  /// Themes matching a search word by name or keyword.
  static List<ReflectionTheme> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.length < 2) return const [];
    return all
        .where((t) =>
            t.nameEn.toLowerCase().contains(q) ||
            t.nameBn.contains(q) ||
            t.keywords.any((k) => (q.length >= 3 && k.startsWith(q)) || _matches(q, k)))
        .toList();
  }

  static String promptOfDay(DateTime date, bool bangla) {
    final prompts = [for (final t in all) ...t.prompts(bangla)];
    final day = date.difference(DateTime(date.year)).inDays;
    return prompts[day % prompts.length];
  }
}
