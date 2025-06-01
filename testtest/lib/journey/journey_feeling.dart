import 'package:flutter/material.dart';
import 'dart:math'; // Import for Random
import 'package:testtest/services/journey/journey_model.dart'; // Import for UserJourneyResourceProgress
import 'package:testtest/resources/resource_detail_page.dart';
import 'package:testtest/services/resource/resource_service.dart';
import 'package:testtest/services/journey/journey_service.dart';
import 'package:testtest/services/image/image_service.dart'; // Import for ImageService
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

  bool _showFirstStarfish = Random().nextBool(); // Randomly decide which starfish to show
  String? _selectedFeeling; // Track the selected feeling
  String? _rewardImageBase64; // Cache for the reward image

  @override
  void initState() {
    super.initState();
    _initializeSelectedFeeling(); // Initialize the selected feeling
    _fetchRewardImage(); // Fetch the reward image
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
    if (widget.resourceProgress.rewardId == null) {
      try {
        //final base64Image = await _imageService.getImageBase64(widget.resourceProgress.rewardId!);
        final base64Image = await _imageService.getImageBase64("e9c1060a-69da-45aa-b399-6d474ffb0935");
        setState(() {
          _rewardImageBase64 = base64Image;
        });
      } catch (e) {
        print('Error fetching reward image: $e');
      }
    }
  }

  void _showRewardPopup() {
    if (_rewardImageBase64 != null) {
      showDialog(
        context: context,
        barrierColor: const Color(0xFF0D1B2A).withOpacity(0.7), // Semi-transparent background
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.transparent, // Transparent background for the dialog
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: Text(
                    "Prize After Completing This Day",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White title color
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Image.memory(
                    base64Decode(_rewardImageBase64!),
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void _showInfoMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "This day has been completed. You can view it again, but changes will not be saved.",
        ),
        duration: const Duration(seconds: 5), // Automatically close after 5 seconds
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

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
                    crossAxisAlignment: CrossAxisAlignment.start, // Align the back arrow to the left
                    children: [
                      // Top Row with Back Icon, Info Icon, and Trophy Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                          ),
                          Row(
                            children: [
                              if (_rewardImageBase64 != null && widget.resourceProgress.completed != true)
                                GestureDetector(
                                  onTap: _showRewardPopup, // Show the reward popup when tapped
                                  child: const Icon(Icons.emoji_events, color: Colors.white, size: 28), // Trophy icon
                                ),
                              const SizedBox(width: 10),
                              if (widget.resourceProgress.completed)
                                GestureDetector(
                                  onTap: _showInfoMessage, // Show the info message when tapped
                                  child: const Icon(Icons.info, color: Colors.white, size: 28),
                                ),
                            ],
                          ),
                        ],
                      ),
                      Expanded(
                        child: Center( // Center the rest of the content
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center, // Vertically center elements
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
                              const SizedBox(height: 40),
                              ElevatedButton(
                                onPressed: () async {
                                  if (widget.resourceProgress.completed) {
                                    // Skip updating progress if already completed
                                    /*
                                    final resource = await _resourceService.fetchResourceById(
                                      widget.resourceProgress.resourceId!,
                                    );
                                    */
                                    
      final resource = await _resourceService.fetchResourceById("dd2c5a72-f4aa-487b-a93d-6c2697c280d9");
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ResourceDetailPage(resource: resource),
                                      ),
                                    );
                                  } else {
                                    await _handleContinue(); // Call the update method if not completed
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
                                  'Continue',
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeelingOption({required String emoji, required String label}) {
    final bool isSelected = _selectedFeeling == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFeeling = label; // Update the selected feeling
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(30), // Increase padding for larger icons
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? Colors.white.withOpacity(0.8) // 30% transparent when selected
                  : Colors.white.withOpacity(0.2),
            ),
            child: Text(
              emoji,
              style: TextStyle(
                fontSize: 50, // Emoji size
                color: isSelected ? Colors.black : Colors.white,
              ),
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
          const SnackBar(content: Text('Please select a feeling before continuing.')),
        );
      }
      return;
    }

    try {
      // Fetch the resource by its ID
      //final resource = await _resourceService.fetchResourceById(widget.resourceProgress.resourceId!);
      final resource = await _resourceService.fetchResourceById("dd2c5a72-f4aa-487b-a93d-6c2697c280d9");

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResourceDetailPage(resource: resource),
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

      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      print('Error handling continue: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to proceed. Please try again.')),
        );
      }
    }
  }
}
