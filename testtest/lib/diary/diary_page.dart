import 'dart:ui'; // For BackdropFilter
import 'package:flutter/material.dart';
import 'package:testtest/services/diary/diary_service.dart'; // Import DiaryService
import 'package:testtest/services/diary/diary_model.dart'; // Import DiaryModel
import 'diary_detail_page.dart'; // Import the new page

class DiaryPage extends StatefulWidget {
  const DiaryPage({Key? key}) : super(key: key);

  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final DiaryService _diaryService = DiaryService(); // Initialize DiaryService
  bool _isLoading = false; // Tracks if data is being fetched
  bool _hasError = false; // Tracks if there was an error during fetch
  bool _hasMoreData = true; // Tracks if there is more data to fetch
  int _currentPage = 0; // Tracks the current page for pagination

  DateTime _selectedDate = DateTime.now();

  Set<DiaryType> _selectedEmotions = {}; // Selected filter emotions
  bool _isFilterPanelVisible = false; // Filter panel visibility

  List<Diary> _diaryEntries =
      []; // Initialize _diaryEntries as an empty list of Diary

  @override
  void initState() {
    super.initState();
    _fetchDiariesForSelectedDate(); // Fetch diaries for the initial selected date
  }

  // Function to toggle the filter panel visibility
  void _toggleFilterPanel() {
    setState(() {
      _isFilterPanelVisible = !_isFilterPanelVisible;
    });
  }

  // Function to handle emotion selection
  void _toggleEmotion(DiaryType emotion) {
    setState(() {
      if (_selectedEmotions.contains(emotion)) {
        _selectedEmotions.remove(emotion);
      } else {
        _selectedEmotions.add(emotion);
      }
    });

    // Fetch diaries with the updated emotions
    _fetchDiariesForSelectedDate();
  }

  // Function to filter diary entries by the selected date and emotions
  List<Diary> _getEntriesForSelectedDate() {
    return _diaryEntries
        .where(
          (entry) =>
              entry.recordedAt.toLocal().year == _selectedDate.toLocal().year &&
              entry.recordedAt.toLocal().month ==
                  _selectedDate.toLocal().month &&
              entry.recordedAt.toLocal().day == _selectedDate.toLocal().day &&
              (_selectedEmotions.isEmpty ||
                  _selectedEmotions.contains(entry.emotion)),
        )
        .toList();
  }

  // Function to fetch diaries for the selected date
  Future<void> _fetchDiariesForSelectedDate({bool isScrolling = false}) async {
    if (isScrolling && !_hasMoreData) {
      // If there is no more data to fetch, stop further requests
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;

      // Reset _diaryEntries and _currentPage only if not scrolling
      if (!isScrolling) {
        _diaryEntries = [];
        _currentPage = 0;
        _hasMoreData = true; // Reset hasMoreData when fetching new data
      }
    });

    try {
      // Fetch diaries from the DiaryService
      final diaries = await _diaryService.fetchDiaries(
        _selectedEmotions.toList(), // Pass selected emotions
        _selectedDate, // Start date
        _selectedDate, // End date (same as start date for a single day)
        page: _currentPage, // Current page
        size: 10, // Fetch 10 diaries per page
      );

      setState(() {
        if (diaries.isNotEmpty) {
          // Append fetched data to the existing diary entries
          for (var diaryDay in diaries) {
            _diaryEntries.addAll(diaryDay.diaries);
          }
          _currentPage++; // Increment the page number
        } else {
          _hasMoreData = false; // No more data to fetch
        }
      });
    } catch (e) {
      print("Error fetching diaries: $e");
      setState(() {
        _hasError = true;
      });

      // Show error message using SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Falha ao procurar os diários. Tente novamente."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to navigate to the previous day
  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
    _fetchDiariesForSelectedDate(); // Fetch diaries for the new selected date
  }

