import 'package:flutter/material.dart';
import 'diary_page.dart';
import 'package:testtest/services/diary/diary_model.dart';
import 'package:testtest/services/diary/diary_service.dart';

class DiaryDetailPage extends StatefulWidget {
  final Diary? diary; // Pass a diary entry if editing or viewing, null if creating
  final bool createDiary; // Indicates if this is a new diary

  const DiaryDetailPage({
    Key? key,
    this.diary,
    this.createDiary = false,
  }) : super(key: key);

  @override
  _DiaryDetailPageState createState() => _DiaryDetailPageState();
}

class _DiaryDetailPageState extends State<DiaryDetailPage> {
  bool editMode = false; // Tracks if the user is editing
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late DateTime recordedAt;
  DiaryType? selectedEmotion;
  final DiaryService _diaryService = DiaryService(); // Initialize DiaryService

  @override
  void initState() {
    super.initState();
    editMode = widget.createDiary; // Start in edit mode if creating a new diary
    titleController = TextEditingController(text: widget.diary?.title ?? "");
    descriptionController = TextEditingController(text: widget.diary?.description ?? "");
    recordedAt = widget.diary?.recordedAt ?? DateTime.now();
    selectedEmotion = widget.diary?.emotion;
  }

  Future<void> saveDiary() async {
    if (titleController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        selectedEmotion != null) {
      final diary = Diary(
        id: widget.diary?.id ?? UniqueKey().toString(),
        title: titleController.text,
        description: descriptionController.text,
        recordedAt: recordedAt,
        emotion: selectedEmotion!,
        createdAt: widget.diary?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      try {
        if (widget.createDiary) {
          // Call createDiary if this is a new diary
          final createdDiary = await _diaryService.createDiary(diary);
          Navigator.pop(context); // Close the loading dialog
          Navigator.pop(context, createdDiary); // Return the created diary
        } else {
          // Call updateDiary if editing an existing diary
          final updatedDiary = await _diaryService.updateDiary(diary.id, diary);
          Navigator.pop(context); // Close the loading dialog
          Navigator.pop(context, updatedDiary); // Return the updated diary
        }
      } catch (e) {
        Navigator.pop(context); // Close the loading dialog
        // Handle errors (e.g., show a snackbar)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to save diary. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void toggleEditMode() {
    setState(() {
      editMode = !editMode;
    });
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
      default:
        return Icons.sentiment_neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(72, 85, 204, 0.9), // Start color (darker blue)
                    Color.fromRGBO(123, 144, 255, 0.9), // End color (lighter blue)
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
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  TextField(
                    controller: titleController,
                    enabled: editMode,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      hintText: "Enter Diary Title",
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Emotion Dropdown
                  if (editMode)
                    DropdownButton<DiaryType>(
                      value: selectedEmotion,
                      dropdownColor: const Color.fromRGBO(72, 85, 204, 1),
                      items: DiaryType.values.map((emotion) {
                        return DropdownMenuItem(
                          value: emotion,
                          child: Text(
                            emotion.toString().split('.').last,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedEmotion = value;
                        });
                      },
                    )
                  else if (selectedEmotion != null)
                    Row(
                      children: [
                        Icon(
                          _getEmotionIcon(selectedEmotion!),
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          selectedEmotion!.toString().split('.').last,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),

                  // Recorded At Date
                  Row(
                    children: [
                      const Text(
                        "Recorded At: ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      TextButton(
                        onPressed: editMode
                            ? () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: recordedAt,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (pickedDate != null) {
                                  setState(() {
                                    recordedAt = pickedDate;
                                  });
                                }
                              }
                            : null,
                        child: Text(
                          "${recordedAt.month}/${recordedAt.day}/${recordedAt.year}",
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Expanded(
                    child: TextField(
                      controller: descriptionController,
                      enabled: editMode,
                      maxLines: null,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        hintText: "Enter Diary Description",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Save/Edit Icons
          Positioned(
            top: 58,
            right: 30,
            child: GestureDetector(
              onTap: () {
                if (widget.createDiary || editMode) {
                  // Save the diary if creating or in edit mode
                  saveDiary();
                } else {
                  // Toggle edit mode if viewing
                  toggleEditMode();
                }
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  widget.createDiary || editMode ? Icons.check : Icons.edit,
                  color: const Color.fromRGBO(72, 85, 204, 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}