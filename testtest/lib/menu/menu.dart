import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive hide LinearGradient;
import 'package:mentara/activities/activities_page.dart';
import 'package:mentara/diary/diary_page.dart';
import 'package:mentara/goals/goals_page.dart';
import 'package:mentara/medicines/medicines_page.dart';
import 'package:mentara/menu/models/menu_item.dart';
import 'dart:math' as math;
import 'package:mentara/menu/navigation/custom_tab_bar.dart';
import 'package:mentara/menu/navigation/home_tab_view.dart';
import 'package:mentara/menu/navigation/side_menu.dart';
import 'package:mentara/notifications/notifications_page.dart';
import 'package:mentara/resources/resources_page.dart';
import 'package:mentara/sos/sos_details_page.dart';
import 'package:mentara/menu/theme.dart';
import 'package:mentara/menu/assets.dart' as app_assets;
import 'package:mentara/profile/user_profile.dart'; // Import the user_profile.dart
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:mentara/journey/journey_page.dart';
import 'package:mentara/services/user/user_service.dart'; // Import UserService
import 'package:mentara/services/user/user_model.dart'; // Import UserModel

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
  if (tabName == "Journey") {
    return JourneyPage(); // Return the journey page directly
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
  final UserService _userService = UserService(); // Initialize UserService
  late AnimationController? _animationController;
  late AnimationController? _onBoardingAnimController;
  late Animation<double> _onBoardingAnim;
  late Animation<double> _sidebarAnim;

  late rive.SMIBool _menuBtn;

  bool _showOnBoarding = false;
  bool _isDarkMode = false; // Default value for dark mode

  // Reference to HomeTabView
  late HomeTabView _homeTabView;

  // Initialize _tabBody with a fallback widget
  Widget _tabBody = Container(
    color: Colors.red, // Fallback color for debugging
    alignment: Alignment.center,
    child: const Text(
      "Menu inválido",
      style: TextStyle(fontSize: 20, color: Colors.white),
    ),
  );

  // Screens list
  late final List<Widget> _screens;

  int _currentTabIndex = 0; // Track the current tab index

  @override
  void initState() {
    super.initState();

    // Load the saved theme mode
    _loadThemeMode();

    // Initialize HomeTabView
    _homeTabView = HomeTabView(
      onTabChange: (tabIndex) {
        setState(() {
          if (tabIndex >= 0 && tabIndex < _screens.length) {
            _tabBody = _screens[tabIndex];
            _currentTabIndex = tabIndex;
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
      commonTabScene("Journey"),
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

  // Load the saved theme mode from SharedPreferences
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode =
          prefs.getBool('isDarkMode') ?? false; // Default to light mode
    });
  }

  void _onMenuIconInit(rive.Artboard artboard) {
    final controller = rive.StateMachineController.fromArtboard(
      artboard,
      "State Machine",
    );
    artboard.addController(controller!);
    _menuBtn = controller.findInput<bool>("isOpen") as rive.SMIBool;
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
        _tabBody = _screens[9]; // Index for "User"
        _currentTabIndex = 9; // Update the current tab index
      });
      return;
    }

    // Search in menuItems
    int index = MenuItemModel.menuItems.indexWhere(
      (menuItem) => menuItem.title == menuTitle,
    );

    if (index != -1) {
      print('Menu title found at index: $index'); // Debugging print
      setState(() {
        _tabBody = _screens[index];
        _currentTabIndex = index; // Update the current tab index
      });
    } else {
      print('Error: Invalid menu title or index');
      setState(() {
        _tabBody = Container(
          color: Colors.red,
          alignment: Alignment.center,
          child: const Text(
            "Menu inválido",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        );
      });
    }
  }

  void _showImagePreviews(List<ImageInfoDTO> images) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1B263B), // Use the specified background color
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Prémios Obtidos",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Display two images side by side
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: images.length,
                      itemBuilder: (BuildContext context, int index) {
                        final base64Image = images[index].data.split(',').last;
                        return Image.memory(
                          base64Decode(base64Image),
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onTrophyIconPressed() async {
    try {
      final images = await _userService.getAllImagePreviewsBase64();
      _showImagePreviews(images);
    } catch (e) {
      print('Error fetching image previews: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao carregar imagens')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentTabIndex != 0) {
          // Redirect to _homeTabView if not already there
          setState(() {
            _tabBody = _screens[0];
            _currentTabIndex = 0;
          });
          return false; // Prevent the app from closing
        } else {
          // Show confirmation dialog to exit the app
          final shouldExit = await showDialog(
            context: context,
            builder:
                (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF0D1B2A,
                      ), // Use a darker solid color
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Center(
                          child: Text(
                            "Sair da aplicação",
                            style: TextStyle(
                              fontSize: 28,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Center(
                          child: Text(
                            "Tem a certeza de que quer sair?",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: "Poppins",
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed:
                                  () => Navigator.of(
                                    context,
                                  ).pop(false), // User pressed No
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color.fromRGBO(
                                  102,
                                  122,
                                  236,
                                  1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Não",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed:
                                  () =>
                                      SystemNavigator.pop(), // User pressed Yes
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(
                                  102,
                                  122,
                                  236,
                                  1,
                                ),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Sim",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          );
          return shouldExit ?? false; // Exit if user confirms
        }
      },
      child: Scaffold(
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
                    // Show the DayNightSwitch only when the user is on the MenuPage (index 0)
                    if (_currentTabIndex == 0)
                      Positioned(
                        top: 50,
                        right: 20,
                        child: IconButton(
                          iconSize: 36, // Make the icon slightly larger
                          icon: const Icon(Icons.emoji_events, color: Colors.white),
                          onPressed: _onTrophyIconPressed,
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
                  onTap: () async {
                    if (FocusScope.of(context).hasFocus) {
                      FocusScope.of(context).unfocus(); // Close the keyboard
                      await Future.delayed(const Duration(milliseconds: 200)); // Wait for the keyboard to close
                    }
                    onMenuPress(); // Open the side menu
                  },
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
                      child: Stack(
                        children: [
                          rive.RiveAnimation.asset(
                            app_assets.menuButtonRiv,
                            stateMachines: const ["State Machine"],
                            animations: const ["open", "close"],
                            onInit: _onMenuIconInit,
                          ),
                          Positioned(
                            top: 55,
                            right: 20,
                            child: IconButton(
                              icon: const Icon(Icons.emoji_events, color: Colors.white),
                              onPressed: _onTrophyIconPressed,
                            ),
                          ),
                        ],
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
      ),
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
                    _currentTabIndex = 0; // Update the current tab index
                  }
                  if (tabIndex == 1) {
                    _tabBody = _screens[1];
                    _currentTabIndex = 1; // Update the current tab index
                  }
                  if (tabIndex == 2) {
                    _tabBody = _screens[4];
                    _currentTabIndex = 4; // Update the current tab index
                  }
                  if (tabIndex == 3) {
                    _tabBody = _screens[2];
                    _currentTabIndex = 2; // Update the current tab index
                  }
                  if (tabIndex == 4) {
                    _tabBody = _screens[9];
                    _currentTabIndex = 9; // Update the current tab index
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
