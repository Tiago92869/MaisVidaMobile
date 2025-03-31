import 'package:flutter/material.dart';
import 'package:testtest/services/notification/notification_service.dart';
import 'package:testtest/services/notification/notification_model.dart';
import 'notification_details_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationService _notificationService = NotificationService();
  final ScrollController _scrollController = ScrollController();

  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  bool _isFetchingNextPage = false;
  int _currentPage = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();

    _notifications = [
      NotificationModel(
        id: "1",
        title: "System Update",
        description: "A new system update is available. Please update your app.",
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      NotificationModel(
        id: "2",
        title: "New Feature Released",
        description: "Check out the new feature in the app settings.",
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 10)),
      ),
      NotificationModel(
        id: "3",
        title: "Scheduled Maintenance",
        description: "The app will undergo maintenance on Sunday at 2 AM.",
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 15)),
      ),
      NotificationModel(
        id: "4",
        title: "Welcome to the App",
        description: "Thank you for joining us! Explore the app to get started.",
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      NotificationModel(
        id: "1",
        title: "System Update",
        description: "A new system update is available. Please update your app.",
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      NotificationModel(
        id: "2",
        title: "New Feature Released",
        description: "Check out the new feature in the app settings.",
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 10)),
      ),
      NotificationModel(
        id: "3",
        title: "Scheduled Maintenance",
        description: "The app will undergo maintenance on Sunday at 2 AM.",
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 15)),
      ),
      NotificationModel(
        id: "4",
        title: "Welcome to the App",
        description: "Thank you for joining us! Explore the app to get started.",
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];

    _fetchNotifications();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchNotifications({bool isNextPage = false}) async {
    if (isNextPage) {
      setState(() {
        _isFetchingNextPage = true;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Fetch notifications from the NotificationService
      final notifications = await _notificationService.fetchNotifications(page: _currentPage, size: 10);
      setState(() {
        if (isNextPage) {
          _notifications.addAll(notifications); // Append new notifications
        } else {
          _notifications = notifications; // Replace notifications on refresh
        }

        // Check if there are more notifications to load
        _hasMore = notifications.isNotEmpty;
        if (_hasMore) {
          _currentPage++;
        }
      });
    } catch (e) {
      print("Error fetching notifications: $e");

      // Show error message using SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to fetch notifications. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _isFetchingNextPage = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent &&
        !_isFetchingNextPage &&
        !_isLoading &&
        _hasMore) {
      _fetchNotifications(isNextPage: true); // Fetch the next page when reaching the bottom
    }
  }

  void _navigateToNotificationDetail(BuildContext context, NotificationModel notification) {
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
                    child: RefreshIndicator(
                      onRefresh: () => _fetchNotifications(isNextPage: false), // Refresh notifications
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              itemCount: _notifications.length + (_isFetchingNextPage ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _notifications.length) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }

                                final notification = _notifications[index];
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