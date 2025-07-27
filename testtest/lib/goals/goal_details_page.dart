import 'package:flutter/material.dart';
import 'package:testtest/services/goal/goal_service.dart';
import 'package:testtest/services/goal/goal_model.dart';

class GoalDetailPage extends StatefulWidget {
  final GoalInfoCard?
  goal; // Pass a goal for viewing/editing, or null for a new goal
  final bool
  createResource; // Indicates if the page is opened for creating a new goal
  final VoidCallback? onSave; // Callback to refresh goals in GoalsPage

  const GoalDetailPage({
    Key? key,
    this.goal,
    required this.createResource,
    this.onSave,
  }) : super(key: key);

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
  bool _isLoading = false; // Tracks if a save operation is in progress
  bool _showFirstStarfish = true; // Randomly show one of the starfish images

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.goal?.title ?? "");
    descriptionController = TextEditingController(
      text: widget.goal?.description ?? "",
    );
    selectedDate = widget.goal?.goalDate ?? DateTime.now();
    selectedSubject = widget.goal?.subject;
    hasNotifications = widget.goal?.hasNotifications ?? false;
    completed = widget.goal?.completed ?? false;
    editMode =
        widget
            .createResource; // Automatically enable edit mode if creating a new goal
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
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

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveGoal() async {
    final updatedGoal = GoalInfoCard(
      id:
          widget.goal?.id ??
          "", // Use the existing ID for updates or an empty ID for new goals
      title: titleController.text,
      description: descriptionController.text,
      goalDate: selectedDate ?? DateTime.now(),
      completedDate: completed ? DateTime.now() : null,
      completed: completed,
      hasNotifications: hasNotifications,
      subject:
          selectedSubject ??
          GoalSubject.Personal, // Default to Personal if no subject is selected
      createdAt: widget.goal?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      if (widget.createResource) {
        // Call createGoal if creating a new goal
        await _goalService.createGoal(updatedGoal);
        print('Meta criada com sucesso.');
      } else {
        // Call updateGoal if editing an existing goal
        await _goalService.updateGoal(updatedGoal.id, updatedGoal);
        print('Meta atualizada com sucesso.');
      }
      if (widget.onSave != null) {
        widget.onSave!(); // Trigger the callback to refresh goals
      }
    } catch (e) {
      print('Error saving goal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Falha ao salvar o meta. Tente novamente."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  Future<void> _deleteGoal() async {
    if (widget.goal == null || widget.goal!.id.isEmpty) return;

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      await _goalService.deleteGoal(widget.goal!.id);
      print('Meta eliminado com sucesso.');

      if (widget.onSave != null) {
        widget.onSave!(); // Trigger the callback to refresh goals
      }

      // Navigate back and pass a flag to indicate deletion
      Navigator.pop(context, true);
    } catch (e) {
      print('Error deleting goal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Falha ao eliminar a meta. Tente novamente."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0D1B2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Apagar Meta",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                "Tem a certeza de que pretende eliminar esta meta? Esta ação não pode ser anulada.",
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
        false; // Return false if the dialog is dismissed
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Simply go back without saving
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
                      maxLines: null, // Allow unlimited lines for title
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        hintText: "Insira o título da meta",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Subject Dropdown
                    if (editMode)
                      DropdownButton<GoalSubject>(
                        value: selectedSubject,
                        dropdownColor: const Color(0xFF0D1B2A),
                        items:
                            GoalSubject.values.map((subject) {
                              return DropdownMenuItem(
                                value: subject,
                                child: Text(
                                  getSubjectDisplayName(subject),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          selectedSubject != null
                              ? getSubjectDisplayName(selectedSubject!)
                              : "Sem Assunto",
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
                          "Data da meta",
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              selectedDate != null
                                  ? "${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}"
                                  : "Seleciona uma data",
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
                    if (!widget.createResource) // Show only when editing
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Concluídas",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                          Switch(
                            value: completed,
                            onChanged:
                                editMode
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
                          "Notificações",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        Switch(
                          value: hasNotifications,
                          onChanged:
                              editMode
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
                    TextField(
                      controller: descriptionController,
                      enabled: editMode,
                      maxLines: null,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Insira a descrição da meta",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Edit/Save Icons
          Positioned(
            top: 58,
            right: 30,
            child: GestureDetector(
              onTap: () async {
                if (editMode) {
                  // Validate fields when creating a new goal
                  if (widget.createResource &&
                      (titleController.text.isEmpty ||
                          descriptionController.text.isEmpty ||
                          selectedDate == null ||
                          selectedSubject == null)) {
                    // Show a styled popup message warning of missing fields
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: const Color(
                            0xFF0D1B2A,
                          ), // Match page background
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              20,
                            ), // Rounded corners
                          ),
                          title: const Text(
                            "Campos em falta",
                            style: TextStyle(
                              color: Colors.white, // White text
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: const Text(
                            "Por favor preencha todos os campos (Título, Descrição, Data e Assunto) antes de guardar.",
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
                                  color:
                                      Colors.white, // White text for the button
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

                  // Prevent multiple calls by disabling the button while saving
                  if (_isLoading) return;

                  // Save the goal and close the page
                  setState(() {
                    _isLoading = true; // Prevent duplicate calls
                  });

                  try {
                    await _saveGoal();

                    if (widget.onSave != null) {
                      widget.onSave!(); // Trigger the callback to refresh goals
                    }

                    Navigator.pop(
                      context,
                      true,
                    ); // Return true to indicate success
                  } catch (e) {
                    print('Error saving goal: $e');
                  } finally {
                    setState(() {
                      _isLoading = false; // Re-enable the button
                    });
                  }
                } else {
                  // Toggle edit mode
                  setState(() {
                    editMode = true;
                  });
                }
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  editMode ? Icons.check : Icons.edit,
                  color: const Color(0xFF0D1B2A),
                ),
              ),
            ),
          ),
          // Delete Button
          if (!widget.createResource) // Show only when editing an existing goal
            Positioned(
              bottom: 20,
              right: 20, // Move the button to the right side
              child: GestureDetector(
                onTap: () async {
                  final shouldDelete = await _showDeleteConfirmationDialog();
                  if (shouldDelete) {
                    await _deleteGoal();
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
