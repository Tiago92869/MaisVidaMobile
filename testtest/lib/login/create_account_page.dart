// create_account_page.dart
import 'package:flutter/material.dart';
import 'package:testtest/services/user/user_service.dart';
import 'package:testtest/services/user/user_model.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();

  // Controllers for input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _familyNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false; // For toggling password visibility

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final createUser = CreateUser(
        id: "", // ID is empty for new users
        firstName: _firstNameController.text.trim(),
        secondName: _familyNameController.text.trim(),
        email: _emailController.text.trim(),
        city: _cityController.text.trim(),
        aboutMe: "", // Optional field, can be left empty
        dateOfBirth: DateTime.parse(_birthdayController.text.trim()),
        password: _passwordController.text.trim(),
      );

      await _userService.createUser(createUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account created successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      // Display a red warning message for errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to create account: ${e.toString()}",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background3.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 100),
                    const Center(
                      child: Text(
                        "Create Account",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildInputField("Email", _emailController, validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email is required.";
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return "Enter a valid email.";
                      }
                      return null;
                    }),
                    _buildInputField("First Name", _firstNameController, validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "First name is required.";
                      }
                      return null;
                    }),
                    _buildInputField("Family Name", _familyNameController, validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Family name is required.";
                      }
                      return null;
                    }),
                    _buildInputField("City", _cityController, validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "City is required.";
                      }
                      return null;
                    }),
                    _buildDateInputField("Birthday Date", _birthdayController),
                    _buildPasswordField("Password", _passwordController),
                    _buildPasswordField("Confirm Password", _confirmPasswordController),
                    const SizedBox(height: 30),
                    _buildButton(context, "Create Account", _createAccount),
                    const SizedBox(height: 20),
                    _buildButton(context, "Go Back", () {
                      Navigator.pop(context);
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField(String hint, TextEditingController controller,
      {bool obscureText = false, String? Function(String?)? validator}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(bottom: 10),
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
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[700]),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDateInputField(String hint, TextEditingController controller) {
    return GestureDetector(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color.fromRGBO(72, 85, 204, 1), // Header background color
                  onPrimary: Colors.white, // Header text color
                  onSurface: Colors.black, // Body text color
                ),
              ),
              child: child!,
            );
          },
        );
        if (selectedDate != null) {
          setState(() {
            controller.text = "${selectedDate.toLocal()}".split(' ')[0];
          });
        }
      },
      child: AbsorbPointer(
        child: _buildInputField(hint, controller, validator: (value) {
          if (value == null || value.isEmpty) {
            return "Birthday date is required.";
          }
          return null;
        }),
      ),
    );
  }

  Widget _buildPasswordField(String hint, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(bottom: 10),
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
      child: TextFormField(
        controller: controller,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[700]),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey[700],
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$hint is required.";
          }
          if (hint == "Password" && value.length < 6) {
            return "Password must be at least 6 characters.";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
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
            ),
          ),
        ),
      ),
    );
  }
}
