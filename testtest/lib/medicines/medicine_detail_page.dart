import 'dart:math'; // Import for Random
import 'package:flutter/material.dart';
import 'package:testtest/services/medicine/medicine_model.dart'; // Import the models
import 'package:testtest/services/medicine/medicine_repository.dart'; // Import the repository

class MedicineDetailPage extends StatefulWidget {
  final Medicine? medicine; // Use the Medicine model
  final bool isEditing; // Indicates if the page is in editing mode

  const MedicineDetailPage({Key? key, this.medicine, this.isEditing = false})
    : super(key: key);

  @override
  _MedicineDetailPageState createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends State<MedicineDetailPage> {
  final MedicineRepository _medicineRepository =
      MedicineRepository(); // Repository instance
  bool editMode = false; // Tracks if the user is editing
  bool isSaving = false; // Tracks if the save operation is in progress
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  DateTime? startDate; // Start date for the medicine
  DateTime? endDate; // End date for the medicine
  bool hasNotifications = false; // Local variable for notifications toggle
  bool isArchived = false; // Local variable for archived toggle
  final bool _showFirstStarfish =
      Random().nextBool(); // Randomly decide which starfish to show

  @override
  void initState() {
    super.initState();
    editMode = widget.isEditing;
    nameController = TextEditingController(text: widget.medicine?.name ?? "");
    descriptionController = TextEditingController(
      text: widget.medicine?.description ?? "",
    );
    startDate = widget.medicine?.startedAt ?? DateTime.now();
    endDate = widget.medicine?.endedAt ?? DateTime.now();
    hasNotifications = widget.medicine?.hasNotifications ?? false;
    isArchived = widget.medicine?.archived ?? false;
  }

  Future<void> _pickDate({required bool isStartDate}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          isStartDate
              ? (startDate ?? DateTime.now())
              : (endDate ?? DateTime.now()),
      firstDate: DateTime(2000), // Earliest selectable date
      lastDate: DateTime(2100), // Latest selectable date
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color.fromRGBO(
              72,
              85,
              204,
              1,
            ), // Header background color
            hintColor: const Color.fromRGBO(
              123,
              144,
              255,
              1,
            ), // Selected date color
            colorScheme: const ColorScheme.light(
              primary: Color.fromRGBO(72, 85, 204, 1), // Header text color
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

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          startDate = pickedDate;
        } else {
          endDate = pickedDate;
        }
      });
    }
  }

  Future<void> saveMedicine() async {
    setState(() {
      isSaving = true; // Show loading indicator
    });

    try {
      final String name = nameController.text.trim();
      final String description = descriptionController.text.trim();

      // Validation: Check if required fields are filled
      if (name.isEmpty ||
          description.isEmpty ||
          startDate == null ||
          endDate == null) {
        _showMissingFieldsDialog();
        return;
      }

      // Validation: Check if start date is earlier than or equal to end date
      if (startDate!.isAfter(endDate!)) {
        _showErrorSnackBar(
          "End Date can only be equal or bigger then Start Date",
        );
        return;
      }

      if (widget.medicine == null) {
        // Creating a new medicine
        final newMedicine = MedicineCreate(
          name: name,
          description: description,
          archived: false, // Set archived to false for new medicines
          startedAt: startDate!,
          endedAt: endDate!,
          hasNotifications: hasNotifications,
        );
        await _medicineRepository.createMedicine(newMedicine);
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        // Updating an existing medicine
        final updatedMedicine = Medicine(
          id: widget.medicine!.id,
          name: name,
          description: description,
          archived: isArchived,
          startedAt: startDate!,
          endedAt: endDate!,
          hasNotifications: hasNotifications,
          createdAt: widget.medicine!.createdAt,
          updatedAt: DateTime.now(),
          plans: widget.medicine!.plans, // Include plans
        );
        await _medicineRepository.updateMedicine(
          updatedMedicine.id,
          updatedMedicine,
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      print("Error saving medicine: $e");
      _showErrorSnackBar("Failed to save medicine. Please try again.");
    } finally {
      setState(() {
        isSaving = false; // Hide loading indicator
      });
    }
  }

  Future<void> _deleteMedicine() async {
    if (widget.medicine == null || widget.medicine!.id.isEmpty) return;

    setState(() {
      isSaving = true; // Show loading indicator
    });

    try {
      await _medicineRepository.deleteMedicine(widget.medicine!.id);
      print('Medicine deleted successfully.');

      // Navigate back and pass a flag to indicate deletion
      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      print('Error deleting medicine: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to delete medicine. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSaving = false; // Hide loading indicator
      });
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color.fromRGBO(72, 85, 204, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Delete Medicine",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                "Are you sure you want to delete this medicine? This action cannot be undone.",
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if the dialog is dismissed
  }

  void _showMissingFieldsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(72, 85, 204, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Missing Fields",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Please fill in all the fields (Name, Description, Start Date, and End Date) before saving.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Function to display the 7-day plan
  Widget _build7DayPlan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Week Plan",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap:
              true, // Ensures the ListView takes only the required space
          physics: const NeverScrollableScrollPhysics(), // Disable scrolling
          itemCount: widget.medicine?.plans.length ?? 0,
          itemBuilder: (context, index) {
            final plan = widget.medicine!.plans[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Weekday
                  Text(
                    plan.weekDay,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  // Dosages (Placeholder for now)
                  Text(
                    plan.dosages.isEmpty
                        ? "No dosages"
                        : "${plan.dosages.length} dosages",
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
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
                    Color.fromRGBO(72, 85, 204, 0.9),
                    Color.fromRGBO(123, 144, 255, 0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Add starfish logic
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

          // Loading Indicator
          if (isSaving)
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // Content
          SafeArea(
            child: SizedBox.expand(
              child: SingleChildScrollView(
                // Make the page scrollable
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
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

                    // Name
                    TextField(
                      controller: nameController,
                      enabled: editMode,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        hintText: "Enter Medicine Name",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Description
                    TextField(
                      controller: descriptionController,
                      enabled: editMode,
                      maxLines: null,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Enter Medicine Description",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Start Date
                    const Text(
                      "Start Date",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap:
                          editMode ? () => _pickDate(isStartDate: true) : null,
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
                          startDate != null
                              ? "${startDate!.day.toString().padLeft(2, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.year}"
                              : "Select a start date",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // End Date
                    const Text(
                      "End Date",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap:
                          editMode ? () => _pickDate(isStartDate: false) : null,
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
                          endDate != null
                              ? "${endDate!.day.toString().padLeft(2, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.year}"
                              : "Select an end date",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 7-Day Plan (Only visible when editing an existing medicine)
                    if (widget.medicine != null) _build7DayPlan(),
                    const SizedBox(height: 20),

                    // Notifications Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Notifications",
                          style: TextStyle(
                            fontSize: 16, // Match font size with "Start Date"
                            fontWeight: FontWeight.bold, // Keep bold style
                            color: Colors.white,
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
                    const SizedBox(height: 10),

                    // Archived Toggle (only visible when editing an existing medicine)
                    if (widget.medicine != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Archived",
                            style: TextStyle(
                              fontSize: 16, // Match font size with "Start Date"
                              fontWeight: FontWeight.bold, // Keep bold style
                              color: Colors.white,
                            ),
                          ),
                          Switch(
                            value: isArchived,
                            onChanged:
                                editMode
                                    ? (value) {
                                      setState(() {
                                        isArchived = value;
                                      });
                                    }
                                    : null,
                          ),
                        ],
                      ),

                    const SizedBox(height: 100),
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
              onTap:
                  editMode
                      ? saveMedicine
                      : () => setState(() => editMode = true),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  editMode ? Icons.check : Icons.edit,
                  color: const Color.fromRGBO(72, 85, 204, 1),
                ),
              ),
            ),
          ),

          // Delete Button
          if (widget.medicine != null)
            Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTap: () async {
                  final shouldDelete = await _showDeleteConfirmationDialog();
                  if (shouldDelete) {
                    await _deleteMedicine();
                  }
                },
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
