class RiderRegisterPostResponse {
  String message;
  Rider rider;

  RiderRegisterPostResponse({required this.message, required this.rider});

  factory RiderRegisterPostResponse.fromJson(Map<String, dynamic> json) =>
      RiderRegisterPostResponse(
        message: json["message"] ?? "",
        rider: Rider.fromJson(json["rider"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "rider": rider.toJson(),
  };
}

class Rider {
  int id;
  String phone;
  String name;
  String? profilePic; // รูป profile อาจไม่มี
  String? vehiclePic; // รูป vehicle อาจไม่มี
  String? plateNumber; // plate number อาจไม่มี

  Rider({
    required this.id,
    required this.phone,
    required this.name,
    this.profilePic,
    this.vehiclePic,
    this.plateNumber,
  });

  factory Rider.fromJson(Map<String, dynamic> json) => Rider(
    id: json["id"] ?? 0,
    phone: json["phone"] ?? "",
    name: json["name"] ?? "",
    profilePic: json["profile_pic"],
    vehiclePic: json["vehicle_pic"],
    plateNumber: json["plate_number"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "phone": phone,
    "name": name,
    "profile_pic": profilePic,
    "vehicle_pic": vehiclePic,
    "plate_number": plateNumber,
  };
}
