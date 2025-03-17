// reset_password_page.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'login_page.dart'; // Import the Login Page

class ResetPasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background3.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(30.0),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 50),
                  Center(
                    child: Text(
                      "Reset Password",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Write your respective email address and a new password will be sent to you via email",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Input field
                  _buildInputField("Email"),

                  // Pushes everything above upwards, making buttons stay at the bottom
                  Spacer(),

                  // Buttons at the bottom
                  _buildButton(context, "Create New Password", () {
                    // Navigate to Login Page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  }),
                  SizedBox(height: 20),
                  _buildButton(context, "Go Back", () {
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
    return FadeInUp(
      duration: Duration(milliseconds: 1800),
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color.fromRGBO(85, 123, 233, 1)),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(125, 154, 238, .2),
              blurRadius: 20.0,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Function() onTap) {
    return FadeInUp(
      duration: Duration(milliseconds: 1900),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          width: double.infinity, // Makes button full width
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [Color(0xFF557BE9), Color(0xFF7D9AEE)],
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
