class ImageFile {
  final String id;
  final String name;
  final String contentType;
  final int size;
  final String url;

  ImageFile({
    required this.id,
    required this.name,
    required this.contentType,
    required this.size,
    required this.url,
  });

  factory ImageFile.fromJson(Map<String, dynamic> json) {
    return ImageFile(
      id: json['id'],
      name: json['name'],
      contentType: json['contentType'],
      size: json['size'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contentType': contentType,
      'size': size,
      'url': url,
    };
  }
}

class ImageInfoDTO {
  final String id;
  final String data;

  ImageInfoDTO({required this.id, required this.data});

  factory ImageInfoDTO.fromJson(Map<String, dynamic> json) {
    return ImageInfoDTO(
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
