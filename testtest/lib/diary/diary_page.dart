import 'dart:ui'; // For BackdropFilter
import 'package:flutter/material.dart';
import 'diary_detail_page.dart'; // Import the new page

enum Emotion {
  LOVE,
  FANTASTIC,
  HAPPY,
  NEUTRAL,
  DISAPPOINTED,
  SAD,
  ANGRY,
  SICK,
}

class DiaryDTO {
  final String id;
  final String title;
  final String description;
  final DateTime recordedAt;
  final Emotion emotion;
  final DateTime createdAt;
  final DateTime updatedAt;

  DiaryDTO({
    required this.id,
    required this.title,
    required this.description,
    required this.recordedAt,
    required this.emotion,
    required this.createdAt,
    required this.updatedAt,
  });
}

class DiaryPage extends StatefulWidget {
  const DiaryPage({Key? key}) : super(key: key);

  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  DateTime _selectedDate = DateTime.now();

  // Sample diary entries
  final List<DiaryDTO> _diaryEntries = [
    DiaryDTO(
      id: "1",
      title: "Morning Walk",
      description: "Had a refreshing walk in the park.",
      recordedAt: DateTime.now().subtract(const Duration(days: 1)),
      emotion: Emotion.HAPPY,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    DiaryDTO(
      id: "2",
      title: "Work Presentation",
      description: "Delivered a successful presentation at work.Delivered a successful presentation at work.Delivered a successful presentation at work.",
      recordedAt: DateTime.now(),
      emotion: Emotion.FANTASTIC,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    DiaryDTO(
      id: "2",
      title: "Work Presentation",
      description: "Delivered a successful presentation at work.Delivered a successful presentation at work.Delivered a successful presentation at work.",
      recordedAt: DateTime.now(),
      emotion: Emotion.FANTASTIC,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    DiaryDTO(
      id: "2",
      title: "Work Presentation",
      description: "Delivered a successful presentation at work.Delivered a successful presentation at work.Delivered a successful presentation at work.",
      recordedAt: DateTime.now(),
      emotion: Emotion.FANTASTIC,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    DiaryDTO(
      id: "2",
      title: "Work Presentation",
      description: "Delivered a successful presentation at work.Delivered a successful presentation at work.Delivered a successful presentation at work.",
      recordedAt: DateTime.now(),
      emotion: Emotion.FANTASTIC,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    DiaryDTO(
      id: "2",
      title: "Work Presentation",
      description: "Delivered a successful presentation at work.Delivered a successful presentation at work.Delivered a successful presentation at work.",
      recordedAt: DateTime.now(),
      emotion: Emotion.FANTASTIC,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    DiaryDTO(
      id: "2",
      title: "Work Presentation",
      description: "Delivered a successful presentation at work.Delivered a successful presentation at work.Delivered a successful presentation at work.",
      recordedAt: DateTime.now(),
      emotion: Emotion.FANTASTIC,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    DiaryDTO(
      id: "2",
      title: "Work Presentation",
      description: "Delivered a successful presentation at work.Delivered a successful presentation at work.Delivered a successful presentation at work.",
      recordedAt: DateTime.now(),
      emotion: Emotion.FANTASTIC,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    DiaryDTO(
      id: "3",
      title: "Evening Yoga",
      description: "Relaxed with a yoga session in the evening.",
      recordedAt: DateTime.now(),
      emotion: Emotion.LOVE,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    DiaryDTO(
      id: "4",
      title: "Rainy Day",
      description: "It rained all day, felt a bit gloomy.",
      recordedAt: DateTime.now().subtract(const Duration(days: 2)),
      emotion: Emotion.SAD,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  final Set<Emotion> _selectedEmotions = {}; // Selected filter emotions
  bool _isFilterPanelVisible = false; // Filter panel visibility

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Emotion? _selectedEmotion;

  // Function to add a new diary entry
  void _addDiaryEntry() {
    if (_titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _selectedEmotion != null) {
      setState(() {
        _diaryEntries.add(
          DiaryDTO(
            id: UniqueKey().toString(),
            title: _titleController.text,
            description: _descriptionController.text,
            recordedAt: _selectedDate,
            emotion: _selectedEmotion!,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        _titleController.clear();
        _descriptionController.clear();
        _selectedEmotion = null;
      });
    }
    Navigator.pop(context); // Close the add entry modal
  }

  // Function to filter diary entries by the selected date and emotions
  List<DiaryDTO> _getEntriesForSelectedDate() {
    return _diaryEntries
        .where((entry) =>
            entry.recordedAt.toLocal().year == _selectedDate.toLocal().year &&
            entry.recordedAt.toLocal().month == _selectedDate.toLocal().month &&
            entry.recordedAt.toLocal().day == _selectedDate.toLocal().day &&
            (_selectedEmotions.isEmpty || _selectedEmotions.contains(entry.emotion)))
        .toList();
  }

  // Function to navigate to the previous day
  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  // Function to navigate to the next day
  void _goToNextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
  }

  // Function to toggle the filter panel visibility
  void _toggleFilterPanel() {
    setState(() {
      _isFilterPanelVisible = !_isFilterPanelVisible;
    });
  }

  // Function to show the add entry modal
  void _showAddEntryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                DropdownButton<Emotion>(
                  value: _selectedEmotion,
                  hint: const Text('Select Emotion'),
                  items: Emotion.values.map((Emotion emotion) {
                    return DropdownMenuItem<Emotion>(
                      value: emotion,
                      child: Text(StringCapitalization(emotion.name).capitalizeFirstLetter()),
                    );
                  }).toList(),
                  onChanged: (Emotion? newValue) {
                    setState(() {
                      _selectedEmotion = newValue;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addDiaryEntry,
                  child: const Text('Add Entry'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final entriesForSelectedDate = _getEntriesForSelectedDate();

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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Center(
                    child: Text(
                      "Diary",
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
                      Text(
                        "${_selectedDate.toLocal().month}/${_selectedDate.toLocal().day}/${_selectedDate.toLocal().year}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward, color: Colors.white),
                        onPressed: _goToNextDay,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Diary Entries List
                  Expanded(
                    child: entriesForSelectedDate.isEmpty
                        ? const Center(
                            child: Text(
                              "No entries for this day.",
                              style: TextStyle(fontSize: 16, color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            itemCount: entriesForSelectedDate.length,
                            itemBuilder: (context, index) {
                              final entry = entriesForSelectedDate[index];
                              return Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(entry.title),
                                  subtitle: Text(
                                    entry.description,
                                    maxLines: 2, // Show only 2 lines of the description
                                    overflow: TextOverflow.ellipsis, // Add ellipsis if the text overflows
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                  trailing: Icon(
                                    _getEmotionIcon(entry.emotion),
                                    color: Colors.blue,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DiaryDetailPage(
                                          diary: entry,
                                          isEditing: false,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
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
                          "Filter by Emotion",
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
                          children: Emotion.values.map((emotion) {
                            final isSelected = _selectedEmotions.contains(emotion);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedEmotions.remove(emotion);
                                  } else {
                                    _selectedEmotions.add(emotion);
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
                                    StringCapitalization(emotion.name).capitalizeFirstLetter(),
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : const Color.fromRGBO(72, 85, 204, 1),
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
            bottom: 100, // Adjust this value to move the button upwards
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiaryDetailPage(
                      diary: null, // Pass null for creating a new entry
                      isEditing: true,
                    ),
                  ),
                );
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

IconData _getEmotionIcon(Emotion emotion) {
  switch (emotion) {
    case Emotion.LOVE:
      return Icons.favorite;
    case Emotion.FANTASTIC:
      return Icons.star;
    case Emotion.HAPPY:
      return Icons.sentiment_satisfied;
    case Emotion.NEUTRAL:
      return Icons.sentiment_neutral;
    case Emotion.DISAPPOINTED:
      return Icons.sentiment_dissatisfied;
    case Emotion.SAD:
      return Icons.sentiment_very_dissatisfied;
    case Emotion.ANGRY:
      return Icons.mood_bad;
    case Emotion.SICK:
      return Icons.sick;
    default:
      return Icons.sentiment_neutral;
  }
}

extension StringCapitalization on String {
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}