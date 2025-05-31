import 'package:flutter/material.dart';
import 'dart:math'; // Import for Random

class JourneyFeelingPage extends StatefulWidget {
  const JourneyFeelingPage({Key? key}) : super(key: key);

  @override
  _JourneyFeelingPageState createState() => _JourneyFeelingPageState();
}

class _JourneyFeelingPageState extends State<JourneyFeelingPage> {
  bool _showFirstStarfish = Random().nextBool(); // Randomly decide which starfish to show

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size; // Get the screen size

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: screenSize.width,
          height: screenSize.height,
          child: Stack(
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
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Go Back Icon
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'How do you feel today?',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildFeelingOption(
                                  emoji: '😊',
                                  label: 'Good',
                                ),
                                const SizedBox(height: 20),
                                _buildFeelingOption(
                                  emoji: '😐',
                                  label: 'Normal',
                                ),
                                const SizedBox(height: 20),
                                _buildFeelingOption(
                                  emoji: '😔',
                                  label: 'Bad',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeelingOption({required String emoji, required String label}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(30), // Increase padding for larger icons
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
          ),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 50), // Emoji size
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 18, // Slightly larger font size
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
