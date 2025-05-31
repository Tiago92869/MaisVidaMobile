class VideoFile {
  final String id;
  final String filename;
  final String extension;
  final DateTime uploadDate;

  VideoFile({
    required this.id,
    required this.filename,
    required this.extension,
    required this.uploadDate,
  });

  factory VideoFile.fromJson(Map<String, dynamic> json) {
    return VideoFile(
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

class VideoInfoDTO {
  final String id;
  final String data;

  VideoInfoDTO({
    required this.id,
    required this.data,
  });

  factory VideoInfoDTO.fromJson(Map<String, dynamic> json) {
    return VideoInfoDTO(
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
