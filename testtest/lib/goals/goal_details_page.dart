import 'package:flutter/material.dart';
import 'package:testtest/services/goal/goal_service.dart';
import 'package:testtest/services/goal/goal_model.dart';

class GoalDetailPage extends StatefulWidget {
  final GoalInfoCard? goal; // Pass a goal for viewing/editing, or null for a new goal
  final bool createResource; // Indicates if the page is opened for creating a new goal

  const GoalDetailPage({Key? key, this.goal, required this.createResource}) : super(key: key);

  @override
  _GoalDetailPageState createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends State<GoalDetailPage> {
  final GoalService _goalService = GoalService();

  late TextEditingController titleController;
  late TextEditingController descriptionController;
  DateTime? selectedDate; // Track the selected date
  GoalSubject? selectedSubject;
  bool hasNotifications = false; // Local variable for notifications toggle
  bool completed = false; // Local variable for completed toggle
  late bool editMode; // Tracks if the user is editing

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.goal?.title ?? "");
    descriptionController = TextEditingController(text: widget.goal?.description ?? "");
    selectedDate = widget.goal?.goalDate ?? DateTime.now();
    selectedSubject = widget.goal?.subject;
    hasNotifications = widget.goal?.hasNotifications ?? false;
    completed = widget.goal?.completed ?? false;
    editMode = widget.createResource; // Automatically enable edit mode if creating a new goal
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveGoal() async {
    final updatedGoal = GoalInfoCard(
      id: widget.goal?.id ?? "", // Use the existing ID for updates or an empty ID for new goals
      title: titleController.text,
      description: descriptionController.text,
      goalDate: selectedDate ?? DateTime.now(),
      completedDate: completed ? DateTime.now() : null,
      completed: completed,
      hasNotifications: hasNotifications,
      subject: selectedSubject ?? GoalSubject.Personal, // Default to Personal if no subject is selected
      createdAt: widget.goal?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      if (widget.createResource) {
        // Call createGoal if creating a new goal
        await _goalService.createGoal(updatedGoal);
        print('Goal created successfully.');
      } else {
        // Call updateGoal if editing an existing goal
        await _goalService.updateGoal(updatedGoal.id, updatedGoal);
        print('Goal updated successfully.');
      }
    } catch (e) {
      print('Error saving goal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to save goal. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
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
                    onTap: () async {
                      await _saveGoal(); // Save the goal (create or update)
                      Navigator.pop(context); // Close the page
                    },
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
                    DropdownButton<GoalSubject>(
                      value: selectedSubject,
                      dropdownColor: const Color.fromRGBO(72, 85, 204, 1),
                      items: GoalSubject.values.map((subject) {
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
                          selectedSubject = value!;
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
                        selectedSubject?.toString().split('.').last.capitalizeFirstLetter() ?? "No Subject",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Goal Date Picker
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
                      GestureDetector(
                        onTap: editMode ? _pickDate : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            selectedDate != null
                                ? "${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}"
                                : "Select a date",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),

                  // Completed Toggle
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
                        value: completed,
                        onChanged: editMode
                            ? (value) {
                                setState(() {
                                  completed = value;
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
          // Edit/Save Icons
          Positioned(
            top: 58,
            right: 30,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  editMode = !editMode;
                });
              },
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

// Extension to capitalize the first letter of a string
extension StringCapitalization on String {
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}