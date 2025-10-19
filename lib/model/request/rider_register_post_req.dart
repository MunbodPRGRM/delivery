class RiderRegisterPostRequest {
  String phone;
  String password;
  String name;
  String? profilePic;
  String? vehiclePic;
  String? plateNumber;

  RiderRegisterPostRequest({
    required this.phone,
    required this.password,
    required this.name,
    this.profilePic,
    this.vehiclePic,
    this.plateNumber,
  });

  Map<String, dynamic> toJson() => {
    "phone": phone,
    "password": password,
    "name": name,
    "profile_pic": profilePic,
    "vehicle_pic": vehiclePic,
    "plate_number": plateNumber,
  };
}
