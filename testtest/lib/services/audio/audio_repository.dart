import 'dart:io';
import 'audio_service.dart';
import 'audio_model.dart';

class AudioRepository {
  final AudioService _audioService = AudioService();

  Future<AudioFile> uploadAudio(File file) {
    return _audioService.uploadAudio(file);
  }

  Future<AudioInfoDTO> getAudioBase64(String id) {
    return _audioService.getAudioBase64(id);
  }

  Future<File?> downloadAudioFile(String id) {
    return _audioService.downloadAudioFile(id);
  }
}
