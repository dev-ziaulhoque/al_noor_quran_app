// lib/presentation/screens/tracker/tracker_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final Map<String, bool> _tasks = {
    'Fajr Prayer': true,
    'Read Quran (1 page)': true,
    'Dhuhr Prayer': false,
    'Morning Adhkar': false,
    'Asr Prayer': false,
    'Evening Adhkar': false,
    'Isha Prayer': false,
    'Tasbih (100x)': false,
  };

  @override
  Widget build(BuildContext context) {
    final completed = _tasks.values.where((v) => v).length;
    final total = _tasks.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(children: [
          Text('Daily Tracker',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          Text('متابعة يومية',
              style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 12,
                  color: AppColors.textLight)),
        ]),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // ── Progress card ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B6B3A), Color(0xFF0D4223)],
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
                        const Text("Today's Progress",
                            style: TextStyle(
                                fontSize: 9,
                                color: Color(0x80FFFFFF),
                                letterSpacing: 1.2)),
                        Text('$completed / $total tasks',
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const Text('Keep it up! 🌙',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xBFFFFFFF))),
                      ],
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withOpacity(0.2),
                        border: Border.all(
                            color: AppColors.goldLight, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          '${((completed / total) * 100).round()}%',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: completed / total,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.goldLight),
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
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text("TODAY'S TASKS",
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                    letterSpacing: 1)),
          ),

          // ── Task list ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.black.withOpacity(0.06), width: 0.5),
            ),
            child: Column(
              children: _tasks.entries.toList().asMap().entries.map((entry) {
                final i = entry.key;
                final task = entry.value;
                final isLast = i == _tasks.length - 1;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _tasks[task.key] = !task.value),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : Border(
                              bottom: BorderSide(
                                  color:
                                      Colors.black.withOpacity(0.04),
                                  width: 0.5)),
                    ),
                    child: Row(children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: task.value
                              ? AppColors.emerald
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                              color: task.value
                                  ? AppColors.emerald
                                  : Colors.black.withOpacity(0.15),
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
                                ? AppColors.textLight
                                : AppColors.textDark,
                            decoration: task.value
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      if (task.value)
                        const Icon(Icons.check_circle_rounded,
                            size: 16, color: AppColors.emerald),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // ── Add custom task ──
          GestureDetector(
            onTap: () => _addTask(context),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.emeraldPale,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.emeraldLight.withOpacity(0.4),
                    width: 0.8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded,
                      color: AppColors.emerald, size: 18),
                  SizedBox(width: 6),
                  Text('Add Custom Task',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.emerald)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addTask(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Task'),
        content: TextField(
          controller: ctrl,
          decoration:
              const InputDecoration(hintText: 'e.g. Read 5 pages'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final txt = ctrl.text.trim();
              if (txt.isNotEmpty) {
                setState(() => _tasks[txt] = false);
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald),
            child: const Text('Add',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final String label;
  final String value;
  const _StreakCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: Colors.black.withOpacity(0.06), width: 0.5),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 9, color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }
}
