import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/controllers/reflection_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/locale_text.dart';
import '../../../data/content/reflection_themes.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/reflection_widgets.dart';

/// Reflection hub: mood check-in, theme collections, insights and private
/// notes. Old callers may pass `{surah, ayah, reference}`; the editor opens
/// straight away for them.
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _ctrl = Get.find<ReflectionController>();
  final _search = TextEditingController();
  String _query = '';
  String? _filter;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map && (args['reference'] != null || args['theme'] != null || args['mood'] != null)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => Get.toNamed(AppRoutes.reflectEditor, arguments: args));
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bn = LocaleText.isBangla;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Reflect'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.card,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        onPressed: () => Get.toNamed(AppRoutes.reflectEditor),
        icon: const Icon(Icons.edit_note_rounded),
        label: Text('Write'.tr),
      ),
      body: Obx(() {
        final notes = _ctrl.notes.toList();
        final insights = _ctrl.insights();
        final usedThemes = ReflectionThemes.all.where((t) => notes.any((n) => n.theme == t.id)).toList();
        final q = _query.toLowerCase();
        final shown = notes.where((n) {
          if (_filter != null && n.theme != _filter) return false;
          if (q.isEmpty) return true;
          return n.text.toLowerCase().contains(q) || n.reference.toLowerCase().contains(q);
        }).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            const MoodCheckIn(),
            const SizedBox(height: 14),
            _PromptOfDay(prompt: ReflectionThemes.promptOfDay(DateTime.now(), bn)),
            const SizedBox(height: 22),
            _Section(title: 'Find ayahs for what you feel'.tr, subtitle: 'Curated collections by emotion and topic'.tr),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ReflectionThemes.all.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (_, i) => ThemeTile(theme: ReflectionThemes.all[i]),
            ),
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 22),
              _InsightsCard(insights: insights),
            ],
            const SizedBox(height: 22),
            _Section(
              title: 'My reflections'.tr,
              subtitle: 'Private notes stay on this phone. They are not uploaded. A settings backup includes them only if you export one yourself.'.tr,
            ),
            const SizedBox(height: 10),
            if (notes.isEmpty)
              EmptyState(
                compact: true,
                icon: Icons.edit_note_rounded,
                title: 'Your reflections live here'.tr,
                message: 'Pick a feeling above or write what an ayah meant to you today. Notes never leave this phone.'.tr,
                actionLabel: 'Write'.tr,
                actionIcon: Icons.edit_rounded,
                onAction: () => Get.toNamed(AppRoutes.reflectEditor),
              )
            else ...[
              TextField(
                controller: _search,
                onChanged: (v) => setState(() => _query = v.trim()),
                decoration: InputDecoration(
                  hintText: 'Search your notes'.tr,
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () => setState(() {
                            _search.clear();
                            _query = '';
                          }),
                        ),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              if (usedThemes.isNotEmpty) ...[
                const SizedBox(height: 10),
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'All'.tr,
                        color: AppColors.emerald,
                        selected: _filter == null,
                        onTap: () => setState(() => _filter = null),
                      ),
                      ...usedThemes.map((t) => _FilterChip(
                            label: t.name(bn),
                            icon: t.icon,
                            color: t.color,
                            selected: _filter == t.id,
                            onTap: () => setState(() => _filter = _filter == t.id ? null : t.id),
                          )),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (shown.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('No notes match.'.tr, style: TextStyle(color: AppColors.textMid)),
                  ),
                ),
              ...shown.map((n) => ReflectionNoteCard(key: ValueKey(n.id), note: n)),
            ],
          ],
        );
      }),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String subtitle;
  const _Section({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 3),
        Text(subtitle, style: TextStyle(fontSize: 11.5, height: 1.35, color: AppColors.textMid)),
      ],
    );
  }
}

class _PromptOfDay extends StatelessWidget {
  final String prompt;
  const _PromptOfDay({required this.prompt});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Get.toNamed(AppRoutes.reflectEditor, arguments: {'prompt': prompt}),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(Icons.wb_sunny_outlined, color: AppColors.gold, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Today's question".tr,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gold)),
                  const SizedBox(height: 3),
                  Text(prompt, style: TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

class _InsightsCard extends StatelessWidget {
  final ReflectionInsights insights;
  const _InsightsCard({required this.insights});

  @override
  Widget build(BuildContext context) {
    final bn = LocaleText.isBangla;
    final moodTotal = insights.moods14.values.fold<int>(0, (a, b) => a + b);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.emerald.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights_rounded, size: 18, color: AppColors.emerald),
              const SizedBox(width: 8),
              Text('Your reflection insights'.tr,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _Stat(value: LocaleText.digits(insights.total), label: 'Notes'.tr),
              _Stat(value: LocaleText.digits(insights.last7), label: 'This week'.tr),
              _Stat(value: LocaleText.digits(insights.streak), label: 'Day streak'.tr),
            ],
          ),
          if (insights.topThemes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('What your heart returns to'.tr, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMid)),
            const SizedBox(height: 8),
            ...insights.topThemes.map((e) {
              final max = insights.topThemes.first.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => Get.toNamed(AppRoutes.reflectTheme, arguments: {'theme': e.key.id}),
                  child: Row(
                    children: [
                      Icon(e.key.icon, size: 16, color: e.key.color),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 104,
                        child: Text(e.key.name(bn),
                            maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: AppColors.textDark)),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: e.value / max,
                            minHeight: 8,
                            backgroundColor: e.key.color.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation(e.key.color),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(LocaleText.digits(e.value), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMid)),
                    ],
                  ),
                ),
              );
            }),
          ],
          if (moodTotal > 0) ...[
            const SizedBox(height: 10),
            Text('Moods in the last 14 days'.tr, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMid)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: ReflectionThemes.moods.where((m) => (insights.moods14[m.id] ?? 0) > 0).map((m) {
                  final count = insights.moods14[m.id]!;
                  return Expanded(
                    flex: count,
                    child: Container(
                      height: 30,
                      alignment: Alignment.center,
                      color: ReflectionThemes.byId(m.themeId)!.color.withValues(alpha: 0.2),
                      child: Text('${m.emoji} ${LocaleText.digits(count)}', style: const TextStyle(fontSize: 12)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.emerald)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.textMid)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.color, required this.selected, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? color : AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 13, color: selected ? Colors.white : color),
                const SizedBox(width: 4),
              ],
              Text(label,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textDark)),
            ],
          ),
        ),
      ),
    );
  }
}
