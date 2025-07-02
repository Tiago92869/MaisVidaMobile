import 'package:flutter/material.dart';
import 'package:testtest/services/diary/diary_model.dart';
import 'package:testtest/services/diary/diary_service.dart';
import 'dart:developer'; // Add this import for logging

class DiaryDetailPage extends StatefulWidget {
  final Diary?
  diary; // Pass a diary entry if editing or viewing, null if creating
  final bool createDiary; // Indicates if this is a new diary

  const DiaryDetailPage({Key? key, this.diary, this.createDiary = false})
    : super(key: key);

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

  bool _showFirstStarfish = true; // Determines which starfish to show

  @override
  void initState() {
    super.initState();
    log("DiaryDetailPage initialized with createDiary: ${widget.createDiary}, diary: ${widget.diary}");
    editMode = widget.createDiary; // Start in edit mode if creating a new diary
    titleController = TextEditingController(text: widget.diary?.title ?? "");
    descriptionController = TextEditingController(
      text: widget.diary?.description ?? "",
    );
    recordedAt = widget.diary?.recordedAt ?? DateTime.now();
    selectedEmotion = widget.diary?.emotion;

    // Randomly decide which starfish to show
    _showFirstStarfish = DateTime.now().millisecondsSinceEpoch % 2 == 0;
    log("Initial state set: editMode=$editMode, recordedAt=$recordedAt, selectedEmotion=$selectedEmotion");
  }

  Future<void> saveDiary() async {
    log("saveDiary called");
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedEmotion == null) {
      log("Missing fields: title=${titleController.text}, description=${descriptionController.text}, selectedEmotion=$selectedEmotion");
      // Show a styled popup message warning of missing fields
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF0D1B2A), // Match page background
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Rounded corners
            ),
            title: const Text(
              "Campos em falta",
              style: TextStyle(
                color: Colors.white, // White text
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              "Por favor preencha todos os campos (Título, Descrição e Emoção) antes de guardar.",
              style: TextStyle(
                color: Colors.white70, // Subtle white text
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text(
                  "OK",
                  style: TextStyle(
                    color: Colors.white, // White text for the button
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
      return; // Stop execution if fields are missing
    }

    final diary = Diary(
      id: widget.diary?.id ?? UniqueKey().toString(),
      title: titleController.text,
      description: descriptionController.text,
      recordedAt: recordedAt,
      emotion: selectedEmotion!,
      createdAt: widget.diary?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    log("Diary object created: $diary");

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      if (widget.createDiary) {
        log("Creating new diary");
        await _diaryService.createDiary(diary);
        log("Diary created successfully");
        Navigator.pop(context); // Close the loading dialog
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        log("Updating existing diary with id: ${widget.diary?.id}");
        await _diaryService.updateDiary(widget.diary!.id, diary);
        log("Diary updated successfully");
        Navigator.pop(context); // Close the loading dialog
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      log("Error saving diary: $e");
      Navigator.pop(context); // Close the loading dialog
      // Handle errors (e.g., show a snackbar)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Falha ao guardar o diário. Tente novamente."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    log("Delete confirmation dialog shown");
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0D1B2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Apagar Diário",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                "Tem a certeza de que pretende eliminar este diário? Esta ação não pode ser anulada.",
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    "Eliminar",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _deleteDiary() async {
    log("Deleting diary with id: ${widget.diary?.id}");
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      await _diaryService.deleteDiary(widget.diary!.id);
      log("Diary deleted successfully");
      Navigator.pop(context); // Close the loading dialog
      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      log("Error deleting diary: $e");
      Navigator.pop(context); // Close the loading dialog
      // Handle errors (e.g., show a snackbar)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Falha ao eliminar o diário. Tente novamente."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void toggleEditMode() {
    log("Toggling edit mode. Current state: $editMode");
    setState(() {
      editMode = !editMode;
    });
    log("Edit mode toggled. New state: $editMode");
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

  @override
  Widget build(BuildContext context) {
    log("Building DiaryDetailPage UI");
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

          // Randomly show one of the starfish images
          if (_showFirstStarfish)
            Positioned(
              right: 80,
              top: 320,
              width: 400,
              height: 400,
              child: Opacity(
                opacity: 0.1,
                child: Transform.rotate(
                  angle: 0.7,
                  child: Image.asset(
                    'assets/images/starfish2.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            )
          else
            Positioned(
              left: 100,
              top: 250,
              width: 400,
              height: 400,
              child: Opacity(
                opacity: 0.1,
                child: Transform.rotate(
                  angle: 0.5,
                  child: Image.asset(
                    'assets/images/starfish1.png',
                    fit: BoxFit.contain,
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
                      hintText: "Introduza o título do diário",
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Emotion Dropdown
                  if (editMode)
                    DropdownButton<DiaryType>(
                      value: selectedEmotion,
                      dropdownColor: const Color(0xFF0D1B2A),
                      items:
                          DiaryType.values.map((emotion) {
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Gravado em",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap:
                            editMode
                                ? () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: recordedAt,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                    builder: (
                                      BuildContext context,
                                      Widget? child,
                                    ) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          primaryColor: const Color(
                                            0xFF0D1B2A,
                                          ), // Header background color
                                          hintColor: const Color(
                                            0xFF0D1B2A,
                                          ), // Selected date color
                                          colorScheme: const ColorScheme.light(
                                            primary: Color(
                                              0xFF0D1B2A,
                                            ), // Header text color
                                            onPrimary:
                                                Colors
                                                    .white, // Header text color
                                            onSurface:
                                                Colors.black, // Body text color
                                          ),
                                          dialogBackgroundColor:
                                              Colors
                                                  .white, // Background color of the calendar
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      recordedAt = pickedDate;
                                    });
                                  }
                                }
                                : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${recordedAt.day.toString().padLeft(2, '0')}-${recordedAt.month.toString().padLeft(2, '0')}-${recordedAt.year}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
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
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Introduza a descrição do diário",
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
                log("Save/Edit button tapped. createDiary=${widget.createDiary}, editMode=$editMode");
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
                  color: const Color(0xFF0D1B2A),
                ),
              ),
            ),
          ),

          // Delete Button
          if (!widget.createDiary) // Show only when editing an existing diary
            Positioned(
              bottom: 20,
              right: 20, // Move the button to the right side
              child: GestureDetector(
                onTap: () async {
                  log("Delete button tapped");
                  final shouldDelete = await _showDeleteConfirmationDialog();
                  log("Delete confirmation result: $shouldDelete");
                  if (shouldDelete) {
                    await _deleteDiary();
                  }
                },
                child: CircleAvatar(
                  radius: 30, // Increase the size of the button
                  backgroundColor: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 28, // Increase the size of the icon
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
