class CustomerRegisterPostRequest {
  String phone;
  String password;
  String name;
  String? profilePic; // เปลี่ยนเป็น nullable
  String address;
  double latitude;
  double longitude;

  CustomerRegisterPostRequest({
    required this.phone,
    required this.password,
    required this.name,
    this.profilePic, // optional
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory CustomerRegisterPostRequest.fromJson(Map<String, dynamic> json) => CustomerRegisterPostRequest(
        phone: json["phone"],
        password: json["password"],
        name: json["name"],
        profilePic: json["profile_pic"],
        address: json["address"],
        latitude: json["latitude"]?.toDouble() ?? 0.0,
        longitude: json["longitude"]?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        "phone": phone,
        "password": password,
        "name": name,
        "profile_pic": profilePic,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
      };
}
