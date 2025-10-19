// To parse this JSON data, do
//
//     final customerLoginPostRequest = customerLoginPostRequestFromJson(jsonString);

import 'dart:convert';

CustomerLoginPostRequest customerLoginPostRequestFromJson(String str) =>
    CustomerLoginPostRequest.fromJson(json.decode(str));

String customerLoginPostRequestToJson(CustomerLoginPostRequest data) =>
    json.encode(data.toJson());

class CustomerLoginPostRequest {
  String phone;
  String password;

  CustomerLoginPostRequest({required this.phone, required this.password});

  factory CustomerLoginPostRequest.fromJson(Map<String, dynamic> json) =>
      CustomerLoginPostRequest(
        phone: json["phone"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {"phone": phone, "password": password};
}
