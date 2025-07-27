import 'package:flutter/material.dart';
import 'package:mentara/activities/activity_details_page.dart';
import 'package:mentara/diary/diary_detail_page.dart';
import 'package:mentara/goals/goal_details_page.dart';
import 'package:mentara/medicines/medicine_detail_page.dart';
import 'package:mentara/resources/resource_detail_page.dart';
import 'package:mentara/services/activity/activity_service.dart';
import 'package:mentara/services/resource/resource_service.dart';
import 'package:mentara/services/medicine/medicine_service.dart';
import 'package:mentara/services/goal/goal_service.dart';
import 'package:mentara/services/diary/diary_service.dart';
import 'package:mentara/services/activity/activity_model.dart';
import 'package:mentara/services/resource/resource_model.dart';
import 'package:mentara/services/medicine/medicine_model.dart';
import 'package:mentara/services/goal/goal_model.dart';
import 'package:mentara/services/diary/diary_model.dart';

class HomeTabView extends StatefulWidget {
  final Function(int tabIndex) onTabChange; // Change callback to use tab index

  const HomeTabView({Key? key, required this.onTabChange}) : super(key: key);

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> {
  final ActivityService _activityService = ActivityService();
  final ResourceService _resourceService = ResourceService();
  final MedicineService _medicineService = MedicineService();
  final GoalService _goalService = GoalService();
  final DiaryService _diaryService = DiaryService();

  List<Activity> _activities = [];
  List<Resource> _resources = [];
  List<Medicine> _medications = [];
  List<GoalInfoCard> _goals = [];
  List<Diary> _diaries = [];

  bool _isLoadingActivities = true;
  bool _isLoadingResources = true;
  bool _isLoadingMedications = true;
  bool _isLoadingGoals = true;
  bool _isLoadingDiaries = true;

  @override
  void initState() {
    super.initState();
    _fetchActivities();
    _fetchResources();
    _fetchMedications();
    _fetchGoals();
    _fetchDiaries();
  }

  Future<void> _fetchActivities() async {
    try {
      final activities = await _activityService.fetchActivities(
        page: 0,
        size: 3,
        searchQuery: "",
      );
      setState(() {
        _activities = activities.content;
      });
    } catch (e) {
      _showErrorSnackBar("Falha ao procurar atividades.");
    } finally {
      setState(() {
        _isLoadingActivities = false;
      });
    }
  }

  Future<void> _fetchResources() async {
    try {
      final resources = await _resourceService.fetchResources(
        [],
        page: 0,
        size: 4,
        search: "",
      );
      setState(() {
        _resources = resources.content;
      });
    } catch (e) {
      _showErrorSnackBar("Failed to fetch resources.");
    } finally {
      setState(() {
        _isLoadingResources = false;
      });
    }
  }

  Future<void> _fetchMedications() async {
    setState(() {
      _isLoadingMedications = true; // Start loading
    });

    try {
      // Fetch medicines using the updated method
      final medicinePage = await _medicineService.fetchMedicines(
        false, // Archived status
        DateTime.now(), // Start date
        DateTime.now(), // End date
        page: 0, // Fetch the first page
        size: 3, // Fetch only 3 medicines
      );

      // Update the state with the fetched medicines
      setState(() {
        _medications =
            medicinePage.content; // Use the content from MedicinePage
      });
    } catch (e) {
      print('Error fetching medications: $e');
      _showErrorSnackBar("Falha ao procurar medicamentos.");
    } finally {
      setState(() {
        _isLoadingMedications = false; // Stop loading
      });
    }
  }

  Future<void> _fetchGoals() async {
    try {
      final pagezGoals = await _goalService.fetchGoals(
        false,
        DateTime.now(),
        DateTime.now(),
        [],
        page: 0,
        size: 3, // Fetch only the first 3 goals
      );
      setState(() {
        _goals = pagezGoals.goals; // Extract goals from the PagezGoalsDTO
      });
    } catch (e) {
      _showErrorSnackBar("Falha ao procurar metas.");
    } finally {
      setState(() {
        _isLoadingGoals = false;
      });
    }
  }

  Future<void> _fetchDiaries() async {
    try {
      final diaries = await _diaryService.fetchDiaries(
        [],
        DateTime.now(),
        DateTime.now(),
      );
      setState(() {
        _diaries = diaries[0].diaries.take(3).toList();
      });
    } catch (e) {
      _showErrorSnackBar("Falha ao procurar diários.");
    } finally {
      setState(() {
        _isLoadingDiaries = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildSection(
    String title,
    List<dynamic> items,
    bool isLoading,
    Widget Function(dynamic) itemBuilder,
    int tabIndex, // Use tab index for navigation
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 34,
                  fontFamily: "Poppins",
                  color: Colors.white, // Set title text color to white
                ),
              ),
              GestureDetector(
                onTap: () {
                  widget.onTabChange(tabIndex); // Pass the tab index
                },
                child: const Text(
                  "Ver mais",
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : items.isEmpty
            ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40), // Add spacing at the top
                  Text(
                    title == "Recursos"
                        ? "Nenhum recurso criado"
                        : "Nenhum dado disponível",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 18, // Increased text size
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ), // Add spacing between the text and the button
                  if (title != "Recursos")
                    ElevatedButton(
                      onPressed: () {
                        widget.onTabChange(tabIndex); // Pass the tab index
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Adicionar $title",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18, // Increased button text size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 40), // Add spacing at the bottom
                ],
              ),
            )
            : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
              child: Column(children: items.map(itemBuilder).toList()),
            ),
        const SizedBox(
          height: 30,
        ), // Increased padding at the end of the section
      ],
    );
  }

