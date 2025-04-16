import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' hide LinearGradient;
import 'package:testtest/activities/activities_page.dart';
import 'package:testtest/diary/diary_page.dart';
import 'package:testtest/goals/goals_page.dart';
import 'package:testtest/medicines/medicines_page.dart';
import 'package:testtest/menu/components/day_night_switch.dart';
import 'package:testtest/menu/models/menu_item.dart';
import 'dart:math' as math;
import 'package:testtest/menu/navigation/custom_tab_bar.dart';
import 'package:testtest/menu/navigation/home_tab_view.dart';
import 'package:testtest/menu/navigation/side_menu.dart';
import 'package:testtest/notifications/notifications_page.dart';
import 'package:testtest/resources/resources_page.dart';
import 'package:testtest/sos/sos_details_page.dart';
import 'package:testtest/menu/theme.dart';
import 'package:testtest/menu/assets.dart' as app_assets;
import 'package:testtest/profile/user_profile.dart'; // Import the user_profile.dart

// Common Tab Scene for the tabs other than 1st one, showing only tab name in center
Widget commonTabScene(String tabName) {
  if (tabName == "Profile") {
    return UserProfilePage(); // Return the user profile page directly
  }
  if (tabName == "Resources") {
    return ResourcesPage(); // Return the resources page directly
  }
  if (tabName == "Diary") {
    return const DiaryPage(); // Return the activities page directly
  }
  if (tabName == "Goals") {
    return const GoalsPage(); // Return the activities page directly
  }
  if (tabName == "Activities") {
    return const ActivitiesPage(); // Return the activities page directly
  }
  if (tabName == "Medicine") {
    return MedicinesPage(); // Return the activities page directly
  }
  if (tabName == "Notifications") {
    return NotificationsPage(); // Return the resources page directly
  }
  if (tabName == "SOS") {
    return SosDetailsPage(); // Return the activities page directly
  }
  return Container(
    color: RiveAppTheme.background,
    alignment: Alignment.center,
    child: Text(
      tabName,
      style: const TextStyle(
        fontSize: 28,
        fontFamily: "Poppins",
        color: Colors.black,
      ),
    ),
  );
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  static const String route = '/course-rive';

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  late AnimationController? _animationController;
  late AnimationController? _onBoardingAnimController;
  late Animation<double> _onBoardingAnim;
  late Animation<double> _sidebarAnim;

  late SMIBool _menuBtn;

  bool _showOnBoarding = false;
  bool _isDarkMode = false;

  // Reference to HomeTabView
  late HomeTabView _homeTabView;

  // Initialize _tabBody with a fallback widget
  Widget _tabBody = Container(
    color: Colors.red, // Fallback color for debugging
    alignment: Alignment.center,
    child: const Text(
      "Invalid Tab",
      style: TextStyle(fontSize: 20, color: Colors.white),
    ),
  );

  // Screens list
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    // Initialize HomeTabView
    _homeTabView = HomeTabView(
      onTabChange: (tabIndex) {
        setState(() {
          if (tabIndex >= 0 && tabIndex < _screens.length) {
            _tabBody = _screens[tabIndex];
          } else {
            print('Invalid tab index: $tabIndex');
          }
        });
      },
    );

    // Initialize _screens with HomeTabView as the first element
    _screens = [
      _homeTabView, // Add HomeTabView as the first screen
      commonTabScene("Diary"),
      commonTabScene("Goals"),
      commonTabScene("Medicine"),
      commonTabScene("Resources"),
      commonTabScene("Activities"),
      commonTabScene("Notifications"),
      commonTabScene("SOS"),
      commonTabScene("Profile"),
    ];

    // Set the initial tab body
    _tabBody = _screens.first;

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      upperBound: 1,
      vsync: this,
    );
    _onBoardingAnimController = AnimationController(
      duration: const Duration(milliseconds: 350),
      upperBound: 1,
      vsync: this,
    );

    _sidebarAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.linear),
    );

    _onBoardingAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _onBoardingAnimController!, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _onBoardingAnimController?.dispose();
    super.dispose();
  }

  void _onMenuIconInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      "State Machine",
    );
    artboard.addController(controller!);
    _menuBtn = controller.findInput<bool>("isOpen") as SMIBool;
    _menuBtn.value = true;
  }

  void onMenuPress() {
    if (_menuBtn.value) {
      final springAnim = SpringSimulation(
        const SpringDescription(mass: 0.1, stiffness: 40, damping: 5),
        0,
        1,
        0,
      );
      _animationController?.animateWith(springAnim);
    } else {
      _animationController?.reverse();
    }
    _menuBtn.change(!_menuBtn.value);
  }

  void _updateTabBody(String menuTitle) {
    print('Updating tab body for menu title: $menuTitle'); // Debugging print

    // Handle "User" menu title explicitly
    if (menuTitle == "User") {
      print('Menu title is "User", setting index to 8'); // Debugging print
      setState(() {
        _tabBody = _screens[8]; // Index for "User"
      });
      return;
    }

    // Search in menuItems
    int index = MenuItemModel.menuItems.indexWhere(
      (menuItem) => menuItem.title == menuTitle,
    );

    if (index == -1) {
      // If not found in menuItems, search in menuItems2
      index = MenuItemModel.menuItems2.indexWhere(
        (menuItem) => menuItem.title == menuTitle,
      );

      if (index != -1) {
        // Adjust the index to match the position in _screens
        index += MenuItemModel.menuItems.length;
      }
    }

    if (index != -1) {
      print('Menu title found at index: $index'); // Debugging print
      setState(() {
        _tabBody = _screens[index];
      });
    } else {
      print('Error: Invalid menu title or index');
      setState(() {
        _tabBody = Container(
          color: Colors.red,
          alignment: Alignment.center,
          child: const Text(
            "Invalid Tab",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned(child: Container(color: RiveAppTheme.background2)),
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _sidebarAnim,
              builder: (BuildContext context, Widget? child) {
                return Transform(
                  alignment: Alignment.center,
                  transform:
                      Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(
                          ((1 - _sidebarAnim.value) * -30) * math.pi / 180,
                        )
                        ..translate((1 - _sidebarAnim.value) * -300),
                  child: child,
                );
              },
              child: FadeTransition(
                opacity: _sidebarAnim,
                child: SideMenu(
                  onMenuPress: _updateTabBody, // Pass the callback here
                ),
              ),
            ),
          ),
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _showOnBoarding ? _onBoardingAnim : _sidebarAnim,
              builder: (context, child) {
                return Transform.scale(
                  scale:
                      1 -
                      (_showOnBoarding
                          ? _onBoardingAnim.value * 0.08
                          : _sidebarAnim.value * 0.1),
                  child: Transform.translate(
                    offset: Offset(_sidebarAnim.value * 265, 0),
                    child: Transform(
                      alignment: Alignment.center,
                      transform:
                          Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(
                              (_sidebarAnim.value * 30) * math.pi / 180,
                            ),
                      child: child,
                    ),
                  ),
                );
              },
              child: Stack(
                children: [
                  _tabBody,
                  Positioned(
                    top: 55,
                    right: 20,
                    child: DayNightSwitch(
                      value: _isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          _isDarkMode = value;
                          print(
                            _isDarkMode
                                ? "Switched to Dark Mode"
                                : "Switched to Light Mode",
                          );
                        });
                      },
                      sunColor: const Color(0xFFFDB813),
                      moonColor: const Color(0xFFf5f3ce),
                      dayColor: const Color(0xFF87CEEB),
                      nightColor: const Color(0xFF003366),
                    ),
                  ),
                ],
              ),
            ),
          ),
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _sidebarAnim,
              builder: (context, child) {
                return SafeArea(
                  child: Row(
                    children: [
                      SizedBox(width: _sidebarAnim.value * 216),
                      child!,
                    ],
                  ),
                );
              },
              child: GestureDetector(
                onTap: onMenuPress,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    width: 44,
                    height: 44,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(44 / 2),
                      boxShadow: [
                        BoxShadow(
                          color: RiveAppTheme.shadow.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: RiveAnimation.asset(
                      app_assets.menuButtonRiv,
                      stateMachines: const ["State Machine"],
                      animations: const ["open", "close"],
                      onInit: _onMenuIconInit,
                    ),
                  ),
                ),
              ),
            ),
          ),
          IgnorePointer(
            ignoring: true,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedBuilder(
                animation: !_showOnBoarding ? _sidebarAnim : _onBoardingAnim,
                builder: (context, child) {
                  return Container(
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          RiveAppTheme.background.withOpacity(0),
                          RiveAppTheme.background.withOpacity(
                            0.35 -
                                (!_showOnBoarding
                                    ? _sidebarAnim.value * 0.3
                                    : _onBoardingAnim.value * 0.3),
                          ),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar(),
    );
  }

  Widget bottomNavigationBar() {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: !_showOnBoarding ? _sidebarAnim : _onBoardingAnim,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              !_showOnBoarding
                  ? _sidebarAnim.value * 300
                  : _onBoardingAnim.value * 200,
            ),
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomTabBar(
              onTabChange: (tabIndex) {
                setState(() {
                  if (tabIndex == 0) {
                    _tabBody = _screens.first;
                  }
                  if (tabIndex == 1) {
                    _tabBody = _screens[1];
                  }
                  if (tabIndex == 2) {
                    _tabBody = _screens[4];
                  }
                  if (tabIndex == 3) {
                    _tabBody = _screens[2];
                  }
                  if (tabIndex == 4) {
                    _tabBody = _screens[8];
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
