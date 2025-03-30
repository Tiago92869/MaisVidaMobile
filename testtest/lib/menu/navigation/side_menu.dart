import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testtest/menu/components/menu_row.dart';
import 'package:testtest/menu/models/menu_item.dart';
import 'package:testtest/menu/theme.dart';
import 'dart:developer'; // Import the log function

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

  void onMenuPress(MenuItemModel menu) {
    print('SideMenu onMenuPress called for: ${menu.title}'); // Debugging print
    setState(() {
      _selectedMenu = menu.title;
      print('Selected menu updated to: $_selectedMenu'); // Debugging print
    });
    if (widget.onMenuPress != null) {
      widget.onMenuPress(menu.title);
      print('Callback to parent triggered with menu title: ${menu.title}'); // Debugging print
    } else {
      print('Error: widget.onMenuPress is null'); // Debugging print
    }
  }

  @override
  Widget build(BuildContext context) {
    log('Building SideMenu widget'); // Log when the SideMenu widget is built
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
                    const Text(
                      "Ashu",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontFamily: "Inter",
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Software Engineer",
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  MenuButtonSection(
                    title: "BROWSE",
                    selectedMenu: _selectedMenu,
                    menuIcons: _browseMenuIcons,
                    onMenuPress: (menu) {
                      print('MenuButtonSection onMenuPress called for: ${menu.title}'); // Debugging print
                      onMenuPress(menu);
                    },
                  ),
                  MenuButtonSection(
                    title: "HISTORY",
                    selectedMenu: _selectedMenu,
                    menuIcons: _historyMenuIcons,
                    onMenuPress: onMenuPress, // Ensure this is not null
                  ),
                ],
              ),
            ),
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
    log('Building MenuButtonSection: $title'); // Log when a MenuButtonSection is built
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
            top: 40,
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
