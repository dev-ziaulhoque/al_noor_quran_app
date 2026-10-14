// lib/presentation/screens/tracker/tracker_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/storage_service.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final StorageService _storage = Get.find<StorageService>();

  final Map<String, bool> _tasks = {
    'Fajr Prayer': true,
    'Dhuhr Prayer': true,
    'Asr Prayer': true,
    'Maghrib Prayer': false,
    'Isha Prayer': false,
    'Read 1 Page Quran': true,
    'Morning Adhkar': true,
    'Evening Adhkar': false,
  };

  final List<String> _customTasks = [];
  final TextEditingController _customTaskCtrl = TextEditingController();

  Icon _buildIcon(IconData icon, double size, Color color) => Icon(icon, size: size, color: color);

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    final saved = _storage.getTrackerData();
    if (saved != null) {
      saved.forEach((key, value) {
        if (value is bool) {
          _tasks[key] = value;
          if (!_isDefaultTask(key) && !_customTasks.contains(key)) {
            _customTasks.add(key);
          }
        }
      });
      setState(() {});
    }
  }

  bool _isDefaultTask(String key) {
    return [
      'Fajr Prayer', 'Dhuhr Prayer', 'Asr Prayer', 'Maghrib Prayer',
      'Isha Prayer', 'Read 1 Page Quran', 'Morning Adhkar', 'Evening Adhkar'
    ].contains(key);
  }

  void _saveTasks() {
    _storage.saveTrackerData(_tasks);
  }

  void _toggle(String key) {
    setState(() {
      _tasks[key] = !(_tasks[key] ?? false);
    });
    _saveTasks();
  }

  void _addCustomTask() {
    final name = _customTaskCtrl.text.trim();
    if (name.isNotEmpty && !_tasks.containsKey(name)) {
      setState(() {
        _tasks[name] = false;
        _customTasks.add(name);
      });
      _customTaskCtrl.clear();
      _saveTasks();
      Get.back();
    }
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Add Custom Habit', style: TextStyle(color: ThemeColors.textDark)),
        content: TextField(
          controller: _customTaskCtrl,
          autofocus: true,
          style: TextStyle(color: ThemeColors.textDark),
          decoration: InputDecoration(
            hintText: 'e.g. Tahajjud, Sadaqah, Read Hadith…',
            hintStyle: TextStyle(color: ThemeColors.textLight),
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text('Cancel', style: TextStyle(color: ThemeColors.textMid))),
          ElevatedButton(
            onPressed: _addCustomTask,
            style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.emerald),
            child: const Text('Add Task', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completed = _tasks.values.where((v) => v).length;
    final total = _tasks.isNotEmpty ? _tasks.length : 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(children: [
          Text('Daily Tracker'.tr,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          Text('متابعة يومية',
              style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 12,
                  color: AppColors.getTextLight())),
        ]),
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // ── Progress card ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeColors.emerald,
                  ThemeColors.emerald.withValues(alpha: 0.8)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Today\'s Progress',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 2),
                        Text('$completed of ${_tasks.length} completed',
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xCCFFFFFF))),
                      ],
                    ),
                    Text('${(completed / total * 100).round()}%',
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppPalette.goldLight)),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: completed / total,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    color: AppPalette.goldLight,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Streak row ──
          Row(children: [
            _StreakCard(label: 'Current Streak', value: '7 🔥'),
            const SizedBox(width: 10),
            _StreakCard(label: 'Best Streak', value: '14 ⭐'),
            const SizedBox(width: 10),
            _StreakCard(label: 'This Week', value: '5/7'),
          ]),
          const SizedBox(height: 16),

          // ── Tasks label ──
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("TODAY'S TASKS",
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: ThemeColors.textLight,
                        letterSpacing: 1)),
                GestureDetector(
                  onTap: _showAddTaskDialog,
                  child: Text("+ Add Habit",
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: ThemeColors.emerald)),
                ),
              ],
            ),
          ),

          // ── Task list ──
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: ThemeColors.textLight.withValues(alpha: 0.15),
                  width: 0.5),
            ),
            child: Column(
              children: _tasks.entries.map((task) {
                final iconColor = ThemeColors.emerald;
                final textLight = ThemeColors.textLight;
                final textDark = ThemeColors.textDark;
                return GestureDetector(
                  onTap: () => _toggle(task.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color:
                                  Colors.black.withValues(alpha: 0.04),
                              width: 0.5)),
                    ),
                    child: Row(children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: task.value
                              ? iconColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                              color: task.value
                                  ? iconColor
                                  : Colors.black.withValues(alpha: 0.15),
                              width: 1.5),
                        ),
                        child: task.value
                            ? const Icon(Icons.check_rounded,
                                size: 15, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          task.key,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: task.value
                                ? textLight
                                : textDark,
                            decoration: task.value
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      if (task.value)
                        Icon(Icons.check_circle_rounded,
                            size: 16, color: Color.fromARGB(iconColor.alpha, iconColor.red, iconColor.green, iconColor.blue)),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final String label;
  final String value;

  _StreakCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textLight = ThemeColors.textLight;
    final textDark = ThemeColors.textDark;
    final emeraldMid = ThemeColors.emeraldMid;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: emeraldMid, width: 0.5),
        ),
        child: Column(
          children: [
            Text(value,
                style:
                    TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 9, color: textLight)),
          ],
        ),
      ),
    );
  }
}
