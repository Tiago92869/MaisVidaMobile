import 'package:flutter/material.dart';
import 'package:testtest/menu/models/tab_item.dart';

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
        stateMachine: "State Machine 1",
        artboard: "RULES",
      ),
    ),
    MenuItemModel(
      title: "Goals",
      riveIcon: TabItem(
        stateMachine: "State Machine 1",
        artboard: "SCORE",
      ),
    ),
    MenuItemModel(
      title: "Medicine",
      riveIcon: TabItem(stateMachine: "CHAT_Interactivity", artboard: "CHAT"),
    ),
    MenuItemModel(
      title: "Resources",
      riveIcon: TabItem(stateMachine: "SEARCH_Interactivity", artboard: "SEARCH"),
    ),
    MenuItemModel(
      title: "Activities",
      riveIcon: TabItem(
        stateMachine: "State Machine 1",
        artboard: "DASHBOARD",
      ),
    ),
  ];

  static List<MenuItemModel> menuItems2 = [
    MenuItemModel(
      title: "Notification",
      riveIcon: TabItem(stateMachine: "BELL_Interactivity", artboard: "BELL"),
    ),
    MenuItemModel(
      title: "SOS",
      riveIcon: TabItem(stateMachine: "TIMER_Interactivity", artboard: "TIMER"),
    ),
  ];
}
