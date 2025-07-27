
import 'package:flutter/material.dart';
import 'package:mentara/services/user/user_service.dart';
import 'package:mentara/services/user/user_model.dart';
import 'package:mentara/login/login_page.dart';


class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}


class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final UserService _userService = UserService();
  bool _showFirstStarfish = true;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> updatePassword() async {
    if (currentPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Todos os campos devem ser preenchidos."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("A nova palavra-passe e a confirmação da palavra-passe não correspondem."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      final passwordUpdateDTO = PasswordUpdateDTO(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );
      await _userService.updateUserPassword(passwordUpdateDTO);
      await _userService.logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Palavra-passe atualizada com sucesso! Faça login novamente."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Falha ao atualizar a palavra-passe: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          if (_showFirstStarfish)
            Positioned(
              right: 80,
              top: 320,
              width: 400,
              height: 400,
              child: Opacity(
              opacity: 0.05,
                child: Transform.rotate(
                  angle: 0.7,
                  child: Image.asset(
                    'assets/images/starfish2.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            )
          else
            Positioned(
              left: 100,
              top: 250,
              width: 400,
              height: 400,
              child: Opacity(
              opacity: 0.05,
                child: Transform.rotate(
                  angle: 0.5,
                  child: Image.asset(
                    'assets/images/starfish1.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      "Atualizar palavra-passe",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  _buildPasswordField(
                    "Palavra-passe atual",
                    currentPasswordController,
                  ),
                  const SizedBox(height: 30),
                  _buildPasswordField("Nova palavra-passe", newPasswordController),
                  const SizedBox(height: 30),
                  _buildPasswordField(
                    "Confirmar palavra-passe",
                    confirmPasswordController,
                  ),
                  const SizedBox(height: 100),
                  Center(
                    child: ElevatedButton(
                      onPressed: updatePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Atualizar palavra-passe",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D1B2A),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    bool _isObscured = true;
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(221, 255, 255, 255),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.90),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[400]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10.0,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      obscureText: _isObscured,
                      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      decoration: InputDecoration.collapsed(
                        hintText: '$label',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
