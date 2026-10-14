import 'package:get/get.dart';
import '../../data/content/reflection_themes.dart';
import '../../data/models/models.dart';
import '../../data/services/quran_service.dart';
import '../../data/services/storage_service.dart';
import 'quran_controller.dart';
import 'settings_controller.dart';

class ReflectionNote {
  final String id;
  final String text;
  final String? theme;
  final String? mood;
  final String reference;
  final int? surah;
  final int? ayah;
  final DateTime createdAt;

  const ReflectionNote({
    required this.id,
    required this.text,
    required this.createdAt,
    this.theme,
    this.mood,
    this.reference = '',
    this.surah,
    this.ayah,
  });

  factory ReflectionNote.fromJson(Map<String, dynamic> j) => ReflectionNote(
        id: j['id']?.toString() ?? '',
        text: j['text']?.toString() ?? '',
        theme: j['theme'] as String?,
        mood: j['mood'] as String?,
        reference: j['reference']?.toString() ?? '',
        surah: j['surah'] as int?,
        ayah: j['ayah'] as int?,
        createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'theme': theme,
        'mood': mood,
        'reference': reference,
        'surah': surah,
        'ayah': ayah,
        'createdAt': createdAt.toIso8601String(),
      };
}

class ReflectionInsights {
  final int total;
  final int last7;
  final int streak;
  final List<MapEntry<ReflectionTheme, int>> topThemes;
  final Map<String, int> moods14;

  const ReflectionInsights(this.total, this.last7, this.streak, this.topThemes, this.moods14);
}

/// Private reflections and theme collections. Everything is stored on the
/// phone; theme suggestions are keyword matches, not a cloud model.
class ReflectionController extends GetxController {
  final _storage = Get.find<StorageService>();

  final notes = <ReflectionNote>[].obs;
  final themeSaves = <String, List<String>>{}.obs;

  final _ayahCache = <String, Future<List<AyahModel>>>{};

  @override
  void onInit() {
    super.onInit();
    notes.value = _storage.getJournal().map(ReflectionNote.fromJson).toList();
    themeSaves.value = _storage.getThemeSaves();
  }

  void _persist() => _storage.saveJournal(notes.map((n) => n.toJson()).toList());

  void saveNote({
    String? id,
    required String text,
    String? theme,
    String? mood,
    String? reference,
    int? surah,
    int? ayah,
  }) {
    final existing = id == null ? null : notes.firstWhereOrNull((n) => n.id == id);
    final note = ReflectionNote(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
      theme: theme,
      mood: mood,
      reference: reference ?? '',
      surah: surah,
      ayah: ayah,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    if (existing != null) {
      notes[notes.indexOf(existing)] = note;
    } else {
      notes.insert(0, note);
    }
    _persist();
  }

  void deleteNote(String id) {
    notes.removeWhere((n) => n.id == id);
    _persist();
  }

  void restoreNote(ReflectionNote note) {
    notes.add(note);
    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _persist();
  }

  List<ReflectionNote> notesFor(String themeId) => notes.where((n) => n.theme == themeId).toList();

  // ─── Ayahs the user added to a theme ───
  List<ThemeAyah> savedAyahs(String themeId) =>
      (themeSaves[themeId] ?? const []).map(ThemeAyah.parse).whereType<ThemeAyah>().toList();

  bool isSaved(String themeId, int surah, int ayah) =>
      themeSaves[themeId]?.contains(ThemeAyah(surah, ayah).key) ?? false;

  bool isCurated(String themeId, int surah, int ayah) =>
      ReflectionThemes.byId(themeId)?.ayahs.any((a) => a.surah == surah && ayah >= a.from && ayah <= a.to) ??
      false;

  void toggleSaved(String themeId, int surah, int ayah) {
    final key = ThemeAyah(surah, ayah).key;
    final list = [...?themeSaves[themeId]];
    list.contains(key) ? list.remove(key) : list.insert(0, key);
    if (list.isEmpty) {
      themeSaves.remove(themeId);
    } else {
      themeSaves[themeId] = list;
    }
    _storage.saveThemeSaves(Map.of(themeSaves));
  }

  // ─── Ayah text, in the reader's translation ───
  Future<List<AyahModel>> loadAyahs(ThemeAyah ref) async {
    final settings = Get.find<SettingsController>();
    final key = '${ref.surah}|${settings.translationId.value}';
    final future = _ayahCache.putIfAbsent(
      key,
      () => Get.find<QuranService>().fetchSurahAyahs(
        ref.surah,
        reciter: settings.reciterId.value,
        translationEdition: settings.translationId.value,
      ),
    );
    try {
      final all = await future;
      return all.where((a) => a.number >= ref.from && a.number <= ref.to).toList();
    } catch (_) {
      _ayahCache.remove(key);
      rethrow;
    }
  }

  String surahName(int surah) {
    final s = Get.find<QuranController>().surahList.firstWhereOrNull((e) => e.number == surah);
    if (s == null) return '${'Surah'.tr} $surah';
    return s.englishName.isNotEmpty ? s.englishName : s.name;
  }

  String referenceLabel(ThemeAyah ref) => '${surahName(ref.surah)} ${ref.ref}';

  // ─── Insights ───
  ReflectionInsights insights() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = notes.map((n) => DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day)).toSet();

    var streak = 0;
    var day = days.contains(today) ? today : today.subtract(const Duration(days: 1));
    while (days.contains(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }

    final counts = <ReflectionTheme, int>{};
    for (final n in notes) {
      final t = ReflectionThemes.byId(n.theme);
      if (t != null) counts[t] = (counts[t] ?? 0) + 1;
    }
    final top = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    final moods = <String, int>{};
    for (final n in notes.where((n) => today.difference(n.createdAt).inDays < 14 && n.mood != null)) {
      moods[n.mood!] = (moods[n.mood!] ?? 0) + 1;
    }

    return ReflectionInsights(
      notes.length,
      notes.where((n) => today.difference(n.createdAt).inDays < 7).length,
      streak,
      top.take(3).toList(),
      moods,
    );
  }

  String? todayMood() {
    final now = DateTime.now();
    final n = notes.firstWhereOrNull((n) =>
        n.mood != null &&
        n.createdAt.year == now.year &&
        n.createdAt.month == now.month &&
        n.createdAt.day == now.day);
    return n?.mood;
  }
}
