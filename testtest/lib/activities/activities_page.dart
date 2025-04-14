import 'dart:ui'; // For BackdropFilter
import 'package:flutter/material.dart';
import 'package:testtest/services/activity/activity_service.dart';
import 'package:testtest/services/activity/activity_model.dart';
import 'activity_details_page.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({Key? key}) : super(key: key);

  @override
  _ActivitiesPageState createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  final ActivityService _activityService = ActivityService();

  // State variables
  List<Activity> _activities = [];
  String _searchText = "";
  bool _isLoading = false;
  int _currentPage = 0;
  bool _isLastPage = false;

  final List<Color> _activityColors = [
    const Color(0xFF9CC5FF),
    const Color(0xFF6E6AE8),
    const Color(0xFF005FE7),
    const Color(0xFFBBA6FF),
  ];

  // Variable to track the glowing state of the star icon
  bool _isStarGlowing = false;

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities({bool loadNextPage = false}) async {
    if (_isLoading || (loadNextPage && _isLastPage)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final activityPage = await _activityService.fetchActivities(
        page: loadNextPage ? _currentPage : 0,
        size: 10,
        searchQuery: _searchText,
      );

      setState(() {
        if (loadNextPage) {
          _activities.addAll(activityPage.content); // Append new activities
        } else {
          _activities = activityPage.content; // Replace activities
        }
        _isLastPage = activityPage.last;
        _currentPage = activityPage.number + 1; // Increment page for next fetch
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

  void _onSearch(String text) {
    setState(() {
      _searchText = text;
      _activities.clear();
      _currentPage = 0;
      _isLastPage = false;
    });
    _fetchActivities();
  }

  void _onScroll(ScrollController controller) {
    if (controller.position.pixels >=
        controller.position.maxScrollExtent - 200) {
      _fetchActivities(loadNextPage: true); // Fetch the next page
    }
  }

  Widget _buildStarIcon() {
    return Positioned(
      top: 58,
      right: 20,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isStarGlowing = !_isStarGlowing; // Toggle the glowing state
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
                  color:
                      _isStarGlowing
                          ? Colors.blue.withOpacity(
                            0.8,
                          ) // Glowing shadow when active
                          : Colors.black.withOpacity(0.2), // Default shadow
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
    );
  }

  Widget _buildActivityCard(Activity activity, Color backgroundColor) {
    return Container(
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
          // Title with a maximum of 2 lines
          Text(
            activity.title,
            style: const TextStyle(
              fontSize: 24,
              fontFamily: "Poppins",
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2, // Limit the title to a maximum of 2 lines
            overflow: TextOverflow.ellipsis, // Add ellipsis if it overflows
          ),
          const SizedBox(
            height: 30,
          ), // Increased spacing between title and description
          // Description with a maximum of 3 lines
          Text(
            activity.description,
            overflow: TextOverflow.ellipsis,
            maxLines: 3, // Limit the description to a maximum of 3 lines
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(
            height: 20,
          ), // Increased spacing between description and resources
          Text(
            "Resources: ${activity.resources?.length ?? 0}",
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
                        (context) => ActivityDetailsPage(activity: activity),
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();
    _scrollController.addListener(() => _onScroll(_scrollController));

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(
                      102,
                      122,
                      236,
                      1,
                    ), // Start color (darker blue)
                    Color.fromRGBO(
                      255,
                      255,
                      255,
                      1,
                    ), // End color (lighter blue)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Center(
                child: Text(
                  "Activities",
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: "Poppins",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    labelText: "Search Activities",
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                  ),
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: () async {
                        await _fetchActivities(); // Refresh the list
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        itemCount:
                            _activities.length + 1, // Add 1 for the SizedBox
                        itemBuilder: (context, index) {
                          if (index < _activities.length) {
                            final activity = _activities[index];
                            final backgroundColor =
                                _activityColors[index % _activityColors.length];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 20,
                              ),
                              child: _buildActivityCard(
                                activity,
                                backgroundColor,
                              ),
                            );
                          } else {
                            return const SizedBox(
                              height: 60,
                            ); // Add spacing at the end
                          }
                        },
                      ),
                    ),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ],
          ),
          // Star Icon
          _buildStarIcon(),
        ],
      ),
    );
  }
}
