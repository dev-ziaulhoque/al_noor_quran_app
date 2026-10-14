// lib/data/services/quran_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import '../../core/quran/quran_catalog.dart';
import '../models/models.dart';
import 'quran_offline_store.dart';
import 'storage_service.dart';

typedef DownloadProgress = void Function(double fraction);

class QuranService {
  /// Uthmani script published by Tanzil, served by AlQuran Cloud (`quran-uthmani`).
  static const String arabicTextSource = 'Tanzil Uthmani via AlQuran Cloud';
  static const String arabicEdition = 'quran-uthmani';

  final Dio _dio;
  final Dio _files = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 60),
  ));
  final QuranOfflineStore store;

  QuranService({QuranOfflineStore? store})
      : store = store ?? QuranOfflineStore(),
        _dio = Dio(
          BaseOptions(
            baseUrl: 'https://api.alquran.cloud/v1',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 60),
          ),
        ) {
    if (Get.isRegistered<StorageService>()) Get.find<StorageService>().purgeLegacyQuranCache();
  }

  /// Editions shipped in `assets/quran` (built by `tool/bundle_quran.dart`)
  /// so the Quran opens on first launch without internet.
  static const bundledEditions = {arabicEdition, 'en.sahih', 'bn.bengali'};
  final _seeding = <String, Future<void>>{};

  static Future<dynamic> _readAsset(String name) async {
    final data = await rootBundle.load('assets/quran/$name.json.gz');
    final bytes = gzip.decode(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    return jsonDecode(utf8.decode(bytes));
  }

  /// Copies a bundled edition into the offline store once.
  Future<void> _seedEdition(String edition) {
    if (!bundledEditions.contains(edition)) return Future.value();
    return _seeding.putIfAbsent(edition, () async {
      try {
        final surahs = await _readAsset(edition) as List;
        for (final raw in surahs) {
          final s = Map<String, dynamic>.from(raw as Map);
          final number = s['number'] as int;
          final path = QuranOfflineStore.textPath(edition, number);
          if (await store.readJson(path) is List) continue;
          if (edition == arabicEdition) {
            final ayahs = _parseArabic(number, {...s, 'numberOfAyahs': (s['ayahs'] as List).length});
            await store.writeJson(path, ayahs.map((a) => a.toJson()).toList());
          } else {
            await store.writeJson(path, _parseTranslation(s));
          }
        }
      } catch (_) {
        _seeding.remove(edition);
      }
    });
  }

  /// Called at startup so the reader is instant on first open.
  Future<void> warmUp(String translationEdition) async {
    await _seedEdition(arabicEdition);
    await _seedEdition(translationEdition);
  }

  Future<List<SurahModel>> fetchSurahList() async {
    final cached = await store.readJson('surahs.json');
    if (cached is List && cached.length == 114) {
      return cached.map((e) => SurahModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    }
    try {
      final bundled = await _readAsset('surahs') as List;
      if (bundled.length == 114) {
        await store.writeJson('surahs.json', bundled);
        return bundled.map((e) => SurahModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      }
    } catch (_) {}
    try {
      final response = await _dio.get('/surah');
      final List data = response.data['data'] as List;
      await store.writeJson('surahs.json', data);
      return data.map((e) => SurahModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Arabic is Tanzil's Uthmani text. Arabic and translation are saved per
  /// surah, so switching reciter or translation only fetches what is missing.
  Future<List<AyahModel>> fetchSurahAyahs(
    int surahNumber, {
    String reciter = QuranCatalog.defaultReciter,
    String translationEdition = QuranCatalog.defaultTranslation,
  }) async {
    var arabic = await _readArabic(surahNumber);
    var translation = await _readTranslation(translationEdition, surahNumber);
    if (arabic == null) {
      await _seedEdition(arabicEdition);
      arabic = await _readArabic(surahNumber);
    }
    if (translation == null) {
      await _seedEdition(translationEdition);
      translation = await _readTranslation(translationEdition, surahNumber);
    }

    if (arabic == null || translation == null) {
      final editions = [if (arabic == null) arabicEdition, if (translation == null) translationEdition];
      try {
        final response = await _dio.get('/surah/$surahNumber/editions/${editions.join(',')}');
        final data = (response.data['data'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
        for (final edition in data) {
          final id = edition['edition']?['identifier'];
          if (id == arabicEdition) {
            arabic = _parseArabic(surahNumber, edition);
            await store.writeJson(QuranOfflineStore.textPath(arabicEdition, surahNumber), arabic.map((a) => a.toJson()).toList());
          } else if (id == translationEdition) {
            translation = _parseTranslation(edition);
          }
        }
      } on DioException catch (e) {
        throw _handleError(e);
      }
      if (arabic == null) throw 'The Quran text source did not match Tanzil Uthmani. Please try again.';
      if (translation == null || translation.length != arabic.length) {
        throw 'This surah loaded incompletely. Please try again.';
      }
      await store.writeJson(QuranOfflineStore.textPath(translationEdition, surahNumber), translation);
    }

    final reciterOption = QuranCatalog.reciterById(reciter);
    final result = <AyahModel>[];
    for (var i = 0; i < arabic.length; i++) {
      final a = arabic[i];
      final local = await store.audioFile(reciterOption.id, surahNumber, a.number);
      result.add(AyahModel(
        number: a.number,
        arabic: a.text,
        translation: translation![i],
        surahNumber: surahNumber,
        globalNumber: a.global,
        audio: local.existsSync() ? local.path : reciterOption.audioUrl(a.global),
      ));
    }
    return result;
  }

  Future<List<ArabicAyah>?> _readArabic(int surah) async {
    final raw = await store.readJson(QuranOfflineStore.textPath(arabicEdition, surah));
    if (raw is! List || raw.isEmpty) return null;
    return raw.map((e) => ArabicAyah.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<List<String>?> _readTranslation(String edition, int surah) async {
    final raw = await store.readJson(QuranOfflineStore.textPath(edition, surah));
    if (raw is! List || raw.isEmpty) return null;
    return raw.map((e) => e.toString()).toList();
  }

  List<ArabicAyah> _parseArabic(int surahNumber, Map<String, dynamic> edition) {
    final expected = edition['numberOfAyahs'] as int?;
    final List ayahs = edition['ayahs'] as List;
    if (expected != null && expected != ayahs.length) {
      throw 'This surah loaded incompletely. Please try again.';
    }
    return [
      for (var i = 0; i < ayahs.length; i++)
        ArabicAyah(
          number: ayahs[i]['numberInSurah'] as int,
          global: ayahs[i]['number'] as int,
          text: _cleanArabic(surahNumber, i, ayahs[i]['text'] as String),
        ),
    ];
  }

  List<String> _parseTranslation(Map<String, dynamic> edition) =>
      (edition['ayahs'] as List).map((a) => (a['text'] ?? '').toString()).toList();

  static String _cleanArabic(int surah, int index, String text) {
    final clean = text.replaceAll('\uFEFF', '').trim();
    return index == 0 ? stripLeadingBismillah(surah, clean) : clean;
  }

  // ─── Downloads ───

  /// Whole Quran in one request per edition, written as per-surah files.
  Future<void> downloadEdition(String edition, {DownloadProgress? onProgress, CancelToken? cancel}) async {
    try {
      final response = await _dio.get(
        '/quran/$edition',
        cancelToken: cancel,
        onReceiveProgress: (received, total) {
          if (total > 0) onProgress?.call(0.8 * received / total);
        },
      );
      final surahs = (response.data['data']['surahs'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      if (surahs.length != 114) throw 'The download was incomplete. Please try again.';
      for (var i = 0; i < surahs.length; i++) {
        final s = surahs[i];
        final number = s['number'] as int;
        if (edition == arabicEdition) {
          final ayahs = _parseArabic(number, {...s, 'numberOfAyahs': (s['ayahs'] as List).length});
          await store.writeJson(QuranOfflineStore.textPath(edition, number), ayahs.map((a) => a.toJson()).toList());
        } else {
          await store.writeJson(QuranOfflineStore.textPath(edition, number), _parseTranslation(s));
        }
        onProgress?.call(0.8 + 0.2 * (i + 1) / surahs.length);
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) rethrow;
      throw _handleError(e);
    }
  }

  /// Recitation of one surah, one file per ayah.
  Future<void> downloadSurahAudio(
    int surah, {
    required String reciter,
    DownloadProgress? onProgress,
    CancelToken? cancel,
  }) async {
    var arabic = await _readArabic(surah);
    if (arabic == null) {
      await fetchSurahAyahs(surah, reciter: reciter);
      arabic = await _readArabic(surah);
    }
    if (arabic == null) throw 'Could not load this surah.';
    final option = QuranCatalog.reciterById(reciter);
    for (var i = 0; i < arabic.length; i++) {
      final a = arabic[i];
      final file = await store.audioFile(option.id, surah, a.number);
      if (!file.existsSync()) {
        file.parent.createSync(recursive: true);
        final tmp = '${file.path}.part';
        try {
          await _files.download(option.audioUrl(a.global), tmp, cancelToken: cancel);
          await File(tmp).rename(file.path);
        } on DioException catch (e) {
          final part = File(tmp);
          if (part.existsSync()) part.deleteSync();
          if (CancelToken.isCancel(e)) rethrow;
          throw _handleError(e);
        }
      }
      onProgress?.call((i + 1) / arabic.length);
    }
  }

  /// Tanzil puts the Bismillah inside ayah 1 of every surah except 1 and 9.
  /// It is not part of that ayah's numbering, so the reader shows it as a header.
  static String stripLeadingBismillah(int surahNumber, String text) {
    if (surahNumber == 1 || surahNumber == 9) return text;
    final words = text.split(RegExp(r'\s+'));
    if (words.length <= 4) return text;
    final head = words.take(4).map(_baseLetters).join(' ');
    if (head != 'بسم الله الرحمن الرحيم') return text;
    return words.skip(4).join(' ');
  }

  static String _baseLetters(String word) {
    final out = StringBuffer();
    for (final r in word.runes) {
      final isMark = (r >= 0x064B && r <= 0x065F) || r == 0x0670 || (r >= 0x06D6 && r <= 0x06ED) || r == 0x0640;
      if (isMark) continue;
      out.writeCharCode(r == 0x0671 ? 0x0627 : r);
    }
    return out.toString();
  }

  String _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionError) return 'No internet connection.'.tr;
    return 'Failed to load data. Please check internet and try again.'.tr;
  }
}

class ArabicAyah {
  final int number;
  final int global;
  final String text;

  const ArabicAyah({required this.number, required this.global, required this.text});

  Map<String, dynamic> toJson() => {'n': number, 'g': global, 't': text};

  factory ArabicAyah.fromJson(Map<String, dynamic> json) =>
      ArabicAyah(number: json['n'] as int, global: json['g'] as int, text: json['t'] as String);
}
