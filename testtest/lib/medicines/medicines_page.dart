import 'package:flutter/material.dart';
import 'dart:math';
import 'package:testtest/services/medicine/medicine_repository.dart';
import 'package:testtest/services/medicine/medicine_model.dart';

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
  bool _isLoading = false; // Track loading state
  bool _showArchived = false; // Track whether to show archived medicines

  final MedicineRepository _medicineRepository = MedicineRepository();

  final List<Medicine> _medicines = []; // Use the Medicine model directly

  @override
  void initState() {
    super.initState();

    // Add mocked data
    _medicines.addAll([
      Medicine(
      id: "1",
      name: "Paracetamol",
      description: "Used to treat fever and mild pain.",
      archived: false,
      startedAt: DateTime.now().subtract(const Duration(days: 2)),
      endedAt: DateTime.now().add(const Duration(days: 5)),
      hasNotifications: true,
      plans: WeekDay.values.map((day) {
        return Plan(
          id: UniqueKey().toString(),
          weekDay: day,
          dosages: [], // Empty dosages for now
        );
      }).toList(),
    ),
      Medicine(
        id: "2",
        name: "Ibuprofen",
        description: "Anti-inflammatory medicine for pain inflammatory medicine for pain reliefinflammatory medicine for pain reliefinflammatory medicine for pain reliefrelief.",
        archived: false,
        startedAt: DateTime.now().subtract(const Duration(days: 1)),
        endedAt: DateTime.now().add(const Duration(days: 10)),
        hasNotifications: false,
        plans: [],
      ),
      Medicine(
        id: "3",
        name: "Amoxicillin",
        description: "Antibiotic used to treat bacterial infections.",
        archived: true,
        startedAt: DateTime.now().subtract(const Duration(days: 7)),
        endedAt: DateTime.now().subtract(const Duration(days: 1)),
        hasNotifications: true,
        plans: [],
      ),
    ]);
  }

  Future<void> _fetchMedicines() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      DateTime startDate;
      DateTime endDate;

      if (_selectedDay != null) {
        // If a day is selected, fetch medicines for that day
        startDate = _selectedDay!;
        endDate = _selectedDay!;
      } else {
        // Otherwise, fetch medicines for the entire week
        startDate = _currentWeekStart;
        endDate = _currentWeekStart.add(const Duration(days: 6));
      }

      // Fetch medicines from the repository
      final medicineDays = await _medicineRepository.getMedicines(_showArchived, startDate, endDate);

      // Update the _medicines list with the fetched data
      setState(() {
        _medicines.clear();
        for (var medicineDay in medicineDays) {
          _medicines.addAll(medicineDay.medicines);
        }
      });
    } catch (e) {
      print('Error fetching medicines: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to fetch medicines. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      if (_selectedDay == day) {
        // Deselect the date if it's already selected
        _selectedDay = null;
      } else {
        // Select the new date
        _selectedDay = day;
      }
    });
    // Fetch medicines for the selected day
    _fetchMedicines();
  }

  void _moveWeek(int direction) {
    setState(() {
      // Move the current week start by 7 days in the specified direction
      _currentWeekStart = _currentWeekStart.add(Duration(days: 7 * direction));
      // Deselect the selected day when moving to a different week
      _selectedDay = null;
    });
    // Fetch medicines for the new week
    _fetchMedicines();
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
                                    onTap: () => _onDaySelected(day),
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
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(), // Show loading indicator
                              )
                            : _medicines.isEmpty
                                ? const Center(
                                    child: Text(
                                      "No Medicines Found",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  )
                                : Container(
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
          // Open Medicines Icon
          Positioned(
  top: 58,
  right: 30,
  child: GestureDetector(
    onTap: () {
      setState(() {
        _showArchived = !_showArchived; // Toggle between archived and open medicines
      });
      _fetchMedicines(); // Refresh the medicines list
    },
    child: CircleAvatar(
      backgroundColor: Colors.white,
      child: Icon(
        _showArchived ? Icons.folder_open : Icons.archive, // Switch icon based on _showArchived
        color: const Color.fromRGBO(72, 85, 204, 1),
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
