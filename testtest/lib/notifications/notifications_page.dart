import 'package:flutter/material.dart';
import 'package:testtest/services/notification/notification_service.dart';
import 'package:testtest/services/notification/notification_model.dart';
import 'notification_details_page.dart';
import 'dart:async';

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
  Timer? _pollingTimer;
  List<String> _seenNotificationIds = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _scrollController.addListener(_onScroll);
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkForNewNotifications();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkForNewNotifications() async {
    try {
      final notifications = await _notificationService.fetchNotifications(page: 0, size: 1);
      if (notifications.isNotEmpty) {
        final latest = notifications.first;
        if (!_seenNotificationIds.contains(latest.id)) {
          _seenNotificationIds.add(latest.id);
          _showPopup(latest.title, latest.description);
        }
      }
    } catch (e) {
      print("Polling error: $e");
    }
  }

  void _showPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchNotifications({bool isNextPage = false}) async {
    if (isNextPage && (!_hasMore || _isFetchingNextPage)) return;

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
      final notifications = await _notificationService.fetchNotifications(
        page: isNextPage ? _currentPage : 0,
        size: 10,
      );

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
    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels == 0 &&
          !_isFetchingNextPage &&
          !_isLoading) {
        // Scrolled to the top
        _refreshNotifications();
      } else if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isFetchingNextPage &&
          !_isLoading &&
          _hasMore) {
        // Scrolled to the bottom
        _fetchNotifications(isNextPage: true);
      }
    }
  }

  void _refreshNotifications() {
    setState(() {
      _currentPage = 0; // Reset to the first page
      _hasMore = true; // Allow fetching more pages
      _notifications.clear(); // Clear current notifications
    });
    _fetchNotifications(isNextPage: false); // Refresh notifications
  }

  void _navigateToNotificationDetail(
    BuildContext context,
    NotificationModel notification,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => NotificationDetailsPage(notification: notification),
      ),
    );
  }

  void _onNotificationTap(NotificationModel notification) async {
    if (!notification.read) {
      try {
        final updatedNotification =
            await _notificationService.markAsRead(notification.id);
        setState(() {
          final index = _notifications.indexWhere((n) => n.id == notification.id);
          if (index != -1) {
            _notifications[index] = updatedNotification;
          }
        });
      } catch (e) {
        print("Error marking notification as read: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to mark notification as read."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    _navigateToNotificationDetail(context, notification);
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
                    Color.fromRGBO(
                      123,
                      144,
                      255,
                      1,
                    ), // End color (lighter blue)
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
                      onRefresh: () async {
                        setState(() {
                          _currentPage = 0; // Reset to the first page
                          _hasMore = true; // Allow fetching more pages
                        });
                        await _fetchNotifications(isNextPage: false);
                      },
                      child:
                          _isLoading
                              ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                              : ListView.builder(
                                controller: _scrollController,
                                itemCount:
                                    _notifications.length +
                                    (_isFetchingNextPage ? 1 : 0),
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
                                    onTap: () => _onNotificationTap(notification),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: notification.read
                                            ? const Color(0xFF2C3E50) // Darker blue for read
                                            : const Color(0xFF34495E), // Slightly lighter for unread
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Title with one line
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  notification.title,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              if (!notification.read)
                                                const Icon(
                                                  Icons.circle,
                                                  color: Color.fromRGBO(
                                                      123, 144, 255, 1), // Match background color
                                                  size: 14, // Slightly larger size
                                                ), // Identifier for unread
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          // Description with one line
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
                                          // Date and time
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
