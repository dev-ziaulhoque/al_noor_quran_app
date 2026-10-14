import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/controllers/reflection_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/locale_text.dart';
import '../../../data/content/reflection_themes.dart';
import '../../widgets/islamic_art.dart';
import '../../widgets/reflection_widgets.dart';

/// One emotion or topic: curated ayahs, the user's own saved ayahs, guided
/// prompts and the notes written under it. Argument: `{'theme': id}`.
class ReflectionThemeScreen extends StatelessWidget {
  const ReflectionThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final theme = ReflectionThemes.byId(args is Map ? args['theme'] as String? : null) ?? ReflectionThemes.all.first;
    final ctrl = Get.find<ReflectionController>();
    final bn = LocaleText.isBangla;
    final dark = Color.lerp(theme.color, Colors.black, 0.45)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.color,
        foregroundColor: Colors.white,
        onPressed: () => Get.toNamed(AppRoutes.reflectEditor, arguments: {'theme': theme.id}),
        icon: const Icon(Icons.edit_note_rounded),
        label: Text('Write'.tr),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 230,
            backgroundColor: dark,
            foregroundColor: Colors.white,
            title: Text(theme.name(bn), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [theme.color, dark],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: 0.5,
                      child: CustomPaint(
                        painter: IslamicArtPainter(art: IslamicArt.lattice, accent: Colors.white, compact: true),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(theme.arabic,
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(fontFamily: 'Amiri', fontSize: 30, color: Colors.white)),
                            const SizedBox(height: 6),
                            Text(theme.desc(bn),
                                style: const TextStyle(fontSize: 13, height: 1.45, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Expanded(
                      child: _QuickButton(
                        icon: Icons.edit_note_rounded,
                        label: 'Write'.tr,
                        color: theme.color,
                        onTap: () => Get.toNamed(AppRoutes.reflectEditor, arguments: {'theme': theme.id}),
                      ),
                    ),
                    if (theme.duaCategory != null) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickButton(
                          icon: Icons.volunteer_activism_rounded,
                          label: 'Related duas'.tr,
                          color: theme.color,
                          onTap: () => Get.toNamed(AppRoutes.dua, arguments: {'category': theme.duaCategory}),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                _Header(title: 'Questions to sit with'.tr, icon: Icons.psychology_alt_rounded, color: theme.color),
                const SizedBox(height: 8),
                ...theme.prompts(bn).map((p) => _PromptTile(prompt: p, theme: theme)),
                const SizedBox(height: 20),
                _Header(
                  title: 'Curated ayahs'.tr,
                  icon: Icons.auto_stories_rounded,
                  color: theme.color,
                  trailing: LocaleText.digits(theme.ayahs.length),
                ),
                const SizedBox(height: 4),
                Text('Shown in your chosen translation. Open any ayah in the Quran for context and tafsir.'.tr,
                    style: TextStyle(fontSize: 11.5, color: AppColors.textMid)),
                const SizedBox(height: 10),
                ...theme.ayahs.map((a) => ThemeAyahCard(key: ValueKey('c${a.key}'), ayah: a, theme: theme)),
                Obx(() {
                  final saved = ctrl.savedAyahs(theme.id);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      _Header(
                        title: 'Added by you'.tr,
                        icon: Icons.bookmark_added_rounded,
                        color: theme.color,
                        trailing: saved.isEmpty ? null : LocaleText.digits(saved.length),
                      ),
                      const SizedBox(height: 8),
                      if (saved.isEmpty)
                        _Hint(
                          icon: Icons.lightbulb_outline_rounded,
                          text: 'While reading the Quran, tap the reflect icon on any ayah to add it here.'.tr,
                        )
                      else
                        ...saved.map((a) => ThemeAyahCard(key: ValueKey('s${a.key}'), ayah: a, theme: theme, userSaved: true)),
                    ],
                  );
                }),
                Obx(() {
                  final notes = ctrl.notesFor(theme.id);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      _Header(
                        title: 'Your reflections'.tr,
                        icon: Icons.lock_outline_rounded,
                        color: theme.color,
                        trailing: notes.isEmpty ? null : LocaleText.digits(notes.length),
                      ),
                      const SizedBox(height: 8),
                      if (notes.isEmpty)
                        _Hint(icon: Icons.edit_note_rounded, text: 'Nothing written here yet. Your notes stay on this phone.'.tr)
                      else
                        ...notes.map((n) => ReflectionNoteCard(key: ValueKey(n.id), note: n, showTheme: false)),
                    ],
                  );
                }),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String? trailing;

  const _Header({required this.title, required this.icon, required this.color, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        ),
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Text(trailing!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ),
      ],
    );
  }
}

class _PromptTile extends StatelessWidget {
  final String prompt;
  final ReflectionTheme theme;

  const _PromptTile({required this.prompt, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Get.toNamed(AppRoutes.reflectEditor, arguments: {'theme': theme.id, 'prompt': prompt}),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.format_quote_rounded, size: 18, color: theme.color),
              const SizedBox(width: 10),
              Expanded(child: Text(prompt, style: TextStyle(fontSize: 13.5, height: 1.4, color: AppColors.textDark))),
              Icon(Icons.edit_rounded, size: 16, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Hint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textLight),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.textMid))),
        ],
      ),
    );
  }
}
