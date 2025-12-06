// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
// bottom nav is provided by HomeShell; individual pages should not include it.

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final List<Map<String, dynamic>> _schedule = [
    {
      'day': 'Понеділок',
      'lessons': [
        {
          'subject': 'Математичний аналіз',
          'time': '08:30 - 10:05',
          'room': 'Ауд. 205',
          'type': 'Лекція',
          'color': Colors.blueAccent,
        },
        {
          'subject': 'Фізика',
          'time': '10:25 - 12:00',
          'room': 'Ауд. 301',
          'type': 'Лабораторна',
          'color': Colors.purpleAccent,
        },
        {
          'subject': 'Англійська мова',
          'time': '12:20 - 13:55',
          'room': 'Ауд. 102',
          'type': 'Семінар',
          'color': Colors.greenAccent,
        },
      ],
    },
    {
      'day': 'Вівторок',
      'lessons': [
        {
          'subject': 'Програмування',
          'time': '09:00 - 10:35',
          'room': 'Ком. клас',
          'type': 'Лабораторна',
          'color': Colors.purpleAccent,
        },
        {
          'subject': 'Історія України',
          'time': '11:00 - 12:35',
          'room': 'Ауд. 150',
          'type': 'Лекція',
          'color': Colors.blueAccent,
        },
      ],
    },
    {
      'day': 'Середа',
      'lessons': [
        {
          'subject': 'Хімія',
          'time': '09:00 - 10:35',
          'room': 'Ауд. 210',
          'type': 'Лабораторна',
          'color': Colors.purpleAccent,
        },
      ],
    },
    {
      'day': 'Четвер',
      'lessons': [],
    },
    {
      'day': 'П’ятниця',
      'lessons': [],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 245, 245),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Розклад занять",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: const Icon(Icons.chevron_left, color: Colors.black54),
        actions: const [
          Icon(Icons.chevron_right, color: Colors.black54),
          SizedBox(width: 8),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _schedule.length,
        itemBuilder: (context, index) {
          final day = _schedule[index];
          final lessons = day['lessons'] as List;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day['day'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                if (lessons.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "Немає занять",
                        style: TextStyle(color: Colors.black45),
                      ),
                    ),
                  )
                else
                  Column(
                    children: lessons.map((lesson) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  lesson['subject'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (lesson['color'] as Color)
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    lesson['type'],
                                    style: TextStyle(
                                      color: lesson['color'],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 16, color: Colors.black54),
                                const SizedBox(width: 6),
                                Text(
                                  lesson['time'],
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.location_on_outlined,
                                    size: 16, color: Colors.black54),
                                const SizedBox(width: 6),
                                Text(
                                  lesson['room'],
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
