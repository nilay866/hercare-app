import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/ui_utils.dart';

class MedicalReportsScreen extends StatefulWidget {
  const MedicalReportsScreen({super.key});

  @override
  State<MedicalReportsScreen> createState() => _MedicalReportsScreenState();
}

class _MedicalReportsScreenState extends State<MedicalReportsScreen> {
  List<dynamic> _reports = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final auth = context.read<AuthProvider>();
    try {
      final data = await ApiService.getReports(patientId: auth.userId!, token: auth.token!);
      setState(() { _reports = data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _addReport() async {
    final titleCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String reportType = 'other';

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Upload Report', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: 'Report Title',
                hintText: 'e.g. Blood Test - Feb 2026',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: reportType,
              items: const [
                DropdownMenuItem(value: 'blood_test', child: Text('🩸 Blood Test')),
                DropdownMenuItem(value: 'ultrasound', child: Text('📷 Ultrasound')),
                DropdownMenuItem(value: 'prescription', child: Text('💊 Prescription')),
                DropdownMenuItem(value: 'other', child: Text('📋 Other')),
              ],
              onChanged: (v) => setModalState(() => reportType = v!),
              decoration: InputDecoration(
                labelText: 'Report Type',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notes',
                hintText: 'Add any notes or observations...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty) Navigator.pop(ctx, true);
                },
                icon: const Icon(Icons.upload, color: Colors.white),
                label: const Text('Save Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E8C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );

    if (result == true) {
      final auth = context.read<AuthProvider>();
      try {
        await ApiService.createReport(
          body: {
            'patient_id': auth.userId,
            'uploaded_by': auth.userId,
            'title': titleCtrl.text,
            'report_type': reportType,
            'notes': notesCtrl.text,
          },
          token: auth.token!,
        );
        if (mounted) UiUtils.showSuccess(context, 'Report uploaded!');
        _loadReports();
      } catch (e) {
        if (mounted) UiUtils.showError(context, e.toString());
      }
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'blood_test': return Icons.bloodtype;
      case 'ultrasound': return Icons.camera_alt;
      case 'prescription': return Icons.medication;
      default: return Icons.description;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'blood_test': return const Color(0xFFE53935);
      case 'ultrasound': return const Color(0xFF7C4DFF);
      case 'prescription': return const Color(0xFF00BCD4);
      default: return const Color(0xFFFF9800);
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'blood_test': return 'Blood Test';
      case 'ultrasound': return 'Ultrasound';
      case 'prescription': return 'Prescription';
      default: return 'Report';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Medical Reports')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addReport,
        backgroundColor: const Color(0xFFE91E8C),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Upload', style: TextStyle(color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text('No reports yet', style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
                  const SizedBox(height: 4),
                  Text('Upload your first medical report', style: TextStyle(color: Colors.grey.shade400)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reports.length,
                  itemBuilder: (_, i) {
                    final r = _reports[i];
                    final color = _typeColor(r['report_type'] ?? 'other');
                    return Dismissible(
                      key: Key(r['id']),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        final auth = context.read<AuthProvider>();
                        await ApiService.deleteReport(reportId: r['id'], token: auth.token!);
                        setState(() => _reports.removeAt(i));
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(_typeIcon(r['report_type'] ?? 'other'), color: color, size: 26),
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(r['title'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Row(children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                  child: Text(_typeLabel(r['report_type'] ?? 'other'),
                                      style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
                                ),
                                const SizedBox(width: 8),
                                Text(r['created_at']?.toString().substring(0, 10) ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                              ]),
                              if (r['notes'] != null && r['notes'].toString().isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(r['notes'], maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                              ],
                            ])),
                          ]),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
