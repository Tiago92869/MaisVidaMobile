import 'dart:ui'; // For BackdropFilter
import 'package:flutter/material.dart';
import 'package:mentara/services/activity/activity_service.dart';
import 'package:mentara/services/activity/activity_model.dart';
import 'package:mentara/services/favorite/favorite_service.dart';
import 'activity_details_page.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({Key? key}) : super(key: key);

  @override
  _ActivitiesPageState createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  final ActivityService _activityService = ActivityService();
  final FavoriteService _favoriteService = FavoriteService(); // Add FavoriteRepository

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
        // Garantir que a lista vazia mostra o estado vazio
        if (_activities.isEmpty) {
          _isLastPage = true;
        }
      });
    } catch (e) {
      print('Error fetching activities: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Falha ao procurar atividades. Tente novamente."),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _activities = [];
        _isLastPage = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchFavoriteActivities() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final favoriteActivities = await _favoriteService.fetchFavoriteActivities();
      setState(() {
        _activities = favoriteActivities; // Replace activities with favorites
        _isLastPage = true; // Assume all favorite activities are loaded
      });
    } catch (e) {
      print('Error fetching favorite activities: $e');
      // Show empty state if 404 or any error
      setState(() {
        _activities = [];
        _isLastPage = true;
      });
      // Optionally, you can still show the snackbar for other errors
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
        onTap: () async {
          setState(() {
            _isStarGlowing = !_isStarGlowing; // Toggle the glowing state
          });

          if (_isStarGlowing) {
            // Fetch favorite activities when the star is glowing
            await _fetchFavoriteActivities();
          } else {
            // Reset the activities list using the existing fetch logic
            setState(() {
              _activities.clear();
              _currentPage = 0;
              _isLastPage = false;
            });
            _fetchActivities();
          }
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(
                  Icons.star,
                  color: _isStarGlowing ? const Color.fromARGB(255, 255, 217, 0) : Colors.grey,
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
        color: backgroundColor.withOpacity(0.65),
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
            maxLines: 4, // Limit the description to a maximum of 3 lines
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(
            height: 20,
          ), // Increased spacing between description and resources
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
              onPressed: () async {
                // Navigate to ActivityDetailsPage and wait for the result
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActivityDetailsPage(activity: activity),
                  ),
                );

                // Refresh the activities list when returning
                if (_isStarGlowing) {
                  // If the star icon is glowing, fetch favorite activities
                  await _fetchFavoriteActivities();
                } else {
                  // Otherwise, refresh the default activities list
                  _onSearch(_searchText);
                }
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
                  colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
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
                  "Atividades",
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
                    labelText: "Pesquisar atividades",
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
                      child: _activities.isEmpty
                          ? Center(
                              child: Text(
                                "Nenhuma atividade encontrada",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
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
