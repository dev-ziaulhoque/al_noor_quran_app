import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/controllers/settings_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/prayer/prayer_options.dart';

Future<void> showPrayerMethodPicker(BuildContext context) {
  final ctrl = Get.find<SettingsController>();
  return showModalBottomSheet(
    context: context,
    backgroundColor: ThemeColors.getCard(),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: ThemeColors.getTextLight().withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 12),
            Text('Calculation method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ThemeColors.getTextDark())),
            const SizedBox(height: 4),
            Text(
              'Karachi is the usual method in Bangladesh. Asr also depends on the madhab.',
              style: TextStyle(fontSize: 12, color: ThemeColors.getTextLight()),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: PrayerOptions.methods.map((method) {
                  return Obx(() {
                    final selected = ctrl.calcMethodId.value == method.id;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        method.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? ThemeColors.getEmerald() : ThemeColors.getTextDark(),
                        ),
                      ),
                      subtitle: Text(method.region, style: TextStyle(fontSize: 11, color: ThemeColors.getTextLight())),
                      trailing: selected ? Icon(Icons.check_circle_rounded, color: ThemeColors.getEmerald()) : null,
                      onTap: () {
                        ctrl.selectCalcMethod(method.id);
                        Get.back();
                      },
                    );
                  });
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> showMadhabPicker(BuildContext context) {
  final ctrl = Get.find<SettingsController>();
  return showModalBottomSheet(
    context: context,
    backgroundColor: ThemeColors.getCard(),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Asr madhab', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ThemeColors.getTextDark())),
            const SizedBox(height: 8),
            ...PrayerOptions.madhabs.map((madhab) {
              return Obx(() {
                final selected = ctrl.madhabId.value == madhab.id;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    madhab.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? ThemeColors.getEmerald() : ThemeColors.getTextDark(),
                    ),
                  ),
                  subtitle: Text(madhab.asrNote, style: TextStyle(fontSize: 11, color: ThemeColors.getTextLight())),
                  trailing: selected ? Icon(Icons.check_circle_rounded, color: ThemeColors.getEmerald()) : null,
                  onTap: () {
                    ctrl.selectMadhab(madhab.id);
                    Get.back();
                  },
                );
              });
            }),
          ],
        ),
      ),
    ),
  );
}

/// Muazzin choice lives in the azan setup, where the voice is downloaded and previewed.
Future<void> showMuazzinPicker(BuildContext context) async {
  await Get.toNamed(AppRoutes.azanSetup);
}
