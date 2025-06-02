import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testtest/menu/components/menu_row.dart';
import 'package:testtest/menu/models/menu_item.dart';
import 'package:testtest/menu/theme.dart';
import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:testtest/services/user/user_service.dart'; // Import the log function

class SideMenu extends StatefulWidget {
  const SideMenu({Key? key, required this.onMenuPress}) : super(key: key);

  final Function(String menuTitle) onMenuPress;

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final List<MenuItemModel> _browseMenuIcons = MenuItemModel.menuItems;
  final List<MenuItemModel> _historyMenuIcons = MenuItemModel.menuItems2;
  String _selectedMenu = MenuItemModel.menuItems[0].title;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Variables to store user data
  String _userName = "Não encontrado";
  String _userEmail = "Não encontrado";

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data when the menu is initialized
  }

  Future<void> _fetchUserData() async {
    try {
      // Retrieve the user's first name, second name, and email from secure storage
      final firstName = await _storage.read(key: 'firstName') ?? "";
      final secondName = await _storage.read(key: 'secondName') ?? "";
      final email = await _storage.read(key: 'email') ?? "";

      // Limit the size of the name and email strings
      final String limitedName = _limitString(
        "$firstName $secondName",
        15,
      ); // Limit to 20 characters
      final String limitedEmail = _limitString(
        email,
        18,
      ); // Limit to 30 characters

      setState(() {
        _userName = limitedName;
        _userEmail = limitedEmail;
      });
    } catch (e) {
      print("Error fetching user data: $e");
      // Optionally, show a fallback or error message
    }
  }

  String _limitString(String text, int maxLength) {
    if (text.length > maxLength) {
      return text.substring(0, maxLength) + "...";
    }
    return text;
  }

  void onMenuPress(MenuItemModel menu) {
    setState(() {
      _selectedMenu = menu.title;
    });
    if (widget.onMenuPress != null) {
      widget.onMenuPress(menu.title);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        bottom: MediaQuery.of(context).padding.bottom - 60,
      ),
      constraints: const BoxConstraints(maxWidth: 288),
      decoration: BoxDecoration(
        color: RiveAppTheme.background2,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () {
                widget.onMenuPress("User");
              },
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.person_outline),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontFamily: "Inter",
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _userEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 15,
                          fontFamily: "Inter",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  MenuButtonSection(
                    title: "Navegar",
                    selectedMenu: _selectedMenu,
                    menuIcons: _browseMenuIcons,
                    onMenuPress: onMenuPress,
                  ),
                  MenuButtonSection(
                    title: "Histórico",
                    selectedMenu: _selectedMenu,
                    menuIcons: _historyMenuIcons,
                    onMenuPress: onMenuPress,
                  ),
                ],
              ),
            ),
          ),
          const Divider(
            color: Colors.white54,
            thickness: 1,
          ), // Divider before Logout
          ListTile(
            contentPadding: const EdgeInsets.only(
              left: 28,
            ), // Add padding to the left
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ), // Set icon color to red
            title: const Text(
              "Sair",
              style: TextStyle(
                color: Colors.red, // Set text color to red
                fontSize: 16,
                fontFamily: "Inter",
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () async {
              final userService = UserService();
              await userService.logout(); // Call the logout method
              Navigator.pushReplacementNamed(
                context,
                '/login',
              ); // Redirect to login screen
            },
          ),
        ],
      ),
    );
  }
}

class MenuButtonSection extends StatelessWidget {
  const MenuButtonSection({
    Key? key,
    required this.title,
    required this.menuIcons,
    this.selectedMenu = "Home",
    this.onMenuPress,
  }) : super(key: key);

  final String title;
  final String selectedMenu;
  final List<MenuItemModel> menuIcons;
  final Function(MenuItemModel menu)? onMenuPress;

  @override
  Widget build(BuildContext context) {
    log(
      'Building MenuButtonSection: $title',
    ); // Log when a MenuButtonSection is built
    if (onMenuPress == null) {
      log('Warning: onMenuPress is null in MenuButtonSection: $title');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 10,
            bottom: 8,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 15,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          child: Column(
            children: [
              for (var menu in menuIcons) ...[
                Divider(
                  color: Colors.white.withOpacity(0.1),
                  thickness: 1,
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                MenuRow(
                  menu: menu,
                  selectedMenu: selectedMenu,
                  onMenuPress: () {
                    print('MenuRow pressed: ${menu.title}');
                    if (onMenuPress != null) {
                      onMenuPress!(menu);
                    } else {
                      print('Error: onMenuPress is null in MenuRow');
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
