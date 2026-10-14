import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../app/controllers/quran_controller.dart';
import '../../app/controllers/reflection_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/i18n/locale_text.dart';
import '../../data/content/reflection_themes.dart';
import '../../data/models/models.dart';
import 'ayah_share_card.dart';

String _arabicDigits(int n) =>
    n.toString().split('').map((d) => String.fromCharCode(0x0660 + int.parse(d))).join();

/// "How is your heart today?" row. Tapping a mood opens the editor with the
/// mood picked and its matching theme suggested.
class MoodCheckIn extends StatelessWidget {
  final bool compact;
  const MoodCheckIn({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ReflectionController>();
    final bn = LocaleText.isBangla;
    return Obx(() {
      final today = ReflectionThemes.moodById(ctrl.todayMood());
      return Container(
        padding: EdgeInsets.all(compact ? 14 : 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.emerald.withValues(alpha: 0.12), AppColors.gold.withValues(alpha: 0.10)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.emerald.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite_border_rounded, size: 18, color: AppColors.emerald),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    today == null
                        ? 'How is your heart today?'.tr
                        : 'Today you felt @mood'.trParams({'mood': today.label(bn)}),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.journal),
                  child: Text('Reflect'.tr,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.emerald)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Pick a feeling to find ayahs for it and write a private note.'.tr,
                style: TextStyle(fontSize: 11.5, color: AppColors.textMid)),
            const SizedBox(height: 12),
            Row(
              children: ReflectionThemes.moods.map((m) {
                final picked = today?.id == m.id;
                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _openMood(m),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: picked ? AppColors.emerald.withValues(alpha: 0.18) : AppColors.card,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: picked ? AppColors.emerald : Colors.black.withValues(alpha: 0.05)),
                            ),
                            child: Text(m.emoji, style: const TextStyle(fontSize: 22)),
                          ),
                          const SizedBox(height: 4),
                          Text(m.label(bn),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 10, color: AppColors.textMid)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }

  void _openMood(Mood m) {
    final theme = ReflectionThemes.byId(m.themeId)!;
    final bn = LocaleText.isBangla;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.textLight, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(m.emoji, style: const TextStyle(fontSize: 34)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(m.label(bn),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(theme.desc(bn), style: TextStyle(fontSize: 13, height: 1.45, color: AppColors.textMid)),
            const SizedBox(height: 18),
            _SheetAction(
              icon: theme.icon,
              color: theme.color,
              title: 'Ayahs for @theme'.trParams({'theme': theme.name(bn)}),
              subtitle: '@count curated ayahs'.trParams({'count': LocaleText.digits(theme.ayahs.length)}),
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.reflectTheme, arguments: {'theme': theme.id});
              },
            ),
            const SizedBox(height: 10),
            _SheetAction(
              icon: Icons.edit_note_rounded,
              color: AppColors.emerald,
              title: 'Write how I feel'.tr,
              subtitle: 'Private, saved on this phone'.tr,
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.reflectEditor, arguments: {'mood': m.id, 'theme': theme.id});
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SheetAction({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 20, backgroundColor: color, child: Icon(icon, color: Colors.white, size: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 11.5, color: AppColors.textMid)),
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

/// Full "how do you feel" section: mood check-in, today's question, every
/// theme, and a way into the user's notes.
class ReflectionDiscover extends StatelessWidget {
  const ReflectionDiscover({super.key});

  @override
  Widget build(BuildContext context) {
    final bn = LocaleText.isBangla;
    final ctrl = Get.find<ReflectionController>();
    final prompt = ReflectionThemes.promptOfDay(DateTime.now(), bn);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MoodCheckIn(),
        const SizedBox(height: 12),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.toNamed(AppRoutes.reflectEditor, arguments: {'prompt': prompt}),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                Icon(Icons.wb_sunny_outlined, color: AppColors.gold, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Today's question".tr,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gold)),
                      const SizedBox(height: 2),
                      Text(prompt,
                          style: TextStyle(fontSize: 13.5, height: 1.35, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    ],
                  ),
                ),
                Icon(Icons.edit_rounded, size: 16, color: AppColors.textLight),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Find ayahs for what you feel'.tr,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text('Curated collections by emotion and topic'.tr,
                      style: TextStyle(fontSize: 11.5, color: AppColors.textMid)),
                ],
              ),
            ),
            Obx(() {
              final count = ctrl.notes.length;
              return TextButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.journal),
                icon: Icon(Icons.lock_outline_rounded, size: 15, color: AppColors.emerald),
                label: Text(
                  count == 0 ? 'My reflections'.tr : '${'My reflections'.tr} (${LocaleText.digits(count)})',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.emerald),
                ),
              );
            }),
          ],
        ),
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
      ],
    );
  }
}

