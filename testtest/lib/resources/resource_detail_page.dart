import 'dart:math'; // Import for Random
import 'package:flutter/material.dart';
import 'package:testtest/services/resource/resource_model.dart';
import 'package:testtest/services/favorite/favorite_service.dart';
import 'package:testtest/services/favorite/favorite_model.dart';

class ResourceDetailPage extends StatefulWidget {
  final Resource resource;

  const ResourceDetailPage({Key? key, required this.resource})
    : super(key: key);

  @override
  _ResourceDetailPageState createState() => _ResourceDetailPageState();
}

class _ResourceDetailPageState extends State<ResourceDetailPage> {
  final FavoriteService _favoriteService = FavoriteService();

  bool _isFavorite = false;
  bool _initialFavoriteStatus = false; // Track the initial favorite status
  bool _showFirstStarfish =
      Random().nextBool(); // Randomly decide which starfish to show

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
              child: _buildResourceDetails(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceDetails() {
    final resource = widget.resource;

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
        Expanded(
          child: SingleChildScrollView(
            child: Text(
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
          ),
        ),
        const SizedBox(height: 20),

        // Created and Updated Dates
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDateInfo("Created At", resource.createdAt),
            _buildDateInfo("Updated At", resource.updatedAt),
          ],
        ),
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
