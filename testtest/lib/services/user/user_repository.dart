import 'package:testtest/services/user/user_model.dart';
import 'package:testtest/services/user/user_service.dart';

class UserRepository {
  final UserService userService;

  UserRepository({required this.userService});

  Future<User> getUserById() async {
    print('UserRepository: Fetching user by ID...');
    try {
      final user = await userService.getUserById();
      print('UserRepository: Successfully fetched user: ${user.id}');
      return user;
    } catch (e) {
      print('UserRepository: Error fetching user by ID: $e');
      rethrow;
    }
  }

  Future<User> updateUser(User user) async {
    print('UserRepository: Updating user with ID: ${user.id}...');
    try {
      final updatedUser = await userService.updateUser(user);
      print('UserRepository: Successfully updated user: ${updatedUser.id}');
      return updatedUser;
    } catch (e) {
      print('UserRepository: Error updating user: $e');
      rethrow;
    }
  }

  Future<User> createUser(CreateUser user) async {
    print('UserRepository: Creating user...');
    try {
      final createdUser = await userService.createUser(user);
      print('UserRepository: Successfully created user: ${createdUser.id}');
      return createdUser;
    } catch (e) {
      print('UserRepository: Error creating user: $e');
      rethrow;
    }
  }

  Future<Token> login(String username, String password) async {
    print('UserRepository: Logging in user: $username...');
    try {
      final token = await userService.login(username, password);
      print(
          'UserRepository: Successfully logged in, access token: ${token.accessToken}');
      return token;
    } catch (e) {
      print('UserRepository: Error logging in user: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    print('UserRepository: Logging out...');
    try {
      await userService.logout();
      print('UserRepository: Successfully logged out');
    } catch (e) {
      print('UserRepository: Error logging out: $e');
      rethrow;
    }
  }

  // Method to update the user's password
  Future<void> updateUserPassword(String userId, PasswordUpdateDTO passwordUpdateDTO) async {
    await userService.updateUserPassword(userId, passwordUpdateDTO);
  }
}
