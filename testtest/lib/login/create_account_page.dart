// create_account_page.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'login_page.dart';

class CreateAccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background3.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Starfish positioned above background but below content
          Positioned(
            top: 35,
            right: 10,
            child: Opacity(
              opacity: 0.4,
              child: Image.asset(
                'assets/images/starfish.png',
                width: 240,
                height: 240,
              ),
            ),
          ),

          // Content (text fields and buttons)
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 100),
                Center(
                  child: Text(
                    "Create Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    children: <Widget>[
                      _buildInputField("Email"),
                      _buildInputField("First Name"),
                      _buildInputField("Family Name"),
                      _buildInputField("City"),
                      _buildInputField("Birthday Date"),
                      _buildInputField("Password", obscureText: true),
                      _buildInputField("Confirm Password", obscureText: true),
                      SizedBox(height: 30),
                      _buildButton(context, "Create Account", () {}),
                      SizedBox(height: 20),
                      _buildButton(context, "Go Back", () {
                        Navigator.pop(context);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String hint, {bool obscureText = false}) {
    return FadeInUp(
      duration: Duration(milliseconds: 1800),
      child: Container(
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.only(bottom: 10),
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
          obscureText: obscureText,
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
