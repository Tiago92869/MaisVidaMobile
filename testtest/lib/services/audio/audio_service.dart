import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'audio_model.dart';
import 'package:mentara/config/config.dart' as configg;

const Duration _timeoutDuration = Duration(seconds: 10);

class AudioService {
  final String _baseUrl = configg.Config.audioUrl; // Use configg alias
  final _storage = const FlutterSecureStorage();

  String? _accessToken;

  Future<void> _loadStoredCredentials() async {
    _accessToken = await _storage.read(key: 'accessToken');
  }

  Future<AudioFile> uploadAudio(File file) async {
    await _loadStoredCredentials();
    final requestUrl = '$_baseUrl/upload';

    final request = http.MultipartRequest('POST', Uri.parse(requestUrl))
      ..headers['Authorization'] = 'Bearer $_accessToken'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      final response = await request.send().timeout(
        _timeoutDuration,
        onTimeout: () {
          throw TimeoutException('The connection has timed out, please try again later.');
        },
      );

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return AudioFile.fromJson(json.decode(responseBody));
      } else {
        throw Exception('Failed to upload audio');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<AudioInfoDTO> getAudioBase64(String id) async {
    await _loadStoredCredentials();
    final requestUrl = '$_baseUrl/$id';

    try {
      final response = await http.get(
        Uri.parse(requestUrl),
        headers: {'Authorization': 'Bearer $_accessToken'},
      ).timeout(
        _timeoutDuration,
        onTimeout: () {
          throw TimeoutException('The connection has timed out, please try again later.');
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return AudioInfoDTO.fromJson(responseBody);
      } else {
        throw Exception('Failed to fetch audio Base64');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<File?> downloadAudioFile(String id) async {
    await _loadStoredCredentials();
    final requestUrl = '$_baseUrl/download/$id';

    try {
      final headers = {
        'Authorization': 'Bearer $_accessToken',
      };

      final fileInfo = await DefaultCacheManager().downloadFile(
        requestUrl,
        authHeaders: headers,
      );

      if (fileInfo.file.existsSync()) {
        final appDocDir = await getApplicationDocumentsDirectory();
        final savedFilePath = '${appDocDir.path}/${fileInfo.file.uri.pathSegments.last}';
        final savedFile = await fileInfo.file.copy(savedFilePath);
        return savedFile;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
