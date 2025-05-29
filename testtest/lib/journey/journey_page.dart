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
  List<Journey> _journeys = [];
  bool _isLoading = false;
  int _currentPage = 0;
  bool _isLastPage = false;

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

  Future<void> _fetchJourneys({bool loadNextPage = false}) async {
  if (_isLoading || (loadNextPage && _isLastPage)) return;

  setState(() {
    _isLoading = true;
  });

  try {
    print('Fetching journeys: page=$_currentPage, loadNextPage=$loadNextPage');
    final journeys = await _journeyService.getAllJourneys(
      _currentPage,
      10,
    );

    print('Fetched ${journeys.length} journeys');
    setState(() {
      if (loadNextPage) {
        _journeys.addAll(journeys); // Append new journeys
      } else {
        _journeys = journeys; // Replace journeys
      }
      _isLastPage = journeys.length < 10; // Check if it's the last page
      _currentPage++; // Increment page for next fetch
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

  void _onScroll(ScrollController controller) {
    if (controller.position.pixels >=
        controller.position.maxScrollExtent - 200) {
      _fetchJourneys(loadNextPage: true); // Fetch the next page
    }
  }

  Widget _buildJourneyCard(Journey journey, Color backgroundColor) {
  print('Building journey card for: ${journey.title}');
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
        const Spacer(),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              print('Navigating to JourneyDetailPage for: ${journey.title}');
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JourneyDetailPage(journey: journey),
                ),
              );

              // Refresh the journeys list when returning
              print('Returned from JourneyDetailPage, refreshing journeys');
              _fetchJourneys();
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: backgroundColor,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "View",
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
                      child: ListView.builder(
                        controller: _scrollController,
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