  // Function to navigate to the next day
  void _goToNextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
    _fetchDiariesForSelectedDate(); // Fetch diaries for the new selected date
  }

  // Function to show a calendar for selecting a date
  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000), // Earliest selectable date
      lastDate: DateTime(2100), // Latest selectable date
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF0D1B2A), // Header background color
            hintColor: const Color(0xFF0D1B2A), // Selected date color
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D1B2A), // Header text color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            dialogBackgroundColor:
                Colors.white, // Background color of the calendar
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      _fetchDiariesForSelectedDate(); // Fetch diaries for the newly selected date
    }
  }

  @override
  Widget build(BuildContext context) {
    _getEntriesForSelectedDate();

    return Scaffold(
      body: Stack(
        children: [
          // Main content
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Center(
                    child: Text(
                      "Diário",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Date Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: _goToPreviousDay,
                      ),
                      GestureDetector(
                        onTap:
                            _selectDate, // Show calendar when the date is tapped
                        child: Text(
                          "${_selectedDate.toLocal().month}/${_selectedDate.toLocal().day}/${_selectedDate.toLocal().year}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                        onPressed: _goToNextDay,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Diary Entries List with Pull-to-Refresh
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!_isLoading &&
                            scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                          // User has scrolled to the bottom, fetch the next page
                          _fetchDiariesForSelectedDate(isScrolling: true);
                        }
                        return false;
                      },
                      child: RefreshIndicator(
                        onRefresh:
                            () => _fetchDiariesForSelectedDate(
                              isScrolling: false,
                            ), // Reset on refresh
                        child:
                            _hasError
                                ? const Center(
                                  child: Text(
                                    "Falha ao carregar os diários. Tente novamente.",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                )
                                : _diaryEntries.isEmpty
                                ? const Center(
                                  child: Text(
                                    "Não há diários para este dia.",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 60),
                                  itemCount: _diaryEntries.length,
                                  itemBuilder: (context, index) {
                                    final entry = _diaryEntries[index];
                                    return Card(
                                      elevation: 4,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: ListTile(
                                        title: Text(entry.title),
                                        subtitle: Text(
                                          entry.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                        trailing: Icon(
                                          _getEmotionIcon(entry.emotion),
                                          color: const Color(0xFF0D1B2A),
                                          size: 32,
                                        ),
                                        onTap: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => DiaryDetailPage(
                                                    diary: entry,
                                                    createDiary: false,
                                                  ),
                                            ),
                                          );

                                          if (result == true) {
                                            // Refresh the search with the previously set parameters
                                            _fetchDiariesForSelectedDate(
                                              isScrolling: false,
                                            );
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Apply blur effect when filter panel is visible
          if (_isFilterPanelVisible)
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 5.0,
                sigmaY: 5.0,
              ), // Adjust blur intensity
              child: Container(
                color: Colors.black.withOpacity(
                  0.2,
                ), // Optional: Add a semi-transparent overlay
              ),
            ),

          // Filter Button
          Positioned(
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
                    if (_selectedEmotions
                        .isNotEmpty) // Show the small circle if filters are selected
                      Positioned(
                        top: 3,
                        right: 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(
                              0xFF0D1B2A,
                            ), // Blue color for the indicator
                          ),
                        ),
                      ),
                  ],
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
                  colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
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
                  const SizedBox(
                    height: 40,
                  ), // Space between the arrow and text
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
                          //"Filtrar por emoção",
                          "Emoções",
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
                          children:
                              DiaryType.values.map((emotion) {
                                final isSelected = _selectedEmotions.contains(
                                  emotion,
                                );
                                // Map DiaryType to Portuguese display names
                                String emotionDisplay;
                                switch (emotion) {
                                  case DiaryType.Love:
                                    emotionDisplay = "Amor";
                                    break;
                                  case DiaryType.Fantastic:
                                    emotionDisplay = "Fantástico";
                                    break;
                                  case DiaryType.Happy:
                                    emotionDisplay = "Feliz";
                                    break;
                                  case DiaryType.Neutral:
                                    emotionDisplay = "Neutro";
                                    break;
                                  case DiaryType.Disappointed:
                                    emotionDisplay = "Desapontado";
                                    break;
                                  case DiaryType.Sad:
                                    emotionDisplay = "Triste";
                                    break;
                                  case DiaryType.Angry:
                                    emotionDisplay = "Zangado";
                                    break;
                                  case DiaryType.Sick:
                                    emotionDisplay = "Doente";
                                    break;
                                }
                                return GestureDetector(
                                  onTap: () {
                                    _toggleEmotion(emotion);
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
                                              ? const Color(
                                                0xFF0D1B2A,
                                              ) // Selected button color
                                              : Colors
                                                  .white, // Default button color
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
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Center(
                                      child: Text(
                                        emotionDisplay,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF0D1B2A),
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
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Floating Action Button Positioned Upwards
          Positioned(
            bottom: 100, // Adjust the vertical position of the FAB
            right:
                _isFilterPanelVisible
                    ? -80
                    : 20, // Slide the FAB out when the filter panel is open
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity:
                  _isFilterPanelVisible
                      ? 0.0
                      : 1.0, // Hide the FAB when the filter panel is open
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => DiaryDetailPage(
                            diary: null, // Pass null for creating a new entry
                            createDiary: true,
                          ),
                    ),
                  );

                  if (result == true) {
                    // Refresh the search with the previously set parameters
                    _fetchDiariesForSelectedDate(isScrolling: false);
                  }
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.add, color: Color(0xFF0D1B2A)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _getEmotionIcon(DiaryType emotion) {
  switch (emotion) {
    case DiaryType.Love:
      return Icons.favorite;
    case DiaryType.Fantastic:
      return Icons.star;
    case DiaryType.Happy:
      return Icons.sentiment_satisfied;
    case DiaryType.Neutral:
      return Icons.sentiment_neutral;
    case DiaryType.Disappointed:
      return Icons.sentiment_dissatisfied;
    case DiaryType.Sad:
      return Icons.sentiment_very_dissatisfied;
    case DiaryType.Angry:
      return Icons.mood_bad;
    case DiaryType.Sick:
      return Icons.sick;
  }
}
