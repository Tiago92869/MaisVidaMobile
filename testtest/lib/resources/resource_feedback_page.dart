import 'package:flutter/material.dart';
import 'dart:math'; // Import for Random
import 'package:testtest/services/feedback/feedback_model.dart' as feedback_model;
import 'package:testtest/services/feedback/feedback_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ResourceFeedbackPage extends StatefulWidget {
  final String resourceId;

  const ResourceFeedbackPage({Key? key, required this.resourceId})
      : super(key: key);

  @override
  _ResourceFeedbackPageState createState() => _ResourceFeedbackPageState();
}

class _ResourceFeedbackPageState extends State<ResourceFeedbackPage> {
  feedback_model.UsefulnessRating? _selectedRating;
  final FeedbackService _feedbackService = FeedbackService();
  final _storage = const FlutterSecureStorage();
  bool _isSubmitting = false;
  String? _feedbackId;
  String? _userId;
  bool _showFirstStarfish = Random().nextBool(); // Randomly decide which starfish to show

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadExistingFeedback();
  }

  Future<void> _loadUserId() async {
    _userId = await _storage.read(key: 'userId');
  }

  Future<void> _loadExistingFeedback() async {
    try {
      final feedback = await _feedbackService.getFeedbackByResource(widget.resourceId);
      setState(() {
        _selectedRating = feedback.usefulnessRating;
        _feedbackId = feedback.id;
      });
    } catch (e) {
      print('No existing feedback found or error occurred: $e');
    }
  }

  Future<void> _submitFeedback() async {
    if (_selectedRating == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating before saving.')),
      );
      return;
    }

    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found. Please log in again.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final feedback = feedback_model.Feedback(
        id: _feedbackId ?? '',
        userId: _userId!,
        resourceId: widget.resourceId,
        usefulnessRating: _selectedRating!,
      );

      if (_feedbackId == null) {
        await _feedbackService.createFeedback(feedback);
      } else {
        await _feedbackService.updateFeedback(feedback);
      }

      // Navigate back two pages
      Navigator.pop(context); // Close ResourceFeedbackPage
      Navigator.pop(context); // Close ResourceDetailPage
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit feedback.')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size; // Get the screen size

    return Scaffold(
      body: SizedBox(
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
                            'How useful was this resource?',
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
                              _buildRatingIcon(
                                icon: Icons.thumb_up,
                                label: 'Useful',
                                rating: feedback_model.UsefulnessRating.USEFUL,
                              ),
                              const SizedBox(height: 20),
                              _buildRatingIcon(
                                icon: Icons.thumbs_up_down,
                                label: 'Indifferent',
                                rating: feedback_model.UsefulnessRating.INDIFFERENT,
                              ),
                              const SizedBox(height: 20),
                              _buildRatingIcon(
                                icon: Icons.thumb_down,
                                label: 'Not Useful',
                                rating: feedback_model.UsefulnessRating.NOT_USEFUL,
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitFeedback,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: const Color(0xFF0D1B2A),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSubmitting
                                ? const CircularProgressIndicator(
                                    color: Color(0xFF0D1B2A),
                                  )
                                : const Text(
                                    'Save',
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
    );
  }

  Widget _buildRatingIcon({
    required IconData icon,
    required String label,
    required feedback_model.UsefulnessRating rating,
  }) {
    final isSelected = _selectedRating == rating;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRating = rating;
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(30), // Increase padding for larger icons
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.yellow : Colors.white.withOpacity(0.2),
            ),
            child: Icon(
              icon,
              size: 50, // Increase icon size
              color: isSelected ? Colors.black : Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 18, // Slightly larger font size
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.yellow : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
