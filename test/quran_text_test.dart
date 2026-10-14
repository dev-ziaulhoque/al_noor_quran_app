import 'package:al_noor_app/data/services/quran_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const bismillah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

  test('removes the Bismillah Tanzil adds to ayah 1', () {
    expect(QuranService.stripLeadingBismillah(2, '$bismillah الٓمٓ'), 'الٓمٓ');
    expect(
      QuranService.stripLeadingBismillah(112, '$bismillah قُلْ هُوَ ٱللَّهُ أَحَدٌ'),
      'قُلْ هُوَ ٱللَّهُ أَحَدٌ',
    );
  });

  test('keeps Al-Fatiha 1:1, which is the Bismillah itself', () {
    expect(QuranService.stripLeadingBismillah(1, bismillah), bismillah);
  });

  test('leaves At-Tawbah and ayahs without a Bismillah untouched', () {
    const tawbah = 'بَرَآءَةٌۭ مِّنَ ٱللَّهِ وَرَسُولِهِۦٓ';
    expect(QuranService.stripLeadingBismillah(9, tawbah), tawbah);
    const ayah = 'ذَٰلِكَ ٱلْكِتَٰبُ لَا رَيْبَ';
    expect(QuranService.stripLeadingBismillah(2, ayah), ayah);
  });

  test('keeps An-Naml 27:30, where the Bismillah is inside the ayah', () {
    const naml = 'إِنَّهُۥ مِن سُلَيْمَٰنَ وَإِنَّهُۥ $bismillah';
    expect(QuranService.stripLeadingBismillah(27, naml), naml);
  });
}
