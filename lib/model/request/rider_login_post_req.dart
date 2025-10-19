class RiderLoginPostRequest {
  String phone;
  String password;

  RiderLoginPostRequest({required this.phone, required this.password});

  Map<String, dynamic> toJson() => {"phone": phone, "password": password};
}
