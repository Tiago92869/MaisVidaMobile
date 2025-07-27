import 'dart:ui';
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
  final FavoriteService _favoriteService = FavoriteService();

  List<Activity> _activities = [];
  String _searchText = "";
  bool _isLoading = false;
  int _currentPage = 0;
  bool _isLastPage = false;

  final List<Color> _activityColors = [
    Color(0xFF9CC5FF),
    Color(0xFF6E6AE8),
    Color(0xFF005FE7),
    Color(0xFFBBA6FF),
  ];

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
          _activities.addAll(activityPage.content);
        } else {
          _activities = activityPage.content;
        }
        _isLastPage = activityPage.last;
        _currentPage = activityPage.number + 1;
        if (_activities.isEmpty) {
          _isLastPage = true;
        }
      });
    } catch (e) {
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
        _activities = favoriteActivities;
        _isLastPage = true;
      });
    } catch (e) {
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
      _fetchActivities(loadNextPage: true);
    }
  }

  Widget _buildStarIcon() {
    return Positioned(
      top: 58,
      right: 20,
      child: GestureDetector(
        onTap: () async {
          setState(() {
            _isStarGlowing = !_isStarGlowing;
          });

          if (_isStarGlowing) {
            await _fetchFavoriteActivities();
          } else {
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
              color: _isStarGlowing ? Color.fromARGB(255, 255, 217, 0) : Colors.grey,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(Activity activity, Color backgroundColor) {
    return Container(
      constraints: BoxConstraints(maxWidth: 350, maxHeight: 350),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.65),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 12),
          ),
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activity.title,
            style: TextStyle(
              fontSize: 24,
              fontFamily: "Poppins",
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 30),
          Text(
            activity.description,
            overflow: TextOverflow.ellipsis,
            maxLines: 4,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Recursos: ${activity.resources?.length ?? 0}",
            style: TextStyle(
              fontSize: 17,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Spacer(),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActivityDetailsPage(activity: activity),
                  ),
                );
                if (_isStarGlowing) {
                  await _fetchFavoriteActivities();
                } else {
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
              child: Text(
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
    final ScrollController scrollController = ScrollController();
    scrollController.addListener(() => _onScroll(scrollController));

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60),
              Center(
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
              SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    labelText: "Pesquisar atividades",
                    labelStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                  ),
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: () async {
                        await _fetchActivities();
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
                              controller: scrollController,
                              physics: AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(vertical: 10),
                              itemCount: _activities.length + 1,
                              itemBuilder: (context, index) {
                                if (index < _activities.length) {
                                  final activity = _activities[index];
                                  final backgroundColor =
                                      _activityColors[index % _activityColors.length];
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 20,
                                    ),
                                    child: _buildActivityCard(
                                      activity,
                                      backgroundColor,
                                    ),
                                  );
                                } else {
                                  return SizedBox(
                                    height: 60,
                                  );
                                }
                              },
                            ),
                    ),
                    if (_isLoading)
                      Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ],
          ),
          _buildStarIcon(),
        ],
      ),
    );
  }
}
