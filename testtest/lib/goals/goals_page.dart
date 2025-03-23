import 'package:flutter/material.dart';
import 'dart:math';

enum Subject {
  PERSONAL,
  WORK,
  STUDIES,
  FAMILY,
}

class GoalsPage extends StatefulWidget {
  const GoalsPage({Key? key}) : super(key: key);

  @override
  _GoalsPageState createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  DateTime _currentWeekStart = DateTime.now();
  DateTime? _selectedDay; // Track the selected day
  Set<Subject> _selectedSubjects = {}; // Selected filter subjects
  bool _isFilterPanelVisible = false; // Filter panel visibility

  @override
  void initState() {
    super.initState();
    _selectedDay = _currentWeekStart; // Default to the first day of the week
  }

  // Dummy goals data
  final List<GoalDTO> _goals = [
    GoalDTO(
      title: "Finish Flutter Project",
      description: "Complete the Flutter project by the end of the week.",
      goalDate: DateTime.now().add(const Duration(days: 2)),
      completed: false,
      hasNotifications: true,
      subject: Subject.WORK,
    ),
    GoalDTO(
      title: "Read a Book",
      description: "Read at least 50 pages of a book.",
      goalDate: DateTime.now().add(const Duration(days: 4)),
      completed: false,
      hasNotifications: false,
      subject: Subject.PERSONAL,
    ),
    GoalDTO(
      title: "Finish Flutter Project",
      description: "Complete the Flutter project by the end of the week.",
      goalDate: DateTime.now().add(const Duration(days: 2)),
      completed: false,
      hasNotifications: true,
      subject: Subject.WORK,
    ),
    GoalDTO(
      title: "Read a Book",
      description: "Read at least 50 pages of a book.",
      goalDate: DateTime.now().add(const Duration(days: 4)),
      completed: false,
      hasNotifications: false,
      subject: Subject.PERSONAL,
    ),
    GoalDTO(
      title: "Finish Flutter Project",
      description: "Complete the Flutter project by the end of the week.",
      goalDate: DateTime.now().add(const Duration(days: 2)),
      completed: false,
      hasNotifications: true,
      subject: Subject.WORK,
    ),
    GoalDTO(
      title: "Read a Book",
      description: "Read at least 50 pages of a book.",
      goalDate: DateTime.now().add(const Duration(days: 4)),
      completed: false,
      hasNotifications: false,
      subject: Subject.PERSONAL,
    ),
  ];

  void _moveWeek(int direction) {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: 7 * direction));
    });
  }

  List<DateTime> _getWeekDays(DateTime start) {
    return List.generate(7, (index) => start.add(Duration(days: index)));
  }

  void _toggleFilterPanel() {
    setState(() {
      _isFilterPanelVisible = !_isFilterPanelVisible;
    });
  }

  void _closeFilterPanel() {
    if (_isFilterPanelVisible) {
      setState(() {
        _isFilterPanelVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getWeekDays(_currentWeekStart);

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(102, 122, 236, 1), // Start color (darker blue)
                    Color.fromRGBO(255, 255, 255, 1), // End color (lighter blue)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Content
          GestureDetector(
            onTap: _closeFilterPanel,
            child: IgnorePointer(
              ignoring: _isFilterPanelVisible,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Center(
                        child: Text(
                          "Goals",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Calendar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left Arrow
                          IconButton(
                            onPressed: () => _moveWeek(-1),
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            iconSize: 30, // Arrow size
                          ),
                          // Week Days
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              child: Row(
                                key: ValueKey(_currentWeekStart),
                                mainAxisAlignment: MainAxisAlignment.spaceAround, // Adjust spacing
                                children: weekDays.map((day) {
                                  final isSelected = _selectedDay?.day == day.day &&
                                      _selectedDay?.month == day.month &&
                                      _selectedDay?.year == day.year;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          // Deselect the date if it's already selected
                                          _selectedDay = null;
                                        } else {
                                          // Select the new date
                                          _selectedDay = day;
                                        }
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        // Day of the week
                                        Text(
                                          "${['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day.weekday - 1]}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),

                                        // Date with conditional purple container
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // Reduced horizontal padding
                                          decoration: isSelected
                                              ? BoxDecoration(
                                                  color: const Color.fromRGBO(85, 123, 233, 1), // Purple background
                                                  borderRadius: BorderRadius.circular(12),
                                                )
                                              : null, // No decoration if not selected
                                          child: Text(
                                            day.day.toString(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),

                                        // Month abbreviation
                                        Text(
                                          "${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][day.month - 1]}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          // Right Arrow
                          IconButton(
                            onPressed: () => _moveWeek(1),
                            icon: const Icon(Icons.arrow_forward, color: Colors.white),
                            iconSize: 30, // Arrow size
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Goals Container
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(72, 85, 204, 1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              // List of goals
                              ListView.builder(
                                itemCount: _goals.length,
                                itemBuilder: (context, index) {
                                  final goal = _goals[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Goal Title
                                        Text(
                                          goal.title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        // Goal Description (limited to 2 lines)
                                        Text(
                                          goal.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        // Subject as a button-like style
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            goal.subject.toString().split('.').last.capitalizeFirstLetter(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              // Button in the bottom-right corner
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: FloatingActionButton(
                                  onPressed: () {
                                    // Add logic for the button here
                                  },
                                  backgroundColor: Colors.white,
                                  child: const Icon(Icons.add, color: Color.fromRGBO(72, 85, 204, 1)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Filter Icon Positioned
          Positioned(
            top: 58,
            right: 20,
            child: GestureDetector(
              onTap: _toggleFilterPanel,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.filter_alt,
                    color: Colors.blue,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          // Sliding filter panel
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            right: _isFilterPanelVisible ? 0 : -230, // Slide in/out effect
            top: 0,
            bottom: 0,
            child: Container(
              width: 230,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(72, 85, 204, 1), // Start color (darker blue)
                    Color.fromRGBO(123, 144, 255, 1), // End color (lighter blue)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(-5, 0), // Shadow on the left side
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40), // Space between the arrow and text
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 15),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _toggleFilterPanel,
                          child: const Icon(
                            Icons.arrow_forward,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 30),
                        const Text(
                          "Filter by Subject",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: Subject.values.map((subject) {
                            bool isSelected = _selectedSubjects.contains(subject);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedSubjects.remove(subject);
                                  } else {
                                    _selectedSubjects.add(subject);
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: isSelected
                                      ? const Color.fromRGBO(85, 123, 233, 1) // Selected button color
                                      : Colors.white, // Default button color
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Center(
                                  child: Text(
                                    subject.toString().split('.').last.capitalizeFirstLetter(),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color.fromRGBO(72, 85, 204, 1),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins",
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
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

// Dummy GoalDTO model
class GoalDTO {
  final String title;
  final String description;
  final DateTime goalDate;
  final bool completed;
  final bool hasNotifications;
  final Subject subject;

  GoalDTO({
    required this.title,
    required this.description,
    required this.goalDate,
    required this.completed,
    required this.hasNotifications,
    required this.subject,
  });
}

// Extension to capitalize the first letter of a string
extension StringCapitalization on String {
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}