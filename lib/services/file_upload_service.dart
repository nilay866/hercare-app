import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/phase2_models.dart';

class FileUploadService {
  static const String baseUrl = 'http://localhost:8000';
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<List<MedicalFile>> getMyFiles({
    String? resourceType,
  }) async {
    try {
      final token = await _getToken();
      String url = '$baseUrl/files';
      if (resourceType != null) {
        url += '?resource_type=$resourceType';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<MedicalFile> files = (data['files'] as List)
            .map((f) => MedicalFile.fromJson(f))
            .toList();
        return files;
      } else {
        throw Exception('Failed to load files');
      }
    } catch (e) {
      print('Error getting files: $e');
      rethrow;
    }
  }

  Future<MedicalFile> uploadFile({
    required PlatformFile file,
    required String resourceType,
    String? resourceId,
    String? fileName,
  }) async {
    try {
      final token = await _getToken();
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/files/upload'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['resource_type'] = resourceType;
      if (resourceId != null) {
        request.fields['resource_id'] = resourceId;
      }

      request.files.add(
        http.MultipartFile(
          'file',
          file.readStream!,
          file.size,
          filename: fileName ?? file.name,
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        return MedicalFile.fromJson(data);
      } else {
        throw Exception('Failed to upload file');
      }
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  Future<void> deleteFile(String fileId) async {
    try {
      final token = await _getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/files/$fileId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete file');
      }
    } catch (e) {
      print('Error deleting file: $e');
      rethrow;
    }
  }

  Future<String> getDownloadUrl(String fileId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/files/$fileId/download-url'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['download_url'];
      } else {
        throw Exception('Failed to get download URL');
      }
    } catch (e) {
      print('Error getting download URL: $e');
      rethrow;
    }
  }

  Future<MedicalFile> shareFile(String fileId, {List<String>? userIds}) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/files/$fileId/share'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          if (userIds != null) 'user_ids': userIds,
          'is_public': userIds == null,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MedicalFile.fromJson(data);
      } else {
        throw Exception('Failed to share file');
      }
    } catch (e) {
      print('Error sharing file: $e');
      rethrow;
    }
  }

  Future<List<MedicalFile>> getSharedWithMe() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/files/shared'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<MedicalFile> files = (data['files'] as List)
            .map((f) => MedicalFile.fromJson(f))
            .toList();
        return files;
      } else {
        throw Exception('Failed to load shared files');
      }
    } catch (e) {
      print('Error getting shared files: $e');
      rethrow;
    }
  }
}
