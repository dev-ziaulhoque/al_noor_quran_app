/// Which ayahs have been read, and how many new ayahs were read each day.
class ReadingProgress {
  static const int totalAyahs = 6236;

  final Map<int, Set<int>> read;
  final Map<String, int> days;

  ReadingProgress({Map<int, Set<int>>? read, Map<String, int>? days})
      : read = read ?? {},
        days = days ?? {};

  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Returns true when the ayah had not been read before.
  bool mark(int surah, int ayah, DateTime now) {
    final set = read.putIfAbsent(surah, () => <int>{});
    if (!set.add(ayah)) return false;
    final key = dateKey(now);
    days[key] = (days[key] ?? 0) + 1;
    return true;
  }

  int get totalRead => read.values.fold(0, (sum, s) => sum + s.length);

  double get fraction => totalRead / totalAyahs;

  int readInSurah(int surah) => read[surah]?.length ?? 0;

  int today(DateTime now) => days[dateKey(now)] ?? 0;

  /// Consecutive days with reading, ending today. If today has no reading yet,
  /// the streak still counts up to yesterday.
  int streak(DateTime now) {
    var day = DateTime(now.year, now.month, now.day);
    if ((days[dateKey(day)] ?? 0) == 0) {
      day = day.subtract(const Duration(days: 1));
    }
    var count = 0;
    while ((days[dateKey(day)] ?? 0) > 0) {
      count++;
      day = day.subtract(const Duration(days: 1));
    }
    return count;
  }
}
