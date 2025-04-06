import 'package:flutter/material.dart';
import 'package:testtest/activities/activity_details_page.dart';
import 'package:testtest/diary/diary_detail_page.dart';
import 'package:testtest/goals/goal_details_page.dart';
import 'package:testtest/medicines/medicine_detail_page.dart';
import 'package:testtest/menu/components/hcard.dart';
import 'package:testtest/menu/components/vcard.dart';
import 'package:testtest/menu/models/courses.dart';
import 'package:testtest/menu/theme.dart';
import 'package:testtest/activities/activities_page.dart';
import 'package:testtest/resources/resource_detail_page.dart';
import 'package:testtest/resources/resources_page.dart';
import 'package:testtest/medicines/medicines_page.dart';
import 'package:testtest/goals/goals_page.dart';
import 'package:testtest/diary/diary_page.dart';
import 'package:testtest/services/activity/activity_service.dart';
import 'package:testtest/services/resource/resource_service.dart';
import 'package:testtest/services/medicine/medicine_service.dart';
import 'package:testtest/services/goal/goal_service.dart';
import 'package:testtest/services/diary/diary_service.dart';
import 'package:testtest/services/activity/activity_model.dart';
import 'package:testtest/services/resource/resource_model.dart';
import 'package:testtest/services/medicine/medicine_model.dart';
import 'package:testtest/services/goal/goal_model.dart';
import 'package:testtest/services/diary/diary_model.dart';

