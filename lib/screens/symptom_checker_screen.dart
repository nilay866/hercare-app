import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  final _symptomCtrl = TextEditingController();
  bool _isChecking = false;
  Map<String, dynamic>? _result;

  Future<void> _checkSymptoms() async {
    if (_symptomCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please describe your symptoms')));
      return;
    }

    setState(() { _isChecking = true; _result = null; });

    try {
      final token = context.read<AuthProvider>().token!;
      final resp = await ApiService.checkSymptoms(symptoms: _symptomCtrl.text.trim(), token: token);
      if (mounted) setState(() => _result = resp);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Symptom Checker')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Card(
            color: Colors.deepPurple.shade50,
            child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.deepPurple.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.health_and_safety, color: Colors.deepPurple, size: 28)),
              const SizedBox(width: 14),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('AI Health Analysis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.deepPurple)),
                SizedBox(height: 4),
                Text('Describe your symptoms and get instant insights', style: TextStyle(fontSize: 13, color: Colors.deepPurple)),
              ])),
            ])),
          ),
          const SizedBox(height: 20),

          // Input
          Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [Icon(Icons.edit_note, color: Color(0xFFE91E8C)), SizedBox(width: 8), Text('Your Symptoms', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))]),
            const SizedBox(height: 12),
            TextField(
              controller: _symptomCtrl, maxLines: 4,
              decoration: const InputDecoration(hintText: 'e.g. headache, nausea, lower back pain, fatigue, irregular periods...'),
            ),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: _isChecking ? null : _checkSymptoms,
              icon: _isChecking ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.search),
              label: Text(_isChecking ? 'Analyzing...' : 'Check Symptoms'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            )),
          ]))),

          // Results
          if (_result != null) ...[
            const SizedBox(height: 20),

            // Severity
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _severityColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.warning_amber, color: _severityColor, size: 24)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Severity', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text(_result!['severity'] ?? 'Unknown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _severityColor)),
              ]),
            ]))),
            const SizedBox(height: 12),

            // Possible causes
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [Icon(Icons.list_alt, color: Color(0xFF7C4DFF)), SizedBox(width: 8), Text('Possible Causes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))]),
              const Divider(height: 20),
              ...(_result!['causes'] as List? ?? []).map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('• ', style: TextStyle(fontSize: 16, color: Color(0xFF7C4DFF))),
                  Expanded(child: Text(c.toString(), style: const TextStyle(fontSize: 14))),
                ]),
              )),
            ]))),
            const SizedBox(height: 12),

            // Recommendations
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [Icon(Icons.tips_and_updates, color: Colors.teal), SizedBox(width: 8), Text('Recommendations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))]),
              const Divider(height: 20),
              ...(_result!['recommendations'] as List? ?? []).map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('✅ ', style: TextStyle(fontSize: 14)),
                  Expanded(child: Text(r.toString(), style: const TextStyle(fontSize: 14))),
                ]),
              )),
            ]))),
            const SizedBox(height: 12),

            // Disclaimer
            Card(
              color: Colors.amber.shade50,
              child: const Padding(padding: EdgeInsets.all(16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.info_outline, color: Colors.amber, size: 20),
                SizedBox(width: 10),
                Expanded(child: Text(
                  '⚠️ Disclaimer: This is an AI-powered analysis for informational purposes only. It is NOT a medical diagnosis. Always consult a qualified healthcare professional for proper medical advice.',
                  style: TextStyle(fontSize: 12, color: Colors.brown, height: 1.4),
                )),
              ])),
            ),
          ],
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Color get _severityColor {
    final s = (_result?['severity'] ?? '').toString().toLowerCase();
    if (s.contains('low') || s.contains('mild')) return Colors.green;
    if (s.contains('moderate') || s.contains('medium')) return Colors.orange;
    return Colors.red;
  }
}
