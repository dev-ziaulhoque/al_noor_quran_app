import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/controllers/prayer_controller.dart';
import '../../../app/controllers/settings_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/locale_text.dart';
import '../../../core/prayer/prayer_options.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/services/storage_service.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/islamic_art.dart';
import '../../widgets/location_picker.dart';

/// First launch: language, place for prayer times, then name and alerts.
/// Every step can be skipped; nothing is asked before the user taps.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _deep = Color(0xFF0D4223);
  static const _pages = 3;

  final _page = PageController();
  final _name = TextEditingController();
  final _settings = Get.find<SettingsController>();
  final _prayer = Get.find<PrayerController>();
  int _index = 0;
  bool _placeChosen = false;
  bool _azan = true;
  bool _dailyAyah = true;
  bool _reminders = true;

  @override
  void dispose() {
    _page.dispose();
    _name.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < _pages - 1) {
      _page.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    } else {
      _finish();
    }
  }

  void _setLanguage(String code) {
    _settings.setAppLanguage(code);
    _settings.selectTranslation(code == 'bn' ? 'bn.bengali' : 'en.sahih');
    setState(() {});
  }

  Future<void> _finish({bool skipped = false}) async {
    final storage = Get.find<StorageService>();
    storage.saveAppLanguage(_settings.appLanguage.value);
    final name = _name.text.trim();
    if (name.isNotEmpty) {
      _settings.userName.value = name;
      storage.saveUserName(name);
    }
    if (!skipped && (_azan || _dailyAyah || _reminders)) {
      await NotificationService.instance.ensurePermission();
    }
    storage.savePrayerAlertsNotif(_azan);
    storage.saveDailyVerseNotif(_dailyAyah);
    storage.saveRemindersNotif(_reminders);
    _settings.prayerAlerts.value = _azan;
    _settings.dailyVerse.value = _dailyAyah;
    _settings.reminders.value = _reminders;
    storage.setOnboarded();
    _prayer.syncNotifications();
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deep,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B6B3A), _deep, Color(0xFF0A3019)],
            stops: [0, 0.55, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.35,
                child: CustomPaint(painter: IslamicArtPainter(art: IslamicArt.lattice, accent: AppPalette.goldLight, compact: true)),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
                    child: Row(
                      children: [
                        ...List.generate(_pages, (i) {
                          final active = i == _index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(right: 6),
                            width: active ? 22 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: active ? AppPalette.goldLight : Colors.white24,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _finish(skipped: true),
                          child: Text('Skip'.tr, style: const TextStyle(color: Colors.white70)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _page,
                      onPageChanged: (i) => setState(() => _index = i),
                      children: [_languagePage(), _locationPage(), _personalPage()],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPalette.goldLight,
                          foregroundColor: _deep,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          _index == _pages - 1 ? 'Start using Al-Noor'.tr : (_index == 1 && !_placeChosen ? 'Use Dhaka for now'.tr : 'Continue'.tr),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Page 1: welcome + language ───
  Widget _languagePage() {
    final lang = _settings.appLanguage.value;
    return _PageBody(
      children: [
        const SizedBox(height: 12),
        const Center(child: AppLogo.full(size: 168)),
        const SizedBox(height: 10),
        const Center(
          child: Text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              textDirection: TextDirection.rtl,
              style: TextStyle(fontFamily: 'Amiri', fontSize: 18, color: AppPalette.goldLight)),
        ),
        const SizedBox(height: 22),
        Text('Your daily companion for Quran, prayer and reflection'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, height: 1.35, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 10),
        Text('Works offline. No account. Your data stays on your phone.'.tr,
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 13.5, height: 1.4, color: Colors.white70)),
        const SizedBox(height: 32),
        Text('Choose your language'.tr,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppPalette.goldLight)),
        const SizedBox(height: 10),
        _OptionCard(
          title: 'বাংলা',
          subtitle: 'বাংলা অনুবাদসহ কুরআন',
          selected: lang == 'bn',
          onTap: () => _setLanguage('bn'),
        ),
        const SizedBox(height: 10),
        _OptionCard(
          title: 'English',
          subtitle: 'Quran with Saheeh International',
          selected: lang == 'en',
          onTap: () => _setLanguage('en'),
        ),
      ],
    );
  }

  // ─── Page 2: location + live preview ───
  Widget _locationPage() {
    return _PageBody(
      children: [
        const SizedBox(height: 8),
        const _BigIcon(icon: Icons.mosque_rounded),
        const SizedBox(height: 18),
        Text('Prayer times for where you are'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 8),
        Text(
          'Your location is used only on this phone to calculate prayer times and Qibla. It is never uploaded.'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13.5, height: 1.45, color: Colors.white70),
        ),
        const SizedBox(height: 22),
        OutlinedButton.icon(
          onPressed: () async {
            final picked = await showLocationPicker(context);
            if (picked && mounted) setState(() => _placeChosen = true);
          },
          icon: const Icon(Icons.place_rounded, color: AppPalette.goldLight),
          label: Text(_placeChosen ? 'Change location'.tr : 'Set my location'.tr,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            side: const BorderSide(color: Colors.white38),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 18),
        Obx(() {
          final place = _prayer.placeLabel;
          final next = _prayer.nextPrayerName.value;
          final at = _prayer.nextAzanAt.value;
          final method = PrayerOptions.methodById(_settings.calcMethodId.value);
          final madhab = PrayerOptions.madhabById(_settings.madhabId.value);
          final list = _prayer.getPrayerList().where((p) => p['name'] != 'Sunrise').toList();
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 16, color: AppPalette.goldLight),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(place,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Next: @name'.trParams({'name': next.tr}),
                    style: const TextStyle(fontSize: 13, color: Colors.white70)),
                Text(at == null ? '--:--' : LocaleText.time(at),
                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white)),
                if (at != null)
                  Text('in @time'.trParams({'time': LocaleText.duration(at.difference(DateTime.now()))}),
                      style: const TextStyle(fontSize: 12.5, color: AppPalette.goldLight)),
                const SizedBox(height: 12),
                Row(
                  children: list.map((p) {
                    final isNext = p['next'] == true;
                    return Expanded(
                      child: Column(
                        children: [
                          Text((p['name'] as String).tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 10.5, color: isNext ? AppPalette.goldLight : Colors.white60)),
                          const SizedBox(height: 2),
                          Text(LocaleText.digits((p['time'] as String).split(' ').first),
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: isNext ? AppPalette.goldLight : Colors.white,
                              )),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Text('@method · @madhab Asr. You can change this in Settings.'
                        .trParams({'method': method.shortName, 'madhab': madhab.id == 'hanafi' ? 'Hanafi' : "Shafi'i"}),
                    style: const TextStyle(fontSize: 11, color: Colors.white54)),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ─── Page 3: name + alerts ───
  Widget _personalPage() {
    return _PageBody(
      children: [
        const SizedBox(height: 8),
        const _BigIcon(icon: Icons.favorite_rounded),
        const SizedBox(height: 18),
        Text('Make it yours'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 18),
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            labelText: 'Your name (optional)'.tr,
            labelStyle: const TextStyle(color: Colors.white60),
            prefixIcon: const Icon(Icons.person_outline_rounded, color: Colors.white60),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 22),
        Text('Gentle reminders'.tr,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppPalette.goldLight)),
        const SizedBox(height: 8),
        _ToggleRow(
          icon: Icons.notifications_active_rounded,
          title: 'Azan alerts'.tr,
          subtitle: 'At each prayer time'.tr,
          value: _azan,
          onChanged: (v) => setState(() => _azan = v),
        ),
        _ToggleRow(
          icon: Icons.wb_sunny_rounded,
          title: 'Ayah every morning'.tr,
          subtitle: 'One ayah with meaning at 7 AM'.tr,
          value: _dailyAyah,
          onChanged: (v) => setState(() => _dailyAyah = v),
        ),
        _ToggleRow(
          icon: Icons.mosque_rounded,
          title: "Jumu'ah & Ramadan".tr,
          subtitle: 'Al-Kahf on Friday, sehri and iftar in Ramadan'.tr,
          value: _reminders,
          onChanged: (v) => setState(() => _reminders = v),
        ),
        const SizedBox(height: 10),
        Text('Your phone will ask once if Al-Noor may send these. No ads, ever.'.tr,
            style: const TextStyle(fontSize: 11.5, height: 1.4, color: Colors.white54)),
      ],
    );
  }
}

class _PageBody extends StatelessWidget {
  final List<Widget> children;
  const _PageBody({required this.children});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      children: children,
    );
  }
}

class _BigIcon extends StatelessWidget {
  final IconData icon;
  const _BigIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(colors: [AppPalette.goldLight, AppPalette.gold]),
          boxShadow: [BoxShadow(color: AppPalette.gold.withValues(alpha: 0.35), blurRadius: 24)],
        ),
        child: Icon(icon, size: 40, color: const Color(0xFF0D4223)),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _OptionCard({required this.title, required this.subtitle, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withValues(alpha: 0.16) : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppPalette.goldLight : Colors.white24, width: selected ? 1.6 : 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white60)),
                ],
              ),
            ),
            Icon(selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected ? AppPalette.goldLight : Colors.white38),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppPalette.goldLight, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                Text(subtitle, style: const TextStyle(fontSize: 11.5, color: Colors.white60)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppPalette.gold,
          ),
        ],
      ),
    );
  }
}
