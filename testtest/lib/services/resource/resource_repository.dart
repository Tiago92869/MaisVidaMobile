import 'package:testtest/services/resource/resource_model.dart';
import 'package:testtest/services/resource/resource_service.dart';

class ResourceRepository {
  final ResourceService _resourceService = ResourceService();

  Future<List<Resource>> getResources(List<ResourceType> resourceTypes,
      int page, int size, String search) async {
    try {
      print(
          'ResourceRepository: Fetching resources with types: $resourceTypes, page: $page, size: $size, search: $search');
      final ResourcePage resourcePage = await _resourceService.fetchResources(
          resourceTypes, page, size, search);
      print('ResourceRepository: Successfully fetched resources.');
      return resourcePage.content;
    } catch (e) {
      print('ResourceRepository: Failed to fetch resources. Error: $e');
      rethrow;
    }
  }

  Future<Resource> getResourceById(String id) async {
    try {
      print('ResourceRepository: Fetching resource by ID: $id');
      final Resource resource = await _resourceService.fetchResourceById(id);
      print('ResourceRepository: Successfully fetched resource.');
      return resource;
    } catch (e) {
      print(
          'ResourceRepository: Failed to fetch resource by ID: $id. Error: $e');
      rethrow;
    }
  }
}
