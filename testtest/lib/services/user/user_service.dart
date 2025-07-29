import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mentara/services/user/user_model.dart';
import 'package:mentara/config/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Import the jwt_decoder package

const Duration _timeoutDuration = Duration(seconds: 10);

class UserService {
  final String _baseUrl = Config.userUrl;
  final String _emailUrl = Config.emailUrl;
  final String _tokenUrl = Config.tokenUrl;
  final _storage = const FlutterSecureStorage();

  String? _accessToken;
  String? _userId;

  Future<void> _loadStoredCredentials() async {
    _accessToken = await _storage.read(key: 'accessToken');
    _userId = await _storage.read(key: 'userId');
  }

  Future<User> getUserById() async {
    await _loadStoredCredentials();

    if (_accessToken == null) {
      throw Exception('No access token found');
    }

    try {
      final requestUrl = '$_baseUrl/mine';

      final response = await http
          .get(
            Uri.parse(requestUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_accessToken',
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
        return User.fromJson(json.decode(decodedBody));
      } else {
        throw Exception('Failed to load user');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getSimpleUser() async {
    await _loadStoredCredentials();

    if (_accessToken == null) {
      throw Exception('No access token found');
    }

    try {
      final requestUrl = '$_baseUrl/mine/simple';

      final response = await http
          .get(
            Uri.parse(requestUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_accessToken',
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
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to fetch simplified user data');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Token> login(String username, String password) async {
    // Não printar senha por segurança
    final queryParameters = {'username': username, 'password': password};

    final uri = Uri.parse(
      '$_tokenUrl',
    ).replace(queryParameters: queryParameters);


    try {
      final response = await http
          .post(uri, headers: {'Content-Type': 'application/json'})
          .timeout(
            _timeoutDuration,
            onTimeout: () {
              throw TimeoutException(
                'The connection has timed out, please try again later.',
              );
            },
          );

      if (response.statusCode == 200) {
        final token = Token.fromJson(json.decode(response.body));
        _accessToken = token.accessToken;


        // Decode the token to get the user ID
        Map<String, dynamic> decodedToken = JwtDecoder.decode(_accessToken!);
        _userId = decodedToken['sub'];

        await _storage.write(key: 'accessToken', value: _accessToken);
        await _storage.write(key: 'userId', value: _userId);

        return token;
      } else {
        throw Exception('Failed to load token');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'userId');
    _accessToken = null;
    _userId = null;
  }

  Future<User> updateUser(User user) async {
    await _loadStoredCredentials();
    try {
      final requestBody = json.encode(user.toJson());
      final requestUrl = '$_baseUrl/$_userId';

      final response = await http
          .patch(
            Uri.parse(requestUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_accessToken',
            },
            body: requestBody,
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
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update user');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<User> createUser(CreateUser user) async {
    try {
      final requestBody = json.encode(user.toJson());
      final requestUrl = '$_baseUrl/create';

      final response = await http
          .post(
            Uri.parse(requestUrl),
            headers: {'Content-Type': 'application/json'},
            body: requestBody,
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
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create user');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Method to update the user's password
  Future<void> updateUserPassword(PasswordUpdateDTO passwordUpdateDTO) async {
    await _loadStoredCredentials();
    final url = Uri.parse('$_baseUrl/password');
    final requestBody = jsonEncode({
      'oldPassword': passwordUpdateDTO.currentPassword,
      'newPassword': passwordUpdateDTO.newPassword,
      'newPasswordCheck':
          passwordUpdateDTO
              .newPassword, // Ensure newPasswordCheck matches newPassword
    });

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update password: ${response.body}');
    }
  }

  Future<void> sendEmail(String email) async {
    try {
      final String requestUrl = '$_emailUrl/$email';

      final response = await http
          .post(
            Uri.parse(requestUrl),
            headers: {'Content-Type': 'application/json'},
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
      } else {
        throw Exception('Failed to send email');
      }
    } catch (e) {
      throw Exception('Failed to send email');
    }
  }

  Future<List<ImageInfoDTO>> getAllImagePreviewsBase64() async {
    await _loadStoredCredentials(); // Load stored credentials (access token and user ID).
    final requestUrl = '$_baseUrl/previews'; // Construct the request URL.

    try {
      // Send the GET request to the server.
      final response = await http.get(
        Uri.parse(requestUrl),
        headers: {
          'Authorization': 'Bearer $_accessToken', // Include the access token in the headers.
          'Content-Type': 'application/json', // Specify the content type.
        },
      ).timeout(
        _timeoutDuration, // Set a timeout for the request.
        onTimeout: () {
          throw TimeoutException('The connection has timed out, please try again later.');
        },
      );

      // Check the response status code.
      if (response.statusCode == 200) {
        // Parse the response body into a list of `ImageInfoDTO` objects.
        final List<dynamic> responseData = json.decode(response.body);
        return responseData.map((item) => ImageInfoDTO.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch image previews');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ImageInfoDTO> getProfileImage() async {
    await _loadStoredCredentials(); // Load stored credentials (access token and user ID).
    final requestUrl = '$_baseUrl/profileImage'; // Construct the request URL.

    try {
      // Send the GET request to the server.
      final response = await http.get(
        Uri.parse(requestUrl),
        headers: {
          'Authorization': 'Bearer $_accessToken', // Include the access token in the headers.
          'Content-Type': 'application/json', // Specify the content type.
        },
      ).timeout(
        _timeoutDuration, // Set a timeout for the request.
        onTimeout: () {
          throw TimeoutException('The connection has timed out, please try again later.');
        },
      );

      // Check the response status code.
      if (response.statusCode == 200) {
        // Parse the response body into an `ImageInfoDTO` object.
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ImageInfoDTO.fromJson(responseData);
      } else {
        throw Exception('Failed to fetch profile image');
      }
    } catch (e) {
      rethrow;
    }
  }
}
