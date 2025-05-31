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
    final journeyDetails = journey.journey;

    // Sort resources by order in ascending order
    final sortedResources = journey.resourceProgressList
      ..sort((a, b) => a.order.compareTo(b.order));

    final completedCount = sortedResources.where((resource) => resource.completed).length;
    final totalCount = sortedResources.length;
    final progress = completedCount / totalCount;
    final isComplete = progress == 1.0;

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
          // Content
          SafeArea(
            child: Column(
              children: [
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
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
                          journeyDetails.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Description
                        Text(
                          journeyDetails.description,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: "Inter",
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Progress bar with star icon
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
                        const SizedBox(height: 10),
                        Text(
                          "${(progress * 100).toStringAsFixed(0)}% Completed",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Resource progress grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5, // 5 squares per line
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: sortedResources.length,
                          itemBuilder: (context, index) {
                            final resource = sortedResources[index];
                            final isLastSquare =
                                resource == sortedResources.last;

                            return GestureDetector(
                              onTap: resource.unlocked
                                  ? () {
                                      print(
                                          'Square pressed for resource order: ${resource.order}');
                                    }
                                  : null,
                              child: Stack(
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isLastSquare
                                            ? Colors.yellow
                                            : Colors.white.withOpacity(0.5),
                                        width: 2,
                                      ),
                                    ),
                                    child: Text(
                                      resource.order.toString(),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: resource.unlocked
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                  ),
                                  if (resource.completed)
                                    const Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.greenAccent,
                                        size: 20,
                                      ),
                                    )
                                  else if (!resource.unlocked)
                                    const Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Icon(
                                        Icons.lock,
                                        color: Colors.redAccent,
                                        size: 20,
                                      ),
                                    ),
                                  if (isLastSquare)
                                    const Positioned(
                                      top: 0,
                                      left: 0,
                                      child: Icon(
                                        Icons.star,
                                        color: Colors.yellow,
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Fixed footer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Created At: ${journeyDetails.createdAt?.toLocal().toString().split(' ')[0] ?? 'N/A'}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        "Resources: ${journeyDetails.resourceQuantity}",
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