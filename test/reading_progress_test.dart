import 'package:al_noor_app/core/quran/reading_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final day = DateTime(2026, 10, 13, 9);

  test('counts an ayah once', () {
    final p = ReadingProgress();
    expect(p.mark(2, 1, day), isTrue);
    expect(p.mark(2, 1, day), isFalse);
    expect(p.totalRead, 1);
    expect(p.today(day), 1);
    expect(p.readInSurah(2), 1);
  });

  test('streak counts back from yesterday when today is empty', () {
    final p = ReadingProgress(days: {
      '2026-10-10': 3,
      '2026-10-11': 5,
      '2026-10-12': 1,
    });
    expect(p.streak(day), 3);
    p.mark(1, 1, day);
    expect(p.streak(day), 4);
  });

  test('a missed day breaks the streak', () {
    final p = ReadingProgress(days: {'2026-10-10': 3, '2026-10-12': 2});
    expect(p.streak(day), 1);
  });
}
