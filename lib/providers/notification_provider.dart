import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/notification_item.dart';
import '../models/task_item.dart';
import '../repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  static const _basePrefsKey = 'notifications_v1';
  String? _prefsKey;

  final NotificationRepository? firestoreRepo;
  Stream<List<NotificationItem>>? _stream;
  StreamSubscription<List<NotificationItem>>? _sub;
  StreamSubscription<User?>? _authSub;

  List<NotificationItem> _items = [];
  bool _loading = false;

  NotificationProvider({this.firestoreRepo}) {
    // react to auth changes so notifications are scoped per-user
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
    _onAuthChanged(FirebaseAuth.instance.currentUser);
  }

  Future<void> _onAuthChanged(User? user) async {
    await _sub?.cancel();
    _sub = null;
    final newPrefsKey =
        user != null ? '$_basePrefsKey\_${user.uid}' : _basePrefsKey;

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
    // clear in-memory notifications immediately to avoid showing previous user's items
    _items = [];
    notifyListeners();

    await _load();
    _startListenerIfNeeded();
  }

  Future<void> load() async => _load();

  List<NotificationItem> get items => List.unmodifiable(_items);
  bool get loading => _loading;

  Future<void> _load() async {
    _loading = true;
    notifyListeners();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (firestoreRepo != null && user != null) {
        try {
          _items = await firestoreRepo!.fetchOnce(user.uid);
          await _save();
        } catch (e) {
          final prefs = await SharedPreferences.getInstance();
          final key = _prefsKey ?? _basePrefsKey;
          final raw = prefs.getString(key);
          if (raw != null && raw.isNotEmpty) {
            final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
            _items = decoded
                .map((e) =>
                    NotificationItem.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          } else {
            _items = [];
          }
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        final key = _prefsKey ?? _basePrefsKey;
        final raw = prefs.getString(key);
        if (raw != null && raw.isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
          _items = decoded
              .map((e) =>
                  NotificationItem.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else {
          _items = [];
        }
      }
    } catch (e) {
      _items = [];
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_items.map((e) => e.toJson()).toList());
    try {
      final key = _prefsKey ?? _basePrefsKey;
      await prefs.setString(key, encoded);
    } catch (_) {}
  }

  void _startListenerIfNeeded() {
    final user = FirebaseAuth.instance.currentUser;
    if (firestoreRepo != null && user != null) {
      _stream = firestoreRepo!.watchForUser(user.uid);
      _sub = _stream!.listen((list) async {
        _items = list;
        await _save();
        notifyListeners();
      });
    }
  }

  Future<void> addNotification(NotificationItem n) async {
    _items.insert(0, n);
    await _save();
    try {
      if (firestoreRepo != null) await firestoreRepo!.create(n);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> addFromTask(TaskItem t, {String type = 'Дедлайн'}) async {
    final id = DateTime.now().millisecondsSinceEpoch;
    final tag = type;
    final title = (t.title.isNotEmpty) ? t.title : 'Нове завдання';
    final message = (t.description?.isNotEmpty == true)
        ? t.description!
        : (t.deadline ?? 'Без опису');
    final colorVal = t.priorityColorValue;
    final n = NotificationItem(
      id: id,
      title: title,
      message: message,
      type: type,
      tag: tag,
      colorValue: colorVal,
      deadline: t.deadline,
      taskId: t.id,
    );

    await addNotification(n);
  }

  Future<void> markRead(int id) async {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx != -1) {
      _items[idx].read = true;
      await _save();
      try {
        if (firestoreRepo != null)
          await firestoreRepo!.markRead(id, read: true);
      } catch (_) {}
      notifyListeners();
    }
  }

  Future<void> remove(int id) async {
    _items.removeWhere((i) => i.id == id);
    await _save();
    try {
      if (firestoreRepo != null) await firestoreRepo!.deleteById(id);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> removeByTaskId(int taskId) async {
    _items.removeWhere((i) => i.taskId == taskId);
    await _save();
    try {
      if (firestoreRepo != null) await firestoreRepo!.deleteByTaskId(taskId);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> markReadByTaskId(int taskId, {bool read = true}) async {
    var changed = false;
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].taskId == taskId) {
        _items[i].read = read;
        changed = true;
      }
    }
    if (changed) {
      await _save();
      try {
        if (firestoreRepo != null)
          await firestoreRepo!.markReadByTaskId(taskId, read: read);
      } catch (_) {}
      notifyListeners();
    }
  }

  Future<void> clearAll() async {
    _items.clear();
    await _save();
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }
}
