// lib/presentation/screens/search/search_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/controllers/quran_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/locale_text.dart';
import '../../../data/content/reflection_themes.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/reflection_widgets.dart';
import '../quran/quran_reader_screen.dart';

double _dyn(double val) => val;

TextStyle _textStyle({required double fontSize, required Color color, FontWeight? fontWeight}) {
  return TextStyle(fontSize: fontSize, color: Color.fromARGB(color.alpha, color.red, color.green, color.blue), fontWeight: fontWeight);
}

BoxDecoration _boxDecoration({Color? color, BorderRadiusGeometry? borderRadius, BoxShape shape = BoxShape.rectangle}) {
  return BoxDecoration(color: color, borderRadius: borderRadius, shape: shape);
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _textCtrl;

  @override
  void initState() {
    super.initState();
    final ctrl = Get.find<QuranController>();
    _textCtrl = TextEditingController(text: ctrl.searchQuery.value);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _textCtrl.clear();
    Get.find<QuranController>().searchQuery.value = '';
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QuranController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: AppColors.card,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Explore'.tr, style: _textStyle(fontSize: 20.0, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                            const SizedBox(height: 2),
                            Text('Surahs, feelings and topics in one place'.tr,
                                style: _textStyle(fontSize: 12.0, color: AppColors.textMid)),
                          ],
                        ),
                      ),
                      Text('استكشف', style: TextStyle(fontFamily: 'Amiri', fontSize: 20, color: AppColors.gold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: _boxDecoration(color: AppColors.emeraldPale, borderRadius: BorderRadius.circular(10)),
                    child: Obx(() {
                      final txtLight = AppColors.textLight;
                      final searchIconWidget = Icon(Icons.search_rounded, color: txtLight, size: 20);
                      final closeIconWidget = Icon(Icons.close_rounded, size: 18, color: txtLight);
                      return TextField(
                        controller: _textCtrl,
                        onChanged: (val) {
                          ctrl.searchQuery.value = val;
                        },
                        onSubmitted: (val) {
                          ctrl.addRecentSearch(val);
                        },
                        style: TextStyle(fontSize: 14, color: AppColors.textDark),
                        decoration: InputDecoration(
                          hintText: 'Search a surah or a feeling (patience, rizq…)'.tr,
                          hintStyle: _textStyle(color: txtLight, fontSize: 13.0),
                          prefixIcon: searchIconWidget,
                          suffixIcon: ctrl.searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: closeIconWidget,
                                  onPressed: _clearSearch,
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Obx(() {
                  final query = ctrl.searchQuery.value.trim();
                  final txtDark = AppColors.textDark;
                  final txtLight = AppColors.textLight;
                  final primary = AppColors.emerald;

                  if (query.isEmpty) {
                    final listWidgets = <Widget>[
                      const ReflectionDiscover(),
                      const SizedBox(height: 26),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('RECENT SEARCHES'.tr, style: _textStyle(fontSize: 11.0, fontWeight: FontWeight.w600, color: txtLight)),
                          if (ctrl.recentSearches.isNotEmpty)
                            GestureDetector(
                              onTap: ctrl.clearRecentSearches,
                              child: Text('Clear All'.tr, style: _textStyle(fontSize: 11.0, color: primary, fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ctrl.recentSearches.isEmpty
                          ? EmptyState(
                              compact: true,
                              icon: Icons.manage_search_rounded,
                              title: 'Find any surah'.tr,
                              message: 'Your recent searches will appear here. Try a quick topic below.'.tr,
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ctrl.recentSearches.map((s) => _SearchChip(
                                    label: s,
                                    onTap: () {
                                      _textCtrl.text = s;
                                      ctrl.searchQuery.value = s;
                                    },
                                  )).toList(),
                            ),
                      const SizedBox(height: 24),
                      Text('QUICK TOPICS'.tr, style: _textStyle(fontSize: 11.0, fontWeight: FontWeight.w600, color: txtLight)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'Al-Fatiha', 'Yaseen', 'Al-Mulk', 'Ar-Rahman',
                          'Al-Kahf', 'Ayat al-Kursi',
                        ].map((t) => _TopicChip(
                              label: t,
                              onTap: () {
                                _textCtrl.text = t;
                                ctrl.searchQuery.value = t;
                                ctrl.addRecentSearch(t);
                              },
                            )).toList(),
                      ),
                    ];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: listWidgets,
                    );
                  }

                  final results = ctrl.searchResults;
                  final themes = ReflectionThemes.search(query);
                  final themeSection = themes.isEmpty
                      ? const <Widget>[]
                      : <Widget>[
                          Text('FEELINGS & TOPICS'.tr, style: _textStyle(fontSize: 11.0, fontWeight: FontWeight.w600, color: txtLight)),
                          const SizedBox(height: 10),
                          Wrap(spacing: 8, runSpacing: 8, children: themes.map((t) => _ThemeChip(theme: t)).toList()),
                          const SizedBox(height: 20),
                        ];
                  if (results.isEmpty && themes.isNotEmpty) {
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: themeSection);
                  }
                  if (results.isEmpty) {
                    return EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No surah matches "@q"'.trParams({'q': query}),
                      message: 'Try the English or Arabic name, the meaning, or the surah number.'.tr,
                      actionLabel: 'Clear search'.tr,
                      actionIcon: Icons.close_rounded,
                      onAction: _clearSearch,
                      secondaryLabel: 'Browse duas'.tr,
                      onSecondary: () => Get.toNamed(AppRoutes.dua),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...themeSection,
                      Text('${'RESULTS'.tr} (${results.length})', style: _textStyle(fontSize: 11.0, fontWeight: FontWeight.w600, color: txtLight)),
                      const SizedBox(height: 10),
                      ...results.map((s) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: _boxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 16,
                                backgroundColor: primary.withValues(alpha: 0.12),
                                child: Text('${s.number}', style: _textStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: primary)),
                              ),
                              title: Text(s.name, style: _textStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: txtDark)),
                              subtitle: Text('${s.englishNameTranslation} • ${s.numberOfAyahs} ${'Ayahs'.tr}', style: _textStyle(fontSize: 11.0, color: txtLight)),
                              trailing: Text(s.nameArabic, style: TextStyle(fontFamily: 'Amiri', fontSize: 16, color: primary)),
                              onTap: () {
                                ctrl.addRecentSearch(s.name);
                                ctrl.loadSurahAyahs(s);
                                Get.to(() => QuranReaderScreen(surah: s));
                              },
                            ),
                          )),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  _SearchChip({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final txtLight = AppColors.textLight;
    final txtDark = AppColors.textDark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: _boxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 13, color: txtLight),
            const SizedBox(width: 5),
            Text(label, style: _textStyle(fontSize: 12.0, color: txtDark)),
          ],
        ),
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final ReflectionTheme theme;
  const _ThemeChip({required this.theme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.reflectTheme, arguments: {'theme': theme.id}),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: _boxDecoration(color: theme.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(theme.icon, size: 14, color: theme.color),
            const SizedBox(width: 5),
            Text(theme.name(LocaleText.isBangla),
                style: _textStyle(fontSize: 12.0, color: theme.color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  _TopicChip({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pColor = AppColors.emerald;
    final pPale = AppColors.emeraldPale;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: _boxDecoration(color: pPale, borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: _textStyle(fontSize: 12.0, color: pColor, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
