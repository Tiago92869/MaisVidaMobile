import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:mentara/services/resource/resource_model.dart';
import 'package:mentara/config/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const Duration _timeoutDuration = Duration(seconds: 10);

class ResourceService {
  final String _baseUrl = Config.resourceUrl;
  final _storage = const FlutterSecureStorage();

  String? _accessToken;
  String? _userId;

  Future<void> _loadStoredCredentials() async {
    _accessToken = await _storage.read(key: 'accessToken');
    _userId = await _storage.read(key: 'userId');
  }

  Future<ResourcePage> fetchResources(
    List<ResourceType> resourceTypes, {
    int page = 0, // Default page
    int size = 10, // Default size
    String search = "", // Default search query
  }) async {
    await _loadStoredCredentials();
    try {
      // If resourceTypes is empty, use all types except TIVA
      /*
      if (resourceTypes.isEmpty) {
        resourceTypes = ResourceType.values.where((type) => type != ResourceType.TIVA).toList();
      }
      */
      // Convert resourceTypes to a comma-separated string
      final String resourceTypesParam = resourceTypes
          .map((type) => type.toString().split('.').last)
          .join(',');

      // Build the URL with query parameters
      final String url =
          '$_baseUrl?userId=$_userId&page=$page&size=$size&search=$search&resourceType=$resourceTypesParam';
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Content-Type': 'application/json; charset=utf-8', // Ensure UTF-8 encoding
            },
          )
          .timeout(
            _timeoutDuration,
            onTimeout: () {
              throw TimeoutException(
                'The connection has timed out, please try again later.',
              );
            },
          );

      // Decode response body with UTF-8
      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        return ResourcePage.fromJson(jsonDecode(decodedBody));
      } else {
        throw Exception('Failed to load resources');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Resource> fetchResourceById(String id) async {
    await _loadStoredCredentials();
    try {
      final String requestUrl = '$_baseUrl/$id';

      final response = await http
          .get(
            Uri.parse(requestUrl),
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            _timeoutDuration,
            onTimeout: () {
              throw TimeoutException(
                'The connection has timed out, please try again later.',
              );
            },
          );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes); // Decodifica explicitamente em UTF-8
        return Resource.fromJson(jsonDecode(decodedBody));
      } else {
        throw Exception('Failed to load resource');
      }
    } catch (e) {
      throw Exception('Failed to fetch resource');
    }
  }
}
