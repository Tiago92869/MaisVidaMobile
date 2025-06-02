import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:testtest/services/user/user_model.dart';
import 'package:testtest/config/config.dart';
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
    print('Loading stored credentials...');
    _accessToken = await _storage.read(key: 'accessToken');
    _userId = await _storage.read(key: 'userId');

    if (_accessToken != null) {
      print('Access token loaded: $_accessToken');
    } else {
      print('No access token found');
    }

    if (_userId != null) {
      print('User ID loaded: $_userId');
    } else {
      print('No User ID found');
    }
  }

  Future<User> getUserById() async {
    print('Getting user by ID...');
    await _loadStoredCredentials();

    if (_accessToken == null) throw Exception('No access token found');

    try {
      final requestUrl = '$_baseUrl/mine';
      print('Request URL for getUserById: $requestUrl'); // Log the request URL

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

      print('Response status code: ${response.statusCode}');
      print('Response Headers: ${response.headers}'); // Log para verificar o Content-Type

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes); // Decodifica explicitamente em UTF-8
        print('Response body: $decodedBody');
        return User.fromJson(json.decode(decodedBody));
      } else {
        throw Exception('Failed to load user');
      }
    } catch (e) {
      print('Error getting user by ID: $e');
      rethrow;
    }
  }

  Future<User> getSimpleUser() async {
    print('Fetching simplified user data...');
    await _loadStoredCredentials();

    if (_accessToken == null) throw Exception('No access token found');

    try {
      final requestUrl = '$_baseUrl/mine/simple';
      print(
        'Request URL for getSimpleUser: $requestUrl',
      ); // Log the request URL

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

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to fetch simplified user data');
      }
    } catch (e) {
      print('Error fetching simplified user data: $e');
      rethrow;
    }
  }

  Future<Token> login(String username, String password) async {
    print('Attempting login with username: $username');
    final queryParameters = {'username': username, 'password': password};

    final uri = Uri.parse(
      '$_tokenUrl',
    ).replace(queryParameters: queryParameters);
    print('Request URL for login: $uri'); // Log the request URL

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

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final token = Token.fromJson(json.decode(response.body));
        _accessToken = token.accessToken;

        // Decode the token to get the user ID
        Map<String, dynamic> decodedToken = JwtDecoder.decode(_accessToken!);
        _userId = decodedToken['sub'];

        print('Decoded User ID: $_userId');

        await _storage.write(key: 'accessToken', value: _accessToken);
        await _storage.write(key: 'userId', value: _userId);

        print('Login successful, access token: $_accessToken');
        return token;
      } else {
        throw Exception('Failed to load token');
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    print('Logging out...');
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'userId');
    _accessToken = null;
    _userId = null;
    print('Logout successful');
  }

  Future<User> updateUser(User user) async {
    await _loadStoredCredentials();
    print('Updating user with ID: $_userId');
    try {
      final requestBody = json.encode(user.toJson());
      final requestUrl = '$_baseUrl/$_userId';
      print('Request URL for updateUser: $requestUrl'); // Log the request URL
      print(
        'Request body for updateUser: $requestBody',
      ); // Log the request body

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

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update user');
      }
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  Future<User> createUser(CreateUser user) async {
    print('Creating user...');
    try {
      final requestBody = json.encode(user.toJson());
      final requestUrl = '$_baseUrl/create';
      print('Request URL for createUser: $requestUrl'); // Log the request URL
      print(
        'Request body for createUser: $requestBody',
      ); // Log the request body

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

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create user');
      }
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  // Method to update the user's password
  Future<void> updateUserPassword(PasswordUpdateDTO passwordUpdateDTO) async {
    await _loadStoredCredentials();
    print('Starting password update for user: $_userId');
    final url = Uri.parse('$_baseUrl/password');
    final requestBody = jsonEncode({
      'oldPassword': passwordUpdateDTO.currentPassword,
      'newPassword': passwordUpdateDTO.newPassword,
      'newPasswordCheck':
          passwordUpdateDTO
              .newPassword, // Ensure newPasswordCheck matches newPassword
    });

    print('Request URL: $url');
    print('Request Body: $requestBody');

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode != 200) {
      print('Password update failed with status code: ${response.statusCode}');
      throw Exception('Failed to update password: ${response.body}');
    }

    print('Password update successful for user: $_userId');
  }

  Future<void> sendEmail(String email) async {
    try {
      final String requestUrl = '$_emailUrl/$email';
      print('Request URL for sendEmail: $requestUrl'); // Log the request URL

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

      print('Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Email sent successfully.');
      } else {
        print('Failed to send email. Status Code: ${response.statusCode}');
        throw Exception('Failed to send email');
      }
    } catch (e) {
      print('Error sending email: $e');
      throw Exception('Failed to send email');
    }
  }

  Future<List<ImageInfoDTO>> getAllImagePreviewsBase64() async {
    print('Starting getAllImagePreviewsBase64...');
    await _loadStoredCredentials(); // Load stored credentials (access token and user ID).
    final requestUrl = '$_baseUrl/previews'; // Construct the request URL.
    print('Request URL: $requestUrl');

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
          print('Request timed out for getAllImagePreviewsBase64');
          throw TimeoutException('The connection has timed out, please try again later.');
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Check the response status code.
      if (response.statusCode == 200) {
        // Parse the response body into a list of `ImageInfoDTO` objects.
        final List<dynamic> responseData = json.decode(response.body);
        print('Successfully fetched ${responseData.length} image previews.');
        return responseData.map((item) => ImageInfoDTO.fromJson(item)).toList();
      } else {
        print('Failed to fetch image previews. Status code: ${response.statusCode}');
        throw Exception('Failed to fetch image previews');
      }
    } catch (e) {
      print('Error in getAllImagePreviewsBase64: $e');
      rethrow;
    }
  }

  Future<ImageInfoDTO> getProfileImage() async {
    print('Starting getProfileImage...');
    await _loadStoredCredentials(); // Load stored credentials (access token and user ID).
    final requestUrl = '$_baseUrl/profileImage'; // Construct the request URL.
    print('Request URL: $requestUrl');

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
          print('Request timed out for getProfileImage');
          throw TimeoutException('The connection has timed out, please try again later.');
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Check the response status code.
      if (response.statusCode == 200) {
        // Parse the response body into an `ImageInfoDTO` object.
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Successfully fetched profile image with ID: ${responseData['id']}');
        return ImageInfoDTO.fromJson(responseData);
      } else {
        print('Failed to fetch profile image. Status code: ${response.statusCode}');
        throw Exception('Failed to fetch profile image');
      }
    } catch (e) {
      print('Error in getProfileImage: $e');
      rethrow;
    }
  }
}
