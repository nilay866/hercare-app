import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/phase2_models.dart';
import '../services/file_upload_service.dart';

class FileUploadProvider extends ChangeNotifier {
  final FileUploadService _service = FileUploadService();

  List<MedicalFile> _files = [];
  List<MedicalFile> _sharedFiles = [];
  bool _isLoading = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _error;

  // Getters
  List<MedicalFile> get files => _files;
  List<MedicalFile> get sharedFiles => _sharedFiles;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get error => _error;

  // Get files by type
  List<MedicalFile> getFilesByType(String resourceType) {
    return _files.where((f) => f.resourceType == resourceType).toList();
  }

  // Load my files
  Future<void> loadFiles({String? resourceType}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _files = await _service.getMyFiles(resourceType: resourceType);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload file
  Future<MedicalFile?> uploadFile({
    required PlatformFile file,
    required String resourceType,
    String? resourceId,
    String? fileName,
  }) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    _error = null;
    notifyListeners();

    try {
      final uploadedFile = await _service.uploadFile(
        file: file,
        resourceType: resourceType,
        resourceId: resourceId,
        fileName: fileName,
      );
      
      _files.add(uploadedFile);
      _uploadProgress = 1.0;
      _error = null;
      return uploadedFile;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  // Delete file
  Future<bool> deleteFile(String fileId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteFile(fileId);
      _files.removeWhere((f) => f.id == fileId);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get download URL
  Future<String?> getDownloadUrl(String fileId) async {
    try {
      return await _service.getDownloadUrl(fileId);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  // Share file
  Future<bool> shareFile(String fileId, {List<String>? userIds}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final shared = await _service.shareFile(fileId, userIds: userIds);
      
      final index = _files.indexWhere((f) => f.id == fileId);
      if (index >= 0) {
        _files[index] = shared;
      }
      
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load shared with me
  Future<void> loadSharedFiles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sharedFiles = await _service.getSharedWithMe();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
