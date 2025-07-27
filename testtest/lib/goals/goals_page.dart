import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mentara/goals/goal_details_page.dart';
import 'package:mentara/services/goal/goal_service.dart';
import 'package:mentara/services/goal/goal_model.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({Key? key}) : super(key: key);

  @override
  _GoalsPageState createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final GoalService _goalService = GoalService();
  final ScrollController _scrollController = ScrollController();

  DateTime _currentWeekStart = DateTime.now();
  DateTime? _selectedDay;
  Set<GoalSubject> _selectedSubjects = {};
  bool _isFilterPanelVisible = false;

  List<GoalInfoCard> _goals = [];
  bool _isLoading = false;
  bool _isFetchingMore = false; // To track if more data is being fetched
  bool _isCompleted = false; // To track if more data is being fetched
  int _currentPage = 0; // Current page
  int _totalPages = 1; // Total pages (default to 1)

  // Returns the Monday of the week for a given date
  DateTime _getMondayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  @override
  void initState() {
    super.initState();
    _currentWeekStart = _getMondayOfWeek(DateTime.now()); // Start at current week (Monday)
    _fetchGoalsForWeek();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isFetchingMore &&
        _currentPage < _totalPages - 1) {
      _fetchMoreGoals();
    }
  }

  Future<void> _fetchGoalsForWeek({int page = 0, int size = 10}) async {
    setState(() => _isLoading = true);
    try {
      final startDate = _currentWeekStart;
      final endDate = _currentWeekStart.add(const Duration(days: 6));
      final pagezGoals = await _goalService.fetchGoals(
        _isCompleted,
        startDate,
        endDate,
        _selectedSubjects.toList(),
        page: page,
        size: size,
      );
      setState(() {
        _goals = pagezGoals.goals;
        _currentPage = pagezGoals.pageNumber;
        _totalPages = pagezGoals.totalPages;
      });
    } catch (e) {
      _showErrorSnackbar("Falha ao procurar metas. Tente novamente.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchGoalsForDay(
    DateTime day, {
    int page = 0,
    int size = 10,
  }) async {
    setState(() => _isLoading = true);
    try {
      final pagezGoals = await _goalService.fetchGoals(
        _isCompleted,
        day,
        day,
        _selectedSubjects.toList(),
        page: page,
        size: size,
      );
      setState(() {
        _goals = pagezGoals.goals;
        _currentPage = pagezGoals.pageNumber;
        _totalPages = pagezGoals.totalPages;
      });
    } catch (e) {
      _showErrorSnackbar("Falha ao procurar metas. Tente novamente.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMoreGoals() async {
    setState(() => _isFetchingMore = true);
    try {
      final startDate = _currentWeekStart;
      final endDate = _currentWeekStart.add(const Duration(days: 6));
      final pagezGoals = await _goalService.fetchGoals(
        _isCompleted,
        startDate,
        endDate,
        _selectedSubjects.toList(),
        page: _currentPage + 1,
        size: 10,
      );
      setState(() {
        _goals.addAll(pagezGoals.goals); // Append new goals to the list
        _currentPage = pagezGoals.pageNumber;
        _totalPages = pagezGoals.totalPages;
      });
    } catch (e) {
      _showErrorSnackbar("Falha ao procurar metas. Tente novamente.");
    } finally {
      setState(() => _isFetchingMore = false);
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

  // Returns a list of 7 days from Monday to Sunday for the current week
  List<DateTime> _getWeekDays(DateTime weekStart) {
    return List.generate(7, (index) => weekStart.add(Duration(days: index)));
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
          // Filtro e toggle de completadas
          Positioned(
            top: 58,
            right: 20,
            child: Row(
              children: [
                // Toggle completed/por completar
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isCompleted = !_isCompleted;
                    });
                    if (_selectedDay != null) {
                      _fetchGoalsForDay(_selectedDay!);
                    } else {
                      _fetchGoalsForWeek();
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isCompleted ? Colors.green : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                      color: _isCompleted ? Colors.white : const Color(0xFF0D1B2A),
                      size: 28,
                    ),
                  ),
                ),
                // Filtro
                GestureDetector(
                  onTap: _toggleFilterPanel,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Stack(
                      children: [
                        Container(
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
                            color: Color(0xFF0D1B2A),
                            size: 28,
                          ),
                        ),
                        if (_selectedSubjects.isNotEmpty)
                          Positioned(
                            top: 3,
                            right: 4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF0D1B2A),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Move FAB before filter panel so the panel covers it
          Positioned(
            bottom: 10,
            right: 0,
            child: _buildFloatingActionButton(),
          ),
          _buildFilterPanel(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
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
        "Metas",
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

    // Dias da semana em português (segunda a domingo)
    const weekDaysPt = ["Seg", "Ter", "Qua", "Qui", "Sex", "Sáb", "Dom"];
    // Meses em português (jan a dez)
    const monthsPt = [
      "Jan", "Fev", "Mar", "Abr", "Mai", "Jun",
      "Jul", "Ago", "Set", "Out", "Nov", "Dez"
    ];

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            // Deselect the day and fetch goals for the entire week
            _selectedDay = null;
            _fetchGoalsForWeek();
          } else {
            // Select the day and fetch goals for that specific day
            _selectedDay = day;
            _fetchGoalsForDay(day);
          }
        });
      },
      child: Column(
        children: [
          Text(
            weekDaysPt[day.weekday - 1],
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration:
                isSelected
                    ? BoxDecoration(
                      color: const Color.fromARGB(255, 33, 70, 119),
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
            monthsPt[day.month - 1],
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList() {
    if (_isLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(), // Center the loading indicator
        ),
      );
    }

    if (_goals.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "Nenhuma meta encontrada",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          if (_selectedDay != null) {
            await _fetchGoalsForDay(
              _selectedDay!,
            ); // Fetch goals for the selected day
          } else {
            await _fetchGoalsForWeek(); // Fetch goals for the entire week
          }
        },
        child: ListView.builder(
          controller: _scrollController, // Attach the ScrollController
          padding: const EdgeInsets.all(20),
          itemCount: _goals.length + (_isFetchingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _goals.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final goal = _goals[index];
            return _buildGoalCard(goal);
          },
        ),
      ),
    );
  }

  // Helper to get the translated name and emoji for a GoalSubject
String getSubjectDisplayName(GoalSubject subject) {
  switch (subject) {
    case GoalSubject.Personal:
      return "👤 Pessoal";
    case GoalSubject.Work:
      return "💼 Trabalho";
    case GoalSubject.Studies:
      return "📚 Estudos";
    case GoalSubject.Family:
      return "👪 Família";
    }
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
                  onSave: () {
                    if (_selectedDay != null) {
                      _fetchGoalsForDay(
                        _selectedDay!,
                      ); // Fetch goals for the selected day
                    } else {
                      _fetchGoalsForWeek(); // Fetch goals for the entire week
                    }
                  },
                ),
          ),
        ).then((result) {
          if (result == true) {
            // Check if a day is selected and fetch accordingly
            if (_selectedDay != null) {
              _fetchGoalsForDay(
                _selectedDay!,
              ); // Fetch goals for the selected day
            } else {
              _fetchGoalsForWeek(); // Fetch goals for the entire week
            }
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
            // Goal Date
            Text(
              "Data: ${goal.goalDate.day.toString().padLeft(2, '0')}-${goal.goalDate.month.toString().padLeft(2, '0')}-${goal.goalDate.year}",
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
                fontWeight: FontWeight.w800,
              ),
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
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    getSubjectDisplayName(goal.subject),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Completed Checkbox (toggle both ways)
                Row(
                  children: [
                    Text(
                      "Completado",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: goal.completed ? Colors.green[200] : Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Checkbox(
                      value: goal.completed,
                      onChanged: (value) async {
                        final updatedGoal = GoalInfoCard(
                          id: goal.id,
                          title: goal.title,
                          description: goal.description,
                          goalDate: goal.goalDate,
                          completedDate: value == true ? DateTime.now() : null,
                          completed: value ?? false,
                          hasNotifications: goal.hasNotifications,
                          subject: goal.subject,
                          createdAt: goal.createdAt,
                          updatedAt: DateTime.now(),
                        );
                        try {
                          await _goalService.updateGoal(goal.id, updatedGoal);
                          // Instead of mutating the existing goal (which is immutable),
                          // refresh the list from backend to get the updated state.
                          if (_selectedDay != null) {
                            await _fetchGoalsForDay(_selectedDay!);
                          } else {
                            await _fetchGoalsForWeek();
                          }
                        } catch (e) {
                          _showErrorSnackbar("Erro ao atualizar o estado da meta.");
                        }
                      },
                      activeColor: Colors.green,
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
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
    return Positioned.fill(
      child: GestureDetector(
        onTap: _closeFilterPanel, // Fecha o painel ao clicar no fundo desfocado
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(color: Colors.black.withOpacity(0.2)),
        ),
      ),
    );
  }

  Widget _buildFilterIcon() {
    final bool hasFilters =
        _selectedSubjects.isNotEmpty; // Check if filters are selected

    return Positioned(
      top: 58,
      right: 20,
      child: GestureDetector(
        onTap: _toggleFilterPanel,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Stack(
            children: [
              Container(
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
                  color: Color(0xFF0D1B2A),
                  size: 28,
                ),
              ),
              if (hasFilters) // Show the small circle only if filters are selected
                Positioned(
                  top: 3,
                  right: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF0D1B2A), // Red color for the indicator
                    ),
                  ),
                ),
            ],
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
            colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
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
                    "Tema", // Título alterado para "Tema"
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
                    children: [
                      // Subject Filters
                      ...GoalSubject.values.map((subject) {
                        final isSelected = _selectedSubjects.contains(subject);
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
                                      ? const Color(0xFF0D1B2A)
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
                                getSubjectDisplayName(subject),
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : const Color(0xFF0D1B2A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
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
                    onSave: () {
                      if (_selectedDay != null) {
                        _fetchGoalsForDay(
                          _selectedDay!,
                        ); // Fetch goals for the selected day
                      } else {
                        _fetchGoalsForWeek(); // Fetch goals for the entire week
                      }
                    },
                  ),
            ),
          );
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Color(0xFF0D1B2A)),
      ),
    );
  }
}



