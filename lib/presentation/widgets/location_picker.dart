import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/controllers/prayer_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/i18n/locale_text.dart';
import '../../core/prayer/cities.dart';

/// GPS or a city from the built-in list. Picking a place also sets the
/// calculation method used there. Resolves to true when a place was set.
Future<bool> showLocationPicker(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => const _LocationSheet(),
  );
  return result ?? false;
}

class _LocationSheet extends StatefulWidget {
  const _LocationSheet();

  @override
  State<_LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends State<_LocationSheet> {
  final _p = Get.find<PrayerController>();
  String _query = '';
  bool _locating = false;
  String? _error;

  Future<void> _useGps() async {
    setState(() {
      _locating = true;
      _error = null;
    });
    final error = await _p.useDeviceLocation();
    if (!mounted) return;
    if (error == null) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _locating = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bn = LocaleText.isBangla;
    final results = Cities.search(_query);
    final local = results.where((c) => c.isBangladesh).toList();
    final world = results.where((c) => !c.isBangladesh).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, scroll) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: AppColors.textLight, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 14),
                Text('Your location'.tr,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text('Used only on this phone to calculate prayer times. Never uploaded.'.tr,
                    style: TextStyle(fontSize: 12, color: AppColors.textMid)),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _locating ? null : _useGps,
                    icon: _locating
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.my_location_rounded, size: 20),
                    label: Text(_locating ? 'Finding you…'.tr : 'Use my current location'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.emerald.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(fontSize: 12, color: Color(0xFFC0392B))),
                ],
                const SizedBox(height: 14),
                TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search city or district'.tr,
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              children: [
                if (local.isNotEmpty) _header('Bangladesh'.tr),
                ...local.map((c) => _tile(c, bn)),
                if (world.isNotEmpty) _header('Around the world'.tr),
                ...world.map((c) => _tile(c, bn)),
                if (results.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Not in the list? Use your current location instead.'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMid),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 14, 8, 4),
        child: Text(text.toUpperCase(),
            style: TextStyle(fontSize: 10.5, letterSpacing: 1, fontWeight: FontWeight.w700, color: AppColors.textLight)),
      );

  Widget _tile(City c, bool bn) {
    final selected = !_p.usingGps.value && _p.locationName.value == c.name;
    return ListTile(
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(c.isBangladesh ? Icons.location_city_rounded : Icons.public_rounded,
          size: 20, color: selected ? AppColors.emerald : AppColors.textLight),
      title: Text(c.label(bn),
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.emerald : AppColors.textDark,
          )),
      subtitle: bn ? null : Text(c.nameBn, style: TextStyle(fontSize: 11, color: AppColors.textLight)),
      trailing: selected ? Icon(Icons.check_circle_rounded, color: AppColors.emerald) : null,
      onTap: () {
        _p.setCity(c);
        Navigator.pop(context, true);
      },
    );
  }
}
