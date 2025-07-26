import 'package:flutter/material.dart';
import 'package:testtest/profile/change_password.dart';
import 'package:testtest/services/user/user_repository.dart';
import 'package:testtest/services/user/user_service.dart';
import 'package:testtest/services/user/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

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

  String? profileImageBase64; // Variable to store the profile image as a base64 string
  User? currentUser; // Store the current user object

  void toggleEditMode() {
    setState(() {
      editMode = !editMode;
    });
  }

  Future<void> fetchUserData() async {
    try {
      // Fetch user data using getSimpleUser
      User user = await userRepository.getSimpleUser();
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
                  1,
                ) // Remove the "+" prefix for editing
                : user.emergencyContact;

        lastSavedFirstName = firstNameController.text;
        lastSavedFamilyName = familyNameController.text;
        lastSavedCity = cityController.text;
        lastSavedBirthday = birthdayController.text;
        lastSavedAboutMe = aboutMeController.text;
        lastSavedEmergencyContact = emergencyContactController.text;
        currentUser = user; // Store the fetched user object
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Falha ao procurar dados do utilizador. Tente novamente."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchUserProfileImage() async {
    try {
      final profileImage = await userRepository.userService.getProfileImage();
      final base64Image = profileImage.data.split(',').last;
      setState(() {
        profileImageBase64 = base64Image;
      });
    } catch (e) {
      // Não mostra mensagem de erro se não houver imagem de perfil
      setState(() {
        profileImageBase64 = null;
      });
    }
  }

  Future<void> showImageSelectionPopup() async {
    try {
      final images = await userRepository.userService.getAllImagePreviewsBase64();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1B263B), // Use the specified background color
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Imagem de perfil",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Display two images side by side
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: images.length,
                        itemBuilder: (BuildContext context, int index) {
                          final base64Image = images[index].data.split(',').last;
                          return GestureDetector(
                            onTap: () async {
                              setState(() {
                                profileImageBase64 = base64Image;
                              });

                              // Update the user's profileImage with the selected image's ID
                              if (currentUser != null) {
                                currentUser = User(
                                  id: currentUser!.id,
                                  firstName: currentUser!.firstName,
                                  secondName: currentUser!.secondName,
                                  email: currentUser!.email,
                                  city: currentUser!.city,
                                  aboutMe: currentUser!.aboutMe,
                                  dateOfBirth: currentUser!.dateOfBirth,
                                  emergencyContact: currentUser!.emergencyContact,
                                  profileImage: images[index].id, // Set the selected image ID
                                );

                                // Save the updated user data
                                await userRepository.updateUser(currentUser!);
                              }

                              Navigator.of(context).pop();
                            },
                            child: Image.memory(
                              base64Decode(base64Image),
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      print('Failed to fetch image previews: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Falha ao carregar as imagens."),
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
            content: Text("O primeiro nome não pode estar vazio."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (firstNameController.text.trim().contains(' ')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("O primeiro nome deve ser uma única palavra."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate Family Name (must not be empty)
      if (familyNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("O apelido não pode estar vazio."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate Birthdate (must not be empty)
      if (birthdayController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("A data de nascimento não pode estar vazia."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Allow empty Emergency Contact
      final emergencyContact =
          emergencyContactController.text.trim().isNotEmpty
              ? '+${emergencyContactController.text.trim()}'
              : ''; // Save as an empty string if the field is empty

      // Validate Emergency Contact Format (only if not empty)
      if (emergencyContact.isNotEmpty) {
        final emergencyContactRegex = RegExp(r'^\+\d{7,15}$');
        if (!emergencyContactRegex.hasMatch(emergencyContact)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "O contacto de emergência deve seguir o formato + seguido de 7 a 15 dígitos.",
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
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

      // Update secure storage with the new first name, family name, and emergency contact
      await _storage.write(key: 'firstName', value: updatedUser.firstName);
      await _storage.write(key: 'secondName', value: updatedUser.secondName);
      await _storage.write(
        key: 'emergencyContact',
        value: updatedUser.emergencyContact,
      );

      // Update the last saved values
      setState(() {
        lastSavedFirstName = firstNameController.text;
        lastSavedFamilyName = firstNameController.text;
        lastSavedCity = cityController.text;
        lastSavedBirthday = birthdayController.text;
        lastSavedAboutMe = aboutMeController.text;
        lastSavedEmergencyContact = emergencyContactController.text;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Dados guardados com sucesso!"),
          backgroundColor: Colors.green,
        ),
      );

      // Exit edit mode
      toggleEditMode();
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Falha ao guardar as alterações. Tente novamente."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> cancelEdit() async {
    if (editMode) {
      final discard = await _showDiscardChangesDialog();
      if (!discard) return;
    }
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
            primaryColor: const Color(0xFF0D1B2A),
            hintColor: const Color(0xFF0D1B2A),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D1B2A),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
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
    fetchUserProfileImage(); // Fetch the profile image on initialization
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
    return Material(
      child: WillPopScope(
        onWillPop: () async {
          // Só mostra o dialogo se algum campo foi alterado
          bool hasChanges =
              firstNameController.text != lastSavedFirstName ||
              familyNameController.text != lastSavedFamilyName ||
              cityController.text != lastSavedCity ||
              birthdayController.text != lastSavedBirthday ||
              aboutMeController.text != lastSavedAboutMe ||
              emergencyContactController.text != lastSavedEmergencyContact;

          if (editMode && hasChanges) {
            final discard = await _showDiscardChangesDialog();
            if (discard) {
              setState(() {
                firstNameController.text = lastSavedFirstName;
                familyNameController.text = lastSavedFamilyName;
                cityController.text = lastSavedCity;
                birthdayController.text = lastSavedBirthday;
                aboutMeController.text = lastSavedAboutMe;
                emergencyContactController.text = lastSavedEmergencyContact;
                editMode = false;
              });
              return false;
            } else {
              return false;
            }
          }
          // Se não houver alterações, apenas sai do modo de edição ou permite o pop normal
          if (editMode) {
            setState(() {
              editMode = false;
            });
            return false;
          }
          // Mantém a navegação para o menu conforme pedido
          Navigator.of(context).pushReplacementNamed('/menu');
          return false;
        },
        child: Scaffold(
          body: Stack(
        children: [
          // Background
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

          // Starfish Decorations
          Positioned(
            right: 80,
            top: -80,
            width: 400,
            height: 400,
            child: Opacity(
              opacity: 0.1,
              child: Transform.rotate(
                angle: 0.7,
                child: Image.asset(
                  'assets/images/starfish2.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            left: 100,
            top: 450,
            width: 400,
            height: 400,
            child: Opacity(
              opacity: 0.1,
              child: Transform.rotate(
                angle: 0.5,
                child: Image.asset(
                  'assets/images/starfish1.png',
                  fit: BoxFit.contain,
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

                    // Profile Image with Add Image Icon
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 75,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: (profileImageBase64 != null && profileImageBase64!.isNotEmpty)
                                ? MemoryImage(base64Decode(profileImageBase64!))
                                : null,
                            child: (profileImageBase64 == null || profileImageBase64!.isEmpty)
                                ? const Icon(Icons.person, size: 70, color: Colors.grey)
                                : null,
                          ),
                          if (editMode)
                            IconButton(
                              icon: const Icon(Icons.add_a_photo, color: Colors.white, size: 30),
                              onPressed: showImageSelectionPopup,
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // User Info Fields
                    _buildUserInfo("Primeiro nome", firstNameController),
                    const SizedBox(height: 20),
                    _buildUserInfo("Apelido", familyNameController),
                    const SizedBox(height: 20),
                    _buildUserInfo(
                      "E-mail",
                      emailController,
                      editable: false,
                    ), // Email is not editable
                    const SizedBox(height: 20),
                    _buildUserInfo("Cidade", cityController),
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
                          "Sobre mim",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(221, 255, 255, 255),
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
                              hintText: 'Sobre mim',
                            ),
                            maxLines: null,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Reset Password Button
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChangePasswordPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white, // Button color
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Alterar palavra-passe",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D1B2A),
                              ),
                            ),
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
                    onTap: () async {
                      await cancelEdit();
                    },
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
                        color: const Color(0xFF0D1B2A),
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
      ),
      ),
    );
  }

  Widget _buildUserInfo(
    String title,
    TextEditingController controller, {
    bool editable = true,
  }) {
    String hint = title;
    if (title == "Primeiro nome") hint = "Primeiro nome";
    if (title == "Apelido") hint = "Apelido";
    if (title == "Cidade") hint = "Cidade";
    if (title == "E-mail") hint = "E-mail";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
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
          child: TextField(
            controller: controller,
            enabled: editable && editMode,
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            decoration: InputDecoration.collapsed(hintText: hint),
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
          "Data de nascimento",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(221, 255, 255, 255),
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
                  hintText: 'Seleciona a sua data de nascimento',
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
          "Contacto de emergência",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(221, 255, 255, 255),
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
                    hintText: 'Contacto de emergência',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool> _showDiscardChangesDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0D1B2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Guardar Dados",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                "Tem a certeza que não quer guardar os dados alterados?",
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    "Voltar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    "Sim",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
