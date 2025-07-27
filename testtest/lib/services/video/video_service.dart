import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mentara/services/video/video_model.dart';
import 'package:mentara/config/config.dart' as configg;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

const Duration _timeoutDuration = Duration(seconds: 10);

class VideoService {
  final String _baseUrl = configg.Config.videoUrl; // Use configg alias
  final _storage = const FlutterSecureStorage();

  String? _accessToken;

  Future<void> _loadStoredCredentials() async {
    _accessToken = await _storage.read(key: 'accessToken');
  }

  Future<VideoFile> uploadVideo(File file) async {
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
        return VideoFile.fromJson(json.decode(responseBody));
      } else {
        throw Exception('Failed to upload video');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<VideoInfoDTO> getVideoBase64(String id) async {
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
        final decodedBody = utf8.decode(response.bodyBytes); // Decodifica explicitamente em UTF-8
        final responseBody = json.decode(decodedBody);
        return VideoInfoDTO.fromJson(responseBody);
      } else {
        throw Exception('Failed to fetch video Base64');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<http.StreamedResponse> streamVideo(String id) async {
    await _loadStoredCredentials();
    final requestUrl = '$_baseUrl/stream/$id';

    try {
      final request = http.Request('GET', Uri.parse(requestUrl))
        ..headers['Authorization'] = 'Bearer $_accessToken';

      final response = await request.send().timeout(
        _timeoutDuration,
        onTimeout: () {
          throw TimeoutException('The connection has timed out, please try again later.');
        },
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<File?> downloadVideoFile(String id) async {
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

        // Save the file to the app's documents directory
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
