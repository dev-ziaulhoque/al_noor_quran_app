import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Files under `<documents>/quran`:
///   text/<edition>/<surah>.json   Arabic or translation text
///   tafsir/<slug>/<surah>.json    { "<ayah>": "text" }
///   audio/<reciter>/<surah>/<ayah>.mp3
class QuranOfflineStore {
  Directory? _root;

  Future<Directory> root() async {
    if (_root != null) return _root!;
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/quran');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return _root = dir;
  }

  Future<File> _file(String relative) async => File('${(await root()).path}/$relative');

  Future<dynamic> readJson(String relative) async {
    try {
      final file = await _file(relative);
      if (!file.existsSync()) return null;
      return jsonDecode(await file.readAsString());
    } catch (_) {
      return null;
    }
  }

  /// Writes to a temp file first so a killed app never leaves half a surah.
  Future<void> writeJson(String relative, Object data) async {
    final file = await _file(relative);
    file.parent.createSync(recursive: true);
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonEncode(data), flush: true);
    if (file.existsSync()) file.deleteSync();
    await tmp.rename(file.path);
  }

  static String textPath(String edition, int surah) => 'text/$edition/$surah.json';
  static String tafsirPath(String slug, int surah) => 'tafsir/$slug/$surah.json';

  Future<File> audioFile(String reciter, int surah, int ayah) => _file('audio/$reciter/$surah/$ayah.mp3');

  Future<int> _countFiles(String relativeDir, String suffix) async {
    final dir = Directory('${(await root()).path}/$relativeDir');
    if (!dir.existsSync()) return 0;
    return dir.listSync().where((e) => e is File && e.path.endsWith(suffix)).length;
  }

  Future<int> savedSurahs(String edition) => _countFiles('text/$edition', '.json');
  Future<int> savedTafsirSurahs(String slug) => _countFiles('tafsir/$slug', '.json');
  Future<int> savedAudioAyahs(String reciter, int surah) => _countFiles('audio/$reciter/$surah', '.mp3');

  Future<Map<int, int>> savedAudioBySurah(String reciter) async {
    final dir = Directory('${(await root()).path}/audio/$reciter');
    final result = <int, int>{};
    if (!dir.existsSync()) return result;
    for (final entry in dir.listSync()) {
      if (entry is! Directory) continue;
      final surah = int.tryParse(entry.uri.pathSegments.where((s) => s.isNotEmpty).last);
      if (surah == null) continue;
      result[surah] = entry.listSync().where((f) => f is File && f.path.endsWith('.mp3')).length;
    }
    return result;
  }

  Future<void> deleteAudio(String reciter, int surah) async {
    final dir = Directory('${(await root()).path}/audio/$reciter/$surah');
    if (dir.existsSync()) await dir.delete(recursive: true);
  }

  Future<void> deleteDir(String relativeDir) async {
    final dir = Directory('${(await root()).path}/$relativeDir');
    if (dir.existsSync()) await dir.delete(recursive: true);
  }

  Future<int> sizeBytes() async {
    final dir = await root();
    var total = 0;
    await for (final entry in dir.list(recursive: true, followLinks: false)) {
      if (entry is File) total += await entry.length();
    }
    return total;
  }
}
