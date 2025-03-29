import 'package:flutter/material.dart';
import 'activities_page.dart';
import 'dart:math';

class ActivityDetailsPage extends StatefulWidget {
  final ActivityModel activity;

  static final Set<String> favoriteActivities = {}; // Track favorite activities

  const ActivityDetailsPage({Key? key, required this.activity}) : super(key: key);

  @override
  _ActivityDetailsPageState createState() => _ActivityDetailsPageState();
}

class _ActivityDetailsPageState extends State<ActivityDetailsPage> {
  int _currentResourceIndex = 0;
  bool _isViewingResources = false;
  bool _showFirstStarfish = Random().nextBool();

  void _startActivity() {
    setState(() {
      _isViewingResources = true;
      _currentResourceIndex = 0;
    });
  }

  void _nextResource() {
    setState(() {
      if (_currentResourceIndex < widget.activity.resources.length - 1) {
        _currentResourceIndex++;
        _showFirstStarfish = Random().nextBool();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;
    final isFavorite = ActivityDetailsPage.favoriteActivities.contains(widget.activity.title);

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0D1B2A),
                    Color(0xFF1B263B),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Randomly show one of the starfish images
          if (_showFirstStarfish)
            Positioned(
              right: 80,
              top: 320,
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
            )
          else
            Positioned(
              left: 100,
              top: 250,
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
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title and Favorite Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.activity.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                            color: Colors.white,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isFavorite) {
                              ActivityDetailsPage.favoriteActivities.remove(widget.activity.title);
                            } else {
                              ActivityDetailsPage.favoriteActivities.add(widget.activity.title);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isFavorite ? Colors.yellow : Colors.transparent,
                            border: Border.all(color: Colors.yellow, width: 2),
                          ),
                          child: Icon(
                            isFavorite ? Icons.star : Icons.star_border,
                            color: isFavorite ? Colors.white : Colors.yellow,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Resource Types (in activity details)
                  if (!_isViewingResources)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: activity.resources.map((resource) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            resource.type.toString().split('.').last.capitalizeFirstLetter(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 20),
                  // Description or Resource View
                  Expanded(
                    child: _isViewingResources
                        ? _buildResourceView()
                        : SingleChildScrollView(
                            child: Text(
                              activity.description,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: "Inter",
                                color: Colors.white,
                                height: 1.5,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  // Created At
                  if (!_isViewingResources)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDateInfo("Created At", activity.createdAt),
                        _buildDateInfo("Resources", activity.resources.length.toString()),
                      ],
                    ),
                  const SizedBox(height: 20),
                  // Start or Next Button
                  if (!_isViewingResources)
                    Center(
                      child: ElevatedButton(
                        onPressed: _startActivity,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: const Color.fromRGBO(72, 85, 204, 1),
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
                    )
                  else
                    _buildNavigationButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo(String label, dynamic value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value is DateTime
              ? "${value.day.toString().padLeft(2, '0')}-${value.month.toString().padLeft(2, '0')}-${value.year}"
              : value.toString(),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildResourceView() {
    final resource = widget.activity.resources[_currentResourceIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          resource.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        // Resource Type
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            resource.type.toString().split('.').last.capitalizeFirstLetter(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          resource.description,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Center(
      child: ElevatedButton(
        onPressed: _currentResourceIndex < widget.activity.resources.length - 1
            ? _nextResource
            : () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color.fromRGBO(72, 85, 204, 1),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          _currentResourceIndex < widget.activity.resources.length - 1 ? "Next" : "Finish",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
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