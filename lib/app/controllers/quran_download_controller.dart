import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../core/quran/quran_catalog.dart';
import '../../data/services/quran_service.dart';
import '../../data/services/quran_study_service.dart';
import 'settings_controller.dart';

/// Offline downloads. Lives for the whole app so a download keeps going
/// after the user leaves the downloads screen.
class QuranDownloadController extends GetxController {
  final QuranService _service = Get.find();
  final QuranStudyService _study = Get.find();
  SettingsController get _settings => Get.find();

  final RxInt arabicSaved = 0.obs;
  final RxInt translationSaved = 0.obs;
  final RxInt tafsirSaved = 0.obs;
  final RxMap<int, int> audioSaved = <int, int>{}.obs;
  final RxInt storageBytes = 0.obs;

  /// Task id → progress 0..1. Ids: `text`, `tafsir`, `audio:<surah>`.
  final RxMap<String, double> progress = <String, double>{}.obs;
  final RxString lastError = ''.obs;
  final Map<String, CancelToken> _tokens = {};

  @override
  void onInit() {
    super.onInit();
    refreshStatus();
    ever(_settings.translationId, (_) => refreshStatus());
    ever(_settings.tafsirId, (_) => refreshStatus());
    ever(_settings.reciterId, (_) => refreshStatus());
  }

  Future<void> refreshStatus() async {
    final store = _service.store;
    arabicSaved.value = await store.savedSurahs(QuranService.arabicEdition);
    translationSaved.value = await store.savedSurahs(_settings.translationId.value);
    final tafsir = _settings.tafsirOption;
    tafsirSaved.value = tafsir == null ? 0 : await store.savedTafsirSurahs(tafsir.id);
    audioSaved.assignAll(await store.savedAudioBySurah(_settings.reciterId.value));
    storageBytes.value = await store.sizeBytes();
  }

  bool get textComplete => arabicSaved.value >= 114 && translationSaved.value >= 114;
  bool isRunning(String id) => progress.containsKey(id);

  void cancel(String id) => _tokens[id]?.cancel();

  Future<void> _run(String id, Future<void> Function(CancelToken token) task) async {
    if (isRunning(id)) return;
    final token = CancelToken();
    _tokens[id] = token;
    progress[id] = 0;
    lastError.value = '';
    try {
      await task(token);
    } on DioException catch (e) {
      if (!CancelToken.isCancel(e)) lastError.value = 'Download failed. Check the connection and try again.'.tr;
    } catch (e) {
      lastError.value = e.toString();
    } finally {
      progress.remove(id);
      _tokens.remove(id);
      await refreshStatus();
    }
  }

  /// Arabic text and the selected translation for all 114 surahs.
  Future<void> downloadText() => _run('text', (token) async {
        final translation = _settings.translationId.value;
        if (arabicSaved.value < 114) {
          await _service.downloadEdition(
            QuranService.arabicEdition,
            cancel: token,
            onProgress: (p) => progress['text'] = p * 0.5,
          );
        }
        progress['text'] = 0.5;
        await _service.downloadEdition(
          translation,
          cancel: token,
          onProgress: (p) => progress['text'] = 0.5 + p * 0.5,
        );
      });

  Future<void> downloadTafsir() {
    final tafsir = _settings.tafsirOption;
    if (tafsir == null) return Future.value();
    return _run('tafsir', (token) async {
      for (var s = 1; s <= 114; s++) {
        if (token.isCancelled) break;
        await _study.downloadTafsirSurah(tafsir.id, s, cancel: token);
        progress['tafsir'] = s / 114;
        if (s % 10 == 0) tafsirSaved.value = s;
      }
    });
  }

  Future<void> deleteTafsir() async {
    final tafsir = _settings.tafsirOption;
    if (tafsir == null) return;
    await _service.store.deleteDir('tafsir/${tafsir.id}');
    await refreshStatus();
  }

  Future<void> deleteText() async {
    await _service.store.deleteDir('text/${_settings.translationId.value}');
    await refreshStatus();
  }

  Future<void> downloadSurahAudio(int surah) => _run('audio:$surah', (token) async {
        await _service.downloadSurahAudio(
          surah,
          reciter: _settings.reciterId.value,
          cancel: token,
          onProgress: (p) => progress['audio:$surah'] = p,
        );
      });

  Future<void> deleteSurahAudio(int surah) async {
    await _service.store.deleteAudio(_settings.reciterId.value, surah);
    await refreshStatus();
  }

  String get reciterName => QuranCatalog.reciterById(_settings.reciterId.value).name;
}
