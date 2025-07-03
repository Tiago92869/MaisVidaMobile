import 'package:flutter/material.dart';
import 'package:testtest/services/journey/journey_model.dart';
import 'dart:math';
import 'package:testtest/journey/journey_feeling.dart'; // Import JourneyFeelingPage
import 'package:testtest/services/image/image_service.dart';
import 'dart:convert';
import 'dart:ui'; // For BackdropFilter

class JourneyDetailPage extends StatefulWidget {
  final UserJourneyProgress journey;
  final bool isNewJourney; // Flag to indicate if this is a newly started journey

  const JourneyDetailPage({Key? key, required this.journey, required this.isNewJourney}) : super(key: key);

  @override
  _JourneyDetailPageState createState() => _JourneyDetailPageState();
}

class _JourneyDetailPageState extends State<JourneyDetailPage> {
  final ImageService _imageService = ImageService();
  bool _showWelcomePopup = false; // State variable to show the popup

  @override
  void initState() {
    super.initState();
    _showWelcomePopup = widget.isNewJourney; // Show popup only for new journeys
  }

  Future<void> _showPrizeImage(String imageId) async {
    try {
      final base64Image = await _imageService.getImageBase64(imageId);
      showDialog(
        context: context,
        barrierColor: const Color(0xFF0D1B2A).withOpacity(0.7), // Semi-transparent background
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.transparent, // Transparent background for the dialog
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Prémio após a conclusão",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White title color
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Image.memory(
                    base64Decode(base64Image),
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print('Error fetching prize image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao carregar a imagem do prémio.')),
      );
    }
  }

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
                // Top bar with prize icon
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      ),
                      if (widget.journey.journey.rewardImage != null)
                        GestureDetector(
                          onTap: () => _showPrizeImage(widget.journey.journey.rewardImage!),
                          child: const Icon(Icons.emoji_events, color: Colors.white, size: 28), // Trophy icon
                        ),
                    ],
                  ),
                ),
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          "${(progress * 100).toStringAsFixed(0)}% Concluído",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Add day labels
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const [
                            Text("S", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text("T", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text("Q", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text("Q", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text("S", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text("S", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text("D", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Resource progress grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7, // 7 squares per line
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
                                      print('Navigating to JourneyFeelingPage for resource order: ${resource.order}');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => JourneyFeelingPage(
                                            resourceProgress: resource, // Pass the resource progress
                                          ),
                                        ),
                                      );
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
                                        fontSize: 16,
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
                                        size: 16,
                                      ),
                                    )
                                  else if (!resource.unlocked)
                                    const Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Icon(
                                        Icons.lock,
                                        color: Colors.redAccent,
                                        size: 16,
                                      ),
                                    ),
                                  if (isLastSquare)
                                    const Positioned(
                                      top: 0,
                                      left: 0,
                                      child: Icon(
                                        Icons.star,
                                        color: Colors.yellow,
                                        size: 16,
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
              ],
            ),
          ),
          if (_showWelcomePopup)
            Stack(
              children: [
                // Blurred background
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
                    ),
                  ),
                ),
                // Popup box
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B263B), // Match page background color
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/genial.png', // Add the image
                          width: 250, // Adjust width as needed
                          height: 250, // Adjust height as needed
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Olá, o meu nome é TIVA!",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // White text color
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Durante os próximos 28 dias, estarei aqui todos os dias para saber como se sente e propor uma atividade que ajude a fortalecer a sua Saúde Mental Positiva.\n\nQuero acompanhá-la nesta jornada e crescer consigo. Está pronta para começar?",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70, // Slightly transparent text
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showWelcomePopup = false; // Close the popup
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, // White button background
                            foregroundColor: const Color(0xFF1B263B), // Transparent font color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "SIM",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}