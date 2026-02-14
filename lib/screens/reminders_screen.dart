import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Map<String, dynamic>> _reminders = [];
  late Box _box;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    _box = await Hive.openBox('reminders');
    final data = _box.get('list');
    if (data != null) {
      _reminders = (data as List).map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      // Default reminders
      _reminders = [
        {'type': 'period', 'title': 'Period Reminder', 'subtitle': 'Track your cycle start', 'icon': 'water_drop', 'time': '09:00 AM', 'enabled': false},
        {'type': 'medication', 'title': 'Medication Reminder', 'subtitle': 'Take your daily medication', 'icon': 'medication', 'time': '08:00 AM', 'enabled': false},
        {'type': 'appointment', 'title': 'Appointment Reminder', 'subtitle': 'Upcoming doctor visit', 'icon': 'calendar_month', 'time': '10:00 AM', 'enabled': false},
        {'type': 'water', 'title': 'Water Intake', 'subtitle': 'Stay hydrated throughout the day', 'icon': 'local_drink', 'time': '07:00 AM', 'enabled': false},
      ];
    }
    setState(() {});
  }

  Future<void> _saveReminders() async {
    await _box.put('list', _reminders);
  }

  void _toggleReminder(int index) {
    setState(() => _reminders[index]['enabled'] = !_reminders[index]['enabled']);
    _saveReminders();
  }

  void _editTime(int index) async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) {
      setState(() => _reminders[index]['time'] = time.format(context));
      _saveReminders();
    }
  }

  void _addCustomReminder() {
    final titleCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Add Reminder'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Prenatal vitamins')),
        const SizedBox(height: 12),
        TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'Note', hintText: 'e.g. Take after breakfast')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          if (titleCtrl.text.isNotEmpty) {
            setState(() => _reminders.add({
              'type': 'custom', 'title': titleCtrl.text,
              'subtitle': noteCtrl.text.isEmpty ? 'Custom reminder' : noteCtrl.text,
              'icon': 'notifications', 'time': '09:00 AM', 'enabled': true,
            }));
            _saveReminders();
          }
          Navigator.pop(ctx);
        }, child: const Text('Add')),
      ],
    ));
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'water_drop': return Icons.water_drop;
      case 'medication': return Icons.medication;
      case 'calendar_month': return Icons.calendar_month;
      case 'local_drink': return Icons.local_drink;
      default: return Icons.notifications;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'period': return const Color(0xFFE91E8C);
      case 'medication': return const Color(0xFF7C4DFF);
      case 'appointment': return Colors.teal;
      case 'water': return Colors.blue;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCustomReminder,
        backgroundColor: const Color(0xFFE91E8C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _reminders.isEmpty
          ? const Center(child: Text('No reminders yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reminders.length,
              itemBuilder: (_, i) {
                final r = _reminders[i];
                final color = _getColor(r['type']);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(_getIcon(r['icon']), color: color, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(r['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(r['subtitle'], style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _editTime(i),
                          child: Row(children: [
                            Icon(Icons.access_time, size: 14, color: color),
                            const SizedBox(width: 4),
                            Text(r['time'], style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
                            const SizedBox(width: 4),
                            Icon(Icons.edit, size: 12, color: color),
                          ]),
                        ),
                      ])),
                      Switch(value: r['enabled'], activeColor: color, onChanged: (_) => _toggleReminder(i)),
                    ]),
                  ),
                );
              },
            ),
    );
  }
}
