import 'package:flutter/material.dart';
import 'package:maisvida/services/goal/goal_service.dart';
import 'package:maisvida/services/goal/goal_model.dart';

class GoalDetailPage extends StatefulWidget {
  final GoalInfoCard? goal;
  final bool createResource;
  final VoidCallback? onSave;

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
  DateTime? selectedDate;
  GoalSubject? selectedSubject;
  bool hasNotifications = false;
  bool completed = false;
  late bool editMode;
  bool _isLoading = false;
  final bool _showFirstStarfish = true;

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
    editMode = widget.createResource;
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveGoal() async {
    final updatedGoal = GoalInfoCard(
      id: widget.goal?.id ?? "",
      title: titleController.text,
      description: descriptionController.text,
      goalDate: selectedDate ?? DateTime.now(),
      completedDate: completed ? DateTime.now() : null,
      completed: completed,
      hasNotifications: hasNotifications,
      subject: selectedSubject ?? GoalSubject.Personal,
      createdAt: widget.goal?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.createResource) {
        await _goalService.createGoal(updatedGoal);
      } else {
        await _goalService.updateGoal(updatedGoal.id, updatedGoal);
      }
      if (widget.onSave != null) {
        widget.onSave!();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Falha ao salvar o meta. Tente novamente."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteGoal() async {
    if (widget.goal == null || widget.goal!.id.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _goalService.deleteGoal(widget.goal!.id);
      if (widget.onSave != null) {
        widget.onSave!();
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Falha ao eliminar a meta. Tente novamente."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
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
        false;
  }

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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        40,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (editMode) {
                                  if (widget.createResource &&
                                      (titleController.text.isEmpty ||
                                          descriptionController.text.isEmpty ||
                                          selectedDate == null ||
                                          selectedSubject == null)) {
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
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          content: const Text(
                                            "Por favor preencha todos os campos antes de guardar.",
                                            style: TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
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
                                    return;
                                  }
                                  if (_isLoading) return;
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  try {
                                    await _saveGoal();
                                    if (widget.onSave != null) {
                                      widget.onSave!();
                                    }
                                    Navigator.pop(context, true);
                                  } finally {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                } else {
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
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: titleController,
                          enabled: editMode,
                          maxLines: null,
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
                        if (editMode)
                          DropdownButton<GoalSubject>(
                            value: selectedSubject,
                            dropdownColor: const Color(0xFF0D1B2A),
                            items: GoalSubject.values.map((subject) {
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Notificações ativadas",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
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
                        const SizedBox(height: 20),
                        Expanded(
                          child: TextField(
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (!widget.createResource)
            Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTap: () async {
                  final shouldDelete = await _showDeleteConfirmationDialog();
                  if (shouldDelete) {
                    await _deleteGoal();
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
