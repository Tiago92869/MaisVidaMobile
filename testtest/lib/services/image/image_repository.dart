import 'dart:io';
import 'package:mentara/services/image/image_model.dart';
import 'package:mentara/services/image/image_service.dart';

class ImageRepository {
  final ImageService _imageService = ImageService();

  Future<ImageFile> uploadImage(File file) async {
    try {
      return await _imageService.uploadImage(file);
    } catch (e) {
      print('ImageRepository: Failed to upload image. Error: $e');
      rethrow;
    }
  }

  Future<File> downloadImage(String id, String savePath) async {
    try {
      return await _imageService.downloadImage(id, savePath);
    } catch (e) {
      print('ImageRepository: Failed to download image. Error: $e');
      rethrow;
    }
  }
}
