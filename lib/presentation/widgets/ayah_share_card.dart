import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../data/services/storage_service.dart';
import 'app_logo.dart';
import 'app_surfaces.dart';
import 'islamic_art.dart';

/// What a share card shows: Arabic, meaning, heading and a source line.
/// Used for ayahs, duas and hadith.
class AyahCardContent {
  final String arabic;
  final String meaning;
  final String heading;
  final String reference;
  final String fileId;

  AyahCardContent({
    required this.arabic,
    required this.meaning,
    required String surahName,
    required int surahNumber,
    required int ayahNumber,
    this.heading = 'Quran',
  })  : reference = '$surahName · $surahNumber:$ayahNumber',
        fileId = 'ayah_${surahNumber}_$ayahNumber';

  const AyahCardContent.text({
    required this.arabic,
    required this.meaning,
    required this.heading,
    required this.reference,
    required this.fileId,
  });
}

class AyahCardFont {
  final String name;
  final TextStyle arabic;

  const AyahCardFont(this.name, this.arabic);

  static final List<AyahCardFont> all = [
    const AyahCardFont('Amiri', TextStyle(fontFamily: 'Amiri', fontSize: 26, height: 1.9, color: Colors.white)),
    AyahCardFont('Naskh', GoogleFonts.notoNaskhArabic(fontSize: 24, height: 1.9, color: Colors.white)),
    AyahCardFont('Lateef', GoogleFonts.lateef(fontSize: 32, height: 1.7, color: Colors.white)),
  ];
}

/// Card colour: a three-stop gradient and the accent used for the art.
class AyahCardLook {
  final String name;
  final List<Color> colors;
  final Color accent;

  const AyahCardLook(this.name, this.colors, this.accent);

  static const List<AyahCardLook> all = [
    AyahCardLook('Garden', [Color(0xFF2A8A50), Color(0xFF15592F), Color(0xFF0A2E1A)], Color(0xFFE8C96A)),
    AyahCardLook('Night', [Color(0xFF2A4A75), Color(0xFF16294A), Color(0xFF0A1424)], Color(0xFFE8C96A)),
    AyahCardLook('Gold', [Color(0xFF8C6A26), Color(0xFF5E4312), Color(0xFF2E1F06)], Color(0xFFF6E2A0)),
    AyahCardLook('Turquoise', [Color(0xFF14918A), Color(0xFF0B5C57), Color(0xFF052E2C)], Color(0xFFF4D58D)),
    AyahCardLook('Ruby', [Color(0xFFA62A4A), Color(0xFF6E1430), Color(0xFF330716)], Color(0xFFF2CD8C)),
    AyahCardLook('Royal', [Color(0xFF5E3A96), Color(0xFF3A1F66), Color(0xFF1A0B33)], Color(0xFFEBC874)),
    AyahCardLook('Sapphire', [Color(0xFF2B5FD9), Color(0xFF1D3A8F), Color(0xFF0D1B4A)], Color(0xFFFCD679)),
    AyahCardLook('Sunset', [Color(0xFFD9622B), Color(0xFFA33B22), Color(0xFF4F1610)], Color(0xFFFFE6A8)),
    AyahCardLook('Rose', [Color(0xFFB0567E), Color(0xFF7A3358), Color(0xFF3B142A)], Color(0xFFF8DCAE)),
    AyahCardLook('Olive', [Color(0xFF66772E), Color(0xFF424E1C), Color(0xFF1E240C)], Color(0xFFEFDB9C)),
    AyahCardLook('Midnight', [Color(0xFF2E3644), Color(0xFF161B24), Color(0xFF05070B)], Color(0xFFD9B44A)),
  ];
}

/// One ayah, dua or hadith: Arabic, meaning and source, over Islamic art.
/// `compact` is the in-app size; the share image uses the full size.
class AyahShareCard extends StatelessWidget {
  final AyahCardContent content;
  final int lookIndex;
  final int fontIndex;
  final int artIndex;
  final bool compact;