  Widget _buildActivitiesSection(
    String title,
    List<Activity> activities,
    bool isLoading,
    int tabIndex, // Use tab index for navigation
  ) {
    final List<Color> activityColors = [
      const Color(0xFF9CC5FF),
      const Color(0xFF6E6AE8),
      const Color(0xFF005FE7),
      const Color(0xFFBBA6FF),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 34,
                  fontFamily: "Poppins",
                  color: Colors.white, // Set title text color to white
                ),
              ),
              GestureDetector(
                onTap: () {
                  widget.onTabChange(tabIndex); // Pass the tab index
                },
                child: const Text(
                  "Ver mais",
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : activities.isEmpty
            ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Text(
                  "Nenhuma atividade disponível",
                  style: const TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ),
            )
            : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
              child: Row(
                children:
                    activities.map((activity) {
                      final backgroundColor =
                          activityColors[activities.indexOf(activity) % activityColors.length];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      ActivityDetailsPage(activity: activity),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            width: 300,
                            height: 300,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: backgroundColor.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: backgroundColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 12),
                                ),
                                BoxShadow(
                                  color: backgroundColor.withOpacity(0.3),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontFamily: "Poppins",
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 30),
                                Text(
                                  activity.description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  "Recursos: ${activity.resources?.length ?? 0}",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontFamily: "Inter",
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => ActivityDetailsPage(
                                                activity: activity,
                                              ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: backgroundColor.withOpacity(0.65),
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      "Iniciar",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Set background to white
      body: Stack(
        children: [
          // Add both images
          Positioned(
            right: 80,
            top: -80,
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
          ),
          Positioned(
            left: 100,
            top: 450,
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

          // Main content of HomeTabView
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 60,
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildActivitiesSection(
                  "Atividades",
                  _activities,
                  _isLoadingActivities,
                  5, // Tab index for "Activities"
                ),
                _buildSection(
                  "Recursos",
                  _resources,
                  _isLoadingResources,
                  (resource) {
                    final backgroundColor = Color(0xFF6E6AE8);
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ResourceDetailPage(resource: resource),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: _buildResourceCard(resource, backgroundColor),
                      ),
                    );
                  },
                  4, // Tab index for "Resources"
                ),
                _buildSection(
                  "Medicamentos",
                  _medications,
                  _isLoadingMedications,
                  (medicine) {
                    // Fundo: const Color(0xFF9CC5FF) com opacidade 0.3
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MedicineDetailPage(
                              medicine: medicine,
                              isEditing: false,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9CC5FF).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9CC5FF).withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Medicine Name
                            Text(
                              medicine.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Medicine Description
                            Text(
                              medicine.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14, color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            // Start and End Dates
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: "Inicio: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      TextSpan(
                                        text: medicine.startedAt.toLocal().toString().split(' ')[0],
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: "Fim: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      TextSpan(
                                        text: medicine.endedAt.toLocal().toString().split(' ')[0],
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  3, // Tab index for "Medication"
                ),
                _buildSection(
                  "Metas",
                  _goals,
                  _isLoadingGoals,
                  (goal) {
                    // Fundo: const Color(0xFF005FE7) com opacidade 0.3
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GoalDetailPage(
                              goal: goal,
                              createResource: false,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF005FE7).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF005FE7).withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal.title,
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
                              goal.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14, color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            // Goal Date
                            Text(
                              "Data: ${goal.goalDate.day.toString().padLeft(2, '0')}-${goal.goalDate.month.toString().padLeft(2, '0')}-${goal.goalDate.year}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Subject and Completed Toggle
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Subject
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
                                    _getSubjectDisplayName(goal.subject),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                // Completed Checkbox (disabled)
                                Row(
                                  children: [
                                    Text(
                                      "Completado",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: goal.completed ? Colors.green[200] : Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Checkbox(
                                      value: goal.completed,
                                      onChanged: null,
                                      activeColor: Colors.green,
                                      checkColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  2, // Tab index for "Goals"
                ),
                _buildSection(
                  "Diário",
                  _diaries,
                  _isLoadingDiaries,
                  (diary) {
                    // Fundo: const Color(0xFFBBA6FF) com opacidade 0.3
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiaryDetailPage(
                              diary: diary,
                              createDiary: false,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFBBA6FF).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFBBA6FF).withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              diary.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8), // Add spacing between title and description
                            // Description
                            Text(
                              diary.description,
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
                                    _getEmotionEmoji(diary.emotion),
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getEmotionDisplayName(diary.emotion),
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
                  1, // Tab index for "Diary"
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Novo método para o modelo visual dos recursos igual ao resources_page.dart
  Widget _buildResourceCard(Resource resource, Color backgroundColor) {
    const int maxDescriptionLength = 90;
    String truncatedDescription = resource.description.length > maxDescriptionLength
        ? '${resource.description.substring(0, maxDescriptionLength)}...'
        : resource.description;

    String emoji;
    switch (resource.type) {
      case ResourceType.ARTICLE:
        emoji = "📖";
        break;
      case ResourceType.VIDEO:
        emoji = "🎬";
        break;
      case ResourceType.PODCAST:
        emoji = "🎧";
        break;
      case ResourceType.PHRASE:
        emoji = "💬";
        break;
      case ResourceType.CARE:
        emoji = "💚";
        break;
      case ResourceType.EXERCISE:
        emoji = "🏋️";
        break;
      case ResourceType.RECIPE:
        emoji = "🍲";
        break;
      case ResourceType.MUSIC:
        emoji = "🎵";
        break;
      case ResourceType.SOS:
        emoji = "🚨";
        break;
      case ResourceType.OTHER:
        emoji = "🗂️";
        break;
      case ResourceType.TIVA:
        emoji = "🧠";
        break;
      default:
        emoji = "❓";
    }

    String _translateResourceType(ResourceType type) {
      switch (type) {
        case ResourceType.ARTICLE:
          return "Artigo";
        case ResourceType.VIDEO:
          return "Vídeo";
        case ResourceType.PODCAST:
          return "Podcast";
        case ResourceType.PHRASE:
          return "Frase";
        case ResourceType.CARE:
          return "Cuidado";
        case ResourceType.EXERCISE:
          return "Exercício";
        case ResourceType.RECIPE:
          return "Receita";
        case ResourceType.MUSIC:
          return "Música";
        case ResourceType.SOS:
          return "SOS";
        case ResourceType.OTHER:
          return "Outro";
        case ResourceType.TIVA:
          return "TIVA";
        default:
          return type.toString().split('.').last;
      }
    }

    return Center(
      child: Container(
        width: 520,
        constraints: const BoxConstraints(minHeight: 140),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.65),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    truncatedDescription,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          emoji,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _translateResourceType(resource.type),
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
            const SizedBox(width: 24),
          ],
        ),
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

// Adicione esta função utilitária ao final da classe _HomeTabViewState:
String _getSubjectDisplayName(GoalSubject subject) {
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

String _getEmotionDisplayName(DiaryType emotion) {
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
