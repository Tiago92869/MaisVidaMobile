import 'package:flutter/material.dart';
import 'diary_page.dart';

class DiaryDetailPage extends StatefulWidget {
  final DiaryDTO? diary; // Pass a diary entry if editing or viewing, null if creating
  final bool isEditing; // Indicates if the page is in editing mode

  const DiaryDetailPage({Key? key, this.diary, this.isEditing = false}) : super(key: key);

  @override
  _DiaryDetailPageState createState() => _DiaryDetailPageState();
}

class _DiaryDetailPageState extends State<DiaryDetailPage> {
  bool editMode = false; // Tracks if the user is editing
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late DateTime recordedAt;
  Emotion? selectedEmotion;

  @override
  void initState() {
    super.initState();
    editMode = widget.isEditing;
    titleController = TextEditingController(text: widget.diary?.title ?? "");
    descriptionController = TextEditingController(text: widget.diary?.description ?? "");
    recordedAt = widget.diary?.recordedAt ?? DateTime.now();
    selectedEmotion = widget.diary?.emotion;
  }

  void saveDiary() {
    if (titleController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        selectedEmotion != null) {
      final newDiary = DiaryDTO(
        id: widget.diary?.id ?? UniqueKey().toString(),
        title: titleController.text,
        description: descriptionController.text,
        recordedAt: recordedAt,
        emotion: selectedEmotion!,
        createdAt: widget.diary?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Return the new or updated diary entry to the previous page
      Navigator.pop(context, newDiary);
    }
  }

  void toggleEditMode() {
    setState(() {
      editMode = !editMode;
    });
  }

  void cancelEdit() {
    setState(() {
      editMode = false;
      titleController.text = widget.diary?.title ?? "";
      descriptionController.text = widget.diary?.description ?? "";
      recordedAt = widget.diary?.recordedAt ?? DateTime.now();
      selectedEmotion = widget.diary?.emotion;
    });
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
                    DropdownButton<Emotion>(
                      value: selectedEmotion,
                      dropdownColor: const Color.fromRGBO(72, 85, 204, 1),
                      items: Emotion.values.map((emotion) {
                        return DropdownMenuItem(
                          value: emotion,
                          child: Text(
                            StringCapitalization(emotion.name).capitalizeFirstLetter(),
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
                          StringCapitalization(selectedEmotion!.name).capitalizeFirstLetter(),
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

          // Cancel Icon (only show in editing mode and when editing an existing diary)
          if (editMode && widget.diary != null)
            Positioned(
              top: 58,
              right: 90, // Position to the left of the save/edit icon
              child: GestureDetector(
                onTap: cancelEdit,
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
                    Icons.cancel,
                    color: Colors.red,
                    size: 28,
                  ),
                ),
              ),
            ),

          // Edit/Save Icons
          Positioned(
            top: 58,
            right: 30,
            child: GestureDetector(
              onTap: editMode ? saveDiary : toggleEditMode,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  editMode ? Icons.check : Icons.edit,
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

extension StringCapitalization on String {
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}