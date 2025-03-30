import 'dart:ui'; // For BackdropFilter
import 'package:flutter/material.dart';
import 'activity_details_page.dart';

enum ResourceType {
  ARTICLE,
  VIDEO,
  PODCAST,
  PHRASE,
  CARE,
  EXERCISE,
  RECIPE,
  MUSIC,
  SOS,
  OTHER,
}

class ResourceModel {
  final String title;
  final String description;
  final ResourceType type;
  final DateTime createdAt;
  final DateTime updatedAt;

  ResourceModel({
    required this.title,
    required this.description,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });
}

class ActivityModel {
  final String title;
  final String description;
  final DateTime createdAt;
  final List<ResourceModel> resources;

  ActivityModel({
    required this.title,
    required this.description,
    required this.createdAt,
    required this.resources,
  });
}

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({Key? key}) : super(key: key);

  @override
  _ActivitiesPageState createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  // Dummy activity data
  final List<ActivityModel> _activities = [
    ActivityModel(
      title: "Morning Yoga",
      description: "A relaxing yoga session to start your day. This session will help you stretch and relax your body while preparing for the day ahead.",
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      resources: [
        ResourceModel(
          title: "Yoga Mat",
          description: "A high-quality yoga mat for your practice.",
          type: ResourceType.EXERCISE,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        ResourceModel(
          title: "Water Bottle",
          description: "Stay hydrated during your yoga session.",
          type: ResourceType.OTHER,
          createdAt: DateTime.now().subtract(const Duration(days: 12)),
          updatedAt: DateTime.now().subtract(const Duration(days: 6)),
        ),
        ResourceModel(
          title: "Yoga Mat",
          description: "A high-quality yoga mat for your practice.",
          type: ResourceType.EXERCISE,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        ResourceModel(
          title: "Water Bottle",
          description: "Stay hydrated during your yoga session.",
          type: ResourceType.OTHER,
          createdAt: DateTime.now().subtract(const Duration(days: 12)),
          updatedAt: DateTime.now().subtract(const Duration(days: 6)),
        ),
        ResourceModel(
          title: "Yoga Mat",
          description: "A high-quality yoga mat for your practice.",
          type: ResourceType.EXERCISE,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        ResourceModel(
          title: "Water Bottle",
          description: "Stay hydrated during your yoga session.",
          type: ResourceType.OTHER,
          createdAt: DateTime.now().subtract(const Duration(days: 12)),
          updatedAt: DateTime.now().subtract(const Duration(days: 6)),
        ),
      ],
    ),
    ActivityModel(
      title: "Cooking Class",
      description: "Learn to cook a delicious Italian pasta dish. This class will teach you the basics of Italian cuisine.",
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      resources: [
        ResourceModel(
          title: "Recipe Book",
          description: "A book with Italian pasta recipes.",
          type: ResourceType.RECIPE,
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          updatedAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
        ResourceModel(
          title: "Ingredients",
          description: "Fresh ingredients for the pasta dish.",
          type: ResourceType.OTHER,
          createdAt: DateTime.now().subtract(const Duration(days: 14)),
          updatedAt: DateTime.now().subtract(const Duration(days: 8)),
        ),
      ],
    ),
    ActivityModel(
      title: "Meditation Session",
      description: "A guided meditation to help you relax and focus. This session is perfect for beginners and experienced meditators alike.",
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      resources: [
        ResourceModel(
          title: "Meditation App",
          description: "An app with guided meditation sessions.",
          type: ResourceType.CARE,
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        ResourceModel(
          title: "Headphones",
          description: "Noise-canceling headphones for meditation.",
          type: ResourceType.OTHER,
          createdAt: DateTime.now().subtract(const Duration(days: 18)),
          updatedAt: DateTime.now().subtract(const Duration(days: 9)),
        ),
      ],
    ),
  ];

  // Set to store selected activity filter types
  Set<ResourceType> _selectedFilterTypes = {};

  // List of all available activity filter types
  final List<ResourceType> _filterTypes = ResourceType.values;

  // Control the visibility of the sliding filter panel
  bool _isFilterPanelVisible = false;

  // Function to toggle the filter panel visibility
  void _toggleFilterPanel() {
    setState(() {
      _isFilterPanelVisible = !_isFilterPanelVisible;
    });
  }

  // Function to close filter panel when tapping outside
  void _closeFilterPanel() {
    if (_isFilterPanelVisible) {
      setState(() {
        _isFilterPanelVisible = false;
      });
    }
  }

  // List of background colors for activities
  final List<Color> _activityColors = [
    const Color(0xFF9CC5FF),
    const Color(0xFF6E6AE8),
    const Color(0xFF005FE7),
    const Color(0xFFBBA6FF),
  ];

  // Set to track favorite activities
  final Set<String> _favoriteActivities = {};

  // Variable to track the glowing state of the star icon
  bool _isStarGlowing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content with blur effect when filter is open
          GestureDetector(
            onTap: _closeFilterPanel,
            child: IgnorePointer(
              ignoring: _isFilterPanelVisible, // Disable interactions when the filter is open
              child: Stack(
                children: [
                  Container(
                    color: Colors.transparent, // Detect taps anywhere on the screen
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center, // Center the cards
                          children: [
                            const SizedBox(height: 60), // Add spacing between the top of the screen and the title
                            // Title (Activities) centered at the top
                            const Center(
                              child: Text(
                                "Activities",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontFamily: "Poppins",
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            // Input TextField with Search icon
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Search Activities",
                                labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                                prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              ),
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 20),
                            // Display the activities as cards
                            Column(
                              children: _activities
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) {
                                      final index = entry.key;
                                      final activity = entry.value;
                                      final backgroundColor = _activityColors[index % _activityColors.length];
                                      final isFavorite = _favoriteActivities.contains(activity.title);

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 15), // Increased spacing
                                        child: Container(
                                          constraints: const BoxConstraints(maxWidth: 350, maxHeight: 350),
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: backgroundColor,
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
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Title
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    activity.title,
                                                    style: const TextStyle(
                                                      fontSize: 24,
                                                      fontFamily: "Poppins",
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),

                                              // Description
                                              Text(
                                                activity.description,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.7),
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 8),

                                              // Created At
                                              Text(
                                                "Created At: ${activity.createdAt.toLocal().toString().split(' ')[0]}",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: "Inter",
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 8),

                                              // Resources Count
                                              Text(
                                                "Resources: ${activity.resources.length}",
                                                style: const TextStyle(
                                                  fontSize: 14,
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
                                                        builder: (context) => ActivityDetailsPage(
                                                          activity: activity,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    foregroundColor: backgroundColor, backgroundColor: Colors.white,
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
                                      );
                                    },
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Apply blur effect when filter panel is visible
                  if (_isFilterPanelVisible)
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Adjust blur intensity
                      child: Container(
                        color: Colors.black.withOpacity(0.2), // Optional: Add a semi-transparent overlay
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Filter Icon Positioned
          Positioned(
            top: 58,
            right: 20,
            child: Row(
              children: [
                // Star Icon
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isStarGlowing = !_isStarGlowing;
                    });
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: _isStarGlowing
                                ? Colors.blue.withOpacity(0.8) // Glowing shadow when pressed
                                : Colors.black.withOpacity(0.2), // Default shadow when not pressed
                            blurRadius: _isStarGlowing ? 15 : 5,
                            spreadRadius: _isStarGlowing ? 5 : 0,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.star,
                        color: _isStarGlowing ? Colors.blue : Colors.grey,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Filter Icon
                GestureDetector(
                  onTap: _toggleFilterPanel,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
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
                        Icons.filter_alt,
                        color: Colors.blue,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Sliding filter panel
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            right: _isFilterPanelVisible ? 0 : -230, // Slide in/out effect
            top: 0,
            bottom: 0,
            child: Container(
              width: 230,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(50, 75, 200, 1), // Start color (darker blue)
                    Color.fromRGBO(100, 130, 255, 1), // End color (lighter blue)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(-5, 0), // Shadow on the left side
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40), // Space between the arrow and text
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
                          "Filter by Type",
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
                          children: _filterTypes.map((filterType) {
                            bool isSelected = _selectedFilterTypes.contains(filterType);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedFilterTypes.remove(filterType);
                                  } else {
                                    _selectedFilterTypes.add(filterType);
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: isSelected
                                      ? const Color.fromRGBO(70, 100, 200, 1) // Selected button color (blueish)
                                      : Colors.white, // Default button color
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Center(
                                  child: Text(
                                    filterType.toString().split('.').last,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color.fromRGBO(50, 75, 200, 1), // Text color for unselected buttons
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins",
                                    ),
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
        ],
      ),
    );
  }
}