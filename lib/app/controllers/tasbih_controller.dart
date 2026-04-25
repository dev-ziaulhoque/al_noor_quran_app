// lib/app/controllers/tasbih_controller.dart
import 'package:get/get.dart';
import '../../data/services/storage_service.dart';

class TasbihController extends GetxController {
  final StorageService _storage = Get.find();

  final RxInt count = 0.obs;
  final RxInt total = 0.obs;
  final RxInt streak = 0.obs;
  final RxInt targetCount = 33.obs;
  final RxInt selectedPhrase = 0.obs; // 0=SubhanAllah 1=Alhamdulillah 2=AllahuAkbar

  static const List<Map<String, String>> phrases = [
    {'arabic': 'سُبْحَانَ الله', 'transliteration': 'SubhanAllah', 'meaning': 'Glory be to Allah'},
    {'arabic': 'الْحَمْدُ لِلَّه', 'transliteration': 'Alhamdulillah', 'meaning': 'Praise be to Allah'},
    {'arabic': 'اللَّهُ أَكْبَر', 'transliteration': 'Allahu Akbar', 'meaning': 'Allah is the Greatest'},
  ];

  @override
  void onInit() {
    super.onInit();
    count.value = _storage.getTasbihCount();
    total.value = _storage.getTasbihTotal();
    streak.value = _storage.getTasbihStreak();
    _checkStreak();
  }

  void _checkStreak() {
    final lastDate = _storage.getTasbihLastDate();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (lastDate == null) return;
    final last = DateTime.parse(lastDate);
    final diff = DateTime.now().difference(last).inDays;
    if (diff > 1) {
      streak.value = 0;
      _storage.saveTasbihStreak(0);
    }
  }

  void tap() {
    if (count.value >= targetCount.value) {
      reset();
      return;
    }
    count.value++;
    total.value++;
    _storage.saveTasbihCount(count.value);
    _storage.saveTasbihTotal(total.value);

    if (count.value == targetCount.value) {
      _onTargetReached();
    }
  }

  void _onTargetReached() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = _storage.getTasbihLastDate();
    if (lastDate != today) {
      streak.value++;
      _storage.saveTasbihStreak(streak.value);
      _storage.saveTasbihLastDate(today);
    }
  }

  void reset() {
    count.value = 0;
    _storage.saveTasbihCount(0);
  }

  void selectPhrase(int index) {
    selectedPhrase.value = index;
    reset();
  }

  void setTarget(int target) {
    targetCount.value = target;
    reset();
  }

  double get progress => count.value / targetCount.value;
  String get formattedTotal {
    if (total.value >= 1000) {
      return '${(total.value / 1000).toStringAsFixed(1)}k';
    }
    return total.value.toString();
  }
}
