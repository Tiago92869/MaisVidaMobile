import 'package:mentara/services/user/user_model.dart';
import 'package:mentara/services/user/user_service.dart';

class UserRepository {
  final UserService userService;

  UserRepository({required this.userService});

  Future<User> getUserById() async {
    try {
      final user = await userService.getUserById();
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User> updateUser(User user) async {
    try {
      final updatedUser = await userService.updateUser(user);
      return updatedUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<User> createUser(CreateUser user) async {
    try {
      final createdUser = await userService.createUser(user);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<Token> login(String username, String password) async {
    try {
      final token = await userService.login(username, password);
      return token;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await userService.logout();
    } catch (e) {
      rethrow;
    }
  }

  // Method to update the user's password
  Future<void> updateUserPassword(PasswordUpdateDTO passwordUpdateDTO) async {
    await userService.updateUserPassword(passwordUpdateDTO);
  }

  Future<User> getSimpleUser() async {
    try {
      final user = await userService.getSimpleUser();
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendEmail(String email) async {
    try {
      await userService.sendEmail(email);
    } catch (e) {
      rethrow;
    }
  }
}
