import 'dart:ui'; // For BackdropFilter
import 'package:flutter/material.dart';
import 'package:testtest/services/activity/activity_service.dart';
import 'package:testtest/services/activity/activity_model.dart';
import 'package:testtest/services/resource/resource_model.dart';
import 'activity_details_page.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({Key? key}) : super(key: key);

  @override
  _ActivitiesPageState createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  final ActivityService _activityService = ActivityService();

  // List of activities fetched from the service
  List<Activity> _activities = [];

  // Search input text
  String _searchText = "";

  // Loading state
  bool _isLoading = false;

  // Pagination state
  int _currentPage = 0;
  bool _isLastPage = false;

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
  void initState() {
    super.initState();

    // Add mock activities for testing
    _activities = [
      Activity(
        id: "1",
        title: "Morning Yoga",
        description: "Start your day with a refreshing yoga session.",
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        resources: [
          Resource(
            id: "r1",
            title: "Yoga Basics",
            description: "Learn the basics of yoga.",
            type: ResourceType.VIDEO,
            createdAt: DateTime.now().subtract(const Duration(days: 10)),
            updatedAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
          Resource(
            id: "r2",
            title: "Breathing Techniques",
            description: "Master breathing techniques for relaxation.",
            type: ResourceType.ARTICLE,
            createdAt: DateTime.now().subtract(const Duration(days: 8)),
            updatedAt: DateTime.now().subtract(const Duration(days: 4)),
          ),
        ],
      ),
      Activity(
        id: "2",
        title: "Healthy Cooking",
        description: "Learn to cook healthy and delicious meals.",
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
        resources: [
          Resource(
            id: "r3",
            title: "Quick Recipes",
            description: "Prepare quick and healthy recipes.",
            type: ResourceType.RECIPE,
            createdAt: DateTime.now().subtract(const Duration(days: 15)),
            updatedAt: DateTime.now().subtract(const Duration(days: 10)),
          ),
        ],
      ),
      Activity(
        id: "3",
        title: "Meditation for Beginners",
        description: "A guide to help you start meditating.",
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
        resources: [
          Resource(
            id: "r4",
            title: "Meditation Basics",
            description: "Learn the basics of meditation.",
            type: ResourceType.PODCAST,
            createdAt: DateTime.now().subtract(const Duration(days: 25)),
            updatedAt: DateTime.now().subtract(const Duration(days: 20)),
          ),
        ],
      ),
    ];
  }

  // Function to fetch activities
  Future<void> _fetchActivities() async {
    if (_isLoading || _isLastPage) return; // Prevent duplicate or unnecessary requests

    setState(() {
      _isLoading = true;
    });

    try {
      final activityPage = await _activityService.fetchActivities(
        _currentPage, // Current page number
        20, // Page size
        _searchText, // Search query
      );

      setState(() {
        _activities.addAll(activityPage.content); // Append new activities to the list
        _isLastPage = activityPage.last; // Check if this is the last page
        _currentPage++; // Increment the page number for the next fetch
      });
    } catch (e) {
      print('Error fetching activities: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to fetch activities. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to handle search input
  void _onSearch(String text) {
    setState(() {
      _searchText = text;
      _activities.clear(); // Clear the current list of activities
      _currentPage = 0; // Reset to the first page
      _isLastPage = false; // Reset the last page flag
    });
    _fetchActivities();
  }

  // Function to detect when the user scrolls to the bottom
  void _onScroll(ScrollController controller) {
    if (controller.position.pixels >= controller.position.maxScrollExtent - 200) {
      _fetchActivities(); // Fetch the next page when near the bottom
    }
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();
    _scrollController.addListener(() => _onScroll(_scrollController));

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
                      child: RefreshIndicator(
                        onRefresh: () async {
                          setState(() {
                            _activities.clear(); // Clear current activities
                            _currentPage = 0; // Reset pagination
                            _isLastPage = false; // Reset last page flag
                          });
                          await _fetchActivities(); // Fetch activities again
                        },
                        child: SingleChildScrollView(
                          controller: _scrollController, // Attach the scroll controller
                          physics: const AlwaysScrollableScrollPhysics(), // Ensure pull-to-refresh works
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
                                onChanged: _onSearch, // Trigger search on input change
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

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 15),
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
                                                Text(
                                                  activity.title,
                                                  style: const TextStyle(
                                                    fontSize: 24,
                                                    fontFamily: "Poppins",
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
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
                                                  "Created At: ${activity.createdAt?.toLocal().toString().split(' ')[0]}",
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
                                                  "Resources: ${activity.resources?.length}",
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
                                        );
                                      },
                                    )
                                    .toList(),
                              ),
                              if (_isLoading)
                                const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(),
                                ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
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