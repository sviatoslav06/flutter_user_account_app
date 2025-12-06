import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notification_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Сповіщення',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Consumer<NotificationProvider>(
                    builder: (context, prov, child) {
                      final newCount = prov.items.where((i) => !i.read).length;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$newCount нових',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildToggleItem('Налаштування сповіщень', false),
              const SizedBox(height: 12),
              Expanded(
                child: Consumer<NotificationProvider>(
                  builder: (context, prov, child) {
                    if (prov.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final items = prov.items;
                    if (items.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async => await prov.load(),
                        child: ListView(
                          children: const [
                            SizedBox(height: 20),
                            Center(child: Text('Немає сповіщень')),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async => await prov.load(),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final n = items[i];
                          final color = n.colorValue != null
                              ? Color(n.colorValue!)
                              : Colors.blueAccent;
                          return Dismissible(
                            key: ValueKey(n.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) async {
                              await prov.remove(n.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Сповіщення видалено')),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: color,
                                    child: const Icon(Icons.notifications,
                                        color: Colors.white, size: 18),
                                  ),
                                  title: Text(
                                    n.title,
                                    style: n.read
                                        ? const TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough)
                                        : null,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (n.message.isNotEmpty)
                                        Text(
                                          n.message,
                                          style: n.read
                                              ? const TextStyle(
                                                  decoration: TextDecoration
                                                      .lineThrough)
                                              : null,
                                        ),
                                      if ((n.deadline ?? '').isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 6.0),
                                          child: Text(
                                            'Дедлайн: ${n.deadline}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          n.tag,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _timeAgo(n.createdAt),
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      )
                                    ],
                                  ),
                                  onTap: () async {
                                    await prov.markRead(n.id);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem(String title, bool isOn) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        Switch(
          value: isOn,
          onChanged: (_) {},
          activeThumbColor: Colors.indigo,
        ),
      ],
    );
  }

  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'менше хвилини тому';
    if (diff.inMinutes < 60) return '${diff.inMinutes} хвилин тому';
    if (diff.inHours < 24) return '${diff.inHours} годин тому';
    return '${diff.inDays} днів тому';
  }
}
