import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../widgets/task_card.dart';
import 'create_task_page.dart';
import '../models/task_item.dart';
import '../providers/task_provider.dart';
import '../providers/notification_provider.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Consumer<TaskProvider>(
          builder: (context, prov, child) => Text(
            'Мої завдання (${prov.tasks.length})',
            style: const TextStyle(color: Colors.black, fontSize: 24),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          final items = provider.tasks;
          if (provider.loading && items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Не вдалось завантажити завдання'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => provider.loadTasks(),
                    child: const Text('Повторити'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadTasks();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final TaskItem t = items[index];
                final taskMap = {
                  'subject': t.subject,
                  'priority': t.priority ?? (t.isDone ? 'Низький' : 'Середній'),
                  'priorityColor': t.priorityColorValue != null
                      ? Color(t.priorityColorValue!)
                      : (t.isDone ? Colors.green : Colors.red),
                  'title': t.title,
                  'deadline': t.deadline ?? '',
                  'description': t.description ?? '',
                  'date': null,
                  'time': null,
                  'isDone': t.isDone,
                };

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Slidable(
                    key: ValueKey(t.id),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) async {
                            final updatedMap = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CreateTaskPage(task: taskMap),
                              ),
                            );
                            if (updatedMap != null && updatedMap is Map) {
                              final priorityColorRaw =
                                  updatedMap['priorityColor'];
                              int? priorityColorVal;
                              if (priorityColorRaw is Color) {
                                priorityColorVal = priorityColorRaw.value;
                              } else if (priorityColorRaw is int) {
                                priorityColorVal = priorityColorRaw;
                              } else if (priorityColorRaw is String) {
                                priorityColorVal =
                                    int.tryParse(priorityColorRaw);
                              }

                              final updatedTask = TaskItem(
                                id: t.id,
                                subject: (updatedMap['subject'] as String?) ??
                                    t.subject,
                                title:
                                    (updatedMap['title'] as String?) ?? t.title,
                                description:
                                    (updatedMap['description'] as String?) ??
                                        (updatedMap['deadline'] as String?) ??
                                        t.description,
                                deadline: (updatedMap['deadline'] as String?) ??
                                    t.deadline,
                                priority: (updatedMap['priority'] as String?) ??
                                    t.priority,
                                priorityColorValue:
                                    priorityColorVal ?? t.priorityColorValue,
                                isDone: t.isDone,
                              );
                              try {
                                await context
                                    .read<TaskProvider>()
                                    .updateTask(updatedTask);
                                try {
                                  await context
                                      .read<NotificationProvider>()
                                      .addFromTask(updatedTask,
                                          type: 'Оновлено');
                                } catch (_) {}

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Завдання оновлено')),
                                );
                              } catch (e) {}
                            }
                          },
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: 'Редагувати',
                        ),
                        SlidableAction(
                          onPressed: (_) async {
                            try {
                              await context
                                  .read<TaskProvider>()
                                  .deleteTask(t.id);
                              try {
                                await context
                                    .read<NotificationProvider>()
                                    .removeByTaskId(t.id);
                              } catch (_) {}
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Завдання видалено')),
                              );
                            } catch (e) {}
                          },
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Видалити',
                        ),
                      ],
                    ),
                    child: TaskCard(
                      task: taskMap,
                      onToggle: () async {
                        await context.read<TaskProvider>().toggleDone(t.id);
                        try {
                          final updated = context
                              .read<TaskProvider>()
                              .tasks
                              .firstWhere((x) => x.id == t.id);
                          if (updated.isDone) {
                            await context
                                .read<NotificationProvider>()
                                .markReadByTaskId(t.id, read: true);
                          } else {
                            await context
                                .read<NotificationProvider>()
                                .markReadByTaskId(t.id, read: false);
                          }
                        } catch (_) {}
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateTaskPage()),
          );
          if (newTask != null && newTask is Map) {
            final id = DateTime.now().millisecondsSinceEpoch;
            final priorityColorRaw = newTask['priorityColor'];
            int? priorityColorVal;
            if (priorityColorRaw is Color) {
              priorityColorVal = priorityColorRaw.value;
            } else if (priorityColorRaw is int) {
              priorityColorVal = priorityColorRaw;
            } else if (priorityColorRaw is String) {
              priorityColorVal = int.tryParse(priorityColorRaw);
            }

            final TaskItem created = TaskItem(
              id: id,
              subject: (newTask['subject'] as String?) ?? 'Без предмету',
              title: (newTask['title'] as String?) ?? 'Нове завдання',
              description: (newTask['description'] as String?) ??
                  (newTask['deadline'] as String?),
              deadline: (newTask['deadline'] as String?),
              priority: (newTask['priority'] as String?),
              priorityColorValue: priorityColorVal,
              isDone: false,
            );
            try {
              await context.read<TaskProvider>().addTask(created);
              try {
                await context
                    .read<NotificationProvider>()
                    .addFromTask(created, type: 'Дедлайн');
              } catch (_) {}
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Завдання додано')),
              );
            } catch (e) {}
          }
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
