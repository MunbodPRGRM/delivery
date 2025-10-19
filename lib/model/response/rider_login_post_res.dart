class RiderLoginPostResponse {
  String message;
  Rider rider;

  RiderLoginPostResponse({required this.message, required this.rider});

  factory RiderLoginPostResponse.fromJson(Map<String, dynamic> json) =>
      RiderLoginPostResponse(
        message: json["message"],
        rider: Rider.fromJson(json["rider"]),
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
  String? profilePic;
  String? vehiclePic;
  String? plateNumber;

  Rider({
    required this.id,
    required this.phone,
    required this.name,
    this.profilePic,
    this.vehiclePic,
    this.plateNumber,
  });

  factory Rider.fromJson(Map<String, dynamic> json) => Rider(
    id: json["id"],
    phone: json["phone"],
    name: json["name"],
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
