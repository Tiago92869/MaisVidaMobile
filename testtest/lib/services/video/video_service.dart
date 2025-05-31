import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:testtest/services/video/video_model.dart';
import 'package:testtest/config/config.dart';

const Duration _timeoutDuration = Duration(seconds: 10);

class VideoService {
  final String _baseUrl = Config.videoUrl;
  final _storage = const FlutterSecureStorage();

  String? _accessToken;

  Future<void> _loadStoredCredentials() async {
    _accessToken = await _storage.read(key: 'accessToken');
  }

  Future<VideoFile> uploadVideo(File file) async {
    await _loadStoredCredentials();
    final requestUrl = '$_baseUrl/upload';
    print('VideoService: Starting uploadVideo...');
    print('VideoService: Request URL: $requestUrl');
    print('VideoService: File path: ${file.path}');

    final request = http.MultipartRequest('POST', Uri.parse(requestUrl))
      ..headers['Authorization'] = 'Bearer $_accessToken'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      final response = await request.send().timeout(
        _timeoutDuration,
        onTimeout: () {
          print('VideoService: Upload request to $requestUrl timed out.');
          throw TimeoutException('The connection has timed out, please try again later.');
        },
      );

      print('VideoService: Upload response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print('VideoService: Upload response body: $responseBody');
        return VideoFile.fromJson(json.decode(responseBody));
      } else {
        print('VideoService: Failed to upload video. Status Code: ${response.statusCode}');
        throw Exception('Failed to upload video');
      }
    } catch (e) {
      print('VideoService: Error during uploadVideo: $e');
      rethrow;
    }
  }

  Future<VideoInfoDTO> getVideoBase64(String id) async {
    await _loadStoredCredentials();
    final requestUrl = '$_baseUrl/$id';
    print('VideoService: Starting getVideoBase64...');
    print('VideoService: Request URL: $requestUrl');

    try {
      final response = await http.get(
        Uri.parse(requestUrl),
        headers: {'Authorization': 'Bearer $_accessToken'},
      ).timeout(
        _timeoutDuration,
        onTimeout: () {
          print('VideoService: Request to $requestUrl timed out.');
          throw TimeoutException('The connection has timed out, please try again later.');
        },
      );

      print('VideoService: Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        print('VideoService: VideoInfoDTO fetched successfully.');
        return VideoInfoDTO.fromJson(responseBody);
      } else {
        print('VideoService: Failed to fetch video Base64. Status Code: ${response.statusCode}');
        throw Exception('Failed to fetch video Base64');
      }
    } catch (e) {
      print('VideoService: Error during getVideoBase64: $e');
      rethrow;
    }
  }

  Future<http.StreamedResponse> streamVideo(String id) async {
    await _loadStoredCredentials();
    final requestUrl = '$_baseUrl/stream/$id';
    print('VideoService: Starting streamVideo...');
    print('VideoService: Request URL: $requestUrl');

    try {
      final request = http.Request('GET', Uri.parse(requestUrl))
        ..headers['Authorization'] = 'Bearer $_accessToken';

      final response = await request.send().timeout(
        _timeoutDuration,
        onTimeout: () {
          print('VideoService: Request to $requestUrl timed out.');
          throw TimeoutException('The connection has timed out, please try again later.');
        },
      );

      print('VideoService: Response status code: ${response.statusCode}');
      return response;
    } catch (e) {
      print('VideoService: Error during streamVideo: $e');
      rethrow;
    }
  }
}
