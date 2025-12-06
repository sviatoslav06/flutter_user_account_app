class NotificationItem {
  final int id;
  final String title;
  final String message;
  final String type;
  final String tag;
  final int? colorValue;
  final String? deadline;
  final int? taskId;
  final DateTime createdAt;
  bool read;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.tag,
    this.colorValue,
    this.deadline,
    this.taskId,
    DateTime? createdAt,
    this.read = false,
  }) : createdAt = createdAt ?? DateTime.now();

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final dynamic idRaw = json['id'];
    int parsedId;
    if (idRaw is int) {
      parsedId = idRaw;
    } else if (idRaw is num) {
      parsedId = idRaw.toInt();
    } else if (idRaw is String) {
      parsedId = int.tryParse(idRaw) ?? 0;
    } else {
      parsedId = 0;
    }

    final createdRaw = json['createdAt'] as String?;
    DateTime parsedDate = DateTime.now();
    if (createdRaw != null) {
      try {
        parsedDate = DateTime.parse(createdRaw);
      } catch (_) {}
    }

    int? colorVal;
    final colorRaw = json['colorValue'];
    if (colorRaw is int) colorVal = colorRaw;
    if (colorRaw is String) colorVal = int.tryParse(colorRaw);

    return NotificationItem(
      id: parsedId,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? '',
      tag: json['tag'] as String? ?? '',
      colorValue: colorVal,
      deadline: json['deadline'] as String?,
      taskId: json['taskId'] is int
          ? json['taskId'] as int
          : (json['taskId'] is String ? int.tryParse(json['taskId']) : null),
      createdAt: parsedDate,
      read: json['read'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'type': type,
        'tag': tag,
        'colorValue': colorValue?.toString(),
        'deadline': deadline,
        'taskId': taskId,
        'createdAt': createdAt.toIso8601String(),
        'read': read,
      };
}
