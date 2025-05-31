import 'dart:convert';
import 'dart:io';
import 'dart:math'; // Import for Random
import 'package:flutter/material.dart';
import 'package:testtest/services/resource/resource_model.dart';
import 'package:testtest/services/favorite/favorite_service.dart';
import 'package:testtest/services/favorite/favorite_model.dart';
import 'package:testtest/resources/resource_feedback_page.dart';
import 'package:testtest/services/image/image_service.dart';

class ResourceDetailPage extends StatefulWidget {
  final Resource resource;

  const ResourceDetailPage({Key? key, required this.resource})
    : super(key: key);

  @override
  _ResourceDetailPageState createState() => _ResourceDetailPageState();
}

class _ResourceDetailPageState extends State<ResourceDetailPage> {
  final FavoriteService _favoriteService = FavoriteService();
  final ImageService _imageService = ImageService();

  bool _isFavorite = false;
  bool _initialFavoriteStatus = false; // Track the initial favorite status
  bool _showFirstStarfish =
      Random().nextBool(); // Randomly decide which starfish to show

  // Cache for Base64 images
  final Map<String, String> _imageCache = {};

  @override
  void initState() {
    super.initState();
    _checkIfFavorite(); // Check if the resource is a favorite when the page loads
  }

  Future<void> _checkIfFavorite() async {
    try {
      final isFavorite = await _favoriteService.isFavorite(
        resourceId: widget.resource.id,
      );
      setState(() {
        _isFavorite = isFavorite;
        _initialFavoriteStatus =
            isFavorite; // Store the initial favorite status
      });
    } catch (e) {
      print('Error checking favorite status: $e');
    }
  }

  Future<void> _toggleFavoriteStatus() async {
    setState(() {
      _isFavorite = !_isFavorite; // Toggle the favorite status locally
    });

    try {
      final favoriteInput = FavoriteInput(
        activities: [],
        resources: [widget.resource.id], // Pass the resource ID
      );

      // Call modifyFavorite with the appropriate `add` value
      await _favoriteService.modifyFavorite(favoriteInput, _isFavorite);
      print(
        _isFavorite
            ? 'Resource added to favorites.'
            : 'Resource removed from favorites.',
      );
    } catch (e) {
      print('Error updating favorite status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update favorite status.')),
      );

      // Revert the favorite status if the request fails
      setState(() {
        _isFavorite = !_isFavorite;
      });
    }
  }

  Future<String> _getCachedImageBase64(String contentId) async {
    if (_imageCache.containsKey(contentId)) {
      // Return cached image if available
      return _imageCache[contentId]!;
    }

    // Fetch the image and cache it
    final base64Image = await _imageService.getImageBase64(contentId);
    _imageCache[contentId] = base64Image;
    return base64Image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildResourceDetails(),
                            const Spacer(), // Push the following widgets to the bottom
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildDateInfo("Created At", widget.resource.createdAt),
                                _buildDateInfo("Updated At", widget.resource.updatedAt),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ResourceFeedbackPage(
                                        resourceId: widget.resource.id,
                                      ),
                                    ),
                                  );
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
        },
      ),
    );
  }

  Widget _buildResourceDetails() {
    final resource = widget.resource;

    // Sort contents by ascending order
    final sortedContents = List.of(resource.contents)
      ..sort((a, b) => a.order.compareTo(b.order));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 20),

        // Title and Favorite Icon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                resource.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
                  color: Colors.white,
                ),
              ),
            ),
            GestureDetector(
              onTap: _toggleFavoriteStatus, // Toggle the favorite status
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 300,
                ), // Smooth transition for color change
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isFavorite ? Colors.yellow : Colors.transparent,
                  border: Border.all(color: Colors.yellow, width: 2),
                ),
                child: Icon(
                  _isFavorite ? Icons.star : Icons.star_border,
                  color: _isFavorite ? Colors.white : Colors.yellow,
                  size: 28, // Adjust size if needed
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Resource Type
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            resource.type.toString().split('.').last,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 40),

        // Description
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                resource.description.isNotEmpty
                    ? resource.description
                    : "No description available.", // Fallback if description is empty
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: "Inter",
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40), // Increased distance before first content

              // Separator Line
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7, // 70% of the screen width
                  height: 1, // Line height
                  color: Colors.white, // Line color
                ),
              ),
              const SizedBox(height: 40), // Space after the line

              // Display contents
              for (final content in sortedContents) ...[
                if (content.type.toLowerCase() == 'text') ...[
                  Center(
                    child: Text(
                      content.contentValue,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: "Inter",
                        color: Colors.white,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ] else if (content.type.toLowerCase() == 'image') ...[
                  FutureBuilder(
                    future: _getCachedImageBase64(content.contentId),
                    builder: (context, snapshot) {
                      print('Fetching Base64 image with ID: ${content.contentId}');
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        print('Base64 image fetch in progress...');
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        print('Error fetching Base64 image: ${snapshot.error}');
                        return const Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.red),
                        );
                      } else if (snapshot.hasData) {
                        final base64Image = snapshot.data as String;
                        print('Base64 image fetched successfully.');
                        return Center(
                          child: SizedBox(
                            width: 150,
                            height: 150,
                            child: Image.memory(
                              base64Decode(base64Image),
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      } else {
                        print('Unexpected state: No data and no error.');
                        return const Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.red),
                        );
                      }
                    },
                  ),
                ],
                const SizedBox(height: 30), // Increased distance between contents
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDateInfo(String label, DateTime? date) {
    if (date == null) return const SizedBox.shrink();

    final formattedDate =
        "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formattedDate,
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
      ],
    );
  }
}
