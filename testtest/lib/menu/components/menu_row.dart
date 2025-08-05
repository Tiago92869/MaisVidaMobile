import 'package:flutter/material.dart';
import 'package:maisvida/menu/models/menu_item.dart';

class MenuRow extends StatelessWidget {
  const MenuRow({
    Key? key,
    required this.menu,
    required this.selectedMenu,
    required this.emoji,
    this.onMenuPress,
    this.isHighlighted = false,
  }) : super(key: key);

  final MenuItemModel menu;
  final String selectedMenu;
  final String emoji;
  final VoidCallback? onMenuPress;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedMenu == menu.title;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isSelected
            ? (isHighlighted ? Colors.amber.withOpacity(0.3) : Colors.white.withOpacity(0.2))
            : (isHighlighted ? Colors.amber.withOpacity(0.1) : Colors.transparent),
        border: isHighlighted
            ? Border.all(color: Colors.amber.withOpacity(0.5), width: 1)
            : null,
        boxShadow: isHighlighted
            ? [
          BoxShadow(
            color: Colors.amber.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ]
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isSelected
                ? (isHighlighted ? Colors.amber.withOpacity(0.4) : Colors.white.withOpacity(0.3))
                : (isHighlighted ? Colors.amber.withOpacity(0.2) : Colors.white.withOpacity(0.1)),
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
            color: isSelected
                ? Colors.white
                : (isHighlighted ? Colors.amber.shade200 : Colors.white.withOpacity(0.7)),
            fontSize: 16,
            fontFamily: "Inter",
            fontWeight: isSelected
                ? FontWeight.w600
                : (isHighlighted ? FontWeight.w500 : FontWeight.w400),
          ),
        ),
        trailing: isHighlighted
            ? Icon(
          Icons.star,
          color: Colors.amber.withOpacity(0.8),
          size: 16,
        )
            : null,
        onTap: onMenuPress,
      ),
    );
  }
}
