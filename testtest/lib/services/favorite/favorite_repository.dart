import 'package:testtest/services/activity/activity_model.dart';
import 'package:testtest/services/favorite/favorite_service.dart';
import 'package:testtest/services/favorite/favorite_model.dart';
import 'package:testtest/services/resource/resource_model.dart';

class FavoriteRepository {
  final FavoriteService _favoriteService = FavoriteService();

  Future<Favorite> getFavoriteByUserId() async {
    try {
      final favorite = await _favoriteService.fetchFavoriteByUserId();
      print('Successfully fetched favorite: $favorite');
      return favorite;
    } catch (e) {
      print('Error fetching favorite, Error: $e');
      rethrow;
    }
  }

  Future<void> updateFavorite(FavoriteInput favoriteInput, bool add) async {
    print('Updating favorite with input: $favoriteInput, add: $add');
    try {
      final favorite =
          await _favoriteService.modifyFavorite(favoriteInput, add);
      print('Successfully updated favorite');
    } catch (e) {
      print(
          'Error updating favorite with input: $favoriteInput, add: $add, Error: $e');
      rethrow;
    }
  }

  Future<bool> checkFavorite({String? resourceId, String? activityId}) async {
    print(
        'Checking favorite with resourceId: $resourceId, activityId: $activityId');
    try {
      final isFavorite = await _favoriteService.isFavorite(
          resourceId: resourceId, activityId: activityId);
      print(
          'Favorite status for resourceId: $resourceId, activityId: $activityId is $isFavorite');
      return isFavorite;
    } on BadRequestException catch (e) {
      print('Bad request error while checking favorite: $e');
      return false; // or handle as needed
    } catch (e) {
      print(
          'Error checking favorite with resourceId: $resourceId, activityId: $activityId, Error: $e');
      rethrow;
    }
  }

  Future<List<Resource>> getFavoriteResources() async {
  try {
    print('FavoriteRepository: Fetching favorite resources...');
    final resources = await _favoriteService.fetchFavoriteResources();
    print('FavoriteRepository: Successfully fetched favorite resources.');
    return resources;
  } catch (e) {
    print('FavoriteRepository: Failed to fetch favorite resources. Error: $e');
    rethrow;
  } 
}

Future<List<Activity>> getFavoriteActivities() async {
  try {
    print('FavoriteRepository: Fetching favorite activities...');
    final activities = await _favoriteService.fetchFavoriteActivities();
    print('FavoriteRepository: Successfully fetched favorite activities.');
    return activities;
  } catch (e) {
    print('FavoriteRepository: Failed to fetch favorite activities. Error: $e');
    rethrow;
  }
}
}
