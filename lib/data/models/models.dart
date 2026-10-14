// lib/data/models/models.dart

class SurahModel {
  final int number;
  final String name;
  final String nameArabic;
  final String meaning;
  final int totalAyah;
  final String revelationType; 
  final String englishName;

  SurahModel({
    required this.number,
    required this.name,
    required this.nameArabic,
    required this.meaning,
    required this.totalAyah,
    required this.revelationType,
    required this.englishName,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      number: json['number'] ?? 0,
      name: json['englishName'] ?? '',
      nameArabic: json['name'] ?? '',
      meaning: json['englishNameTranslation'] ?? '',
      totalAyah: json['numberOfAyahs'] ?? 0,
      revelationType: json['revelationType'] ?? '',
      englishName: json['englishName'] ?? '',
    );
  }

  String get englishNameTranslation => meaning;
  int get numberOfAyahs => totalAyah;
}

class AyahModel {
  final int number;
  final String arabic;
  final String translation;
  final int surahNumber;

  /// Remote URL, or a file path when the recitation is downloaded.
  final String audio;

  /// Position in the whole Quran (1..6236).
  final int globalNumber;

  AyahModel({
    required this.number,
    required this.arabic,
    required this.translation,
    required this.surahNumber,
    required this.audio,
    this.globalNumber = 0,
  });

  bool get audioIsLocal => audio.isNotEmpty && !audio.startsWith('http');

  Map<String, dynamic> toJson() => {
        'number': number,
        'arabic': arabic,
        'translation': translation,
        'surahNumber': surahNumber,
        'audio': audio,
        'globalNumber': globalNumber,
      };

  factory AyahModel.fromJson(Map<String, dynamic> json) => AyahModel(
        number: json['number'] as int,
        arabic: json['arabic'] as String,
        translation: json['translation'] as String? ?? '',
        surahNumber: json['surahNumber'] as int,
        audio: json['audio'] as String? ?? '',
        globalNumber: json['globalNumber'] as int? ?? 0,
      );
}

// ... (BookmarkModel and LastReadModel remain the same)
class BookmarkModel {
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final String arabic;
  final DateTime savedAt;

  BookmarkModel({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.arabic,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'surahNumber': surahNumber,
        'ayahNumber': ayahNumber,
        'surahName': surahName,
        'arabic': arabic,
        'savedAt': savedAt.toIso8601String(),
      };

  factory BookmarkModel.fromJson(Map<String, dynamic> json) => BookmarkModel(
        surahNumber: json['surahNumber'],
        ayahNumber: json['ayahNumber'],
        surahName: json['surahName'],
        arabic: json['arabic'],
        savedAt: DateTime.parse(json['savedAt']),
      );
}

class LastReadModel {
  final int surahNumber;
  final int ayahNumber;
  final String surahName;

  LastReadModel({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
  });

  Map<String, dynamic> toJson() => {
        'surahNumber': surahNumber,
        'ayahNumber': ayahNumber,
        'surahName': surahName,
      };

  factory LastReadModel.fromJson(Map<String, dynamic> json) => LastReadModel(
        surahNumber: json['surahNumber'],
        ayahNumber: json['ayahNumber'],
        surahName: json['surahName'],
      );
}
