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
    print('[UserService] Carregando credenciais armazenadas...');
    _accessToken = await _storage.read(key: 'accessToken');
    _userId = await _storage.read(key: 'userId');
    print('[UserService] accessToken: $_accessToken');
    print('[UserService] userId: $_userId');
  }

  Future<User> getUserById() async {
    await _loadStoredCredentials();

    if (_accessToken == null) {
      print('[UserService] Nenhum access token encontrado!');
      throw Exception('No access token found');
    }

    try {
      final requestUrl = '$_baseUrl/mine';
      print('[UserService] Fazendo GET em $requestUrl');

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
              print('[UserService] Timeout na requisição GET userById');
              throw TimeoutException(
                'The connection has timed out, please try again later.',
              );
            },
          );

      print('[UserService] Status code getUserById: ${response.statusCode}');
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes); // Decodifica explicitamente em UTF-8
        print('[UserService] Corpo da resposta getUserById: $decodedBody');
        return User.fromJson(json.decode(decodedBody));
      } else {
        print('[UserService] Falha ao carregar usuário');
        throw Exception('Failed to load user');
      }
    } catch (e) {
      print('[UserService] Erro em getUserById: $e');
      rethrow;
    }
  }

  Future<User> getSimpleUser() async {
    await _loadStoredCredentials();

    if (_accessToken == null) {
      print('[UserService] Nenhum access token encontrado!');
      throw Exception('No access token found');
    }

    try {
      final requestUrl = '$_baseUrl/mine/simple';
      print('[UserService] Fazendo GET em $requestUrl');

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
              print('[UserService] Timeout na requisição GET simpleUser');
              throw TimeoutException(
                'The connection has timed out, please try again later.',
              );
            },
          );

      print('[UserService] Status code getSimpleUser: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('[UserService] Corpo da resposta getSimpleUser: ${response.body}');
        return User.fromJson(json.decode(response.body));
      } else {
        print('[UserService] Falha ao buscar dados simplificados do usuário');
        throw Exception('Failed to fetch simplified user data');
      }
    } catch (e) {
      print('[UserService] Erro em getSimpleUser: $e');
      rethrow;
    }
  }

  Future<Token> login(String username, String password) async {
    print('[UserService] Iniciando login...');
    print('[UserService] username: $username');
    // Não printar senha por segurança
    final queryParameters = {'username': username, 'password': password};

    final uri = Uri.parse(
      '$_tokenUrl',
    ).replace(queryParameters: queryParameters);

    print('[UserService] URI de login: $uri');

    try {
      final response = await http
          .post(uri, headers: {'Content-Type': 'application/json'})
          .timeout(
            _timeoutDuration,
            onTimeout: () {
              print('[UserService] Timeout na requisição de login');
              throw TimeoutException(
                'The connection has timed out, please try again later.',
              );
            },
          );

      print('[UserService] Status code login: ${response.statusCode}');
      print('[UserService] Corpo da resposta login: ${response.body}');
      if (response.statusCode == 200) {
        final token = Token.fromJson(json.decode(response.body));
        _accessToken = token.accessToken;

        print('[UserService] Token recebido: $_accessToken');

        // Decode the token to get the user ID
        Map<String, dynamic> decodedToken = JwtDecoder.decode(_accessToken!);
        print('[UserService] Token decodificado: $decodedToken');
        _userId = decodedToken['sub'];
        print('[UserService] userId extraído do token: $_userId');

        await _storage.write(key: 'accessToken', value: _accessToken);
        await _storage.write(key: 'userId', value: _userId);

        print('[UserService] Token e userId salvos no storage');
        return token;
      } else {
        print('[UserService] Falha ao carregar token');
        throw Exception('Failed to load token');
      }
    } catch (e) {
      print('[UserService] Erro no login: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    print('[UserService] Fazendo logout...');
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'userId');
    _accessToken = null;
    _userId = null;
    print('[UserService] Logout concluído.');
  }

  Future<User> updateUser(User user) async {
    await _loadStoredCredentials();
    try {
      final requestBody = json.encode(user.toJson());
      final requestUrl = '$_baseUrl/$_userId';
      print('[UserService] Atualizando usuário em $requestUrl');
      print('[UserService] Corpo da requisição: $requestBody');

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
              print('[UserService] Timeout na requisição PATCH updateUser');
              throw TimeoutException(
                'The connection has timed out, please try again later.',
              );
            },
          );

      print('[UserService] Status code updateUser: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('[UserService] Corpo da resposta updateUser: ${response.body}');
        return User.fromJson(json.decode(response.body));
      } else {
        print('[UserService] Falha ao atualizar usuário');
        throw Exception('Failed to update user');
      }
    } catch (e) {
      print('[UserService] Erro em updateUser: $e');
      rethrow;
    }
  }

  Future<User> createUser(CreateUser user) async {
    try {
      final requestBody = json.encode(user.toJson());
      final requestUrl = '$_baseUrl/create';
      print('[UserService] Criando usuário em $requestUrl');
      print('[UserService] Corpo da requisição: $requestBody');

      final response = await http
          .post(
            Uri.parse(requestUrl),
            headers: {'Content-Type': 'application/json'},
            body: requestBody,
          )
          .timeout(
            _timeoutDuration,
            onTimeout: () {
              print('[UserService] Timeout na requisição POST createUser');
              throw TimeoutException(
                'The connection has timed out, please try again later.',
              );
            },
          );

      print('[UserService] Status code createUser: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('[UserService] Corpo da resposta createUser: ${response.body}');
        return User.fromJson(json.decode(response.body));
      } else {
        print('[UserService] Falha ao criar usuário');
        throw Exception('Failed to create user');
      }
    } catch (e) {
      print('[UserService] Erro em createUser: $e');
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

    print('[UserService] Atualizando senha do usuário em $url');
    print('[UserService] Corpo da requisição: $requestBody');

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    print('[UserService] Status code updateUserPassword: ${response.statusCode}');
    if (response.statusCode != 200) {
      print('[UserService] Falha ao atualizar senha: ${response.body}');
      throw Exception('Failed to update password: ${response.body}');
    }
    print('[UserService] Senha atualizada com sucesso.');
  }

  Future<void> sendEmail(String email) async {
    try {
      final String requestUrl = '$_emailUrl/$email';
      print('[UserService] Enviando email para $email em $requestUrl');

      final response = await http
          .post(
            Uri.parse(requestUrl),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            _timeoutDuration,
            onTimeout: () {
              print('[UserService] Timeout na requisição POST sendEmail');
              throw TimeoutException(
                'The connection has timed out, please try again later.',
              );
            },
          );

      print('[UserService] Status code sendEmail: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('[UserService] Email enviado com sucesso.');
      } else {
        print('[UserService] Falha ao enviar email');
        throw Exception('Failed to send email');
      }
    } catch (e) {
      print('[UserService] Erro em sendEmail: $e');
      throw Exception('Failed to send email');
    }
  }

  Future<List<ImageInfoDTO>> getAllImagePreviewsBase64() async {
    await _loadStoredCredentials(); // Load stored credentials (access token and user ID).
    final requestUrl = '$_baseUrl/previews'; // Construct the request URL.
    print('[UserService] Buscando previews de imagens em $requestUrl');

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
          print('[UserService] Timeout na requisição GET getAllImagePreviewsBase64');
          throw TimeoutException('The connection has timed out, please try again later.');
        },
      );

      print('[UserService] Status code getAllImagePreviewsBase64: ${response.statusCode}');
      // Check the response status code.
      if (response.statusCode == 200) {
        // Parse the response body into a list of `ImageInfoDTO` objects.
        final List<dynamic> responseData = json.decode(response.body);
        print('[UserService] Quantidade de imagens recebidas: ${responseData.length}');
        return responseData.map((item) => ImageInfoDTO.fromJson(item)).toList();
      } else {
        print('[UserService] Falha ao buscar previews de imagens');
        throw Exception('Failed to fetch image previews');
      }
    } catch (e) {
      print('[UserService] Erro em getAllImagePreviewsBase64: $e');
      rethrow;
    }
  }

  Future<ImageInfoDTO> getProfileImage() async {
    await _loadStoredCredentials(); // Load stored credentials (access token and user ID).
    final requestUrl = '$_baseUrl/profileImage'; // Construct the request URL.
    print('[UserService] Buscando imagem de perfil em $requestUrl');

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
          print('[UserService] Timeout na requisição GET getProfileImage');
          throw TimeoutException('The connection has timed out, please try again later.');
        },
      );

      print('[UserService] Status code getProfileImage: ${response.statusCode}');
      // Check the response status code.
      if (response.statusCode == 200) {
        // Parse the response body into an `ImageInfoDTO` object.
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('[UserService] Dados da imagem de perfil recebidos: $responseData');
        return ImageInfoDTO.fromJson(responseData);
      } else {
        print('[UserService] Falha ao buscar imagem de perfil');
        throw Exception('Failed to fetch profile image');
      }
    } catch (e) {
      print('[UserService] Erro em getProfileImage: $e');
      rethrow;
    }
  }
}
