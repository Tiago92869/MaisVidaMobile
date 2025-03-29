import 'package:flutter/material.dart';
import 'medicines_page.dart';

class MedicineDetailPage extends StatefulWidget {
  final MedicineDTO? medicine; // Pass a medicine if editing or visualizing, null if creating
  final bool isEditing; // Indicates if the page is in editing mode

  const MedicineDetailPage({Key? key, this.medicine, this.isEditing = false}) : super(key: key);

  @override
  _MedicineDetailPageState createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends State<MedicineDetailPage> {
  bool editMode = false; // Tracks if the user is editing
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController startDateController;
  late TextEditingController endDateController;
  bool hasNotifications = false; // Local variable for notifications toggle

  @override
  void initState() {
    super.initState();
    editMode = widget.isEditing;
    nameController = TextEditingController(text: widget.medicine?.name ?? "");
    descriptionController = TextEditingController(text: widget.medicine?.description ?? "");
    startDateController = TextEditingController(
      text: widget.medicine?.startedAt != null
          ? "${widget.medicine!.startedAt.day.toString().padLeft(2, '0')}-${widget.medicine!.startedAt.month.toString().padLeft(2, '0')}-${widget.medicine!.startedAt.year}"
          : "",
    );
    endDateController = TextEditingController(
      text: widget.medicine?.endedAt != null
          ? "${widget.medicine!.endedAt.day.toString().padLeft(2, '0')}-${widget.medicine!.endedAt.month.toString().padLeft(2, '0')}-${widget.medicine!.endedAt.year}"
          : "",
    );
    hasNotifications = widget.medicine?.hasNotifications ?? false; // Initialize from medicine or default to false
  }

  void saveMedicine() {
    // Save the medicine (in a real app, you'd save it to a database or API)
    print("Medicine saved: ${nameController.text}, ${descriptionController.text}, Notifications: $hasNotifications");

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
      nameController.text = widget.medicine?.name ?? "";
      descriptionController.text = widget.medicine?.description ?? "";
      startDateController.text = widget.medicine?.startedAt != null
          ? "${widget.medicine!.startedAt.day.toString().padLeft(2, '0')}-${widget.medicine!.startedAt.month.toString().padLeft(2, '0')}-${widget.medicine!.startedAt.year}"
          : "";
      endDateController.text = widget.medicine?.endedAt != null
          ? "${widget.medicine!.endedAt.day.toString().padLeft(2, '0')}-${widget.medicine!.endedAt.month.toString().padLeft(2, '0')}-${widget.medicine!.endedAt.year}"
          : "";
      hasNotifications = widget.medicine?.hasNotifications ?? false;
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
                    if (widget.medicine?.plans != null && widget.medicine!.plans.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Weekly Plan",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...WeekDay.values.map((weekDay) {
                            final plan = widget.medicine!.plans.firstWhere(
                              (p) => p.weekDay == weekDay,
                              orElse: () => PlanDTO(id: "", weekDay: weekDay, dosages: []),
                            );
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${weekDay.name[0].toUpperCase()}${weekDay.name.substring(1).toLowerCase()}", // Capitalize only the first letter
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                if (plan.dosages.isNotEmpty)
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: plan.dosages.map((dosage) {
                                        return Container(
                                          margin: const EdgeInsets.only(right: 10),
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color: const Color.fromRGBO(255, 255, 255, 0.1), // Slightly brighter background
                                            border: Border.all(color: Colors.white), // Brighter border
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                dosage.time.format(context),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold, // Make the text bold
                                                  color: Colors.white, // Bright white for better contrast
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                "${dosage.dosage}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold, // Make the text bold
                                                  color: Colors.white, // Bright white for better contrast
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  )
                                else
                                  const Padding(
                                    padding: EdgeInsets.only(left: 16.0),
                                    child: Text(
                                      "No dosage scheduled.",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 10),
                              ],
                            );
                          }).toList(),
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
                    TextField(
                      controller: startDateController,
                      enabled: editMode,
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
                    const SizedBox(height: 10),

                    // End Date
                    TextField(
                      controller: endDateController,
                      enabled: editMode,
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
                  ],
                ),
              ),
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
}