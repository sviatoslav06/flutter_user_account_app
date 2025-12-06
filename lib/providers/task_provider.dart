import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task_item.dart';
import 'dart:async';
// notification creation is delegated to NotificationProvider/UI
import '../repositories/task_repository.dart';
// NotificationRepository removed from TaskProvider; notifications are handled by NotificationProvider/UI

class TaskProvider extends ChangeNotifier {
  static const _basePrefsKey = 'tasks_list_v1';
  String? _prefsKey;

  List<TaskItem> _tasks = [];
  bool _loading = false;
  String? _error;

  final TaskRepository? firestoreRepo;

  Stream<List<TaskItem>>? _firestoreStream;
  StreamSubscription<List<TaskItem>>? _firestoreSub;
  StreamSubscription<User?>? _authSub;

  TaskProvider({this.firestoreRepo}) {
    // Listen to auth state changes so we can load the correct per-user cache
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
    // Initialize for current user (may be null)
    _onAuthChanged(FirebaseAuth.instance.currentUser);
  }

  Future<void> _onAuthChanged(User? user) async {
    // cancel any existing firestore subscription (changes user)
    await _firestoreSub?.cancel();
    _firestoreSub = null;
    // set prefs key per-user to isolate local caches
    final newPrefsKey =
        user != null ? '$_basePrefsKey\_${user.uid}' : _basePrefsKey;

    // If user signs in and they don't have a per-user cache but there is a global cache,
    // migrate the global cache to the per-user key so previously created tasks aren't lost.
    try {
      final prefs = await SharedPreferences.getInstance();
      final baseRaw = prefs.getString(_basePrefsKey);
      final perRaw = prefs.getString(newPrefsKey);
      if (user != null &&
          (perRaw == null || perRaw.isEmpty) &&
          baseRaw != null &&
          baseRaw.isNotEmpty) {
        await prefs.setString(newPrefsKey, baseRaw);
      }
    } catch (_) {}

    _prefsKey = newPrefsKey;

    // clear in-memory tasks immediately so previous user's tasks aren't shown
    _tasks = [];
    notifyListeners();

    // reload tasks for the new auth state and (re)start listener if needed
    await loadTasks();
    _startFirestoreListenerIfNeeded();
  }

  List<TaskItem> get tasks => List.unmodifiable(_tasks);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadTasks({bool simulateError = false}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 200));

    try {
      if (simulateError) throw Exception('Simulated load error');
      // Prefer Firestore if repository is available and user is signed in
      final user = FirebaseAuth.instance.currentUser;
      if (firestoreRepo != null && user != null) {
        try {
          final list = await firestoreRepo!.fetchTasksOnce(user.uid);
          if (list.isNotEmpty) {
            _tasks = list;
          } else {
            _tasks = _createDemoTasks();
            await _save();
          }
        } catch (e) {
          // fallback to prefs
          final prefs = await SharedPreferences.getInstance();
          final key = _prefsKey ?? _basePrefsKey;
          final raw = prefs.getString(key);
          if (raw != null && raw.isNotEmpty) {
            final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
            _tasks = decoded
                .map((e) => TaskItem.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          } else {
            _tasks = _createDemoTasks();
            await _save();
          }
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        final key = _prefsKey ?? _basePrefsKey;
        final raw = prefs.getString(key);

        if (raw != null && raw.isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
          _tasks = decoded
              .map((e) => TaskItem.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else {
          _tasks = _createDemoTasks();
          await _save();
        }
      }
    } catch (e) {
      _error = e.toString();
      _tasks = [];
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_tasks.map((e) => e.toJson()).toList());
    try {
      final key = _prefsKey ?? _basePrefsKey;
      await prefs.setString(key, encoded);
    } catch (e) {}
  }

  void _startFirestoreListenerIfNeeded() {
    final user = FirebaseAuth.instance.currentUser;
    if (firestoreRepo != null && user != null) {
      _firestoreStream = firestoreRepo!.watchTasksForUser(user.uid);
      _firestoreSub = _firestoreStream!.listen((list) async {
        _tasks = list;
        await _save();
        notifyListeners();
      });
    }
  }

  List<TaskItem> _createDemoTasks() {
    final base = DateTime.now().millisecondsSinceEpoch;
    return [
      TaskItem(
          id: base,
          subject: 'Математика',
          title: 'Домашнє завдання №15',
          description: 'Розв\'язати задачі з параграфа 7',
          deadline: '30 вер.',
          priority: 'Середній',
          priorityColorValue: 0xFFFFA000.toInt(),
          isDone: false),
      TaskItem(
          id: base + 1,
          subject: 'Фізика',
          title: 'Лабораторна робота',
          description: 'Підготувати звіт і вимірювання',
          deadline: '2 жовт.',
          priority: 'Високий',
          priorityColorValue: 0xFFFF5252.toInt(),
          isDone: false),
      TaskItem(
          id: base + 2,
          subject: 'Історія',
          title: 'Есе про Київську Русь',
          description: 'Написати 1000 слів',
          deadline: '5 жовт.',
          priority: 'Низький',
          priorityColorValue: 0xFF66BB6A.toInt(),
          isDone: true),
    ];
  }

  Future<void> refresh() async => loadTasks();

  Future<void> addTask(TaskItem t) async {
    _tasks.add(t);
    // persist locally
    await _save();
    // persist to Firestore if available
    try {
      if (firestoreRepo != null) {
        await firestoreRepo!.createTask(t);
      }
    } catch (_) {}

    notifyListeners();
  }

  Future<void> updateTask(TaskItem updated) async {
    final idx = _tasks.indexWhere((t) => t.id == updated.id);
    if (idx != -1) {
      _tasks[idx] = updated;
      await _save();
      try {
        if (firestoreRepo != null) await firestoreRepo!.updateTask(updated);
      } catch (_) {}
      notifyListeners();
    }
  }

  Future<void> deleteTask(int id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _save();
    try {
      if (firestoreRepo != null) await firestoreRepo!.deleteTask(id);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> toggleDone(int id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx != -1) {
      final t = _tasks[idx];
      final updated = t.copyWith(isDone: !t.isDone);
      _tasks[idx] = updated;
      await _save();
      try {
        if (firestoreRepo != null) await firestoreRepo!.updateTask(updated);
        // Notifications (mark read) are handled by NotificationProvider/UI
      } catch (_) {}
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _firestoreSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }
}
