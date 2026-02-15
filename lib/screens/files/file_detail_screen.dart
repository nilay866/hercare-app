import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/phase2_models.dart';
import '../../../providers/file_upload_provider.dart';

class FileDetailScreen extends StatefulWidget {
  final MedicalFile file;

  const FileDetailScreen({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  State<FileDetailScreen> createState() => _FileDetailScreenState();
}

class _FileDetailScreenState extends State<FileDetailScreen> {
  late MedicalFile _file;

  @override
  void initState() {
    super.initState();
    _file = widget.file;
  }

  void _downloadFile(BuildContext context, FileUploadProvider provider) async {
    final url = await provider.getDownloadUrl(_file.id);
    if (url != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download started')),
      );
      // TODO: Implement actual download using url_launcher or similar
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Failed to get download link')),
      );
    }
  }

  void _shareFile(BuildContext context, FileUploadProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share File'),
        content: const Text('Share with doctor or healthcare provider'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.shareFile(_file.id).then((success) {
                if (success) {
                  setState(() {
                    _file = _file.copyWith(
                      sharedWith: [..._file.sharedWith, 'doctor@example.com'],
                    );
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('File shared')),
                  );
                }
              });
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _deleteFile(BuildContext context, FileUploadProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: const Text('Are you sure you want to delete this file?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deleteFile(_file.id).then((success) {
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('File deleted')),
                  );
                }
              });
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('File Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // File preview/icon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              color: Colors.blue[50],
              child: Column(
                children: [
                  Icon(
                    _getFileIcon(_file.fileType),
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _file.fileName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _file.fileType.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // File information
                  _buildDetailCard(
                    title: 'File Type',
                    value: _file.resourceType.replaceAll('_', ' ').toUpperCase(),
                    icon: Icons.category,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailCard(
                    title: 'Uploaded',
                    value: dateFormat.format(_file.uploadedAt),
                    icon: Icons.calendar_today,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailCard(
                    title: 'File Size',
                    value: '2.4 MB', // TODO: Get actual file size from backend
                    icon: Icons.storage,
                  ),

                  // Shared information
                  if (_file.sharedWith.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Shared With',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(
                      _file.sharedWith.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.person,
                                color: Colors.blue,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(_file.sharedWith[index]),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Security notice
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This file is encrypted and securely stored.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.green[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Consumer<FileUploadProvider>(
                    builder: (context, provider, _) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: provider.isLoading
                              ? null
                              : () => _downloadFile(context, provider),
                          icon: const Icon(Icons.download),
                          label: const Text('Download File'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Consumer<FileUploadProvider>(
                    builder: (context, provider, _) {
                      return SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: provider.isLoading
                              ? null
                              : () => _shareFile(context, provider),
                          icon: const Icon(Icons.share),
                          label: const Text('Share File'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Consumer<FileUploadProvider>(
                    builder: (context, provider, _) {
                      return SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: provider.isLoading
                              ? null
                              : () => _deleteFile(context, provider),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text(
                            'Delete File',
                            style: TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }
}
