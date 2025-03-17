// login_page.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'create_account_page.dart';
import 'reset_password_page.dart';
import 'package:testtest/menu/menu.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 400,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background1.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: 0,
                    top: 50,
                    width: 160,
                    height: 200,
                    child: Opacity(
                      opacity: 0.4,
                      child: FadeInUp(
                        duration: Duration(seconds: 1),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/starfish1.png'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 270,
                    top: 100,
                    width: 200,
                    height: 200,
                    child: Opacity(
                      opacity: 0.4,
                      child: FadeInUp(
                        duration: Duration(milliseconds: 1200),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/starfish2.png'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    child: FadeInUp(
                      duration: Duration(milliseconds: 1600),
                      child: Container(
                        margin: EdgeInsets.only(top: 50),
                        child: Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 30, right: 30),
              child: Column(
                children: <Widget>[
                  FadeInUp(
                    duration: Duration(milliseconds: 1800),
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Color(0xFF557BE9)),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x7D9AEE),
                            blurRadius: 20.0,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFF557BE9)),
                              ),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Email or Phone number",
                                hintStyle: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: TextField(
                              obscureText: true,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Password",
                                hintStyle: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  FadeInUp(
  duration: Duration(milliseconds: 1900),
  child: GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MenuScreen(),
        ),
      );
    },
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
          "Login",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  ),
),
                  SizedBox(height: 20),
                  FadeInUp(
                    duration: Duration(milliseconds: 1950),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateAccountPage(),
                          ),
                        );
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(85, 123, 233, 1),
                              Color.fromRGBO(125, 154, 238, 1),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Create Account",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 70),
                  FadeInUp(
                    duration: Duration(milliseconds: 2000),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResetPasswordPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Color(0xFF557BE9),
                          decoration: TextDecoration.underline, // Underline to show it's clickable
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
