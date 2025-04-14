import 'dart:math'; // Import for Random
import 'package:flutter/material.dart';
import 'package:testtest/services/medicine/medicine_model.dart'; // Import the models
import 'package:testtest/services/medicine/medicine_repository.dart'; // Import the repository
import 'medicines_page.dart';

// Define WeekDay enum if not already defined elsewhere
enum WeekDay { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

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
  late TextEditingController startDateController;
  late TextEditingController endDateController;
  bool hasNotifications = false; // Local variable for notifications toggle
  bool isArchived = false; // Local variable for archived toggle
  bool _showFirstStarfish = Random().nextBool();

  //REMOVE
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  } // Randomly decide which starfish to show

  /*
  @override
  void initState() {
    super.initState();
    editMode = widget.isEditing;
    nameController = TextEditingController(text: widget.medicine?.name ?? "");
    descriptionController = TextEditingController(
      text: widget.medicine?.description ?? "",
    );
    startDateController = TextEditingController(
      text:
          widget.medicine?.startedAt != null
              ? "${widget.medicine!.startedAt.day.toString().padLeft(2, '0')}-${widget.medicine!.startedAt.month.toString().padLeft(2, '0')}-${widget.medicine!.startedAt.year}"
              : "",
    );
    endDateController = TextEditingController(
      text:
          widget.medicine?.endedAt != null
              ? "${widget.medicine!.endedAt.day.toString().padLeft(2, '0')}-${widget.medicine!.endedAt.month.toString().padLeft(2, '0')}-${widget.medicine!.endedAt.year}"
              : "",
    );
    hasNotifications =
        widget.medicine?.hasNotifications ??
        false; // Initialize from medicine or default to false
    isArchived = widget.medicine?.archived ?? false;
  }

  Future<void> saveMedicine() async {
    setState(() {
      isSaving = true; // Show loading indicator
    });

    try {
      final String name = nameController.text.trim();
      final String description = descriptionController.text.trim();
      final DateTime? startedAt =
          startDateController.text.isNotEmpty
              ? _parseDate(startDateController.text)
              : null;
      final DateTime? endedAt =
          endDateController.text.isNotEmpty
              ? _parseDate(endDateController.text)
              : null;

      // Validation: Check if required fields are filled
      if (name.isEmpty ||
          description.isEmpty ||
          startedAt == null ||
          endedAt == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Please fill in all required fields: Name, Description, Start Date, and End Date.",
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isSaving = false; // Hide loading indicator
        });
        return;
      }

      // Validation: Check if start date is earlier than or equal to end date
      if (startedAt.isAfter(endedAt)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Start Date must be earlier than or equal to End Date.",
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isSaving = false; // Hide loading indicator
        });
        return;
      }

      if (widget.medicine == null) {
        // Creating a new medicine
        final newMedicine = Medicine(
          id: UniqueKey().toString(),
          name: name,
          description: description,
          archived: isArchived,
          startedAt: startedAt,
          endedAt: endedAt,
          hasNotifications: hasNotifications,
          plans: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (widget.medicine == null && newMedicine.plans.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please add at least one plan before saving."),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            isSaving = false; // Hide loading indicator
          });
          return;
        }

        await _medicineRepository.createMedicine(newMedicine);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Medicine created successfully!")),
        );
      } else {
        // Updating an existing medicine
        final updatedMedicine = widget.medicine!.copyWith(
          name: name,
          description: description,
          archived: isArchived,
          startedAt: startedAt,
          endedAt: endedAt,
          hasNotifications: hasNotifications,
          plans: widget.medicine!.plans ?? [], // Ensure plans are not null
        );
        await _medicineRepository.updateMedicine(
          updatedMedicine.id,
          updatedMedicine,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Medicine updated successfully!")),
        );
      }

      // Close the page after saving
      Navigator.pop(context);
    } catch (e) {
      print("Error saving medicine: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to save medicine. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSaving = false; // Hide loading indicator
      });
    }
  }

  void toggleEditMode() {
    setState(() {
      editMode = !editMode;
    });
  }

  void cancelEdit() {
    setState(() {
      // Revert changes and exit edit mode
      nameController.text = widget.medicine?.name ?? "";
      descriptionController.text = widget.medicine?.description ?? "";
      startDateController.text =
          widget.medicine?.startedAt != null
              ? "${widget.medicine!.startedAt.day.toString().padLeft(2, '0')}-${widget.medicine!.startedAt.month.toString().padLeft(2, '0')}-${widget.medicine!.startedAt.year}"
              : "";
      endDateController.text =
          widget.medicine?.endedAt != null
              ? "${widget.medicine!.endedAt.day.toString().padLeft(2, '0')}-${widget.medicine!.endedAt.month.toString().padLeft(2, '0')}-${widget.medicine!.endedAt.year}"
              : "";
      hasNotifications = widget.medicine?.hasNotifications ?? false;
      editMode = false;
    });
  }

  void _showAddPlanDialog() {
    List<WeekDay> selectedDays = [];
    TimeOfDay? selectedTime;
    double? dosage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(
                        72,
                        85,
                        204,
                        0.9,
                      ), // Start color (darker blue)
                      Color.fromRGBO(
                        123,
                        144,
                        255,
                        0.9,
                      ), // End color (lighter blue)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Add Weekly Plan",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Select Days:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8.0,
                        children:
                            [
                              "Jan",
                              "Feb",
                              "Mar",
                              "Apr",
                              "May",
                              "Jun",
                              "Jul",
                              "Aug",
                              "Sep",
                              "Oct",
                              "Nov",
                              "Dec",
                            ].map((month) {
                              return FilterChip(
                                label: Text(
                                  "${day.name[0].toUpperCase()}${day.name.substring(1).toLowerCase()}",
                                  style: TextStyle(
                                    color:
                                        selectedDays.contains(day)
                                            ? Colors.white
                                            : Colors.black87,
                                  ),
                                ),
                                selected: selectedDays.contains(day),
                                selectedColor: const Color.fromRGBO(
                                  123,
                                  144,
                                  255,
                                  1,
                                ),
                                backgroundColor: Colors.white10,
                                onSelected: (isSelected) {
                                  setState(() {
                                    if (isSelected) {
                                      selectedDays.add(day);
                                    } else {
                                      selectedDays.remove(day);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Select Time:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedTime != null
                                  ? selectedTime!.format(context)
                                  : "No time selected",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color.fromRGBO(
                                          72,
                                          85,
                                          204,
                                          1,
                                        ), // Header background color
                                        onPrimary:
                                            Colors.white, // Header text color
                                        onSurface:
                                            Colors.black, // Body text color
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Color.fromRGBO(
                                            72,
                                            85,
                                            204,
                                            1,
                                          ), // Button text color
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (time != null) {
                                setState(() {
                                  selectedTime = time;
                                });
                              }
                            },
                            child: const Text(
                              "Select Time",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Enter Dosage:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Dosage",
                          labelStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        onChanged: (value) {
                          dosage = double.tryParse(value);
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color.fromRGBO(
                                72,
                                85,
                                204,
                                1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              if (selectedDays.isNotEmpty &&
                                  selectedTime != null &&
                                  dosage != null) {
                                setState(() {
                                  for (var day in selectedDays) {
                                    // Find the plan for the selected day
                                    final plan = widget.medicine?.plans
                                        .firstWhere(
                                          (p) => p.weekDay == day,
                                          orElse:
                                              () =>
                                                  throw Exception(
                                                    "Plan for $day not found",
                                                  ),
                                        );

                                    // Add the dosage to the existing plan
                                    plan?.dosages.add(
                                      Dosage(
                                        id: UniqueKey().toString(),
                                        time: selectedTime!,
                                        dosage: dosage!,
                                      ),
                                    );
                                  }
                                });

                                // Trigger a rebuild of the main UI
                                this.setState(() {});

                                Navigator.pop(context);
                              }
                            },
                            child: const Text("Add"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  DateTime? _parseDate(String dateString) {
    try {
      final parts = dateString.split('-');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      print("Error parsing date: $e");
    }
    return null;
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
                    Color.fromRGBO(
                      72,
                      85,
                      204,
                      0.9,
                    ), // Start color (darker blue)
                    Color.fromRGBO(
                      123,
                      144,
                      255,
                      0.9,
                    ), // End color (lighter blue)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Loading Indicator
          if (isSaving)
            const Center(child: CircularProgressIndicator(color: Colors.white)),

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
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: SingleChildScrollView(
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
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            decoration: const InputDecoration(
                              hintText: "Enter Medicine Description",
                              hintStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Plans Section
                          if (widget.medicine?.plans != null &&
                              widget.medicine!.plans.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Weekly Plan",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    if (editMode)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        ),
                                        onPressed: _showAddPlanDialog,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ...widget.medicine!.plans
                                    .where(
                                      (plan) => plan.dosages.isNotEmpty,
                                    ) // Filter out days without dosages
                                    .map((plan) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${plan.weekDay.name[0].toUpperCase()}${plan.weekDay.name.substring(1).toLowerCase()}", // Capitalize only the first letter
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Stack(
                                            children: [
                                              // Medicine row with horizontal scrolling
                                              Scrollbar(
                                                controller:
                                                    ScrollController(), // Add a controller for the scrollbar
                                                thumbVisibility:
                                                    true, // Ensure the scrollbar is visible
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    children:
                                                        plan.dosages.map((
                                                          dosage,
                                                        ) {
                                                          return Container(
                                                            margin:
                                                                const EdgeInsets.only(
                                                                  right: 10,
                                                                ),
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  8.0,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: const Color.fromRGBO(
                                                                255,
                                                                255,
                                                                255,
                                                                0.1,
                                                              ), // Slightly brighter background
                                                              border: Border.all(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ), // Brighter border
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Text(
                                                                  dosage.time
                                                                      .format(
                                                                        context,
                                                                      ),
                                                                  style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold, // Make the text bold
                                                                    color:
                                                                        Colors
                                                                            .white, // Bright white for better contrast
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Text(
                                                                  "${dosage.dosage}",
                                                                  style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold, // Make the text bold
                                                                    color:
                                                                        Colors
                                                                            .white, // Bright white for better contrast
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }).toList(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      );
                                    })
                                    .toList(),
                              ],
                            )
                          else
                            const Text(
                              "No plans available.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          const SizedBox(height: 20),

                          // Start Date
                          InkWell(
                            onTap:
                                editMode
                                    ? () async {
                                      final selectedDate = await showDatePicker(
                                        context: context,
                                        initialDate:
                                            _parseDate(
                                              startDateController.text,
                                            ) ??
                                            DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: const ColorScheme.light(
                                                primary: Color.fromRGBO(
                                                  72,
                                                  85,
                                                  204,
                                                  1,
                                                ), // Header background color
                                                onPrimary:
                                                    Colors
                                                        .white, // Header text color
                                                onSurface:
                                                    Colors
                                                        .black, // Body text color
                                              ),
                                              textButtonTheme:
                                                  TextButtonThemeData(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Color.fromRGBO(
                                                            72,
                                                            85,
                                                            204,
                                                            1,
                                                          ), // Button text color
                                                    ),
                                                  ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (selectedDate != null) {
                                        setState(() {
                                          startDateController.text =
                                              "${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}";
                                        });
                                      }
                                    }
                                    : null,
                            child: IgnorePointer(
                              child: TextField(
                                controller: startDateController,
                                enabled: false,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  labelText: "Start Date",
                                  labelStyle: TextStyle(color: Colors.white70),
                                  border: UnderlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // End Date
                          InkWell(
                            onTap:
                                editMode
                                    ? () async {
                                      final selectedDate = await showDatePicker(
                                        context: context,
                                        initialDate:
                                            _parseDate(
                                              endDateController.text,
                                            ) ??
                                            DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: const ColorScheme.light(
                                                primary: Color.fromRGBO(
                                                  72,
                                                  85,
                                                  204,
                                                  1,
                                                ), // Header background color
                                                onPrimary:
                                                    Colors
                                                        .white, // Header text color
                                                onSurface:
                                                    Colors
                                                        .black, // Body text color
                                              ),
                                              textButtonTheme:
                                                  TextButtonThemeData(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Color.fromRGBO(
                                                            72,
                                                            85,
                                                            204,
                                                            1,
                                                          ), // Button text color
                                                    ),
                                                  ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (selectedDate != null) {
                                        setState(() {
                                          endDateController.text =
                                              "${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}";
                                        });
                                      }
                                    }
                                    : null,
                            child: IgnorePointer(
                              child: TextField(
                                controller: endDateController,
                                enabled: false,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  labelText: "End Date",
                                  labelStyle: TextStyle(color: Colors.white70),
                                  border: UnderlineInputBorder(),
                                ),
                              ),
                            ),
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
                          const SizedBox(
                            height: 10,
                          ), // Add spacing between switches
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Archived",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              Switch(
                                value: isArchived,
                                onChanged:
                                    widget.medicine != null && editMode
                                        ? (value) {
                                          setState(() {
                                            isArchived = value;
                                          });
                                        }
                                        : null, // Disable toggle when creating a new medicine
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cancel Icon (only show in editing mode and when editing an existing medicine)
          if (editMode && widget.medicine != null)
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
                  child: const Icon(Icons.cancel, color: Colors.red, size: 28),
                ),
              ),
            ),

          // Edit/Save Icons
          Positioned(
            top: 58,
            right: 30,
            child: GestureDetector(
              onTap: editMode ? saveMedicine : toggleEditMode,
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
  */
}
