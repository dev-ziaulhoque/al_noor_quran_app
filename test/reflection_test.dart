import 'package:flutter_test/flutter_test.dart';
import 'package:al_noor_app/data/content/reflection_themes.dart';

void main() {
  group('ReflectionThemes.suggest', () {
    test('finds rizq from Bangla words', () {
      final s = ReflectionThemes.suggest('চাকরি নেই, টাকার অভাবে খুব চিন্তা হচ্ছে');
      expect(s.map((t) => t.id), contains('rizq'));
    });

    test('finds despair and patience from English', () {
      expect(ReflectionThemes.suggest('I feel hopeless and want to give up').first.id, 'despair');
      expect(ReflectionThemes.suggest('So tired of waiting, need patience').first.id, 'patience');
    });

    test('short keywords only match whole words', () {
      expect(ReflectionThemes.suggest('I will read it since morning'), isEmpty);
      expect(ReflectionThemes.suggest('আমার আজকের দিন'), isEmpty);
      expect(ReflectionThemes.suggest('মা অসুস্থ').map((t) => t.id), containsAll(['family', 'illness']));
    });

    test('empty or tiny text gives nothing', () {
      expect(ReflectionThemes.suggest(''), isEmpty);
      expect(ReflectionThemes.suggest('ok'), isEmpty);
    });
  });

  test('search matches names and keywords', () {
    expect(ReflectionThemes.search('patience').map((t) => t.id), contains('patience'));
    expect(ReflectionThemes.search('ধৈর্য').map((t) => t.id), contains('patience'));
    expect(ReflectionThemes.search('Al-Mulk'), isEmpty);
  });

  test('theme data is consistent', () {
    final ids = ReflectionThemes.all.map((t) => t.id).toSet();
    expect(ids.length, ReflectionThemes.all.length);
    for (final t in ReflectionThemes.all) {
      expect(t.ayahs, isNotEmpty, reason: t.id);
      expect(t.promptsEn.length, t.promptsBn.length, reason: t.id);
      for (final a in t.ayahs) {
        expect(a.surah, inInclusiveRange(1, 114));
        expect(a.to, greaterThanOrEqualTo(a.from));
      }
    }
    for (final m in ReflectionThemes.moods) {
      expect(ids, contains(m.themeId));
    }
  });

  test('ThemeAyah key round-trips', () {
    const a = ThemeAyah(94, 5, 6);
    expect(ThemeAyah.parse(a.key)!.ref, '94:5-6');
    expect(ThemeAyah.parse('2:153')!.ref, '2:153');
    expect(ThemeAyah.parse('bad'), isNull);
  });
}
