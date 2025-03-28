import 'package:flutter/material.dart';
import 'goals_page.dart';

class GoalDetailPage extends StatefulWidget {
  final GoalDTO? goal; // Pass a goal if editing or visualizing, null if creating
  final bool isEditing; // Indicates if the page is in editing mode

  const GoalDetailPage({Key? key, this.goal, this.isEditing = false}) : super(key: key);

  @override
  _GoalDetailPageState createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends State<GoalDetailPage> {
  bool editMode = false; // Tracks if the user is editing
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController goalDateController;
  Subject? selectedSubject;
  bool hasNotifications = false; // Local variable for notifications toggle

  @override
  void initState() {
    super.initState();
    editMode = widget.isEditing;
    titleController = TextEditingController(text: widget.goal?.title ?? "");
    descriptionController = TextEditingController(text: widget.goal?.description ?? "");
    goalDateController = TextEditingController(
      text: widget.goal?.goalDate != null
          ? "${widget.goal!.goalDate.day.toString().padLeft(2, '0')}-${widget.goal!.goalDate.month.toString().padLeft(2, '0')}-${widget.goal!.goalDate.year}"
          : "",
    );
    selectedSubject = widget.goal?.subject ?? Subject.PERSONAL;
    hasNotifications = widget.goal?.hasNotifications ?? false; // Initialize from goal or default to false
  }

  void saveGoal() {
    // Save the goal (in a real app, you'd save it to a database or API)
    print("Goal saved: ${titleController.text}, ${descriptionController.text}, $selectedSubject, Notifications: $hasNotifications");

    // Close the page after saving
    Navigator.pop(context);
  }

  void toggleEditMode() {
    setState(() {
      editMode = !editMode;
    });
  }

  void cancelEdit() {
    setState(() {
      // Revert changes and exit edit mode
      titleController.text = widget.goal?.title ?? "";
      descriptionController.text = widget.goal?.description ?? "";
      goalDateController.text = widget.goal?.goalDate != null
          ? "${widget.goal!.goalDate.day.toString().padLeft(2, '0')}-${widget.goal!.goalDate.month.toString().padLeft(2, '0')}-${widget.goal!.goalDate.year}"
          : "";
      selectedSubject = widget.goal?.subject ?? Subject.PERSONAL;
      editMode = false;
    });
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
                      hintText: "Enter Goal Title",
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Subject Dropdown
                  if (editMode)
                    DropdownButton<Subject>(
                      value: selectedSubject,
                      dropdownColor: const Color.fromRGBO(72, 85, 204, 1),
                      items: Subject.values.map((subject) {
                        return DropdownMenuItem(
                          value: subject,
                          child: Text(
                            subject.toString().split('.').last.capitalizeFirstLetter(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSubject = value;
                        });
                      },
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        selectedSubject.toString().split('.').last.capitalizeFirstLetter(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Goal Date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Goal Date",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: goalDateController,
                        enabled: editMode,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Enter Goal Date",
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),

                  // Completed Toggle
                  if (widget.goal != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Completed",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        Switch(
                          value: widget.goal!.completed,
                          onChanged: editMode
                              ? (value) {
                                  setState(() {
                                    widget.goal!.completed = value;
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),

                  // Notifications Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Notifications",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      Switch(
                        value: hasNotifications,
                        onChanged: editMode
                            ? (value) {
                                setState(() {
                                  hasNotifications = value;
                                });
                              }
                            : null,
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
                        hintText: "Enter Goal Description",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Cancel Icon (only show in editing mode and when editing an existing goal)
          if (editMode && widget.goal != null)
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
              onTap: editMode ? saveGoal : toggleEditMode,
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