class TaskItem {
  final int id;
  String subject;
  String title;
  String? description;
  String? deadline;
  String? priority;
  int? priorityColorValue;
  bool isDone;

  TaskItem({
    required this.id,
    this.subject = '',
    required this.title,
    this.description,
    this.deadline,
    this.priority,
    this.priorityColorValue,
    this.isDone = false,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
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

    final dynamic isDoneRaw = json['isDone'];
    bool parsedDone = false;
    if (isDoneRaw is bool) {
      parsedDone = isDoneRaw;
    } else if (isDoneRaw is num) {
      parsedDone = isDoneRaw != 0;
    } else if (isDoneRaw is String) {
      parsedDone = isDoneRaw.toLowerCase() == 'true';
    }

    int? colorVal;
    final dynamic colorRaw = json['priorityColor'];
    if (colorRaw is int) colorVal = colorRaw;
    if (colorRaw is String) colorVal = int.tryParse(colorRaw);

    return TaskItem(
      id: parsedId,
      subject: json['subject'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      deadline: json['deadline'] as String?,
      priority: json['priority'] as String?,
      priorityColorValue: colorVal,
      isDone: parsedDone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'title': title,
      'description': description,
      'deadline': deadline,
      'priority': priority,
      'priorityColor': priorityColorValue?.toString(),
      'isDone': isDone,
    };
  }

  TaskItem copyWith({
    int? id,
    String? subject,
    String? title,
    String? description,
    String? deadline,
    String? priority,
    int? priorityColorValue,
    bool? isDone,
  }) {
    return TaskItem(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      priorityColorValue: priorityColorValue ?? this.priorityColorValue,
      isDone: isDone ?? this.isDone,
    );
  }
}
