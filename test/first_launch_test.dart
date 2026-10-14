import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:al_noor_app/core/prayer/cities.dart';
import 'package:al_noor_app/core/prayer/prayer_options.dart';
import 'package:al_noor_app/data/services/quran_service.dart';

List<dynamic> _asset(String name) =>
    jsonDecode(utf8.decode(gzip.decode(File('assets/quran/$name.json.gz').readAsBytesSync()))) as List;

void main() {
  group('Cities', () {
    test('has all 64 districts of Bangladesh', () {
      expect(Cities.bangladesh.length, 64);
      expect(Cities.bangladesh.map((c) => c.name).toSet().length, 64);
    });

    test('names a GPS fix from the nearest district', () {
      final m = Cities.nearest(24.90, 91.87);
      expect(m.city.name, 'Sylhet');
      expect(m.km, lessThan(5));
      expect(Cities.countryNear(24.90, 91.87), 'BD');
    });

    test('far from every known city gives no country', () {
      expect(Cities.countryNear(-75, 0), isNull);
    });

    test('country defaults point at real options', () {
      expect(Cities.prayerDefaults('BD'), ('karachi', 'hanafi'));
      expect(Cities.prayerDefaults('SA').$1, 'umm_al_qura');
      for (final c in ['BD', 'SA', 'AE', 'QA', 'KW', 'MY', 'TR', 'EG', 'US', 'GB', null]) {
        final (method, madhab) = Cities.prayerDefaults(c);
        expect(PrayerOptions.methods.any((m) => m.id == method), isTrue, reason: '$c');
        expect(PrayerOptions.madhabs.any((m) => m.id == madhab), isTrue, reason: '$c');
      }
    });
  });

  group('Bundled Quran', () {
    test('surah list is complete', () {
      final surahs = _asset('surahs');
      expect(surahs.length, 114);
      expect(surahs.fold<int>(0, (a, s) => a + (s['numberOfAyahs'] as int)), 6236);
    });

    for (final edition in QuranService.bundledEditions) {
      test('$edition has every ayah', () {
        final surahs = _asset(edition);
        expect(surahs.length, 114);
        final ayahs = surahs.expand((s) => s['ayahs'] as List).toList();
        expect(ayahs.length, 6236);
        expect(ayahs.every((a) => (a['text'] as String).trim().isNotEmpty), isTrue);
      });
    }

    test('Arabic matches Tanzil layout (Bismillah only as header)', () {
      final surahs = _asset('quran-uthmani');
      final baqarah1 = (surahs[1]['ayahs'] as List).first['text'] as String;
      expect(QuranService.stripLeadingBismillah(2, baqarah1).replaceAll('\uFEFF', '').trim().startsWith('الٓمٓ'), isTrue);
      final fatiha1 = (surahs[0]['ayahs'] as List).first['text'] as String;
      expect(QuranService.stripLeadingBismillah(1, fatiha1), fatiha1);
    });
  });
}
