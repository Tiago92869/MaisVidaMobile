import 'package:flutter/material.dart';
import 'dart:math'; // Import for randomization
import 'notifications_page.dart' as custom;

class NotificationDetailsPage extends StatefulWidget {
  final custom.Notification notification;

  const NotificationDetailsPage({
    Key? key,
    required this.notification,
  }) : super(key: key);

  @override
  _NotificationDetailsPageState createState() => _NotificationDetailsPageState();
}

class _NotificationDetailsPageState extends State<NotificationDetailsPage> {
  bool _showFirstStarfish = Random().nextBool(); // Randomly decide which starfish to show

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make Scaffold background transparent
        body: Stack(
          children: [
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
                    angle: 0.7, // Rotation angle in radians
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
                    angle: 0.5, // Rotation angle in radians
                    child: Image.asset(
                      'assets/images/starfish1.png',
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

                    // Title
                    Text(
                      widget.notification.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Description
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          widget.notification.description,
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

                    // Created and Last Updated Dates
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDateInfo("Created At", widget.notification.createdAt),
                        _buildDateInfo("Last Updated At", widget.notification.lastUpdatedAt),
                      ],
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

  Widget _buildDateInfo(String label, DateTime date) {
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
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}