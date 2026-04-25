// lib/app/controllers/quran_controller.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../../data/models/models.dart';
import '../../data/services/quran_service.dart';
import '../../data/services/storage_service.dart';

class QuranController extends GetxController {
  final QuranService _service = Get.find();
  final StorageService _storage = Get.find();
  final AudioPlayer audioPlayer = AudioPlayer();
  final ScrollController scrollController = ScrollController();

  final RxList<SurahModel> surahList = <SurahModel>[].obs;
  final RxList<AyahModel> currentAyahs = <AyahModel>[].obs;
  final RxBool isLoadingSurahs = false.obs;
  final RxBool isLoadingAyahs = false.obs;
  final RxString error = ''.obs;
  final Rx<SurahModel?> currentSurah = Rx<SurahModel?>(null);
  final RxList<SurahModel> filteredSurahs = <SurahModel>[].obs;
  final RxString searchQuery = ''.obs;
  final Rx<LastReadModel?> lastRead = Rx<LastReadModel?>(null);
  final RxList<BookmarkModel> bookmarks = <BookmarkModel>[].obs;
  final RxDouble fontSize = 22.0.obs;

  final RxBool isPlaying = false.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final RxInt currentAyahIndex = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    _initAudioSession();
    loadSurahs();
    lastRead.value = _storage.getLastRead();
    bookmarks.value = _storage.getBookmarks();
    fontSize.value = _storage.getFontSize();
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
      if (index != null) {
        currentAyahIndex.value = index;
        _scrollToIndex(index);
      }
    });
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  void _scrollToIndex(int index) {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        index * 200.0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void onClose() {
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

  Future<void> loadSurahAyahs(SurahModel surah) async {
    if (audioPlayer.playing) await audioPlayer.stop();
    
    currentAyahIndex.value = -1;
    currentSurah.value = surah;
    isLoadingAyahs.value = true;
    error.value = '';

    try {
      final ayahs = await _service.fetchSurahAyahs(surah.number);
      currentAyahs.value = ayahs;
      
      final lr = LastReadModel(
        surahNumber: surah.number,
        ayahNumber: 1,
        surahName: surah.name,
      );
      lastRead.value = lr;
      _storage.saveLastRead(lr);

      final playlist = ConcatenatingAudioSource(
        children: ayahs.map((ayah) => AudioSource.uri(
          Uri.parse(ayah.audio),
        )).toList(),
      );
      
      await audioPlayer.setAudioSource(playlist);
      
      duration.value = Duration.zero;
      position.value = Duration.zero;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoadingAyahs.value = false;
    }
  }

  Future<void> playSurah() async {
    if (currentAyahs.isEmpty) return;
    try {
      audioPlayer.play();
    } catch (e) {
      debugPrint("Audio Play Error: $e");
    }
  }

  Future<void> playAyah(int index) async {
    if (currentAyahs.isEmpty) return;
    try {
      await audioPlayer.seek(Duration.zero, index: index);
      audioPlayer.play();
    } catch (e) {
      debugPrint("Audio Ayah Play Error: $e");
    }
  }

  Future<void> togglePlayPause() async {
    if (audioPlayer.playing) {
      await audioPlayer.pause();
    } else {
      if (audioPlayer.audioSource == null) {
        if (currentSurah.value != null) await loadSurahAyahs(currentSurah.value!);
        audioPlayer.play();
      } else {
        audioPlayer.play();
      }
    }
  }

  void seek(Duration pos) {
    audioPlayer.seek(pos);
  }

  void skipNext() {
    if (audioPlayer.hasNext) audioPlayer.seekToNext();
  }

  void skipPrevious() {
    if (audioPlayer.hasPrevious) audioPlayer.seekToPrevious();
  }

  void filterSurahs() {
    final q = searchQuery.value.toLowerCase();
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

  void toggleBookmark(AyahModel ayah) {
    final isMarked = _storage.isBookmarked(currentSurah.value!.number, ayah.number);
    if (isMarked) {
      _storage.removeBookmark(currentSurah.value!.number, ayah.number);
    } else {
      _storage.saveBookmark(BookmarkModel(
        surahNumber: currentSurah.value!.number,
        ayahNumber: ayah.number,
        surahName: currentSurah.value!.name,
        arabic: ayah.arabic,
        savedAt: DateTime.now(),
      ));
    }
    bookmarks.value = _storage.getBookmarks();
  }

  bool isBookmarked(int surahNum, int ayahNum) {
    return _storage.isBookmarked(surahNum, ayahNum);
  }

  void updateFontSize(double size) {
    fontSize.value = size;
    _storage.saveFontSize(size);
  }
}
