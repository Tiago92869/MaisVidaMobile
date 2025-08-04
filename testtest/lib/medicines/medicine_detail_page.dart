import 'dart:math'; // Import for Random
import 'package:flutter/material.dart';
import 'package:mentara/services/medicine/medicine_model.dart'; // Import the models
import 'package:mentara/services/medicine/medicine_service.dart'; // Import the service

class MedicineDetailPage extends StatefulWidget {
  final Medicine? medicine; // Use the Medicine model
  final bool isEditing; // Indicates if the page is in editing mode

  const MedicineDetailPage({Key? key, this.medicine, this.isEditing = false})
    : super(key: key);

  @override
  _MedicineDetailPageState createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends State<MedicineDetailPage> {
  final MedicineService _medicineService =
      MedicineService(); // Service instance
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
            primaryColor: const Color(0xFF0D1B2A), // Header background color
            hintColor: const Color(0xFF0D1B2A), // Selected date color
            colorScheme: const ColorScheme.light(
              primary: const Color(0xFF0D1B2A), // Header text color
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
          "A data final só pode ser igual ou superior à data inicial",
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
        await _medicineService.createMedicine(newMedicine);
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
        await _medicineService.modifyMedicine(
          updatedMedicine.id,
          updatedMedicine,
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      _showErrorSnackBar("Falha ao guardar o medicamento. Tente novamente.");
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
      await _medicineService.deleteMedicine(widget.medicine!.id);

      // Navigate back and pass a flag to indicate deletion
      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Falha ao eliminar o medicamento. Tente novamente."),
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
              backgroundColor: const Color(0xFF0D1B2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Eliminar medicamento",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                "Tem a certeza que pretende eliminar este medicamento? Esta ação não pode ser anulada.",
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

  void _showMissingFieldsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D1B2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Campos ausentes",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Preencha todos os campos antes de guardar.",
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Plano semanal",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                        color: Colors.white70, // Use white70 for subtitle
              ),
            ),
            if (editMode) // Show "+" button only in edit mode
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () => _showAddDosageDialog(),
              ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        // Translate English weekday to Portuguese for display
                        {
                          "MONDAY": "SEGUNDA",
                          "TUESDAY": "TERÇA",
                          "WEDNESDAY": "QUARTA",
                          "THURSDAY": "QUINTA",
                          "FRIDAY": "SEXTA",
                          "SATURDAY": "SÁBADO",
                          "SUNDAY": "DOMINGO",
                        }[plan.weekDay] ?? plan.weekDay,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        plan.dosages.isEmpty
                            ? "Zero dosagens"
                            : "${plan.dosages.length} dosage${plan.dosages.length > 1 ? 'ns' : 'm'}",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color.fromARGB(220, 255, 255, 255),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  if (plan.dosages.isNotEmpty)
                    Column(
                      children:
                          plan.dosages.map((dosage) {
                            return GestureDetector(
                              onTap:
                                  editMode
                                      ? () =>
                                          _showEditDosageDialog(plan, dosage)
                                      : null, // Only allow tapping in edit mode
                              child: Container(
                                margin: const EdgeInsets.only(top: 5),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Display time and dosage text
                                    Text(
                                      "${dosage.time} | ${dosage.dosage.toStringAsFixed(2)} quant",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Color.fromARGB(
                                          195,
                                          255,
                                          255,
                                          255,
                                        ),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 48,
                                    ), // Add spacing here
                                    // Horizontally scrollable dosage images with shadow indicators
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: _getDosageImages(
                                                dosage.dosage,
                                              ),
                                            ),
                                          ),
                                          // Left shadow
                                          Positioned(
                                            left: 0,
                                            child: IgnorePointer(
                                              child: Container(
                                                width: 30,
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.black26,
                                                      Colors.transparent,
                                                    ],
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Right shadow
                                          Positioned(
                                            right: 0,
                                            child: IgnorePointer(
                                              child: Container(
                                                width: 30,
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.transparent,
                                                      Colors.black26,
                                                    ],
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
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
                  colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
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
              opacity: 0.05,
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
              opacity: 0.05,
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

                    // Name (title)
                    TextField(
                      controller: nameController,
                      enabled: editMode,
                      maxLines: null, // Allow unlimited lines for title
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        hintText: "Introduza o nome do medicamento",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 18), // More vertical space
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Start Date
                    const Text(
                      "Data de inicio",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70, // Use white70 for subtitle
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
                              : "Seleciona uma data de inicio",
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
                      "Data de fim",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70, // Use white70 for subtitle
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
                              : "Seleciona uma data de fim",
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
                          "Notificações ativadas",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70, // Use white70 for subtitle
                          ),
                        ),
                        Checkbox(
                          value: hasNotifications,
                          onChanged: editMode
                              ? (value) {
                                  setState(() {
                                    hasNotifications = value ?? false;
                                  });
                                }
                              : null,
                          activeColor: Colors.green,
                          checkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
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
                            "Arquivado",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70, // Use white70 for subtitle
                            ),
                          ),
                          Checkbox(
                            value: isArchived,
                            onChanged: editMode
                                ? (value) {
                                    setState(() {
                                      isArchived = value ?? false;
                                    });
                                  }
                                : null,
                            activeColor: Colors.green,
                            checkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 20),

                    // Description (moved here)
                    const SizedBox(height: 5),
                    TextField(
                      controller: descriptionController,
                      enabled: editMode,
                      maxLines: null,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Introduza a descrição do medicamento",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
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
                  color: const Color(0xFF0D1B2A),
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

  void _showAddDosageDialog() {
    final List<String> selectedWeekdays = [];
    TimeOfDay? selectedTime;
    double selectedDosage = 0.25;

    // Dias da semana em português, mas mantendo os valores lógicos em inglês
    final Map<String, String> weekDayLabels = {
      "MONDAY": "Segunda",
      "TUESDAY": "Terça",
      "WEDNESDAY": "Quarta",
      "THURSDAY": "Quinta",
      "FRIDAY": "Sexta",
      "SATURDAY": "Sábado",
      "SUNDAY": "Domingo",
    };

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0D1B2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Adicionar Dosagem",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Weekday Title
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Dia da Semana:",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Weekday Selection
                  Wrap(
                    spacing: 10,
                    children: [
                      for (var day in [
                        "MONDAY",
                        "TUESDAY",
                        "WEDNESDAY",
                        "THURSDAY",
                        "FRIDAY",
                        "SATURDAY",
                        "SUNDAY",
                      ])
                        FilterChip(
                          label: Text(
                            weekDayLabels[day]!,
                            style: TextStyle(
                              color:
                                  selectedWeekdays.contains(day)
                                      ? Colors.white
                                      : const Color(0xFF0D1B2A),
                            ),
                          ),
                          selected: selectedWeekdays.contains(day),
                          onSelected: (isSelected) {
                            setState(() {
                              if (isSelected) {
                                selectedWeekdays.add(day);
                              } else {
                                selectedWeekdays.remove(day);
                              }
                            });
                          },
                          selectedColor: const Color(0xFF0D1B2A),
                          backgroundColor:
                              selectedWeekdays.contains(day)
                                  ? const Color(0xFF0D1B2A)
                                  : Colors.white,
                          side: BorderSide(
                            color:
                                selectedWeekdays.contains(day)
                                    ? Colors.white
                                    : Colors.transparent,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Time Row
                  Row(
                    children: [
                      const Text(
                        "Horário:",
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    primaryColor: const Color(0xFF0D1B2A),
                                    hintColor: const Color(0xFF0D1B2A),
                                    colorScheme: const ColorScheme.light(
                                      primary: Color(0xFF0D1B2A),
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                                    dialogBackgroundColor: Colors.white,
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
                              selectedTime != null
                                  ? selectedTime!.format(context)
                                  : "Selecionar Horário",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Dosage Row
                  Row(
                    children: [
                      const Text(
                        "Dosagem:",
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<double>(
                          value: selectedDosage,
                          dropdownColor: const Color(0xFF0D1B2A),
                          items:
                              List.generate(
                                40,
                                (index) => (index + 1) * 0.25,
                              ).map((value) {
                                return DropdownMenuItem<double>(
                                  value: value,
                                  child: Text(
                                    value.toStringAsFixed(2),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedDosage = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedWeekdays.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Selecione pelo menos um dia da semana."),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Selecione um horário."),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (selectedDosage <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Selecione uma dosagem válida."),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    _addDosageToPlans(
                      selectedWeekdays,
                      selectedTime!,
                      selectedDosage,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Confirmar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addDosageToPlans(List<String> weekdays, TimeOfDay time, double dosage) {
    setState(() {
      for (var day in weekdays) {
        final plan = widget.medicine!.plans.firstWhere(
          (plan) => plan.weekDay == day,
          orElse: () => Plan(id: "", weekDay: day, dosages: []),
        );
        plan.dosages.add(
          Dosage(
            id: "",
            time:
                "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
            dosage: dosage,
          ),
        );
      }
    });
  }

  void _showEditDosageDialog(Plan plan, Dosage dosage) {
    TimeOfDay selectedTime = TimeOfDay(
      hour: int.parse(dosage.time.split(":")[0]),
      minute: int.parse(dosage.time.split(":")[1]),
    );
    double selectedDosage = dosage.dosage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0D1B2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Editar dosagem",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Time Picker
                  Row(
                    children: [
                      const Text(
                        "Horário:",
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (time != null) {
                              setState(() {
                                selectedTime = time;
                              });
                            }
                          },
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
                              selectedTime.format(context),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Dosage Quantity
                  Row(
                    children: [
                      const Text(
                        "Dosagem:",
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<double>(
                          value: selectedDosage,
                          dropdownColor: const Color(0xFF0D1B2A),
                          items:
                              List.generate(
                                40,
                                (index) => (index + 1) * 0.25,
                              ).map((value) {
                                return DropdownMenuItem<double>(
                                  value: value,
                                  child: Text(
                                    value.toStringAsFixed(2),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedDosage = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                // Delete Button
                TextButton(
                  onPressed: () {
                    setState(() {
                      plan.dosages.remove(dosage); // Remove dosage locally
                    });
                    Navigator.pop(context); // Close the dialog
                    this.setState(() {}); // Update the parent widget's state
                  },
                  child: const Text(
                    "Eliminar",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                // Save Button
                TextButton(
                  onPressed: () {
                    setState(() {
                      dosage.time =
                          "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";
                      dosage.dosage = selectedDosage;
                    });
                    Navigator.pop(context);
                    this.setState(() {}); // Update the parent widget's state
                  },
                  child: const Text(
                    "Guardar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Widget> _getDosageImages(double dosage) {
    List<Widget> images = [];

    // Calculate the number of full units (drug1)
    int fullUnits = dosage.floor();
    for (int i = 0; i < fullUnits; i++) {
      images.add(
        Image.asset(
          'assets/medicine/drug1.png',
          height: 24, // Adjust height to fit the row
          width: 24, // Adjust width to fit the row
          fit: BoxFit.contain,
        ),
      );
    }

    // Calculate the remaining fractional part
    double fractionalPart = dosage - fullUnits;
    if (fractionalPart > 0) {
      String fractionalImage = _getFractionalImage(fractionalPart);
      images.add(
        Image.asset(
          fractionalImage,
          height: 24, // Adjust height to fit the row
          width: 24, // Adjust width to fit the row
          fit: BoxFit.contain,
        ),
      );
    }

    return images;
  }

  String _getFractionalImage(double fractionalPart) {
    if (fractionalPart == 0.25) {
      return 'assets/medicine/drug25.png';
    } else if (fractionalPart == 0.5) {
      return 'assets/medicine/drug50.png';
    } else if (fractionalPart == 0.75) {
      return 'assets/medicine/drug75.png';
    } else {
      return 'assets/medicine/drug1.png'; // Default to full unit if unexpected value
    }
  }
}