class HomeTabView extends StatefulWidget {
  const HomeTabView({Key? key}) : super(key: key);

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> {
  final List<CourseModel> _courses = CourseModel.courses;
  final List<CourseModel> _courseSections = CourseModel.courseSections;

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
      final activities = await _activityService.fetchActivities(0, 3, "");
      setState(() {
        _activities =
            activities.content.isNotEmpty
                ? activities.content
                : _getMockedActivities();
      });
    } catch (e) {
      _showErrorSnackBar("Failed to fetch activities.");
      setState(() {
        _activities = _getMockedActivities();
      });
    } finally {
      setState(() {
        _isLoadingActivities = false;
      });
    }
  }

  Future<void> _fetchResources() async {
    try {
      final resources = await _resourceService.fetchResources([], 0, 4, "");
      setState(() {
        _resources =
            resources.content.isNotEmpty
                ? resources.content
                : _getMockedResources();
      });
    } catch (e) {
      _showErrorSnackBar("Failed to fetch resources.");
      setState(() {
        _resources = _getMockedResources();
      });
    } finally {
      setState(() {
        _isLoadingResources = false;
      });
    }
  }

  Future<void> _fetchMedications() async {
    try {
      final medications = await _medicineService.fetchMedicines(
        false,
        DateTime.now(),
        DateTime.now(),
      );
      setState(() {
        _medications =
            medications.isNotEmpty
                ? medications[0].medicines.take(3).toList()
                : _getMockedMedications();
      });
    } catch (e) {
      _showErrorSnackBar("Failed to fetch medications.");
      setState(() {
        _medications = _getMockedMedications();
      });
    } finally {
      setState(() {
        _isLoadingMedications = false;
      });
    }
  }

  Future<void> _fetchGoals() async {
    try {
      final goals = await _goalService.fetchGoals(
        false,
        DateTime.now(),
        DateTime.now(),
        [],
      );
      setState(() {
        _goals =
            goals.isNotEmpty
                ? goals[0].goals.take(3).toList()
                : _getMockedGoals();
      });
    } catch (e) {
      _showErrorSnackBar("Failed to fetch goals.");
      setState(() {
        _goals = _getMockedGoals();
      });
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
        _diaries =
            diaries.isNotEmpty
                ? diaries[0].diaries.take(3).toList()
                : _getMockedDiaries();
      });
    } catch (e) {
      _showErrorSnackBar("Failed to fetch diaries.");
      setState(() {
        _diaries = _getMockedDiaries();
      });
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

  // Mocked data for each section
  List<Activity> _getMockedActivities() {
    return [
      Activity(
        id: "1",
        title: "Mocked Activity 1",
        description: "Description for activity 1",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        resources: [],
      ),
      Activity(
        id: "2",
        title: "Mocked Activity 2",
        description: "Description for activity 2",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        resources: [],
      ),
      Activity(
        id: "3",
        title: "Mocked Activity 3",
        description: "Description for activity 3",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        resources: [],
      ),
    ];
  }

  List<Resource> _getMockedResources() {
    return [
      Resource(
        id: "1",
        title: "Mocked Resource 1",
        description: "Description for resource 1",
        type: ResourceType.ARTICLE,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Resource(
        id: "2",
        title: "Mocked Resource 2",
        description: "Description for resource 2",
        type: ResourceType.VIDEO,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Resource(
        id: "3",
        title: "Mocked Resource 3",
        description: "Description for resource 3",
        type: ResourceType.PODCAST,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Resource(
        id: "4",
        title: "Mocked Resource 4",
        description: "Description for resource 4",
        type: ResourceType.EXERCISE,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  List<Medicine> _getMockedMedications() {
    return [
      Medicine(
        id: "1",
        name: "Mocked Medicine 1",
        description: "Description for medicine 1",
        archived: false,
        startedAt: DateTime.now().subtract(const Duration(days: 10)),
        endedAt: DateTime.now().add(const Duration(days: 10)),
        hasNotifications: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        plans: [],
      ),
      Medicine(
        id: "2",
        name: "Mocked Medicine 2",
        description: "Description for medicine 2",
        archived: false,
        startedAt: DateTime.now().subtract(const Duration(days: 5)),
        endedAt: DateTime.now().add(const Duration(days: 15)),
        hasNotifications: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        plans: [],
      ),
      Medicine(
        id: "3",
        name: "Mocked Medicine 3",
        description: "Description for medicine 3",
        archived: true,
        startedAt: DateTime.now().subtract(const Duration(days: 20)),
        endedAt: DateTime.now().add(const Duration(days: 5)),
        hasNotifications: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        plans: [],
      ),
    ];
  }

  List<GoalInfoCard> _getMockedGoals() {
    return [
      GoalInfoCard(
        id: "1",
        title: "Mocked Goal 1",
        description: "Description for goal 1",
        goalDate: DateTime.now().add(const Duration(days: 7)),
        completedDate: null,
        completed: false,
        hasNotifications: true,
        subject: GoalSubject.Personal,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      GoalInfoCard(
        id: "2",
        title: "Mocked Goal 2",
        description: "Description for goal 2",
        goalDate: DateTime.now().add(const Duration(days: 14)),
        completedDate: null,
        completed: false,
        hasNotifications: false,
        subject: GoalSubject.Work,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      GoalInfoCard(
        id: "3",
        title: "Mocked Goal 3",
        description: "Description for goal 3",
        goalDate: DateTime.now().add(const Duration(days: 21)),
        completedDate: null,
        completed: true,
        hasNotifications: true,
        subject: GoalSubject.Studies,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  List<Diary> _getMockedDiaries() {
    return [
      Diary(
        id: "1",
        title: "Mocked Diary 1",
        description: "Description for diary 1",
        recordedAt: DateTime.now(),
        emotion: DiaryType.Happy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Diary(
        id: "2",
        title: "Mocked Diary 2",
        description: "Description for diary 2",
        recordedAt: DateTime.now(),
        emotion: DiaryType.Neutral,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Diary(
        id: "3",
        title: "Mocked Diary 3",
        description: "Description for diary 3",
        recordedAt: DateTime.now(),
        emotion: DiaryType.Sad,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  Widget _buildSection(
    String title,
    List<dynamic> items,
    bool isLoading,
    Widget Function(dynamic) itemBuilder,
    VoidCallback onSeeMore,
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
                style: const TextStyle(fontSize: 34, fontFamily: "Poppins"),
              ),
              GestureDetector(
                onTap: onSeeMore,
                child: const Text(
                  "See More",
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
            ? const Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
              child: Text(
                "No data available",
                style: TextStyle(color: Colors.grey),
              ),
            )
            : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                10,
                10,
                10,
                20,
              ), // Added consistent padding
              child: Column(children: items.map(itemBuilder).toList()),
            ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildActivitiesSection(
    String title,
    List<Activity> activities,
    bool isLoading,
    VoidCallback onSeeMore,
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
                style: TextStyle(fontSize: 34, fontFamily: "Poppins"),
              ),
              GestureDetector(
                onTap: onSeeMore,
                child: const Text(
                  "See More",
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
            ? const Text(
              "No activities available",
              style: TextStyle(color: Colors.grey),
            )
            : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
              child: Row(
                children:
                    activities.map((activity) {
                      final backgroundColor =
                          const [
                            Color(0xFF9CC5FF),
                            Color(0xFF6E6AE8),
                            Color(0xFF005FE7),
                            Color(0xFFBBA6FF),
                          ][activities.indexOf(activity) %
                              4]; // Cycle through colors

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
                            width: 300, // Ensure a fixed width for each card
                            height: 300, // Optional: Set a fixed height
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: backgroundColor,
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  activity.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
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
                                      foregroundColor: backgroundColor,
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      "Start",
                                      style: TextStyle(
                                        fontSize: 16,
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
      backgroundColor: Colors.transparent,
      body: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: RiveAppTheme.background,
          borderRadius: BorderRadius.circular(30),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 60,
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildActivitiesSection(
                "Activities",
                _activities,
                _isLoadingActivities,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ActivitiesPage(),
                  ),
                ),
              ),
              _buildSection(
                "Resources",
                _resources,
                _isLoadingResources,
                (resource) {
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
                      child: _buildHCard(resource),
                    ),
                  );
                },
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResourcesPage(),
                  ),
                ),
              ),
              _buildSection(
                "Medication",
                _medications,
                _isLoadingMedications,
                (medicine) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => MedicineDetailPage(
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
                        color: const Color(0xFF4A90E2).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicine.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A90E2),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            medicine.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Starts: ${medicine.startedAt.toLocal().toString().split(' ')[0]}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                "Ends: ${medicine.endedAt.toLocal().toString().split(' ')[0]}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MedicinesPage(),
                  ),
                ),
              ),
              _buildSection(
                "Goals",
                _goals,
                _isLoadingGoals,
                (goal) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => GoalDetailPage(
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
                        color: const Color(0xFF7B61FF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7B61FF),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            goal.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF7B61FF,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  StringCapitalization(
                                    goal.subject.toString().split('.').last,
                                  ).capitalizeFirstLetter(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7B61FF),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    goal.completed
                                        ? "Completed"
                                        : "Not Completed",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Switch(
                                    value: goal.completed,
                                    onChanged: null,
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
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GoalsPage()),
                ),
              ),
              _buildSection(
                "Diary",
                _diaries,
                _isLoadingDiaries,
                (diary) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => DiaryDetailPage(
                                diary: diary,
                                createDiary: false,
                              ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: const Color(0xFFBBDEFB), // Lighter blue color
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          diary.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                Colors.black, // Darker text for better contrast
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              diary.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black87,
                              ), // Subtle dark text
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Created: ${diary.createdAt.toLocal().toString().split(' ')[0]}",
                              style: const TextStyle(
                                fontSize: 14,
                                color:
                                    Colors
                                        .black54, // Subtle gray text for the date
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          _getEmotionIcon(diary.emotion),
                          color: const Color(
                            0xFF64B5F6,
                          ), // Light blue for the icon
                          size: 32,
                        ),
                      ),
                    ),
                  );
                },
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DiaryPage()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHCard(Resource resource) {
    const int maxDescriptionLength =
        30; // Maximum length for the description (fits around two lines)

    String truncatedDescription =
        resource.description.length > maxDescriptionLength
            ? '${resource.description.substring(0, maxDescriptionLength)}...'
            : resource.description;

    return Container(
      constraints: const BoxConstraints(maxHeight: 110),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blueAccent, // Replace with a dynamic color if needed
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: "Poppins",
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  truncatedDescription,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: "Inter",
                    color: Colors.white,
                  ),
                  maxLines: 2, // Ensure it doesn't exceed two lines
                  overflow:
                      TextOverflow.ellipsis, // Add ellipsis if it overflows
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: VerticalDivider(thickness: 0.8, width: 0),
          ),
          Opacity(
            opacity: 0.9,
            child: Image.asset(
              _getImageForResourceType(resource.type),
              width: 48, // Set the width to 48
              height: 48, // Set the height to 48
              fit: BoxFit.contain, // Ensure the image fits within the bounds
            ),
          ),
        ],
      ),
    );
  }

  String _getImageForResourceType(ResourceType type) {
    switch (type) {
      case ResourceType.ARTICLE:
        return 'assets/images/resources/newspaper.png';
      case ResourceType.VIDEO:
        return 'assets/images/resources/video.png';
      case ResourceType.PODCAST:
        return 'assets/images/resources/recording.png';
      case ResourceType.EXERCISE:
        return 'assets/images/resources/physical-wellbeing.png';
      case ResourceType.RECIPE:
        return 'assets/images/resources/recipe.png';
      case ResourceType.SOS:
        return 'assets/images/resources/sos.png';
      default:
        return 'assets/images/resources/other.png';
    }
  }
}

// Extension to capitalize the first letter of a string
extension StringCapitalization on String {
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}

IconData _getEmotionIcon(DiaryType emotion) {
  switch (emotion) {
    case DiaryType.Love:
      return Icons.favorite;
    case DiaryType.Fantastic:
      return Icons.star;
    case DiaryType.Happy:
      return Icons.sentiment_satisfied;
    case DiaryType.Neutral:
      return Icons.sentiment_neutral;
    case DiaryType.Disappointed:
      return Icons.sentiment_dissatisfied;
    case DiaryType.Sad:
      return Icons.sentiment_very_dissatisfied;
    case DiaryType.Angry:
      return Icons.mood_bad;
    case DiaryType.Sick:
      return Icons.sick;
    default:
      return Icons.sentiment_neutral;
  }
}
