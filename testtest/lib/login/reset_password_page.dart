// reset_password_page.dart
import 'package:flutter/material.dart';
import 'package:maisvida/services/user/user_service.dart';
import 'login_page.dart'; // Import the Login Page

class ResetPasswordPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background3.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 50),
                  const Center(
                    child: Text(
                      "Redefinir palavra-passe",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Escreva o seu respetivo endereço de e-mail e uma nova palavra-passe ser-lhe-á enviada por e-mail",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Input field
                  _buildInputField("E-mail"),

                  // Pushes everything above upwards, making buttons stay at the bottom
                  const Spacer(),

                  // Buttons at the bottom
                  _buildButton(context, "Criar nova palavra-passe", () {
                    // Check if email is not null
                    if (_emailController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Por favor, introduza o seu endereço de e-mail."),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Show loading animation
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return const Center(child: CircularProgressIndicator());
                      },
                    );

                    // Call sendEmail method
                    UserService userService = UserService();
                    userService
                        .sendEmail(_emailController.text)
                        .then((_) {
                          Navigator.pop(context); // Dismiss loading animation
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "E-mail de redefinição de palavra-passe enviado com sucesso.",
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        })
                        .catchError((error) {
                          Navigator.pop(context); // Dismiss loading animation
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Falha ao enviar e-mail: $error"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        });
                  }),
                  const SizedBox(height: 20),
                  _buildButton(context, "Voltar Atrás", () {
                    Navigator.pop(context);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String hint) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color.fromRGBO(85, 123, 233, 1)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(125, 154, 238, .2),
            blurRadius: 20.0,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: _emailController,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[700]),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: double.infinity, // Makes button full width
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [Color(0xFF557BE9), Color(0xFF7D9AEE)],
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
