// lib/app/controllers/quran_controller.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import '../../core/quran/reading_progress.dart';
import '../../data/models/models.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/quran_service.dart';
import '../../data/services/storage_service.dart';
import 'settings_controller.dart';

class QuranController extends GetxController {
  final QuranService _service = Get.find();
  final StorageService _storage = Get.find();
  final AudioPlayer audioPlayer = AudioPlayer();
  final ScrollController scrollController = ScrollController();

  // Surah List & Search State
  final RxList<SurahModel> surahList = <SurahModel>[].obs;
  final RxList<SurahModel> filteredSurahs = <SurahModel>[].obs;
  final RxList<String> recentSearches = <String>[].obs;
  final RxList<BookmarkModel> bookmarks = <BookmarkModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoadingSurahs = false.obs;
  final RxString error = ''.obs;

  // Ayah Reader State
  final RxList<AyahModel> currentAyahs = <AyahModel>[].obs;
  final RxBool isLoadingAyahs = false.obs;
  final RxString readerError = ''.obs;
  final Rx<SurahModel?> currentSurah = Rx<SurahModel?>(null);
  final Rx<LastReadModel?> lastRead = Rx<LastReadModel?>(null);

  // Audio UI State
  final RxDouble fontSize = 22.0.obs;
  final RxBool isPlaying = false.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final RxInt currentAyahIndex = (-1).obs;

  // Reading progress (stored only on this phone)
  late ReadingProgress _progress;
  final RxInt todayRead = 0.obs;
  final RxInt totalRead = 0.obs;
  final RxInt streakDays = 0.obs;
  final RxInt dailyGoal = 10.obs;
  final RxMap<int, int> readBySurah = <int, int>{}.obs;

  /// Keys for the ayah cards that are currently built, by list index.
  final Map<int, GlobalKey> ayahKeys = {};
  final GlobalKey listKey = GlobalKey();

  GlobalKey keyForAyah(int index) => ayahKeys.putIfAbsent(index, () => GlobalKey());

