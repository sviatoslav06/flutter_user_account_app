// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Профіль',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      child: user?.photoURL == null
                          ? const Icon(Icons.person_outline)
                          : ClipOval(
                              child: SizedBox(
                                width: 64,
                                height: 64,
                                child: CachedNetworkImage(
                                  imageUrl: user!.photoURL!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2)),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.person_outline),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?.displayName ?? 'Нове ім\'я',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(user?.email ?? '',
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 4),
                          Row(
                            children: const [
                              _Tag(
                                  text: '3 курс',
                                  color: Colors.blueAccent,
                                  fontSize: 12),
                              SizedBox(width: 4),
                              _Tag(text: 'ІКНІ', color: Colors.grey),
                              SizedBox(width: 4),
                              _Tag(text: 'ПЗ-37', color: Colors.grey),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildStatsSection(),
              const SizedBox(height: 20),
              _buildAchievements(),
              const SizedBox(height: 20),
              _buildSettings(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Статистика',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _StatItem(
                  value: '75%',
                  label: 'Виконано\nзавдань',
                  color: Colors.green),
              _StatItem(
                  value: '7', label: 'Днів поспіль', color: Colors.indigo),
              _StatItem(
                  value: '45', label: 'Годин навчання', color: Colors.purple),
              _StatItem(value: '15', label: 'Завершено', color: Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Досягнення',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          const _Achievement(
              title: 'Перший тиждень',
              subtitle: '7 днів поспіль виконання завдань',
              color: Colors.amber),
          const _Achievement(
              title: 'Організований студент',
              subtitle: 'Використання планера',
              color: Colors.amber),
          const SizedBox(height: 16),
          const _Achievement(
              title: 'Сумлінний', subtitle: 'Виконання всіх завдань вчасно'),
          const _Achievement(
              title: 'Марафонець', subtitle: '100 годин навчання'),
        ],
      ),
    );
  }

  Widget _buildSettings(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Налаштування',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          _settingsItem(Icons.dark_mode_outlined, 'Темна тема', switcher: true),
          _settingsItem(Icons.notifications_outlined, 'Сповіщення',
              switcher: true),
          const Divider(),
          _settingsItem(Icons.person_outline, 'Налаштування профілю'),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () async {
              try {
                try {
                  await GoogleSignIn().disconnect();
                } catch (_) {}
                try {
                  await GoogleSignIn().signOut();
                } catch (_) {}

                await FirebaseAuth.instance.signOut();
              } catch (_) {}

              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Вийти з акаунту',
                style: TextStyle(color: Colors.red)),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              try {
                FirebaseCrashlytics.instance.crash();
              } catch (e) {
                FirebaseCrashlytics.instance
                    .recordError(e, StackTrace.current, fatal: true);
              }
            },
            icon: const Icon(Icons.bug_report, color: Colors.orange),
            label: const Text('Згенерувати помилку (Crashlytics)',
                style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  Widget _settingsItem(IconData icon, String title, {bool switcher = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.black54),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        if (switcher)
          Switch(value: false, onChanged: (_) {}, activeColor: Colors.indigo),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatItem(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label,
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _Achievement extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color? color;
  const _Achievement({required this.title, required this.subtitle, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey[200])!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events_outlined, color: color ?? Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text('$title\n$subtitle')),
          if (color != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color!.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Отримано', style: TextStyle(fontSize: 10)),
            )
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  const _Tag({required this.text, required this.color, this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: fontSize)),
    );
  }
}
