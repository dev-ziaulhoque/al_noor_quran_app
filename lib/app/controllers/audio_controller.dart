// lib/app/controllers/audio_controller.dart
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class AudioController extends GetxController {
  late AudioPlayer _player;

  final RxBool isPlaying = false.obs;
  final RxBool isLoading = false.obs;
  final RxDouble progress = 0.0.obs;
  final RxString currentDuration = '0:00'.obs;
  final RxString totalDuration = '0:00'.obs;
  final RxString error = ''.obs;

  // Selected reciter — always HTTPS URLs
  static const String reciterBase =
      'https://everyayah.com/data/Abdul_Basit_Murattal_64kbps';

  @override
  void onInit() {
    super.onInit();
    _player = AudioPlayer();

    _player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      isLoading.value = state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;
    });

    _player.positionStream.listen((pos) {
      final dur = _player.duration;
      if (dur != null && dur.inMilliseconds > 0) {
        progress.value = pos.inMilliseconds / dur.inMilliseconds;
      }
      currentDuration.value = _formatDuration(pos);
    });

    _player.durationStream.listen((dur) {
      if (dur != null) totalDuration.value = _formatDuration(dur);
    });

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        isPlaying.value = false;
        progress.value = 0;
      }
    });
  }

  /// Build HTTPS audio URL for a surah+ayah
  /// Format: https://everyayah.com/data/{reciter}/{surahPadded}{ayahPadded}.mp3
  String _buildUrl(int surahNumber, int ayahNumber) {
    final s = surahNumber.toString().padLeft(3, '0');
    final a = ayahNumber.toString().padLeft(3, '0');
    return '$reciterBase/$s$a.mp3';
  }

  Future<void> playAyah(int surahNumber, int ayahNumber) async {
    try {
      error.value = '';
      isLoading.value = true;
      final url = _buildUrl(surahNumber, ayahNumber);

      // Ensure HTTPS — never allow HTTP
      assert(url.startsWith('https://'), 'Audio URL must be HTTPS: $url');

      await _player.stop();
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      error.value = 'Could not load audio. Check connection.';
      isLoading.value = false;
    }
  }

  Future<void> playSurah(int surahNumber) async {
    // Play from ayah 1 — everyayah.com has full surah files too
    await playAyah(surahNumber, 1);
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seekTo(double value) async {
    final dur = _player.duration;
    if (dur != null) {
      await _player.seek(Duration(milliseconds: (dur.inMilliseconds * value).round()));
    }
  }

  Future<void> stop() async {
    await _player.stop();
    progress.value = 0;
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }
}