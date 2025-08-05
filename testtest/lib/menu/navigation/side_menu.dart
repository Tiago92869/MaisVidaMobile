import 'package:flutter/material.dart';
import 'package:maisvida/menu/components/menu_row.dart';
import 'package:maisvida/menu/models/menu_item.dart';
import 'package:maisvida/menu/theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_scroll_shadow/flutter_scroll_shadow.dart';

import 'package:maisvida/services/user/user_service.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({Key? key, required this.onMenuPress}) : super(key: key);

  final Function(String menuTitle) onMenuPress;

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final List<MenuItemModel> _browseMenuIcons = MenuItemModel.menuItems;
  String _selectedMenu = MenuItemModel.menuItems[0].title;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Variables to store user data
  String _userName = "Não encontrado";
  String _userEmail = "Não encontrado";

  // Emoji mapping for menu items
  final Map<String, String> _menuEmojiMap = {
    'Menu': '🏠',
    'Diário': '📝',
    'Metas': '🎯',
    'Medicação': '💊',
    'Recursos': '📑',
    'Atividades': '📖',
    'Jornadas': '✨',
    'Notificações': '🔔',
    'SOS': '🚨',
  };

  @override
  void initState() {
    super.initState();
    _fetchUserData();
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
      // Optionally, show a fallback or error message
    }
  }

  String _limitString(String text, int maxLength) {
    if (text.length > maxLength) {
      return "${text.substring(0, maxLength)}...";
    }
    return text;
  }

  void onMenuPress(MenuItemModel menu) {
    setState(() {
      _selectedMenu = menu.title;
    });
    widget.onMenuPress(menu.title);
    }

  Future<bool> _showLogoutConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0D1B2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Sair",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                "Tem a certeza que deseja sair da aplicação?",
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    "Não",
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
            child: ScrollShadow(
              color: Colors.white.withOpacity(0.3),
              size: 20.0,
              fadeInCurve: Curves.easeIn,
              fadeOutCurve: Curves.easeOut,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    MenuButtonSection(
                      selectedMenu: _selectedMenu,
                      menuIcons: _browseMenuIcons,
                      menuEmojiMap: _menuEmojiMap,
                      onMenuPress: onMenuPress,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.white54,
            thickness: 1,
            height: 1, // Add this to remove extra spacing
          ),
          ListTile(
            contentPadding: const EdgeInsets.only(left: 28),
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              "Sair",
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontFamily: "Inter",
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () async {
              final shouldLogout = await _showLogoutConfirmationDialog();
              if (shouldLogout) {
                final userService = UserService();
                await userService.logout();
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
    );
  }
}

class MenuButtonSection extends StatelessWidget {
  const MenuButtonSection({
    super.key,
    required this.menuIcons,
    required this.menuEmojiMap,
    this.selectedMenu = "Home",
    this.onMenuPress,
  });

  final String selectedMenu;
  final List<MenuItemModel> menuIcons;
  final Map<String, String> menuEmojiMap;
  final Function(MenuItemModel menu)? onMenuPress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
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
                  emoji: menuEmojiMap[menu.title] ?? '📋',
                  isHighlighted: menu.title == 'Jornadas',
                  onMenuPress: () {
                    if (onMenuPress != null) {
                      onMenuPress!(menu);
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
