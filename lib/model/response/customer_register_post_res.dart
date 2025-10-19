// To parse this JSON data, do
//
//     final customerRegisterPostResponse = customerRegisterPostResponseFromJson(jsonString);

import 'dart:convert';

CustomerRegisterPostResponse customerRegisterPostResponseFromJson(String str) =>
    CustomerRegisterPostResponse.fromJson(json.decode(str));

String customerRegisterPostResponseToJson(CustomerRegisterPostResponse data) =>
    json.encode(data.toJson());

class CustomerRegisterPostResponse {
  String message;
  User user;

  CustomerRegisterPostResponse({required this.message, required this.user});

  factory CustomerRegisterPostResponse.fromJson(Map<String, dynamic> json) =>
      CustomerRegisterPostResponse(
        message: json["message"],
        user: User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "user": user.toJson()};
}

class User {
  int id;
  String phone;
  String name;
  dynamic profilePic;

  User({
    required this.id,
    required this.phone,
    required this.name,
    required this.profilePic,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    phone: json["phone"],
    name: json["name"],
    profilePic: json["profile_pic"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "phone": phone,
    "name": name,
    "profile_pic": profilePic,
  };
}
