import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/ui_utils.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  List<dynamic> _medications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    final auth = context.read<AuthProvider>();
    try {
      final data = await ApiService.getMedications(patientId: auth.userId!, token: auth.token!);
      setState(() { _medications = data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _addMedication() async {
    final nameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String frequency = '1x daily';
    List<String> times = ['08:00'];

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('Add Medication', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Medicine Name',
                  hintText: 'e.g. Folic Acid',
                  prefixIcon: const Icon(Icons.medication),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dosageCtrl,
                decoration: InputDecoration(
                  labelText: 'Dosage',
                  hintText: 'e.g. 500mg',
                  prefixIcon: const Icon(Icons.science),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: frequency,
                items: const [
                  DropdownMenuItem(value: '1x daily', child: Text('Once daily')),
                  DropdownMenuItem(value: '2x daily', child: Text('Twice daily')),
                  DropdownMenuItem(value: '3x daily', child: Text('Three times daily')),
                ],
                onChanged: (v) {
                  setModalState(() {
                    frequency = v!;
                    if (v == '1x daily') times = ['08:00'];
                    if (v == '2x daily') times = ['08:00', '20:00'];
                    if (v == '3x daily') times = ['08:00', '14:00', '20:00'];
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Frequency',
                  prefixIcon: const Icon(Icons.schedule),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(spacing: 8, children: times.map((t) => Chip(
                avatar: const Icon(Icons.access_time, size: 16),
                label: Text(t),
                backgroundColor: const Color(0xFFE91E8C).withValues(alpha: 0.1),
              )).toList()),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  hintText: 'e.g. Take after food',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty) Navigator.pop(ctx, true);
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Add Medication', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C4DFF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );

    if (result == true) {
      final auth = context.read<AuthProvider>();
      try {
        await ApiService.createMedication(
          body: {
            'patient_id': auth.userId,
            'name': nameCtrl.text,
            'dosage': dosageCtrl.text,
            'frequency': frequency,
            'times': times,
            'notes': notesCtrl.text,
          },
          token: auth.token!,
        );
        if (mounted) UiUtils.showSuccess(context, 'Medication added!');
        _loadMedications();
      } catch (e) {
        if (mounted) UiUtils.showError(context, e.toString());
      }
    }
  }

  final _pillColors = [
    const Color(0xFF7C4DFF),
    const Color(0xFFE91E8C),
    const Color(0xFF00BCD4),
    const Color(0xFFFF9800),
    const Color(0xFF4CAF50),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medications')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMedication,
        backgroundColor: const Color(0xFF7C4DFF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _medications.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.medication, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text('No medications', style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
                  const SizedBox(height: 4),
                  Text('Add your prescribed medications', style: TextStyle(color: Colors.grey.shade400)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _medications.length,
                  itemBuilder: (_, i) {
                    final m = _medications[i];
                    final color = _pillColors[i % _pillColors.length];
                    final times = (m['times'] as List?)?.cast<String>() ?? [];
                    return Dismissible(
                      key: Key(m['id']),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        final auth = context.read<AuthProvider>();
                        await ApiService.deleteMedication(medId: m['id'], token: auth.token!);
                        setState(() => _medications.removeAt(i));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: color.withValues(alpha: 0.2)),
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                              child: Icon(Icons.medication, color: color, size: 26),
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(m['name'] ?? '', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: color)),
                              if (m['dosage'] != null) Text(m['dosage'], style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                            ])),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                              child: Text(m['frequency'] ?? '', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
                            ),
                          ]),
                          if (times.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(spacing: 8, children: times.map((t) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.access_time, size: 14, color: color),
                                const SizedBox(width: 4),
                                Text(t, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
                              ]),
                            )).toList()),
                          ],
                          if (m['notes'] != null && m['notes'].toString().isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text('💡 ${m['notes']}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                          ],
                        ]),
                      ),
                    );
                  },
                ),
    );
  }
}
