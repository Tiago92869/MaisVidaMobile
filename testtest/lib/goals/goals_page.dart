import 'package:flutter/material.dart';
import 'dart:math';

class GoalsPage extends StatefulWidget {
  const GoalsPage({Key? key}) : super(key: key);

  @override
  _GoalsPageState createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  DateTime _currentWeekStart = DateTime.now();

  // Dummy goals data
  final List<GoalDTO> _goals = [
    GoalDTO(
      title: "Finish Flutter Project",
      description: "Complete the Flutter project by the end of the week.",
      goalDate: DateTime.now().add(const Duration(days: 2)),
      completed: false,
      hasNotifications: true,
    ),
    GoalDTO(
      title: "Read a Book",
      description: "Read at least 50 pages of a book.",
      goalDate: DateTime.now().add(const Duration(days: 4)),
      completed: false,
      hasNotifications: false,
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
                    Color.fromRGBO(72, 85, 204, 1), // Start color (darker blue)
                    Color.fromRGBO(123, 144, 255, 1), // End color (lighter blue)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    "Goals",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins",
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Calendar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => _moveWeek(-1),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: weekDays.map((day) {
                            return Column(
                              children: [
                                Text(
                                    "${['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day.weekday - 1]}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                    "${day.day}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _moveWeek(1),
                        icon: const Icon(Icons.arrow_forward, color: Colors.white),
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
                      child: ListView.builder(
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
                                Text(
                                  goal.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  goal.description,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                    "Goal Date: ${goal.goalDate.day}-${goal.goalDate.month}-${goal.goalDate.year}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Add Goal Button
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                // Add goal logic here
              },
              backgroundColor: Colors.white,
              child: const Icon(Icons.add, color: Color.fromRGBO(72, 85, 204, 1)),
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

  GoalDTO({
    required this.title,
    required this.description,
    required this.goalDate,
    required this.completed,
    required this.hasNotifications,
  });
}