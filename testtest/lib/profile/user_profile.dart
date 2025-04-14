import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:testtest/services/user/user_repository.dart';
import 'package:testtest/services/user/user_service.dart';
import 'package:testtest/services/user/user_model.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool editMode = false;

  // Controllers for text fields
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController birthdayController = TextEditingController();
  TextEditingController aboutMeController = TextEditingController();

  // Variables to store the last saved values
  String lastSavedName = "";
  String lastSavedEmail = "";
  String lastSavedCity = "";
  String lastSavedBirthday = "";
  String lastSavedAboutMe = "";

  // UserRepository instance
  final UserRepository userRepository = UserRepository(
    userService: UserService(),
  );

  void toggleEditMode() {
    print("Toggling edit mode. Current state: $editMode");
    setState(() {
      editMode = !editMode;
    });
    print("Edit mode toggled. New state: $editMode");
  }

  Future<void> fetchUserData() async {
    print("Fetching user data...");
    try {
      User user = await userRepository.getUserById();
      print("User data fetched successfully: ${user.toJson()}");

      setState(() {
        nameController.text = "${user.firstName} ${user.secondName}";
        emailController.text = user.email;
        cityController.text = user.city;
        birthdayController.text =
            user.dateOfBirth.toIso8601String().split('T')[0];
        aboutMeController.text = user.aboutMe;

        lastSavedName = nameController.text;
        lastSavedEmail = emailController.text;
        lastSavedCity = cityController.text;
        lastSavedBirthday = birthdayController.text;
        lastSavedAboutMe = aboutMeController.text;
      });
    } catch (e) {
      print("Error fetching user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to fetch user data. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> saveChanges() async {
    print("Saving changes...");
    try {
      List<String> nameParts = nameController.text.split(" ");
      String firstName = nameParts.isNotEmpty ? nameParts[0] : "";
      String secondName =
          nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";

      print("Preparing updated user data...");
      User updatedUser = User(
        id: "user-id-placeholder", // Replace with actual user ID if available
        firstName: firstName,
        secondName: secondName,
        email: emailController.text,
        city: cityController.text,
        aboutMe: aboutMeController.text,
        dateOfBirth: DateTime.parse(birthdayController.text),
        emergencyContact: "",
      );

      print("Sending updated user data to repository...");
      User savedUser = await userRepository.updateUser(updatedUser);
      print("User updated successfully: ${savedUser.toJson()}");

      setState(() {
        lastSavedName = nameController.text;
        lastSavedEmail = emailController.text;
        lastSavedCity = cityController.text;
        lastSavedBirthday = birthdayController.text;
        lastSavedAboutMe = aboutMeController.text;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Data saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      toggleEditMode();
    } catch (e) {
      print("Error saving changes: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save changes. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void cancelEdit() {
    print("Cancelling edit...");
    setState(() {
      nameController.text = lastSavedName;
      emailController.text = lastSavedEmail;
      cityController.text = lastSavedCity;
      birthdayController.text = lastSavedBirthday;
      aboutMeController.text = lastSavedAboutMe;
      editMode = false;
    });
    print("Edit cancelled. Reverted to last saved values.");
  }

  Future<void> _selectDate(BuildContext context) async {
    print("Opening date picker...");
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date
      firstDate: DateTime(1900), // Earliest selectable date
      lastDate: DateTime.now(), // Latest selectable date
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF1565C0), // Darker blue for header
            hintColor: const Color(
              0xFF1565C0,
            ), // Darker blue for active elements
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF1565C0), // Darker blue for selected date
              onPrimary: Colors.white, // White text on selected date
              surface: Colors.white, // White background for the calendar
              onSurface: Colors.black, // Black text for unselected dates
            ),
            dialogBackgroundColor:
                Colors.white, // White background for the dialog
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      print("Date selected: ${pickedDate.toIso8601String()}");
      setState(() {
        birthdayController.text =
            pickedDate.toIso8601String().split('T')[0]; // Format as YYYY-MM-DD
      });
    } else {
      print("No date selected.");
    }
  }

  @override
  void initState() {
    super.initState();
    print("Initializing UserProfilePage...");
    fetchUserData();
  }

  @override
  void dispose() {
    print("Disposing controllers...");
    nameController.dispose();
    emailController.dispose();
    cityController.dispose();
    birthdayController.dispose();
    aboutMeController.dispose();
    super.dispose();
    print("Controllers disposed.");
  }

  @override
  Widget build(BuildContext context) {
    print("Building UserProfilePage...");
    return Scaffold(
      body: Stack(
        children: [
          // Light Blue Gradient Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFE3F2FD), const Color(0xFFFFFFFF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Starfish Image
          Positioned(
            left: 30,
            top: 240,
            width: 700,
            height: 700,
            child: Opacity(
              opacity: 0.7,
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
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('assets/images/starfish.png'),
                      backgroundColor: Colors.grey[300],
                    ),
                  ),

                  SizedBox(height: 40),

                  // User Info Fields
                  _buildUserInfo("Full Name", nameController),
                  SizedBox(height: 20),
                  _buildUserInfo("Email", emailController),
                  SizedBox(height: 20),
                  _buildUserInfo("City", cityController),
                  SizedBox(height: 20),
                  _buildBirthdayField(),

                  SizedBox(height: 30),

                  // About Me Section
                  Column(
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
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.90),
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
                          controller: aboutMeController,
                          enabled: editMode,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                          decoration: InputDecoration.collapsed(
                            hintText: 'Enter About Me',
                          ),
                          maxLines: null,
                        ),
                      ),
                      SizedBox(height: 70),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Edit/Save Button
          Positioned(
            top: 58,
            right: 30,
            child: GestureDetector(
              onTap: editMode ? saveChanges : toggleEditMode,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  width: 40,
                  height: 40,
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
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(String title, TextEditingController controller) {
    print("Building user info field: $title");
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
            color: Colors.white.withOpacity(0.90),
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
            enabled: editMode,
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            decoration: InputDecoration.collapsed(hintText: 'Enter $title'),
          ),
        ),
      ],
    );
  }

  Widget _buildBirthdayField() {
    print("Building birthday field...");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Birthday",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(context), // Open the date picker
          child: AbsorbPointer(
            // Prevent manual text input
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.90),
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
                controller: birthdayController,
                enabled: editMode,
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                decoration: InputDecoration.collapsed(
                  hintText: 'Select your birthday',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
