import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class ReportUploadScreen extends StatefulWidget {
  final String patientId;

  const ReportUploadScreen({super.key, required this.patientId});

  @override
  State<ReportUploadScreen> createState() => _ReportUploadScreenState();
}

class _ReportUploadScreenState extends State<ReportUploadScreen> {
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _reportType = 'other';
  PlatformFile? _pickedFile;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true, // Needed for web and small files
    );

    if (result != null) {
      setState(() => _pickedFile = result.files.first);
    }
  }

  Future<void> _upload() async {
    if (_titleCtrl.text.isEmpty || _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter title and pick a file')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      
      String? base64String;
      if (_pickedFile!.bytes != null) {
        base64String = base64Encode(_pickedFile!.bytes!);
      } else if (_pickedFile!.path != null) {
        final bytes = await File(_pickedFile!.path!).readAsBytes();
        base64String = base64Encode(bytes);
      }

      await ApiService.createReport(
        token: auth.token!,
        body: {
          'patient_id': widget.patientId,
          'uploaded_by': auth.userId,
          'title': _titleCtrl.text,
          'report_type': _reportType,
          'notes': _notesCtrl.text,
          'file_name': _pickedFile!.name,
          'file_data': base64String, // The backend expects this
        },
      );

      if (mounted) {
        PlatformFile? file = _pickedFile;
        // The context is still valid here.
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Report "${file?.name}" uploaded!')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Medical Report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Report Title', hintText: 'e.g. Blood Test, Ultrasound')),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _reportType,
              decoration: const InputDecoration(labelText: 'Type'),
              items: const [
                DropdownMenuItem(value: 'blood_test', child: Text('Blood Test 🩸')),
                DropdownMenuItem(value: 'ultrasound', child: Text('Ultrasound 📷')),
                DropdownMenuItem(value: 'prescription', child: Text('Prescription 💊')),
                DropdownMenuItem(value: 'other', child: Text('Other 📄')),
              ],
              onChanged: (v) => setState(() => _reportType = v!),
            ),
            const SizedBox(height: 16),
            TextField(controller: _notesCtrl, decoration: const InputDecoration(labelText: 'Notes'), maxLines: 3),
            const SizedBox(height: 24),
            
            // File Picker
            InkWell(
              onTap: _pickFile,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.upload_file, size: 32, color: Colors.teal),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _pickedFile != null ? _pickedFile!.name : 'Tap to select generic file (JPG, PNG, PDF)',
                        style: TextStyle(color: _pickedFile != null ? Colors.black : Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _upload,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Upload Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
