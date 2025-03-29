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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editMode ? "Edit Diary" : widget.diary == null ? "Create Diary" : "View Diary"),
        actions: [
          if (!editMode && widget.diary != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: toggleEditMode,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
              enabled: editMode || widget.diary == null,
            ),
            const SizedBox(height: 16),

            // Description Field
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 3,
              enabled: editMode || widget.diary == null,
            ),
            const SizedBox(height: 16),

            // Emotion Dropdown
            DropdownButtonFormField<Emotion>(
              value: selectedEmotion,
              items: Emotion.values
                  .map(
                    (emotion) => DropdownMenuItem(
                      value: emotion,
                      child: Text(StringCapitalization(emotion.name).capitalizeFirstLetter()),
                    ),
                  )
                  .toList(),
              onChanged: editMode || widget.diary == null
                  ? (value) {
                      setState(() {
                        selectedEmotion = value;
                      });
                    }
                  : null,
              decoration: const InputDecoration(labelText: "Emotion"),
            ),
            const SizedBox(height: 16),

            // Recorded At Date Picker
            Row(
              children: [
                const Text("Recorded At: "),
                TextButton(
                  onPressed: editMode || widget.diary == null
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
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Save and Cancel Buttons
            if (editMode || widget.diary == null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: cancelEdit,
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: saveDiary,
                    child: const Text("Save"),
                  ),
                ],
              ),
          ],
        ),
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