import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/controllers/reflection_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/locale_text.dart';
import '../../../data/content/reflection_themes.dart';

/// Write or edit a reflection. Arguments (all optional): `noteId`, `theme`,
/// `mood`, `surah`, `ayah`, `reference`, `prompt`.
class ReflectionEditorScreen extends StatefulWidget {
  const ReflectionEditorScreen({super.key});

  @override
  State<ReflectionEditorScreen> createState() => _ReflectionEditorScreenState();
}

class _ReflectionEditorScreenState extends State<ReflectionEditorScreen> {
  final _ctrl = Get.find<ReflectionController>();
  final _text = TextEditingController();
  String? _noteId;
  String? _theme;
  String? _mood;
  String? _reference;
  int? _surah;
  int? _ayah;
  List<ReflectionTheme> _suggested = const [];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map) {
      _noteId = args['noteId'] as String?;
      _theme = args['theme'] as String?;
      _mood = args['mood'] as String?;
      _reference = args['reference'] as String?;
      _surah = args['surah'] as int?;
      _ayah = args['ayah'] as int?;
      final prompt = args['prompt'] as String?;
      if (prompt != null) _text.text = '$prompt\n';
    }
    final existing = _noteId == null ? null : _ctrl.notes.firstWhereOrNull((n) => n.id == _noteId);
    if (existing != null) {
      _text.text = existing.text;
      _theme = existing.theme;
      _mood = existing.mood;
      _reference = existing.reference.isEmpty ? null : existing.reference;
      _surah = existing.surah;
      _ayah = existing.ayah;
    }
    if (_theme == null && _mood != null) _theme = ReflectionThemes.moodById(_mood)?.themeId;
    _text.addListener(_onText);
    _onText();
  }

  void _onText() {
    final next = ReflectionThemes.suggest(_text.text, limit: 3);
    if (next.map((t) => t.id).join() != _suggested.map((t) => t.id).join()) {
      setState(() => _suggested = next);
    }
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _insertPrompt(String prompt) {
    final current = _text.text.trimRight();
    _text.text = current.isEmpty ? '$prompt\n' : '$current\n\n$prompt\n';
    _text.selection = TextSelection.collapsed(offset: _text.text.length);
  }

  void _save() {
    final body = _text.text.trim();
    if (body.isEmpty) {
      Get.snackbar('Reflection'.tr, 'Write a few words first.'.tr, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final theme = _theme ?? (_suggested.isNotEmpty ? _suggested.first.id : null);
    _ctrl.saveNote(
      id: _noteId,
      text: body,
      theme: theme,
      mood: _mood,
      reference: _reference,
      surah: _surah,
      ayah: _ayah,
    );
    Get.back();
    final t = ReflectionThemes.byId(theme);
    Get.snackbar(
      'Saved on this phone'.tr,
      t == null ? 'Your reflection is saved.'.tr : 'Ayahs for @theme are ready for you.'.trParams({'theme': t.name(LocaleText.isBangla)}),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      mainButton: t == null
          ? null
          : TextButton(
              onPressed: () => Get.toNamed(AppRoutes.reflectTheme, arguments: {'theme': t.id}),
              child: Text('Open'.tr),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bn = LocaleText.isBangla;
    final theme = ReflectionThemes.byId(_theme);
    final prompts = theme?.prompts(bn) ?? [ReflectionThemes.promptOfDay(DateTime.now(), bn)];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_noteId == null ? 'New reflection'.tr : 'Edit reflection'.tr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.card,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _save,
            icon: Icon(Icons.check_rounded, color: AppColors.emerald),
            label: Text('Save'.tr, style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _label('How is your heart today?'.tr),
          const SizedBox(height: 8),
          Row(
            children: ReflectionThemes.moods.map((m) {
              final selected = _mood == m.id;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _mood = selected ? null : m.id;
                    if (!selected && _theme == null) _theme = m.themeId;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.emerald.withValues(alpha: 0.12) : AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: selected ? AppColors.emerald : Colors.black.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      children: [
                        Text(m.emoji, style: TextStyle(fontSize: selected ? 26 : 22)),
                        const SizedBox(height: 2),
                        Text(m.label(bn),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 10, color: selected ? AppColors.emerald : AppColors.textMid)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          if (_reference != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
              decoration: BoxDecoration(
                color: AppColors.emerald.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.menu_book_rounded, size: 16, color: AppColors.emerald),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_reference!,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.emerald)),
                  ),
                  IconButton(
                    tooltip: 'Remove'.tr,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() {
                      _reference = null;
                      _surah = null;
                      _ayah = null;
                    }),
                    icon: Icon(Icons.close_rounded, size: 18, color: AppColors.textMid),
                  ),
                ],
              ),
            ),
          TextField(
            controller: _text,
            minLines: 6,
            maxLines: 14,
            autofocus: _noteId == null && _mood == null,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(fontSize: 15, height: 1.5, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: 'Write freely. What happened, how you feel, what you want to ask Allah for…'.tr,
              hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 10),
          _label('Guided prompts'.tr),
          const SizedBox(height: 6),
          ...prompts.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _insertPrompt(p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: (theme?.color ?? AppColors.emerald).withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add_comment_outlined, size: 16, color: theme?.color ?? AppColors.emerald),
                        const SizedBox(width: 8),
                        Expanded(child: Text(p, style: TextStyle(fontSize: 13, height: 1.35, color: AppColors.textDark))),
                      ],
                    ),
                  ),
                ),
              )),
          if (_suggested.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.auto_awesome_rounded, size: 15, color: AppColors.gold),
                const SizedBox(width: 6),
                _label('Suggested from your words'.tr),
              ],
            ),
            const SizedBox(height: 4),
            Text('Matched on this phone. Nothing you write is sent anywhere.'.tr,
                style: TextStyle(fontSize: 11, color: AppColors.textLight)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggested.map((t) => _themeChip(t, bn, suggested: true)).toList(),
            ),
          ],
          const SizedBox(height: 16),
          _label('Theme'.tr),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ReflectionThemes.all.map((t) => _themeChip(t, bn)).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.lock_outline_rounded, size: 18),
              label: Text('Save on this phone'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) =>
      Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark));

  Widget _themeChip(ReflectionTheme t, bool bn, {bool suggested = false}) {
    final selected = _theme == t.id;
    return GestureDetector(
      onTap: () => setState(() => _theme = selected ? null : t.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? t.color : (suggested ? t.color.withValues(alpha: 0.12) : AppColors.card),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: t.color.withValues(alpha: selected ? 1 : 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(t.icon, size: 14, color: selected ? Colors.white : t.color),
            const SizedBox(width: 5),
            Text(t.name(bn),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textDark,
                )),
          ],
        ),
      ),
    );
  }
}
