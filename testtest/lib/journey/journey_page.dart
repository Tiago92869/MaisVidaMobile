import 'dart:math';
import 'dart:ui'; // For BackdropFilter
import 'package:flutter/material.dart';
import 'package:testtest/services/journey/journey_service.dart';
import 'package:testtest/services/journey/journey_model.dart';
import 'journey_detail_page.dart';

class JourneyPage extends StatefulWidget {
  const JourneyPage({Key? key}) : super(key: key);

  @override
  _JourneyPageState createState() => _JourneyPageState();
}

class _JourneyPageState extends State<JourneyPage> {
  final JourneyService _journeyService = JourneyService();

  // State variables
  List<JourneySimpleUser> _journeys = [];
  bool _isLoading = false;

  final List<Color> _journeyColors = [
    const Color(0xFF9CC5FF),
    const Color(0xFF6E6AE8),
    const Color(0xFF005FE7),
    const Color(0xFFBBA6FF),
  ];

  @override
  void initState() {
    super.initState();
    _fetchJourneys();
  }

  Future<void> _fetchJourneys() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('Fetching user journeys...');
      final journeys = await _journeyService.getAllJourneys();
      print('Fetched ${journeys.length} journeys');
      setState(() {
        _journeys = journeys;
      });
    } catch (e) {
      print('Error fetching journeys: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to fetch journeys. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToJourneyDetails(String journeyId) async {
    try {
      print('Fetching details for journey: $journeyId');
      final journeyDetails = await _journeyService.getJourneyDetails(journeyId);

      print('Fetched journey details: ${journeyDetails.currentStep}');

      // Navigate to the JourneyDetailPage with the fetched details
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JourneyDetailPage(journey: journeyDetails),
        ),
      );

      // Refresh the journeys list when returning
      print('Returned from JourneyDetailPage, refreshing journeys');
      _fetchJourneys();
    } catch (e) {
      print('Error fetching journey details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to fetch journey details. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildJourneyCard(JourneySimpleUser journey, Color backgroundColor) {
    print('Building journey card for: ${journey.title}');
    final double progress = journey.completedQuantity / journey.resourceQuantity;
    final bool isComplete = progress >= 1.0;

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
            journey.title,
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
            journey.description,
            overflow: TextOverflow.ellipsis,
            maxLines: 3, // Limit the description to a maximum of 3 lines
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20), // Increased spacing before the progress bar
          Text(
            "${(progress * 100).toStringAsFixed(0)}% Completed",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5), // Small spacing between text and progress bar
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete ? Colors.yellow : Colors.blueAccent,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: isComplete
                    ? () {
                        print("Random message: ${Random().nextInt(100)}");
                      }
                    : null,
                child: Icon(
                  Icons.star,
                  color: isComplete ? Colors.yellow : Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const Spacer(),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                print(
                    '${journey.started ? "Continuing" : "Starting"} journey: ${journey.title}');
                await _navigateToJourneyDetails(journey.id);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: backgroundColor,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                journey.started ? "Continue" : "Start",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  "Journeys",
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: "Poppins",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: () async {
                        await _fetchJourneys(); // Refresh the list
                      },
                      child: _journeys.isEmpty
                          ? const Center(
                              child: Text(
                                "No journeys created",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: "Poppins",
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              itemCount: _journeys.length + 1, // Add 1 for the SizedBox
                              itemBuilder: (context, index) {
                                if (index < _journeys.length) {
                                  final journey = _journeys[index];
                                  final backgroundColor =
                                      _journeyColors[index % _journeyColors.length];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 20,
                                    ),
                                    child: _buildJourneyCard(
                                      journey,
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
        ],
      ),
    );
  }
}