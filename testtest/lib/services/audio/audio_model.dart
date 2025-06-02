class AudioFile {
  final String id;
  final String filename;
  final String extension;
  final DateTime uploadDate;

  AudioFile({
    required this.id,
    required this.filename,
    required this.extension,
    required this.uploadDate,
  });

  factory AudioFile.fromJson(Map<String, dynamic> json) {
    return AudioFile(
      id: json['id'],
      filename: json['filename'],
      extension: json['extension'],
      uploadDate: DateTime.parse(json['uploadDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'extension': extension,
      'uploadDate': uploadDate.toIso8601String(),
    };
  }
}

class AudioInfoDTO {
  final String id;
  final String data;

  AudioInfoDTO({
    required this.id,
    required this.data,
  });

  factory AudioInfoDTO.fromJson(Map<String, dynamic> json) {
    return AudioInfoDTO(
      id: json['id'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
    };
  }
}
