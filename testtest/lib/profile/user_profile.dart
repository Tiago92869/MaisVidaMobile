import 'package:flutter/material.dart';
import 'package:testtest/services/user/user_repository.dart';
import 'package:testtest/services/user/user_service.dart';
import 'package:testtest/services/user/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool editMode = false;

  // Controllers for text fields
  TextEditingController firstNameController = TextEditingController();
  TextEditingController familyNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController birthdayController = TextEditingController();
  TextEditingController aboutMeController = TextEditingController();
  TextEditingController emergencyContactController = TextEditingController();

  // Variables to store the last saved values
  String lastSavedFirstName = "";
  String lastSavedFamilyName = "";
  String lastSavedCity = "";
  String lastSavedBirthday = "";
  String lastSavedAboutMe = "";
  String lastSavedEmergencyContact = "";

  // UserRepository instance
  final UserRepository userRepository = UserRepository(
    userService: UserService(),
  );

  // Secure storage instance
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  void toggleEditMode() {
    setState(() {
      editMode = !editMode;
    });
  }

  Future<void> fetchUserData() async {
    try {
      User user = await userRepository.getUserById();
      setState(() {
        firstNameController.text = user.firstName;
        familyNameController.text = user.secondName;
        emailController.text =
            user.email; // Email is pre-filled but not editable
        cityController.text = user.city;
        birthdayController.text =
            user.dateOfBirth.toIso8601String().split('T')[0];
        aboutMeController.text = user.aboutMe;
        emergencyContactController.text =
            user.emergencyContact.startsWith('+')
                ? user.emergencyContact.substring(
                  2,
                ) // Remove the "+" prefix for editing
                : user.emergencyContact;

        lastSavedFirstName = firstNameController.text;
        lastSavedFamilyName = familyNameController.text;
        lastSavedCity = cityController.text;
        lastSavedBirthday = birthdayController.text;
        lastSavedAboutMe = aboutMeController.text;
        lastSavedEmergencyContact = emergencyContactController.text;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to fetch user data. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> saveChanges() async {
    try {
      // Validate First Name (must not be empty and only one word)
      if (firstNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("First Name cannot be empty."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (firstNameController.text.trim().contains(' ')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("First Name must be a single word."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate Family Name (must not be empty)
      if (familyNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Family Name cannot be empty."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate Birthdate (must not be empty)
      if (birthdayController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Birthdate cannot be empty."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate Emergency Contact Format
      final emergencyContact = '+${emergencyContactController.text.trim()}';
      final emergencyContactRegex = RegExp(r'^\+\d{7,15}$');
      if (!emergencyContactRegex.hasMatch(emergencyContact)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Emergency Contact must follow the format + followed by 7 to 15 digits.",
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create updated user object
      User updatedUser = User(
        id: "user-id-placeholder", // Replace with actual user ID if available
        firstName: firstNameController.text.trim(),
        secondName: familyNameController.text.trim(),
        email: emailController.text, // Email remains unchanged
        city: cityController.text.trim(),
        aboutMe: aboutMeController.text.trim(),
        dateOfBirth: DateTime.parse(birthdayController.text),
        emergencyContact: emergencyContact,
      );

      // Update user in the repository
      await userRepository.updateUser(updatedUser);

      // Update secure storage with the new first name and family name
      await _storage.write(key: 'firstName', value: updatedUser.firstName);
      await _storage.write(key: 'secondName', value: updatedUser.secondName);

      // Update the last saved values
      setState(() {
        lastSavedFirstName = firstNameController.text;
        lastSavedFamilyName = familyNameController.text;
        lastSavedCity = cityController.text;
        lastSavedBirthday = birthdayController.text;
        lastSavedAboutMe = aboutMeController.text;
        lastSavedEmergencyContact = emergencyContactController.text;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      // Exit edit mode
      toggleEditMode();
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save changes. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void cancelEdit() {
    setState(() {
      firstNameController.text = lastSavedFirstName;
      familyNameController.text = lastSavedFamilyName;
      cityController.text = lastSavedCity;
      birthdayController.text = lastSavedBirthday;
      aboutMeController.text = lastSavedAboutMe;
      emergencyContactController.text = lastSavedEmergencyContact;
      editMode = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color.fromRGBO(
              72,
              85,
              204,
              1,
            ), // Header background color
            hintColor: const Color.fromRGBO(
              123,
              144,
              255,
              1,
            ), // Selected date color
            colorScheme: const ColorScheme.light(
              primary: Color.fromRGBO(72, 85, 204, 1), // Header text color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            dialogBackgroundColor:
                Colors.white, // Background color of the calendar
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        birthdayController.text = pickedDate.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _refreshPage() async {
    await fetchUserData(); // Re-fetch user data
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    familyNameController.dispose();
    emailController.dispose();
    cityController.dispose();
    birthdayController.dispose();
    aboutMeController.dispose();
    emergencyContactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
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

          // Content with RefreshIndicator
          RefreshIndicator(
            onRefresh: _refreshPage, // Trigger refresh logic
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(), // Ensure scrollable even if content is small
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // Profile Image
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: const AssetImage(
                          'assets/images/starfish.png',
                        ),
                        backgroundColor: Colors.grey[300],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // User Info Fields
                    _buildUserInfo("First Name", firstNameController),
                    const SizedBox(height: 20),
                    _buildUserInfo("Family Name", familyNameController),
                    const SizedBox(height: 20),
                    _buildUserInfo(
                      "Email",
                      emailController,
                      editable: false,
                    ), // Email is not editable
                    const SizedBox(height: 20),
                    _buildUserInfo("City", cityController),
                    const SizedBox(height: 20),
                    _buildBirthdayField(),
                    const SizedBox(height: 20),
                    _buildEmergencyContactField(),

                    const SizedBox(height: 30),

                    // About Me Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "About Me",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
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
                          child: TextField(
                            controller: aboutMeController,
                            enabled: editMode,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                            ),
                            decoration: const InputDecoration.collapsed(
                              hintText: 'Enter About Me',
                            ),
                            maxLines: null,
                          ),
                        ),
                        const SizedBox(height: 70),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Edit/Save/Cancel Buttons
          Positioned(
            top: 58,
            right: 30,
            child: Row(
              children: [
                if (editMode)
                  GestureDetector(
                    onTap: cancelEdit,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                GestureDetector(
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
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        editMode ? Icons.save : Icons.edit,
                        color: const Color.fromRGBO(85, 123, 233, 1),
                        size: 28,
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

  Widget _buildUserInfo(
    String title,
    TextEditingController controller, {
    bool editable = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
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
          child: TextField(
            controller: controller,
            enabled: editable && editMode,
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            decoration: InputDecoration.collapsed(hintText: 'Enter $title'),
          ),
        ),
      ],
    );
  }

  Widget _buildBirthdayField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Birthday",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: AbsorbPointer(
            child: Container(
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
              child: TextField(
                controller: birthdayController,
                enabled: editMode,
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                decoration: const InputDecoration.collapsed(
                  hintText: 'Select your birthday',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyContactField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Emergency Contact",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
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
              const Icon(
                Icons.add, // Plus icon
                color: Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: emergencyContactController,
                  enabled: editMode,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Enter Phone Number', // No placeholder text
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
