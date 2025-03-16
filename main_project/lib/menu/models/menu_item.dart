import 'package:flutter/material.dart';
import 'package:main_project/menu/models/tab_item.dart';

class MenuItemModel {
  MenuItemModel({this.id, this.title = "", required this.riveIcon});

  UniqueKey? id = UniqueKey();
  String title;
  TabItem riveIcon;

  static List<MenuItemModel> menuItems = [
    MenuItemModel(
      title: "Home",
      riveIcon: TabItem(stateMachine: "HOME_interactivity", artboard: "HOME"),
    ),
    MenuItemModel(
      title: "Diary",
      riveIcon: TabItem(
        stateMachine: "SEARCH_Interactivity",
        artboard: "SEARCH",
      ),
    ),
    MenuItemModel(
      title: "Goals",
      riveIcon: TabItem(
        stateMachine: "STAR_Interactivity",
        artboard: "LIKE/STAR",
      ),
    ),
    MenuItemModel(
      title: "Medicine",
      riveIcon: TabItem(stateMachine: "CHAT_Interactivity", artboard: "CHAT"),
    ),
    MenuItemModel(
      title: "Resources",
      riveIcon: TabItem(stateMachine: "HOME_interactivity", artboard: "HOME"),
    ),
    MenuItemModel(
      title: "Activities",
      riveIcon: TabItem(
        stateMachine: "SEARCH_Interactivity",
        artboard: "SEARCH",
      ),
    ),
  ];

  static List<MenuItemModel> menuItems2 = [
    MenuItemModel(
      title: "History",
      riveIcon: TabItem(stateMachine: "TIMER_Interactivity", artboard: "TIMER"),
    ),
    MenuItemModel(
      title: "Notification",
      riveIcon: TabItem(stateMachine: "BELL_Interactivity", artboard: "BELL"),
    ),
    MenuItemModel(
      title: "SOS",
      riveIcon: TabItem(stateMachine: "TIMER_Interactivity", artboard: "TIMER"),
    ),
  ];

  static List<MenuItemModel> menuItems3 = [
    MenuItemModel(
      title: "Dark Mode",
      riveIcon: TabItem(
        stateMachine: "SETTINGS_Interactivity",
        artboard: "SETTINGS",
      ),
    ),
  ];
}
