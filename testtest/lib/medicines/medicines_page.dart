import 'package:flutter/material.dart';
import 'package:mentara/services/medicine/medicine_repository.dart';
import 'package:mentara/services/medicine/medicine_model.dart';

import 'medicine_detail_page.dart';

class MedicinesPage extends StatefulWidget {
  const MedicinesPage({Key? key}) : super(key: key);

  @override
  _MedicinesPageState createState() => _MedicinesPageState();
}

class _MedicinesPageState extends State<MedicinesPage> {
  DateTime _currentWeekStart = _getMondayOfWeek(DateTime.now());
  DateTime? _selectedDay; // Track the selected day
  bool _isFilterPanelVisible = false; // Filter panel visibility
  bool _isLoading = false; // Track loading state
  bool _showArchived = false; // Track whether to show archived medicines

  late ScrollController _scrollController;
  int _currentPage = 0; // Track the current page
  int _totalPages = 1; // Track the total number of pages (default to 1)
  bool _isFetchingMore = false; // Prevent multiple fetches at the same time

  final MedicineRepository _medicineRepository = MedicineRepository();

  final List<Medicine> _medicines = []; // Use the Medicine model directly

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _fetchMedicines(); // Fetch the first page of medicines
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Check if the user has scrolled to the top
    if (_scrollController.position.pixels <= 0 && !_isLoading) {
      _fetchMedicines(); // Refresh the medicines list
    }

