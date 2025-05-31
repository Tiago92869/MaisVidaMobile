import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:testtest/services/video/video_model.dart';
import 'package:testtest/services/video/video_service.dart';

class VideoRepository {
  final VideoService _videoService = VideoService();

  Future<VideoFile> uploadVideo(File file) async {
    try {
      return await _videoService.uploadVideo(file);
    } catch (e) {
      print('VideoRepository: Failed to upload video. Error: $e');
      rethrow;
    }
  }

  Future<VideoInfoDTO> getVideoBase64(String id) async {
    try {
      return await _videoService.getVideoBase64(id);
    } catch (e) {
      print('VideoRepository: Failed to fetch video Base64. Error: $e');
      rethrow;
    }
  }

  Future<http.StreamedResponse> streamVideo(String id) async {
    try {
      return await _videoService.streamVideo(id);
    } catch (e) {
      print('VideoRepository: Failed to stream video. Error: $e');
      rethrow;
    }
  }

  Future<File?> downloadVideoFile(String id) async {
    try {
      return await _videoService.downloadVideoFile(id);
    } catch (e) {
      print('VideoRepository: Failed to download video file. Error: $e');
      return null;
    }
  }
}
