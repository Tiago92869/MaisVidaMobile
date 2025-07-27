import 'package:flutter/material.dart';
import 'package:mentara/services/diary/diary_model.dart';
import 'package:mentara/services/diary/diary_service.dart';

class DiaryDetailPage extends StatefulWidget {
  final Diary? diary;
  final bool createDiary;

  const DiaryDetailPage({Key? key, this.diary, this.createDiary = false})
    : super(key: key);

  @override
  _DiaryDetailPageState createState() => _DiaryDetailPageState();
}

class _DiaryDetailPageState extends State<DiaryDetailPage> {
  bool editMode = false;
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late DateTime recordedAt;
  DiaryType? selectedEmotion;
  final DiaryService _diaryService = DiaryService();

  bool _showFirstStarfish = true;

  @override
  void initState() {
    super.initState();
    editMode = widget.createDiary;
    titleController = TextEditingController(text: widget.diary?.title ?? "");
    descriptionController = TextEditingController(
      text: widget.diary?.description ?? "",
    );
    recordedAt = widget.diary?.recordedAt ?? DateTime.now();
    selectedEmotion = widget.diary?.emotion;
    _showFirstStarfish = DateTime.now().millisecondsSinceEpoch % 2 == 0;
  }

  Future<void> saveDiary() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedEmotion == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF0D1B2A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Campos em falta",
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

    final diary = Diary(
      id: widget.diary?.id ?? UniqueKey().toString(),
      title: titleController.text,
      description: descriptionController.text,
      recordedAt: recordedAt,
      emotion: selectedEmotion!,
      createdAt: widget.diary?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      if (widget.createDiary) {
        await _diaryService.createDiary(diary);
        Navigator.pop(context);
        Navigator.pop(context, true);
      } else {
        await _diaryService.updateDiary(widget.diary!.id, diary);
        Navigator.pop(context);
        Navigator.pop(context, true);
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Falha ao guardar o diário. Tente novamente."),
          backgroundColor: Colors.red,
        ),
      );
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      await _diaryService.deleteDiary(widget.diary!.id);
      Navigator.pop(context);
      Navigator.pop(context, true);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Falha ao eliminar o diário. Tente novamente."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void toggleEditMode() {
    setState(() {
      editMode = !editMode;
    });
  }

  String _emotionDisplayPt(DiaryType emotion) {
    switch (emotion) {
      case DiaryType.Love:
        return "Amor";
      case DiaryType.Fantastic:
        return "Fantástico";
      case DiaryType.Happy:
        return "Feliz";
      case DiaryType.Neutral:
        return "Neutro";
      case DiaryType.Disappointed:
        return "Desapontado";
      case DiaryType.Sad:
        return "Triste";
      case DiaryType.Angry:
        return "Zangado";
      case DiaryType.Sick:
        return "Doente";
    }
  }

  String _getEmotionEmoji(DiaryType emotion) {
    switch (emotion) {
      case DiaryType.Love:
        return "❤️";
      case DiaryType.Fantastic:
        return "🤩";
      case DiaryType.Happy:
        return "😊";
      case DiaryType.Neutral:
        return "😐";
      case DiaryType.Disappointed:
        return "😞";
      case DiaryType.Sad:
        return "😢";
      case DiaryType.Angry:
        return "😡";
      case DiaryType.Sick:
        return "🤒";
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
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
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
                            hintText: "Introduza o título do diário",
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (editMode)
                          DropdownButton<DiaryType>(
                            value: selectedEmotion,
                            dropdownColor: const Color(0xFF0D1B2A),
                            items: DiaryType.values.map((emotion) {
                              return DropdownMenuItem(
                                value: emotion,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        _getEmotionEmoji(emotion),
                                        style: const TextStyle(fontSize: 22),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _emotionDisplayPt(emotion),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 0,
                              maxWidth: double.infinity,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getEmotionEmoji(selectedEmotion!),
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _emotionDisplayPt(selectedEmotion!),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),
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
                              onTap: editMode
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
                                              ),
                                              hintColor: const Color(
                                                0xFF0D1B2A,
                                              ),
                                              colorScheme: const ColorScheme.light(
                                                primary: Color(
                                                  0xFF0D1B2A,
                                                ),
                                                onPrimary: Colors.white,
                                                onSurface: Colors.black,
                                              ),
                                              dialogBackgroundColor: Colors.white,
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
              ),
            ),
          ),
          Positioned(
            top: 58,
            right: 30,
            child: GestureDetector(
              onTap: () {
                if (widget.createDiary || editMode) {
                  saveDiary();
                } else {
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
          if (!widget.createDiary)
            Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTap: () async {
                  final shouldDelete = await _showDeleteConfirmationDialog();
                  if (shouldDelete) {
                    await _deleteDiary();
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
