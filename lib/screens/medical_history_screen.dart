import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class MedicalHistoryScreen extends StatefulWidget {
  final String patientId;
  final bool isDoctor;

  const MedicalHistoryScreen({super.key, required this.patientId, required this.isDoctor});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  final _allergiesCtrl = TextEditingController();
  final _chronicCtrl = TextEditingController();
  final _surgeriesCtrl = TextEditingController();
  final _medsCtrl = TextEditingController();
  final _consultingCtrl = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final data = await ApiService.getMedicalHistory(patientId: widget.patientId, token: auth.token!);
      setState(() {
        _allergiesCtrl.text = data['allergies'] ?? '';
        _chronicCtrl.text = data['chronic_conditions'] ?? '';
        _surgeriesCtrl.text = data['surgeries'] ?? '';
        _medsCtrl.text = data['medications'] ?? '';
        _consultingCtrl.text = data['consulting_summary'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      await ApiService.updateMedicalHistory(
        patientId: widget.patientId,
        token: auth.token!,
        body: {
          'allergies': _allergiesCtrl.text,
          'chronic_conditions': _chronicCtrl.text,
          'surgeries': _surgeriesCtrl.text,
          'medications': _medsCtrl.text,
          'consulting_summary': _consultingCtrl.text, // Fixed typo from 'counsulting'
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('History Saved!')));
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medical History'), backgroundColor: Colors.teal),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSection("Allergies 🤧", _allergiesCtrl),
                  _buildSection("Chronic Conditions 🏥", _chronicCtrl),
                  _buildSection("Surgeries 🔪", _surgeriesCtrl),
                  _buildSection("Past Medications 💊", _medsCtrl),
                  _buildSection("Consultation Summary 👨‍⚕️", _consultingCtrl),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: const EdgeInsets.all(16)),
                    child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Save History', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            maxLines: 3,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ],
      ),
    );
  }
}
