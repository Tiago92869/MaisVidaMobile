import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mentara/services/video/video_model.dart';
import 'package:mentara/services/video/video_service.dart';

class VideoRepository {
  final VideoService _videoService = VideoService();

  Future<VideoFile> uploadVideo(File file) async {
    try {
      return await _videoService.uploadVideo(file);
    } catch (e) {
      rethrow;
    }
  }

  Future<VideoInfoDTO> getVideoBase64(String id) async {
    try {
      return await _videoService.getVideoBase64(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<http.StreamedResponse> streamVideo(String id) async {
    try {
      return await _videoService.streamVideo(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<File?> downloadVideoFile(String id) async {
    try {
      return await _videoService.downloadVideoFile(id);
    } catch (e) {
      return null;
    }
  }
}