    // Check if the user has scrolled to the bottom for infinite scrolling
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 50 &&
        !_isFetchingMore &&
        _currentPage < _totalPages - 1) {
      _fetchMoreMedicines();
    }
  }

  Future<void> _fetchMedicines() async {
    setState(() {
      _isLoading = true; // Start loading
      _currentPage = 0; // Reset to the first page
      _totalPages = 1; // Reset total pages
    });

    try {
      final medicinePage = await _medicineRepository.getMedicines(
        _showArchived,
        _selectedDay ?? _currentWeekStart,
        _selectedDay ?? _currentWeekStart.add(const Duration(days: 6)),
        page: 0, // Pass the page number
        size: 4, // Pass the page size
      );

      setState(() {
        _medicines.clear();
        _medicines.addAll(
          medicinePage.content,
        ); // Add medicines from the response
        _currentPage = medicinePage.number; // Update the current page
        _totalPages = medicinePage.totalPages; // Update the total pages
      });
    } catch (e) {
      print('Error fetching medicines: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Falha ao procurar medicamentos. Tente novamente."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  Future<void> _fetchMedicinesForDay(DateTime day) async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      final formattedDay = _formatDate(day);

      final medicinePage = await _medicineRepository.getMedicines(
        _showArchived,
        DateTime.parse(formattedDay), // Pass formatted day as start date
        DateTime.parse(formattedDay), // Pass formatted day as end date
        page: 0, // Start with the first page
        size: 10, // Fetch 10 medicines per page
      );

      setState(() {
        _medicines.clear();
        _medicines.addAll(
          medicinePage.content,
        ); // Add medicines from the response
      });
    } catch (e) {
      print('Error fetching medicines for the day: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Falha ao procurar medicamentos para o dia selecionado."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  Future<void> _fetchMoreMedicines() async {
    setState(() {
      _isFetchingMore = true; // Start fetching more medicines
    });

    try {
      final startDate = _formatDate(_selectedDay ?? _currentWeekStart);
      final endDate = _formatDate(
        _selectedDay ?? _currentWeekStart.add(const Duration(days: 6)),
      );

      final medicinePage = await _medicineRepository.getMedicines(
        _showArchived,
        DateTime.parse(startDate),
        DateTime.parse(endDate),
        page: _currentPage + 1, // Fetch the next page
        size: 4, // Fetch 10 medicines per page
      );

      setState(() {
        _medicines.addAll(medicinePage.content); // Append new medicines
        _currentPage = medicinePage.number; // Update the current page
        _totalPages = medicinePage.totalPages; // Update the total pages
      });
    } catch (e) {
      print('Error fetching more medicines: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Falha ao procurar mais medicamentos. Tente novamente."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isFetchingMore = false; // Stop fetching
      });
    }
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      if (_selectedDay == day) {
        // Deselect the date if it's already selected
        _selectedDay = null;
        _fetchMedicines(); // Fetch medicines for the entire week
      } else {
        // Select the new date
        _selectedDay = day;
        _fetchMedicinesForDay(day); // Fetch medicines for the selected day
      }
    });
  }

  // Helper to get the Monday of the week for a given date
  static DateTime _getMondayOfWeek(DateTime date) {
    // In Dart, weekday: 1=Monday, 7=Sunday
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _moveWeek(int direction) {
    setState(() {
      // Move the current week start by 7 days in the specified direction, always landing on a Monday
      _currentWeekStart = _getMondayOfWeek(_currentWeekStart.add(Duration(days: 7 * direction)));
      _selectedDay = null;
    });
    _fetchMedicines();
  }

  List<DateTime> _getWeekDays(DateTime start) {
    // Always return Monday to Sunday for the week containing 'start'
    final monday = _getMondayOfWeek(start);
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  void _closeFilterPanel() {
    if (_isFilterPanelVisible) {
      setState(() {
        _isFilterPanelVisible = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
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
      onTap: () => _onDaySelected(day), // Call _onDaySelected
      child: Column(
        children: [
          Text(
            ["Seg", "Ter", "Qua", "Qui", "Sex", "Sab", "Dom"][day.weekday - 1],
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
            [
              "Jan",
              "Fev",
              "Mar",
              "Abr",
              "Mai",
              "Jun",
              "Jul",
              "Ago",
              "Set",
              "Out",
              "Nov",
              "Des",
            ][day.month - 1],
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicinesList() {
    if (_isLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(), // Center the loading indicator
        ),
      );
    }

    if (_medicines.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "Nenhum medicamento encontrado",
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
        onRefresh: _fetchMedicines, // Pull-to-refresh functionality
        child: ListView.builder(
          controller: _scrollController, // Attach the ScrollController
          padding: const EdgeInsets.all(20),
          itemCount: _medicines.length + (_isFetchingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _medicines.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(), // Loading indicator
                ),
              );
            }
            final medicine = _medicines[index];
            return _buildMedicineCard(medicine);
          },
        ),
      ),
    );
  }

  Widget _buildMedicineCard(Medicine medicine) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    MedicineDetailPage(medicine: medicine, isEditing: false),
          ),
        ).then((isMedicineUpdatedOrDeleted) {
          // Refresh the medicines list if a medicine was updated or deleted
          if (isMedicineUpdatedOrDeleted == true) {
            if (_selectedDay == null) {
              _fetchMedicines(); // Fetch medicines for the entire week
            } else {
              _fetchMedicinesForDay(
                _selectedDay!,
              ); // Fetch medicines for the selected day
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
            // Medicine Name
            Text(
              medicine.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // Medicine Description
            Text(
              medicine.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            // Start and End Dates
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: "Inicio: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      TextSpan(
                        text:
                            medicine.startedAt.toLocal().toString().split(
                              ' ',
                            )[0],
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: "Fim: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      TextSpan(
                        text:
                            medicine.endedAt.toLocal().toString().split(' ')[0],
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
                  colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: _showArchived ? 20 : 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Center(
                        child: Text(
                          _showArchived ? "Arquivados" : "Medicação",
                          style: TextStyle(
                            fontSize:
                                _showArchived
                                    ? 28
                                    : 28, // Reduce font size for Archived Medicines
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Calendar
                      _buildCalendar(weekDays),
                      const SizedBox(height: 20),
                      // Medicines List
                      _buildMedicinesList(),
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
                  _showArchived = !_showArchived;
                });
                _fetchMedicines();
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  _showArchived ? Icons.history : Icons.archive,
                  color: const Color(0xFF0D1B2A),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0, right: 20),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => const MedicineDetailPage(
                      medicine: null,
                      isEditing: true,
                    ),
              ),
            ).then((isMedicineCreated) {
              // Refresh the medicines list if a new medicine was created
              if (isMedicineCreated == true) {
                if (_selectedDay == null) {
                  _fetchMedicines(); // Fetch medicines for the entire week
                } else {
                  _fetchMedicinesForDay(
                    _selectedDay!,
                  ); // Fetch medicines for the selected day
                }
              }
            });
          },
          backgroundColor: Colors.white,
          child: const Icon(Icons.add, color: Color(0xFF0D1B2A)),
        ),
      ),
    );
  }
}