  @override
  void onInit() {
    super.onInit();
    _initAudioSession();
    loadSurahs();
    recentSearches.value = _storage.getRecentSearches();
    bookmarks.value = _storage.getBookmarks();
    lastRead.value = _storage.getLastRead();
    fontSize.value = _storage.getFontSize();
    _progress = ReadingProgress(read: _storage.getReadAyahs(), days: _storage.getReadDays());
    dailyGoal.value = _storage.getDailyAyahGoal();
    _publishProgress();
    ever(searchQuery, (_) => filterSurahs());

    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      if (state.processingState == ProcessingState.completed) {
        isPlaying.value = false;
        position.value = Duration.zero;
        currentAyahIndex.value = -1;
      }
    });

    audioPlayer.durationStream.listen((d) {
      if (d != null) duration.value = d;
    });

    audioPlayer.positionStream.listen((p) {
      position.value = p;
    });
    
    audioPlayer.currentIndexStream.listen((index) {
      if (index == null) return;
      currentAyahIndex.value = index;
      if (audioPlayer.playing) {
        _scrollToIndex(index);
        final surah = currentSurah.value;
        if (surah != null && index < currentAyahs.length) {
          _markRead(surah.number, [currentAyahs[index].number]);
        }
      }
    });
  }

  void _publishProgress() {
    final now = DateTime.now();
    todayRead.value = _progress.today(now);
    totalRead.value = _progress.totalRead;
    streakDays.value = _progress.streak(now);
    readBySurah.assignAll(_progress.read.map((k, v) => MapEntry(k, v.length)));
  }

  void _markRead(int surah, Iterable<int> ayahs) {
    final now = DateTime.now();
    var changed = false;
    for (final a in ayahs) {
      if (_progress.mark(surah, a, now)) changed = true;
    }
    if (!changed) return;
    _storage.saveReadAyahs(_progress.read);
    _storage.saveReadDays(_progress.days);
    _publishProgress();
  }

  double get quranFraction => _progress.fraction;

  void setDailyGoal(int goal) {
    dailyGoal.value = goal;
    _storage.saveDailyAyahGoal(goal);
  }

  Timer? _trackTimer;

  /// Waits until the reader has stayed still for a moment, so ayahs that only
  /// flash past while scrolling are not counted.
  void scheduleReadTracking() {
    _trackTimer?.cancel();
    _trackTimer = Timer(const Duration(milliseconds: 1500), trackVisibleAyahs);
  }

  /// Marks the ayahs that are fully on screen as read and moves "last read"
  /// to the first of them. Call after scrolling stops.
  void trackVisibleAyahs() {
    final surah = currentSurah.value;
    final listBox = listKey.currentContext?.findRenderObject() as RenderBox?;
    if (surah == null || listBox == null || !listBox.hasSize) return;
    final top = listBox.localToGlobal(Offset.zero).dy;
    final bottom = top + listBox.size.height;

    final visible = <int>[];
    ayahKeys.forEach((index, key) {
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached || !box.hasSize || index >= currentAyahs.length) return;
      final y = box.localToGlobal(Offset.zero).dy;
      final end = y + box.size.height;
      final fullyShown = y >= top - 1 && end <= bottom + 1;
      final tallAndCovering = box.size.height > listBox.size.height && y <= top && end >= bottom;
      if (fullyShown || tallAndCovering) visible.add(index);
    });
    if (visible.isEmpty) return;
    visible.sort();

    _markRead(surah.number, visible.map((i) => currentAyahs[i].number));
    final first = currentAyahs[visible.first].number;
    if (lastRead.value?.surahNumber != surah.number || lastRead.value?.ayahNumber != first) {
      final lr = LastReadModel(surahNumber: surah.number, ayahNumber: first, surahName: surah.name);
      lastRead.value = lr;
      _storage.saveLastRead(lr);
    }
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  void _scrollToIndex(int index, {bool animate = true}) {
    if (!scrollController.hasClients) return;
    final built = ayahKeys[index]?.currentContext;
    if (built != null) {
      Scrollable.ensureVisible(
        built,
        alignment: 0.05,
        duration: animate ? const Duration(milliseconds: 500) : Duration.zero,
        curve: Curves.easeInOut,
      );
      return;
    }
    final position = scrollController.position;
    final count = currentAyahs.length;
    final perItem = count > 0 && position.maxScrollExtent > 0
        ? (position.maxScrollExtent + position.viewportDimension) / count
        : 200.0;
    scrollController.jumpTo((index * perItem).clamp(0.0, position.maxScrollExtent));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = ayahKeys[index]?.currentContext;
      if (ctx != null) Scrollable.ensureVisible(ctx, alignment: 0.05);
    });
  }

  /// Opens the reader at [ayahNumber] once the surah has loaded.
  void scrollToAyah(int ayahNumber) {
    final index = currentAyahs.indexWhere((a) => a.number == ayahNumber);
    if (index <= 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToIndex(index, animate: false);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToIndex(index, animate: false));
    });
  }

  @override
  void onClose() {
    _trackTimer?.cancel();
    audioPlayer.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> loadSurahs() async {
    isLoadingSurahs.value = true;
    error.value = '';
    try {
      final list = await _service.fetchSurahList();
      surahList.value = list;
      filteredSurahs.value = list;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoadingSurahs.value = false;
    }
  }

  List<SurahModel> get searchResults => filteredSurahs;

  void addRecentSearch(String term) {
    if (term.trim().isEmpty) return;
    _storage.saveRecentSearch(term);
    recentSearches.value = _storage.getRecentSearches();
  }

  void clearRecentSearches() {
    _storage.clearRecentSearches();
    recentSearches.clear();
  }

  void filterSurahs() {
    final q = searchQuery.value.toLowerCase().trim();
    if (q.isEmpty) {
      filteredSurahs.value = surahList;
      return;
    }
    filteredSurahs.value = surahList
        .where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.nameArabic.contains(q) ||
            s.meaning.toLowerCase().contains(q) ||
            s.number.toString() == q)
        .toList();
  }

  Future<void> loadSurahAyahs(SurahModel surah, {int? startAyah}) async {
    if (audioPlayer.playing) await audioPlayer.stop();
    currentAyahIndex.value = -1;
    currentSurah.value = surah;
    currentAyahs.clear();
    ayahKeys.clear();
    readerError.value = '';
    isLoadingAyahs.value = true;

    try {
      final settingsCtrl = Get.find<SettingsController>();
      final ayahs = await _service.fetchSurahAyahs(
        surah.number, 
        reciter: settingsCtrl.getReciterId(),
        translationEdition: settingsCtrl.getTranslationEditionId(),
      );
      currentAyahs.value = ayahs;

      final resumeAt = startAyah ??
          (lastRead.value?.surahNumber == surah.number ? lastRead.value!.ayahNumber : 1);
      final lr = LastReadModel(surahNumber: surah.number, ayahNumber: resumeAt, surahName: surah.name);
      lastRead.value = lr;
      _storage.saveLastRead(lr);

      final reciterName = settingsCtrl.reciterOption.name;
      final playlist = ConcatenatingAudioSource(
        children: ayahs
            .map((ayah) => AudioSource.uri(
                  ayah.audioIsLocal ? Uri.file(ayah.audio) : Uri.parse(ayah.audio),
                  tag: MediaItem(
                    id: '${surah.number}:${ayah.number}',
                    album: '${surah.name} · ${surah.nameArabic}',
                    title: '${surah.name} · ${'Ayah'.tr} ${ayah.number}/${surah.totalAyah}',
                    artist: reciterName,
                    displaySubtitle: reciterName,
                    displayDescription: 'Al-Noor · ${'Quran recitation'.tr}',
                  ),
                ))
            .toList(),
      );
      await audioPlayer.setAudioSource(playlist, preload: false);
      if (resumeAt > 1) scrollToAyah(resumeAt);
      scheduleReadTracking();
    } catch (e) {
      readerError.value = e.toString();
      debugPrint("Load Error: $e");
    } finally {
      isLoadingAyahs.value = false;
    }
  }

  Future<void> playAyah(int index) async {
    try {
      if (currentAyahIndex.value == index && audioPlayer.playing) {
        await audioPlayer.pause();
        return;
      }
      await NotificationService.instance.ensurePermission();
      await audioPlayer.seek(Duration.zero, index: index);
      audioPlayer.play();
    } catch (e) {
      debugPrint("Play Error: $e");
    }
  }

  Future<void> togglePlayPause() async {
    if (audioPlayer.playing) {
      await audioPlayer.pause();
    } else {
      await NotificationService.instance.ensurePermission();
      audioPlayer.play();
    }
  }

  Future<void> stopPlayback() async {
    await audioPlayer.stop();
    currentAyahIndex.value = -1;
  }

  void seek(Duration pos) => audioPlayer.seek(pos);
  void skipNext() => audioPlayer.hasNext ? audioPlayer.seekToNext() : null;
  void skipPrevious() => audioPlayer.hasPrevious ? audioPlayer.seekToPrevious() : null;

  void updateFontSize(double size) {
    fontSize.value = size;
    _storage.saveFontSize(size);
  }

  void removeBookmarkAt(int surahNum, int ayahNum) {
    _storage.removeBookmark(surahNum, ayahNum);
    bookmarks.value = _storage.getBookmarks();
  }

  /// Opens the reader at a saved ayah.
  void openAyah(int surahNum, int ayahNum) {
    final surah = surahList.firstWhereOrNull((s) => s.number == surahNum);
    if (surah == null) return;
    loadSurahAyahs(surah, startAyah: ayahNum);
  }

  bool isBookmarked(int surahNum, int ayahNum) {
    return bookmarks.any((b) => b.surahNumber == surahNum && b.ayahNumber == ayahNum);
  }

  void toggleBookmark(AyahModel ayah) {
    if (currentSurah.value == null) return;
    final surahNum = currentSurah.value!.number;
    final isMarked = isBookmarked(surahNum, ayah.number);

    if (isMarked) {
      _storage.removeBookmark(surahNum, ayah.number);
      Get.snackbar('Bookmark removed'.tr, '${'Ayah'.tr} ${ayah.number}',
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));
    } else {
      _storage.saveBookmark(BookmarkModel(
        surahNumber: surahNum,
        ayahNumber: ayah.number,
        surahName: currentSurah.value!.name,
        arabic: ayah.arabic,
        savedAt: DateTime.now(),
      ));
      Get.snackbar('Bookmark saved'.tr, '${'Ayah'.tr} ${ayah.number}',
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));
    }
    bookmarks.value = _storage.getBookmarks();
  }
}
