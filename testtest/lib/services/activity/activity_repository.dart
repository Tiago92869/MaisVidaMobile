import 'package:testtest/services/activity/activity_service.dart';
import 'package:testtest/services/activity/activity_model.dart';

class ActivityRepository {
  final ActivityService _activityService = ActivityService();

  Future<List<Activity>> getActivitiesByUserId(
      int page, int size, String searchQuery) async {
    try {
      print('Fetching activities by user ID...');
      final activities =
          await _activityService.fetchActivities(page, size, searchQuery);
      print('Fetched ${activities.length} activities.');
      return activities;
    } catch (e) {
      print('Error fetching activities by user ID: $e');
      rethrow;
    }
  }

  Future<Activity> getActivityById(String id) async {
    try {
      print('Fetching activity with ID: $id...');
      final activity = await _activityService.fetchActivityById(id);
      print('Fetched activity: ${activity.toString()}');
      return activity;
    } catch (e) {
      print('Error fetching activity with ID $id: $e');
      rethrow;
    }
  }
}
