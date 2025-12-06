import 'package:flutter/material.dart';

class CreateTaskPage extends StatefulWidget {
  final Map<String, dynamic>? task;

  const CreateTaskPage({super.key, this.task});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String? _selectedSubject;
  String? _selectedPriority;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final List<String> subjects = [
    'Математика',
    'Фізика',
    'Історія',
    'Англійська мова',
  ];

  final List<Map<String, dynamic>> priorities = [
    {'label': 'Низький', 'color': Colors.green},
    {'label': 'Середній', 'color': Colors.amber},
    {'label': 'Високий', 'color': Colors.redAccent},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?['title'] ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?['description'] ?? '');
    _selectedSubject = widget.task?['subject'];
    _selectedPriority = widget.task?['priority'];
    _selectedDate = widget.task?['date'];
    _selectedTime = widget.task?['time'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final task = {
        'subject': _selectedSubject ?? 'Без предмету',
        'title': _titleController.text,
        'description': _descriptionController.text,
        'deadline': _selectedDate != null
            ? '${_selectedDate!.day}.${_selectedDate!.month}'
            : 'Без дати',
        'priority': _selectedPriority ?? 'Середній',
        'priorityColor': priorities.firstWhere(
            (p) => p['label'] == _selectedPriority,
            orElse: () => priorities[1])['color'] as Color,
      };
      Navigator.pop(context, task);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Редагувати завдання' : 'Створити завдання',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSubject,
                    decoration: const InputDecoration(labelText: 'Предмет'),
                    items: subjects
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedSubject = value),
                    validator: (value) =>
                        value == null ? 'Оберіть предмет' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _titleController,
                    decoration:
                        const InputDecoration(labelText: 'Назва завдання'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Введіть назву' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Опис'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_selectedDate != null
                              ? '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}'
                              : 'Дата дедлайну'),
                        ),
                      ),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: _pickTime,
                          icon: const Icon(Icons.access_time),
                          label: Text(_selectedTime != null
                              ? _selectedTime!.format(context)
                              : 'Час дедлайну'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedPriority,
                    decoration: const InputDecoration(labelText: 'Важливість'),
                    items: priorities
                        .map(
                          (p) => DropdownMenuItem<String>(
                            value: p['label'] as String,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: p['color'],
                                  radius: 6,
                                ),
                                const SizedBox(width: 8),
                                Text(p['label']),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedPriority = value),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Скасувати'),
                      ),
                      ElevatedButton(
                        onPressed: _saveTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(isEditing ? 'Оновити' : 'Створити'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
