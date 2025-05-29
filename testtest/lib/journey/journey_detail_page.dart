import 'package:flutter/material.dart';
import 'package:testtest/services/journey/journey_model.dart';
import 'dart:math';

class JourneyDetailPage extends StatefulWidget {
  final UserJourneyProgress journey;

  const JourneyDetailPage({Key? key, required this.journey}) : super(key: key);

  @override
  _JourneyDetailPageState createState() => _JourneyDetailPageState();
}

class _JourneyDetailPageState extends State<JourneyDetailPage> {
  bool _showFirstStarfish = Random().nextBool();

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section with back button and title
                Padding(
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
                      const SizedBox(height: 20), // Add spacing below the back button
                      // Title
                      Text(
                        "Journey ID: ${journey.journeyId}",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10), // Add spacing below the title
                      // Description
                      const Text(
                        "This is a detailed description of the journey. It provides an overview of the journey's purpose and progress.",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Inter",
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40), // Add more spacing below the description
                    ],
                  ),
                ),
                // Middle section with squares
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 10, // Horizontal spacing between squares
                    runSpacing: 10, // Vertical spacing between rows
                    alignment: WrapAlignment.center, // Center the squares horizontally
                    children: journey.resourceProgressList.map((resource) {
                      return Stack(
                        children: [
                          // Square background
                          Container(
                            width: 50, // Fixed width for each square
                            height: 50, // Fixed height for each square
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: Opacity(
                              opacity: (resource.completed || !resource.unlocked) ? 0.3 : 1.0, // Blur effect
                              child: Text(
                                resource.order.toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          // Overlay icons for completed or locked states
                          if (resource.completed)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.greenAccent,
                                size: 20,
                              ),
                            )
                          else if (!resource.unlocked)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Icon(
                                Icons.lock,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const Spacer(), // Push the bottom section to the bottom of the page
                // Bottom section with user ID and resource count
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // User ID
                      Text(
                        "User ID: ${journey.userId}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      // Number of resources
                      Text(
                        "Resources: ${journey.resourceProgressList.length}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}