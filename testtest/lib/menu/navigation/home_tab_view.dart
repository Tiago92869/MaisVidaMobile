import 'package:flutter/material.dart';
import 'package:testtest/activities/activity_details_page.dart';
import 'package:testtest/diary/diary_detail_page.dart';
import 'package:testtest/goals/goal_details_page.dart';
import 'package:testtest/medicines/medicine_detail_page.dart';
import 'package:testtest/resources/resource_detail_page.dart';
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
      final activities = await _activityService.fetchActivities(0, 3, "");
      setState(() {
        _activities = activities.content;
      });
    } catch (e) {
      _showErrorSnackBar("Failed to fetch activities.");
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
      _showErrorSnackBar("Failed to fetch medications.");
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
      _showErrorSnackBar("Failed to fetch goals.");
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
      _showErrorSnackBar("Failed to fetch diaries.");
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
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
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
                            width: 300,
                            height: 300,
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
              opacity: 0.1,
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
                  "Activities",
                  _activities,
                  _isLoadingActivities,
                  4, // Tab index for "Activities"
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
                  3, // Tab index for "Resources"
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
                          color: const Color(
                            0xFFB3E5FC,
                          ).withOpacity(0.3), // Lighter blue
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
                                color: Colors.white, // White text
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              medicine.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70, // Subtle white text
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
                                    color: Colors.white70, // Subtle white text
                                  ),
                                ),
                                Text(
                                  "Ends: ${medicine.endedAt.toLocal().toString().split(' ')[0]}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70, // Subtle white text
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  2, // Tab index for "Medication"
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
                          color: const Color(
                            0xFFCE93D8,
                          ).withOpacity(0.3), // Lighter purple
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
                                color: Colors.white, // White text
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              goal.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70, // Subtle white text
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
                                      0xFFCE93D8,
                                    ).withOpacity(0.2), // Lighter purple
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    goal.subject.toString().split('.').last,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white, // White text
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
                                        color:
                                            Colors.white70, // Subtle white text
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Switch(
                                      value: goal.completed,
                                      onChanged:
                                          null, // Disable toggle in this view
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
                  1, // Tab index for "Goals"
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
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF64B5F6,
                          ).withOpacity(0.3), // Transparent blue
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Left side: Diary information
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    diary.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white, // White text
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    diary.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color:
                                          Colors.white70, // Subtle white text
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Created: ${diary.createdAt.toLocal().toString().split(' ')[0]}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color:
                                          Colors.white70, // Subtle white text
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Right side: Emotion icon
                            Icon(
                              _getEmotionIcon(diary.emotion),
                              color: Colors.white, // White icon
                              size: 48, // Larger size for better visibility
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  0, // Tab index for "Diary"
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHCard(Resource resource) {
    const int maxDescriptionLength = 30; // Maximum length for the description

    String truncatedDescription =
        resource.description.length > maxDescriptionLength
            ? '${resource.description.substring(0, maxDescriptionLength)}...'
            : resource.description;

    return Container(
      constraints: const BoxConstraints(maxHeight: 110),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.3), // Transparent blue
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
                    fontWeight: FontWeight.bold, // Make the title bold
                    fontFamily: "Poppins",
                    color: Colors.white, // White text
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  truncatedDescription,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: "Inter",
                    color: Colors.white70, // Subtle white text
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
