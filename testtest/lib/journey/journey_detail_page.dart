import 'package:flutter/material.dart';
import 'package:testtest/services/journey/journey_model.dart';
import 'dart:math';

class JourneyDetailPage extends StatefulWidget {
  final Journey journey;

  const JourneyDetailPage({Key? key, required this.journey}) : super(key: key);

  @override
  _JourneyDetailPageState createState() => _JourneyDetailPageState();
}

class _JourneyDetailPageState extends State<JourneyDetailPage> {
  int _currentResourceIndex = 0;
  bool _isViewingResources = false;
  bool _showFirstStarfish = Random().nextBool();

  void _startJourney() {
    print('Starting journey: ${widget.journey.title}');
    setState(() {
      _isViewingResources = true;
      _currentResourceIndex = 0;
    });
  }

  void _nextResource() {
    print('Viewing next resource in journey: ${widget.journey.title}');
    setState(() {
      if (_currentResourceIndex < widget.journey.journeyResources.length - 1) {
        _currentResourceIndex++;
        _showFirstStarfish = Random().nextBool();
      } else {
        print('No more resources to view in journey: ${widget.journey.title}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final journey = widget.journey;

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
                  // Title
                  Text(
                    journey.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins",
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Journey Resources
                  if (!_isViewingResources)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: journey.journeyResources.map((resource) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Resource ${resource.order}",
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
                              journey.description,
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
                        _buildDateInfo("Created At", journey.createdAt),
                        _buildDateInfo(
                          "Resources",
                          journey.journeyResources.length.toString(),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  // Start or Next Button
                  if (!_isViewingResources)
                    Center(
                      child: ElevatedButton(
                        onPressed: _startJourney,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: const Color(0xFF0D1B2A),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Start",
                          style: TextStyle(
                            fontSize: 20,
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
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildResourceView() {
    final resource = widget.journey.journeyResources[_currentResourceIndex];
    print('Viewing resource ${resource.order} in journey: ${widget.journey.title}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Resource ${resource.order}",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Unlock Image ID: ${resource.unlockImageId ?? 'N/A'}",
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Center(
      child: ElevatedButton(
        onPressed: _currentResourceIndex <
                widget.journey.journeyResources.length - 1
            ? _nextResource
            : () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color(0xFF0D1B2A),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          _currentResourceIndex <
                  widget.journey.journeyResources.length - 1
              ? "Next"
              : "Finish",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}