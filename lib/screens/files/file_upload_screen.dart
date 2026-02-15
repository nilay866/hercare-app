import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../providers/file_upload_provider.dart';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({Key? key}) : super(key: key);

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  late TextEditingController _fileNameController;
  String _selectedResourceType = 'medical_report';
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  final List<String> _resourceTypes = [
    'medical_report',
    'prescription',
    'lab_report',
    'imaging',
    'vaccination',
    'allergy',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _fileNameController = TextEditingController();
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      type: FileType.custom,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      _uploadFile(file);
    }
  }

  void _uploadFile(PlatformFile file) async {
    if (_fileNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a file name')),
      );
      return;
    }

    setState(() => _isUploading = true);

    final provider = context.read<FileUploadProvider>();
    final result = await provider.uploadFile(
      file: file,
      resourceType: _selectedResourceType,
      fileName: _fileNameController.text,
    );

    setState(() => _isUploading = false);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File uploaded successfully')),
      );
      _fileNameController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Failed to upload file')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Medical File'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File Type Selection
            const Text(
              'File Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: DropdownButton<String>(
                  value: _selectedResourceType,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _resourceTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(
                              type.replaceAll('_', ' ').toUpperCase(),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedResourceType = value!);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // File Name
            const Text(
              'File Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _fileNameController,
              decoration: InputDecoration(
                hintText: 'e.g., Blood Test Report April 2024',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 32),

            // Upload Area
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue[200]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue[50],
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 64,
                    color: Colors.blue[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ready to upload medical files',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'PDF, Images, Word documents',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isUploading ? null : _pickAndUploadFile,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Choose File'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Upload progress
            if (_isUploading) ...[
              const SizedBox(height: 24),
              const Text('Uploading...'),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _uploadProgress,
                  minHeight: 8,
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your medical files are securely stored and encrypted. Only you and your healthcare providers can access them.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
