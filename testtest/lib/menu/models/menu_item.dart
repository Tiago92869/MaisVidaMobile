import 'package:flutter/material.dart';
import 'package:mentara/menu/models/tab_item.dart';

class MenuItemModel {
  MenuItemModel({this.id, this.title = "", required this.riveIcon});

  UniqueKey? id = UniqueKey();
  String title;
  TabItem riveIcon;

  static List<MenuItemModel> menuItems = [
    MenuItemModel(
      title: "Menu",
      riveIcon: TabItem(stateMachine: "HOME_interactivity", artboard: "HOME"),
    ),
    MenuItemModel(
      title: "Diário",
      riveIcon: TabItem(
        stateMachine: "State Machine 1",
        artboard: "RULES",
      ),
    ),
    MenuItemModel(
      title: "Metas",
      riveIcon: TabItem(
        stateMachine: "State Machine 1",
        artboard: "SCORE",
      ),
    ),
    MenuItemModel(
      title: "Medicação",
      riveIcon: TabItem(stateMachine: "CHAT_Interactivity", artboard: "CHAT"),
    ),
    MenuItemModel(
      title: "Recursos",
      riveIcon: TabItem(stateMachine: "SEARCH_Interactivity", artboard: "SEARCH"),
    ),
    MenuItemModel(
      title: "Atividades",
      riveIcon: TabItem(
        stateMachine: "State Machine 1",
        artboard: "DASHBOARD",
      ),
    ),
    MenuItemModel(
      title: "Jornadas",
      riveIcon: TabItem(stateMachine: "State Machine 1", artboard: "ONLINE"),
    ),
    MenuItemModel(
      title: "Notificações",
      riveIcon: TabItem(stateMachine: "BELL_Interactivity", artboard: "BELL"),
    ),
    MenuItemModel(
      title: "SOS",
      riveIcon: TabItem(stateMachine: "TIMER_Interactivity", artboard: "TIMER"),
    ),
  ];
}
