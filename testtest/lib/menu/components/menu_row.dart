import 'package:flutter/material.dart';
import 'package:mentara/menu/models/menu_item.dart';

class MenuRow extends StatelessWidget {
  const MenuRow({
    Key? key,
    required this.menu,
    required this.selectedMenu,
    required this.emoji,
    this.onMenuPress,
  }) : super(key: key);

  final MenuItemModel menu;
  final String selectedMenu;
  final String emoji;
  final VoidCallback? onMenuPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: selectedMenu == menu.title
            ? Colors.white.withOpacity(0.2)
            : Colors.transparent,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: selectedMenu == menu.title
                ? Colors.white.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(
          menu.title,
          style: TextStyle(
            color: selectedMenu == menu.title
                ? Colors.white
                : Colors.white.withOpacity(0.7),
            fontSize: 16,
            fontFamily: "Inter",
            fontWeight: selectedMenu == menu.title
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
        onTap: onMenuPress,
      ),
    );
  }
}
