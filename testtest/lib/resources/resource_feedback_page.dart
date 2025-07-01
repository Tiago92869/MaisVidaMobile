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
        const SnackBar(content: Text('Selecione uma classificação antes de guardar.')),
      );
      return;
    }

    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID de utilizador não encontrado. Efetue novamente o login.')),
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

      // Close all pages until the JourneyDetailPage
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao enviar feedback.')),
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
                              'Quão útil foi este recurso?',
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
                                  label: 'Útil',
                                  rating: feedback_model.UsefulnessRating.USEFUL,
                                ),
                                const SizedBox(height: 20),
                                _buildRatingIcon(
                                  label: 'Indiferente',
                                  rating: feedback_model.UsefulnessRating.INDIFFERENT,
                                ),
                                const SizedBox(height: 20),
                                _buildRatingIcon(
                                  label: 'Não é útil',
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
                                      'Guardar',
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

  Widget _buildRatingIcon({
    required String label,
    required feedback_model.UsefulnessRating rating,
  }) {
    final isSelected = _selectedRating == rating;

    // Map labels to image paths
    final Map<String, String> imagePaths = {
      'Útil': 'assets/images/bem.png',
      'Indiferente': 'assets/images/normal.png',
      'Não é útil': 'assets/images/muito mau.png',
    };

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRating = rating;
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8), // Increase padding for larger images
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? const Color.fromARGB(255, 255, 255, 255).withOpacity(0.9) : Colors.white.withOpacity(0.2),
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
              color: isSelected ? Colors.white : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
