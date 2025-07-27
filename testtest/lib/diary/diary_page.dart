import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mentara/services/diary/diary_service.dart';
import 'package:mentara/services/diary/diary_model.dart';
import 'diary_detail_page.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({Key? key}) : super(key: key);

  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final DiaryService _diaryService = DiaryService();
  bool _isLoading = false;
  bool _hasError = false;
  bool _hasMoreData = true;
  int _currentPage = 0;

  DateTime _selectedDate = DateTime.now();

  final Set<DiaryType> _selectedEmotions = {};
  bool _isFilterPanelVisible = false;

  List<Diary> _diaryEntries = [];

  @override
  void initState() {
    super.initState();
    _fetchDiariesForSelectedDate();
  }

  void _toggleFilterPanel() {
    setState(() {
      _isFilterPanelVisible = !_isFilterPanelVisible;
    });
  }

  void _toggleEmotion(DiaryType emotion) {
    setState(() {
      if (_selectedEmotions.contains(emotion)) {
        _selectedEmotions.remove(emotion);
      } else {
        _selectedEmotions.add(emotion);
      }
    });
    _fetchDiariesForSelectedDate();
  }

  List<Diary> _getEntriesForSelectedDate() {
    return _diaryEntries
        .where(
          (entry) =>
              entry.recordedAt.toLocal().year == _selectedDate.toLocal().year &&
              entry.recordedAt.toLocal().month == _selectedDate.toLocal().month &&
              entry.recordedAt.toLocal().day == _selectedDate.toLocal().day &&
              (_selectedEmotions.isEmpty ||
                  _selectedEmotions.contains(entry.emotion)),
        )
        .toList();
  }

  Future<void> _fetchDiariesForSelectedDate({bool isScrolling = false}) async {
    if (isScrolling && !_hasMoreData) {
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      if (!isScrolling) {
        _diaryEntries = [];
        _currentPage = 0;
        _hasMoreData = true;
      }
    });

    try {
      final diaries = await _diaryService.fetchDiaries(
        _selectedEmotions.toList(),
        _selectedDate,
        _selectedDate,
        page: _currentPage,
        size: 10,
      );

      setState(() {
        final hasAnyDiary = diaries.any((d) => d.diaries.isNotEmpty);
        if (hasAnyDiary) {
          for (var diaryDay in diaries) {
            _diaryEntries.addAll(diaryDay.diaries);
          }
          _currentPage++;
        } else {
          _hasMoreData = false;
        }
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Falha ao procurar os diários. Tente novamente."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
    _fetchDiariesForSelectedDate();
  }

  void _goToNextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
    _fetchDiariesForSelectedDate();
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      _fetchDiariesForSelectedDate();
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
    _getEntriesForSelectedDate();

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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Diário",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: _goToPreviousDay,
                      ),
                      GestureDetector(
                        onTap: _selectDate,
                        child: Text(
                          "${_selectedDate.toLocal().month}/${_selectedDate.toLocal().day}/${_selectedDate.toLocal().year}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                        onPressed: _goToNextDay,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!_isLoading &&
                            _hasMoreData &&
                            scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                          _fetchDiariesForSelectedDate(isScrolling: true);
                        }
                        return false;
                      },
                      child: RefreshIndicator(
                        onRefresh: () => _fetchDiariesForSelectedDate(isScrolling: false),
                        child: _hasError
                            ? const Center(
                                child: Text(
                                  "Falha ao carregar os diários. Tente novamente.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                              )
                            : _diaryEntries.isEmpty
                                ? const Center(
                                    child: Text(
                                      "Não há diários para este dia.",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.only(bottom: 60),
                                    itemCount: _diaryEntries.length,
                                    itemBuilder: (context, index) {
                                      final entry = _diaryEntries[index];
                                      return GestureDetector(
                                        onTap: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => DiaryDetailPage(
                                                diary: entry,
                                                createDiary: false,
                                              ),
                                            ),
                                          );
                                          if (result == true) {
                                            _fetchDiariesForSelectedDate(isScrolling: false);
                                          }
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(vertical: 8),
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(255, 33, 70, 119).withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color.fromARGB(255, 33, 70, 119).withOpacity(0.3),
                                                blurRadius: 5,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                entry.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                entry.description,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      _getEmotionEmoji(entry.emotion),
                                                      style: const TextStyle(fontSize: 18),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      () {
                                                        switch (entry.emotion) {
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
                                                      }(),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isFilterPanelVisible)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _toggleFilterPanel,
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 5.0,
                    sigmaY: 5.0,
                  ),
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),
              ),
            ),
          if (_isFilterPanelVisible)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              right: _isFilterPanelVisible ? 0 : -230,
              top: 0,
              bottom: 0,
              child: Container(
                width: 230,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(-5, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 15),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _toggleFilterPanel,
                            child: const Icon(
                              Icons.arrow_forward,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 30),
                          const Text(
                            "Emoções",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: DiaryType.values.map((emotion) {
                              final isSelected = _selectedEmotions.contains(emotion);
                              String emotionDisplay;
                              switch (emotion) {
                                case DiaryType.Love:
                                  emotionDisplay = "Amor";
                                  break;
                                case DiaryType.Fantastic:
                                  emotionDisplay = "Fantástico";
                                  break;
                                case DiaryType.Happy:
                                  emotionDisplay = "Feliz";
                                  break;
                                case DiaryType.Neutral:
                                  emotionDisplay = "Neutro";
                                  break;
                                case DiaryType.Disappointed:
                                  emotionDisplay = "Desapontado";
                                  break;
                                case DiaryType.Sad:
                                  emotionDisplay = "Triste";
                                  break;
                                case DiaryType.Angry:
                                  emotionDisplay = "Zangado";
                                  break;
                                case DiaryType.Sick:
                                  emotionDisplay = "Doente";
                                  break;
                              }
                              return GestureDetector(
                                onTap: () {
                                  _toggleEmotion(emotion);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.transparent,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color: isSelected
                                        ? const Color(0xFF0D1B2A)
                                        : Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 15,
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _getEmotionEmoji(emotion),
                                          style: const TextStyle(fontSize: 22),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          emotionDisplay,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : const Color(0xFF0D1B2A),
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          if (!_isFilterPanelVisible)
            Positioned(
              top: 58,
              right: 20,
              child: GestureDetector(
                onTap: _toggleFilterPanel,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Stack(
                    children: [
                      Container(
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
                          Icons.filter_alt,
                          color: Color(0xFF0D1B2A),
                          size: 28,
                        ),
                      ),
                      if (_selectedEmotions.isNotEmpty)
                        Positioned(
                          top: 3,
                          right: 4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF0D1B2A),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 100,
            right: _isFilterPanelVisible ? -80 : 20,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isFilterPanelVisible ? 0.0 : 1.0,
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiaryDetailPage(
                        diary: null,
                        createDiary: true,
                      ),
                    ),
                  );
                  if (result == true) {
                    _fetchDiariesForSelectedDate(isScrolling: false);
                  }
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.add, color: Color(0xFF0D1B2A)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

