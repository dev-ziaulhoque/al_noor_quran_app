import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/controllers/quran_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/locale_text.dart';
import '../../widgets/app_surfaces.dart';
import '../../widgets/empty_state.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QuranController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Bookmarks'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.card,
        elevation: 0,
      ),
      body: Obx(() {
        final list = ctrl.bookmarks;
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.bookmark_add_rounded,
            title: 'No bookmarks yet'.tr,
            message: 'Tap the bookmark icon on any ayah while reading. It will wait for you here.'.tr,
            actionLabel: 'Open the Quran'.tr,
            actionIcon: Icons.menu_book_rounded,
            onAction: () => Get.offNamed(AppRoutes.quranList),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final b = list[i];
            return Dismissible(
              key: ValueKey('bm_${b.surahNumber}_${b.ayahNumber}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(color: const Color(0xFFC0392B), borderRadius: BorderRadius.circular(18)),
                child: const Icon(Icons.delete_rounded, color: Colors.white),
              ),
              onDismissed: (_) => ctrl.removeBookmarkAt(b.surahNumber, b.ayahNumber),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  ctrl.openAyah(b.surahNumber, b.ayahNumber);
                  Get.toNamed(AppRoutes.quranReader);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: AppSurfaces.card(radius: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bookmark_rounded, size: 18, color: AppColors.gold),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${b.surahName} · ${LocaleText.digits('${b.surahNumber}:${b.ayahNumber}')}',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.emerald),
                            ),
                          ),
                          Text(LocaleText.gregorianShort(b.savedAt), style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        b.arabic,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(fontFamily: 'Amiri', fontSize: 19, height: 1.8, color: AppColors.textDark),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