  const AyahShareCard({
    super.key,
    required this.content,
    required this.lookIndex,
    this.fontIndex = 0,
    this.artIndex = 0,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final look = AyahCardLook.all[lookIndex % AyahCardLook.all.length];
    final font = AyahCardFont.all[fontIndex % AyahCardFont.all.length];
    final art = IslamicArt.values[artIndex % IslamicArt.values.length];
    final accent = look.accent;
    final scale = compact ? 0.72 : 1.0;
    final arabicStyle = font.arabic.copyWith(
      fontSize: (font.arabic.fontSize ?? 26) * scale,
      shadows: const [Shadow(color: Color(0x55000000), blurRadius: 8, offset: Offset(0, 2))],
    );

    final framed = art == IslamicArt.mihrab || art == IslamicArt.arabesque;
    final side = compact ? (framed ? 22.0 : 16.0) : (framed ? 32.0 : 24.0);
    final topExtra = art == IslamicArt.mihrab ? (compact ? 16.0 : 34.0) : 0.0;
    final bottomExtra = art == IslamicArt.mihrab ? (compact ? 26.0 : 52.0) : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(compact ? 18 : 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: look.colors,
            stops: const [0, 0.55, 1],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: CustomPaint(
          painter: IslamicArtPainter(art: art, accent: accent, compact: compact),
          child: Padding(
            padding: EdgeInsets.fromLTRB(side, compact ? 14 : 24, side, (compact ? 14 : 24) + bottomExtra),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    AppLogo.mark(size: compact ? 16 : 24),
                    const SizedBox(width: 7),
                    Text(
                      'AL NOOR QURAN',
                      style: TextStyle(
                        fontSize: compact ? 9 : 11,
                        letterSpacing: compact ? 2.4 : 3.2,
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        content.heading,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: compact ? 9 : 11, color: const Color(0xCCFFFFFF)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: (compact ? 10 : 20) + topExtra),
                Text(
                  content.arabic,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  maxLines: compact ? 3 : null,
                  overflow: compact ? TextOverflow.ellipsis : null,
                  style: arabicStyle,
                ),
                SizedBox(height: compact ? 6 : 12),
                OrnamentDivider(color: accent, size: compact ? 8 : 11),
                SizedBox(height: compact ? 6 : 12),
                Text(
                  content.meaning.isEmpty ? 'Meaning is not loaded yet.'.tr : content.meaning,
                  textAlign: TextAlign.center,
                  maxLines: compact ? 2 : null,
                  overflow: compact ? TextOverflow.ellipsis : null,
                  style: TextStyle(fontSize: compact ? 12 : 15, height: 1.45, color: const Color(0xEBFFFFFF)),
                ),
                SizedBox(height: compact ? 10 : 18),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14, vertical: compact ? 3 : 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accent.withValues(alpha: 0.45)),
                  ),
                  child: Text(
                    content.reference,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: compact ? 10.5 : 13, color: accent, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showAyahShareSheet(BuildContext context, AyahCardContent content) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) => _AyahShareSheet(content: content),
  );
}

class _AyahShareSheet extends StatefulWidget {
  final AyahCardContent content;
  const _AyahShareSheet({required this.content});

  @override
  State<_AyahShareSheet> createState() => _AyahShareSheetState();
}

class _AyahShareSheetState extends State<_AyahShareSheet> {
  final GlobalKey _cardKey = GlobalKey();
  final _storage = Get.find<StorageService>();
  late int _look;
  late int _font;
  late int _art;

  @override
  void initState() {
    super.initState();
    _look = _storage.getAyahCardBackground() % AyahCardLook.all.length;
    _font = _storage.getAyahCardFont();
    _art = _storage.getAyahCardArt() % IslamicArt.values.length;
  }

  Future<void> _share() async {
    try {
      final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${widget.content.fileId}.png');
      await file.writeAsBytes(bytes.buffer.asUint8List());
      final caption = '${widget.content.heading} · ${widget.content.reference}\n${widget.content.arabic}\n\n${widget.content.meaning}';
      await Share.shareXFiles([XFile(file.path)], text: caption);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create the share image.'.tr)),
      );
    }
  }

  BoxDecoration _chip(bool selected) => AppSurfaces.card(radius: 14).copyWith(
        border: Border.all(
          color: selected ? AppColors.emerald : (ThemeColors.isDark ? const Color(0x33C9A84C) : const Color(0xFFE6D9BE)),
          width: selected ? 1.6 : 1,
        ),
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMid)),
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: AppColors.textLight.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 14),
            RepaintBoundary(
              key: _cardKey,
              child: AyahShareCard(content: widget.content, lookIndex: _look, fontIndex: _font, artIndex: _art),
            ),
            const SizedBox(height: 16),
            _label('${'Card color'.tr} · ${AyahCardLook.all[_look].name.tr}'),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: AyahCardLook.all.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final look = AyahCardLook.all[i];
                  final selected = i == _look;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _look = i);
                      _storage.saveAyahCardBackground(i);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 46,
                      height: 46,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: selected ? AppColors.emerald : Colors.transparent, width: 2),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: look.colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                        ),
                        child: Center(child: StarGlyph(color: look.accent, size: selected ? 14 : 10)),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            _label('Islamic art'.tr),
            Row(
              children: [
                for (var i = 0; i < IslamicArt.values.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _art = i);
                        _storage.saveAyahCardArt(i);
                      },
                      child: Container(
                        height: 64,
                        decoration: _chip(_art == i),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(6, 6, 6, 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: LinearGradient(colors: AyahCardLook.all[_look].colors),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: CustomPaint(
                                  painter: IslamicArtPainter(
                                    art: IslamicArt.values[i],
                                    accent: AyahCardLook.all[_look].accent,
                                    compact: true,
                                  ),
                                  child: const SizedBox.expand(),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                IslamicArt.values[i].label.tr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: _art == i ? AppColors.emerald : AppColors.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            _label('Arabic font'.tr),
            Row(
              children: [
                for (var i = 0; i < AyahCardFont.all.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _font = i);
                        _storage.saveAyahCardFont(i);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: _chip(_font == i),
                        child: Text(
                          AyahCardFont.all[i].name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _font == i ? AppColors.emerald : AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _share,
              icon: const Icon(Icons.share_rounded, color: Colors.white),
              label: Text('Share card'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.emerald,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
