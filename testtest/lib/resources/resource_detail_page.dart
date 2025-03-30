import 'package:flutter/material.dart';
import 'package:testtest/services/resource/resource_model.dart';
import 'package:testtest/services/favorite/favorite_service.dart';
import 'package:testtest/services/favorite/favorite_model.dart';

class ResourceDetailPage extends StatefulWidget {
  final Resource resource;

  const ResourceDetailPage({Key? key, required this.resource}) : super(key: key);

  @override
  _ResourceDetailPageState createState() => _ResourceDetailPageState();
}

class _ResourceDetailPageState extends State<ResourceDetailPage> {
  final FavoriteService _favoriteService = FavoriteService();

  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
  try {
    final isFavorite = await _favoriteService.isFavorite(resourceId: widget.resource.id);
    setState(() {
      _isFavorite = isFavorite;
    });
  } catch (e) {
    print('Error checking favorite status: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Failed to check favorite status. Please try again."),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  Future<void> _toggleFavorite() async {
    try {
      final favoriteInput = FavoriteInput(
        activities: [],
        resources: [widget.resource.id],
      );

      await _favoriteService.modifyFavorite(favoriteInput, !_isFavorite);

      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (e) {
      print('Error updating favorite status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update favorite status.')),
      );
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
                  colors: [
                    Color.fromRGBO(72, 85, 204, 1), // Start color (darker blue)
                    Color.fromRGBO(123, 144, 255, 1), // End color (lighter blue)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 28,
          ),
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
              onTap: _toggleFavorite,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isFavorite ? Colors.yellow : Colors.transparent,
                  border: Border.all(color: Colors.yellow, width: 2),
                ),
                child: Icon(
                  _isFavorite ? Icons.star : Icons.star_border,
                  color: _isFavorite ? Colors.white : Colors.yellow,
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
        const SizedBox(height: 20),

        // Description
        Expanded(
          child: SingleChildScrollView(
            child: Text(
              resource.description,
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

    final formattedDate = "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
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
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}