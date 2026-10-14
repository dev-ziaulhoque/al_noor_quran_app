/// Editions the reader can switch between. Translation and reciter ids are
/// AlQuran Cloud edition identifiers; tafsir ids are spa5k/tafsir_api slugs.
class TranslationOption {
  final String id;
  final String language;
  final String languageCode;
  final String translator;

  const TranslationOption(this.id, this.language, this.languageCode, this.translator);

  String get label => '$language · $translator';
}

class ReciterOption {
  final String id;
  final String name;
  final String style;
  final int bitrate;

  const ReciterOption(this.id, this.name, this.style, this.bitrate);

  /// Per-ayah recitation on the Islamic Network CDN, by whole-Quran ayah number.
  String audioUrl(int globalAyah) => 'https://cdn.islamic.network/quran/audio/$bitrate/$id/$globalAyah.mp3';
}

class TafsirOption {
  final String id;
  final String name;
  final String languageCode;
  final String author;

  const TafsirOption(this.id, this.name, this.languageCode, this.author);
}

class QuranCatalog {
  static const String defaultTranslation = 'en.sahih';
  static const String defaultReciter = 'ar.alafasy';
  static const String defaultTafsir = 'bn-tafsir-ahsanul-bayaan';
  static const String noTafsir = 'none';

  static const List<TranslationOption> translations = [
    TranslationOption('en.sahih', 'English', 'en', 'Saheeh International'),
    TranslationOption('en.hilali', 'English', 'en', 'Hilali & Muhsin Khan'),
    TranslationOption('bn.bengali', 'বাংলা', 'bn', 'Muhiuddin Khan'),
    TranslationOption('bn.hoque', 'বাংলা', 'bn', 'Zohurul Hoque'),
    TranslationOption('ur.jalandhry', 'اردو', 'ur', 'Fateh Muhammad Jalandhry'),
    TranslationOption('hi.hindi', 'हिन्दी', 'hi', 'Suhel Farooq Khan & Saifur Rahman Nadwi'),
    TranslationOption('id.indonesian', 'Bahasa Indonesia', 'id', 'Indonesian translation'),
    TranslationOption('ms.basmeih', 'Bahasa Melayu', 'ms', 'Abdullah Muhammad Basmeih'),
    TranslationOption('tr.diyanet', 'Türkçe', 'tr', 'Diyanet İşleri'),
    TranslationOption('fr.hamidullah', 'Français', 'fr', 'Muhammad Hamidullah'),
    TranslationOption('es.cortes', 'Español', 'es', 'Julio Cortes'),
    TranslationOption('de.aburida', 'Deutsch', 'de', 'Abu Rida'),
    TranslationOption('ru.kuliev', 'Русский', 'ru', 'Elmir Kuliev'),
    TranslationOption('zh.jian', '中文', 'zh', 'Ma Jian'),
  ];

  static const List<ReciterOption> reciters = [
    ReciterOption('ar.alafasy', 'Mishary Rashid Alafasy', 'Kuwait', 128),
    ReciterOption('ar.abdulbasitmurattal', 'Abdul Basit Abdus Samad', 'Egypt · Murattal', 192),
    ReciterOption('ar.abdurrahmaansudais', 'Abdurrahmaan As-Sudais', 'Makkah', 192),
    ReciterOption('ar.saoodshuraym', 'Saood Ash-Shuraym', 'Makkah', 64),
    ReciterOption('ar.mahermuaiqly', 'Maher Al Muaiqly', 'Makkah', 128),
    ReciterOption('ar.husary', 'Mahmoud Khalil Al-Husary', 'Egypt · Murattal', 128),
    ReciterOption('ar.minshawi', 'Muhammad Siddiq Al-Minshawi', 'Egypt · Murattal', 128),
    ReciterOption('ar.hudhaify', 'Ali Al-Hudhaify', 'Madinah', 128),
    ReciterOption('ar.shaatree', 'Abu Bakr Ash-Shaatree', 'Saudi Arabia', 128),
    ReciterOption('ar.ahmedajamy', 'Ahmed ibn Ali al-Ajamy', 'Saudi Arabia', 128),
  ];

  static const List<TafsirOption> tafsirs = [
    TafsirOption('bn-tafsir-ahsanul-bayaan', 'Tafsir Ahsanul Bayaan', 'bn', 'Bayaan Foundation'),
    TafsirOption('bn-tafsir-abu-bakr-zakaria', 'Tafsir Abu Bakr Zakaria', 'bn', 'King Fahd Quran Printing Complex'),
    TafsirOption('bn-tafseer-ibn-e-kaseer', 'Tafsir Ibn Kathir (Bangla)', 'bn', 'Tawheed Publication'),
    TafsirOption('bengali-mokhtasar', 'Al-Mukhtasar (Bangla)', 'bn', 'Tafsir Center for Quranic Studies'),
    TafsirOption('en-tafsir-al-mukhtasar', 'Al-Mukhtasar (English)', 'en', 'Tafsir Center for Quranic Studies'),
    TafsirOption('en-tafisr-ibn-kathir', 'Tafsir Ibn Kathir (English)', 'en', 'Hafiz Ibn Kathir'),
  ];

  /// Languages Quran.com has word-by-word meanings for.
  static const Set<String> wordByWordLanguages = {'en', 'bn', 'ur', 'id', 'tr', 'hi'};

  static TranslationOption translationById(String id) =>
      translations.firstWhere((t) => t.id == id, orElse: () => translations.first);

  static ReciterOption reciterById(String id) =>
      reciters.firstWhere((r) => r.id == id, orElse: () => reciters.first);

  static TafsirOption? tafsirById(String id) {
    for (final t in tafsirs) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Older builds stored a language code or a display name.
  static String migrateTranslation(String stored) {
    switch (stored) {
      case 'bn':
        return 'bn.bengali';
      case 'ur':
        return 'ur.jalandhry';
      case 'en':
        return 'en.sahih';
    }
    return translations.any((t) => t.id == stored) ? stored : defaultTranslation;
  }

  static String migrateReciter(String stored) {
    switch (stored) {
      case 'Mishary Rashid Alafasy':
        return 'ar.alafasy';
      case 'Abdul Basit Samad':
        return 'ar.abdulbasitmurattal';
      case 'Abdurrahmaan As-Sudais':
      case 'ar.as-sudais':
        return 'ar.abdurrahmaansudais';
    }
    return reciters.any((r) => r.id == stored) ? stored : defaultReciter;
  }
}
