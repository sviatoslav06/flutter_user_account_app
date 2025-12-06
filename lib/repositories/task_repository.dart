import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task_item.dart';

class TaskRepository {
  final FirebaseFirestore _firestore;
  TaskRepository([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _tasksRef => _firestore.collection('tasks');

  Stream<List<TaskItem>> watchTasksForUser(String userId) {
    return _tasksRef
        .where('userId', isEqualTo: userId)
        .orderBy('deadline')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                TaskItem.fromJson(Map<String, dynamic>.from(d.data() as Map)))
            .toList());
  }

  Future<List<TaskItem>> fetchTasksOnce(String userId) async {
    final snap = await _tasksRef
        .where('userId', isEqualTo: userId)
        .orderBy('deadline')
        .get();
    return snap.docs
        .map((d) =>
            TaskItem.fromJson(Map<String, dynamic>.from(d.data() as Map)))
        .toList();
  }

  Future<void> createTask(TaskItem t) async {
    final data = t.toJson();
    // attach current user id if available
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) data['userId'] = uid;
    await _tasksRef.add(data);
  }

  Future<void> updateTask(TaskItem t) async {
    final snapshot =
        await _tasksRef.where('id', isEqualTo: t.id).limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      await doc.reference.update(t.toJson());
    }
  }

  Future<void> deleteTask(int id) async {
    final snapshot = await _tasksRef.where('id', isEqualTo: id).get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
