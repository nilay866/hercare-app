import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/health_log_provider.dart';
import '../utils/ui_utils.dart';

class AddHealthLogScreen extends StatefulWidget {
  const AddHealthLogScreen({super.key});

  @override
  State<AddHealthLogScreen> createState() => _AddHealthLogScreenState();
}

class _AddHealthLogScreenState extends State<AddHealthLogScreen> {
  String _logType = 'period';
  double _painLevel = 1;
  String _bleedingLevel = 'light';
  final _moodCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      await context.read<HealthLogProvider>().addLog({
        'user_id': auth.userId,
        'log_type': _logType,
        'pain_level': _painLevel.toInt(),
        'bleeding_level': _bleedingLevel,
        'mood': _moodCtrl.text.trim().isEmpty ? 'neutral' : _moodCtrl.text.trim(),
        'notes': _notesCtrl.text.trim().isEmpty ? 'No notes' : _notesCtrl.text.trim(),
      }, auth.token!);

      if (mounted) {
        UiUtils.showSnackBar(context, '✅ Health log saved!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) UiUtils.showError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Health Log')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _card('Log Type', Icons.category, const Color(0xFFE91E8C), DropdownButtonFormField<String>(
          initialValue: _logType,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.category_outlined)),
          items: const [
            DropdownMenuItem(value: 'period', child: Text('🔴 Period')),
            DropdownMenuItem(value: 'pregnancy', child: Text('🤰 Pregnancy')),
            DropdownMenuItem(value: 'symptom', child: Text('🤒 Symptom')),
            DropdownMenuItem(value: 'medication', child: Text('💊 Medication')),
            DropdownMenuItem(value: 'checkup', child: Text('🩺 Checkup')),
          ],
          onChanged: (v) => setState(() => _logType = v!),
        )),
        const SizedBox(height: 16),

        _card('Pain Level', Icons.healing, _painColor, Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: _painColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Text('${_painLevel.toInt()}/10', style: TextStyle(fontWeight: FontWeight.bold, color: _painColor))),
          ]),
          Slider(value: _painLevel, min: 1, max: 10, divisions: 9, activeColor: _painColor, label: '${_painLevel.toInt()}', onChanged: (v) => setState(() => _painLevel = v)),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Mild', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)), Text('Severe', style: TextStyle(color: Colors.grey.shade500, fontSize: 12))]),
        ])),
        const SizedBox(height: 16),

        _card('Bleeding Level', Icons.water_drop, const Color(0xFFE91E8C), DropdownButtonFormField<String>(
          initialValue: _bleedingLevel,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.water_drop_outlined)),
          items: const [DropdownMenuItem(value: 'light', child: Text('🟢 Light')), DropdownMenuItem(value: 'medium', child: Text('🟡 Medium')), DropdownMenuItem(value: 'heavy', child: Text('🔴 Heavy'))],
          onChanged: (v) => setState(() => _bleedingLevel = v!),
        )),
        const SizedBox(height: 16),

        _card('Mood', Icons.mood, const Color(0xFF7C4DFF), TextField(controller: _moodCtrl, decoration: const InputDecoration(hintText: 'happy, anxious, tired...'))),
        const SizedBox(height: 16),

        _card('Notes', Icons.notes, Colors.teal, TextField(controller: _notesCtrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Additional notes...'))),
        const SizedBox(height: 24),

        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _submit,
          icon: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save),
          label: Text(_isLoading ? 'Saving...' : 'Save Health Log'),
        )),
        const SizedBox(height: 24),
      ])),
    );
  }

  Widget _card(String label, IconData icon, Color color, Widget child) {
    return Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: color), const SizedBox(width: 8), Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))]),
      const SizedBox(height: 12), child,
    ])));
  }

  Color get _painColor { if (_painLevel <= 3) return Colors.green; if (_painLevel <= 6) return Colors.orange; return Colors.red; }
}
