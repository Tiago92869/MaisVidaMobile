import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:testtest/goals/goal_details_page.dart';
import 'package:testtest/services/goal/goal_service.dart';
import 'package:testtest/services/goal/goal_model.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({Key? key}) : super(key: key);

  @override
  _GoalsPageState createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final GoalService _goalService = GoalService();

  DateTime _currentWeekStart = DateTime.now();
  DateTime? _selectedDay;
  Set<GoalSubject> _selectedSubjects = {};
  bool _isFilterPanelVisible = false;

  List<GoalInfoCard> _goals = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchGoalsForWeek();
  }

  Future<void> _fetchGoalsForWeek() async {
    setState(() => _isLoading = true);
    try {
      final startDate = _currentWeekStart;
      final endDate = _currentWeekStart.add(const Duration(days: 6));
      final goalDays = await _goalService.fetchGoals(
        null,
        startDate,
        endDate,
        _selectedSubjects.toList(),
      );
      setState(() {
        _goals = goalDays.expand((goalDay) => goalDay.goals).toList();
      });
    } catch (e) {
      _showErrorSnackbar("Failed to fetch goals. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _moveWeek(int direction) {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: 7 * direction));
      _selectedDay = null;
    });
    _fetchGoalsForWeek();
  }

  void _updateFilters(Set<GoalSubject> selectedSubjects) {
    setState(() => _selectedSubjects = selectedSubjects);
    _fetchGoalsForWeek();
  }

  void _toggleFilterPanel() {
    setState(() => _isFilterPanelVisible = !_isFilterPanelVisible);
  }

  void _closeFilterPanel() {
    if (_isFilterPanelVisible) {
      setState(() => _isFilterPanelVisible = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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
          _buildBackground(),
          GestureDetector(
            onTap: _closeFilterPanel,
            child: IgnorePointer(
              ignoring: _isFilterPanelVisible,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitle(),
                      const SizedBox(height: 20),
                      _buildCalendar(weekDays),
                      const SizedBox(height: 10),
                      _buildGoalsList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isFilterPanelVisible) _buildBlurEffect(),
          _buildFilterIcon(),
          _buildFilterPanel(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(102, 122, 236, 1),
              Color.fromRGBO(255, 255, 255, 1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Center(
      child: Text(
        "Goals",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: "Poppins",
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCalendar(List<DateTime> weekDays) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => _moveWeek(-1),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          iconSize: 30,
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((day) => _buildDayTile(day)).toList(),
          ),
        ),
        IconButton(
          onPressed: () => _moveWeek(1),
          icon: const Icon(Icons.arrow_forward, color: Colors.white),
          iconSize: 30,
        ),
      ],
    );
  }

  Widget _buildDayTile(DateTime day) {
    final isSelected =
        _selectedDay?.day == day.day &&
        _selectedDay?.month == day.month &&
        _selectedDay?.year == day.year;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedDay = isSelected ? null : day);
      },
      child: Column(
        children: [
          Text(
            ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][day.weekday - 1],
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration:
                isSelected
                    ? BoxDecoration(
                      color: const Color.fromRGBO(85, 123, 233, 1),
                      borderRadius: BorderRadius.circular(12),
                    )
                    : null,
            child: Text(
              day.day.toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            [
              "Jan",
              "Feb",
              "Mar",
              "Apr",
              "May",
              "Jun",
              "Jul",
              "Aug",
              "Sep",
              "Oct",
              "Nov",
              "Dec",
            ][day.month - 1],
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_goals.isEmpty) {
      return const Center(
        child: Text(
          "No Goals Found",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _goals.length,
        itemBuilder: (context, index) {
          final goal = _goals[index];
          return _buildGoalCard(goal);
        },
      ),
    );
  }

  Widget _buildGoalCard(GoalInfoCard goal) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => GoalDetailPage(
                  goal: goal,
                  createResource: false,
                  onSave: _fetchGoalsForWeek,
                ),
          ),
        ).then((value) {
          if (value == true) {
            _fetchGoalsForWeek();
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 33, 70, 119).withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 33, 70, 119).withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 8),

            // Subject and Completed Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Subject
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(
                      0.2,
                    ), // Slightly lighter background
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    StringCapitalization(
                      goal.subject.toString().split('.').last,
                    ).capitalizeFirstLetter(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text for subject
                    ),
                  ),
                ),

                // Status Toggle
                Row(
                  children: [
                    Text(
                      goal.completed ? "Completed" : "Not Completed",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70, // Subtle white text for status
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(value: goal.completed ?? false, onChanged: null),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurEffect() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: Container(color: Colors.black.withOpacity(0.2)),
    );
  }

  Widget _buildFilterIcon() {
    return Positioned(
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
            child: const Icon(Icons.filter_alt, color: Colors.blue, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPanel() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      right: _isFilterPanelVisible ? 0 : -230,
      top: 0,
      bottom: 0,
      child: Container(
        width: 230,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromRGBO(72, 85, 204, 1),
              Color.fromRGBO(123, 144, 255, 1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(-5, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
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
                    children:
                        GoalSubject.values.map((subject) {
                          final isSelected = _selectedSubjects.contains(
                            subject,
                          );
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedSubjects.remove(subject);
                                } else {
                                  _selectedSubjects.add(subject);
                                }
                              });
                              _updateFilters(_selectedSubjects);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Colors.transparent,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color:
                                    isSelected
                                        ? const Color.fromRGBO(85, 123, 233, 1)
                                        : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 15,
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: Text(
                                  StringCapitalization(
                                    subject.toString().split('.').last,
                                  ).capitalizeFirstLetter(),
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : const Color.fromRGBO(
                                              72,
                                              85,
                                              204,
                                              1,
                                            ),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildFloatingActionButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 90.0, right: 20),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => GoalDetailPage(
                    createResource: true,
                    onSave: _fetchGoalsForWeek,
                  ),
            ),
          ).then((value) {
            if (value == true) {
              _fetchGoalsForWeek();
            }
          });
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Color.fromRGBO(72, 85, 204, 1)),
      ),
    );
  }
}

// Extension to capitalize the first letter of a string
extension StringCapitalization on String {
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
