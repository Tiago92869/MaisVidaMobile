import 'package:flutter/material.dart';
import 'package:testtest/menu/models/courses.dart'; // Import ResourceType for type

class ResourceDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final ResourceType type;
  final DateTime createdAt;
  final DateTime updatedAt;

  static final Set<String> favoriteResources = {}; // Track favorite resources

  const ResourceDetailPage({
    Key? key,
    required this.title,
    required this.description,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isFavorite = favoriteResources.contains(title);

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
          Positioned(
            right: 80,
            top: 320,
            width: 400,
            height: 400,
            child: Opacity(
              opacity: 0.1,
              child: Transform.rotate(
                angle: 0.7, // Rotation angle in radians (e.g., 0.5 radians ≈ 28.65 degrees)
                child: Image.asset(
                  'assets/images/starfish2.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
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

                  // Title and Favorite Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                            color: Colors.white,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (isFavorite) {
                            favoriteResources.remove(title);
                          } else {
                            favoriteResources.add(title);
                          }
                          (context as Element).markNeedsBuild(); // Rebuild widget
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isFavorite ? Colors.yellow : Colors.transparent,
                            border: Border.all(color: Colors.yellow, width: 2),
                          ),
                          child: Icon(
                            isFavorite ? Icons.star : Icons.star_border,
                            color: isFavorite ? Colors.white : Colors.yellow,
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
                      type.toString().split('.').last.capitalizeFirstLetter(),
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
                        description,
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
                      _buildDateInfo("Created At", createdAt),
                      _buildDateInfo("Updated At", updatedAt),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo(String label, DateTime date) {
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

// Extension to capitalize the first letter of a string
extension StringCapitalization on String {
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}