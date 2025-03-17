import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class TabItem {
  TabItem({this.stateMachine = "", this.artboard = "", this.status});

  UniqueKey? id = UniqueKey();
  String stateMachine;
  String artboard;
  late SMIBool? status;

  static List<TabItem> tabItemsList = [
    TabItem(stateMachine: "HOME_interactivity", artboard: "HOME"),
    TabItem(stateMachine: "State Machine 1", artboard: "RULES"),
    TabItem(stateMachine: "SEARCH_Interactivity", artboard: "SEARCH"),
    TabItem(stateMachine: "State Machine 1", artboard: "SCORE"),
    TabItem(stateMachine: "STAR_Interactivity", artboard: "LIKE/STAR"),
  ];
}
