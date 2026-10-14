import 'package:dio/dio.dart';

import '../../core/quran/quran_catalog.dart';
import 'quran_offline_store.dart';

class WordGloss {
  final String arabic;
  final String meaning;

  const WordGloss({required this.arabic, required this.meaning});
}

class AyahStudy {
  final List<WordGloss> words;
  final String? explanation;
  final String? explanationSource;
  final String? shaneNuzul;

  const AyahStudy({
    required this.words,
    this.explanation,
    this.explanationSource,
    this.shaneNuzul,
  });
}

class QuranStudyService {
  final QuranOfflineStore store;

  QuranStudyService(this.store);

  final Dio _quran = Dio(BaseOptions(
    baseUrl: 'https://api.quran.com/api/v4',
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 20),
  ));

  final Dio _tafsir = Dio(BaseOptions(
    baseUrl: 'https://cdn.jsdelivr.net/gh/spa5k/tafsir_api@main/tafsir',
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 90),
  ));

  final Map<String, AyahStudy> _cache = {};
  final Map<String, Map<String, dynamic>> _tafsirFiles = {};
  int? _asbabSurahNumber;
  List<dynamic>? _asbabAyahs;

  Future<AyahStudy> load({
    required int surah,
    required int ayah,
    required String language,
    required String tafsirId,
  }) async {
    final key = '$language:$tafsirId:$surah:$ayah';
    final cached = _cache[key];
    if (cached != null) return cached;

    final tafsir = QuranCatalog.tafsirById(tafsirId);
    final wordsFuture = _words(surah, ayah, language);
    final asbabFuture = _asbab(surah, ayah);
    final explanationFuture = tafsir == null ? Future<String?>.value(null) : explanation(tafsir.id, surah, ayah);

    final words = await wordsFuture;
    final asbab = await asbabFuture;
    final text = await explanationFuture;

    final study = AyahStudy(
      words: words,
      explanation: text,
      explanationSource: text == null ? null : '${tafsir!.name} · ${tafsir.author}',
      shaneNuzul: asbab,
    );
    _cache[key] = study;
    return study;
  }

  /// Downloaded surah file first, then the single ayah from the network.
  Future<String?> explanation(String slug, int surah, int ayah) async {
    final fileKey = '$slug/$surah';
    var file = _tafsirFiles[fileKey];
    if (file == null) {
      final saved = await store.readJson(QuranOfflineStore.tafsirPath(slug, surah));
      if (saved is Map) {
        file = Map<String, dynamic>.from(saved);
        _tafsirFiles[fileKey] = file;
      }
    }
    if (file != null) {
      final text = (file['$ayah'] ?? '').toString().trim();
      return text.isEmpty ? null : text;
    }
    try {
      final response = await _tafsir.get('/$slug/$surah/$ayah.json');
      final text = (response.data['text'] ?? '').toString().trim();
      return text.isEmpty ? null : text;
    } on DioException {
      return null;
    }
  }

  Future<void> downloadTafsirSurah(String slug, int surah, {CancelToken? cancel}) async {
    final response = await _tafsir.get('/$slug/$surah.json', cancelToken: cancel);
    final list = response.data is List ? response.data as List : (response.data['ayahs'] as List? ?? []);
    final map = <String, String>{};
    for (final item in list) {
      final ayah = item['ayah'];
      final text = (item['text'] ?? '').toString();
      if (ayah != null && text.trim().isNotEmpty) map['$ayah'] = text;
    }
    if (map.isEmpty) throw 'Empty tafsir file for surah $surah';
    await store.writeJson(QuranOfflineStore.tafsirPath(slug, surah), map);
    _tafsirFiles['$slug/$surah'] = map;
  }

  Future<List<WordGloss>> _words(int surah, int ayah, String language) async {
    try {
      final response = await _quran.get(
        '/verses/by_key/$surah:$ayah',
        queryParameters: {
          'words': true,
          'word_fields': 'text_uthmani',
          'language': language,
        },
      );
      final words = (response.data['verse']['words'] as List?) ?? [];
      return words
          .where((word) => word['char_type_name'] == 'word')
          .map((word) => WordGloss(
                arabic: (word['text_uthmani'] ?? word['text'] ?? '').toString(),
                meaning: (word['translation']?['text'] ?? '').toString(),
              ))
          .where((word) => word.arabic.isNotEmpty)
          .toList();
    } on DioException {
      return [];
    }
  }

  Future<String?> _asbab(int surah, int ayah) async {
    try {
      if (_asbabSurahNumber != surah || _asbabAyahs == null) {
        final response = await _tafsir.get('/en-asbab-al-nuzul-by-al-wahidi/$surah.json');
        final data = response.data;
        _asbabAyahs = data is List ? data : ((data['ayahs'] as List?) ?? []);
        _asbabSurahNumber = surah;
      }
      // This file also holds passages from another tafsir. Al-Wahidi's
      // entries quote the ayah with its reference, e.g. "[2:102]".
      final marker = RegExp('\\[$surah:\\d+(-\\d+)?\\]');
      for (final item in _asbabAyahs!) {
        if (item['ayah'] == ayah) {
          final text = (item['text'] ?? '').toString().trim();
          if (text.isNotEmpty && marker.hasMatch(text)) return text;
        }
      }
      return null;
    } on DioException {
      return null;
    }
  }
}
