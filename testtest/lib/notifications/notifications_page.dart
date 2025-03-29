import 'package:flutter/material.dart';
import 'notification_details_page.dart';

class Notification {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime lastUpdatedAt; // New field

  Notification({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.lastUpdatedAt, // Initialize the new field
  });
}

class NotificationsPage extends StatelessWidget {
  final List<Notification> notifications = [
    Notification(
      id: "1",
      title: "System Update",
      description: "A new system update is available. Please update your app.",
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      lastUpdatedAt: DateTime.now().subtract(const Duration(hours: 1)), // Example value
    ),
    Notification(
      id: "2",
      title: "Reminder",
      description: "Don't forget to complete your daily goals!",
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      lastUpdatedAt: DateTime.now().subtract(const Duration(hours: 20)), // Example value
    ),
    Notification(
      id: "3",
      title: "New Feature",
      description: "Check out the new SOS feature in the app.",
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      lastUpdatedAt: DateTime.now().subtract(const Duration(days: 2, hours: 5)), // Example value
    ),
  ];

  NotificationsPage({Key? key}) : super(key: key);

  void _navigateToNotificationDetail(BuildContext context, Notification notification) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationDetailsPage(notification: notification),
      ),
    );
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      "Notifications",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return GestureDetector(
                          onTap: () => _navigateToNotificationDetail(context, notification),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C3E50), // Darker blue for cards
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  notification.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "${notification.createdAt.hour.toString().padLeft(2, '0')}:${notification.createdAt.minute.toString().padLeft(2, '0')} - ${notification.createdAt.day.toString().padLeft(2, '0')}/${notification.createdAt.month.toString().padLeft(2, '0')}/${notification.createdAt.year}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}