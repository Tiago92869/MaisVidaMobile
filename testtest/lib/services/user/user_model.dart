import 'dart:convert';

class Token {
  final String accessToken;
  final String refreshToken;

  Token({required this.accessToken, required this.refreshToken});

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }
}

class PasswordUpdateDTO {
  final String currentPassword;
  final String newPassword;

  PasswordUpdateDTO({required this.currentPassword, required this.newPassword});

  Map<String, dynamic> toJson() {
    return {'currentPassword': currentPassword, 'newPassword': newPassword};
  }
}

class User {
  final String id;
  final String firstName;
  final String secondName;
  final String email;
  final String city;
  final String aboutMe;
  final DateTime dateOfBirth;
  final String emergencyContact; // Added emergencyContact field
  final String? profileImage; // New nullable profileImage field
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.firstName,
    required this.secondName,
    required this.email,
    required this.city,
    required this.aboutMe,
    required this.dateOfBirth,
    required this.emergencyContact, // Added emergencyContact to constructor
    this.profileImage, // Add profileImage to the constructor
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      secondName: json['secondName'],
      email: json['email'],
      city: json['city'],
      aboutMe: json['aboutMe'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      emergencyContact:
          json['emergencyContact'] ?? '', // Parse emergencyContact
      profileImage: json['profileImage'], // Parse profileImage
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'secondName': secondName,
      'email': email,
      'city': city,
      'aboutMe': aboutMe,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'emergencyContact': emergencyContact, // Include emergencyContact in JSON
      'profileImage': profileImage, // Include profileImage in JSON
    };
  }

  @override
  String toString() {
    return jsonEncode(this.toJson());
  }
}

class CreateUser {
  final String id; // This will be empty when creating a new user
  final String firstName;
  final String secondName;
  final String email;
  final String city;
  final String aboutMe;
  final DateTime dateOfBirth;
  final String password;

  CreateUser({
    required this.id,
    required this.firstName,
    required this.secondName,
    required this.email,
    required this.city,
    required this.aboutMe,
    required this.dateOfBirth,
    required this.password,
  });

  // Convert the object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'secondName': secondName,
      'email': email,
      'city': city,
      'aboutMe': aboutMe,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'password': password,
    };
  }
}

class ImageInfoDTO {
  final String id;
  final String data;

  ImageInfoDTO({required this.id, required this.data});

  factory ImageInfoDTO.fromJson(Map<String, dynamic> json) {
    return ImageInfoDTO(
      id: json['id'] as String,
      data: json['data'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
    };
  }
}

DateTime? parseDate(String? date) => date != null ? DateTime.parse(date) : null;
