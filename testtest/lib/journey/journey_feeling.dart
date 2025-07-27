import 'package:flutter/material.dart';
// Import for Random
import 'package:mentara/services/journey/journey_model.dart'; // Import for UserJourneyResourceProgress
import 'package:mentara/resources/resource_detail_page.dart';
import 'package:mentara/services/resource/resource_service.dart';
import 'package:mentara/services/journey/journey_service.dart';
import 'package:mentara/services/image/image_service.dart'; // Import for ImageService
import 'dart:convert'; // Import for base64Decode

class JourneyFeelingPage extends StatefulWidget {
  final UserJourneyResourceProgress resourceProgress;

  const JourneyFeelingPage({Key? key, required this.resourceProgress}) : super(key: key);

  @override
  _JourneyFeelingPageState createState() => _JourneyFeelingPageState();
}

class _JourneyFeelingPageState extends State<JourneyFeelingPage> {
  final ResourceService _resourceService = ResourceService();
  final JourneyService _journeyService = JourneyService();
  final ImageService _imageService = ImageService();

  String? _selectedFeeling; // Track the selected feeling

  @override
  void initState() {
    super.initState();
    _initializeSelectedFeeling(); // Initialize the selected feeling
    _fetchRewardImage(); // Fetch the reward image
    if (!widget.resourceProgress.completed && widget.resourceProgress.rewardId != null) {
      _showRewardImage(widget.resourceProgress.rewardId!); // Show reward image only if not completed
    }
  }

  void _initializeSelectedFeeling() {
    if (widget.resourceProgress.feeling != null) {
      final String feeling = widget.resourceProgress.feeling!.toLowerCase();
      if (feeling == 'good') {
        _selectedFeeling = 'Good';
      } else if (feeling == 'normal') {
        _selectedFeeling = 'Normal';
      } else if (feeling == 'bad') {
        _selectedFeeling = 'Bad';
      }
    }
  }

  Future<void> _fetchRewardImage() async {
    if (widget.resourceProgress.rewardId != null) {
      try {
        // This function currently does nothing except call setState with no changes.
        // If you intend to fetch and store the image for later use, you should add logic here.
        setState(() {});
      } catch (e) {
        // Optionally handle errors here
      }
    }
  }

  Future<void> _showRewardImage(String rewardId) async {
    try {
      final base64Image = await _imageService.getImageBase64(rewardId);
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
                const SizedBox(height: 20),
                SizedBox(
                  width: 250,
                  height: 250,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao carregar a imagem do prémio.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size; // Get the screen size

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: screenSize.width,
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
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align the back arrow to the left
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Como você está se sentindo?',
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
                                _buildFeelingOption(label: 'Bem'),
                                const SizedBox(height: 20),
                                _buildFeelingOption(label: 'Normal'),
                                const SizedBox(height: 20),
                                _buildFeelingOption(label: 'Mal'),
                              ],
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton(
                              onPressed: () async {
                                if (widget.resourceProgress.completed) {
                                  final resource = await _resourceService.fetchResourceById(
                                    widget.resourceProgress.resourceId!,
                                  );
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ResourceDetailPage(
                                        resource: resource,
                                        resourceProgressId: widget.resourceProgress.id, // Pass progress ID
                                        order: widget.resourceProgress.order,           // Pass order
                                      ),
                                    ),
                                  );
                                } else {
                                  await _handleContinue();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: const Color(0xFF0D1B2A),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Continuar',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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

  Widget _buildFeelingOption({required String label}) {
    final bool isSelected = _selectedFeeling == label;

    // Map labels to image paths
    final Map<String, String> imagePaths = {
      'Bem': 'assets/images/bem.png',
      'Normal': 'assets/images/normal.png',
      'Mal': 'assets/images/muito mau.png',
    };

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFeeling = label; // Update the selected feeling
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8), // Padding inside the circle
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? const Color.fromARGB(255, 255, 255, 255).withOpacity(0.9) // Slightly darker gray when selected
                  : Colors.grey.withOpacity(0.4), // Lighter gray when not selected
            ),
            child: Image.asset(
              imagePaths[label]!,
              width: 120, // Adjust image size
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 18, // Slightly larger font size
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (_selectedFeeling == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione um sentimento antes de continuar.')),
        );
      }
      return;
    }

    try {
      // Fetch the resource by its ID
      final resource = await _resourceService.fetchResourceById(widget.resourceProgress.resourceId!);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResourceDetailPage(
            resource: resource,
            resourceProgressId: widget.resourceProgress.id, // Pass progress ID
            order: widget.resourceProgress.order,           // Pass order
          ),
        ),
      );

      final updateProgress = UpdateUserJourneyResourceProgress(
        order: widget.resourceProgress.order,
        feeling: _selectedFeeling?.toUpperCase(),
        completed: true,
        unlocked: true,
      );

      await _journeyService.editUserJourneyProgress(
        widget.resourceProgress.id,
        updateProgress,
      );

      // Show reward image if available
      if (widget.resourceProgress.rewardId != null) {
        await _showRewardImage(widget.resourceProgress.rewardId!);
      }

      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao prosseguir. Tente novamente.')),
        );
      }
    }
  }
}
