import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:testtest/services/image/image_model.dart';
import 'package:testtest/config/config.dart';

const Duration _timeoutDuration = Duration(seconds: 10);

class ImageService {
  final String _baseUrl = Config.imageUrl;
  final _storage = const FlutterSecureStorage();

  String? _accessToken;

  Future<void> _loadStoredCredentials() async {
    _accessToken = await _storage.read(key: 'accessToken');
  }

  Future<ImageFile> uploadImage(File file) async {
    await _loadStoredCredentials();
    final requestUrl = '$_baseUrl/upload';
    final request = http.MultipartRequest('POST', Uri.parse(requestUrl))
      ..headers['Authorization'] = 'Bearer $_accessToken'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send().timeout(
      _timeoutDuration,
      onTimeout: () {
        throw TimeoutException('The connection has timed out, please try again later.');
      },
    );

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      return ImageFile.fromJson(json.decode(responseBody));
    } else {
      throw Exception('Failed to upload image');
    }
  }

  Future<File> downloadImage(String id, String savePath) async {
    await _loadStoredCredentials();
    final requestUrl = '$_baseUrl/download/$id';

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
      final file = File(savePath);
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      throw Exception('Failed to download image');
    }
  }
}
