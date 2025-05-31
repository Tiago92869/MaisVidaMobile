import 'package:testtest/services/resource/resource_model.dart';
import 'package:testtest/services/resource/resource_service.dart';

class ResourceRepository {
  final ResourceService _resourceService = ResourceService();

  Future<List<Resource>> getResources(
    List<ResourceType> resourceTypes,
    int page,
    int size,
    String search,
  ) async {
    try {
      final ResourcePage resourcePage = await _resourceService.fetchResources(
        resourceTypes,
        page: page, // Pass page as a named parameter
        size: size, // Pass size as a named parameter
        search: search,
      );
      return resourcePage.content;
    } catch (e) {
      rethrow;
    }
  }

  Future<Resource> getResourceById(String id) async {
    try {
      return await _resourceService.fetchResourceById(id);
    } catch (e) {
      rethrow;
    }
  }
}
