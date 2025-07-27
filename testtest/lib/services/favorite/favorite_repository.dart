import 'package:mentara/services/activity/activity_model.dart';
import 'package:mentara/services/favorite/favorite_service.dart';
import 'package:mentara/services/favorite/favorite_model.dart';
import 'package:mentara/services/resource/resource_model.dart';

class FavoriteRepository {
  final FavoriteService _favoriteService = FavoriteService();

  Future<Favorite> getFavoriteByUserId() async {
    try {
      final favorite = await _favoriteService.fetchFavoriteByUserId();
      return favorite;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateFavorite(FavoriteInput favoriteInput, bool add) async {
    try {
      await _favoriteService.modifyFavorite(favoriteInput, add);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkFavorite({String? resourceId, String? activityId}) async {
    try {
      final isFavorite = await _favoriteService.isFavorite(
          resourceId: resourceId, activityId: activityId);
      return isFavorite;
    } catch (e) {
      return false;
    }
  }

  Future<List<Resource>> getFavoriteResources() async {
    try {
      final resources = await _favoriteService.fetchFavoriteResources();
      return resources;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Activity>> getFavoriteActivities() async {
    try {
      final activities = await _favoriteService.fetchFavoriteActivities();
      return activities;
    } catch (e) {
      rethrow;
    }
  }
}
