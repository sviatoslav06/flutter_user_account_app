import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/notification_item.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;
  NotificationRepository([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _notifsRef => _firestore.collection('notifications');

  Stream<List<NotificationItem>> watchForUser(String userId) {
    return _notifsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => NotificationItem.fromJson(
                Map<String, dynamic>.from(d.data() as Map)))
            .toList());
  }

  Future<List<NotificationItem>> fetchOnce(String userId) async {
    final snap = await _notifsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => NotificationItem.fromJson(
            Map<String, dynamic>.from(d.data() as Map)))
        .toList();
  }

  Future<void> create(NotificationItem n) async {
    final data = n.toJson();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) data['userId'] = uid;
    await _notifsRef.add(data);
  }

  Future<void> deleteById(int id) async {
    final snap = await _notifsRef.where('id', isEqualTo: id).get();
    for (final d in snap.docs) await d.reference.delete();
  }

  Future<void> deleteByTaskId(int taskId) async {
    final snap = await _notifsRef.where('taskId', isEqualTo: taskId).get();
    for (final d in snap.docs) await d.reference.delete();
  }

  Future<void> markRead(int id, {bool read = true}) async {
    final snap = await _notifsRef.where('id', isEqualTo: id).get();
    for (final d in snap.docs) await d.reference.update({'read': read});
  }

  Future<void> markReadByTaskId(int taskId, {bool read = true}) async {
    final snap = await _notifsRef.where('taskId', isEqualTo: taskId).get();
    for (final d in snap.docs) await d.reference.update({'read': read});
  }
}
