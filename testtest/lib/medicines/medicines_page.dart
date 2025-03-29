import 'package:flutter/material.dart';
import 'dart:math';

import 'medicine_detail_page.dart';

class MedicinesPage extends StatefulWidget {
  const MedicinesPage({Key? key}) : super(key: key);

  @override
  _MedicinesPageState createState() => _MedicinesPageState();
}

class _MedicinesPageState extends State<MedicinesPage> {
  DateTime _currentWeekStart = DateTime.now();
  DateTime? _selectedDay; // Track the selected day
  bool _isFilterPanelVisible = false; // Filter panel visibility

void initState() {
  super.initState();
  _selectedDay = null; // No day is selected initially
  _currentWeekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)); // Start of the current week
  }

  // Dummy medicines data
  final List<MedicineDTO> _medicines = [
    MedicineDTO(
      id: "1",
      name: "Paracetamol",
      description: "Take one tablet after meals.",
      archived: false,
      startedAt: DateTime.now().subtract(const Duration(days: 2)),
      endedAt: DateTime.now().add(const Duration(days: 5)),
      hasNotifications: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
      plans: [
        PlanDTO(
          id: "1",
          weekDay: WeekDay.MONDAY,
          dosages: [
            DosageDTO(id: "1", time: const TimeOfDay(hour: 8, minute: 0), dosage: 1.0),
            DosageDTO(id: "2", time: const TimeOfDay(hour: 20, minute: 0), dosage: 1.0),
          ],
        ),
        PlanDTO(
          id: "2",
          weekDay: WeekDay.WEDNESDAY,
          dosages: [
            DosageDTO(id: "3", time: const TimeOfDay(hour: 9, minute: 30), dosage: 0.5),
          ],
        ),
      ],
    ),
    MedicineDTO(
      id: "2",
      name: "Vitamin D",
      description: "Take one capsule in the morning.",
      archived: false,
      startedAt: DateTime.now(),
      endedAt: DateTime.now().add(const Duration(days: 7)),
      hasNotifications: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      plans: [
        PlanDTO(
          id: "3",
          weekDay: WeekDay.TUESDAY,
          dosages: [
            DosageDTO(id: "4", time: const TimeOfDay(hour: 9, minute: 0), dosage: 1.0),
          ],
        ),
        PlanDTO(
          id: "4",
          weekDay: WeekDay.THURSDAY,
          dosages: [
            DosageDTO(id: "5", time: const TimeOfDay(hour: 10, minute: 0), dosage: 1.0),
          ],
        ),
      ],
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
                          "Medicines",
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
                      // Medicines Container
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(72, 85, 204, 1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListView.builder(
                            itemCount: _medicines.length,
                            itemBuilder: (context, index) {
                              final medicine = _medicines[index];
                              return GestureDetector(
                                onTap: () {
                                  // Navigate to MedicineDetailPage for visualizing the medicine
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MedicineDetailPage(
                                        medicine: medicine,
                                        isEditing: false,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Medicine Name
                                      Text(
                                        medicine.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // Medicine Description (limited to 2 lines)
                                      Text(
                                        medicine.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // Start and End Dates
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Starts: ${medicine.startedAt.toLocal().toString().split(' ')[0]}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          Text(
                                            "Ends: ${medicine.endedAt.toLocal().toString().split(' ')[0]}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
  padding: const EdgeInsets.only(bottom: 90.0, right: 20), // Move the button 40 pixels upwards
  child: FloatingActionButton(
        onPressed: () {
          // Navigate to MedicineDetailPage for creating a new medicine
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MedicineDetailPage(
                medicine: null,
                isEditing: true,
              ),
            ),
          );
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Color.fromRGBO(72, 85, 204, 1)),
      ),
      ),
    );
  }
}

// Dummy MedicineDTO model
class MedicineDTO {
  final String id;
  final String name;
  final String description;
  final bool archived;
  final DateTime startedAt;
  final DateTime endedAt;
  final bool hasNotifications;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PlanDTO> plans;

  MedicineDTO({
    required this.id,
    required this.name,
    required this.description,
    required this.archived,
    required this.startedAt,
    required this.endedAt,
    required this.hasNotifications,
    required this.createdAt,
    required this.updatedAt,
    required this.plans,
  });
}

class PlanDTO {
  final String id;
  final WeekDay weekDay;
  final List<DosageDTO> dosages;

  PlanDTO({
    required this.id,
    required this.weekDay,
    required this.dosages,
  });
}

class DosageDTO {
  final String id;
  final TimeOfDay time;
  final double dosage;

  DosageDTO({
    required this.id,
    required this.time,
    required this.dosage,
  });
}

enum WeekDay {
  MONDAY,
  TUESDAY,
  WEDNESDAY,
  THURSDAY,
  FRIDAY,
  SATURDAY,
  SUNDAY,
}