class ThemeTile extends StatelessWidget {
  final ReflectionTheme theme;
  const ThemeTile({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ReflectionController>();
    final bn = LocaleText.isBangla;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Get.toNamed(AppRoutes.reflectTheme, arguments: {'theme': theme.id}),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.color, Color.lerp(theme.color, Colors.black, 0.35)!],
          ),
          boxShadow: [BoxShadow(color: theme.color.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -6,
              bottom: -10,
              child: Icon(theme.icon, size: 64, color: Colors.white.withValues(alpha: 0.12)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(theme.icon, color: Colors.white, size: 20),
                const Spacer(),
                Text(theme.arabic,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontFamily: 'Amiri', fontSize: 15, color: Colors.white70)),
                Text(theme.name(bn),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13.5, height: 1.2, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 4),
                Obx(() {
                  final notes = ctrl.notesFor(theme.id).length;
                  final ayahs = theme.ayahs.length + ctrl.savedAyahs(theme.id).length;
                  final parts = [
                    '${LocaleText.digits(ayahs)} ${'ayahs'.tr}',
                    if (notes > 0) '${LocaleText.digits(notes)} ${'notes'.tr}',
                  ];
                  return Text(parts.join(' · '), style: const TextStyle(fontSize: 10.5, color: Colors.white70));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A curated or saved ayah inside a theme, loaded in the reader's translation.
class ThemeAyahCard extends StatefulWidget {
  final ThemeAyah ayah;
  final ReflectionTheme theme;
  final bool userSaved;

  const ThemeAyahCard({super.key, required this.ayah, required this.theme, this.userSaved = false});

  @override
  State<ThemeAyahCard> createState() => _ThemeAyahCardState();
}

class _ThemeAyahCardState extends State<ThemeAyahCard> {
  final _ctrl = Get.find<ReflectionController>();
  late Future<List<AyahModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _ctrl.loadAyahs(widget.ayah);
  }

  String _arabic(List<AyahModel> list) => list.map((a) => '${a.arabic} ﴿${_arabicDigits(a.number)}﴾').join(' ');
  String _meaning(List<AyahModel> list) => list.map((a) => a.translation).where((t) => t.isNotEmpty).join(' ');

  @override
  Widget build(BuildContext context) {
    final color = widget.theme.color;
    final reference = _ctrl.referenceLabel(widget.ayah);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Icon(widget.userSaved ? Icons.bookmark_added_rounded : Icons.auto_stories_rounded, size: 16, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(reference, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: color)),
                ),
                if (widget.userSaved)
                  Text('Added by you'.tr, style: TextStyle(fontSize: 10.5, color: AppColors.textLight)),
              ],
            ),
          ),
          FutureBuilder<List<AyahModel>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: color))),
                );
              }
              final list = snap.data ?? const <AyahModel>[];
              if (snap.hasError || list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off_rounded, size: 18, color: AppColors.textLight),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Connect once to load this ayah. It is then saved for offline reading.'.tr,
                            style: TextStyle(fontSize: 12, color: AppColors.textMid)),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _future = _ctrl.loadAyahs(widget.ayah)),
                        child: Text('Retry'.tr),
                      ),
                    ],
                  ),
                );
              }
              final arabic = _arabic(list);
              final meaning = _meaning(list);
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(arabic,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: TextStyle(fontFamily: 'Amiri', fontSize: 21, height: 1.9, color: AppColors.textDark)),
                    if (meaning.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(meaning, style: TextStyle(fontSize: 13.5, height: 1.55, color: AppColors.textMid)),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _iconAction(Icons.menu_book_rounded, 'Open in Quran'.tr, () {
                          Get.find<QuranController>().openAyah(widget.ayah.surah, widget.ayah.from);
                          Get.toNamed(AppRoutes.quranReader);
                        }),
                        _iconAction(Icons.copy_rounded, 'Copy'.tr, () {
                          Clipboard.setData(ClipboardData(text: '$arabic\n\n$meaning\n— $reference'));
                          Get.snackbar('Copied'.tr, reference, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));
                        }),
                        _iconAction(Icons.share_rounded, 'Share'.tr, () {
                          showAyahShareSheet(
                            context,
                            AyahCardContent.text(
                              arabic: arabic,
                              meaning: meaning,
                              heading: widget.theme.name(LocaleText.isBangla),
                              reference: reference,
                              fileId: 'al_noor_theme_${widget.ayah.surah}_${widget.ayah.from}',
                            ),
                          );
                        }),
                        _iconAction(Icons.edit_note_rounded, 'Reflect'.tr, () {
                          Get.toNamed(AppRoutes.reflectEditor, arguments: {
                            'theme': widget.theme.id,
                            'surah': widget.ayah.surah,
                            'ayah': widget.ayah.from,
                            'reference': reference,
                          });
                        }),
                        if (widget.userSaved)
                          _iconAction(Icons.bookmark_remove_rounded, 'Remove'.tr, () {
                            _ctrl.toggleSaved(widget.theme.id, widget.ayah.surah, widget.ayah.from);
                          }),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _iconAction(IconData icon, String tooltip, VoidCallback onTap) => IconButton(
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        onPressed: onTap,
        icon: Icon(icon, size: 19, color: AppColors.textMid),
      );
}

