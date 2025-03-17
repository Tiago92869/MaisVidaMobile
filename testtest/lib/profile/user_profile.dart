import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool editMode = false;

  // Controller for text fields
  TextEditingController nameController = TextEditingController(text: "John Doe");
  TextEditingController emailController = TextEditingController(text: "johndoe@example.com");
  TextEditingController cityController = TextEditingController(text: "Los Angeles");
  TextEditingController birthdayController = TextEditingController(text: "Jan 1, 1990");

  // Variables to store the last saved values
  String lastSavedName = "John Doe";
  String lastSavedEmail = "johndoe@example.com";
  String lastSavedCity = "Los Angeles";
  String lastSavedBirthday = "Jan 1, 1990";

  // Method to toggle edit mode
  void toggleEditMode() {
    setState(() {
      editMode = !editMode;
    });
  }

  // Method to save changes
  void saveChanges() {
    // Save the changes (in a real app, you'd probably save them to a database or API)
    print("Changes saved: ${nameController.text}, ${emailController.text}, ${cityController.text}, ${birthdayController.text}");
    
    // Update last saved values
    lastSavedName = nameController.text;
    lastSavedEmail = emailController.text;
    lastSavedCity = cityController.text;
    lastSavedBirthday = birthdayController.text;

    toggleEditMode(); // After saving, exit edit mode
  }

  // Method to discard changes and exit edit mode (revert to last saved values)
  void cancelEdit() {
    setState(() {
      // Revert to the last saved values
      nameController.text = lastSavedName;
      emailController.text = lastSavedEmail;
      cityController.text = lastSavedCity;
      birthdayController.text = lastSavedBirthday;
      editMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Light Blue Gradient Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.lightBlue[300]!, Colors.lightBlue[100]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Starfish Image between the background and content
          Positioned(
            left: 80,
            top: 340,
            width: 600,
            height: 600,
            child: Opacity(
              opacity: 0.9, // Adjust opacity for starfish image
              child: FadeInUp(
                duration: Duration(seconds: 1),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/startfhis1blue.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),

                  // Profile Image
                  Center(
                    child: FadeInUp(
                      duration: Duration(milliseconds: 1200),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage('assets/images/starfish.png'),
                        backgroundColor: Colors.grey[300],
                      ),
                    ),
                  ),

                  SizedBox(height: 40),

                  // User Info Fields with FadeInUp Animation
                  FadeInUp(
                    duration: Duration(milliseconds: 1400),
                    child: _buildUserInfo("Full Name", nameController),
                  ),
                  SizedBox(height: 20),
                  FadeInUp(
                    duration: Duration(milliseconds: 1600),
                    child: _buildUserInfo("Email", emailController),
                  ),
                  SizedBox(height: 20),
                  FadeInUp(
                    duration: Duration(milliseconds: 1800),
                    child: _buildUserInfo("City", cityController),
                  ),
                  SizedBox(height: 20),
                  FadeInUp(
                    duration: Duration(milliseconds: 2000),
                    child: _buildUserInfo("Birthday", birthdayController),
                  ),

                  SizedBox(height: 30),

                  // About Me Section
                  FadeInUp(
                    duration: Duration(milliseconds: 1400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "About Me",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10), // Space after the "About Me" text
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[400]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10.0,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Text(
                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                            "Vestibulum in neque et nisl vestibulum cursus.",
                            style: TextStyle(color: Colors.grey[700], fontSize: 16),
                          ),
                        ),
                        SizedBox(height: 30), // Adding some space after the "About Me" container for better separation
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Cancel Icon with white circle moved to the left side
          Positioned(
            top: 55,
            right: 90, // Move to the left side
            child: Row(
              children: [
                // Cancel Icon with white circle moved to the left side
                if (editMode)
                  GestureDetector(
                    onTap: cancelEdit,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        width: 40, // Smaller size for the circle
                        height: 40, // Smaller size for the circle
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: 28, // Smaller icon size to fit the smaller circle
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Edit/Save Icon with white circle behind it, keep it on the right side
          Positioned(
            top: 55,
            right: 30,
            child: Row(
              children: [
                GestureDetector(
                  onTap: editMode ? saveChanges : toggleEditMode,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      width: 40, // Smaller size for the circle
                      height: 40, // Smaller size for the circle
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        editMode ? Icons.save : Icons.edit,
                        color: Color.fromRGBO(85, 123, 233, 1),
                        size: 28, // Smaller icon size to fit the smaller circle
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(String title, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[400]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10.0,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            enabled: editMode, // Enable or disable the text field based on editMode
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
            decoration: InputDecoration.collapsed(hintText: 'Enter $title'),
          ),
        ),
      ],
    );
  }
}
