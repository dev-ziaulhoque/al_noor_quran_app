import 'package:al_noor_app/core/i18n/app_translations.dart';
import 'package:al_noor_app/presentation/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('empty state renders title, message and action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EmptyState(
          icon: Icons.bookmark_rounded,
          title: 'No bookmarks yet',
          message: 'Tap the bookmark icon.',
          actionLabel: 'Open the Quran',
          onAction: () => tapped = true,
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('No bookmarks yet'), findsOneWidget);
    await tester.tap(find.text('Open the Quran'));
    expect(tapped, isTrue);
  });

  testWidgets('Bangla translations resolve and English falls back to the key', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('bn'),
      fallbackLocale: const Locale('en'),
      home: Builder(builder: (_) => Text('Assalamu Alaikum'.tr, textDirection: TextDirection.ltr)),
    ));
    expect(find.text('আসসালামু আলাইকুম'), findsOneWidget);

    Get.updateLocale(const Locale('en'));
    await tester.pumpAndSettle();
    expect('Assalamu Alaikum'.tr, 'Assalamu Alaikum');
  });
}