class ReflectionNoteCard extends StatefulWidget {
  final ReflectionNote note;
  final bool showTheme;

  const ReflectionNoteCard({super.key, required this.note, this.showTheme = true});

  @override
  State<ReflectionNoteCard> createState() => _ReflectionNoteCardState();
}

class _ReflectionNoteCardState extends State<ReflectionNoteCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final bn = LocaleText.isBangla;
    final theme = ReflectionThemes.byId(note.theme);
    final mood = ReflectionThemes.moodById(note.mood);
    final accent = theme?.color ?? AppColors.emerald;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: accent, width: 3.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 6, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (mood != null) ...[
                    Text(mood.emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      '${LocaleText.gregorian(note.createdAt, withYear: note.createdAt.year != DateTime.now().year)} · ${LocaleText.time(note.createdAt)}',
                      style: TextStyle(fontSize: 11, color: AppColors.textLight),
                    ),
                  ),
                  if (widget.showTheme && theme != null)
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.reflectTheme, arguments: {'theme': theme.id}),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(theme.icon, size: 11, color: accent),
                            const SizedBox(width: 4),
                            Text(theme.name(bn), style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: accent)),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                ],
              ),
              if (note.reference.isNotEmpty) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: note.surah == null
                      ? null
                      : () {
                          Get.find<QuranController>().openAyah(note.surah!, note.ayah ?? 1);
                          Get.toNamed(AppRoutes.quranReader);
                        },
                  child: Row(
                    children: [
                      Icon(Icons.menu_book_rounded, size: 13, color: AppColors.emerald),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(note.reference,
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.emerald)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  note.text,
                  maxLines: _expanded ? null : 4,
                  overflow: _expanded ? null : TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textDark),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Edit'.tr,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Get.toNamed(AppRoutes.reflectEditor, arguments: {'noteId': note.id}),
                    icon: Icon(Icons.edit_outlined, size: 18, color: AppColors.textMid),
                  ),
                  IconButton(
                    tooltip: 'Delete'.tr,
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      final ctrl = Get.find<ReflectionController>();
                      ctrl.deleteNote(note.id);
                      Get.snackbar(
                        'Reflection deleted'.tr,
                        '',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 4),
                        mainButton: TextButton(
                          onPressed: () {
                            ctrl.restoreNote(note);
                            if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
                          },
                          child: Text('Undo'.tr),
                        ),
                      );
                    },
                    icon: Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.textMid),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// From the Quran reader: add this ayah to a theme collection or write about it.
void showAyahReflectSheet(BuildContext context, {required int surah, required int ayah, required String reference}) {
  final ctrl = Get.find<ReflectionController>();
  final bn = LocaleText.isBangla;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.62,
      maxChildSize: 0.92,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.textLight, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 14),
          Text(reference, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 12),
          _SheetAction(
            icon: Icons.edit_note_rounded,
            color: AppColors.emerald,
            title: 'Write a reflection'.tr,
            subtitle: 'What did this ayah bring to mind?'.tr,
            onTap: () {
              Navigator.pop(context);
              Get.toNamed(AppRoutes.reflectEditor, arguments: {'surah': surah, 'ayah': ayah, 'reference': reference});
            },
          ),
          const SizedBox(height: 18),
          Text('Add to a theme'.tr, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text('Build your own collection for hard days.'.tr, style: TextStyle(fontSize: 11.5, color: AppColors.textMid)),
          const SizedBox(height: 10),
          Obx(() {
            ctrl.themeSaves.length;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ReflectionThemes.all.map((t) {
                final curated = ctrl.isCurated(t.id, surah, ayah);
                final saved = curated || ctrl.isSaved(t.id, surah, ayah);
                return FilterChip(
                  selected: saved,
                  avatar: Icon(t.icon, size: 15, color: saved ? Colors.white : t.color),
                  label: Text(t.name(bn)),
                  labelStyle: TextStyle(fontSize: 12, color: saved ? Colors.white : AppColors.textDark),
                  selectedColor: t.color,
                  checkmarkColor: Colors.white,
                  showCheckmark: false,
                  backgroundColor: AppColors.background,
                  side: BorderSide(color: t.color.withValues(alpha: 0.4)),
                  tooltip: curated ? 'Already in the curated collection'.tr : null,
                  onSelected: (_) {
                    if (!curated) ctrl.toggleSaved(t.id, surah, ayah);
                  },
                );
              }).toList(),
            );
          }),
        ],
      ),
    ),
  );
}
