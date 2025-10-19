import 'dart:convert';

// To parse this JSON data
CustomerLoginPostResponse customerLoginPostResponseFromJson(String str) =>
    CustomerLoginPostResponse.fromJson(json.decode(str));

String customerLoginPostResponseToJson(CustomerLoginPostResponse data) =>
    json.encode(data.toJson());

// Model สำหรับ Login Response
class CustomerLoginPostResponse {
  String message;
  User user;

  CustomerLoginPostResponse({required this.message, required this.user});

  factory CustomerLoginPostResponse.fromJson(Map<String, dynamic> json) =>
      CustomerLoginPostResponse(
        message: json["message"],
        user: User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "user": user.toJson()};
}

// Model สำหรับ User
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
